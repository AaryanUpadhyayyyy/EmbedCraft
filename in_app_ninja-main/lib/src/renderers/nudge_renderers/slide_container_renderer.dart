import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../layers/ninja_layer_utils.dart';
import '../layers/ninja_video_layer.dart';
import 'Floater_render_v2.dart';

class SlideContainerRenderer extends StatefulWidget {
  final Map<String, dynamic> story;
  final VoidCallback? onNextStory;
  final VoidCallback? onPrevStory;
  final VoidCallback? onDismiss;
  final Function(String action, Map<String, dynamic>? data)? onCTAClick;

  const SlideContainerRenderer({
    Key? key,
    required this.story,
    this.onNextStory,
    this.onPrevStory,
    this.onDismiss,
    this.onCTAClick,
  }) : super(key: key);

  @override
  State<SlideContainerRenderer> createState() => _SlideContainerRendererState();
}

class _SlideContainerRendererState extends State<SlideContainerRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  int _currentSlideIndex = 0;
  bool _isPaused = false;
  bool _isReady = false;
  bool _isMuted = true;
  List<dynamic> _slides = [];
  List<dynamic> _allLayers = [];
  Map<String, dynamic>? _rootContainer;

  // Per-slide duration — reads from active slide's content.duration
  double get _currentSlideDuration {
    if (_slides.isEmpty) return 5.0;
    final slide = _slides[_currentSlideIndex];
    final mode = slide['content']?['autoAdvanceMode']?.toString() ?? 'fixed';
    if (mode == 'manual') return 0.0;
    return (slide['content']?['duration'] as num?)?.toDouble() ?? 5.0;
  }

  // BUG A FIX: Match Dashboard's full video detection — bgUrl, YouTube, OR child video/media layers
  bool _isSlideVideo(dynamic slide) {
    final url = (slide['content']?['url']?.toString() ?? '').trim();
    if (_isVideoUrl(url)) return true;
    if (_isYouTubeUrl(url)) return true;
    // Check if any child layer is a video/media type
    final slideId = slide['id'];
    return _allLayers.any((l) {
      if (l['parent'] != slideId) return false;
      if (l['type'] == 'video') return true;
      if (l['type'] == 'media') {
        final mediaUrl = l['content']?['imageUrl']?.toString() ?? '';
        return _isVideoUrl(mediaUrl) || _isYouTubeUrl(mediaUrl);
      }
      return false;
    });
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    // Dashboard: url.toLowerCase().match(/\.(mp4|webm|ogg)$/)
    return lower.endsWith('.mp4') || lower.endsWith('.webm') || lower.endsWith('.ogg');
  }

  bool _isYouTubeUrl(String url) {
    // Dashboard getYouTubeId regex (lib/utils.ts line 9):
    // /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=|shorts\/)([^#&?]*).*/
    // Returns non-null ONLY if match[2].length === 11 (valid YouTube video ID)
    // SDK must match this — a bare youtube.com homepage has no valid 11-char ID.
    final regExp = RegExp(
      r'(?:youtu\.be/|v/|u/\w/|embed/|watch\?v=|&v=|shorts/)([^#&?]{11})'
    );
    return regExp.hasMatch(url);
  }

  @override
  void initState() {
    super.initState();
    _extractSlides();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_currentSlideDuration * 1000).toInt()),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleAutoAdvance();
      }
    });

    if (_slides.isNotEmpty) {
      _onSlideChanged(0);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onNextStory != null) {
          widget.onNextStory!.call();
        } else {
          widget.onDismiss?.call();
        }
      });
    }
  }

  void _extractSlides() {
    _allLayers = widget.story['layers'] is List
        ? List<dynamic>.from(widget.story['layers'])
        : [];

    for (final l in _allLayers) {
      if (l is Map &&
          l['type'] == 'container' &&
          (l['parent'] == null || l['parent'] == '')) {
        _rootContainer = Map<String, dynamic>.from(l);
        break;
      }
    }

    if (_rootContainer != null) {
      _slides = _allLayers
          .where((l) =>
              l['parent'] == _rootContainer!['id'] && l['type'] == 'container')
          .toList();
    } else {
      _slides = _allLayers
          .where((l) =>
              l['type'] == 'container' &&
              (l['parent'] == null || l['parent'] == ''))
          .toList();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _onSlideChanged(int index) {
    if (!mounted) return;
    setState(() {
      _currentSlideIndex = index;
      _isPaused = false;
      _isReady = false;
    });

    // Update duration for this specific slide
    _progressController.duration =
        Duration(milliseconds: (_currentSlideDuration * 1000).toInt());

    final slide = _slides[index];
    final bgUrl = (slide['content']?['url']?.toString() ?? '').trim();
    // Dashboard line 289-292:
    //   const isVid = url.match(/\.(mp4|webm|ogg)$/)
    //   const ytid = getYouTubeId(url)  ← validates 11-char video ID
    //   if (!isVid && !ytid) setIsReady(true)  ← images ready immediately
    // YouTube backgrounds: Dashboard shows iframe with onLoad → setIsReady(true).
    // SDK shows a black placeholder (no iframe/video) → NinjaVideoStatusNotification
    // NEVER fires for YouTube → slide stuck forever. Fix: YouTube placeholder
    // is treated like an image (no playback) → mark ready immediately.
    final isDirectVideoBg = _isVideoUrl(bgUrl); // .mp4/.webm/.ogg only

    if (!isDirectVideoBg) {
      // Image background OR YouTube placeholder (black container) → ready immediately
      // (matches Dashboard: if (!isVid && !ytid) setIsReady(true), plus iframe onLoad)
      _markReady();
    }
    // else: direct video bg → wait for NinjaVideoStatusNotification(isPlaying:true)
  }

  void _markReady() {
    if (!mounted) return;
    setState(() => _isReady = true);
    // Dashboard line 617: progress bar animation condition: autoAdvanceMode !== 'manual'
    // For manual mode, do NOT start the progress controller — bar stays at 0%
    final mode = _slides.isNotEmpty
        ? (_slides[_currentSlideIndex]['content']?['autoAdvanceMode']?.toString() ?? 'fixed')
        : 'fixed';
    if (mode == 'manual') return;
    if (!_isPaused) {
      _progressController.forward(from: 0);
    }
  }

  void _pauseProgress() {
    setState(() => _isPaused = true);
    _progressController.stop();
  }

  void _resumeProgress() {
    if (!mounted) return;
    setState(() => _isPaused = false);
    if (_isReady) _progressController.forward();
  }

  void _handleAutoAdvance() {
    if (_slides.isEmpty) return;
    final slide = _slides[_currentSlideIndex];
    final mode = slide['content']?['autoAdvanceMode']?.toString() ?? 'fixed';
    if (mode == 'manual') return;
    // Dashboard line 304-305: video_completion mode ONLY waits for video 'ended' event
    // if the slide has a DIRECT background video URL (.mp4/.webm/.ogg).
    // If video_completion mode but NO direct video (e.g. YouTube, image, or child video layer),
    // it falls back to the fixed timer — so we DO advance here.
    if (mode == 'video_completion') {
      final bgUrl = (slide['content']?['url']?.toString() ?? '').trim();
      final hasDirectVideo = _isVideoUrl(bgUrl); // excludes YouTube — matches Dashboard
      if (hasDirectVideo) return; // wait for NinjaVideoStatusNotification instead
    }
    _nextSlide();
  }

  void _nextSlide() {
    if (_currentSlideIndex < _slides.length - 1) {
      _onSlideChanged(_currentSlideIndex + 1);
    } else {
      if (widget.onNextStory != null) {
        widget.onNextStory!.call();
      } else {
        widget.onDismiss?.call();
      }
    }
  }

  void _previousSlide() {
    if (_currentSlideIndex > 0) {
      _onSlideChanged(_currentSlideIndex - 1);
    } else {
      widget.onPrevStory?.call();
    }
  }

  // Dashboard: lastSwipeTime guard — ignore tap within 50ms of swipe
  int _lastSwipeTimeMs = 0;
  // Dashboard: minSwipeDistance = 30 (mapped to velocity ~300 logical px/s)
  static const double _minSwipeVelocity = 300.0;

  void _handleTap(TapUpDetails details, BuildContext context) {
    // Dashboard: if (Date.now() - lastSwipeTime.current < 50) return
    if (DateTime.now().millisecondsSinceEpoch - _lastSwipeTimeMs < 50) return;
    if (_isPaused) {
      _resumeProgress();
      return;
    }
    // Dashboard line 197-198: x = e.clientX - rect.left (LOCAL position within widget)
    // Must use localPosition, not globalPosition, to correctly find the midpoint
    final width = context.size?.width ?? MediaQuery.of(context).size.width;
    if (details.localPosition.dx > width / 2) {
      _nextSlide();
    } else {
      _previousSlide();
    }
  }

  void _handleAction(String action, Map<String, dynamic>? data) {
    _pauseProgress();
    widget.onCTAClick?.call(action, data);
  }

  // ───────────────────────────── TRANSITIONS ─────────────────────────────────

  // Default "slide": stack with AnimatedSlide translateX (matches Dashboard CSS translateX)
  // Dashboard CSS parity:
  //   .future (.slide-wrapper default): opacity:0, translateX(100%)
  //   .active:  opacity:1, translateX(0)
  //   .past:    opacity:1, translateX(-100%)
  // Dashboard JS (line 530): visibility:hidden on ALL non-active slides for SLIDE/FADE.
  // ONLY active slide is visible. Past slides disappear immediately (no slide-out).
  // Active slide slides IN from the right. Old slide disappears instantly.
  Widget _buildSlideEffect(Size layoutSize, double scaleX, double scaleY) {
    final indices = List.generate(_slides.length, (i) => i)
      ..sort((a, b) {
        if (a == _currentSlideIndex) return 1;  // active goes last (z-order)
        if (b == _currentSlideIndex) return -1;
        return a.compareTo(b);
      });

    return Stack(
      fit: StackFit.expand,
      children: indices.map((i) {
        final offset = i - _currentSlideIndex;
        final isActive = offset == 0;
        final isFuture = offset > 0;
        // Dashboard line 530: visibility:hidden on ALL non-active slides (SLIDE mode)
        // Only active slide is visible. Past slides vanish immediately.
        // Future slides: opacity:0 + invisible (animation plays while hidden, ready to reveal)
        final bool isVisible = isActive;
        final double targetOpacity = isFuture ? 0.0 : 1.0;

        return Positioned.fill(
          key: ValueKey('slide_$i'),
          child: Visibility(
            visible: isVisible,
            maintainState: true, // preserves AnimatedSlide position
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              curve: const Cubic(0.2, 0.8, 0.2, 1.0),
              opacity: targetOpacity,
              child: AnimatedSlide(
                offset: Offset(offset.toDouble(), 0),
                duration: const Duration(milliseconds: 600),
                curve: const Cubic(0.2, 0.8, 0.2, 1.0),
                child: _buildSlideBody(_slides[i], isActive, layoutSize, scaleX, scaleY),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFadeEffect(Size layoutSize, double scaleX, double scaleY) {
    // Dashboard line 530: visibility:hidden on all non-active slides (same as SLIDE mode)
    // Active slide must be last in Stack for z-order parity (Dashboard: zIndex:2)
    final indices = List.generate(_slides.length, (i) => i)
      ..sort((a, b) {
        if (a == _currentSlideIndex) return 1; // active last = highest z-order
        if (b == _currentSlideIndex) return -1;
        return a.compareTo(b);
      });

    return Stack(
      fit: StackFit.expand,
      children: indices.map((i) {
        final isActive = i == _currentSlideIndex;
        return Positioned.fill(
          key: ValueKey('fade_$i'),
          child: Visibility(
            visible: isActive, // Dashboard: visibility:hidden for non-active
            maintainState: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: isActive ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !isActive,
                child: _buildSlideBody(_slides[i], isActive, layoutSize, scaleX, scaleY),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCubeEffect(Size layoutSize, double scaleX, double scaleY) {
    final halfWidth = layoutSize.width / 2;
    final List<Map<String, dynamic>> renderList = [];

    for (int i = 0; i < _slides.length; i++) {
      final offset = (i - _currentSlideIndex).toDouble();
      // Dashboard line 530: cube shows active + ±1 adjacent slides, hides all others
      if (offset.abs() >= 2.0) continue;
      renderList.add({'i': i, 'offset': offset});
    }

    // Painter's algorithm: back-to-front (active slide on top)
    renderList.sort((a, b) =>
        (b['offset'] as double).abs().compareTo((a['offset'] as double).abs()));

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: renderList.map((item) {
        final int i = item['i'] as int;
        final double offset = item['offset'] as double;
        final isActive = offset.abs() < 0.5;
        final isVisible = isActive || offset.abs() <= 1.0;

        // Dashboard CSS cube parity (lines 489-503):
        // future (.slide-wrapper default): rotateY(90deg) translateZ(halfWidth) translateX(halfWidth)
        //   transform-origin: center right
        // active: rotateY(0deg)  transform-origin: center center
        // past:   rotateY(-90deg) translateZ(halfWidth) translateX(-halfWidth)
        //   transform-origin: center left
        //
        // Matrix4 in Flutter (right-hand rule):
        // offset=+1 (future): rotateY(+90°) translateZ(+halfWidth) translateX(+halfWidth)
        // offset=-1 (past):   rotateY(-90°) translateZ(+halfWidth) translateX(-halfWidth)
        //
        // NOTE: SDK was using offset*-90 (WRONG SIGN) and zShift=-halfWidth (WRONG SIGN)
        final double rotateYRad = (offset * 90.0) * (math.pi / 180.0); // FIXED: positive
        final double xShift = offset * halfWidth; // translateX: ±halfWidth
        final double zShift = offset.abs() > 0.1 ? halfWidth : 0.0; // translateZ: +halfWidth for adjacent, 0 for active

        final Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 1.0 / 1200.0) // perspective: 1200px (matches Dashboard --slide-half-width context)
          ..translate(xShift, 0.0, zShift) // FIXED: zShift is now positive
          ..rotateY(rotateYRad); // FIXED: sign matches Dashboard

        return Positioned.fill(
          key: ValueKey('cube_$i'),
          child: Visibility(
            visible: isVisible,
            maintainState: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: const Cubic(0.2, 0.8, 0.2, 1.0),
              transform: transform,
              transformAlignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: isActive ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !isActive,
                  child: _buildSlideBody(_slides[i], isActive, layoutSize, scaleX, scaleY),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────── SLIDE BODY ────────────────────────────────────

  Widget _buildSlideBody(
    dynamic slide,
    bool isActive,
    Size layoutSize,
    double scaleX,
    double scaleY,
  ) {
    // Dashboard default: slide.style?.backgroundColor || '#FFFFFF'
    final bgColor =
        NinjaLayerUtils.parseColor(slide['style']?['backgroundColor']) ??
            Colors.white;
    final bgUrl = (slide['content']?['url']?.toString() ?? '').trim();
    final objectFit = slide['content']?['objectFit']?.toString() ?? 'cover';
    final isVideoBg = _isVideoUrl(bgUrl);
    final isYouTubeBg = _isYouTubeUrl(bgUrl);
    final autoAdvanceMode =
        slide['content']?['autoAdvanceMode']?.toString() ?? 'fixed';

    return NotificationListener<NinjaVideoStatusNotification>(
      onNotification: (n) {
        if (!isActive) return true;
        // When video starts playing → mark ready, start timer
        if (n.isPlaying && !_isReady) {
          _markReady();
        }
        // BUG E FIX: ONLY advance on video_completion when isPlaying becomes false
        // after having been playing (i.e., ended, not just paused)
        if (!n.isPlaying && autoAdvanceMode == 'video_completion' && _isReady) {
          _nextSlide();
        }
        return true;
      },
      child: Container(
        width: layoutSize.width,
        height: layoutSize.height,
        color: bgColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background Media (z-index 0) ──
            if (bgUrl.isNotEmpty) ...[
              if (isVideoBg)
                Positioned.fill(
                  child: IgnorePointer(
                    child: NinjaVideoLayer(
                      layer: {
                        'content': {
                          'url': bgUrl,
                          'autoPlay': isActive && !_isPaused,
                          'muted': _isMuted,
                          'loop': autoAdvanceMode != 'video_completion',
                        },
                        'style': {
                          'width': '100%',
                          'height': '100%',
                          'objectFit': objectFit
                        },
                      },
                      parentSize: layoutSize,
                      isActive: isActive && !_isPaused,
                    ),
                  ),
                )
              else if (isYouTubeBg)
              // YouTube background — handled as poster image for now
              // (no webview available in Flutter without plugin)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(color: Colors.black),
                  ),
                )
              else
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.network(
                      bgUrl,
                      fit: NinjaLayerUtils.parseBoxFit(objectFit),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
            ],

            // ── Child Layers (z-index 1): render slide's children DIRECTLY ──
            // Dashboard (line 577-580):
            //   <div style={{ pointerEvents:'none', zIndex:1 }}>
            //     {layers.filter(l => l.parent === slide.id).map(l => (
            //       <div key={l.id} style={{ pointerEvents:'auto' }}>{renderLayer(l)}</div>
            //     ))}
            //   </div>
            //
            // In Flutter, hit-testing is NATURAL: a tap on empty space falls through
            // to the parent GestureDetector. A tap on a child widget (button, input)
            // is consumed by that widget. NO IgnorePointer wrapper needed.
            // WARNING: IgnorePointer(ignoring:true) blocks ALL descendants — inner
            // IgnorePointer(ignoring:false) has NO effect once parent ignores.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pw = constraints.maxWidth;
                  final ph = constraints.maxHeight;
                  final slideId = slide['id']?.toString();
                  final childLayers = slideId != null
                      ? _allLayers.where((l) => l['parent'] == slideId).toList()
                      : <dynamic>[];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: childLayers.map<Widget>((child) {
                      return buildFloaterLayerGlobally(
                        child,
                        scaleX,
                        scaleY,
                        _allLayers,
                        _handleAction,
                        parentWidth: pw,
                        parentHeight: ph,
                        isActive: isActive,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── PROGRESS BARS ─────────────────────────────────

  Widget _buildProgressBars(
      Map<String, dynamic> pbCfg, double scaleX, double scaleY) {
    // Dashboard line 600: borderRadius: ((progressBar.height || 3) / 2) * scale
    // = (rawHeight / 2) * scaleX — NOT (rawHeight * scaleY) / 2
    final rawHeight = pbCfg['height'] is num ? (pbCfg['height'] as num).toDouble() : 3.0;
    final double pbHeight = rawHeight * scaleY;
    final double pbRadius = (rawHeight / 2.0) * scaleX; // Dashboard parity
    final double pbGap =
        (pbCfg['gap'] is num ? (pbCfg['gap'] as num).toDouble() : 3.0) * scaleX;
    final double topOffset =
        (pbCfg['topOffset'] is num
                ? (pbCfg['topOffset'] as num).toDouble()
                : 8.0) *
            scaleY;
    // Dashboard defaults: activeColor 'rgba(255,255,255,0.95)', inactiveColor 'rgba(255,255,255,0.35)'
    final Color activeColor =
        NinjaLayerUtils.parseColor(pbCfg['activeColor']) ??
            const Color(0xF2FFFFFF); // 0xF2 ≈ 0.95 alpha
    final Color inactiveColor =
        NinjaLayerUtils.parseColor(pbCfg['inactiveColor']) ??
            Colors.white.withOpacity(0.35);

    // Dashboard line 588: top: (progressBar.topOffset ?? 8) * scaleY, left: 8*scale, right: 8*scale
    // Safe area: the widget is already positioned within a full-screen dialog/overlay.
    // We only add safe-area padding ONCE here via MediaQuery.of(context).padding.top.
    // Do NOT add layoutSize padding again — it would double-offset on notched phones.
    return Positioned(
      top: MediaQuery.of(context).padding.top + topOffset,
      left: 8 * scaleX,
      right: 8 * scaleX,
      child: Row(
        children: List.generate(_slides.length, (i) {
          final isPast = i < _currentSlideIndex;
          final isActive = i == _currentSlideIndex;

          return Expanded(
            child: Container(
              height: pbHeight,
              margin: EdgeInsets.symmetric(horizontal: pbGap / 2),
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(pbRadius), // Dashboard parity
              ),
              clipBehavior: Clip.hardEdge,
              child: isActive
                  ? AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressController.value,
                        child: Container(color: activeColor),
                      ),
                    )
                  : Container(
                      color: isPast ? activeColor : Colors.transparent),
            ),
          );
        }),
      ),
    );
  }

  // ────────────────────────── CONTROL BUTTONS ────────────────────────────────

  // BUG B FIX: Use exact switch-case like Dashboard's resolvePositionValue
  // BUG C FIX: Add backdropFilter blur(4px) to match Dashboard
  // BUG D FIX: Parse cfg.backgroundColor properly
  Widget _buildControlButton({
    required Map<String, dynamic> cfg,
    required Widget icon,
    required VoidCallback onTap,
    required double scaleX,
    required double scaleY,
  }) {
    if (cfg['show'] != true) return const SizedBox.shrink();

    final double size =
        (cfg['size'] is num ? (cfg['size'] as num).toDouble() : 20.0) * scaleX;
    final double pad = 6.0 * scaleX;
    final String pos = cfg['position']?.toString() ?? 'top-right';
    final double offsetX =
        (cfg['offsetX'] is num ? (cfg['offsetX'] as num).toDouble() : 0.0) * scaleX;
    final double offsetY =
        (cfg['offsetY'] is num ? (cfg['offsetY'] as num).toDouble() : 0.0) * scaleX; // scaleX not scaleY!

    // BUG D FIX: Dashboard uses cfg.backgroundColor || 'rgba(0,0,0,0.5)'
    final String bgStr = cfg['backgroundColor']?.toString() ?? '';
    final Color bgColor;
    if (bgStr == '#00000000' || bgStr == 'transparent') {
      bgColor = Colors.transparent;
    } else {
      bgColor = NinjaLayerUtils.parseColor(bgStr) ?? Colors.black.withOpacity(0.5);
    }

    // Dashboard resolvePositionValue (line 91-97):
    // const off = (v: number) => `${v * scale}px`  ← uses ONLY scaleX (=scale) for ALL positions
    // Top/bottom offsets use scaleX too — NOT scaleY.
    // This matches because 'scale' in Dashboard = horizontal scale factor only.
    double? top, bottom, left, right;
    switch (pos) {
      case 'top-left':
        top = MediaQuery.of(context).padding.top + (16.0 + offsetY) * scaleX; // scaleX, not scaleY!
        left = (16.0 + offsetX) * scaleX;
        break;
      case 'bottom-right':
        bottom = (16.0 + offsetY) * scaleX; // scaleX, not scaleY!
        right = (16.0 + offsetX) * scaleX;
        break;
      case 'bottom-left':
        bottom = (16.0 + offsetY) * scaleX; // scaleX, not scaleY!
        left = (16.0 + offsetX) * scaleX;
        break;
      default: // 'top-right'
        top = MediaQuery.of(context).padding.top + (16.0 + offsetY) * scaleX; // scaleX, not scaleY!
        right = (16.0 + offsetX) * scaleX;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          // BUG C FIX: backdropFilter: blur(4px) exactly matches Dashboard
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              width: size + pad * 2,
              height: size + pad * 2,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────── BUILD ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) return Container(color: Colors.black);

    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 393.0;
    final double scaleY = size.height / 852.0;

    final Map<String, dynamic> cfg =
        Map<String, dynamic>.from(_rootContainer?['content'] ?? {});
    final String effect = cfg['transition']?.toString() ?? 'slide';
    final Map<String, dynamic> controls =
        Map<String, dynamic>.from(cfg['controls'] ?? {});

    // Dashboard defaults (line 419-423)
    final Map<String, dynamic> pbCfg = Map<String, dynamic>.from(
        controls['progressBar'] ??
            {
              'show': true,
              'height': 3,
              'gap': 3,
              'activeColor': 'rgba(255,255,255,0.95)',
              'inactiveColor': 'rgba(255,255,255,0.35)',
              'topOffset': 8
            });
    final Map<String, dynamic> closeBtn = Map<String, dynamic>.from(
        controls['closeButton'] ??
            {'show': true, 'position': 'top-right', 'size': 20});
    final Map<String, dynamic> backBtn = Map<String, dynamic>.from(
        controls['backButton'] ??
            {'show': false, 'position': 'top-left', 'size': 20});
    final Map<String, dynamic> muteBtn = Map<String, dynamic>.from(
        controls['muteButton'] ??
            {'show': true, 'position': 'top-right', 'size': 18});
    final Map<String, dynamic> pauseBtn = Map<String, dynamic>.from(
        controls['pauseButton'] ??
            {'show': false, 'position': 'top-right', 'size': 18});

    final activeSlide = _slides[_currentSlideIndex];
    // BUG A FIX: full video detection including child layers and YouTube
    final activeIsVideo = _isSlideVideo(activeSlide);

    Widget transitionWidget;
    switch (effect) {
      case 'fade':
        transitionWidget = _buildFadeEffect(size, scaleX, scaleY);
        break;
      case 'cube':
        transitionWidget = _buildCubeEffect(size, scaleX, scaleY);
        break;
      default:
        transitionWidget = _buildSlideEffect(size, scaleX, scaleY);
    }

    return GestureDetector(
      onTapUp: (d) => _handleTap(d, context),
      onLongPressDown: (_) => _pauseProgress(),
      onLongPressCancel: () => _resumeProgress(),
      onLongPressUp: () => _resumeProgress(),
      onHorizontalDragEnd: (d) {
        final velocity = d.primaryVelocity ?? 0;
        // Dashboard onTouchEnd (line 158-168): swipes call goToNextStory/goToPrevStory DIRECTLY.
        // Only handleTap (onClick) navigates slides first, stories at boundary.
        // distance = touchStart - touchEndX >0 means left swipe → goToNextStory
        // In Flutter: primaryVelocity < 0 means left swipe (same direction)
        if (velocity.abs() < _minSwipeVelocity) return;
        _lastSwipeTimeMs = DateTime.now().millisecondsSinceEpoch;
        if (velocity < 0) {
          // Left swipe → directly next STORY (Dashboard: distance>0 → goToNextStory)
          if (widget.onNextStory != null) {
            widget.onNextStory!.call();
          } else {
            widget.onDismiss?.call();
          }
        } else {
          // Right swipe → directly prev STORY (Dashboard: distance<0 → goToPrevStory)
          widget.onPrevStory?.call();
        }
      },
      // Dashboard line 436: backgroundColor: '#000' — black base prevents transparency
      // gaps from showing through during transitions
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dashboard line 438: overflow:'hidden' — clip slides during AnimatedSlide
            // transitions to prevent bleed outside the container bounds
            ClipRect(child: transitionWidget),

          // 2. Progress bars (z-index 998)
          if (pbCfg['show'] == true)
            _buildProgressBars(pbCfg, scaleX, scaleY),

          // 3. Back button
          // Dashboard: backBtn has NO onClick — click bubbles to outer handleTap.
          // handleTap's left-half path calls _previousSlide() (slide-first, then story).
          // SDK back button must use _previousSlide(), NOT widget.onPrevStory directly.
          // widget.onPrevStory skips slide navigation and jumps to previous story.
          _buildControlButton(
            cfg: backBtn,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: (backBtn['size'] is num
                      ? (backBtn['size'] as num).toDouble()
                      : 20.0) *
                  scaleX,
            ),
            onTap: _previousSlide, // slide-first navigation, matching Dashboard left-tap
            scaleX: scaleX,
            scaleY: scaleY,
          ),

          // 4. Mute button — Dashboard line 631-644:
          // const muteCfg = activeSlide?.content?.controls?.muteButton || {};
          // const showMute = activeSlideIsVideo && (muteCfg.show ?? true);
          // const finalMuteCfg = { ...muteBtn, ...muteCfg, show: true };
          if (activeIsVideo) ...[
            Builder(builder: (ctx) {
              final finalMuteCfg = _getMuteCfg(muteBtn, activeSlide);
              final perSlideMuteCfg = Map<String, dynamic>.from(
                  activeSlide['content']?['controls']?['muteButton'] ?? {});
              final showMute = (perSlideMuteCfg['show'] ?? muteBtn['show'] ?? true) != false;
              if (!showMute) return const SizedBox.shrink();
              return _buildControlButton(
                cfg: finalMuteCfg,
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: const Color(0xFFFFFFFF),
                  size: (finalMuteCfg['size'] is num
                          ? (finalMuteCfg['size'] as num).toDouble()
                          : 18.0) *
                      scaleX,
                ),
                onTap: () => setState(() => _isMuted = !_isMuted),
                scaleX: scaleX,
                scaleY: scaleY,
              );
            }),
          ],

          // 5. Pause button — Dashboard: only renders when pauseBtn.show is true
          // (defaults to false — this is an opt-in overlay, not always shown)
          if (pauseBtn['show'] == true)
            _buildControlButton(
              cfg: pauseBtn,
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: (pauseBtn['size'] is num
                        ? (pauseBtn['size'] as num).toDouble()
                        : 18.0) *
                    scaleX,
              ),
              onTap: _isPaused ? _resumeProgress : _pauseProgress,
              scaleX: scaleX,
              scaleY: scaleY,
            ),

          // 6. Close button (z-index 1000, rendered last = highest on stack)
          _buildControlButton(
            cfg: closeBtn,
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: (closeBtn['size'] is num
                      ? (closeBtn['size'] as num).toDouble()
                      : 20.0) *
                  scaleX,
            ),
            onTap: widget.onDismiss ?? () {},
            scaleX: scaleX,
            scaleY: scaleY,
          ),
        ],
      ), // Stack
    ), // ColoredBox
  ); // GestureDetector
  }

  // Helper to compute mute button config with per-slide override
  // Dashboard line 631-636: const muteCfg = activeSlide?.content?.controls?.muteButton || {}
  // const finalMuteCfg = { ...muteBtn, ...muteCfg, show: true }
  Map<String, dynamic> _getMuteCfg(
    Map<String, dynamic> muteBtn,
    dynamic activeSlide,
  ) {
    final perSlide = Map<String, dynamic>.from(
        activeSlide['content']?['controls']?['muteButton'] ?? {});
    return {...muteBtn, ...perSlide, 'show': true};
  }
}
