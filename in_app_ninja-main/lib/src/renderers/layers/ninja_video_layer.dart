import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../utils/ninja_sdk_safe.dart';
import 'ninja_layer_utils.dart';

/// Network video layer using [video_player] only. Provide a direct video URL
/// (e.g. `.mp4`, `.m3u8`, `.webm`).
class NinjaVideoLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(String, Map<String, dynamic>)? onAction;
  final bool isActive;

  const NinjaVideoLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scale = 1.0,
    this.onAction,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<NinjaVideoLayer> createState() => _NinjaVideoLayerState();
}

class _NinjaVideoLayerState extends State<NinjaVideoLayer> {
  VideoPlayerController? _videoController;
  bool _isInit = false;
  bool _loadFailed = false;
  // Dashboard parity: track previous playing state to fire notifications only on CHANGE
  // (prevents every-frame dispatch and buffering false-positive on video_completion)
  bool _wasPlaying = false;

  late Map<String, dynamic> _content;
  late Map<String, dynamic> _style;
  late String _url;
  late bool _autoPlay;
  late bool _muted;
  late bool _loop;

  @override
  void initState() {
    super.initState();
    _parseConfig();
    _initVideo();
  }

  @override
  void didUpdateWidget(NinjaVideoLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        if (_autoPlay) {
          final vc = _videoController;
          if (vc != null) {
            ninjaSdkSafeUnawaited(
              vc.seekTo(Duration.zero).then((_) {
                if (mounted) _videoController?.play();
              }),
              context: 'NinjaVideoLayer seekTo',
            );
          }
        }
      } else {
        _videoController?.pause();
      }
    }

    if (widget.layer != oldWidget.layer) {
      _parseConfig();

      final oldUrl = oldWidget.layer['content']?['url']?.toString() ?? '';
      final oldMuted = oldWidget.layer['content']?['muted'] ?? true;
      final oldAutoPlay = oldWidget.layer['content']?['autoPlay'] ?? true;

      if (_url != oldUrl) {
        // URL changed — full re-init
        _disposeVideo();
        _initVideo();
      } else {
        // Dashboard parity: video element reacts to muted/autoPlay prop changes live
        // React JSX: muted={isMuted} autoPlay={isActive} update without re-mounting
        if (_muted != oldMuted) {
          _videoController?.setVolume(_muted ? 0 : 1);
        }
        if (_autoPlay != oldAutoPlay) {
          if (_autoPlay && widget.isActive) {
            // Dashboard line 282-284: videoRef.current.currentTime = 0; videoRef.current.play()
            // ALWAYS reset to beginning when the slide becomes active — matches Dashboard behavior.
            // Without seekTo, re-visiting a slide would resume mid-video.
            final vc = _videoController;
            if (vc != null) {
              ninjaSdkSafeUnawaited(
                vc.seekTo(Duration.zero).then((_) {
                  if (mounted) _videoController?.play();
                }),
                context: 'NinjaVideoLayer seekTo',
              );
            }
          } else {
            _videoController?.pause();
          }
        }
      }
    }
  }

  void _parseConfig() {
    _content = widget.layer['content'] ?? {};
    _style = widget.layer['style'] ?? {};
    _url = (_content['url'] ?? _content['imageUrl'] ?? '').toString().trim();

    _autoPlay = _content['autoPlay'] ?? true;
    _muted = _content['muted'] ?? true;
    _loop = _content['loop'] ?? true;
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isInit = false;
    _loadFailed = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _initVideo() {
    if (_url.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(_url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInit = true;
          _loadFailed = false;
        });
        final c = _videoController!;
        if (_autoPlay && widget.isActive) c.play();
        c.setLooping(_loop);
        c.setVolume(_muted ? 0 : 1);

        if (_autoPlay && widget.isActive) {
          NinjaVideoStatusNotification(true).dispatch(context);
        }
      }).catchError((Object _) {
        if (!mounted) return;
        _videoController?.dispose();
        _videoController = null;
        setState(() {
          _isInit = false;
          _loadFailed = true;
        });
      })
      ..addListener(_onVideoListener);
  }

  void _onVideoListener() {
    if (_videoController == null ||
        !mounted ||
        !_videoController!.value.isInitialized) return;

    final isPlaying = _videoController!.value.isPlaying;
    final isBuffering = _videoController!.value.isBuffering;

    // Dashboard parity: only dispatch notification on ACTUAL state CHANGE, not every frame.
    // This prevents 60/sec notifications during playback and avoids buffering false-positives.
    // Dashboard uses 'onPlaying' and 'onEnded' events which fire only on state transitions.
    if (isPlaying == _wasPlaying) return;
    _wasPlaying = isPlaying;

    if (isPlaying) {
      NinjaVideoStatusNotification(true).dispatch(context);
    } else if (!isBuffering) {
      // Only dispatch 'stopped' when NOT buffering.
      // Buffering = isPlaying:false + isBuffering:true (temporary, video will resume).
      // Dashboard onEnded fires ONLY at natural video completion, not on buffering.
      NinjaVideoStatusNotification(false).dispatch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = NinjaLayerUtils.parseResponsiveSize(_style['width'], context,
        isVertical: false, parentSize: widget.parentSize);
    final height = NinjaLayerUtils.parseResponsiveSize(
        _style['height'], context,
        isVertical: true, parentSize: widget.parentSize);

    final borderRadiusVal = _style['borderRadius'];
    BorderRadius finalRadius;
    if (borderRadiusVal is Map) {
      finalRadius = BorderRadius.only(
        topLeft: Radius.circular(
            (NinjaLayerUtils.parseDouble(borderRadiusVal['topLeft'], context) ??
                    0) *
                widget.scale),
        topRight: Radius.circular((NinjaLayerUtils.parseDouble(
                    borderRadiusVal['topRight'], context) ??
                0) *
            widget.scale),
        bottomLeft: Radius.circular((NinjaLayerUtils.parseDouble(
                    borderRadiusVal['bottomLeft'], context) ??
                0) *
            widget.scale),
        bottomRight: Radius.circular((NinjaLayerUtils.parseDouble(
                    borderRadiusVal['bottomRight'], context) ??
                0) *
            widget.scale),
      );
    } else {
      final r = NinjaLayerUtils.parseDouble(borderRadiusVal, context) ?? 0;
      finalRadius = BorderRadius.circular(r * widget.scale);
    }

    final fitStr = _style['objectFit'] ?? 'cover';
    final BoxFit fit = NinjaLayerUtils.parseBoxFit(fitStr);

    Widget content;
    if (_url.isEmpty || _loadFailed) {
      content = ColoredBox(
        color: Colors.black26,
        child: Center(
          child: Icon(
            Icons.videocam_off_outlined,
            color: Colors.white.withValues(alpha: 0.6),
            size: 40 * widget.scale,
          ),
        ),
      );
    } else if (_videoController != null && _isInit) {
      content = VideoPlayer(_videoController!);
    } else {
      content = Container(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_videoController != null && _isInit) {
      content = FittedBox(
        fit: fit,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: content,
        ),
      );
    }

    final opacity = NinjaLayerUtils.parseDouble(_style['opacity']) ?? 1.0;

    final borderWidth =
        (NinjaLayerUtils.parseDouble(_style['borderWidth'], context) ?? 0) *
            widget.scale;
    final borderColor =
        NinjaLayerUtils.parseColor(_style['borderColor']) ?? Colors.transparent;
    final hasBorder = borderWidth > 0;

    List<BoxShadow>? shadows;
    if (_style['shadowEnabled'] == true) {
      final sList = NinjaLayerUtils.parseShadowFromStyle(_style, context);
      if (sList != null) {
        shadows = sList
            .map((s) => BoxShadow(
                color: s.color,
                blurRadius: s.blurRadius * widget.scale,
                spreadRadius: s.spreadRadius * widget.scale,
                offset: Offset(
                    s.offset.dx * widget.scale, s.offset.dy * widget.scale)))
            .toList();
      }
    } else {
      final parsed = NinjaLayerUtils.parseShadows(_style['boxShadow'], context);
      if (parsed != null) {
        shadows = parsed
            .map((s) => BoxShadow(
                color: s.color,
                blurRadius: s.blurRadius * widget.scale,
                spreadRadius: s.spreadRadius * widget.scale,
                offset: Offset(
                    s.offset.dx * widget.scale, s.offset.dy * widget.scale)))
            .toList();
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: finalRadius,
        border: hasBorder
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(opacity: opacity, child: content),
    );
  }
}
