import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import 'dart:math' as math;
import 'ninja_layer_utils.dart';
import '../nudge_renderers/Floater_render_v2.dart';
import '../../models/nudge_model.dart';
import '../../utils/ninja_logger.dart';

// --- Notifications ---

class NinjaCarouselLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final Size? scaleSize;
  final double scale;
  final double scaleY;
  final Function(String, Map<String, dynamic>)? onAction;
  final List<dynamic>? allLayers;
  final Widget Function(Map<String, dynamic> layer, {bool isActive})?
      renderChild; // Dashboard Parity: Callback for slide rendering
  final bool isActive;

  const NinjaCarouselLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scaleSize,
    required this.scale,
    required this.scaleY,
    this.onAction,
    this.allLayers,
    this.renderChild, // Dashboard Parity: Optional render callback
    this.isActive = true,
  }) : super(key: key);

  @override
  State<NinjaCarouselLayer> createState() => _NinjaCarouselLayerState();
}

class _NinjaCarouselLayerState extends State<NinjaCarouselLayer>
    with TickerProviderStateMixin {
  // --- Constants ---
  static const int _kInfinitePages = 100000;
  static const int _kMiddlePage = _kInfinitePages ~/ 2;
  static const Duration _kRefTransitionDuration = Duration(milliseconds: 500);
  static const Curve _kRefCurve = Cubic(0.25, 1.0, 0.5,
      1.0); // EXACT match to Dashboard: cubic-bezier(0.25, 1, 0.5, 1)

  // --- State ---
  late PageController _pageController;
  late AnimationController _progressController;
  int _activeIndex = 0;

  bool _isHovered = false;
  bool _isVideoPlaying = false;
  int _prevIndex = 0; // Fix: Track previous index for wrap detection
  Offset? _arrowPointerDownPos; // Fix: Track tap vs drag for arrows

  // --- Getters (Strict Parity Mappings) ---
  Map<String, dynamic> get _config => widget.layer['content'] ?? {};

  bool get _showArrows =>
      _config['showArrows'] ?? _config['show_arrows'] ?? true;
  bool get _showDots => _config['showDots'] ?? true;
  bool get _autoPlay => _config['autoPlay'] ?? true;
  bool get _pauseOnHover => _config['pauseOnHover'] ?? true;
  int get _interval => NinjaLayerUtils.parseInt(_config['interval']) ?? 3000;

  bool get _loop => _config['loop'] ?? _config['shouldLoop'] ?? true;

  // Debug & Effect
  String get _effect => _config['effect'] ?? 'slide';
  bool get _isFade => _effect == 'fade';
  bool get _isCoverflow => _effect == 'coverflow';

  String get _direction => _config['direction'] ?? 'horizontal';
  bool get _isVertical => _direction == 'vertical';

  // Dimensions & Styling
  double get _dotGap =>
      (NinjaLayerUtils.parseDouble(_config['dotGap'] ?? _config['dot_gap']) ??
          6.0) *
      widget.scale;

  // Arrow Config
  String get _arrowType =>
      _config['arrowType'] ?? _config['arrow_type'] ?? 'icon';
  String get _arrowIcon =>
      _config['arrowIcon'] ?? _config['arrow_icon'] ?? 'chevron';
  double get _arrowOffsetX =>
      (NinjaLayerUtils.parseDouble(
              _config['arrowOffsetX'] ?? _config['arrow_offset_x']) ??
          -48.0) *
      widget.scale;
  double get _arrowOffsetY =>
      (NinjaLayerUtils.parseDouble(
              _config['arrowOffsetY'] ?? _config['arrow_offset_y']) ??
          0.0) *
      widget.scale;
  double get _arrowSize =>
      (NinjaLayerUtils.parseDouble(
              _config['arrowSize'] ?? _config['arrow_size']) ??
          32.0) *
      widget.scale;
  Color get _arrowColor =>
      NinjaLayerUtils.parseColor(
          _config['arrowColor'] ?? _config['arrow_color']) ??
      Colors.white;
  Color get _arrowBgColor =>
      NinjaLayerUtils.parseColor(
          _config['arrowBgColor'] ?? _config['arrow_bg_color']) ??
      const Color(0x33000000);
  String? get _arrowImageUrl =>
      _config['arrowImageUrl'] ?? _config['arrow_image_url'];
  // Support arrowBgImage specific key (camel or snake)
  String? get _arrowBgImage =>
      _config['arrowBgImage'] ??
      _config['arrow_bg_image'] ??
      _config['arrowBackgroundImage'] ??
      _config['arrow_background_image'];

  // Dot Config
  double get _dotOffsetY =>
      (NinjaLayerUtils.parseDouble(
              _config['dotOffsetY'] ?? _config['dot_offset_y']) ??
          -24.0) *
      widget.scaleY;
  double get _dotSize =>
      (NinjaLayerUtils.parseDouble(_config['dotSize'] ?? _config['dot_size']) ??
          6.0) *
      widget.scale;
  double get _activeDotSize =>
      (NinjaLayerUtils.parseDouble(
              _config['activeDotSize'] ?? _config['active_dot_size']) ??
          8.0) *
      widget.scale;
  double get _dotRadius =>
      (NinjaLayerUtils.parseDouble(
              _config['dotRadius'] ?? _config['dot_radius']) ??
          999.0) *
      widget.scale;
  Color get _dotColor =>
      NinjaLayerUtils.parseColor(_config['dotColor'] ?? _config['dot_color']) ??
      const Color(0xFFCCCCCC);
  Color get _activeDotColor =>
      NinjaLayerUtils.parseColor(
          _config['activeDotColor'] ?? _config['active_dot_color']) ??
      Colors.black;

  // Thumbnail Config
  bool get _showThumbnails =>
      _config['showThumbnails'] ?? _config['show_thumbnails'] ?? false;
  // CR9 Fix: Scale config value by widget.scale. Fallback re-derives from raw dotOffsetY to avoid double-scaling.
  double get _thumbnailOffset =>
      (NinjaLayerUtils.parseDouble(
              _config['thumbnailOffset'] ?? _config['thumbnail_offset']) ??
          (NinjaLayerUtils.parseDouble(
                  _config['dotOffsetY'] ?? _config['dot_offset_y']) ??
              -24.0)) *
      widget.scale;
  double get _thumbnailGap =>
      (NinjaLayerUtils.parseDouble(
              _config['thumbnailGap'] ?? _config['thumbnail_gap']) ??
          4.0) *
      widget.scale;
  double get _thumbnailHeight =>
      (NinjaLayerUtils.parseDouble(
              _config['thumbnailHeight'] ?? _config['thumbnail_height']) ??
          50.0) *
      widget.scale;

  // Progress Config
  bool get _showProgressBar =>
      _config['showProgressBar'] ?? _config['show_progress_bar'] ?? false;
  String get _progressPosition =>
      _config['progressPosition'] ?? _config['progress_position'] ?? 'bottom';
  double get _progressOffset =>
      (NinjaLayerUtils.parseDouble(
              _config['progressOffset'] ?? _config['progress_offset']) ??
          0.0) *
      widget.scale;
  double get _progressHeight =>
      (NinjaLayerUtils.parseDouble(
              _config['progressHeight'] ?? _config['progress_height']) ??
          4.0) *
      widget.scale;
  double get _progressWidthPct => (NinjaLayerUtils.parseDouble(
          _config['progressWidth'] ?? _config['progress_width']) ??
      100.0);
  Color get _progressColor =>
      NinjaLayerUtils.parseColor(
          _config['progressColor'] ?? _config['progress_color']) ??
      const Color(0xFF6366F1);

  // Slides Source - CRITICAL: Cache this to prevent excessive recomputation
  // This was being called HUNDREDS of times per frame, causing massive lag
  late final List<dynamic> _slides = _computeSlides();

  List<dynamic> _computeSlides() {
    final String myId = widget.layer['id'];
    final List<dynamic> all = widget.allLayers ?? [];
    var slides = all.where((l) => l['parent'] == myId).toList();
    
    // Context Engine: Propagate mappedState downward for data binding
    if (widget.layer.containsKey('mappedState')) {
        slides = slides.map((original) {
            Map<String, dynamic> slideMap = Map<String, dynamic>.from(original);
            slideMap['mappedState'] = widget.layer['mappedState'];
            return slideMap;
        }).toList();
    }
    
    NinjaLog.d('AppNinja', 
        '[NinjaCarouselLayer] _computeSlides: Found ${slides.length} slides for carousel $myId');
    if (slides.isNotEmpty) {
      NinjaLog.d('AppNinja', 
          '[NinjaCarouselLayer] First slide ID: ${slides[0]['id']}, type: ${slides[0]['type']}');
    }
    return slides;
  }

  int get _count => _slides.length;
  // Use Virtual Infinite Loop if looping enabled (Parity Decision: Smoother than cloning)
  bool get _useVirtualLoop => _loop && !_isFade && _count > 1;

  @override
  void initState() {
    super.initState();

    // Page Controller Init
    int initialPage = 0;
    if (_useVirtualLoop) {
      // Center around middle page, strictly aligned to 0 mod count
      int offset = _kMiddlePage % (_count > 0 ? _count : 1);
      initialPage = _kMiddlePage - offset;
    }

    _pageController = PageController(initialPage: initialPage);

    // Progress Controller (Autoplay Timer)
    _progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _interval));

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleAutoplayCycle();
      }
    });

    // Start
    _checkAutoplay();
  }

  @override
  void didUpdateWidget(NinjaCarouselLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check Interval Change
    if (_interval !=
        (NinjaLayerUtils.parseInt(oldWidget.layer['content']?['interval']) ??
            3000)) {
      _progressController.duration = Duration(milliseconds: _interval);
      if (_progressController.isAnimating) {
        _progressController.forward(from: 0);
      }
    }

    // Check Config Changes Triggering State Logic
    final oldAutoPlay = oldWidget.layer['content']?['autoPlay'] ?? true;
    if (oldAutoPlay != _autoPlay) {
      _checkAutoplay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _checkAutoplay() {
    // Logic Parity:
    // if (!autoPlay || count <= 1 || isInteractive) return;
    // if ((pauseOnHover && isHovered) || isVideoPlaying) return;

    bool shouldPlay = _autoPlay && _count > 1;

    if (_pauseOnHover && _isHovered) shouldPlay = false;
    if (_isVideoPlaying) shouldPlay = false;
    // Bug Fix: Stop autoplay in Editor Mode (isInteractive == false)
    if (widget.layer['isInteractive'] == false) shouldPlay = false;

    if (shouldPlay) {
      if (!_progressController.isAnimating) {
        _progressController.forward();
      }
    } else {
      _progressController.stop();
    }
  }

  void _handleAutoplayCycle() {
    if (_isFade || _isCoverflow) {
      int next = _activeIndex + 1;
      if (next >= _count) next = 0;
      setState(() {
        _prevIndex = _activeIndex;
        _activeIndex = next;
      });
      _progressController.forward(from: 0);
    } else {
      // Slide
      _pageController.nextPage(
          duration: _kRefTransitionDuration, curve: _kRefCurve);
      // Progress resets via animation listener restart or explicit set?
      // Actually if we call animateToPage, scroll listener stops progress.
      // We need to ensure it restarts.
      _progressController.forward(from: 0);
    }
  }

  void _nextPage() {
    NinjaLog.d('AppNinja', 
        '[NinjaCarouselLayer] _nextPage called. activeIndex=$_activeIndex, count=$_count, loop=$_loop');
    if (_isFade || _isCoverflow) {
      int next = _activeIndex + 1;
      if (next >= _count) {
        if (_loop)
          next = 0;
        else {
          NinjaLog.d('AppNinja', '[NinjaCarouselLayer] _nextPage: Reached end, no loop');
          return;
        }
      }
      setState(() {
        _prevIndex = _activeIndex;
        _activeIndex = next;
      });
    } else {
      _pageController.nextPage(
          duration: _kRefTransitionDuration, curve: _kRefCurve);
    }
    _progressController.forward(from: 0); // Reset timer
  }

  void _prevPage() {
    NinjaLog.d('AppNinja', 
        '[NinjaCarouselLayer] _prevPage called. activeIndex=$_activeIndex, count=$_count, loop=$_loop');
    if (_isFade || _isCoverflow) {
      int prev = _activeIndex - 1;
      if (prev < 0) {
        if (_loop)
          prev = _count - 1;
        else {
          NinjaLog.d('AppNinja', '[NinjaCarouselLayer] _prevPage: Reached start, no loop');
          return;
        }
      }
      setState(() {
        _prevIndex = _activeIndex;
        _activeIndex = prev;
      });
    } else {
      _pageController.previousPage(
          duration: _kRefTransitionDuration, curve: _kRefCurve);
    }
    _progressController.forward(from: 0);
  }

  void _jumpTo(int index) {
    if (_isFade || _isCoverflow) {
      setState(() {
        _prevIndex = _activeIndex;
        _activeIndex = index;
      });
    } else {
      if (_useVirtualLoop) {
        // Smart Jump logic: Find closest page index matching modulo
        int current =
            _pageController.hasClients ? _pageController.page!.round() : 0;
        int currentMod = current % _count;
        int diff = index - currentMod;
        _pageController.animateToPage(current + diff,
            duration: _kRefTransitionDuration, curve: _kRefCurve);
      } else {
        _pageController.animateToPage(index,
            duration: _kRefTransitionDuration, curve: _kRefCurve);
      }
    }
    _progressController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    NinjaLog.d('AppNinja', 
        'NinjaCarouselLayer: build ID=${widget.layer['id']}, effect=$_effect, count=$_count, parentSize=${widget.parentSize}');
    NinjaLog.d('AppNinja', 
        'NinjaCarouselLayer: showArrows=$_showArrows, showThumbnails=$_showThumbnails');

    if (_count == 0) {
      return Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.withOpacity(0.3), width: 2 * widget.scale),
              borderRadius: BorderRadius.circular(8 * widget.scale)),
          alignment: Alignment.center,
          child: Text('Add Slide +',
              style:
                  TextStyle(color: Colors.grey, fontSize: 10 * widget.scale)));
    }

    // Parse Radius for selective clipping (Slides Only)
    final style = widget.layer['style'] ?? {};
    BorderRadius? radius;
    final rawRadius = style['borderRadius'] ?? style['border_radius'];
    if (rawRadius != null) {
      if (rawRadius is num) {
        radius = BorderRadius.circular(rawRadius.toDouble() * widget.scale);
      } else {
        radius = NinjaLayerUtils.parseBorderRadius(rawRadius, context: context);
        // CR5 Fix: Scale per-corner borderRadius values (same pattern as CT4)
        if (radius != null) {
          radius = BorderRadius.only(
            topLeft: radius.topLeft * widget.scale,
            topRight: radius.topRight * widget.scale,
            bottomLeft: radius.bottomLeft * widget.scale,
            bottomRight: radius.bottomRight * widget.scale,
          );
        }
        if (radius == null && rawRadius is num)
          radius = BorderRadius.circular(rawRadius.toDouble() * widget.scale);
      }
    }

    // FIX (Bug 12): Parse Padding explicitly since FloaterRenderV2 strips it
    EdgeInsets padding =
        NinjaLayerUtils.parsePadding(style['padding'], context) ??
            EdgeInsets.zero;

    return LayoutBuilder(builder: (context, constraints) {
      final effectiveSize = widget.parentSize ??
          Size(constraints.maxWidth, constraints.maxHeight);

      return NotificationListener<Notification>(
          onNotification: (n) {
            if (n is ScrollStartNotification) {
              if (_autoPlay) _progressController.stop();
            } else if (n is ScrollEndNotification) {
              _checkAutoplay();
            } else if (n is NinjaVideoStatusNotification) {
              setState(() => _isVideoPlaying = n.isPlaying);
              _checkAutoplay();
              return true;
            }
            return false;
          },
          child: MouseRegion(
              onEnter: (_) {
                setState(() => _isHovered = true);
                _checkAutoplay();
              },
              onExit: (_) {
                setState(() => _isHovered = false);
                _checkAutoplay();
              },
              child: Container(
                  // FIX (Bug 12): Apply stripped padding to root container
                  padding: padding,
                  decoration:
                      _buildLayerDecoration(radius), // Pass parsed radius
                  clipBehavior:
                      Clip.none, // Allow Arrows/Thumbnails to be OUTSIDE
                  child: Stack(clipBehavior: Clip.none, children: [
                    // 1. Slides Layer - CLIPPED (Except Coverflow which needs overflow)
                    Positioned.fill(
                        child: _isCoverflow
                            ? ClipRRect(
                                // PARITY FIX: Clip coverflow slides to match Dashboard viewport
                                // This prevents slides from extending beyond carousel bounds
                                // Arrows are OUTSIDE this ClipRRect so they remain clickable
                                borderRadius: radius ?? BorderRadius.zero,
                                child: _buildCoverflowStack(effectiveSize))
                            : ClipRRect(
                                borderRadius: radius ?? BorderRadius.zero,
                                child: _isFade
                                    ? _buildFadeStack(effectiveSize)
                                    : _buildPageView(effectiveSize))),

                    // 2. Arrows (Z-Index 20)
                    if (_showArrows) ..._buildArrows(),

                    // 3. Dots (Z-Index 20 - Painted after Arrows)
                    if (_showDots) _buildDots(),

                    // 4. Thumbnails (Z-Index 25 - Painted TOP)
                    if (_showThumbnails) _buildThumbnails(),

                    // 5. Progress Bar (Z-Index 30)
                    if (_showProgressBar) _buildProgressBar(),
                  ]))));
    }); // LayoutBuilder
  }

  BoxDecoration _buildLayerDecoration(BorderRadius? radius) {
    final style = widget.layer['style'] ?? {};

    // Colors
    Color? bgColor = NinjaLayerUtils.parseColor(
        style['backgroundColor'] ?? style['background_color']);
    Color? borderColor = NinjaLayerUtils.parseColor(
        style['borderColor'] ?? style['border_color']);

    // Dimensions
    double borderWidth = (NinjaLayerUtils.parseDouble(
                style['borderWidth'] ?? style['border_width']) ??
            0) *
        widget.scale;

    // Shadow
    List<BoxShadow>? shadows;
    final rawShadow = style['boxShadow'] ??
        style['box_shadow'] ??
        style['dropShadow'] ??
        style['drop_shadow'];
    if (rawShadow != null) {
      if (rawShadow is Map) {
        shadows = [
          BoxShadow(
            color: NinjaLayerUtils.parseColor(rawShadow['color']) ??
                Colors.black.withOpacity(0.2),
            offset: Offset(
                (rawShadow['x'] as num? ?? 0).toDouble() * widget.scale,
                (rawShadow['y'] as num? ?? 0).toDouble() * widget.scale),
            blurRadius:
                (rawShadow['blur'] as num? ?? 0).toDouble() * widget.scale,
            spreadRadius:
                (rawShadow['spread'] as num? ?? 0).toDouble() * widget.scale,
          )
        ];
      }
    }

    return BoxDecoration(
      color: bgColor,
      border: (borderColor != null && borderWidth > 0)
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      borderRadius: radius,
      boxShadow: shadows,
    );
  }

  // --- Renderers ---

  Widget _buildFadeStack(Size parentSize) {
    // React "Fade": Absolute positioning, z-index sort via opacity
    return Stack(
        children: _slides.asMap().entries.map((entry) {
      final idx = entry.key;
      final slide = entry.value;
      final isActive = idx == _activeIndex;
      final isSlideActive = widget.isActive && isActive;

      return AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600), // React: 0.6s
          curve: _kRefCurve,
          child: IgnorePointer(
            ignoring: !isActive, // React: pointerEvents: none if not active
            child: _buildSafeSlide(slide, parentSize, isSlideActive),
          ));
    }).toList());
  }

  Widget _buildPageView(Size parentSize) {
    // Standard Slide Effect (using PageView for physics/drag)
    // If we are Coverflow, we return the new Stack renderer instead.
    if (_isCoverflow) return _buildCoverflowStack(parentSize);

    int? itemCount = _useVirtualLoop ? _kInfinitePages : _count;

    return PageView.builder(
        controller: _pageController,
        scrollDirection: _isVertical ? Axis.vertical : Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        physics: _loop
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics(),
        itemCount: itemCount,
        onPageChanged: (page) {
          final actual = page % _count;
          if (actual != _activeIndex) {
            setState(() => _activeIndex = actual);
          }
        },
        itemBuilder: (context, index) {
          // Standard Slide
          final modIndex = index % _count;
          final isSlideActive = widget.isActive && (modIndex == _activeIndex);
          return _buildSafeSlide(_slides[modIndex], parentSize, isSlideActive);
        });
  }

  Widget _buildCoverflowStack(Size layoutSize) {
    List<Widget> children = [];
    List<Map<String, dynamic>> renderList = [];

    // Use layoutSize for responsive spacing (Fix 2 & 3)

    for (int i = 0; i < _count; i++) {
      double offset = (i - _activeIndex).toDouble();

      // Loop Logic
      if (_count > 1) {
        if (offset > _count / 2)
          offset -= _count;
        else if (offset < -_count / 2) offset += _count;
      }

      double absOffset = offset.abs();
      double zIndex = 100 - absOffset;

      renderList.add({
        'index': i, // Added index for stable sort (Bug 8 Fix)
        'offset': offset,
        'zIndex': zIndex,
        'slide': _slides[i]
      });
    }

    // Sort: Lowest Z-Index first (Painter's Algorithm)
    // Stable Sort: If Z is equal, use Index (DOM order parity)
    renderList.sort((a, b) {
      int zCmp = (a['zIndex'] as double).compareTo(b['zIndex'] as double);
      if (zCmp != 0) return zCmp;
      return (a['index'] as int).compareTo(b['index'] as int);
    });

    // PARITY FIX: Wrap in ClipRect viewport to match Dashboard's overflow structure
    // Dashboard has: outer (overflow: visible) + inner viewport (overflow: hidden)
    // This ensures coverflow slides stay within carousel bounds
    return ClipRect(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0)
            _prevPage();
          else if (details.primaryVelocity! < 0) _nextPage();
        },
        // UPDATED: Use translucent to capture swipe gestures
        // Arrows are in separate Stack layer AFTER this, so they'll still work
        behavior: HitTestBehavior.translucent,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior:
              Clip.none, // Stack itself doesn't clip (ClipRect above does)
          children: renderList.map((item) {
            final double offset = item['offset'];
            final slide = item['slide'];
            final bool isActive = offset.abs() < 0.5;

            // Match TSX 60% spacing relative to CONTAINER WIDTH
            // (offset * 0.6) = percentage of width shift
            final double xShift = offset * (layoutSize.width * 0.6);

            final double rotateYRad = (offset * -35) * (math.pi / 180.0);
            // CRITICAL FIX: Dashboard uses fixed 150px Z-depth (no scaling)
            // Scaling Z breaks perspective and makes animation look different
            final double zShift = -offset.abs() *
                (150 * widget.scale); // Fix: Scale Z-depth by widget.scale

            // Matrix Math (Translate then Rotate)
            final Matrix4 transform = Matrix4.identity()
              ..setEntry(
                  3, 2, 1.0 / (1000.0 * widget.scale)) // Fix: Scale perspective
              ..translate(xShift, 0.0, zShift)
              ..rotateY(rotateYRad);

            final double opacity = (1 - (offset.abs() * 0.25)).clamp(0.0, 1.0);

            // FIX: Spin-Back Glitch
            // Calculate Old Offset to detect "Wrap" (e.g. -1 -> 2)
            double oldOffset = (item['index'] - _prevIndex).toDouble();
            if (_count > 1) {
              if (oldOffset > _count / 2)
                oldOffset -= _count;
              else if (oldOffset < -_count / 2) oldOffset += _count;
            }
            // If the visual position changed drastically (> 1.5 units), it's a wrap.
            // We disable animation to "Snap" instead of flying across.
            double offsetDelta = (oldOffset - offset).abs();
            bool isWrap = offsetDelta > 1.5;

            return Positioned.fill(
              // Use Positioned.fill to constrain slide to container
              child: IgnorePointer(
                ignoring: !isActive, // Only active slide is clickable
                // PERFORMANCE FIX: RepaintBoundary isolates slide repaints
                // Matches Dashboard's "willChange: 'transform, opacity'"
                child: RepaintBoundary(
                  child: AnimatedContainer(
                    duration: isWrap
                        ? Duration.zero
                        : const Duration(milliseconds: 600),
                    curve: _kRefCurve, // Parity Curve (Bug 5 Fix)
                    transform: transform,
                    transformAlignment: Alignment.center,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      curve: _kRefCurve, // Parity Curve
                      opacity: opacity,
                      child: _buildSafeSlide(slide, layoutSize, widget.isActive && isActive), // Render Slide
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSafeSlide(dynamic slideLayer, Size parentSize, bool isActive) {
    // React: "renderSafe" - forces 100% width/height, 0 padding unless user overrides
    final raw = slideLayer is Layer ? slideLayer.raw : slideLayer;
    final config = Map<String, dynamic>.from(raw);
    NinjaLog.d('AppNinja', 
        '[NinjaCarouselLayer] _buildSafeSlide: Rendering slide ${config['id']}, type=${config['type']}');

    Map<String, dynamic> style =
        Map<String, dynamic>.from(config['style'] ?? {});

    // Dashboard Parity: Force slide fill behavior (renderSafe pattern)
    // Dashboard: width: slide.style?.width ?? '100%'
    // Dashboard: height: slide.style?.height ?? '100%'
    // Dashboard: padding: '0px' (forced)
    style['width'] = style['width'] ?? '100%';
    style['height'] = style['height'] ?? '100%';
    style['padding'] = '0px'; // Force zero padding like Dashboard
    style['margin'] = style['margin'] ?? '0px'; // Default margin to zero
    // FIX (Bug 10 & 11): Force relative position to preventing FloaterRenderV2 from treating it as absolute
    // This avoids double positioning and skips the fragile parentId check
    style['position'] = 'relative';

    // FIX (Bug 15): Parity for manual slide positioning
    // 1. Parse offsets (Parity: TSX respects these for Standard, ignores for 3D)
    double offsetX = 0;
    double offsetY = 0;

    if (!_isFade && !_isCoverflow) {
      // Standard Mode: Parse and apply offsets
      // We resolve percentages relative to parentSize
      offsetX += NinjaLayerUtils.parseResponsiveSize(style['left'], context,
              isVertical: false, parentSize: parentSize) ??
          0;
      offsetX -= NinjaLayerUtils.parseResponsiveSize(style['right'], context,
              isVertical: false, parentSize: parentSize) ??
          0;
      offsetY += NinjaLayerUtils.parseResponsiveSize(style['top'], context,
              isVertical: true, parentSize: parentSize) ??
          0;
      offsetY -= NinjaLayerUtils.parseResponsiveSize(style['bottom'], context,
              isVertical: true, parentSize: parentSize) ??
          0;
    } else {
      // 3D/Fade Mode: Force offsets to 0 (Parity with TSX hardcoded 0,0)
      style['left'] = '0px';
      style['top'] = '0px';
      style['right'] = '0px';
      style['bottom'] = '0px';
    }

    config['style'] = style;

    // Parse Margins/Offsets
    // Fix: Remove manual margin calculation to prevent double margins (handled by renderChild)
    // Margins are implicitly 0 here for the wrapper, effectively removed.

    // Also apply padding to wrapper to simulate "Gap" if NOT fade/3d
    EdgeInsets gapPadding = EdgeInsets.zero;
    if (!_isFade && !_isCoverflow) {
      // CR10 Fix: TSX uses dotGap||0 for vertical, dotGap||6 for horizontal
      if (_isVertical) {
        final vertGap = (NinjaLayerUtils.parseDouble(
                    _config['dotGap'] ?? _config['dot_gap']) ??
                0.0) *
            widget.scale;
        gapPadding = EdgeInsets.symmetric(vertical: vertGap / 2);
      } else {
        gapPadding = EdgeInsets.symmetric(horizontal: _dotGap / 2);
      }
    }

    // CRITICAL FIX: Build the child content
    Widget childContent = widget.renderChild != null
        ? widget.renderChild!(config, isActive: isActive)
        : buildFloaterLayerGlobally(
            config,
            widget.scale,
            widget.scaleY,
            widget.allLayers ?? [],
            (a, d) {
              if (widget.onAction != null) widget.onAction!(a, d ?? {});
            },
            parentWidth: parentSize.width,
            parentHeight: parentSize.height,
            isActive: isActive,
          );

    // FIX (Bug 15): Apply Transform for Standard Mode offsets
    if (offsetX != 0 || offsetY != 0) {
      childContent = Transform.translate(
        offset: Offset(offsetX * widget.scale, offsetY * widget.scale),
        child: childContent,
      );
    }

    // Fix: Remove Padding wrapper since margins are now 0
    return Container(
      width: parentSize.width,
      height: parentSize.height,
      padding: gapPadding,
      child: childContent,
    );
  }

  // --- Accessories ---

  List<Widget> _buildArrows() {
    if (!_showArrows || _count <= 1) return [];

    bool canPrev = _loop || _activeIndex > 0;
    bool canNext = _loop || _activeIndex < _count - 1;
    NinjaLog.d('AppNinja', 
        '[NinjaCarouselLayer] _buildArrows: active=$_activeIndex, count=$_count, loop=$_loop, canPrev=$canPrev, canNext=$canNext');

    // Helper to build single arrow matching Dashboard's exact positioning
    Widget buildArrow(
        {required bool isLeft,
        required VoidCallback onTap,
        required bool canNavigate}) {
      // Dashboard CSS (line 264-268):
      // top: calc(50% + offsetY)
      // [left/right]: 0
      // transform: translate(calc(offsetX +/- 50%), -50%)

      // Convert Dashboard's formula to Flutter:
      // 1. Position at left=0 or right=0
      // 2. Use Align with alignment based on side
      // 3. Transform.translate to apply offsetX and arrow centering

      final double xTranslate = isLeft
          ? _arrowOffsetX - (_arrowSize / 2) // offsetX - 50% of arrow width
          : -_arrowOffsetX + (_arrowSize / 2); // -offsetX + 50% of arrow width

      final double yTranslate =
          _arrowOffsetY; // Already accounts for 50% in _arrowOffsetY default

      return Positioned(
        left: isLeft ? 0 : null,
        right: isLeft ? null : 0,
        top: 0,
        bottom: 0,
        child: Align(
          alignment: Alignment.centerLeft, // Align to edge first
          child: Transform.translate(
            offset: Offset(xTranslate, yTranslate),
            child: IgnorePointer(
              ignoring: !canNavigate,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: canNavigate
                    ? 1.0
                    : 0.0, // CR7 Revert: TSX uses opacity 0 at boundary (L272)
                child: Listener(
                  onPointerDown: (e) {
                    _arrowPointerDownPos = e.position;
                  },
                  onPointerUp: (e) {
                    if (_arrowPointerDownPos != null) {
                      final dist =
                          (e.position - _arrowPointerDownPos!).distance;
                      // Allow sloppy taps (up to 20 logical pixels movement)
                      if (dist < 20) {
                        onTap();
                      }
                    }
                  },
                  child: GestureDetector(
                    // Fix: Aggressively capture ALL drags using Pan
                    // This prevents the parent Floater from stealing the gesture
                    // We don't use onTap here because Pan cancels it for sloppy taps.
                    // We handle tap manually in Listener above.
                    onPanStart: (_) {},
                    onPanUpdate: (_) {},
                    behavior: HitTestBehavior.opaque,
                    child: _buildArrowWidget(isLeft),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      buildArrow(
        isLeft: true,
        onTap: _prevPage,
        canNavigate: canPrev,
      ),
      buildArrow(
        isLeft: false,
        onTap: _nextPage,
        canNavigate: canNext,
      ),
    ];
  }

  // Extracted arrow widget builder for clarity
  Widget _buildArrowWidget(bool isLeft) {
    final iconUrl = _cleanUrl(_arrowImageUrl);
    final bool isImage = _arrowType == 'image';
    final bool showBlur = !isImage && _arrowBgColor != Colors.transparent;

    // Build the inner content (icon or image)
    Widget innerContent = (isImage && iconUrl != null)
        ? Transform.rotate(
            angle: isLeft ? math.pi : 0,
            child: Image.network(
              iconUrl,
              height: _arrowSize,
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) => Icon(Icons.error_outline,
                  size: _arrowSize, color: Colors.red),
            ))
        : Icon(_getIconData(isLeft),
            color: _arrowColor, size: _arrowSize * 0.5625);

    // Build the complete arrow widget with proper BackdropFilter structure
    Widget arrowWidget;

    if (showBlur) {
      arrowWidget = SizedBox(
        width: _arrowSize,
        height: _arrowSize,
        child: ClipOval(
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(
                sigmaX: 4 * widget.scale, sigmaY: 4 * widget.scale),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _arrowBgColor,
              ),
              alignment: Alignment.center,
              child: innerContent,
            ),
          ),
        ),
      );
    } else {
      arrowWidget = SizedBox(
        width: _arrowSize,
        height: _arrowSize,
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isImage ? Colors.transparent : _arrowBgColor,
            ),
            alignment: Alignment.center,
            child: innerContent,
          ),
        ),
      );
    }

    return arrowWidget;
  }

  // Helper for URL cleaning
  String? _cleanUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    var clean = url.trim();
    if (clean.startsWith('url(')) clean = clean.substring(4);
    if (clean.endsWith(')')) clean = clean.substring(0, clean.length - 1);
    clean = clean.replaceAll('"', '').replaceAll("'", '');
    return clean.isEmpty ? null : clean;
  }

  // Old arrow rendering method - kept for compatibility but not used anymore
  Widget _renderArrowBtn(bool isLeft, VoidCallback onTap) {
    // Transform math from React:
    // top: calc(50% + offsetY)
    // transform: translate(calc(offsetX +/- 50%), -50%)

    double xOff = isLeft ? _arrowOffsetX : -_arrowOffsetX;
    final iconUrl = _cleanUrl(_arrowImageUrl);
    final bool isImage = _arrowType == 'image'; // Helper check

    // FIX: Only apply blur if it is NOT an image AND background is not transparent
    // TSX Line 247: backdropFilter: (type === 'icon' && bgColor !== 'transparent') ? ... : 'none'
    final bool showBlur = !isImage && _arrowBgColor != Colors.transparent;

    // Build the inner content (icon or image)
    Widget innerContent = (isImage && iconUrl != null)
        ? Transform.rotate(
            angle: isLeft ? math.pi : 0,
            child: Image.network(
              iconUrl,
              height: _arrowSize,
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) => Icon(Icons.error_outline,
                  size: _arrowSize, color: Colors.red),
            ))
        : Icon(_getIconData(isLeft),
            color: _arrowColor, size: _arrowSize * 0.5625);

    // Build the complete arrow widget with proper BackdropFilter structure
    Widget arrowWidget;

    if (showBlur) {
      // When blur is needed: ClipOval > BackdropFilter > Container > Content
      arrowWidget = SizedBox(
        width: _arrowSize,
        height: _arrowSize,
        child: ClipOval(
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(
                sigmaX: 4 * widget.scale, sigmaY: 4 * widget.scale),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _arrowBgColor,
              ),
              alignment: Alignment.center,
              child: innerContent,
            ),
          ),
        ),
      );
    } else {
      // No blur: Just Container with content
      // For image arrows, we still need a fixed size for ClipOval to work properly
      arrowWidget = SizedBox(
        width: _arrowSize,
        height: _arrowSize,
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isImage ? Colors.transparent : _arrowBgColor,
            ),
            alignment: Alignment.center,
            child: innerContent,
          ),
        ),
      );
    }

    return Transform.translate(
        offset: Offset(
            xOff + (isLeft ? -_arrowSize / 2 : _arrowSize / 2), _arrowOffsetY),
        child: GestureDetector(onTap: onTap, child: arrowWidget));
  }

  IconData _getIconData(bool isLeft) {
    switch (_arrowIcon) {
      case 'arrow':
        return isLeft ? Icons.arrow_back : Icons.arrow_forward;
      case 'triangle':
        return Icons
            .play_arrow; // React uses CSS border, play_arrow is close enough
      case 'chevron':
      default:
        return isLeft ? Icons.chevron_left : Icons.chevron_right;
    }
  }

  // Updated buildDots to match React (Always Bottom)
  Widget _buildDots() {
    // React logic ignores direction for dots. Always Bottom, Center.

    return Positioned(
        bottom: _dotOffsetY,
        left: 0,
        right: 0,
        child: Center(
            child: SingleChildScrollView(
                // Safety
                scrollDirection: Axis.horizontal,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_count, (i) {
                      bool active = i == _activeIndex;
                      return GestureDetector(
                          onTap: () => _jumpTo(i),
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves
                                  .easeInOut, // CR12 Fix: Match TSX cubic-bezier(0.4, 0, 0.2, 1)
                              margin: EdgeInsets.symmetric(
                                  horizontal: _dotGap /
                                      2), // CR1 Fix: Match CSS gap (horizontal only)
                              width: active ? _activeDotSize : _dotSize,
                              height: active ? _activeDotSize : _dotSize,
                              decoration: BoxDecoration(
                                  color: active ? _activeDotColor : _dotColor,
                                  borderRadius:
                                      BorderRadius.circular(_dotRadius))));
                    })))));
  }

  Widget _buildThumbnails() {
    // React: bottom: thumbnailOffset, left 50%, translate -50%
    // Padding 4px, BackdropBlur

    return Positioned(
        bottom: _thumbnailOffset,
        left: 0,
        right: 0,
        child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * widget.scale),
                child: BackdropFilter(
                    filter: dart_ui.ImageFilter.blur(
                        sigmaX: 4 * widget.scale, sigmaY: 4 * widget.scale),
                    child: Container(
                        padding: EdgeInsets.all(4 * widget.scale),
                        color: Colors.black.withOpacity(0.3),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(_count, (i) {
                                  final slide = _slides[i];
                                  final raw =
                                      slide is Layer ? slide.raw : slide;
                                  final style = raw['style'] ?? {};
                                  String? bg = style['backgroundImage'] ??
                                      style['background_image'];
                                  // Fix: Use robust cleaner
                                  String? src = _cleanUrl(bg);
                                  bool active = i == _activeIndex;

                                  // CR2 Fix: Inactive thumbnails get 0.7 opacity (TSX parity)
                                  Widget thumb = GestureDetector(
                                      onTap: () => _jumpTo(i),
                                      child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: _thumbnailGap / 2),
                                          height: _thumbnailHeight,
                                          width: _thumbnailHeight * (16 / 9),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  4 * widget.scale),
                                              border: Border.all(
                                                  color: active
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.3),
                                                  width: (active ? 2 : 1) *
                                                      widget.scale),
                                              color: const Color(0xFF333333),
                                              image: src != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(src),
                                                      fit: BoxFit.cover)
                                                  : null),
                                          alignment: Alignment.center,
                                          child: src == null
                                              ? Text('${i + 1}', style: TextStyle(color: Colors.white, fontSize: 8 * widget.scale))
                                              : null));
                                  return active
                                      ? thumb
                                      : Opacity(opacity: 0.7, child: thumb);
                                }))))))));
  }

  Widget _buildProgressBar() {
    // React: absolute, width: progressWidth%, height: progressHeight
    // Animation: scaleX(0->1) linear

    return Positioned(
        bottom: _progressPosition == 'bottom' ? _progressOffset : null,
        top: _progressPosition == 'top' ? _progressOffset : null,
        left: 0,
        right: 0,
        child: Center(
            child: FractionallySizedBox(
                widthFactor: _progressWidthPct / 100,
                child: SizedBox(
                    height: _progressHeight,
                    child: Stack(children: [
                      // Background
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(_progressHeight))),
                      // Progress
                      AnimatedBuilder(
                          animation: _progressController,
                          builder: (ctx, ch) {
                            return FractionallySizedBox(
                                widthFactor: _progressController.value,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: _progressColor,
                                        borderRadius: BorderRadius.circular(
                                            _progressHeight))));
                          })
                    ])))));
  }
}
