import 'package:flutter/material.dart';
import 'package:in_app_ninja/src/models/nudge_model.dart';
import 'dart:ui' as ui;
import '../layers/ninja_layer_utils.dart';
import 'Floater_render_v2.dart';
import '../../utils/ninja_logger.dart';

/// BottomSheet Nudge Renderer - Thin wrapper around FloaterRenderV2
///
/// Uses FloaterRenderV2 as the core renderer with these overrides:
/// - Position: Always bottom-center (no drag positioning)
/// - Draggable: Disabled → Replaced with swipe-to-dismiss
/// - Expanded: Disabled (no expand feature)
/// - Border Radius: Bottom corners forced to 0
class BottomSheetNudgeRenderer extends StatefulWidget {
  final List<Layer> layers;
  final String? selectedLayerId;
  final Function(String?)? onLayerSelect;
  final NudgeConfig config;
  final Function()? onDismiss;
  final Function(String screenName)? onNavigate;
  final Function(String interfaceId)? onInterfaceAction;
  final Function(String, Map<String, dynamic>?)? onAction;
  final Function()? onImpression;
  final double? scale;
  final double? scaleY;

  const BottomSheetNudgeRenderer({
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
  }) : super(key: key);

  @override
  _BottomSheetNudgeRendererState createState() =>
      _BottomSheetNudgeRendererState();
}

class _BottomSheetNudgeRendererState extends State<BottomSheetNudgeRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  double _dragOffset = 0;

  bool _isTop = false;

  @override
  void initState() {
    super.initState();

    // Determine Position Logic
    final raw = widget.config.raw;
    // Legacy support: If type is banner, default to top.
    final type = raw['presentation']?['type'] ?? 'bottom_sheet';
    final posStr = widget.config.position ??
        (type.toString().contains('banner') ? 'top-center' : 'bottom-center');
    _isTop = posStr.contains('top');

    final animConfig = widget.config.animation;
    final durationMs = animConfig?.duration ?? 300;
    final easingStr = animConfig?.easing ?? 'ease-out';
    final Curve curve = _resolveCurve(easingStr);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    // 1. Slide Animation (Direction depends on position)
    _slideAnimation = Tween<Offset>(
      begin: _isTop ? const Offset(0, -1) : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    // 2. Fade Animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );

    // 3. Scale Animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );

    _controller.forward();

    // Track impression
    // Fix: Removed duplicate tracking here. FloaterRenderV2 tracks it.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Curve _resolveCurve(String? easing) {
    if (easing == null) return Curves.easeOutCubic;
    switch (easing.toLowerCase().replaceAll(' ', '-')) {
      case 'linear':
        return Curves.linear;
      case 'ease-in':
        return Curves.easeIn;
      case 'ease-out':
        return Curves.easeOut; // Standard
      case 'ease-in-out':
        return Curves.easeInOut;
      case 'bounce':
        return Curves.bounceOut;
      case 'elastic':
        return Curves.elasticOut;
      case 'slow-middle':
        return Curves.slowMiddle;
      default:
        return Curves.easeOutCubic; // Smooth default
    }
  }

  /// Strips background images from the root layer so that only the wrapper renders it.
  /// Also injects safe area padding directly into the flow layout so absolute elements
  /// don't suffer from height-shrink misalignment.
  List<Layer> _getSanitizedLayers(double safeAreaBottom) {
    final rootLayer = widget.layers.firstWhere(
      (l) => l.type == 'container' && (l.name == 'Floater Container' || l.name == 'FloaterContainer' || l.name == 'Bottom Sheet'),
      orElse: () => widget.layers.isNotEmpty ? widget.layers.first : Layer.fromJson({}),
    );

    return widget.layers.map((layer) {
      if (layer.id == rootLayer.id) {
        final newRaw = Map<String, dynamic>.from(layer.raw);
        if (newRaw['style'] != null) {
          final newStyle = Map<String, dynamic>.from(newRaw['style']);
          newStyle.remove('backgroundImage');
          newStyle.remove('backgroundColor'); // FIX: Ensure inner floater is completely transparent
          
          // Inject Safe Area Padding to protect flow content without shrinking the absolute positioning box
          if (safeAreaBottom > 0) {
             // Fallback to reading standard padding
             final currentPadding = double.tryParse(newStyle['paddingBottom']?.toString().replaceAll('px', '') ?? 
                                    newStyle['padding']?.toString().replaceAll('px', '') ?? '0') ?? 0.0;
             newStyle['paddingBottom'] = currentPadding + safeAreaBottom;
          }
          
          newRaw['style'] = newStyle;
        }
        return Layer.fromJson(newRaw);
      }
      return layer;
    }).toList();
  }

  /// Create modified config for BottomSheet
  /// Overrides Floater-specific properties and adds required defaults
  NudgeConfig _createBottomSheetConfig() {
    final raw = Map<String, dynamic>.from(widget.config.raw);
    NinjaLog.d('AppNinja', '📝 BottomSheet Config IN: $raw');

    // Force BottomSheet-specific values (internal inner config)
    // We treat the inner floater as a simple container
    raw['position'] = _isTop ? 'top-center' : 'bottom-center';
    raw['offsetX'] = 0;
    raw['offsetY'] = 0;
    raw['draggable'] = false;
    raw['expanded'] = false;

    // Default width to 100% for BottomSheet
    raw['width'] = raw['width'] ?? '100%';

    // FIX: FloaterRenderV2 might not support per-corner radius easily if it uses a single value.
    // We set it to 0 here and apply the real radius to our wrapper container in build().
    raw['borderRadius'] = 0;
    raw['backgroundColor'] = 'transparent'; // Move to wrapper
    raw['borderWidth'] = 0; // Move to wrapper

    // Disable Inner Shadows & Overlays (handled by wrapper)
    raw['shadow'] = {'enabled': false};
    raw['overlay'] = {'enabled': false};

    // Disable inner behaviors explicitly
    raw['behavior'] = {
      ...((raw['behavior'] as Map?) ?? {}),
      'draggable': false,
      'snapToCorner': false,
      'doubleTapToDismiss': false,
    };

    // Disable inner controls where necessary, especially expand/mute
    // AND map legacy root 'showCloseButton' to internal control logic (Match React)
    raw['controls'] = {
      ...((raw['controls'] as Map?) ?? {}),
      'closeButton': {
        'show': (raw['controls'] as Map?)?['closeButton']?['show'] ??
            raw['showCloseButton'] ??
            false,
        'position': 'top-right',
        'size': 14
      },
      'expandButton': {'show': false},
      'muteButton': {'show': false},
      'progressBar': {'show': false},
    };

    // Disable internal entrance animations since the bottom sheet wrapper animates the entrance
    raw['animation'] = {'type': 'none'};

    // Ensure media exists (empty default)
    raw['media'] = raw['media'] ?? {'url': '', 'type': 'none'};

    final finalConfig = NudgeConfig.fromJson(raw);
    NinjaLog.d('AppNinja', '📝 BottomSheet Config OUT: ${finalConfig.raw}');
    return finalConfig;
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  // Swipe-to-dismiss handlers
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Top: Swipe Up (delta < 0) to dismiss.
    // Bottom: Swipe Down (delta > 0) to dismiss.

    if (_isTop) {
      if (details.primaryDelta! < 0 || _dragOffset < 0) {
        setState(() {
          _dragOffset += details.primaryDelta!;
          // Clamp to only allow upward movement (negative)
          _dragOffset = _dragOffset.clamp(double.negativeInfinity, 0.0);
        });
      }
    } else {
      if (details.primaryDelta! > 0 || _dragOffset > 0) {
        setState(() {
          _dragOffset += details.primaryDelta!;
          // Clamp to only allow downward movement (positive)
          _dragOffset = _dragOffset.clamp(0.0, double.infinity);
        });
      }
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final screenHeight = MediaQuery.of(context).size.height;

    // Logic: Dismiss if dragged more than 20% or fast swipe
    bool shouldDismiss = false;

    if (_isTop) {
      // Dragged up (-20%) or Fast swipe up (-500)
      if (_dragOffset < -screenHeight * 0.2 || velocity < -500) {
        shouldDismiss = true;
      }
    } else {
      // Dragged down (+20%) or Fast swipe down (+500)
      if (_dragOffset > screenHeight * 0.2 || velocity > 500) {
        shouldDismiss = true;
      }
    }

    if (shouldDismiss) {
      _handleDismiss();
    } else {
      // Snap back
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  Widget _buildEntranceTransition(Widget child) {
    final type = widget.config.animation?.type?.toLowerCase() ?? 'slide';

    // Combine with Fade for smoothness if not strictly Fade
    Widget current = child;

    if (type.contains('slide')) {
      // Default Bottom Sheet Entrance - uses _slideAnimation which is directional
      current = SlideTransition(position: _slideAnimation, child: current);
    } else if (type.contains('scale') || type.contains('zoom')) {
      current = ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(opacity: _fadeAnimation, child: current));
    } else if (type.contains('fade')) {
      current = FadeTransition(opacity: _fadeAnimation, child: current);
    } else {
      // Fallback default
      current = SlideTransition(position: _slideAnimation, child: current);
    }

    return current;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve all styles and config
    final style = _resolveStyle(context);
    final overlay = widget.config.overlay;

    return Stack(
      children: [
        // Backdrop
        if (overlay?['enabled'] == true)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (overlay?['dismissOnClick'] ?? true) _handleDismiss();
            },
            child: FadeTransition(
              opacity: _fadeAnimation, // Backdrop always fades
              child: Container(
                color: NinjaLayerUtils.parseColor(overlay?['color'])
                        ?.withValues(
                            alpha: (overlay?['opacity'] as num?)?.toDouble() ??
                                0.5) ??
                    Colors.black54,
                child: (overlay?['blur'] as num? ?? 0) > 0
                    ? BackdropFilter(
                        filter: ui.ImageFilter.blur(
                            sigmaX: (overlay!['blur'] as num).toDouble() *
                                (widget.scale ?? 1.0),
                            sigmaY: (overlay['blur'] as num).toDouble() *
                                (widget.scale ?? 1.0)),
                        child: Container(color: Colors.transparent),
                      )
                    : null,
              ),
            ),
          ),

        // Content
        Align(
          alignment: style.alignment,
          child: _buildEntranceTransition(
            // Drag Offset Translation + Keyboard Translation (Avoid Compression)
            Transform.translate(
              // Fix: Translate up if keyboard is open to prevent content compression
              offset: Offset(
                  0,
                  _dragOffset -
                      ((!_isTop &&
                              style.viewInsetsBottom > style.viewPaddingBottom)
                          ? style.viewInsetsBottom
                          : 0)),
              child: GestureDetector(
                onVerticalDragUpdate:
                    (style.swipeToDismiss && !style.isScrollable)
                        ? _onVerticalDragUpdate
                        : null,
                onVerticalDragEnd: (style.swipeToDismiss && !style.isScrollable)
                    ? _onVerticalDragEnd
                    : null,
                child: Stack(
                  children: [
                    // Main Content Container
                    Builder(
                      builder: (context) {
                        NinjaLog.d('AppNinja', '🐛 [DEBUG_BOTTOMSHEET] screenHeight: ${MediaQuery.of(context).size.height}');
                        NinjaLog.d('AppNinja', '🐛 [DEBUG_BOTTOMSHEET] style.height: ${style.height}');
                        return Container(
                          width: double.infinity,
                          height: style.height,
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height),
                      decoration: style.boxDecoration,
                      clipBehavior: style.clipBehavior,
                      // ✅ EXACT PARITY DOM STRUCTURE (React Dashboard Matching)
                      child: Stack(
                        alignment: _isTop
                            ? Alignment.bottomCenter
                            : Alignment.topCenter,
                        children: [
                          // Content Wrapper (Full height to align absolute positioning with background)
                          FloaterRenderV2(
                            // FIX: Pass sanitized layers with injected safe area padding
                            layers: _getSanitizedLayers(style.safeAreaPadding.bottom),
                            selectedLayerId: widget.selectedLayerId,
                            onLayerSelect: widget.onLayerSelect,
                            config: style.innerConfig,
                            onDismiss: _handleDismiss,
                            onNavigate: widget.onNavigate,
                            onInterfaceAction: widget.onInterfaceAction,
                            onAction: widget.onAction,
                            onImpression: widget.onImpression, // FIX: Pass down impression tracking
                            scale: widget.scale,
                            scaleY: widget.scaleY,
                          ),
                          // Drag Handle Position (Absolute positioning ignores padding)
                          if (style.hasDragHandle ||
                              (style.isScrollable && style.swipeToDismiss))
                            Positioned(
                              top: _isTop ? null : 8.0 * (widget.scale ?? 1.0),
                              bottom:
                                  _isTop ? 8.0 * (widget.scale ?? 1.0) : null,
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onVerticalDragUpdate: style.swipeToDismiss
                                    ? _onVerticalDragUpdate
                                    : null,
                                onVerticalDragEnd: style.swipeToDismiss
                                    ? _onVerticalDragEnd
                                    : null,
                                behavior: HitTestBehavior.translucent,
                                child: Center(
                                  child: Container(
                                    width: 40 * (widget.scale ?? 1.0),
                                    height: 4 * (widget.scale ?? 1.0),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          2 * (widget.scale ?? 1.0)),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _BottomSheetStyle _resolveStyle(BuildContext context) {
    final raw = widget.config.raw;
    final scaleX = widget.scale ?? 1.0;
    final scaleY = widget.scaleY ?? 1.0;

    // Size & Padding
    final screenHeight = MediaQuery.of(context).size.height;
    final viewPaddingTop = MediaQuery.of(context).viewPadding.top; // Status Bar
    final viewPaddingBottom =
        MediaQuery.of(context).viewPadding.bottom; // Home Indicator
    final viewInsetsBottom =
        MediaQuery.of(context).viewInsets.bottom; // Keyboard

    final configHeight = raw['height'];
    // Parity Fix: Check sizeUnit
    final sizeUnit = widget.config.sizeUnit;
    final isPercentage =
        (configHeight is String && configHeight.endsWith('%')) ||
            (sizeUnit == '%');

    final percentageValue = isPercentage
        ? (double.tryParse(configHeight.toString().replaceAll('%', '')) ??
                100.0) /
            100.0
        : 1.0;

    double? fixedHeight;
    if (!isPercentage &&
        configHeight != null &&
        configHeight.toString().toLowerCase() != 'auto') {
      if (configHeight is num) {
        fixedHeight = configHeight.toDouble() * scaleY;
      } else {
        final str = configHeight.toString().replaceAll('px', '');
        final parsed = double.tryParse(str);
        if (parsed != null) fixedHeight = parsed * scaleY;
      }
    }

    // ✅ FIX 1: Add Safe Area & Drag Handle padding to fixed height so content doesn't get squished/cut
    if (fixedHeight != null) {
      fixedHeight += (viewPaddingTop + viewPaddingBottom);
      if (raw['dragHandle'] == true) {
        fixedHeight += 12.0 * scaleY;
      }
    }

    final floaterLayer = widget.layers.firstWhere(
      (l) => l.name == 'Floater Container',
      orElse: () =>
          widget.layers.isNotEmpty ? widget.layers.first : Layer.fromJson({}),
    );

    // Background - Hoist from config OR floaterLayer to ensure Safe Area is covered
    String? bgUrl = raw['backgroundImageUrl']?.toString();
    if ((bgUrl == null || bgUrl.trim().isEmpty) && floaterLayer.style != null) {
      final styleBg = floaterLayer.style?.backgroundImage;
      if (styleBg != null && styleBg.toString().startsWith('url')) {
        bgUrl = styleBg
            .toString()
            .replaceAll('url(', '')
            .replaceAll(')', '')
            .replaceAll('"', '')
            .replaceAll("'", '')
            .trim();
      }
    }

    final bgSize = raw['backgroundSize']?.toString() ?? 'cover';
    BoxFit boxFit = BoxFit.cover;
    if (bgSize == 'contain') boxFit = BoxFit.contain;
    if (bgSize == 'fill') boxFit = BoxFit.fill;

    // Radius
    final radiusValue = raw['borderRadius'];
    double radiusPx = 16.0;
    if (radiusValue is num) {
      radiusPx = radiusValue.toDouble();
    } else if (radiusValue is Map) {
      // Take max of available corners
      final values =
          radiusValue.values.whereType<num>().map((e) => e.toDouble());
      if (values.isNotEmpty)
        radiusPx = values.reduce((curr, next) => curr > next ? curr : next);
    }
    radiusPx *= scaleX; // Parity: Explicit scalar logic

    // Border
    final borderWidth =
        ((raw['borderWidth'] as num?)?.toDouble() ?? 0.0) * scaleX;
    final borderColor =
        NinjaLayerUtils.parseColor(raw['borderColor']) ?? Colors.black;

    // Shadow
    // If Banner (Top): Shadow Down (+Y)
    // If Sheet (Bottom): Shadow Up (-Y)
    List<BoxShadow>? boxShadows;
    if (widget.config.raw['shadow']?['enabled'] == true) {
      // Use user defined shadow
      final s = widget.config.shadow!;
      boxShadows = [
        BoxShadow(
          color: NinjaLayerUtils.parseColor(s.color) ??
              Colors.black.withValues(alpha: 0.2),
          blurRadius: (s.blur ?? 12).toDouble() * scaleX,
          spreadRadius: (s.spread ?? 0).toDouble() * scaleX,
          offset: Offset(0, (_isTop ? 4 : -4).toDouble() * scaleX),
        )
      ];
    }
    // Parity: Do NOT apply an implicit default shadow if strictly not enabled via UI

    // Safe Area + Drag Handle Logic (Matches React wrapper padding)
    final hasDragHandle = raw['dragHandle'] == true;
    final dragHandleOffset =
        (hasDragHandle ? 12.0 : 0.0) * (widget.scale ?? 1.0);

    EdgeInsets safeAreaPadding;
    if (_isTop) {
      // Top Banner: Safe Area at top, Drag Handle at bottom
      safeAreaPadding =
          EdgeInsets.only(top: viewPaddingTop, bottom: dragHandleOffset);
    } else {
      // Bottom Sheet: Drag Handle at top, Safe Area at bottom
      safeAreaPadding =
          EdgeInsets.only(top: dragHandleOffset, bottom: viewPaddingBottom);
    }

    return _BottomSheetStyle(
      alignment: _isTop ? Alignment.topCenter : Alignment.bottomCenter,
      height: isPercentage ? screenHeight * percentageValue : fixedHeight,
      safeAreaPadding: safeAreaPadding,
      viewInsetsBottom: viewInsetsBottom,
      viewPaddingBottom: viewPaddingBottom,
      swipeToDismiss: raw['swipeToDismiss'] == true,
      isScrollable: (raw['overflow'] ?? 'hide') == 'scroll',
      hasDragHandle: raw['dragHandle'] == true,
      clipBehavior: Clip
          .antiAlias, // ALWAYS clip to prevent background image bleed through rounded corners
      innerConfig: NudgeConfig.fromJson({
        ..._createBottomSheetConfig().raw,
        'height': '100%', // 🔴 CRITICAL PARITY: Force 100% so inner DOM perfectly bounds to wrapper's evaluated physics (prevents 200px fallback)
        'overflow': raw['overflow'] ?? 'hide',
        'bottomSheetConfig': null, // 🔴 CRITICAL: Prevent NudgeConfig.fromJson from magically reviving backgroundImageUrl
        'backgroundImageUrl': '', // Handled by wrapper
        'media': {'url': '', 'type': 'none'},
      }),
      boxDecoration: BoxDecoration(
        color: (() {
          if (raw['backgroundColor'] != null &&
              raw['backgroundColor'] != 'transparent' &&
              raw['backgroundColor'] != '#00000000') {
            return NinjaLayerUtils.parseColor(raw['backgroundColor']) ?? Colors.white;
          } else if (raw['backgroundColor'] == 'transparent' ||
              raw['backgroundColor'] == '#00000000') {
            return Colors.transparent;
          }
          return Colors.white;
        })(),
        image: (bgUrl != null && bgUrl.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(bgUrl),
                fit: boxFit,
                repeat: ImageRepeat.noRepeat,
                alignment: Alignment.center,
              )
            : null,
        // Dynamic Radius
        borderRadius: _isTop
            ? BorderRadius.only(
                bottomLeft: Radius.circular(radiusPx),
                bottomRight: Radius.circular(radiusPx))
            : BorderRadius.only(
                topLeft: Radius.circular(radiusPx),
                topRight: Radius.circular(radiusPx)),
        // Dynamic Border
        border: borderWidth > 0
            ? Border(
                top: (!_isTop)
                    ? BorderSide(color: borderColor, width: borderWidth)
                    : BorderSide.none,
                bottom: (_isTop)
                    ? BorderSide(color: borderColor, width: borderWidth)
                    : BorderSide.none,
                left: BorderSide(color: borderColor, width: borderWidth),
                right: BorderSide(color: borderColor, width: borderWidth),
              )
            : null,
        boxShadow: boxShadows,
      ),
    );
  }
}

class _BottomSheetStyle {
  final Alignment alignment;
  final double? height;
  final EdgeInsets safeAreaPadding;
  final double viewInsetsBottom; // Added for keyboard tracking
  final double viewPaddingBottom; // Added for keyboard tracking
  final bool swipeToDismiss;
  final bool isScrollable;
  final bool hasDragHandle;
  final Clip clipBehavior;
  final NudgeConfig innerConfig;
  final BoxDecoration boxDecoration;

  _BottomSheetStyle({
    required this.alignment,
    required this.height,
    required this.safeAreaPadding,
    required this.viewInsetsBottom,
    required this.viewPaddingBottom,
    required this.swipeToDismiss,
    required this.isScrollable,
    required this.hasDragHandle,
    required this.clipBehavior,
    required this.innerConfig,
    required this.boxDecoration,
  });
}
