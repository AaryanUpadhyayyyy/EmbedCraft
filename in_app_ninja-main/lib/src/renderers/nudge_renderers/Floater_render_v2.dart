import 'package:flutter/material.dart';
import 'package:in_app_ninja/src/models/nudge_model.dart';
import '../../app_ninja.dart';
import '../../callbacks/ninja_callback_manager.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import '../layers/ninja_text_layer.dart';
import '../layers/ninja_button_layer.dart';
import '../layers/ninja_image_layer.dart';
import '../layers/ninja_input_layer.dart';
import '../layers/ninja_copy_button_layer.dart';
import '../layers/ninja_container_layer.dart';
import 'dart:ui' as ui;
import '../layers/ninja_layer_utils.dart';
import '../../utilities/sharedHelper/design_scale.dart';
import '../layers/ninja_countdown_layer.dart';
import 'package:video_player/video_player.dart';
import '../../utilities/utilHelper/ninja_url_launcher.dart';
import '../layers/ninja_scratch_foil_layer.dart';
import '../layers/ninja_carousel_layer.dart';
import '../layers/ninja_video_layer.dart'; // Phase 8: Video Layer
import '../layers/ninja_spinthewheel_layer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../layers/ninja_grid_container_layer.dart';
import '../layers/ninja_lottie_layer.dart';
import '../layers/ninja_rive_layer.dart';
import '../layers/ninja_custom_html_layer.dart';
import '../../utils/ninja_logger.dart';

/// Phase 1: Structure Setup
/// Converting TSX FloaterRenderer to Dart FloaterRenderV2
class FloaterRenderV2 extends StatefulWidget {
  final List<Layer>
      layers; // Assuming Layer is defined in nudge_model or similar
  final String? selectedLayerId;
  final Function(String?)? onLayerSelect;
  final NudgeConfig config; // Assuming NudgeConfig maps to the config prop
  final Function()? onDismiss;
  final Function(String screenName)? onNavigate; // Action Parity
  final Function(String interfaceId)? onInterfaceAction; // Action Parity
  final Function(String, Map<String, dynamic>?)?
      onAction; // Generic Action Support
  final Function()? onImpression; // Impression Tracking (Fixed)
  final double? scale; // Bug 21: Scaling Prop
  final double? scaleY; // Bug 21: Scaling Prop
  final String? campaignId; // Campaign ID for layer rendering
  // Add other props as needed

  const FloaterRenderV2({
    Key? key,
    required this.layers,
    this.selectedLayerId,
    this.onLayerSelect,
    required this.config,
    this.onDismiss,
    this.onNavigate,
    this.onInterfaceAction,
    this.onAction,
    this.onImpression,
    this.scale = 1.0,
    this.scaleY = 1.0,
    this.campaignId,
  }) : super(key: key);

  @override
  _FloaterRenderV2State createState() => _FloaterRenderV2State();
}

class _FloaterRenderV2State extends State<FloaterRenderV2>
    with TickerProviderStateMixin {
  // State variables from TSX
  bool isExpanded = false;
  bool isMuted = true;
  bool isPlaying = true;
  double videoProgress = 0;
  // Offset dragOffset = Offset.zero; // Removed in favor of _dragPosition
  bool isDragging = false;

  // Video (direct URL only; [video_player])
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  // Use ValueNotifier for performance
  final ValueNotifier<double> _videoProgressNotifier = ValueNotifier(0.0);

  // Phase 5: Entrance Animation Parity
  AnimationController? _entranceController;
  Animation<double>? _entranceAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _bounceAnimation;

  // Phase 6: Animated Stripe (Parity)ld
  // Image Caching (Bug Fix: Blinking)
  // Image Caching (Bug Fix: Blinking)
  ImageProvider? _cachedBgProvider;
  // Bug Fix: Restore size cache for safe clamp
  // _cachedFloaterSize removed as unused

  // Drag State (Refactor for Smoothness)
  Offset? _dragPosition;
  final GlobalKey _floaterKey = GlobalKey();

  final ScrollController _scrollController =
      ScrollController(); // Bug Fix: Assertion Error

  Timer? _autoDismissTimer;

  // Parity Fix: Stripe Animation Controller
  late AnimationController _stripeController;

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _scrollController.dispose();
    _entranceController?.dispose();
    _videoController?.dispose();
    _youtubeController?.dispose();
    _videoProgressNotifier.dispose();
    _stripeController.dispose(); // Dispose stripe controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // NinjaLog.d('AppNinja', '🔧 [FloaterV2] initState (Key: ${widget.key})');

    // CRITICAL DEBUG: Show what layers we received from backend
    NinjaLog.d('AppNinja', 
        '[FloaterV2] Received ${widget.layers.length} layers from campaign:');
    for (var layer in widget.layers) {
      final raw = layer.raw;
      NinjaLog.d('AppNinja', 
          '  - ${raw['id']}: type=${raw['type']}, parent=${raw['parent'] ?? "NULL"}');
    }

    // Fix: Track impression only ONCE on mount
    if (widget.onImpression != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onImpression!();
      });
    }

    // Initialize state from config
    // State initialization matches TSX useState defaults
    isExpanded = widget.config.expanded ?? false;
    isMuted = widget.config.media?.muted ?? true;
    isPlaying = widget.config.media?.autoPlay ?? true;

    // Video Init Phase
    _initVideo();

    // Entrance Animation Init (Phase 5)
    // Entrance Animation Init (Phase 5)
    _initEntranceAnimation();

    // Cache Bg Image
    _resolveBgImage();

    // Initial size update frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _cachedFloaterSize removed as unused
    });

    // Bug 4: Record Mount time
    _mountTime = DateTime.now().millisecondsSinceEpoch;

    // Auto Dismiss Logic (Timing)
    _canInitAutoDismiss();

    // Fix: Init Stripe Controller for animated progress bars
    _stripeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  void _resolveBgImage() {
    // Logic extracted from _buildFloaterContent
    final floaterLayer = widget.layers.firstWhere(
      (l) =>
          l.type == 'container' &&
          (l.name == 'Floater Container' || l.name == 'FloaterContainer'),
      orElse: () => widget.layers.isNotEmpty
          ? widget.layers.first
          : Layer(id: 'fallback', type: 'container', content: {}, raw: {}),
    );

    ImageProvider? newProvider;

    if (widget.config.media?.url != null &&
        widget.config.media!.url!.trim().isNotEmpty &&
        (widget.config.media?.type == 'image' ||
            widget.config.media?.type == null)) {
      final mUrl = widget.config.media!.url!;
      if (mUrl.startsWith('data:')) {
        try {
          final base64String =
              mUrl.split(',').last.replaceAll(RegExp(r'\s+'), '');
          newProvider = MemoryImage(base64Decode(base64String));
        } catch (e) {
          NinjaLog.d('AppNinja', "FloaterRenderV2: Error decoding media base64: $e");
        }
      } else if (mUrl.startsWith('http')) {
        newProvider = NetworkImage(mUrl);
      }
    } else if (widget.config.backgroundImageUrl != null &&
        widget.config.backgroundImageUrl!.trim().isNotEmpty) {
      final bgUrl = widget.config.backgroundImageUrl!;
      if (bgUrl.startsWith('data:')) {
        try {
          final base64String =
              bgUrl.split(',').last.replaceAll(RegExp(r'\s+'), '');
          newProvider = MemoryImage(base64Decode(base64String));
        } catch (e) {
          NinjaLog.d('AppNinja', "FloaterRenderV2: Error decoding bgUrl base64: $e");
        }
      } else if (bgUrl.startsWith('http')) {
        newProvider = NetworkImage(bgUrl);
      }
    } else if (floaterLayer.style?.backgroundImage != null &&
        floaterLayer.style!.backgroundImage!.startsWith('url')) {
      String url = floaterLayer.style!.backgroundImage!
          .replaceAll('url(', '')
          .replaceAll(')', '')
          .replaceAll('"', '')
          .replaceAll("'", "")
          .trim();
      if (url.isNotEmpty) {
        if (url.startsWith('data:')) {
          try {
            final base64String =
                url.split(',').last.replaceAll(RegExp(r'\s+'), '');
            newProvider = MemoryImage(base64Decode(base64String));
          } catch (e) {
            NinjaLog.d('AppNinja', "FloaterRenderV2: Error decoding style bg base64: $e");
          }
        } else if (url.startsWith('http')) {
          newProvider = NetworkImage(url);
        }
      }
    }

    setState(() {
      _cachedBgProvider = newProvider;
    });
  }

  void _initEntranceAnimation() {
    final type = widget.config.animation?.type;
    final durationMs = widget.config.animation?.duration ?? 300;

    if (type != null && type != 'none') {
      _entranceController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationMs),
      );

      // TSX Default easing is 'ease-out'
      // CSS ease-out is approx Cubic(0.0, 0.0, 0.2, 1.0)
      final curve = Curves.easeOut;

      _entranceAnimation = CurvedAnimation(
        parent: _entranceController!,
        curve: curve,
      );

      if (type == 'slide') {
        // TSX floater-slide: `transform: translateY(20px)` to `0`
        // We need to convert 20px to a fractional offset based on the widget size.
        // However, Flutter's SlideTransition takes a fractional offset (relative to its own size).
        // Since we don't know the exact size yet, an approximation or specific Tween is needed.
        // A standard fallback is a small fractional offset assuming an average height.
        // Assuming height ~200px, 20px is 0.1. Let's use 0.1 for closer parity than 0.2.
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1), // Adjusted for closer 20px parity
          end: Offset.zero,
        ).animate(_entranceAnimation!);
      } else if (type == 'bounce') {
        // TSX floater-bounce (4 steps):
        // 0%: scale(0.6)
        // 50%: scale(1.1)
        // 70%: scale(0.95)
        // 100%: scale(1.0)
        _bounceAnimation = TweenSequence<double>([
          TweenSequenceItem(
              tween: Tween(begin: 0.6, end: 1.1)
                  .chain(CurveTween(curve: Curves.easeInQuad)),
              weight: 50.0),
          TweenSequenceItem(
              tween: Tween(begin: 1.1, end: 0.95)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 20.0),
          TweenSequenceItem(
              tween: Tween(begin: 0.95, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 30.0),
        ]).animate(_entranceController!);
      }

      _entranceController!.forward();
    }
  }

  // Reactive State (didUpdateWidget) - Parity with React's useEffect/re-render
  @override
  void didUpdateWidget(FloaterRenderV2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 1. React to Config Changes (Mute/Autoplay)
    if (widget.config.media?.muted != oldWidget.config.media?.muted) {
      setState(() {
        isMuted = widget.config.media?.muted ?? true;
        _videoController?.setVolume(isMuted ? 0 : 1);
        if (isMuted) {
          _youtubeController?.mute();
        } else {
          _youtubeController?.unMute();
        }
      });
    }

    // 2. React to Expanded Change (External Control)
    if (widget.config.expanded != oldWidget.config.expanded &&
        widget.config.expanded != null) {
      setState(() {
        isExpanded = widget.config.expanded!;
      });
    }

    // 3. Update cached bg image if needed
    if (widget.config != oldWidget.config ||
        widget.layers != oldWidget.layers) {
      _resolveBgImage();
    }

    // 3. React to Media URL Change (Re-init Video)
    if (widget.config.media?.url != oldWidget.config.media?.url) {
      _disposeVideo();
      _initVideo();
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _youtubeController?.dispose();
    _youtubeController = null;
    _videoProgressNotifier.value = 0.0;
  }

  void _canInitAutoDismiss() {
    _autoDismissTimer?.cancel();
    final raw = widget.config.raw;
    final timing = raw['timing'];

    // Support nested timing object or flat duration
    dynamic durationVal = timing is Map ? timing['duration'] : raw['duration'];
    int duration = 0;

    if (durationVal is int)
      duration = durationVal;
    else if (durationVal is String) duration = int.tryParse(durationVal) ?? 0;

    if (duration > 0) {
      _autoDismissTimer = Timer(Duration(seconds: duration), () {
        if (mounted && widget.onDismiss != null) {
          widget.onDismiss!();
        }
      });
    }
  }

  // --- PHASE 8: VIDEO (network URL via [video_player] only) ---

  void _initVideo() {
    final media = widget.config.media;
    if (media == null || media.url == null || media.url!.isEmpty) return;

    final type = media.type ?? 'image';
    final url = media.url!;

    final String? youtubeId = YoutubePlayer.convertUrlToId(url);
    if (youtubeId != null || type == 'youtube') {
      final String finalId = youtubeId ?? url;
      _youtubeController = YoutubePlayerController(
        initialVideoId: finalId,
        flags: YoutubePlayerFlags(
          autoPlay: isPlaying,
          mute: isMuted,
          loop: media.loop ?? false,
          hideControls: true,
          disableDragSeek: true,
        ),
      )..addListener(() {
          if (!mounted) return;
          if (_youtubeController!.value.hasError) return;
          final position =
              _youtubeController!.value.position.inMilliseconds.toDouble();
          final duration =
              _youtubeController!.metadata.duration.inMilliseconds.toDouble();
          if (duration > 0) {
            _videoProgressNotifier.value = (position / duration) * 100;
          }
        });
      return;
    }

    final isDirectVideo = type == 'video' ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.webm') ||
        url.endsWith('.m3u8');

    if (!isDirectVideo) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        if (isPlaying) _videoController!.play();
        _videoController!.setLooping(media.loop ?? false);
        _videoController!.setVolume(isMuted ? 0 : 1);
      }).catchError((_) {
        _videoController?.dispose();
        _videoController = null;
        if (mounted) setState(() {});
      })
      ..addListener(_onVideoListener);
  }

  void _onVideoListener() {
    if (_videoController == null ||
        !mounted ||
        !_videoController!.value.isInitialized) return;

    final duration = _videoController!.value.duration.inMilliseconds;
    final position = _videoController!.value.position.inMilliseconds;
    if (duration > 0) {
      _videoProgressNotifier.value = (position / duration) * 100;
    }
  }

  Widget _buildVideo(double containerWidth, double containerHeight) {
    final fitStr = widget.config.media?.fit ?? 'cover';
    final fit = fitStr == 'contain' ? BoxFit.contain : BoxFit.cover;

    // Evaluate border radius for clipping
    double rValue =
        (widget.config.borderRadius ?? 0.0).toDouble() * (widget.scale ?? 1.0);
    BorderRadius videoRadius = BorderRadius.circular(rValue);

    if (_youtubeController != null) {
      return Positioned.fill(
        child: ClipRRect(
          borderRadius: videoRadius,
          child: FittedBox(
            fit: fit,
            child: SizedBox(
              width: containerWidth,
              height: containerHeight > 0 ? containerHeight : 200,
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: false,
                onReady: () {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return Positioned.fill(
        child: ClipRRect(
          borderRadius: videoRadius,
          child: FittedBox(
            fit: fit,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  // --- PHASE 9: CONTROLS OVERLAY ---

  Widget _buildControls() {
    final controls = widget.config.controls;

    // Helper to build a button
    Widget _buildBtn(
        {required IconData icon,
        required VoidCallback onTap,
        Map? styleConfig}) {
      // Resolve state-specific configuration (expanded vs unexpanded)
      Map? resolvedConfig = styleConfig;
      if (styleConfig != null) {
        final stateKey = isExpanded ? 'expanded' : 'unexpanded';
        if (styleConfig[stateKey] is Map) {
          resolvedConfig = {
            ...styleConfig,
            ...Map<String, dynamic>.from(styleConfig[stateKey])
          };
        }
      }

      // ROBUST: Check multiple keys for properties

      // Size
      var sizeVal = resolvedConfig?['size'] ??
          resolvedConfig?['iconSize'] ??
          resolvedConfig?['icon_size'];
      final size =
          (sizeVal as num? ?? 14).toDouble() * (widget.scale ?? 1.0); // Scaled

      // Color
      var colorVal = resolvedConfig?['color'] ??
          resolvedConfig?['iconColor'] ??
          resolvedConfig?['icon_color'];
      final color = NinjaLayerUtils.parseColor(colorVal) ?? Colors.white;

      // Background
      var bgVal = resolvedConfig?['backgroundColor'] ??
          resolvedConfig?['background_color'] ??
          resolvedConfig?['bg_color'];
      final bg = NinjaLayerUtils.parseColor(bgVal) ??
          Colors.black.withValues(alpha: 0.5);

      // Padding/Margin (Offset)
      final offsetX = (resolvedConfig?['offsetX'] as num? ?? 0).toDouble() *
          (widget.scale ?? 1.0);
      final offsetY = (resolvedConfig?['offsetY'] as num? ?? 0).toDouble() *
          (widget.scaleY ?? widget.scale ?? 1.0);

      // Icon Image URL
      final iconUrl = resolvedConfig?['iconUrl'];

      return GestureDetector(
        onTap: onTap,
        child: Transform(
          transform: Matrix4.translationValues(offsetX, offsetY, 0),
          child: ClipOval(
            // FL15 Fix: Removed extra EdgeInsets.symmetric(horizontal: 4) wrapper — TSX only uses gap on parent Row
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: bg,
                padding: EdgeInsets.all(6 *
                    (widget.scale ??
                        1.0)), // FL4 Fix: Scale padding to match TSX safeScale(6, scale)
                child: (iconUrl != null && iconUrl.toString().isNotEmpty)
                    ? Image.network(
                        iconUrl,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                        errorBuilder: (c, o, s) =>
                            Icon(icon, size: size, color: color),
                      )
                    : Icon(icon, size: size, color: color),
              ),
            ),
          ),
        ),
      );
    }

    // Groups
    List<Widget> topLeft = [];
    List<Widget> topRight = [];
    List<Widget> bottomLeft = [];
    List<Widget> bottomRight = [];

    // Expand Button
    final expandBtn = controls?['expandButton'];
    bool showExpand =
        widget.config.expanded != true && (expandBtn?['show'] == true);

    if (showExpand) {
      String pos = expandBtn?['position'] ?? 'top-left';
      Widget btn = _buildBtn(
          // Dashboard uses Lucide 'Expand' (4 arrows out) / 'Minimize' (4 arrows in)
          // Material Parity: zoom_out_map (4 out), zoom_in_map (4 in)
          icon: isExpanded ? Icons.zoom_in_map : Icons.zoom_out_map,
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
              if (isExpanded) {
                NinjaCallbackManager.dispatchFloaterExpanded(
                  campaignId: 'unknown', // Resolving campaign ID requires context, but we pass generic
                  displayId: widget.config.raw['id']?.toString() ?? 'floater',
                );
              }
            });
          },
          styleConfig: expandBtn);
      if (pos == 'top-left')
        topLeft.add(btn);
      else if (pos == 'top-right')
        topRight.add(btn);
      else if (pos == 'bottom-left')
        bottomLeft.add(btn);
      else if (pos == 'bottom-right') bottomRight.add(btn);
    }

    // Mute Button (Video Only)
    bool isVideo = _videoController != null || _youtubeController != null;
    final muteBtn = controls?['muteButton'];
    if (isVideo && (muteBtn?['show'] == true)) {
      String pos = muteBtn?['position'] ?? 'top-right';
      IconData icon = isMuted ? Icons.volume_off : Icons.volume_up;
      Widget btn = _buildBtn(
          icon: icon,
          onTap: () {
            setState(() {
              isMuted = !isMuted;
              _videoController?.setVolume(isMuted ? 0 : 1);
              if (isMuted) {
                _youtubeController?.mute();
              } else {
                _youtubeController?.unMute();
              }
            });
          },
          styleConfig: muteBtn);
      if (pos == 'top-left')
        topLeft.add(btn);
      else if (pos == 'top-right')
        topRight.add(btn);
      else if (pos == 'bottom-left')
        bottomLeft.add(btn);
      else if (pos == 'bottom-right') bottomRight.add(btn);
    }

    // Close Button
    final closeBtn = controls?['closeButton'];
    bool showClose =
        widget.config.showCloseButton == true || closeBtn?['show'] == true;
    if (showClose) {
      String pos = closeBtn?['position'] ?? 'top-right';
      Widget btn = _buildBtn(
          icon: Icons.close,
          onTap: () {
            _handleAction({'type': 'close'});
          },
          styleConfig: closeBtn);
      if (pos == 'top-left')
        topLeft.add(btn);
      else if (pos == 'top-right')
        topRight.add(btn);
      else if (pos == 'bottom-left')
        bottomLeft.add(btn);
      else if (pos == 'bottom-right') bottomRight.add(btn);
    }

    List<Widget> stackChildren = [];

    // Progress Bar (Top)
    if (isVideo &&
        controls?['progressBar']?['show'] == true &&
        controls!['progressBar']?['position'] == 'top') {
      stackChildren.add(Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildVideoProgressBar(controls['progressBar']!)));
    }

    // Controls Overlays (Strictly mapped ignoring SafeAreas)
    if (topLeft.isNotEmpty) {
      stackChildren.add(Positioned(
        top: 8,
        left: 8,
        child: Row(mainAxisSize: MainAxisSize.min, children: topLeft),
      ));
    }
    if (topRight.isNotEmpty) {
      stackChildren.add(Positioned(
        top: 8,
        right: 8,
        child: Row(mainAxisSize: MainAxisSize.min, children: topRight),
      ));
    }
    if (bottomLeft.isNotEmpty) {
      stackChildren.add(Positioned(
        bottom: 8,
        left: 8,
        child: Row(mainAxisSize: MainAxisSize.min, children: bottomLeft),
      ));
    }
    if (bottomRight.isNotEmpty) {
      stackChildren.add(Positioned(
        bottom: 8,
        right: 8,
        child: Row(mainAxisSize: MainAxisSize.min, children: bottomRight),
      ));
    }

    // Progress Bar (Bottom)
    if (isVideo &&
        controls?['progressBar']?['show'] == true &&
        controls!['progressBar']?['position'] != 'top') {
      stackChildren.add(Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildVideoProgressBar(controls['progressBar']!)));
    }

    if (stackChildren.isEmpty) return const SizedBox();

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: stackChildren,
      ),
    );
  }

  Widget _buildVideoProgressBar(dynamic config) {
    Color barColor = Colors.white;
    if (config is Map && config['color'] != null) {
      barColor = NinjaLayerUtils.parseColor(config['color']) ?? Colors.white;
    }

    return ValueListenableBuilder<double>(
        valueListenable: _videoProgressNotifier,
        builder: (context, value, _) {
          return Container(
            height: 3,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            color: Colors.white.withValues(alpha: 0.3),
            child: AnimatedContainer(
              duration: const Duration(
                  milliseconds: 100), // Smooth 0.1s transition (TSX Parity)
              width: (MediaQuery.of(context).size.width * (value / 100))
                  .clamp(0.0, double.infinity),
              height: 3,
              decoration: BoxDecoration(
                color: barColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
            ),
          );
        });
  }

  // --- PHASE 2: HELPERS ---

  Color _getBackgroundColor(dynamic colors) {
    // FIX F4: TSX defaults to '#000000' (black), not white
    if (colors == null) return Colors.black;
    if (colors is Map) {
      if (colors.containsKey('background') && colors['background'] is Map) {
        return NinjaLayerUtils.parseColor(colors['background']['card']) ??
            Colors.black;
      }
      if (colors.containsKey('bg')) {
        return NinjaLayerUtils.parseColor(colors['bg']) ?? Colors.black;
      }
    }
    return Colors.black;
  }

  // _getTextColor removed as unused

  // Helpers are now imported from NinjaLayerUtils

  // --- PHASE 3: SCALE & DIMENSIONS ---

  // Returns double (for pixels) or String (for percentages)
  // factor is normally 1.0 unless scaled
  // _resolveDimension removed as unused

  // STRETCH FIX Helper
  // Positioning helpers optimized and inlined elsewhere

  // Helper for Positioning (Bug 23 Fix)
  // Converts raw pixels to percentage relative to design device (393x852)
  // TSX Logic: toPercentX / toPercentY
  // Percentage conversion helpers replaced logic for performance

  // --- PHASE 4: COMPLEX LAYER LOGIC ---

  // --- PHASE 5: BASE LAYER RENDERING & STYLES ---

  Widget _buildLayer(dynamic layer,
      {double? parentWidth, double? parentHeight}) {
    return buildFloaterLayerGlobally(
      layer,
      widget.scale ?? 1.0,
      widget.scaleY ?? widget.scale ?? 1.0,
      widget.layers.map((l) => l.raw).toList(),
      (a, d) => _handleAction({'type': a, ...?d}),
      parentWidth: parentWidth,
      parentHeight: parentHeight,
      config: widget.config,
      campaignId: widget.campaignId,
    );
  }
  // --- PHASE 6: CHILD LAYER WIDGETS ---

  void _handleAction(Map<String, dynamic>? action) {
    if (!_isInteractive() || action == null) return;

    NinjaLog.d('AppNinja', "FloaterRenderV2 Action triggered: $action");
    final type = action['type'];

    switch (type) {
      case 'close':
      case 'dismiss':
        if (AppNinja.stwCloseOverlay != null && AppNinja.stwCloseOverlay!()) {
          NinjaLog.d('AppNinja', "Close action intercepted by Spin the Wheel overlay");
        } else {
          if (widget.onDismiss != null) widget.onDismiss!();
        }
        break;

      // Interface Action
      case 'interface':
        final interfaceId = action['interfaceId'];
        if (interfaceId != null && widget.onInterfaceAction != null) {
          widget.onInterfaceAction!(interfaceId);
        }
        break;

      // Link & Deep Link (Parity with window.open)
      case 'link':
      case 'deeplink':
      case 'external_url': // Handle alias
      case 'open_link': // Handle general alias
        if (widget.onAction != null) {
          widget.onAction!(type, action);
        }
        break;

      // Navigate (Screen)
      case 'navigate':
        final screen = action['screenName'] ??
            action['screen'] ??
            action['route']; // Robust support
        if (screen != null && widget.onNavigate != null) {
          widget.onNavigate!(screen);
        }
        break;

      // Callback / Custom
      case 'custom':
      case 'callback':
        // User requested "Callback" action parity. Assuming generic hook or same as custom.
        NinjaLog.d('AppNinja', "Custom/Callback Action: ${action['data'] ?? action}");
        if (widget.onAction != null) {
          widget.onAction!(type, action);
        }
        break;

      case 'none':
      case 'no_action':
        break;

      // Spin The Wheel Game State Actions
      // CRITICAL FIX: When the STW layer fires spin_started/spin_completed, we MUST
      // call setState() to rebuild the entire widget tree. Sibling NinjaTextLayer
      // widgets are StatelessWidgets that read AppNinja.stwSpinsLeft during build()
      // via resolveText(). Without this rebuild, {{spins_left}}, {{reward_name}},
      // and {{coupon_code}} placeholders show stale values forever.
      case 'spin_started':
        NinjaLog.d('AppNinja', "FloaterRenderV2: Spin started — forcing rebuild for dynamic text");
        if (mounted) setState(() {});
        // Forward to parent
        if (widget.onAction != null) {
          widget.onAction!(type, action);
        }
        break;

      case 'spin_completed':
        NinjaLog.d('AppNinja', "FloaterRenderV2: Spin completed — forcing rebuild for dynamic text (spinsLeft=${action['spinsLeft']}, reward=${action['reward']})");
        if (mounted) setState(() {});
        // Forward to parent
        if (widget.onAction != null) {
          widget.onAction!(type, action);
        }
        break;

      // Internal Scratch Foil Game Action (Standardized Constant from ninja_callback_data.dart)
      case 'NINJA_SCRATCH_CARD_REVEALED':
        final ledgerId = action['ledgerId'];
        if (ledgerId != null && ledgerId.isNotEmpty) {
          NinjaLog.d('AppNinja', 
              "FloaterRenderV2: Syncing scratch ledger event for $ledgerId");
          AppNinja.completeScratchWalletTicket(ledgerId).then((res) {
            NinjaLog.d('AppNinja', 
                "FloaterRenderV2: Wallet ticket synced -> ${res['success']}");
          });
        }

        // Let it fallthrough or forward it up if host app wants to know
        if (widget.onAction != null) {
          widget.onAction!(type, action);
        }
        break;

      default:
        // Fix: Forward generic actions (submit, custom, etc) to parent, including data
        if (widget.onAction != null) {
          widget.onAction!(type, action);
        }
        break;
    }
  }

  Future<void> _launchUrl(String url) async {
    final ok = await NinjaUrlLauncher.launchExternal(url);
    if (!ok) {
      NinjaLog.d('AppNinja', 'Could not launch url: $url');
    }
  }

  // --- PHASE 7: DRAG & DROP ---

  // Simplifed Drag Logic
  // Simplifed Drag Logic
  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    if (!_isInteractive()) return;

    // DEBUG: Log raw config to see what we're receiving
    NinjaLog.d('AppNinja', 
        "🔍 [Drag Debug] Raw config keys: ${widget.config.raw.keys.toList()}");
    NinjaLog.d('AppNinja', 
        "🔍 [Drag Debug] Raw draggable value: ${widget.config.raw['draggable']}");
    NinjaLog.d('AppNinja', "🔍 [Drag Debug] Behavior object: ${widget.config.behavior}");
    NinjaLog.d('AppNinja', 
        "🔍 [Drag Debug] Behavior.draggable: ${widget.config.behavior?.draggable}");

    // FIX: Strict Parity with TSX Precedence (Behavior > Root > Default)
    // React Logic: const isDraggable = rawBehavior !== undefined ? rawBehavior : (rawRoot !== undefined ? rawRoot : true);

    dynamic rawDraggable = widget.config.raw['draggable'];
    bool? rootDraggable;

    // Explicitly check for null to allow fallback
    if (rawDraggable != null) {
      rootDraggable = NinjaLayerUtils.parseBoolean(rawDraggable);
    }

    // Check behavior explicitly (nullable)
    bool? behaviorDraggable = widget.config.behavior?.draggable;

    // Priority: Behavior (Specific) > Root (Legacy) > Default (True)
    bool draggable = behaviorDraggable ?? rootDraggable ?? true;

    NinjaLog.d('AppNinja', 
        "Floater Drag Debug: Behavior=$behaviorDraggable, Root=$rootDraggable, Final=$draggable");

    if (!draggable) {
      NinjaLog.d('AppNinja', "🚫 [Drag Debug] Dragging BLOCKED - draggable is false");
      return;
    }

    NinjaLog.d('AppNinja', "✅ [Drag Debug] Dragging ALLOWED - starting drag");
    if (_dragPosition == null) {
      _initializeDragPosition(constraints);
    }
    setState(() {
      isDragging = true;
    });
  }

  void _initializeDragPosition(BoxConstraints constraints) {
    final double parentW = constraints.maxWidth.isInfinite
        ? MediaQuery.of(context).size.width
        : constraints.maxWidth;
    final double parentH = constraints.maxHeight.isInfinite
        ? MediaQuery.of(context).size.height
        : constraints.maxHeight;

    Size? floaterSize;
    if (_floaterKey.currentContext != null) {
      floaterSize = _floaterKey.currentContext!.size;
    }
    double w = floaterSize?.width ?? 300;
    double h = floaterSize?.height ?? 200;

    final position = widget.config.position ?? 'bottom-right';

    // FL14 Fix: Dynamic default offsets for center positions (matching FL7 / TSX parity)
    double defaultX = 20;
    double defaultY = 20;
    if (position == 'center' || position == 'middle-center') {
      defaultX = 0;
      defaultY = 0;
    } else if (position == 'top-center' || position == 'bottom-center') {
      defaultX = 0;
      defaultY = 20;
    } else if (position == 'center-left' || position == 'center-right') {
      defaultX = 20;
      defaultY = 0;
    }

    // FL14 Fix: Scale offsets by scale/scaleY (TSX: offsetX * scale, offsetY * scaleY)
    final offsetX =
        (widget.config.offsetX ?? defaultX).toDouble() * (widget.scale ?? 1.0);
    final offsetY = (widget.config.offsetY ?? defaultY).toDouble() *
        (widget.scaleY ?? widget.scale ?? 1.0);

    double left = 0;
    double top = 0;

    if (position.contains('right'))
      left = parentW - w - offsetX;
    else if (position.contains('left'))
      left = offsetX;
    else
      left = (parentW - w) / 2;

    if (position.contains('bottom'))
      top = parentH - h - offsetY;
    else if (position.contains('top'))
      top = offsetY;
    else
      top = (parentH - h) / 2;

    setState(() {
      _dragPosition = Offset(left, top);
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!isDragging || _dragPosition == null) return;

    // TSX Parity: Use constraints (parent) for clamping
    // FIX: If infinite, fallback to SafeArea-adjusted screen height, NOT absolute screen height.
    final mediaQuery = MediaQuery.of(context);
    final safeHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        mediaQuery.viewInsets.bottom;
    final safeWidth = mediaQuery.size.width -
        mediaQuery.padding.left -
        mediaQuery.padding.right;

    final double parentW =
        constraints.maxWidth.isInfinite ? safeWidth : constraints.maxWidth;
    final double parentH =
        constraints.maxHeight.isInfinite ? safeHeight : constraints.maxHeight;

    Size? floaterSize = _floaterKey.currentContext?.size;
    double w = floaterSize?.width ?? 300;
    double h = floaterSize?.height ?? 200;

    // Strict Containment: 0.0 to (Parent - Floater)
    double maxLeft = math.max(0.0, parentW - w);
    double maxTop = math.max(0.0, parentH - h);

    double newLeft = (_dragPosition!.dx + details.delta.dx).clamp(0.0, maxLeft);
    double newTop = (_dragPosition!.dy + details.delta.dy).clamp(0.0, maxTop);

    setState(() {
      _dragPosition = Offset(newLeft, newTop);
    });
  }

  void _onPanEnd(DragEndDetails details, BoxConstraints constraints) {
    setState(() {
      isDragging = false;
    });

    // SNAP LOGIC
    // Check config: snapToCorner (boolean)
    // Parity: Handle both boolean and string "true" just in case
    // SNAP LOGIC
    // Priority: behavior.snapToCorner > root snapToCorner > Default TRUE

    dynamic snapVal = widget.config.behavior?.snapToCorner;

    // Fallback 1: Raw nested behavior (if model parsing failed)
    if (snapVal == null && widget.config.raw['behavior'] is Map) {
      snapVal = widget.config.raw['behavior']['snapToCorner'];
    }

    // Fallback 2: Root property (legacy)
    if (snapVal == null) {
      snapVal = widget.config.raw['snapToCorner'];
    }

    // Fallback 3: Snake case legacy
    if (snapVal == null) {
      snapVal = widget.config.raw['snap_to_corner'];
    }

    // Default to TRUE if undefined
    bool snapEnabled = true;
    if (snapVal != null) {
      snapEnabled =
          snapVal == true || snapVal.toString().toLowerCase() == 'true';
    }

    NinjaLog.d('AppNinja', "SNAP DEBUG: snapVal=$snapVal, snapEnabled=$snapEnabled");

    if (snapEnabled) {
      _snapToNearestCorner();
    } else {
      NinjaLog.d('AppNinja', 
          "SNAP DEBUG: Snap NOT enabled. Raw: ${widget.config.raw}, Behavior: ${widget.config.behavior?.snapToCorner}");
    }
  }

  void _snapToNearestCorner() {
    if (_dragPosition == null) return;

    final mediaQuery = MediaQuery.of(context);
    final safeHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        mediaQuery.viewInsets.bottom;
    final safeWidth = mediaQuery.size.width -
        mediaQuery.padding.left -
        mediaQuery.padding.right;

    // Use current constraints if available from the builder, otherwise fallback to safe viewport bound
    final double parentW = safeWidth;
    final double parentH = safeHeight;

    Size? size = _floaterKey.currentContext?.size;
    double w = size?.width ?? 300;
    double h = size?.height ?? 200;

    // TSX Logic: Center-based Quadrant Detection
    final containerCenter = Offset(parentW / 2, parentH / 2);
    final floaterCenter = Offset(
      _dragPosition!.dx + (w / 2),
      _dragPosition!.dy + (h / 2),
    );

    final bool isLeft = floaterCenter.dx < containerCenter.dx;
    final bool isTop = floaterCenter.dy < containerCenter.dy;

    // Physics Constants (MIN_SAFE_PADDING = 12)
    const double MIN_SAFE_PADDING = 12.0;
    double configOffsetX =
        (widget.config.offsetX ?? 20).toDouble() * (widget.scale ?? 1.0);
    double configOffsetY = (widget.config.offsetY ?? 20).toDouble() *
        (widget.scaleY ?? widget.scale ?? 1.0);

    double marginX = math.max(MIN_SAFE_PADDING, configOffsetX);
    double marginY = math.max(MIN_SAFE_PADDING, configOffsetY);

    // Target Calculation based on Quadrant
    double targetX = isLeft ? marginX : (parentW - w - marginX);
    double targetY = isTop ? marginY : (parentH - h - marginY);

    setState(() {
      _dragPosition = Offset(targetX, targetY);
    });
  }

  bool _isInteractive() {
    // Helper to check if interactions are enabled (e.g. not just preview mode)
    return true;
  }

  // --- PHASE 10: FINAL ASSEMBLY ---

  Widget _renderBackdrop() {
    // FIX F1: TSX renders overlay whenever config?.overlay?.enabled || config?.backdrop?.show
    // Previously only rendered when isExpanded, missing overlay in normal floater mode
    final overlayEnabled = widget.config.overlay?['enabled'] == true ||
        widget.config.raw['backdrop']?['show'] == true;
    if (!overlayEnabled && !isExpanded) return const SizedBox();

    // TSX: Backdrop logic
    final overlay = widget.config.overlay;
    if (overlay?['enabled'] == false) return const SizedBox();

    // FL2 Fix: Apply overlay opacity separately (TSX: opacity: config?.overlay?.opacity ?? 0.5)
    final baseColor =
        NinjaLayerUtils.parseColor(overlay?['color']) ?? Colors.black;
    final double overlayOpacityValue =
        (overlay?['opacity'] as num?)?.toDouble() ??
            (widget.config.raw['backdrop']?['opacity'] as num?)?.toDouble() ??
            0.5;
    final color = baseColor.withOpacity(overlayOpacityValue.clamp(0.0, 1.0));
    // FL21 Fix: TSX checks both overlay.blur and backdrop.blur
    final blur =
        (overlay?['blur'] ?? widget.config.raw['backdrop']?['blur'] ?? 0)
            .toDouble();

    Widget backdrop = Container(color: color);

    if (blur > 0) {
      backdrop = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: backdrop,
      );
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          // FL1 Fix: Check dismissOnClick / dismissOnTap keys matching TSX
          final shouldDismiss = overlay?['dismissOnClick'] == true ||
              overlay?['dismissOnTap'] == true ||
              widget.config.raw['backdrop']?['dismissOnTap'] == true ||
              overlay?['dismissParams']?['tapOutsideToDismiss'] == true;
          if (shouldDismiss) {
            if (widget.onDismiss != null) {
              widget.onDismiss?.call();
            } else {
              setState(() => isExpanded = false);
            }
          }
        },
        child: backdrop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = widget.scale ?? 1.0;

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          _renderBackdrop(),
          _buildFloaterPositioned(scale, constraints),
        ],
      );
    });
  }

  Widget _buildFloaterPositioned(double scale, BoxConstraints constraints) {
    if (isExpanded) {
      return Positioned.fill(
        child: _buildFloaterContent(scale, widget.scaleY ?? scale, constraints),
      );
    }

    Widget content = KeyedSubtree(
      key: _floaterKey,
      child: GestureDetector(
        onPanStart: (d) => _onPanStart(d, constraints),
        onPanUpdate: (d) => _onPanUpdate(d, constraints),
        onPanEnd: (d) => _onPanEnd(d, constraints),
        behavior: HitTestBehavior.translucent,
        onDoubleTap: () {
          // ROBUST: Check all possible keys for double tap
          // Refactored for Strict Precedence (User Request: Perfect Working)
          // If 'behavior' exists in raw JSON, we trust it completely and ignore legacy root props.
          // This allows users to explicitly Disable double tap even if legacy 'true' exists.
          bool doubleTapEnabled = false;

          if (widget.config.raw['behavior'] != null) {
            doubleTapEnabled =
                widget.config.behavior?.doubleTapToDismiss == true;
          } else {
            // Legacy Fallback
            var rawDoubleTap = widget.config.raw['doubleTapToDismiss'];
            var rawDoubleTapSnake = widget.config.raw['double_tap_to_dismiss'];
            doubleTapEnabled = rawDoubleTap == true ||
                rawDoubleTap == 'true' ||
                rawDoubleTapSnake == true ||
                rawDoubleTapSnake == 'true';
          }

          if (doubleTapEnabled) {
            _onDoubleTap();
          }
        },
        onTap: _onTap,
        child: _buildEntranceTransition(_buildFloaterContent(
            widget.scale ?? 1.0,
            widget.scaleY ?? widget.scale ?? 1.0,
            constraints)),
      ),
    );

    if (_dragPosition != null) {
      return AnimatedPositioned(
        duration: isDragging
            ? Duration.zero
            : const Duration(milliseconds: 400), // FL9 Fix: Match TSX 0.4s
        curve: Curves.easeOutQuart,
        left: _dragPosition!.dx,
        top: _dragPosition!.dy,
        child: content,
      );
    }

    final position = widget.config.position ?? 'bottom-right';

    // FL7 Fix: Dynamic default offsets based on position (TSX parity)
    double defaultX = 20;
    double defaultY = 20;
    if (position == 'center' || position == 'middle-center') {
      defaultX = 0;
      defaultY = 0;
    } else if (position == 'top-center' || position == 'bottom-center') {
      defaultX = 0;
      defaultY = 20;
    } else if (position == 'center-left' || position == 'center-right') {
      defaultX = 20;
      defaultY = 0;
    }

    // FL6 Fix: Scale offsets by scale/scaleY (TSX: offsetX * scale, offsetY * scaleY)
    final double scaleXVal = widget.scale ?? 1.0;
    final double scaleYVal = widget.scaleY ?? scaleXVal;
    final offsetX = (widget.config.offsetX ?? defaultX).toDouble() * scaleXVal;
    final offsetY = (widget.config.offsetY ?? defaultY).toDouble() * scaleYVal;

    Alignment alignment;
    switch (position) {
      case 'top-left':
        alignment = Alignment.topLeft;
        break;
      case 'top-center':
        alignment = Alignment.topCenter;
        break;
      case 'top-right':
        alignment = Alignment.topRight;
        break;
      case 'center-left':
        alignment = Alignment.centerLeft;
        break;
      case 'center':
        alignment = Alignment.center;
        break;
      case 'center-right':
        alignment = Alignment.centerRight;
        break;
      case 'bottom-left':
        alignment = Alignment.bottomLeft;
        break;
      case 'bottom-center':
        alignment = Alignment.bottomCenter;
        break;
      case 'bottom-right':
      default:
        alignment = Alignment.bottomRight;
        break;
    }

    double padTop = 0.0;
    double padBottom = 0.0;
    double padLeft = 0.0;
    double padRight = 0.0;

    double transX = 0.0;
    double transY = 0.0;

    if (alignment == Alignment.topLeft) {
      padTop = math.max(0.0, offsetY);
      padLeft = math.max(0.0, offsetX);
      if (offsetY < 0.0) transY += offsetY;
      if (offsetX < 0.0) transX += offsetX;
    } else if (alignment == Alignment.topRight) {
      padTop = math.max(0.0, offsetY);
      padRight = math.max(0.0, offsetX);
      if (offsetY < 0.0) transY += offsetY;
      if (offsetX < 0.0) transX -= offsetX;
    } else if (alignment == Alignment.bottomLeft) {
      padBottom = math.max(0.0, offsetY);
      padLeft = math.max(0.0, offsetX);
      if (offsetY < 0.0) transY -= offsetY;
      if (offsetX < 0.0) transX += offsetX;
    } else if (alignment == Alignment.bottomRight) {
      padBottom = math.max(0.0, offsetY);
      padRight = math.max(0.0, offsetX);
      if (offsetY < 0.0) transY -= offsetY;
      if (offsetX < 0.0) transX -= offsetX;
    } else if (alignment == Alignment.topCenter) {
      padTop = math.max(0.0, offsetY);
      if (offsetY < 0.0) transY += offsetY;
      transX += offsetX;
    } else if (alignment == Alignment.bottomCenter) {
      padBottom = math.max(0.0, offsetY);
      if (offsetY < 0.0) transY -= offsetY;
      transX += offsetX;
    } else if (alignment == Alignment.centerLeft) {
      padLeft = math.max(0.0, offsetX);
      if (offsetX < 0.0) transX += offsetX;
      transY += offsetY;
    } else if (alignment == Alignment.centerRight) {
      padRight = math.max(0.0, offsetX);
      if (offsetX < 0.0) transX -= offsetX;
      transY += offsetY;
    } else if (alignment == Alignment.center) {
      transX += offsetX;
      transY += offsetY;
    }

    final initialMargin = EdgeInsets.only(
      top: padTop,
      bottom: padBottom,
      left: padLeft,
      right: padRight,
    );
    final transformOffset = Offset(transX, transY);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: initialMargin,
        child: Transform.translate(offset: transformOffset, child: content),
      ),
    );
  }

  // Phase 5: Transition Builder
  Widget _buildEntranceTransition(Widget child) {
    if (_entranceController == null || _entranceAnimation == null) return child;

    final type = widget.config.animation?.type ?? 'fade';

    if (type == 'fade') {
      return FadeTransition(opacity: _entranceAnimation!, child: child);
    } else if (type == 'scale') {
      // TSX floater-scale: `scale(0.8)` to `scale(1.0)`
      final scaleAnim =
          Tween<double>(begin: 0.8, end: 1.0).animate(_entranceAnimation!);
      return ScaleTransition(
          scale: scaleAnim,
          child: FadeTransition(opacity: _entranceAnimation!, child: child));
    } else if (type == 'bounce') {
      return ScaleTransition(
          scale: _bounceAnimation ?? _entranceAnimation!,
          child: FadeTransition(opacity: _entranceAnimation!, child: child));
    } else if (type == 'slide') {
      return SlideTransition(
          position: _slideAnimation ??
              Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                  .animate(_entranceAnimation!),
          child: FadeTransition(opacity: _entranceAnimation!, child: child));
    }

    return child;
  }

  // Bug 1: Interaction Logic (Tap & Double Tap)
  // Double Tap = Dismiss
  // Tap = Container Action

  // Bug 4 Fix: Interaction Guard
  // Prevent excessive rapid taps or accidental taps on mount
  int _mountTime = 0; // Set in initState

  void _onDoubleTap() {
    if (DateTime.now().millisecondsSinceEpoch - _mountTime < 200)
      return; // Guard
    if (widget.onDismiss != null) widget.onDismiss!();
  }

  void _onTap() {
    // Check for container action
    // Usually the renderer handles its own actions, but if the USER clicks the "background",
    // we should check if the floater container itself has an action.
    final floaterLayer = widget.layers.firstWhere(
      (l) =>
          l.parent == null ||
          l.parent == 'root' ||
          l.parent == '' ||
          (l.type == 'container' &&
              (l.name == 'Floater Container' ||
                  l.name == 'FloaterContainer' ||
                  l.name == 'Bottom Sheet')),
      orElse: () => widget.layers.isNotEmpty
          ? widget.layers.first
          : Layer(id: 'fallback', type: 'container', content: {}, raw: {}),
    );

    final action = floaterLayer.content['action'];

    // Bug 15 Fix: Editor Selection Support
    // If we are NOT in interactive mode (e.g. Editor / Admin),
    // clicking the container should invoke onLayerSelect.
    if (!_isInteractive()) {
      if (widget.onLayerSelect != null) {
        widget.onLayerSelect!(floaterLayer.id);
      }
      return;
    }

    if (action != null) {
      _handleAction(action);
    } else {
      // If no action, check for "Tap to Dismiss" behavior
      // FIX: Guard Tap To Dismiss locally to avoid swallowing fast legitimate actions
      if (DateTime.now().millisecondsSinceEpoch - _mountTime < 200) return;

      bool tapToDismiss = false;
      // Robust check similar to DoubleTap
      if (widget.config.raw['behavior'] != null) {
        tapToDismiss = widget.config.raw['behavior']?['tapToDismiss'] == true;
      } else {
        // Legacy or raw check if model update missing
        tapToDismiss = widget.config.raw['tapToDismiss'] == true ||
            widget.config.raw['tap_to_dismiss'] == true;
      }

      if (tapToDismiss && widget.onDismiss != null) {
        widget.onDismiss!();
      }
    }
  }

  Widget _buildFloaterContent(
      double scaleX, double scaleY, BoxConstraints constraints) {
    // CRITICAL FIX: Infinity Constraint Crash Protection
    // LayoutBuilder can return infinity if placed in unconstrained parent (e.g. Stack/Column).
    // We MUST provide a fallback width/height context for percentages to work.
    final double safeMaxWidth = constraints.maxWidth.isInfinite
        ? MediaQuery.of(context).size.width
        : constraints.maxWidth;
    final double safeMaxHeight = constraints.maxHeight.isInfinite
        ? MediaQuery.of(context).size.height
        : constraints.maxHeight;

    // Use these safe constraints for percentage calculations relative to parent
    // (effectively assuming full screen if unconstrained)
    final safeConstraints = BoxConstraints(
      maxWidth: safeMaxWidth,
      maxHeight: safeMaxHeight,
    );

    // 1. Find Floater Container Layer to access its specific styles
    // Fallback gracefully to a pseudo root container if no valid wrapper container is found
    final floaterLayer = widget.layers.firstWhere(
      (l) =>
          l.parent == null ||
          l.parent == 'root' ||
          l.parent == '' ||
          (l.type == 'container' &&
              (l.name == 'Floater Container' ||
                  l.name == 'FloaterContainer' ||
                  l.name == 'Bottom Sheet')),
      orElse: () =>
          Layer(id: 'fallback_root', type: 'container', content: {}, raw: {}),
    );

    // Bug 3 Fix: Dimension Priority (Config > Layer > Default)
    // Parity Fix: Allow 'auto' mapping to pass through so we don't arbitrarily lock to 180px
    // ✅ FIX 1: DASHBOARD PARITY - Correct 'auto' dimension resolution
    String _resolveDim(dynamic configVal, dynamic layerVal, String defaultVal) {
      // Agar config mein value hai aur wo 'auto' nahi hai, toh use karo
      if (configVal != null && configVal.toString().toLowerCase() != 'auto')
        return configVal.toString();
      // Agar config 'auto' hai, toh check karo layer mein specific value hai kya
      if (layerVal != null && layerVal.toString().toLowerCase() != 'auto')
        return layerVal.toString();
      // Warna default (e.g., '180' ya 'auto')
      return configVal?.toString() ?? defaultVal;
    }

    NinjaLog.d('AppNinja', 
        'FloaterHeightDebug: config=${widget.config.height}, sizeUnit=${widget.config.sizeUnit}, layer=${floaterLayer.style?.height}');

    // Parity Fix: Handle sizeUnit (Dashboard logic)
    final sizeUnit = widget.config.sizeUnit;

    dynamic configWidth = widget.config.width;
    if (sizeUnit == '%' &&
        configWidth != null &&
        double.tryParse(configWidth.toString()) != null) {
      configWidth = "${configWidth}%";
    }

    dynamic configHeight = widget.config.height;
    if (sizeUnit == '%' &&
        configHeight != null &&
        double.tryParse(configHeight.toString()) != null) {
      configHeight = "${configHeight}%";
    }

    String widthStr =
        _resolveDim(configWidth, floaterLayer.style?.width, '280');
    if (isExpanded) widthStr = '100%';

    String heightStr =
        _resolveDim(configHeight, floaterLayer.style?.height, '180');
    if (isExpanded) heightStr = '100%';

    // Width Calculation
    double? finalWidth;
    if (widthStr == 'auto') {
      finalWidth = null;
    } else if (widthStr.endsWith('%')) {
      final pct = double.tryParse(widthStr.replaceAll('%', '')) ?? 100;
      finalWidth = safeConstraints.maxWidth * (pct / 100);
    } else {
      finalWidth = double.tryParse(
          safeScale(widthStr, scaleX).toString().replaceAll('px', ''));
    }

    // Height Calculation
    double? finalHeight;
    if (heightStr == 'auto') {
      finalHeight = null;
    } else if (heightStr.endsWith('%')) {
      final pct = double.tryParse(heightStr.replaceAll('%', '')) ?? 100;
      finalHeight = safeConstraints.maxHeight * (pct / 100);
    } else {
      finalHeight = double.tryParse(
          safeScale(heightStr, scaleY).toString().replaceAll('px', ''));
    }

    // Background Logic: Use Cached Image
    DecorationImage? bgImage;
    if (_cachedBgProvider != null) {
      final fitStr =
          widget.config.media?.fit ?? widget.config.backgroundSize ?? 'fill';
      // TSX Parity: fit derived from config.media.fit primarily
      BoxFit fit = BoxFit.fill; // Default 100% 100%
      if (fitStr == 'contain') fit = BoxFit.contain;
      if (fitStr == 'cover') fit = BoxFit.cover;
      if (fitStr == 'stretch') fit = BoxFit.fill;

      // Bug 18 Fix: Force contain on expand to avoid stretching
      if (isExpanded) fit = BoxFit.contain;

      bgImage = DecorationImage(
        image: _cachedBgProvider!,
        fit: fit,
        alignment: Alignment.center,
      );
    }

    final bgColor = (widget.config.backgroundColor != null)
        ? NinjaLayerUtils.parseColor(widget.config.backgroundColor)
        : NinjaLayerUtils.parseColor(floaterLayer.style?.backgroundColor) ??
            _getBackgroundColor(widget.config.colors);

    // Visibility Logic (Bug 1 Fix)
    // TSX: const isVideo = config?.media?.type === 'video' || config?.media?.type === 'youtube';
    // In Dart, checking controllers.
    bool isVideo = _videoController != null || _youtubeController != null;
    bool showContent = isExpanded || !isVideo;

    // Layout Logic (Exact TSX Parity)
    // 1. Filter Child Layers: Treat orphan layers as root layers if their parent is missing
    final allLayerIds = widget.layers.map((l) => l.id).toSet();
    final childLayers = widget.layers.where((l) {
      if (l.id == floaterLayer.id) return false;
      if (l.parent == floaterLayer.id) return true;
      if (l.parent == null || l.parent == 'root' || l.parent == '') return true;
      // CRITICAL: Orphan check (parent ID absent in payload) -> fallback to root
      if (!allLayerIds.contains(l.parent)) return true;
      return false;
    }).toList();

    // Bug Fix: Z-Index Sorting
    // Ensure layers with higher z-index render last (on top)
    childLayers.sort((a, b) {
      int zA = int.tryParse(a.style?['zIndex']?.toString() ?? '0') ?? 0;
      int zB = int.tryParse(b.style?['zIndex']?.toString() ?? '0') ?? 0;
      return zA.compareTo(zB);
    });

    // 2. Split Absolute vs Relative
    final absoluteLayers = <Widget>[];
    final relativeLayers = <Widget>[];

    // Apply padding from Floater Layer Style to the Relative Content Area
    double pTop = 0;
    double pBottom = 0;
    double pLeft = 0;
    double pRight = 0;

    final sStyle = floaterLayer.style;
    if (sStyle != null) {
      dynamic rawPaddingVal = sStyle.padding;
      if (rawPaddingVal is num) rawPaddingVal = "${rawPaddingVal}px";

      final rawP = NinjaLayerUtils.parsePadding(rawPaddingVal, context);

      pTop = double.tryParse(
              safeScale(sStyle.paddingTop ?? rawP?.top ?? 0, scaleY)
                  .toString()
                  .replaceAll('px', '')) ??
          0;
      pBottom = double.tryParse(
              safeScale(sStyle.paddingBottom ?? rawP?.bottom ?? 0, scaleY)
                  .toString()
                  .replaceAll('px', '')) ??
          0;
      pLeft = double.tryParse(
              safeScale(sStyle.paddingLeft ?? rawP?.left ?? 0, scaleX)
                  .toString()
                  .replaceAll('px', '')) ??
          0;
      pRight = double.tryParse(
              safeScale(sStyle.paddingRight ?? rawP?.right ?? 0, scaleX)
                  .toString()
                  .replaceAll('px', '')) ??
          0;
    }
    final padding = EdgeInsets.fromLTRB(pLeft, pTop, pRight, pBottom);

    final borderStyle =
        widget.config.borderStyle ?? floaterLayer.style?.borderStyle ?? 'solid';
    final isDashed = borderStyle == 'dashed' || borderStyle == 'dotted';

    final borderColor = NinjaLayerUtils.parseColor(
            widget.config.borderColor ?? floaterLayer.style?.borderColor) ??
        Colors.transparent;

    final rawWidth =
        widget.config.borderWidth ?? floaterLayer.style?.borderWidth;
    final borderWidth = (NinjaLayerUtils.parseDouble(rawWidth) ?? 0) * scaleX;

    // Available space inside borders (Padding Box in CSS)
    final double availableWidth =
        (finalWidth != null) ? (finalWidth - 2 * borderWidth) : 300;
    final double availableHeight =
        (finalHeight != null) ? (finalHeight - 2 * borderWidth) : 200;

    final contentWidth =
        (finalWidth != null) ? (finalWidth - pLeft - pRight) : null;
    final contentHeight =
        (finalHeight != null) ? (finalHeight - pTop - pBottom) : null;

    for (var layer in childLayers) {
      if (layer.visible == false) continue;

      // Check Position
      bool isAbs = layer.style?.position == 'absolute' ||
          layer.style?.position == 'fixed';

      // Context Logic:
      // Absolute Layers are relative to the Floater Container (Border Box) -> Use finalWidth/Height
      // Relative Layers are relative to the Column (Content Box) -> Use contentWidth/Height

      // Absolute Layers are relative to the Padding Box (Inside Borders)
      Widget w = _buildLayer(layer.toJson(),
          parentWidth: isAbs ? availableWidth : contentWidth,
          parentHeight: isAbs ? availableHeight : contentHeight);

      if (isAbs) {
        absoluteLayers.add(w);
      } else {
        relativeLayers.add(w);
      }
    }

    // Flex Properties for Relative Content
    final flexDir = floaterLayer.style?.flexDirection ?? 'column';
    // FIX F7: Support row direction via Flex widget
    final isRow = flexDir == 'row';
    final flexDirection = isRow ? Axis.horizontal : Axis.vertical;
    final alignItems = floaterLayer.style?.alignItems ?? 'stretch';
    final justify = floaterLayer.style?.justifyContent ?? 'flex-start';
    // FL18 Fix: TSX always scales gap by `scale` (horizontal), not direction-dependent
    final gap = double.tryParse(safeScale(floaterLayer.style?.gap, scaleX)
            .toString()
            .replaceAll('px', '')) ??
        0;

    // FIX F8: Full justify mapping (including space-around, space-evenly)
    MainAxisAlignment resolveJustify(String j) {
      switch (j) {
        case 'center':
          return MainAxisAlignment.center;
        case 'flex-end':
          return MainAxisAlignment.end;
        case 'space-between':
          return MainAxisAlignment.spaceBetween;
        case 'space-around':
          return MainAxisAlignment.spaceAround;
        case 'space-evenly':
          return MainAxisAlignment.spaceEvenly;
        default:
          return MainAxisAlignment.start;
      }
    }

    final mainAxisAlignment = resolveJustify(justify);

    // Style properties already defined above for coordinate resolution and decoration logic

    // FL19 Fix: TSX defaults borderRadius to 0, not 12
    final rawRadius =
        widget.config.borderRadius ?? floaterLayer.style?.borderRadius ?? 0;
    final radiusVal = (NinjaLayerUtils.parseDouble(rawRadius) ?? 0) * scaleX;

    // Explicit Pill Shape Support
    final isPill = widget.config.raw['clipPathShape'] == 'pill';

    final borderRadius = isExpanded
        ? BorderRadius.zero
        : (widget.config.shape == 'circle'
            ? BorderRadius.circular(9999)
            : (isPill
                ? BorderRadius.circular(9999)
                : BorderRadius.circular(radiusVal)));

    final overflow = widget.config.raw['overflow'] ?? 'hide';
    final isScrollable = overflow == 'scroll';

    // --- GLASSMORPHISM LOGIC ---
    double backdropBlur = 0;

    // FIX 1: Check isExpanded (Parity with TSX)
    if (!isExpanded) {
      if (widget.config.raw['backdropFilter'] != null &&
          widget.config.raw['backdropFilter'] is Map) {
        final bf = widget.config.raw['backdropFilter'];
        if (bf['enabled'] == true) {
          backdropBlur = (bf['blur'] ?? 10).toDouble();
        }
      } else if (widget.config.raw['backdropBlur'] != null) {
        backdropBlur = (widget.config.raw['backdropBlur'] as num).toDouble();
      } else if (floaterLayer.style?['backdropFilter'] != null) {
        final bf = floaterLayer.style!['backdropFilter'];
        if (bf is Map) {
          if (bf['enabled'] == true) {
            backdropBlur =
                double.tryParse(bf['blur']?.toString() ?? '10') ?? 10;
          }
        } else if (bf is String) {
          if (bf.contains('blur')) {
            final match = RegExp(r'blur\(([\d\.]+)px\)').firstMatch(bf);
            if (match != null)
              backdropBlur = double.tryParse(match.group(1) ?? '0') ?? 0;
          }
        }
      }
    }

    // FIX 2: Scale blur by scaleX for responsive sizing
    // Dashboard parity: Direct 1:1 scaling (removed 0.5 factor that was making glass too subtle)
    if (backdropBlur > 0) {
      backdropBlur = backdropBlur * scaleX;
    }

    // Adjust opacity for glass
    Color effectiveBgColor = bgColor ?? Colors.transparent;
    if (backdropBlur > 0 && effectiveBgColor.opacity == 1.0) {
      if (widget.config.raw['backgroundOpacity'] != null) {
        effectiveBgColor = effectiveBgColor.withOpacity(
            (widget.config.raw['backgroundOpacity'] as num).toDouble());
      }
    }

    // Build Main Content Stack
    Widget mainContentStack = Stack(
      children: [
        // Video background (always first if present)
        if (isVideo) _buildVideo(finalWidth ?? 300, finalHeight ?? 200),

        // Main content area (relative layers)
        if (showContent)
          isExpanded
              ? SafeArea(
                  child: SingleChildScrollView(
                    physics: isScrollable
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: finalHeight ?? 0,
                      ),
                      child: Padding(
                        padding: padding,
                        child: Flex(
                          direction:
                              flexDirection, // FIX F7: Support row/column
                          mainAxisSize:
                              MainAxisSize.min, // Use min for dynamic content
                          crossAxisAlignment: alignItems == 'center'
                              ? CrossAxisAlignment.center
                              : (alignItems == 'flex-end'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.stretch),
                          mainAxisAlignment: mainAxisAlignment, // FIX F8
                          children: [
                            for (var i = 0; i < relativeLayers.length; i++) ...[
                              relativeLayers[i],
                              if (i < relativeLayers.length - 1 && gap > 0)
                                SizedBox(
                                    width: isRow ? gap : 0,
                                    height: isRow ? 0 : gap),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : (isScrollable
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: padding,
                        child: Flex(
                          direction: flexDirection, // FIX F7
                          mainAxisSize: MainAxisSize.min, // Support auto height
                          crossAxisAlignment: alignItems == 'center'
                              ? CrossAxisAlignment.center
                              : (alignItems == 'flex-end'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.stretch),
                          mainAxisAlignment: mainAxisAlignment, // FIX F8
                          children: [
                            for (var i = 0; i < relativeLayers.length; i++) ...[
                              relativeLayers[i],
                              if (i < relativeLayers.length - 1 && gap > 0)
                                SizedBox(
                                    width: isRow ? gap : 0,
                                    height: isRow ? 0 : gap),
                            ]
                          ],
                        ),
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: finalHeight ?? 0,
                      ),
                      child: Padding(
                        padding: padding,
                        child: Flex(
                          direction: flexDirection, // FIX F7
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: alignItems == 'center'
                              ? CrossAxisAlignment.center
                              : (alignItems == 'flex-end'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.stretch),
                          mainAxisAlignment: mainAxisAlignment, // FIX F8
                          children: [
                            for (var i = 0; i < relativeLayers.length; i++) ...[
                              relativeLayers[i],
                              if (i < relativeLayers.length - 1 && gap > 0)
                                SizedBox(
                                    width: isRow ? gap : 0,
                                    height: isRow ? 0 : gap),
                            ]
                          ],
                        ),
                      ),
                    )),

        if (showContent) ...absoluteLayers,
        // Bug 10 Fix: Control positioning
        // Layout: Stack [Content -> Controls]
        // Actually, _buildControls returns Positioned.fill(SafeArea(...)).
        // We need to ensure it's on TOP. It's last in Stack, so it is on top.
        _buildControls(),
      ],
    );

    // --- FINAL ASSEMBLY ---

    Widget containerContent;

    if (backdropBlur > 0) {
      // Glass Mode - Parity with NinjaContainerLayer
      // Use Stack to place blur BEHIND the container content
      // This prevents clipping issues and aligns with SDK architecture.

      // Fix: Scale applied above (Fix 2)

      containerContent = Stack(
        children: [
          // 1. Blur Layer (Clipped to Border Radius)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                    sigmaX: backdropBlur, sigmaY: backdropBlur),
                child: Container(
                    color: Colors.transparent), // Transparent placeholder
              ),
            ),
          ),
          // 2. Main Content Container
          Container(
              width: finalWidth,
              height: finalHeight,
              decoration: BoxDecoration(
                color: effectiveBgColor,
                borderRadius: borderRadius,
                border: (isDashed || borderWidth <= 0)
                    ? null
                    : Border.all(color: borderColor, width: borderWidth),
                image: bgImage,
                // Apply shadow to the container itself?
                // If we want shadow on the WHOLE shape, it should be on this container.
                // But wait, ClipRRect clips the shadow of children? No, ClipRRect clips painting.
                // BoxShadow is part of decoration.
              ),
              child: mainContentStack),
        ],
      );

      // Outer Shadow Wrapper (if needed)
      // Since the glass stack itself doesn't have a shadow property, we wrap the whole stack.
      // FL12 Fix: Check shadow.enabled matching TSX (config?.shadow?.enabled === false)
      // FL20 Fix: TSX disables shadow when isExpanded (boxShadow: isExpanded ? 'none' : ...)
      if (!isExpanded &&
          widget.config.raw['shadow']?['enabled'] != false &&
          floaterLayer.raw['style']?['shadowEnabled'] != false) {
        // FL13 Fix: TSX has two shadow paths with different defaults
        // Configured (any shadow prop set): blur=24, spread=4, color=rgba(0,0,0,0.25)
        // Unconfigured (no shadow config):  blur=32, spread=0, color=rgba(0,0,0,0.15)
        final shadowCfg = widget.config.raw['shadow'];
        final bool hasConfiguredShadow = shadowCfg is Map &&
            (shadowCfg['blur'] != null ||
                shadowCfg['spread'] != null ||
                shadowCfg['x'] != null ||
                shadowCfg['y'] != null);
        final double defaultBlur = hasConfiguredShadow ? 24 : 32;
        final double defaultSpread = hasConfiguredShadow ? 4 : 0;
        final double defaultColorOpacity = hasConfiguredShadow ? 0.25 : 0.15;

        containerContent = Container(
            decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: [
              BoxShadow(
                  color: NinjaLayerUtils.parseColor(shadowCfg?['color'])
                          ?.withOpacity((shadowCfg?['color'] != null)
                              ? 1.0
                              : defaultColorOpacity) ??
                      Colors.black.withOpacity(defaultColorOpacity),
                  blurRadius: ((shadowCfg?['blur'] as num?)?.toDouble() ??
                          defaultBlur) *
                      scaleX,
                  offset: Offset(
                    ((shadowCfg?['x'] as num?)?.toDouble() ?? 0) * scaleX,
                    ((shadowCfg?['y'] as num?)?.toDouble() ?? 8) * scaleX,
                  ),
                  spreadRadius: ((shadowCfg?['spread'] as num?)?.toDouble() ??
                          defaultSpread) *
                      scaleX)
            ]),
            child: containerContent);
      }
    } else {
      // Standard Mode
      // Bug 9 Fix: Backdrop clipping Shadow issue.
      // If we use ClipRRect in Standard Mode (for overflow:hidden), we kill the shadow if applied to the same container?
      // No, Standard mode uses Container's decoration.boxShadow which draws OUTSIDE the clip if clipBehavior is None.
      // But if overflow is hidden, clipBehavior is HardEdge.
      // TSX: DraggableLayerWrapper handles this.
      // Here: We split the shadow decoration and the clipping logic to ensure shadows are never clipped.

      final shadowBox = (!isExpanded &&
              widget.config.raw['shadow']?['enabled'] != false &&
              floaterLayer.raw['style']?['shadowEnabled'] != false)
          ? () {
              final sCfg = widget.config.raw['shadow'];
              final bool hasCfgShadow = sCfg is Map &&
                  (sCfg['blur'] != null ||
                      sCfg['spread'] != null ||
                      sCfg['x'] != null ||
                      sCfg['y'] != null);
              final double dBlur = hasCfgShadow ? 24 : 32;
              final double dSpread = hasCfgShadow ? 4 : 0;
              final double dOpacity = hasCfgShadow ? 0.25 : 0.15;
              return [
                BoxShadow(
                    color: NinjaLayerUtils.parseColor(sCfg?['color'])
                            ?.withValues(
                                alpha: (sCfg?['color'] != null)
                                    ? 1.0
                                    : dOpacity) ??
                        Colors.black.withValues(alpha: dOpacity),
                    blurRadius:
                        ((sCfg?['blur'] as num?)?.toDouble() ?? dBlur) * scaleX,
                    offset: Offset(
                      ((sCfg?['x'] as num?)?.toDouble() ?? 0) * scaleX,
                      ((sCfg?['y'] as num?)?.toDouble() ?? 8) * scaleX,
                    ),
                    spreadRadius:
                        ((sCfg?['spread'] as num?)?.toDouble() ?? dSpread) *
                            scaleX)
              ];
            }()
          : null;

      containerContent = Container(
          width: finalWidth,
          height: finalHeight,
          decoration: BoxDecoration(
              // The outer container ONLY handles the shadow and base background to prevent clipping
              borderRadius: borderRadius,
              boxShadow: shadowBox),
          child: ClipRRect(
            borderRadius:
                borderRadius, // Clip child content to the border radius
            child: Container(
              width: finalWidth,
              height: finalHeight,
              decoration: BoxDecoration(
                color: effectiveBgColor,
                borderRadius: borderRadius, // Inner border radius
                border: (isDashed || borderWidth <= 0)
                    ? null
                    : Border.all(color: borderColor, width: borderWidth),
                image: bgImage, // Background image applied inside the clip
              ),
              child:
                  mainContentStack, // Main content is inside the clipped inner container
            ),
          ));
    }

    // Dashed Border Overlay (if any)
    if (isDashed && borderWidth > 0) {
      containerContent = Stack(
        children: [
          containerContent,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                foregroundPainter: _DashedBorderPainter(
                  color: borderColor,
                  strokeWidth: borderWidth,
                  borderRadius: borderRadius,
                  borderStyle: borderStyle,
                  gap: borderWidth * 2,
                ),
              ),
            ),
          )
        ],
      );
    }

    // Opacity Support (Parity with Dashboard)
    final layerOpacity =
        NinjaLayerUtils.parseDouble(floaterLayer.style?['opacity']) ?? 1.0;
    if (layerOpacity < 1.0) {
      containerContent =
          Opacity(opacity: layerOpacity, child: containerContent);
    }

    return containerContent;
  }
}

// Extracted Statistic Layer for Phase 4
class _StatisticLayer extends StatefulWidget {
  final Map<String, dynamic> content;
  final double scale; // Added scale
  const _StatisticLayer({Key? key, required this.content, this.scale = 1.0})
      : super(key: key);

  @override
  __StatisticLayerState createState() => __StatisticLayerState();
}

class __StatisticLayerState extends State<_StatisticLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayValue = 0;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    final targetValue = (widget.content['value'] as num? ?? 0).toDouble();
    _shouldAnimate = widget.content['animateOnLoad'] == true;

    if (!_shouldAnimate) {
      _displayValue = targetValue;
    } else {
      _controller = AnimationController(
          duration: const Duration(milliseconds: 1000), vsync: this);
      _animation =
          Tween<double>(begin: 0, end: targetValue).animate(_controller)
            ..addListener(() {
              setState(() {
                _displayValue = _animation.value;
              });
            });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (_shouldAnimate) _controller.dispose();
    super.dispose();
  }

  // Helper for font weight
  FontWeight _parseFontWeight(dynamic val) {
    if (val == null) return FontWeight.normal;
    String v = val.toString();
    if (v == 'bold') return FontWeight.bold;
    if (v == 'normal') return FontWeight.normal;

    // Bug 22 Fix: Numeric weights
    int? w = int.tryParse(v);
    if (w != null) {
      if (w >= 900) return FontWeight.w900;
      if (w >= 800) return FontWeight.w800;
      if (w >= 700) return FontWeight.w700;
      if (w >= 600) return FontWeight.w600;
      if (w >= 500) return FontWeight.w500;
      if (w >= 400) return FontWeight.w400; // Normal
      if (w >= 300) return FontWeight.w300;
      if (w >= 200) return FontWeight.w200;
      return FontWeight.w100;
    }

    return FontWeight.normal; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.content['prefix'] ?? ''}${_displayValue.toInt()}${widget.content['suffix'] != null ? ' ${widget.content['suffix']}' : ''}',
      style: TextStyle(
        fontSize: (widget.content['fontSize'] as num? ?? 36).toDouble() *
            widget.scale, // Bug 21 Fix: Scale font
        fontWeight: _parseFontWeight(widget.content['fontWeight']),
        color: NinjaLayerUtils.parseColor(widget.content['textColor']) ??
            Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// CustomPainter for dashed and dotted borders (Copied from NinjaTextLayer for self-containment)
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final double gap;
  final String borderStyle;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.gap = 5.0,
    this.borderStyle = 'dashed',
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth <= 0) return;

    final bool isDotted = borderStyle == 'dotted';

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = isDotted ? StrokeCap.round : StrokeCap.butt;

    final RRect rrect = borderRadius.toRRect(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth,
          size.height - strokeWidth),
    );

    final Path path = Path()..addRRect(rrect);

    if (borderStyle == 'solid') {
      canvas.drawPath(path, paint);
      return;
    }

    final Path dashedPath = Path();

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;

      while (distance < metric.length) {
        if (isDotted) {
          // Draw a dot (length ~0)
          dashedPath.addPath(
            metric.extractPath(distance, distance),
            Offset.zero,
          );
          // Move forward: diameter (width) + gap
          distance += strokeWidth + gap;
        } else {
          // Dash
          final double length = gap; // Dash length equals gap
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
          // Move forward: dash length + gap
          distance += length + gap;
        }
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius ||
        gap != oldDelegate.gap ||
        borderStyle != oldDelegate.borderStyle;
  }
}

// Parity Helper: Sliding Gradient Transform for "Barber Pole" effect
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Translate X by the width of the bounds * slidePercent (0.0 to 1.0)
    // For seamless loop, we might need a larger pattern or modulo arithmetic in the gradient stops.
    // However, translating a repeated gradient tile should work if logic aligns.
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

dynamic safeScale(dynamic val, double factor) {
  if (val == null) return null;
  String strVal = val.toString().trim();
  if (strVal.endsWith('%') || strVal.endsWith('vh') || strVal.endsWith('vw'))
    return strVal;

  // Bug 5 Fix: Handle Complex Calc strings or non-px strings by returning as-is
  // TSX: if (typeof val === 'string' && !val.endsWith('px') && isNaN(Number(val))) return val;
  // Attempt parse
  final clean = strVal.replaceAll('px', '');
  if (double.tryParse(clean) == null) {
    return strVal; // Return raw string (e.g. "calc(100% - 20px)")
  }

  // Explicitly handle "px" suffix if present
  if (strVal.endsWith('px')) {
    strVal = clean;
  }

  double? num = double.tryParse(strVal);
  if (num == null) return val;
  return num * factor;
}

class NinjaProgressBarLayer extends StatefulWidget {
  final dynamic layer;
  const NinjaProgressBarLayer({Key? key, required this.layer})
      : super(key: key);

  @override
  _NinjaProgressBarLayerState createState() => _NinjaProgressBarLayerState();
}

class _NinjaProgressBarLayerState extends State<NinjaProgressBarLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _stripeController;

  @override
  void initState() {
    super.initState();
    _stripeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _stripeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    if (layer == null) return const SizedBox();
    final content = layer['content'] as Map<String, dynamic>? ?? {};

    final value = (content['value'] as num? ?? 0).toDouble();
    final max = (content['max'] as num? ?? 100).toDouble();
    final percentage = (value / max * 100).clamp(0.0, 100.0);
    final showPercentage = content['showPercentage'] != false;
    final themeColor = NinjaLayerUtils.parseColor(content['themeColor']) ??
        const Color(0xFF6366F1);
    final variant = content['progressBarVariant'] as String? ?? 'simple';

    // Base styles
    BorderRadius geometryRadius = BorderRadius.circular(4);
    if (variant == 'rounded') geometryRadius = BorderRadius.circular(9999);

    // Gradients/Decorations
    Gradient? barGradient;
    List<BoxShadow>? boxShadow;

    if (variant == 'gradient') {
      barGradient = LinearGradient(
        colors: [themeColor, adjustColorBrightness(themeColor, 40)],
      );
    } else if (variant == 'glow') {
      boxShadow = [
        BoxShadow(color: themeColor, blurRadius: 10, spreadRadius: 0)
      ];
    } else if (variant == 'striped' || variant == 'animated') {
      // Improved Striped Logic (Parity with CSS 25% stripes)
      // Pattern: Color 0-25%, Transparent 25-50% -> Repeated
      barGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight, // 45 degree roughly
        tileMode: TileMode.repeated,
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.15),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.25, 0.5],
      );
    }

    if (variant == 'segmented') {
      return Row(
        children: List.generate(10, (index) {
          final isActive = (index + 1) * 10 <= percentage;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: isActive ? themeColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      );
    }

    // Animation Wrapper for 'animated' variant
    Widget progressFill = Container(
      decoration: BoxDecoration(
        color: barGradient == null ? themeColor : null,
        gradient: barGradient,
        borderRadius: geometryRadius,
        boxShadow: boxShadow,
      ),
      child: showPercentage
          ? Center(
              child: Text('${percentage.round()}%',
                  style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)))
          : null,
    );

    if (variant == 'animated') {
      progressFill = AnimatedBuilder(
          animation: _stripeController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                  color: themeColor, // Base color
                  borderRadius: geometryRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    tileMode: TileMode.repeated,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 0.25, 0.5],
                    transform: _SlidingGradientTransform(
                        _stripeController.value), // Animate
                  )),
            );
          });
    }

    return Container(
      width: double.infinity,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: geometryRadius,
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: percentage / 100,
            child: progressFill,
          ),
        ],
      ),
    );
  }
}

Widget buildFloaterLayerGlobally(
    dynamic layer,
    double scaleX,
    double scaleY,
    List<dynamic> allLayers,
    Function(String, Map<String, dynamic>?) onCustomAction,
    {double? parentWidth,
    double? parentHeight,
    String? campaignId,
    NudgeConfig? config,
    bool isActive = true}) {
  if (layer['visible'] == false) return const SizedBox();

  // 0. Propagate Data Binding recursively
  // If layer contains a inherited 'mappedState', resolve strings dynamically
  if (layer is Map<String, dynamic> && layer.containsKey('mappedState')) {
    layer = NinjaLayerUtils.applyMappedData(layer, layer['mappedState']);
  }

  // Type-safe style extraction and content fallback
  final styleRaw = layer['style'];
  final style = Map<String, dynamic>.from(
      styleRaw is Map<String, dynamic> ? styleRaw : <String, dynamic>{});

  if (layer['content'] is Map) {
    final content = layer['content'] as Map;
    final layoutKeys = [
      'position', 'top', 'bottom', 'left', 'right', 'width', 'height', 'zIndex',
      'backgroundColor', 'borderColor', 'borderWidth', 'borderRadius', 'fontSize', 'fontWeight',
      'textColor', 'alignSelf', 'margin', 'marginTop', 'marginBottom', 'marginLeft', 'marginRight',
      'padding', 'paddingTop', 'paddingBottom', 'paddingLeft', 'paddingRight'
    ];
    for (var key in layoutKeys) {
      if (!style.containsKey(key) && content.containsKey(key)) {
        style[key] = content[key];
      }
    }
  }

  // Normalize layer style
  final Map<String, dynamic> mutableLayer = Map<String, dynamic>.from(
      layer is Layer ? (layer as Layer).raw : (layer as Map));
  mutableLayer['style'] = style;
  layer = mutableLayer;

  final isAbsolute =
      style['position'] == 'absolute' || style['position'] == 'fixed';

  // Scale Factors

  // Dashboard Parity: STRETCH FIX - Convert pixel positions to percentages
  // Design baseline: see [kNinjaDesignWidth] / [kNinjaDesignHeight]
  double? toPercentX(dynamic val) {
    if (val == null) return null;
    String s = val.toString().trim();

    // Already percentage
    if (s.contains('%')) {
      double? pct = double.tryParse(s.replaceAll('%', '').trim());
      return pct; // Return as number (will be used as percentage)
    }

    // Convert pixels to percentage
    double? num = double.tryParse(s.replaceAll('px', '').trim());
    if (num == null) return null;

    // Return percentage value (e.g., 50 for 50%)
    return (num / kNinjaDesignWidth) * 100.0;
  }

  double? toPercentY(dynamic val) {
    if (val == null) return null;
    String s = val.toString().trim();

    // Already percentage
    if (s.contains('%')) {
      double? pct = double.tryParse(s.replaceAll('%', '').trim());
      return pct;
    }

    // Convert pixels to percentage
    double? num = double.tryParse(s.replaceAll('px', '').trim());
    if (num == null) return null;

    // Return percentage value
    return (num / kNinjaDesignHeight) * 100.0;
  }

  // Helper to resolve Value (Percentage or Pixel)
  double? resolveValue(dynamic val, double scale, double? referenceSize) {
    if (val == null) return null;

    String s = val.toString();

    // Handle percentage values
    if (s.contains('%')) {
      // Fix: Don't fall through to pixel scaling if percentage without reference
      if (referenceSize == null) return null;

      double? pct = double.tryParse(s.replaceAll('%', '').trim());
      if (pct != null) {
        // NOTE: DO NOT APPLY SCALE HERE, referenceSize is ALREADY scaled by BottomSheet/Floater wrapper
        return (pct / 100.0) * referenceSize;
      }
      // Invalid percentage format
      return null;
    }

    // Pixel scaling handles pure numbers
    // Note: We use double.tryParse on safeScale result to ensure numeric parity
    return double.tryParse(safeScale(val, scale).toString());
  }

  // Sizing
  double? width = resolveValue(
      style['width'] ?? layer['size']?['width'], scaleX, parentWidth);
  double? height = resolveValue(
      style['height'] ?? layer['size']?['height'], scaleY, parentHeight);

  // Margins (Relative only)
  EdgeInsets margin = EdgeInsets.zero;
  if (!isAbsolute) {
    // Percent margins usually relative to WIDTH (CSS spec), but usage varies.
    // Using respective axis for safety in Flutter.
    double? mt = resolveValue(style['marginTop'], scaleY, parentHeight);
    double? mb = resolveValue(style['marginBottom'], scaleY, parentHeight);
    double? ml = resolveValue(style['marginLeft'], scaleX, parentWidth);
    double? mr = resolveValue(style['marginRight'], scaleX, parentWidth);

    // Shorthand 'margin' (Dashboard Parity: Handle 2, 3, 4 value CSS)
    if (style['margin'] != null) {
      String mStr = style['margin'].toString().trim();
      if (mStr.contains(' ')) {
        // Multi-value CSS shorthand
        List<String> parts = mStr.split(RegExp(r'\s+'));
        if (parts.length == 2) {
          double? mv = resolveValue(parts[0], scaleY, parentHeight);
          double? mh = resolveValue(parts[1], scaleX, parentWidth);
          mt ??= mv;
          mb ??= mv;
          ml ??= mh;
          mr ??= mh;
        } else if (parts.length == 3) {
          double? ptTop = resolveValue(parts[0], scaleY, parentHeight);
          double? ptHoriz = resolveValue(parts[1], scaleX, parentWidth);
          double? ptBottom = resolveValue(parts[2], scaleY, parentHeight);
          mt ??= ptTop;
          ml ??= ptHoriz;
          mr ??= ptHoriz;
          mb ??= ptBottom;
        } else if (parts.length == 4) {
          mt ??= resolveValue(parts[0], scaleY, parentHeight);
          mr ??= resolveValue(parts[1], scaleX, parentWidth);
          mb ??= resolveValue(parts[2], scaleY, parentHeight);
          ml ??= resolveValue(parts[3], scaleX, parentWidth);
        }
      } else {
        // Single value
        double? mAll = resolveValue(style['margin'], scaleX, parentWidth);
        if (mAll != null) {
          mt ??= mAll;
          mb ??= mAll;
          ml ??= mAll;
          mr ??= mAll;
        }
      }
    }

    // Default margin (Dashboard Parity: Only exclude grid items, containers, custom_html)
    if (mb == null &&
        style['margin'] == null &&
        layer['type'] != 'custom_html' &&
        layer['type'] != 'grid_item' &&
        layer['type'] != 'grid_container') {
      mb = 10.0 * scaleY;
    }

    margin = EdgeInsets.only(
        top: mt ?? 0, bottom: mb ?? 0, left: ml ?? 0, right: mr ?? 0);
  }

  // Fixed Button Decoration Logic
  bool stripVisuals =
      ['input', 'copy_button', 'button', 'text'].contains(layer['type']);

  // Dashboard Parity: Strip padding for absolute/fixed positioned elements
  EdgeInsets padding = isAbsolute ? EdgeInsets.zero : EdgeInsets.zero;

  // Decoration
  BoxDecoration? decoration;

  if (!stripVisuals) {
    if (!isAbsolute) {
      final paddingMap = style['padding'] is Map ? style['padding'] : null;
      padding = EdgeInsets.only(
        top: resolveValue(paddingMap?['top'] ?? style['paddingTop'], scaleY,
                parentHeight) ??
            0,
        bottom: resolveValue(paddingMap?['bottom'] ?? style['paddingBottom'],
                scaleY, parentHeight) ??
            0,
        left: resolveValue(paddingMap?['left'] ?? style['paddingLeft'], scaleX,
                parentWidth) ??
            0,
        right: resolveValue(paddingMap?['right'] ?? style['paddingRight'],
                scaleX, parentWidth) ??
            0,
      );
    }

    Color? bgColor = NinjaLayerUtils.parseColor(style['backgroundColor']);
    Color? borderColor = NinjaLayerUtils.parseColor(style['borderColor']);
    double borderWidth =
        resolveValue(style['borderWidth'] ?? 0, scaleX, parentWidth) ?? 0;

    // BorderRadius
    BorderRadius? borderRadius;
    if (style['borderRadius'] is Map) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(resolveValue(
                style['borderRadius']['topLeft'], scaleX, parentWidth) ??
            0),
        topRight: Radius.circular(resolveValue(
                style['borderRadius']['topRight'], scaleX, parentWidth) ??
            0),
        bottomRight: Radius.circular(resolveValue(
                style['borderRadius']['bottomRight'], scaleX, parentWidth) ??
            0),
        bottomLeft: Radius.circular(resolveValue(
                style['borderRadius']['bottomLeft'], scaleX, parentWidth) ??
            0),
      );
    } else {
      double r = resolveValue(style['borderRadius'], scaleX, parentWidth) ?? 0;
      borderRadius = BorderRadius.circular(r);
    }

    // Dashboard Parity: Clip Path Shape Enforcing
    if ((layer['style'] is Map && layer['style']['clipPathShape'] == 'pill') ||
        (layer['style'] is Map &&
            layer['style']['clip_path_shape'] == 'pill')) {
      borderRadius = BorderRadius.circular(9999.0);
    }

    if (bgColor != null ||
        (borderColor != null && borderWidth > 0) ||
        style['backgroundImage'] != null ||
        style['background_image'] != null) {
      DecorationImage? bgImage;
      final bgUrl = style['backgroundImage']?.toString() ??
          style['background_image']?.toString();
      if (bgUrl != null) {
        // Fix: Use standard string with escapes to handle mixed quotes
        String cleanUrl =
            bgUrl.replaceAll(RegExp("^url\\(['\"]?|['\"]?\\)\$"), "");
        if (cleanUrl.isNotEmpty) {
          // Try/Catch for base64 or network
          ImageProvider? provider;
          if (cleanUrl.startsWith('data:')) {
            try {
              final base64String =
                  cleanUrl.split(',').last.replaceAll(RegExp(r'\s+'), '');
              provider = MemoryImage(base64Decode(base64String));
            } catch (e) {
              NinjaLog.d('AppNinja', "Layer BG Base64 Error: $e");
            }
          } else if (cleanUrl.startsWith('http')) {
            provider = NetworkImage(cleanUrl);
          }

          if (provider != null) {
            final bgSize = style['backgroundSize']?.toString();
            final fit = bgSize != null
                ? NinjaLayerUtils.parseBoxFit(bgSize)
                : BoxFit.cover;
            bgImage = DecorationImage(image: provider, fit: fit);
          }
        }
      }

      decoration = BoxDecoration(
        color: bgColor,
        border: (borderColor != null && borderWidth > 0)
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        borderRadius: borderRadius,
        image: bgImage, // Correctly visualised
      );
    }
  }

  // CRITICAL FIX: Pass campaignId through to buildFloaterLayerWidget.
  // Previously, buildFloaterLayerGlobally received campaignId from FloaterRenderV2
  // but DROPPED it here, causing NinjaSpinTheWheelLayer to always get null campaignId
  // → localFallbackSpin() → isWin=false → "Better Luck" every time.
  Widget childContent = buildFloaterLayerWidget(
      layer, scaleX, scaleY, allLayers, onCustomAction,
      parentWidth: parentWidth,
      parentHeight: parentHeight,
      campaignId: campaignId,
      config: config,
      isActive: isActive);

  // FIX (Double Styling): For 'carousel', the styling is handled INSIDE the widget (NinjaCarouselLayer).
  // Applying it here causes double border, double padding, double shadow.
  // We strictly STRIP decorations for this type. Exception: Containers handle inner, but NEED outer padding.

  // Also FIX (Clip): Carousel defaults to Clip.antiAlias which cuts off arrows/dots.
  // We must set it to Clip.none for Carousel.

  // Determine clip behavior based on overflow property (Dashboard Parity)
  Clip clipBehavior;
  if (layer['type'] == 'carousel' || layer['type'] == 'spinthewheel') {
    clipBehavior = Clip.none;
  } else {
    String? overflow = style['overflow'];
    if (overflow == 'hidden') {
      clipBehavior = Clip.hardEdge;
    } else if (overflow == 'visible') {
      clipBehavior = Clip.none;
    } else {
      clipBehavior = Clip.hardEdge;
    }
  }

  // ARCHITECTURE PARITY FIX: Only carousel delegates entirely to internal decoration
  bool isCarousel = layer['type'] == 'carousel';
  bool isContainer =
      layer['type'] == 'container' || layer['type'] == 'grid_item';

  // For container, we MUST preserve outer wrapper geometry (width/height/margin).
  // However decoration parsing needs to remain inside the Container Layer for internal shadows/borders.
  if (isCarousel) {
    clipBehavior = Clip.none;
  }

  BoxDecoration? finalDecoration = isContainer ? null : decoration;

  Widget finalChild = childContent;
  if (finalDecoration == null && clipBehavior != Clip.none) {
    // NinjaContainerLayer handles its own clipping internally, only wrap generic layers
    if (!isContainer) {
      finalChild = ClipRect(clipBehavior: clipBehavior, child: childContent);
    }
  }

  Widget wrapped = Container(
    width: width,
    height: height,
    margin: margin,
    // Provide padding for typical layers, containers handle padding internally but wrap needs boundary
    padding: isCarousel
        ? EdgeInsets.zero
        : (isContainer ? EdgeInsets.zero : padding),
    decoration: finalDecoration,
    clipBehavior: finalDecoration != null ? clipBehavior : Clip.none,
    child: finalChild,
  );

  // Transform & Filter
  wrapped = NinjaLayerUtils.applyTransform(wrapped, style['transform']);
  wrapped = NinjaLayerUtils.applyFilterString(wrapped, style['filter']);

  // Glassmorphism Support (Generic Layers)
  // Dashboard Parity: Scale blur value like Dashboard's safeScale
  if (style['backdropFilter'] != null) {
    double blur = 0;
    final bf = style['backdropFilter'];
    if (bf is Map) {
      if (bf['enabled'] == true) {
        double rawBlur = double.tryParse(bf['blur']?.toString() ?? '10') ?? 10;
        blur = rawBlur * scaleX; // Dashboard uses safeScale(blur, scale)
      }
    }

    if (blur > 0) {
      // Get borderRadius - might be in decoration or calculated earlier
      BorderRadius? effectiveBorderRadius;
      if (decoration?.borderRadius != null) {
        effectiveBorderRadius = decoration!.borderRadius as BorderRadius?;
      } else if (isCarousel || isContainer) {
        // Complex layouts have null decoration, need to calculate borderRadius from style
        final rawRadius = style['borderRadius'] ?? style['border_radius'];
        if (rawRadius != null) {
          if (rawRadius is Map) {
            effectiveBorderRadius = BorderRadius.only(
              topLeft: Radius.circular(
                  resolveValue(rawRadius['topLeft'], scaleX, parentWidth) ?? 0),
              topRight: Radius.circular(
                  resolveValue(rawRadius['topRight'], scaleX, parentWidth) ??
                      0),
              bottomRight: Radius.circular(
                  resolveValue(rawRadius['bottomRight'], scaleX, parentWidth) ??
                      0),
              bottomLeft: Radius.circular(
                  resolveValue(rawRadius['bottomLeft'], scaleX, parentWidth) ??
                      0),
            );
          } else {
            double r = resolveValue(rawRadius, scaleX, parentWidth) ?? 0;
            effectiveBorderRadius = BorderRadius.circular(r);
          }
        }
      }

      wrapped = ClipRRect(
          borderRadius: effectiveBorderRadius ?? BorderRadius.zero,
          child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: wrapped));
    }
  }

  // Dashboard Parity: Apply opacity if specified
  if (style['opacity'] != null) {
    double? opacityValue = double.tryParse(style['opacity'].toString());
    if (opacityValue != null && opacityValue < 1.0) {
      wrapped = Opacity(
        opacity: opacityValue.clamp(0.0, 1.0),
        child: wrapped,
      );
    }
  }

  // Absolute Positioning
  if (isAbsolute) {
    // ✅ FIX 2: DASHBOARD STRETCH PARITY
    // Convert raw pixels to percentages so elements stretch EXACTLY like the background image
    dynamic getStretchX(dynamic v) {
      if (v == null || v.toString().contains('%')) return v;
      double? num = double.tryParse(v.toString().replaceAll('px', '').trim());
      if (num == null) return v;
      return '${(num / 393.0) * 100}%'; // 393 is design width
    }

    dynamic getStretchY(dynamic v) {
      if (v == null || v.toString().contains('%')) return v;
      double? num = double.tryParse(v.toString().replaceAll('px', '').trim());
      if (num == null) return v;
      return '${(num / 852.0) * 100}%'; // 852 is design height
    }

    dynamic stretchedTop = getStretchY(style['top']);
    dynamic stretchedBottom = getStretchY(style['bottom']);
    dynamic stretchedLeft = getStretchX(style['left']);
    dynamic stretchedRight = getStretchX(style['right']);

    // Now resolve the percentage values using scaled parent dimensions
    // 🚀 FIX: Pass 1.0 to resolveValue to get the raw pixel/percentage value relative to scaled parent,
    // then manually apply scale ONLY to pixel-based offsets to avoid double-scaling drift.
    double? top = resolveValue(stretchedTop, 1.0, parentHeight);
    double? bottom = resolveValue(stretchedBottom, 1.0, parentHeight);
    double? left = resolveValue(stretchedLeft, 1.0, parentWidth);
    double? right = resolveValue(stretchedRight, 1.0, parentWidth);

    // Apply scaling only if it's NOT a percentage (percentages are already relative to scaled parent)
    if (top != null && stretchedTop.toString().contains('%') == false) {
      top = top * scaleY;
    }
    if (bottom != null && stretchedBottom.toString().contains('%') == false) {
      bottom = bottom * scaleY;
    }
    if (left != null && stretchedLeft.toString().contains('%') == false) {
      left = left * scaleX;
    }
    if (right != null && stretchedRight.toString().contains('%') == false) {
      right = right * scaleX;
    }

    // Apply width and height explicitly if calculated, to prevent 0x0 collapse
    if (width != null || height != null) {
      wrapped = SizedBox(
        width: width,
        height: height,
        child: wrapped,
      );
    }

    return Positioned(
      key: ValueKey('pos_${layer['id'] ?? layer.hashCode}'),
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: wrapped,
    );
  }

  // Apply width and height for relative layers too
  if (width != null || height != null) {
    wrapped = SizedBox(
      width: width,
      height: height,
      child: wrapped,
    );
  }

  return wrapped;
}

Widget buildFloaterLayerWidget(
    dynamic layer,
    double scaleX,
    double scaleY,
    List<dynamic> allLayers,
    Function(String, Map<String, dynamic>?) onCustomAction,
    {double? parentWidth,
    double? parentHeight,
    String? campaignId,
    NudgeConfig? config,
    bool isActive = true}) {
  String type = layer['type'] ?? 'unknown';

  // Handle 'media' alias for image
  if (type == 'media') {
    type = 'image';
  }

  // Construct Size object for child layers that expect it
  final parentSize = (parentWidth != null || parentHeight != null)
      ? Size(parentWidth ?? double.infinity, parentHeight ?? double.infinity)
      : null;

  switch (type) {
    case 'custom_html':
      return NinjaCustomHtmlLayer(
          key: ValueKey(layer['id']),
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
          scale: scaleX,
          parentSize: parentSize,
          onAction: (action) => onCustomAction(action['name'] ?? action['type'] ?? '', action['payload'] ?? action),
      );

    case 'text':
      return NinjaTextLayer(
          key: ValueKey(layer['id']),
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
          scale: scaleX,
          parentSize: parentSize);

    case 'button':
      return NinjaButtonLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        parentSize: parentSize, // Fix: Pass parentSize
        onAction: (action, data) => onCustomAction(action, data),
      );

    case 'media':
      final content = (layer is Layer
              ? layer.raw
              : (layer as Map<String, dynamic>))['content']
          as Map<String, dynamic>?;
      final url =
          content?['imageUrl']?.toString() ?? content?['url']?.toString() ?? '';
      final isVideo = url.toLowerCase().contains('.mp4') ||
          url.toLowerCase().contains('.webm') ||
          url.toLowerCase().contains('youtube.com') ||
          url.toLowerCase().contains('youtu.be');

      if (isVideo) {
        return NinjaVideoLayer(
          key: ValueKey(layer['id']),
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
          scale: scaleX,
          onAction: (a, d) => onCustomAction(a, d),
          isActive: isActive,
        );
      }

      // Fallthrough to image logic if not video
      return NinjaImageLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        onAction: (a, d) => onCustomAction(a, d ?? {}),
      );

    case 'image':
      return NinjaImageLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        onAction: (a, d) => onCustomAction(a, d ?? {}),
      );

    case 'lottie':
      return NinjaLottieLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        parentSize: parentSize,
        onAction: (a, d) => onCustomAction(a, d ?? {}),
        isActive: isActive,
      );

    case 'rive':
      return NinjaRiveLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        parentSize: parentSize,
        onAction: (a, d) => onCustomAction(a, d ?? {}),
        isActive: isActive,
      );

    case 'input':
      return NinjaInputLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        scaleY: scaleY, // Fix: Pass scaleY for height/vertical padding parity
        parentSize: parentSize,
        onAction: (a, d) => onCustomAction(a, d),
      );

    case 'grid_container':
      return NinjaGridContainerLayer(
          key: ValueKey(layer['id']),
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
          scale: scaleX,
          scaleY: scaleY,
          allLayers: allLayers,
          // When grid container loops, it passes mappedData.
          // We override renderChild to map the text/properties if mappedData exists.
          renderChild: (childLayer, mappedData,
              {double? parentWidth, double? parentHeight}) {
            // Apply mapped data to layer content before building it
            final resolvedLayer = NinjaLayerUtils.applyMappedData(
                Map<String, dynamic>.from(childLayer), mappedData);

            return buildFloaterLayerWidget(
                resolvedLayer, scaleX, scaleY, allLayers, onCustomAction,
                // FIX 1: Pass ONLY locally bounded constraints. The shadowed parameter accurately provides this.
                parentWidth: parentWidth,
                parentHeight: parentHeight,
                campaignId: campaignId,
                config: config,
                isActive: isActive);
          });

    case 'copy_button':
      return NinjaCopyButtonLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        parentSize: parentSize, // Fix: Pass parentSize
      );

    case 'container':
    case 'grid_item': // grid_item is functionally a container that can receive mapped data
      // Recursive rendering for container children
      return NinjaContainerLayer(
          key: ValueKey(layer['id']),
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
          scale: scaleX,
          scaleY: scaleY,
          isRoot: false,
          parentSize: (parentWidth != null && parentHeight != null)
              ? Size(parentWidth, parentHeight)
              : parentSize,
          // CRITICAL FIX: Convert List<Layer> to List<Map> so containers can find children
          allLayers: allLayers,
          onAction: (a, d) => onCustomAction(a, d),
          isActive: isActive,
          // Dashboard Parity: Pass _buildLayer callback for nested children
          renderChild: (childLayer,
                  {double? parentWidth, double? parentHeight}) =>
              buildFloaterLayerGlobally(
                  childLayer, scaleX, scaleY, allLayers, onCustomAction,
                  parentWidth: parentWidth,
                  parentHeight: parentHeight,
                  campaignId: campaignId,
                  config: config,
                  isActive: isActive));

    case 'countdown':
      return NinjaCountdownLayer(
          key: ValueKey(layer['id']),
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
          scale: scaleX,
          onAction: ((a, d) => onCustomAction(a, d)));

    case 'progress-bar':
      return NinjaProgressBarLayer(
          layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>));

    case 'carousel':
      return NinjaCarouselLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        // CRITICAL FIX: Convert List<Layer> to List<Map> so carousel/containers can find children
        allLayers: allLayers,
        scale: scaleX,
        scaleY: scaleY,
        parentSize: parentSize, // Fix: Pass parentSize for correct child sizing
        isActive: isActive,
        // Dashboard Parity: Pass _buildLayer as callback so slides get Floater styling
        renderChild: (childLayer, {isActive = true}) => buildFloaterLayerGlobally(
            childLayer, scaleX, scaleY, allLayers, onCustomAction,
            parentWidth: parentWidth,
            parentHeight: parentHeight,
            campaignId: campaignId,
            config: config,
            isActive: isActive),
      );

    case 'video':
      return NinjaVideoLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        onAction: (a, d) => onCustomAction(a, d),
        isActive: isActive,
      );

    case 'scratch_foil':
      final Map<String, dynamic> scratchLayer = Map<String, dynamic>.from(layer is Layer ? layer.raw : (layer as Map<String, dynamic>));
      // CRITICAL FIX: Inject campaignId into the layer properties so the Scratch Foil
      // layer can properly synchronize with the backend gamification ledger engine!
      if (campaignId != null && scratchLayer['campaignId'] == null) {
          scratchLayer['campaignId'] = campaignId;
      }
      return NinjaScratchFoilLayer(
        key: ValueKey(layer['id']),
        layer: scratchLayer,
        allLayers: allLayers,
        scale:
            scaleX, // Assuming uniform scale logic typically desired for canvas-like elements
        onAction: (a, d) => onCustomAction(a, d),
      );

    case 'statistic':
      return _StatisticLayer(content: layer['content'] ?? {}, scale: scaleX);

    // Bug 5: Gradient Overlay
    case 'gradient-overlay':
      final content = layer['content'] as Map<String, dynamic>?;
      final stops = (content?['gradientStops'] as List?) ?? [];
      Color c1 = Colors.transparent;
      Color c2 = Colors.black.withOpacity(0.5);

      if (stops.isNotEmpty) {
        if (stops.length > 0)
          c1 = NinjaLayerUtils.parseColor(stops[0]['color']) ?? c1;
        if (stops.length > 1)
          c2 = NinjaLayerUtils.parseColor(stops[1]['color']) ?? c2;
      }

      // Parity Fix: Parse gradient direction
      Alignment begin = Alignment.topCenter;
      Alignment end = Alignment.bottomCenter;

      // Default from TSX is 'to bottom' usually, but let's check content
      final direction =
          content?['gradientDirection']?.toString().toLowerCase() ??
              'to bottom';

      switch (direction) {
        case 'to right':
          begin = Alignment.centerLeft;
          end = Alignment.centerRight;
          break;
        case 'to left':
          begin = Alignment.centerRight;
          end = Alignment.centerLeft;
          break;
        case 'to top':
          begin = Alignment.bottomCenter;
          end = Alignment.topCenter;
          break;
        case 'to bottom right':
          begin = Alignment.topLeft;
          end = Alignment.bottomRight;
          break;
        case 'to bottom left':
          begin = Alignment.topRight;
          end = Alignment.bottomLeft;
          break;
        case 'to top right':
          begin = Alignment.bottomLeft;
          end = Alignment.topRight;
          break;
        case 'to top left':
          begin = Alignment.bottomRight;
          end = Alignment.topLeft;
          break;
        case 'to bottom':
        default:
          begin = Alignment.topCenter;
          end = Alignment.bottomCenter;
          break;
      }

      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [c1, c2],
        )),
      );

    // Add other cases as needed (checkbox, radio, etc. if they have specific renderers)

    case 'spinthewheel':
      return NinjaSpinTheWheelLayer(
        key: ValueKey(layer['id']),
        layer: layer is Layer ? layer.raw : (layer as Map<String, dynamic>),
        scale: scaleX,
        parentSize: parentSize,
        onAction: (a, d) => onCustomAction(a, d),
        config: config,
        campaignId: campaignId,
        allLayers: allLayers,
        renderChild: (childLayer,
                {double? parentWidth, double? parentHeight}) =>
            buildFloaterLayerGlobally(
                childLayer, scaleX, scaleY, allLayers, onCustomAction,
                parentWidth: parentWidth,
                parentHeight: parentHeight,
                campaignId: campaignId,
                config: config),
      );

    case 'custom_html':
      // Basic HTML placeholder or HtmlWidget if package available
      // For now, simple placeholder as in TSX fallback
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, style: BorderStyle.solid)),
        child: const Text("Custom HTML (Not fully supported)"),
      );

    default:
      return const SizedBox(); // Unknown types hidden
  }
}

// Global Helper to adjust color brightness (Dart equivalent)
Color adjustColorBrightness(Color color, double percent) {
  // Determine if we need to lighten or darken
  // TSX logic: adds amount to R,G,B.
  // 2.55 * percent. If percent is positive 40, amt is 102.
  final amt = (2.55 * percent).round();
  int r = color.red + amt;
  int g = color.green + amt;
  int b = color.blue + amt;
  return Color.fromARGB(
      color.alpha, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
}
