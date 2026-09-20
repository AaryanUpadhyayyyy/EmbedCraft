import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../models/campaign.dart';
import '../../models/nudge_model.dart';
import '../../utilities/sharedHelper/campaign_layers.dart';
import '../../utilities/sharedHelper/design_scale.dart';
import '../layers/ninja_layer_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'Floater_render_v2.dart';

/// FullScreen Nudge Renderer
///
/// Wraps FloaterRenderV2 to provide a full-screen experience.
/// Forces configuration to fill the screen and disables dragging.
class FullScreenNudgeRenderer extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback? onDismiss;
  final Function(String, Map<String, dynamic>?)? onCTAClick;
  final VoidCallback? onImpression; // FIX: Added onImpression

  const FullScreenNudgeRenderer({
    Key? key,
    required this.campaign,
    this.onDismiss,
    this.onCTAClick,
    this.onImpression,
  }) : super(key: key);

  @override
  _FullScreenNudgeRendererState createState() =>
      _FullScreenNudgeRendererState();
}

class _FullScreenNudgeRendererState extends State<FullScreenNudgeRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    
    // Track impression
    if (widget.onImpression != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onImpression!();
      });
    }

    final configMap = widget.campaign.config as Map<String, dynamic>? ?? {};
    final animConfig = configMap['animation'] as Map<String, dynamic>?;
    final durationMs = (animConfig?['duration'] as num?)?.toInt() ?? 300;

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationMs));

    // Backdrop Fade Animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _initMedia(configMap);
    _controller.forward();
  }

  void _initMedia(Map<String, dynamic> configMap) {
    final media = configMap['media'] as Map<String, dynamic>?;
    if (media == null) return;
    
    final type = media['type']?.toString() ?? 'unknown';
    final url = media['url']?.toString() ?? '';
    final isMuted = media['muted'] == true;
    final loop = media['loop'] == true;
    final autoplay = media['autoplay'] ?? media['autoPlay'] ?? true;
    
    final isDirectVideo = type == 'video' || url.endsWith('.mp4') || url.endsWith('.webm') || url.endsWith('.m3u8');
    final youtubeId = YoutubePlayer.convertUrlToId(url);
    
    if (youtubeId != null || type == 'youtube') {
      final finalId = youtubeId ?? url;
      _youtubeController = YoutubePlayerController(
        initialVideoId: finalId,
        flags: YoutubePlayerFlags(
          autoPlay: autoplay,
          mute: isMuted,
          loop: loop,
          hideControls: true,
          disableDragSeek: true,
          enableCaption: false,
        ),
      );
    } else if (isDirectVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (!mounted) return;
          if (autoplay) _videoController!.play();
          _videoController!.setVolume(isMuted ? 0 : 1);
          _videoController!.setLooping(loop);
          setState(() {});
        }).catchError((_) {
          _videoController?.dispose();
          _videoController = null;
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final originalConfig =
        widget.campaign.config as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> raw = Map<String, dynamic>.from(originalConfig);

    // Force Full Screen Defaults
    raw['position'] = 'center'; // Conceptually centered
    raw['width'] = '100%';
    raw['height'] = '100%';

    // Disable interactions that don't make sense in FS
    raw['draggable'] = false;
    raw['expanded'] = false;

    // Veto dimensions that corrupt fullscreen
    raw['borderRadius'] = 0;
    raw['borderWidth'] = 0;
    raw['shadow'] = {'enabled': false};

    // Disable internal overlay (handled by wrapper perfectly now)
    raw['overlay'] = {'enabled': false};

    // Ensure Controls - merge from both root and fullscreenConfig
    // Disable internal overlay and media (handled by wrapper perfectly now)
    raw['overlay'] = {'enabled': false};
    raw['media'] = null;
    raw['backgroundColor'] = 'transparent';

    // Ensure Controls - merge from both root and fullscreenConfig
    var controls = <String, dynamic>{};
    if (raw['controls'] is Map) {
      controls = Map<String, dynamic>.from(raw['controls']);
    }
    // FIX: fullscreenConfig.controls is the primary source for fullscreen campaigns
    final fsConfig = raw['fullscreenConfig'] as Map<String, dynamic>? ?? {};
    final fsControls = fsConfig['controls'] as Map? ?? {};
    // Merge fullscreenConfig controls (higher priority) into root controls
    for (final entry in fsControls.entries) {
      controls[entry.key.toString()] = entry.value;
    }

    // Ensure Close Button Defaults while respecting the merged config
    final existingCloseBtn = controls['closeButton'] as Map? ?? {};
    controls['closeButton'] = {
      'show': raw['showCloseButton'] ?? existingCloseBtn['show'] ?? true,
      'position': existingCloseBtn['position'] ?? 'top-right',
      'size': existingCloseBtn['size'] ?? 24,
      'darkBackground': true,
    };
    controls['expandButton'] = {'show': false}; // No expand in FS

    // Ensure Progress Bar is preserved
    if (controls['progressBar'] == null) {
      controls['progressBar'] = {'show': false};
    }

    raw['controls'] = controls;

    // Ensure Behavior (Double Tap / Tap)
    var behavior = <String, dynamic>{};
    if (raw['behavior'] is Map) {
      behavior = Map<String, dynamic>.from(raw['behavior']);
    }

    raw['behavior'] = {
      ...behavior,
      'draggable': false,
      'snapToCorner': false,
      'doubleTapToDismiss': behavior['doubleTapToDismiss'] ?? false,
      'tapToDismiss': behavior['tapToDismiss'] ?? false,
    };

    final config = NudgeConfig.fromJson(raw);
    // DASHBOARD PARITY: Brutally strip 10px structural paddings from Fullscreen layouts
    // This enforces true full-bleed by nullifying container paddings that the dashboard routinely inserts,
    // which cause a transparent gap revealing the underlying white base background.
    final List<dynamic> rawLayers = widget.campaign.layers ?? [];
    final List<Layer> layers = [];
    final Map<String, dynamic> scrubbedLayers = {};

    for (var l in rawLayers) {
      final map = Map<String, dynamic>.from(l as Map);
      final style = map['style'] is Map ? Map<String, dynamic>.from(map['style']) : null;
      
      final parent = map['parent'];
      bool isRoot = parent == null || parent == 'root' || parent == '';
      
      bool isChildOfRoot = false;
      if (parent != null && scrubbedLayers.containsKey(parent)) {
         final pParent = scrubbedLayers[parent]['parent'];
         if (pParent == null || pParent == 'root' || pParent == '') {
            isChildOfRoot = true;
         }
      }

      if (isRoot || isChildOfRoot) {
         if (map['type'] == 'container' && style != null) {
            style.remove('padding');
            style.remove('paddingTop');
            style.remove('paddingBottom');
            style.remove('paddingLeft');
            style.remove('paddingRight');
            map['style'] = style;
         }
      }
      scrubbedLayers[map['id']] = map;
      
      // Inject global mapped state if present
      Map<String, dynamic>? globalMappedState;
      if (widget.campaign.config['container'] is List && (widget.campaign.config['container'] as List).isNotEmpty) {
         final containerFirst = (widget.campaign.config['container'] as List).first;
         if (containerFirst is Map && containerFirst['raw'] is Map && containerFirst['raw']['mappedState'] != null) {
            globalMappedState = Map<String, dynamic>.from(containerFirst['raw']['mappedState']);
         }
      }
      
      var finalMap = map;
      if (globalMappedState != null) {
         finalMap = NinjaLayerUtils.applyMappedData(finalMap, globalMappedState);
      }
      
      layers.add(Layer.fromJson(finalMap));
    }
    final fsScale = DesignScale.fromContext(context);
    final scaleX = fsScale.scaleX;
    final scaleY = fsScale.scaleY;

    // Grab the original overlay before we vetoed it in the modified config
    final overlay = originalConfig['overlay'] as Map<String, dynamic>?;

    // Extract Base Backgrounds (Color or Media)
    final bgColor =
        NinjaLayerUtils.parseColor(originalConfig['backgroundColor']) ??
            Colors.transparent;
    final media = originalConfig['media'] as Map<String, dynamic>?;
    final mediaType = media?['type']?.toString();
    final mediaUrl = media?['url']?.toString();
    final mediaFit = media?['fit']?.toString() == 'contain'
        ? BoxFit.contain
        : media?['fit']?.toString() == 'fill'
            ? BoxFit.fill
            : BoxFit.cover;

    return Stack(children: [
      // 1. Base Canvas Color
      Positioned.fill(child: Container(color: bgColor)),

      // 2. Base Media Layer (Image, Video, YouTube Support)
      if ((mediaType == 'youtube' || _youtubeController != null) && _youtubeController != null)
        Positioned.fill(
          child: FittedBox(
            fit: mediaFit,
            child: SizedBox(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height,
               child: YoutubePlayer(controller: _youtubeController!, showVideoProgressIndicator: false),
            )
          )
        )
      else if ((mediaType == 'video' || _videoController != null) && _videoController != null && _videoController!.value.isInitialized)
        Positioned.fill(
          child: FittedBox(
            fit: mediaFit,
            child: SizedBox(
               width: _videoController!.value.size.width,
               height: _videoController!.value.size.height,
               child: VideoPlayer(_videoController!),
            )
          )
        )
      else if (mediaType == 'image' && mediaUrl != null && mediaUrl.isNotEmpty)
        Positioned.fill(
          child: Image.network(
            mediaUrl,
            fit: mediaFit,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),

      // Backdrop Overlay (Scrim)
      if (overlay != null && overlay['enabled'] == true)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (overlay['dismissOnClick'] ?? true) _handleDismiss();
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: NinjaLayerUtils.parseColor(overlay['color'])?.withValues(
                      alpha: (overlay['opacity'] as num?)?.toDouble() ?? 0.5) ??
                  Colors.black54,
              child: (overlay['blur'] as num? ?? 0) > 0
                  ? BackdropFilter(
                      filter: ui.ImageFilter.blur(
                          // Scale the blur identically to TSX
                          sigmaX: (overlay['blur'] as num).toDouble() * scaleX,
                          sigmaY: (overlay['blur'] as num).toDouble() * scaleX),
                      child: Container(color: Colors.transparent),
                    )
                  : null,
            ),
          ),
        ),

      // Content Layer - Fills screen
      Positioned.fill(
        child: FloaterRenderV2(
          key: ValueKey('fs_${widget.campaign.id}'),
          layers: layers,
          config: config,
          scale: scaleX,
          scaleY: scaleY,
          // FIX: Pass campaignId so STW can call the backend game engine.
          // Without this, NinjaSpinTheWheelLayer gets cmpId='' and falls back
          // to local-only spin with isWin=false, causing "Better Luck" every time.
          campaignId: widget.campaign.id,
          onDismiss: _handleDismiss,
          onAction: widget.onCTAClick,
          onNavigate: (screen) =>
              widget.onCTAClick?.call('navigate', {'screen': screen}),
          onInterfaceAction: (id) =>
              widget.onCTAClick?.call('interface', {'interfaceId': id}),
        ),
      ),
    ]);
  }
}
