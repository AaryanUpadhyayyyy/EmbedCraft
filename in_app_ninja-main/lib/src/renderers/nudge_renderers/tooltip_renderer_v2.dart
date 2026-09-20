// ============================================================================
// TooltipRendererV2 - Direct Dart conversion from Dashboard's TooltipRenderer.tsx
// PHASE 1-7: Complete 1:1 parity with Dashboard rendering logic
// ============================================================================

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../utils/ninja_sdk_safe.dart';
import '../../models/campaign.dart';
import '../../utilities/sharedHelper/design_scale.dart';
import '../../app_ninja.dart';
import '../../utils/interface_handler.dart';
import '../layers/ninja_container_layer.dart';
import '../layers/ninja_text_layer.dart';
import '../layers/ninja_button_layer.dart';
import '../layers/ninja_image_layer.dart';
import '../layers/ninja_input_layer.dart';
import '../layers/ninja_copy_button_layer.dart';
import '../layers/ninja_lottie_layer.dart';
import '../layers/ninja_rive_layer.dart';
import '../layers/ninja_custom_html_layer.dart';
import '../../utils/ninja_logger.dart';

// ============================================================================
// CONSTANTS - Dashboard design dimensions (see design_scale.dart)
// ============================================================================

// ============================================================================
// HELPER FUNCTIONS - Direct Dart equivalents of Dashboard's TS helpers
// ============================================================================

/// Dashboard: safeScale(val, factor)
/// Scales pixel values by factor, passes through %, vh, vw strings unchanged
/// Returns null for null input, scaled pixel value for numbers
double? safeScale(dynamic val, double factor) {
  if (val == null) return null;
  final strVal = val.toString().trim();
  if (strVal.endsWith('%') || strVal.endsWith('vh') || strVal.endsWith('vw')) {
    // Percentage values should not be scaled - return null and handle separately
    return null;
  }
  final num = double.tryParse(strVal.replaceAll('px', ''));
  if (num == null) return null;
  return num * factor;
}

/// Dashboard: toPercentX(val) - converts to CSS percentage relative to design width (393)
/// Returns percentage as decimal (0.0 - 1.0) for Flutter's FractionalOffset
double? toPercentX(dynamic val) {
  if (val == null) return null;
  final str = val.toString().trim();
  if (str.endsWith('%')) {
    return double.tryParse(str.replaceAll('%', ''))?.clamp(0, 100) ?? 0 / 100;
  }
  final num = double.tryParse(str);
  if (num == null) return null;
  return (num / kNinjaDesignWidth); // Return as fraction (0-1)
}

/// Dashboard: toPercentY(val) - converts to CSS percentage relative to design height (852)
double? toPercentY(dynamic val) {
  if (val == null) return null;
  final str = val.toString().trim();
  if (str.endsWith('%')) {
    return double.tryParse(str.replaceAll('%', ''))?.clamp(0, 100) ?? 0 / 100;
  }
  final num = double.tryParse(str);
  if (num == null) return null;
  return (num / kNinjaDesignHeight); // Return as fraction (0-1)
}

/// Parse color from hex string (Dashboard uses CSS colors)
Color parseColor(String? colorStr, [double opacity = 1.0]) {
  if (colorStr == null || colorStr.isEmpty) return Colors.transparent;
  if (colorStr == 'transparent') return Colors.transparent;

  // Handle rgba() format
  if (colorStr.startsWith('rgba')) {
    final match = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+),?\s*([\d.]+)?\)')
        .firstMatch(colorStr);
    if (match != null) {
      return Color.fromRGBO(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        double.tryParse(match.group(4) ?? '1') ?? 1.0,
      );
    }
  }

  // Handle #hex format
  String hex = colorStr.replaceAll('#', '');
  if (hex.length == 3) {
    hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
  }
  if (hex.length == 8) {
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    final a = int.parse(hex.substring(6, 8), radix: 16) / 255.0;
    return Color.fromRGBO(r, g, b, a * opacity);
  }
  if (hex.length == 6) {
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    return Color.fromRGBO(r, g, b, opacity);
  }

  return Colors.black.withOpacity(opacity);
}

// ============================================================================
// TARGET GEOMETRY - Dashboard's getTargetGeometry()
// ============================================================================
class TargetGeometry {
  final double x;
  final double y;
  final double width;
  final double height;
  final double padding;
  final double drawX;
  final double drawY;
  final double drawWidth;
  final double drawHeight;
  final double radius;

  TargetGeometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.padding,
    required this.drawX,
    required this.drawY,
    required this.drawWidth,
    required this.drawHeight,
    required this.radius,
  });
}

TargetGeometry? getTargetGeometry({
  required Rect? targetRect,
  required Map<String, dynamic> config,
  required double scale,
  required double scaleY,
}) {
  if (targetRect == null) return null;

  // FIX: targetRect is already in DEVICE PIXELS from localToGlobal()
  // Do NOT multiply by scale again!
  final x = targetRect.left;
  final y = targetRect.top;
  final width = targetRect.width;
  final height = targetRect.height;

  // Apply manual fine-tuning (these are DESIGN values, so scale them)
  final offsetX = ((config['targetOffsetX'] as num?)?.toDouble() ?? 0) * scale;
  final offsetY = ((config['targetOffsetY'] as num?)?.toDouble() ?? 0) * scaleY;
  final widthAdj =
      ((config['targetWidthAdjustment'] as num?)?.toDouble() ?? 0) * scale;
  final heightAdj =
      ((config['targetHeightAdjustment'] as num?)?.toDouble() ?? 0) * scaleY;

  final padding =
      ((config['targetHighlightPadding'] as num?)?.toDouble() ?? 4) * scale;

  // FIX: Use raw device pixel coordinates + scaled adjustments
  final baseX = x + offsetX;
  final baseY = y + offsetY;
  final baseW = width + widthAdj;
  final baseH = height + heightAdj;

  return TargetGeometry(
    x: baseX,
    y: baseY,
    width: baseW,
    height: baseH,
    padding: padding,
    drawX: baseX - padding,
    drawY: baseY - padding,
    drawWidth: baseW + (padding * 2),
    drawHeight: baseH + (padding * 2),
    radius: ((config['targetRoundness'] as num?)?.toDouble() ?? 4) * scale,
  );
}

// ============================================================================
// TOOLTIP POSITION - Dashboard's getPosStyle()
// Returns offset from target for tooltip positioning
// ============================================================================
Offset getTooltipPosition({
  required TargetGeometry? targetGeo,
  required Map<String, dynamic> config,
  required double scale,
  required double scaleY,
  required Size tooltipSize,
}) {
  if (targetGeo == null) {
    // Center on screen if no target
    return Offset.zero; // Will be handled by caller
  }

  final gap = ((config['arrowSize'] as num?)?.toDouble() ?? 10) * scale;
  final offX = ((config['offsetX'] as num?)?.toDouble() ?? 0) * scale;
  final offY = ((config['offsetY'] as num?)?.toDouble() ?? 0) * scaleY;

  final padding = (config['targetHighlightPadding'] as num?)?.toDouble() ?? 4;
  final rx = targetGeo.drawX + padding * scale;
  final ry = targetGeo.drawY + padding * scaleY;
  final rw = targetGeo.drawWidth - padding * scale * 2;
  final rh = targetGeo.drawHeight - padding * scaleY * 2;

  final position = config['position']?.toString() ?? 'bottom';

  switch (position) {
    case 'top':
      return Offset(
        rx + rw / 2 - tooltipSize.width / 2 + offX,
        ry - gap - tooltipSize.height + offY,
      );
    case 'bottom':
      return Offset(
        rx + rw / 2 - tooltipSize.width / 2 + offX,
        ry + rh + gap + offY,
      );
    case 'left':
      return Offset(
        rx - gap - tooltipSize.width + offX,
        ry + rh / 2 - tooltipSize.height / 2 + offY,
      );
    case 'right':
      return Offset(
        rx + rw + gap + offX,
        ry + rh / 2 - tooltipSize.height / 2 + offY,
      );
    default:
      return Offset(
        rx + rw / 2 - tooltipSize.width / 2,
        ry + rh + gap,
      );
  }
}

// ============================================================================
// MAIN WIDGET - TooltipRendererV2
// ============================================================================
class TooltipRendererV2 extends StatefulWidget {
  final Map<String, dynamic>? nudgeData;
  final Campaign? campaign; // NEW: Accept Campaign directly
  final Rect? targetRect; // Optional override
  final VoidCallback? onDismiss;
  final VoidCallback? onRemoveOverlay;
  final Function(String action, Map<String, dynamic>? data)? onAction;
  final VoidCallback? onImpression;

  const TooltipRendererV2({
    Key? key,
    this.nudgeData,
    this.campaign,
    this.targetRect,
    this.onDismiss,
    this.onRemoveOverlay,
    this.onAction,
    this.onImpression,
  }) : super(key: key);

  @override
  State<TooltipRendererV2> createState() => _TooltipRendererV2State();
}

class _TooltipRendererV2State extends State<TooltipRendererV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Target resolution state
  Rect? _resolvedTargetRect;
  LayerLink? _targetLink;
  bool _hasScrolledToTarget = false;

  @override
  void initState() {
    super.initState();
    
    // Track impression
    if (widget.onImpression != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onImpression!();
      });
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.targetRect != null) {
      _resolvedTargetRect = widget.targetRect;
      _controller.forward();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveTargetElement();
      });
    }
  }

  @override
  void didUpdateWidget(TooltipRendererV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetRect != oldWidget.targetRect) {
      setState(() {
        _resolvedTargetRect = widget.targetRect;
      });
      // FIX: Forward animation when we receive a valid rect for first time
      if (widget.targetRect != null && oldWidget.targetRect == null) {
        _controller.forward();
      }
    }

    final oldId = oldWidget.campaign?.id ?? oldWidget.nudgeData?['id'];
    final newId = widget.campaign?.id ?? widget.nudgeData?['id'];

    if (oldId != newId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resolveTargetElement();
      });
    }
  }

  void _resolveTargetElement() {
    // FIX: Use V1's exact config path resolution
    final config = widget.campaign?.config ?? widget.nudgeData?['config'] ?? {};

    // FIX: Check multiple paths for targetElementId (same as V1)
    final tooltipConfig = config['tooltipConfig'] as Map<String, dynamic>? ??
        config['tooltip_config'] as Map<String, dynamic>? ??
        config;

    final targetId = tooltipConfig['targetElementId']?.toString() ??
        tooltipConfig['target_element_id']?.toString() ??
        config['targetElementId']?.toString() ??
        config['target_element_id']?.toString();

    NinjaLog.d('AppNinja', 'InAppNinja: 🔍 [V2] Looking for targetElementId: $targetId');

    if (targetId != null) {
      // 1. Try Compositor Link (Best Performance)
      final link = AppNinja.getLink(targetId);
      if (link != null) {
        NinjaLog.d('AppNinja', 'InAppNinja: 🔗 [V2] Found LayerLink for target!');
        setState(() {
          _targetLink = link;
          // We still need rect for Spotlight and arrow calculations
          // But main positioning will be handled by Follower
        });
      }

      // 2. Fallback to RenderBox (Required for Rect/Spotlight)
      final targetContext = AppNinja.getTargetContext(targetId);
      if (targetContext != null) {
        final renderBox = targetContext.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final offset = renderBox.localToGlobal(Offset.zero);
          setState(() {
            _resolvedTargetRect = Rect.fromLTWH(
              offset.dx,
              offset.dy,
              renderBox.size.width,
              renderBox.size.height,
            );
          });

          NinjaLog.d('AppNinja', 
              '🎯 [V2] Target Found! _resolvedTargetRect: $_resolvedTargetRect');

          // Auto-scroll if target is not in viewport and config enabled
          // FIX: Default to true for tooltips (target must be visible),
          // and accept both boolean true and string "true" from JSON config
          final autoScrollVal = tooltipConfig['autoScrollToTarget'];
          final autoScroll = autoScrollVal == true ||
              autoScrollVal?.toString().toLowerCase() == 'true' ||
              autoScrollVal == null; // Default: ON for tooltips

          if (autoScroll && !_hasScrolledToTarget) {
            // FIX: Check if target is actually off-screen before scrolling
            final screenSize = MediaQuery.of(context).size;
            final isOffScreen = offset.dy < 0 ||
                offset.dy + renderBox.size.height > screenSize.height ||
                offset.dx < 0 ||
                offset.dx + renderBox.size.width > screenSize.width;

            if (isOffScreen) {
              _hasScrolledToTarget = true;

              // NEW: Try exact scroll offset replay first (from dashboard capture)
              final targetScrollOffset = tooltipConfig['targetScrollOffset'] as Map<String, dynamic>?;
              if (targetScrollOffset != null) {
                final scrollY = (targetScrollOffset['scrollY'] as num?)?.toDouble() ?? 0.0;
                final scrollX = (targetScrollOffset['scrollX'] as num?)?.toDouble() ?? 0.0;
                if (scrollY > 0 || scrollX > 0) {
                  NinjaLog.d('AppNinja', 'InAppNinja: 📜 [V2] Scrolling to captured offset: Y=$scrollY, X=$scrollX');
                  _scrollToExactOffset(targetContext, scrollY, scrollX);
                  return; // Don't forward animation yet - callback will re-resolve
                }
              }

              // Fallback: Use ensureVisible when no captured scroll data
              NinjaLog.d('AppNinja', 'InAppNinja: 📜 [V2] No captured scroll offset, using ensureVisible');
              _scrollToTargetIfNeeded(targetContext);
              return; // Don't forward animation yet - callback will re-resolve
            }
          }

          _controller.forward();
        }
      } else {
        // No target context found, show centered or at least show simple tooltip
        NinjaLog.d('AppNinja', 'InAppNinja: ⚠️ [V2] Target context not found: $targetId');
        _controller.forward();
      }
    } else {
      // No target specified
      NinjaLog.d('AppNinja', 'InAppNinja: ⚠️ [V2] No targetId specified');
      _controller.forward();
    }
  }

  /// Scroll to the exact captured offset (from dashboard page capture).
  /// This reproduces the user's scroll position at the time the page was captured,
  /// ensuring the tooltip targets the element at the same visual position.
  void _scrollToExactOffset(BuildContext targetContext, double scrollY, double scrollX) {
    try {
      // Try to find the primary ScrollController via the target's ancestor
      final scrollable = Scrollable.maybeOf(targetContext);
      final controller = scrollable?.widget.controller ??
          PrimaryScrollController.maybeOf(targetContext);

      if (controller != null && controller.hasClients) {
        // Clamp to valid range
        final clampedY = scrollY.clamp(0.0, controller.position.maxScrollExtent);
        NinjaLog.d('AppNinja', 'InAppNinja: 📜 [V2] Animating to offset: $clampedY (max: ${controller.position.maxScrollExtent})');
        
        controller.animateTo(
          clampedY,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ).then((_) {
          // Wait for layout to settle after scroll
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) _resolveTargetElement();
          });
        }).catchError((e, st) {
          ninjaSdkLogError(e, st, 'TooltipRendererV2 scrollToExactOffset');
          // Fallback: try ensureVisible
          if (mounted) _scrollToTargetIfNeeded(targetContext);
        });
      } else {
        // No controller found, fallback to ensureVisible
        NinjaLog.d('AppNinja', 'InAppNinja: ⚠️ [V2] No ScrollController found, falling back to ensureVisible');
        _scrollToTargetIfNeeded(targetContext);
      }
    } catch (e, st) {
      ninjaSdkLogError(e, st, 'TooltipRendererV2 scrollToExactOffset');
      if (mounted) _scrollToTargetIfNeeded(targetContext);
    }
  }

  void _scrollToTargetIfNeeded(BuildContext targetContext) {
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.5,
    ).then((_) {
      // FIX: Wait for scroll animation to fully settle before re-resolving
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _resolveTargetElement();
      });
    }).catchError((e, st) {
      ninjaSdkLogError(e, st, 'TooltipRendererV2 ensureVisible');
      // FIX: Still show tooltip even if scroll fails
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============ ACTION HANDLER ============
  // Dashboard: handleAction(action)
  // ============ ACTION HANDLER ============
  Future<void> _handleAction(String action,
      [Map<String, dynamic>? data]) async {
    NinjaLog.d('AppNinja', '[TooltipV2] Action: $action, data: $data');

    switch (action) {
      case 'close':
      case 'dismiss':
        _handleDismiss();
        break;

      case 'interface':
        final interfaceId = data?['interfaceId'] as String?;
        if (interfaceId != null && interfaceId.isNotEmpty) {
          _showInterface(interfaceId);
        }
        break;

      case 'deeplink':
      case 'link':
      case 'open_link':
      case 'external_url':
        final url = data?['url'] as String?;
        if (url != null) {
          // Try to launch locally if CampaignRenderer doesn't catch it
          // But usually bubbling up to CampaignRenderer is enough for 'link'
          widget.onAction?.call(action, {'url': url, ...?data});
        }
        break;

      case 'navigate':
        final route = data?['route'] as String? ?? data?['screen'] as String?;
        widget.onAction?.call(action, {'route': route, ...?data});
        break;

      default:
        widget.onAction?.call(action, data ?? {});
    }
  }

  void _showInterface(String interfaceId) {
    NinjaLog.d('AppNinja', '[TooltipV2] 🔄 Chaining interface: $interfaceId');

    // 1. Animate out current tooltip
    _controller.reverse().then((_) {
      if (!mounted) return;

      // 2. Show new interface
      // Note: We need a parent campaign. If passed directly use it, else try to construct/find it.
      // InterfaceHandler requires a Campaign object.
      if (widget.campaign != null) {
        InterfaceHandler.show(
          interfaceId: interfaceId,
          parentCampaign: widget.campaign!,
          context: context,
          onDismiss: widget.onDismiss,
          onCTAClick: widget.onAction,
        );
      } else {
        NinjaLog.d('AppNinja', 
            '[TooltipV2] ❌ Cannot chain interface: Campaign object missing');
      }

      // 3. Remove this overlay
      widget.onRemoveOverlay?.call();
    }).catchError((e, st) {
      ninjaSdkLogError(e, st, 'TooltipRendererV2 _showInterface reverse');
    });
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate scale factors (Dashboard: scale = containerWidth / 393)
    final scale = screenSize.width / kNinjaDesignWidth;
    final scaleY = screenSize.height / kNinjaDesignHeight;

    // Extract config and layers - Try Campaign first, then nudgeData
    final baseConfig =
        widget.campaign?.config ?? widget.nudgeData?['config'] ?? {};
    final config = (baseConfig['tooltipConfig'] as Map<String, dynamic>?) ??
        (baseConfig['tooltip_config'] as Map<String, dynamic>?) ??
        (widget.nudgeData?['config'] as Map<String, dynamic>?) ??
        baseConfig;

    // Fix: Ensure layers are a List
    final rawLayersList =
        widget.campaign?.layers ?? widget.nudgeData?['layers'];
    final rawLayers = rawLayersList is List ? rawLayersList : [];

    // Get target geometry (prefer override, then resolved)
    final effectiveTargetRect = widget.targetRect ?? _resolvedTargetRect;

    final targetGeo = getTargetGeometry(
      targetRect: effectiveTargetRect,
      config: config,
      scale: scale,
      scaleY: scaleY,
    );

    // Check modes
    final isCoachmarkEnabled = config['coachmarkEnabled'] == true;
    final isBodyVisible = config['showTooltipBody'] != false;

    return FadeTransition(
      opacity: _controller,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Overlay
          _buildOverlay(config, targetGeo, scale, scaleY, screenSize),

          // 2. Target Decoration
          if (targetGeo != null)
            _buildTargetDecoration(config, targetGeo, scale),

          // 3. Layers (Coachmark mode or non-visible body = full screen)
          if (isCoachmarkEnabled || !isBodyVisible)
            _buildFullScreenLayers(
                rawLayers, config, scale, scaleY, screenSize),

          // 4. Tooltip Body (non-coachmark mode with visible body)
          if (!isCoachmarkEnabled && isBodyVisible)
            _buildTooltipBody(
                rawLayers, config, targetGeo, scale, scaleY, screenSize),
        ],
      ),
    );
  }

  // ============================================================================
  // OVERLAY BUILDER - Dashboard's renderOverlay()
  // ============================================================================
  Widget _buildOverlay(
    Map<String, dynamic> config,
    TargetGeometry? targetGeo,
    double scale,
    double scaleY,
    Size screenSize,
  ) {
    if (config['overlayEnabled'] == false) return const SizedBox.shrink();

    final opacity = (config['overlayOpacity'] as num?)?.toDouble() ?? 0.75;
    final baseColor = config['overlayColor']?.toString() ?? '#000000';
    final overlayColor = parseColor(baseColor, opacity);

    // Timeline mode prevents dismiss on outside click
    final timelineMode = config['timelineMode'] == true;
    final closeOnOutsideClick = config['closeOnOutsideClick'] != false;

    void handleOverlayTap() {
      if (timelineMode) return;
      if (closeOnOutsideClick) {
        _handleDismiss();
      }
    }

    // Standard overlay without target
    if (targetGeo == null) {
      return Positioned.fill(
        child: GestureDetector(
          onTap: handleOverlayTap,
          child: Container(color: overlayColor),
        ),
      );
    }

    // Non-coachmark mode: simple box-shadow cutout effect
    final isCoachmarkEnabled = config['coachmarkEnabled'] == true;

    if (!isCoachmarkEnabled) {
      // Dashboard uses boxShadow: `0 0 0 9999px ${overlayColor}`
      // Flutter equivalent: ColorFiltered with cutout
      return Positioned.fill(
        child: GestureDetector(
          onTap: handleOverlayTap,
          child: CustomPaint(
            painter: _SpotlightPainter(
              targetRect: Rect.fromLTWH(
                targetGeo.drawX,
                targetGeo.drawY,
                targetGeo.drawWidth,
                targetGeo.drawHeight,
              ),
              borderRadius: targetGeo.radius,
              overlayColor: overlayColor,
            ),
          ),
        ),
      );
    }

    // COACHMARK MODE: SVG-based spotlight (more complex shapes)
    return _buildCoachmarkOverlay(
        config, targetGeo, scale, scaleY, screenSize, overlayColor);
  }

  Widget _buildCoachmarkOverlay(
    Map<String, dynamic> config,
    TargetGeometry targetGeo,
    double scale,
    double scaleY,
    Size screenSize,
    Color overlayColor,
  ) {
    final targetX = targetGeo.x;
    final targetY = targetGeo.y;
    final targetW = targetGeo.width;
    final targetH = targetGeo.height;
    final cx = targetX + targetW / 2;
    final cy = targetY + targetH / 2;

    // Spotlight dimensions
    final padding =
        ((config['spotlightPadding'] as num?)?.toDouble() ?? 12) * scale;
    final configSpotWidth = (config['spotlightWidth'] as num?)?.toDouble();
    final configSpotHeight = (config['spotlightHeight'] as num?)?.toDouble();
    final baseWidth = (configSpotWidth != null && configSpotWidth > 0)
        ? configSpotWidth * scale
        : targetW;
    final baseHeight = (configSpotHeight != null && configSpotHeight > 0)
        ? configSpotHeight * scale
        : targetH;
    final radius =
        ((config['spotlightRadius'] as num?)?.toDouble() ?? 8) * scale;
    final blur = ((config['spotlightBlur'] as num?)?.toDouble() ?? 0) * scale;

    final spotW = baseWidth + padding * 2;
    final spotH = baseHeight + padding * 2;
    final spotX = cx - spotW / 2;
    final spotY = cy - spotH / 2;

    final maxRadius = min(spotW, spotH) / 2;
    final rx = min(radius, maxRadius);

    // Coachmark shape
    final coachmarkShape = config['coachmarkShape']?.toString() ?? 'rectangle';

    // Timeline mode prevents dismiss on outside click
    final timelineMode = config['timelineMode'] == true;
    final closeOnOutsideClick = config['closeOnOutsideClick'] != false;

    void handleOverlayTap() {
      if (timelineMode) return;
      if (closeOnOutsideClick) {
        _handleDismiss();
      }
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: handleOverlayTap,
        child: CustomPaint(
          painter: _CoachmarkPainter(
            spotlightRect: Rect.fromLTWH(spotX, spotY, spotW, spotH),
            spotlightRadius: rx,
            overlayColor: overlayColor,
            blur: blur,
            coachmarkShape: coachmarkShape,
            waveConfig: coachmarkShape == 'wave'
                ? _WaveConfig(
                    origin: config['waveOrigin']?.toString() ?? 'bottom',
                    coverage:
                        ((config['waveCoverage'] as num?)?.toDouble() ?? 60) /
                            100,
                    curvature:
                        ((config['waveCurvature'] as num?)?.toDouble() ?? 80) *
                            scale,
                    waveFitToHeight: config['waveFitToHeight'] == true,
                    scale: scale,
                    scaleY: scaleY,
                    screenSize: screenSize,
                  )
                : null,
            ringConfig: config['ringEnabled'] == true
                ? _RingConfig(
                    shape: config['ringShape']?.toString() ?? 'rectangle',
                    width: ((config['ringWidth'] as num?)?.toDouble() ?? 2) *
                        scale,
                    color: parseColor(
                        config['ringColor']?.toString() ?? '#ffffff'),
                    gap: ((config['ringGap'] as num?)?.toDouble() ?? 6) * scale,
                    count: (config['ringCount'] as num?)?.toInt() ??
                        (config['ringShape']?.toString() == 'rectangle'
                            ? 2
                            : 1),
                    radius: ((config['ringRadius'] as num?)?.toDouble() ?? 50) *
                        scale,
                    arcPercent:
                        (config['ringArcPercent'] as num?)?.toDouble() ?? 100,
                    arcStartAngle:
                        (config['ringArcStartAngle'] as num?)?.toDouble() ?? 0,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TARGET DECORATION - Dashboard's renderTargetDecoration()
  // ============================================================================
  Widget _buildTargetDecoration(
    Map<String, dynamic> config,
    TargetGeometry targetGeo,
    double scale,
  ) {
    if (config['targetStyleEnabled'] == false) return const SizedBox.shrink();

    final borderColorStr = config['targetBorderColor']?.toString() ?? '#6366F1';
    final borderColor = parseColor(borderColorStr);
    final borderWidth = config['targetBorderEnabled'] != false
        ? ((config['targetBorderWidth'] as num?)?.toDouble() ?? 0) * scale
        : 0.0;
    final fillColorStr = config['targetFillColor']?.toString() ?? 'transparent';
    final fillColor = parseColor(fillColorStr);

    final closeOnTargetClick = config['closeOnTargetClick'] == true;

    return Positioned(
      left: targetGeo.drawX,
      top: targetGeo.drawY,
      width: targetGeo.drawWidth,
      height: targetGeo.drawHeight,
      child: IgnorePointer(
        ignoring: !closeOnTargetClick,
        child: GestureDetector(
          onTap: closeOnTargetClick ? () => _handleDismiss() : null,
          behavior: closeOnTargetClick
              ? HitTestBehavior.opaque
              : HitTestBehavior.translucent,
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(targetGeo.radius),
              border: borderWidth > 0
                  ? Border.all(color: borderColor, width: borderWidth)
                  : null,
              boxShadow: config['targetShadowEnabled'] == true
                  ? [
                      BoxShadow(
                        color: parseColor(
                          config['targetShadowColor']?.toString() ??
                              borderColorStr,
                        ),
                        blurRadius:
                            _safeDouble(config['targetShadowBlur'], 8) * scale,
                        spreadRadius:
                            _safeDouble(config['targetShadowSpread'], 0) *
                                scale,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // FULL SCREEN LAYERS - Dashboard's coachmark/free positioning mode
  // ============================================================================
  Widget _buildFullScreenLayers(
    List<dynamic> rawLayers,
    Map<String, dynamic> config,
    double scale,
    double scaleY,
    Size screenSize,
  ) {
    // Filter and build layers
    final tooltipLayerId = rawLayers.firstWhere(
      (l) => (l as Map<String, dynamic>)['type'] == 'tooltip',
      orElse: () => rawLayers.isNotEmpty ? rawLayers[0] : null,
    )?['id'];

    final layersToRender = rawLayers.where((l) {
      final layer = l as Map<String, dynamic>;
      if (layer['id'] == tooltipLayerId) return false;
      if (layer['visible'] == false) return false;
      final parent = layer['parent'];
      return parent == null || parent == tooltipLayerId;
    }).toList();

    // Sort logic to match CSS stacking context
    final sortedLayers = _sortLayersByZIndex(layersToRender);

    // parentSize = tooltip size (for position %)
    // scaleSize = tooltip size (for size scaling)
    final tooltipWidth = _getTooltipWidth(config, scale);
    final tooltipHeight = _getTooltipHeight(config, scale, scaleY, screenSize);
    final tooltipSize = Size(tooltipWidth ?? (280 * scale), tooltipHeight);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final layer in sortedLayers)
              _buildLayer(
                layer,
                config,
                scale,
                scaleY,
                screenSize, // parentSize = Screen Size for Coachmark
                screenSize, // scaleSize = Screen Size (Global Scaling) for nested layers
                rawLayers, // allLayers for container child lookup (full flat list)
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TOOLTIP BODY - Dashboard's tooltip mode rendering
  // ============================================================================
  Widget _buildTooltipBody(
    List<dynamic> rawLayers,
    Map<String, dynamic> config,
    TargetGeometry? targetGeo,
    double scale,
    double scaleY,
    Size screenSize,
  ) {
    // Tooltip dimensions
    final tooltipWidth = _getTooltipWidth(config, scale);
    final tooltipHeight = _getTooltipHeight(config, scale, scaleY, screenSize);
    // If width is auto (null), we use 0 or a placeholder for layout calculations that REQUIRE a size
    // (like positioning relative to target, or percentage based children).
    // However, for the Container itself, we pass null.
    final tooltipSize = Size(tooltipWidth ?? 0, tooltipHeight);

    // Background styling
    final bgColorStr = config['backgroundColor']?.toString() ?? '#1F2937';
    final bgOpacity = _safeDouble(config['backgroundOpacity'], 1.0);
    final bgColor = parseColor(bgColorStr, bgOpacity);
    final bgImageUrl = config['backgroundImageUrl']?.toString();
    final borderRadius = _safeDouble(config['borderRadius'], 12) * scale;
    final padding = _safeDouble(config['padding'], 16) * scale;

    // Shadow
    final shadowEnabled = config['shadowEnabled'] != false;
    final shadowOffsetX = _safeDouble(config['shadowOffsetX'], 0) * scale;
    final shadowOffsetY = _safeDouble(config['shadowOffsetY'], 10) * scaleY;
    final shadowBlur = _safeDouble(config['shadowBlur'], 25) * scale;
    final shadowSpread = _safeDouble(config['shadowSpread'], 0) * scale;
    final shadowColorStr = config['shadowColor']?.toString() ?? '#000000';
    final shadowOpacity = _safeDouble(config['shadowOpacity'], 0.2);
    final shadowColor = parseColor(shadowColorStr, shadowOpacity);

    // Glassmorphism
    final glassConfig =
        config['backdropFilter'] is Map ? config['backdropFilter'] : null;
    final glassEnabled = glassConfig?['enabled'] == true;
    final glassBlur = _safeDouble(glassConfig?['blur'], 10) * scale;

    // Position relative to target
    final position = getTooltipPosition(
      targetGeo: targetGeo,
      config: config,
      scale: scale,
      scaleY: scaleY,
      tooltipSize: tooltipSize,
    );

    // Filter layers to render
    final tooltipLayerId = rawLayers.firstWhere(
      (l) => (l as Map<String, dynamic>)['type'] == 'tooltip',
      orElse: () => rawLayers.isNotEmpty ? rawLayers[0] : null,
    )?['id'];

    final layersToRender = rawLayers.where((l) {
      final layer = l as Map<String, dynamic>;
      if (layer['id'] == tooltipLayerId) return false;
      if (layer['visible'] == false) return false;
      final parent = layer['parent'];
      return parent == null || parent == tooltipLayerId;
    }).toList();

    // Sort layers by Z-Index
    final sortedLayers = _sortLayersByZIndex(layersToRender);

    // Calculate actual position (centered if no target)
    double left, top;
    if (targetGeo == null) {
      left = (screenSize.width - (tooltipWidth ?? (280 * scale))) / 2;
      top = (screenSize.height - tooltipHeight) / 2;
    } else {
      left = position.dx;
      top = position.dy;
    }

    return Positioned(
      left: left,
      top: top,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Arrow (Rendered First = Behind)
          if (config['showArrow'] != false)
            _buildArrow(config, scale, tooltipWidth, tooltipHeight),

          // 2. Background Box (Rendered Second = On Top of Arrow)
          // FIX: Must use Clip.none to match Dashboard - no intermediate clipping
          // wrapper exists in Dashboard between arrow and body. Default Clip.hardEdge
          // was cutting the body's boxShadow and bottom decoration.
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Glassmorphism Layer
              if (glassEnabled)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                          sigmaX: glassBlur, sigmaY: glassBlur),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
              // Main Container
              Container(
                width: tooltipWidth,
                height: config['heightMode'] == 'custom' ? tooltipHeight : null,
                // FIX: No padding on Container — padding is applied inside via
                // Padding widget. This ensures the child Stack gets the FULL
                // Container dimensions as tight constraints (W × H), matching
                // the Dashboard where the body div clips at full bounds and
                // the inner div (at padding offset) contains the layers.
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  image: bgImageUrl != null && bgImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(bgImageUrl),
                          fit: () {
                            final size = config['backgroundSize']?.toString();
                            if (size == 'fill') return BoxFit.fill;
                            if (size == 'contain') return BoxFit.contain;
                            return BoxFit.cover;
                          }(),
                          alignment: () {
                            final pos =
                                config['backgroundPosition']?.toString() ??
                                    'center';
                            if (pos.contains('top') && pos.contains('left'))
                              return Alignment.topLeft;
                            if (pos.contains('top') && pos.contains('right'))
                              return Alignment.topRight;
                            if (pos.contains('bottom') && pos.contains('left'))
                              return Alignment.bottomLeft;
                            if (pos.contains('bottom') && pos.contains('right'))
                              return Alignment.bottomRight;
                            if (pos.contains('top')) return Alignment.topCenter;
                            if (pos.contains('bottom'))
                              return Alignment.bottomCenter;
                            if (pos.contains('left'))
                              return Alignment.centerLeft;
                            if (pos.contains('right'))
                              return Alignment.centerRight;
                            return Alignment.center;
                          }(),
                        )
                      : null,
                  boxShadow: shadowEnabled
                      ? [
                          BoxShadow(
                            color: shadowColor,
                            offset: Offset(shadowOffsetX, shadowOffsetY),
                            blurRadius: shadowBlur,
                            spreadRadius: shadowSpread,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                // Dashboard structure: body div (overflow:hidden) > inner div
                // (position:relative, padding offset, overflow:visible) > layers
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Layers
                      for (final layer in sortedLayers)
                        _buildLayer(
                          layer,
                          config,
                          scale,
                          scaleY,
                          // parentSize = content area (W-2P, H-2P)
                          // Matches Dashboard inner div: width/height 100%
                          // of body's content area (border-box)
                          Size(
                            (tooltipWidth ?? (280 * scale)) - padding * 2,
                            (config['heightMode'] == 'custom'
                                    ? tooltipHeight
                                    : (280 * scale)) -
                                padding * 2,
                          ),
                          screenSize,
                          rawLayers,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ARROW BUILDER - Dashboard's Arrow component
  // Matches Dashboard: rotated square positioned via CSS left/top/right/bottom
  // with percentage-based arrowPositionPercent and translateX/Y(-50%).
  // ============================================================================
  Widget _buildArrow(Map<String, dynamic> config, double scale,
      double? tooltipWidth, double tooltipHeight) {
    if (config['arrowEnabled'] == false) return const SizedBox.shrink();

    final arrowHeight = _safeDouble(config['arrowSize'], 10) * scale;
    final squareSize = arrowHeight * 1.4142;

    final bgColorStr = config['arrowColor']?.toString() ??
        config['backgroundColor']?.toString() ??
        '#1F2937';
    Color bgColor = parseColor(bgColorStr);

    // FIX: Sync arrow opacity with body to match Glassmorphism
    final double bgOpacity = _safeDouble(
        config['backgroundOpacity'], _safeDouble(config['opacity'], 1.0));
    if (bgOpacity < 1.0) {
      bgColor = bgColor.withOpacity(bgOpacity);
    }

    final pos = config['position']?.toString() ?? 'bottom';
    final arrowPosPercent = _safeDouble(config['arrowPositionPercent'], 50);
    final roundnessPercent = _safeDouble(config['arrowRoundness'], 0);
    final cornerRadius = (squareSize / 2) * (roundnessPercent / 100);

    // Glassmorphism
    final glassConfig =
        config['backdropFilter'] is Map ? config['backdropFilter'] : null;
    final glassEnabled = glassConfig?['enabled'] == true;
    final glassBlur = _safeDouble(glassConfig?['blur'], 10) * scale;

    final centerOffset = -squareSize / 2;

    // Effective tooltip dimensions for percentage-based positioning
    // Dashboard: CSS `left: arrowPosPercent%` is relative to the parent container
    // which IS the tooltip body. We must replicate this exactly.
    final effectiveWidth = tooltipWidth ?? (280 * scale);
    final effectiveHeight = tooltipHeight;

    // Build the rotated square widget (shared across all positions)
    Widget buildRotatedSquare(BorderRadius borderRadius) {
      return SizedBox(
        width: squareSize,
        height: squareSize,
        child: Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Stack(
            children: [
              if (glassEnabled)
                ClipRRect(
                  borderRadius: borderRadius,
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                        sigmaX: glassBlur, sigmaY: glassBlur),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: borderRadius,
                  boxShadow: config['shadowEnabled'] != false
                      ? [
                          const BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              blurRadius: 4)
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Position arrow using Positioned (matching Dashboard's CSS positioning)
    // Dashboard uses: left/top as % of parent + translateX/Y(-50%) to center
    // Flutter equivalent: calculate pixel offset, then subtract half squareSize
    switch (pos) {
      case 'bottom':
        // Arrow on TOP edge (pointing up)
        // Dashboard: top: centerOffset, left: `${arrowPosPercent}%`, translateX(-50%)
        final leftPx =
            (arrowPosPercent / 100) * effectiveWidth - squareSize / 2;
        return Positioned(
          top: centerOffset,
          left: leftPx,
          child: buildRotatedSquare(
            BorderRadius.only(topLeft: Radius.circular(cornerRadius)),
          ),
        );
      case 'top':
        // Arrow on BOTTOM edge (pointing down)
        // Dashboard: bottom: centerOffset, left: `${arrowPosPercent}%`, translateX(-50%)
        final leftPx =
            (arrowPosPercent / 100) * effectiveWidth - squareSize / 2;
        return Positioned(
          bottom: centerOffset,
          left: leftPx,
          child: buildRotatedSquare(
            BorderRadius.only(bottomRight: Radius.circular(cornerRadius)),
          ),
        );
      case 'left':
        // Arrow on RIGHT edge (pointing right)
        // Dashboard: right: centerOffset, top: `${arrowPosPercent}%`, translateY(-50%)
        final topPx =
            (arrowPosPercent / 100) * effectiveHeight - squareSize / 2;
        return Positioned(
          right: centerOffset,
          top: topPx,
          child: buildRotatedSquare(
            BorderRadius.only(topRight: Radius.circular(cornerRadius)),
          ),
        );
      case 'right':
        // Arrow on LEFT edge (pointing left)
        // Dashboard: left: centerOffset, top: `${arrowPosPercent}%`, translateY(-50%)
        final topPx =
            (arrowPosPercent / 100) * effectiveHeight - squareSize / 2;
        return Positioned(
          left: centerOffset,
          top: topPx,
          child: buildRotatedSquare(
            BorderRadius.only(bottomLeft: Radius.circular(cornerRadius)),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================================
  // LAYER BUILDER - Dashboard's renderLayer()
  // ============================================================================
  // Helper to parse Background Image from CSS style
  DecorationImage? _buildBackgroundImage(Map<String, dynamic> style) {
    var url = style['backgroundImage']?.toString();
    if (url == null || url.isEmpty || url == 'none') return null;

    // Handle CSS 'url(...)' format or raw URL
    if (url.startsWith('url(')) {
      url = url
          .substring(4, url.length - 1)
          .replaceAll('"', '')
          .replaceAll("'", "");
    }

    if (url.isEmpty) return null;

    // Parse Box Fit (background-size)
    final sizeStr = style['backgroundSize']?.toString() ?? 'cover';
    BoxFit fit = BoxFit.cover;
    if (sizeStr == 'contain') fit = BoxFit.contain;
    if (sizeStr == 'fill' || sizeStr == '100% 100%') fit = BoxFit.fill;

    // Parse Alignment (background-position) - Simplified common cases
    final posStr = style['backgroundPosition']?.toString() ?? 'center';
    Alignment alignment = Alignment.center;
    if (posStr.contains('top')) alignment = Alignment.topCenter;
    if (posStr.contains('bottom')) alignment = Alignment.bottomCenter;
    if (posStr.contains('left')) alignment = Alignment.centerLeft;
    if (posStr.contains('right')) alignment = Alignment.centerRight;
    // Combinations
    if (posStr.contains('top') && posStr.contains('left'))
      alignment = Alignment.topLeft;
    if (posStr.contains('top') && posStr.contains('right'))
      alignment = Alignment.topRight;
    if (posStr.contains('bottom') && posStr.contains('left'))
      alignment = Alignment.bottomLeft;
    if (posStr.contains('bottom') && posStr.contains('right'))
      alignment = Alignment.bottomRight;

    return DecorationImage(
      image: NetworkImage(url),
      fit: fit,
      alignment: alignment,
    );
  }

  // Helper to sort layers by z-index to match CSS stacking context
  List<Map<String, dynamic>> _sortLayersByZIndex(List<dynamic> layers) {
    final sorted = List<Map<String, dynamic>>.from(
        layers.map((l) => l as Map<String, dynamic>));
    sorted.sort((a, b) {
      final zA = (a['style']?['zIndex'] as num?)?.toInt() ?? 0;
      final zB = (b['style']?['zIndex'] as num?)?.toInt() ?? 0;
      return zA.compareTo(
          zB); // Lower Z renders first (bottom), Higher Z renders last (top)
    });
    return sorted;
  }

  // Helper to parse CSS box-shadow string (e.g., "0px 4px 10px rgba(0,0,0,0.5)")
  List<BoxShadow>? _parseBoxShadow(String? shadowStr, double scale) {
    if (shadowStr == null || shadowStr == 'none' || shadowStr.isEmpty)
      return null;
    try {
      // 1. Separate Color from Numbers
      String colorPart = '#000000'; // Default
      String numsPart = shadowStr;

      if (shadowStr.contains('rgba')) {
        final idx = shadowStr.indexOf('rgba');
        colorPart = shadowStr.substring(idx);
        numsPart = shadowStr.substring(0, idx);
      } else if (shadowStr.contains('rgb')) {
        final idx = shadowStr.indexOf('rgb');
        colorPart = shadowStr.substring(idx);
        numsPart = shadowStr.substring(0, idx);
      } else if (shadowStr.contains('#')) {
        final idx = shadowStr.indexOf('#');
        // Find end of hex (6 or 8 chars + #)
        final endIdx = shadowStr.indexOf(' ', idx);
        if (endIdx != -1) {
          colorPart = shadowStr.substring(idx, endIdx);
          numsPart = shadowStr.replaceRange(idx, endIdx, '');
        } else {
          colorPart = shadowStr.substring(idx);
          numsPart = shadowStr.substring(0, idx);
        }
      }

      // 2. Parse Numbers (x, y, blur, spread)
      final parts = numsPart
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList();
      double x = 0, y = 0, blur = 0, spread = 0;

      double parsePx(String s) => double.tryParse(s.replaceAll('px', '')) ?? 0;

      if (parts.isNotEmpty) x = parsePx(parts[0]);
      if (parts.length > 1) y = parsePx(parts[1]);
      if (parts.length > 2) blur = parsePx(parts[2]);
      if (parts.length > 3) spread = parsePx(parts[3]);

      return [
        BoxShadow(
          color: parseColor(colorPart),
          offset: Offset(x * scale, y * scale),
          blurRadius: blur * scale,
          spreadRadius: spread * scale,
        )
      ];
    } catch (e) {
      NinjaLog.d('AppNinja', 'Error parsing shadow: $shadowStr - $e');
      return null;
    }
  }

  // Helper to safely parse numbers from dynamic (String or num)
  double _safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Widget _buildLayer(
    Map<String, dynamic> layer,
    Map<String, dynamic> config,
    double scale,
    double scaleY,
    Size parentSize,
    Size scaleSize,
    List<dynamic>? allLayers, // FIX: For container child lookup
  ) {
    final type = layer['type']?.toString() ?? 'text';
    final style = (layer['style'] as Map<String, dynamic>?) ?? {};
    final visible = layer['visible'] != false;

    if (!visible) return const SizedBox.shrink();

    // === POSITION CALCULATION ===
    final leftVal = style['left'];
    final topVal = style['top'];

    double? left, top;

    // Left
    // Dashboard: toPercentX(val) = `${(num / 393) * 100}%` relative to container
    // This proportional formula works for BOTH fullscreen (parentSize=screen → px*scale)
    // and tooltip mode (parentSize=contentArea → proportional to body width)
    if (leftVal != null) {
      final str = leftVal.toString().trim();
      if (str.endsWith('%')) {
        final pct = double.tryParse(str.replaceAll('%', '')) ?? 0;
        left = (pct / 100) * parentSize.width;
      } else {
        final px = double.tryParse(str.replaceAll('px', '')) ?? 0;
        // Dashboard parity: toPercentX(px) = (px/393)*100% of parent width
        // Fullscreen: (px/393) * 393*scale = px*scale (unchanged)
        // Tooltip: (px/393) * contentWidth (proportional, matches dashboard)
        left = (px / kNinjaDesignWidth) * parentSize.width;
      }
    }

    // Top
    // Dashboard: toPercentY(val) = `${(num / 852) * 100}%` relative to container
    if (topVal != null) {
      final str = topVal.toString().trim();
      if (str.endsWith('%')) {
        final pct = double.tryParse(str.replaceAll('%', '')) ?? 0;
        top = (pct / 100) * parentSize.height;
      } else {
        final px = double.tryParse(str.replaceAll('px', '')) ?? 0;
        // Dashboard parity: toPercentY(px) = (px/852)*100% of parent height
        // Fullscreen: (px/852) * 852*scaleY = px*scaleY (matches dashboard)
        // Tooltip: (px/852) * contentHeight (proportional, matches dashboard)
        top = (px / kNinjaDesignHeight) * parentSize.height;
      }
    }

    // === SIZE CALCULATION ===
    final widthVal = style['width'] ?? layer['size']?['width'];
    final heightVal = style['height'] ?? layer['size']?['height'];

    // Scale factors
    // FIX: Use global screen scale for element sizing so they don't shrink in small tooltips
    final scaleX = scale;
    final scaleYVal = scaleY;

    double? width, height;

    // Width
    if (widthVal != null) {
      final str = widthVal.toString().trim();
      if (str.endsWith('%')) {
        final pct = double.tryParse(str.replaceAll('%', '')) ?? 0;
        // FIX: Root Containers use Screen Width (scaleSize) for % to avoid shrinking
        final resizeParentW =
            (type == 'container') ? scaleSize.width : parentSize.width;
        width = (pct / 100) * resizeParentW;
      } else if (str != 'auto') {
        final px = double.tryParse(str.replaceAll('px', '')) ?? 0;
        width = px * scaleX;
      }
    }

    // Height
    // FIX: React uses HEIGHT scale (scaleY) for height pixels
    // React: height: safeScale(..., scaleY)
    if (heightVal != null) {
      final str = heightVal.toString().trim();
      if (str.endsWith('%')) {
        final pct = double.tryParse(str.replaceAll('%', '')) ?? 0;
        // FIX: Root Containers use Screen Height (scaleSize) for % to avoid shrinking
        final resizeParentH =
            (type == 'container') ? scaleSize.height : parentSize.height;
        height = (pct / 100) * resizeParentH;
      } else if (str != 'auto') {
        final px = double.tryParse(str.replaceAll('px', '')) ?? 0;
        // React parity: height pixels use HEIGHT scale (scaleY)
        height = px * scaleYVal;
      }
    }

    // === STYLING ===
    final opacity = _safeDouble(style['opacity'], 1.0);

    // Background Color & Image
    final bgColorStr = style['backgroundColor']?.toString();
    final bgColor = bgColorStr != null ? parseColor(bgColorStr) : null;
    final bgImage = _buildBackgroundImage(style); // <--- NEW: Image Support

    // Border Radius
    final borderRadiusVal = (type == 'input' || type == 'copy_button')
        ? 0.0
        : _safeDouble(style['borderRadius']) * scaleX;

    // Border
    final borderStr = style['border']?.toString();
    BoxBorder? border;
    if (borderStr != null && borderStr != 'none') {
      final parts = borderStr.split(' ');
      if (parts.length >= 3) {
        final wStr = parts[0].replaceAll('px', '');
        final w = double.tryParse(wStr) ?? 1.0;
        final cStr = parts.sublist(2).join(' ');
        final c = parseColor(cStr);
        border = Border.all(color: c, width: w * scaleX);
      }
    }

    // Box Shadow
    final boxShadow = _parseBoxShadow(style['boxShadow']?.toString(), scaleX);

    // Overflow
    final overflow = layer['type'] == 'button'
        ? 'visible'
        : (style['overflow']?.toString() ?? 'hidden');
    final clipBehavior =
        (overflow == 'visible' || type == 'input' || type == 'copy_button')
            ? Clip.none
            : Clip.antiAlias;

    // === CONTENT ===
    Widget content;
    switch (type) {
      case 'custom_html':
        content = NinjaCustomHtmlLayer(
            layer: layer, 
            scale: scaleX,
            onAction: (action) => onCustomAction(action['name'] ?? action['type'] ?? '', action['payload'] ?? action)
        );
        break;
      case 'text':
        content = NinjaTextLayer(layer: layer, scale: scaleX);
        break;
      case 'button':
        content = NinjaButtonLayer(
          layer: layer,
          scale: scale, // FIX: Pass scale for container-relative sizing
          onAction: (action, data) => _handleAction(action, data),
        );
        break;
      case 'media':
      case 'image':
        content =
            NinjaImageLayer(layer: layer, parentSize: scaleSize, scale: scale);
        break;
      case 'lottie':
        content = NinjaLottieLayer(
          layer: layer,
          parentSize: scaleSize,
          scale: scale,
          onAction: (a, d) => _handleAction(a, d),
        );
        break;
      case 'rive':
        content = NinjaRiveLayer(
          layer: layer,
          parentSize: scaleSize,
          scale: scale,
          onAction: (a, d) => _handleAction(a, d),
        );
        break;
      case 'input':
        content = NinjaInputLayer(
          layer: layer,
          parentSize: scaleSize,
          onAction: (a, d) => _handleAction(a, d),
        );
        break;
      case 'copy_button':
        content = NinjaCopyButtonLayer(
          layer: layer,
          parentSize: scaleSize,
          onAction: (a, d) => _handleAction(a, d),
        );
        break;
      case 'container':
        // FIX: The Dashboard Tooltip recursively calls _buildLayer for container children,
        // placing them in absolute positions relative to the container bounds.
        content = NinjaContainerLayer(
          layer: layer,
          parentSize:
              Size(width ?? parentSize.width, height ?? parentSize.height),
          scaleSize: scaleSize,
          scale: scale,
          scaleY: scaleYVal,
          onAction: (action, data) => _handleAction(action, data),
          allLayers: allLayers,
          isRoot: true,
          // PARITY FIX: Dashboard Tooltip explicitly routes inner layers through its own render engine!
          renderChild: (child, {double? parentWidth, double? parentHeight}) =>
              _buildLayer(
                  child,
                  config,
                  scale,
                  scaleYVal,
                  Size(
                      parentWidth ?? width ?? parentSize.width,
                      parentHeight ??
                          height ??
                          parentSize.height), // Parent bounding box
                  scaleSize, // Global scale box
                  allLayers),
        );
        break;
      default:
        content = Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, style: BorderStyle.solid),
          ),
          child: Text('Unknown: $type'),
        );
    }

    // === WRAPPING ===
    final bool isContainer = type == 'container' || type == 'grid_item';

    Widget styledContent = Container(
      width: width,
      height: height,
      decoration: isContainer ? null : BoxDecoration(
        color: bgColor,
        image: bgImage, // <--- NEW: Apply Image
        borderRadius: BorderRadius.circular(borderRadiusVal),
        border: border,
        boxShadow: boxShadow,
      ),
      clipBehavior: isContainer ? Clip.none : clipBehavior,
      child: content,
    );

    // Opacity - REMOVED: Applied to background color directly to support Glassmorphism (preserving text opacity)
    /* 
    if (opacity < 1.0) {
      styledContent = Opacity(opacity: opacity, child: styledContent);
    } 
    */

    // Transform
    final rotateDeg = _safeDouble(style['rotate']);
    final scaleVal = _safeDouble(style['scale'], 1.0);
    final translateX = _safeDouble(style['translateX'], 0.0) * scaleX;
    final translateY = _safeDouble(style['translateY'], 0.0) * scaleYVal;

    if (rotateDeg != 0 ||
        scaleVal != 1.0 ||
        translateX != 0 ||
        translateY != 0) {
      styledContent = Transform(
        transform: Matrix4.identity()
          ..rotateZ(rotateDeg * pi / 180) // 1. Rotate
          ..scale(scaleVal, scaleVal) // 2. Scale
          ..translate(translateX, translateY), // 3. Translate
        alignment: Alignment.center,
        child: styledContent,
      );
    }

    return Positioned(
      left: left ?? 0,
      top: top ?? 0,
      width: width,
      height: height,
      child: styledContent,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  double? _getTooltipWidth(Map<String, dynamic> config, double scale) {
    // 1. If width is explicitly 'auto', return null to let Container size itself
    if (config['width'] == 'auto') return null;

    // 2. Determine Unit (Default to px)
    final widthUnit = config['widthUnit']?.toString() ?? 'px';

    // 3. Parse Width (Default to 280 if missing/invalid)
    final rawWidth = _safeDouble(config['width'], 280);

    // 4. Handle Percentage (Relative to Design Width)
    // Only apply percentage logic if mode is explicitly 'custom' AND unit is '%'
    final widthMode = config['widthMode']?.toString() ?? 'custom';
    if (widthMode == 'custom' && widthUnit == '%') {
      return (rawWidth / 100) * kNinjaDesignWidth * scale;
    }

    // 5. Default/Pixel Fallback (scaled)
    // Matches React: safeScale(config.width || 280, scale)
    // This catches missing widthMode, standard mode, or pixel units
    return rawWidth * scale;
  }

  double _getTooltipHeight(Map<String, dynamic> config, double scale,
      double scaleY, Size screenSize) {
    final heightMode = config['heightMode']?.toString() ?? 'auto';

    if (heightMode == 'custom') {
      final heightUnit = config['heightUnit']?.toString() ?? 'px';
      final rawHeight = _safeDouble(config['height'], 100);

      if (heightUnit == '%') {
        return (rawHeight / 100) * kNinjaDesignHeight * scaleY;
      }
      // FIX: Use 'scale' (Global Scale) for pixels to preserve aspect ratio (square stays square)
      return rawHeight * scale;
    }

    // Auto height - use screen height as fallback for scaling
    return screenSize.height;
  }
}

// ============================================================================
// CUSTOM PAINTERS
// ============================================================================

class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double borderRadius;
  final Color overlayColor;

  _SpotlightPainter({
    required this.targetRect,
    required this.borderRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    // Draw full screen
    final fullScreen = Path()..addRect(Offset.zero & size);

    // Cut out the spotlight
    final spotlight = Path()
      ..addRRect(
        RRect.fromRectAndRadius(targetRect, Radius.circular(borderRadius)),
      );

    // Combine paths
    final combined =
        Path.combine(PathOperation.difference, fullScreen, spotlight);

    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        overlayColor != oldDelegate.overlayColor ||
        borderRadius != oldDelegate.borderRadius;
  }
}

class _WaveConfig {
  final String origin;
  final double coverage;
  final double curvature;
  final bool waveFitToHeight;
  final double scale;
  final double scaleY;
  final Size screenSize;

  _WaveConfig({
    required this.origin,
    required this.coverage,
    required this.curvature,
    required this.waveFitToHeight,
    required this.scale,
    required this.scaleY,
    required this.screenSize,
  });
}

class _RingConfig {
  final String shape;
  final double width;
  final Color color;
  final double gap;
  final int count;
  final double radius;
  final double arcPercent;
  final double arcStartAngle;

  _RingConfig({
    required this.shape,
    required this.width,
    required this.color,
    required this.gap,
    required this.count,
    required this.radius,
    required this.arcPercent,
    required this.arcStartAngle,
  });
}

class _CoachmarkPainter extends CustomPainter {
  final Rect spotlightRect;
  final double spotlightRadius;
  final Color overlayColor;
  final double blur;
  final String coachmarkShape;
  final _WaveConfig? waveConfig;
  final _RingConfig? ringConfig;

  _CoachmarkPainter({
    required this.spotlightRect,
    required this.spotlightRadius,
    required this.overlayColor,
    required this.blur,
    required this.coachmarkShape,
    this.waveConfig,
    this.ringConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Create paint with blur if enabled
    final paint = Paint()..color = overlayColor;
    if (blur > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }

    // 2. Create base overlay path
    Path overlayPath;

    if (coachmarkShape == 'wave' && waveConfig != null) {
      overlayPath = _createWavePath(size);
    } else {
      overlayPath = Path()..addRect(Offset.zero & size);
    }

    // 3. Create spotlight cutout
    final spotlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
            spotlightRect, Radius.circular(spotlightRadius)),
      );

    // 4. Combine paths (Difference = Cutout)
    final combined =
        Path.combine(PathOperation.difference, overlayPath, spotlightPath);

    canvas.drawPath(combined, paint);

    // 5. Draw rings if enabled (on top of blur)
    if (ringConfig != null) {
      _drawRings(canvas, size);
    }
  }

  Path _createWavePath(Size size) {
    if (waveConfig == null) return Path()..addRect(Offset.zero & size);

    final screenW = kNinjaDesignWidth * waveConfig!.scale;
    final screenH = kNinjaDesignHeight * waveConfig!.scale;
    final designHeight = kNinjaDesignHeight *
        (waveConfig!.waveFitToHeight ? waveConfig!.scaleY : waveConfig!.scale);
    final curve = waveConfig!.curvature;
    final coverage = waveConfig!.coverage;

    final path = Path();

    switch (waveConfig!.origin) {
      case 'bottom':
        // Anchor to DESIGN TOP vs REAL BOTTOM to avoid drift
        final waveY = designHeight * (1 - coverage);
        final anchorBottom = max(screenH, 4000.0);
        path.moveTo(0, anchorBottom);
        path.lineTo(0, waveY);
        path.quadraticBezierTo(screenW / 2, waveY - curve, screenW, waveY);
        path.lineTo(screenW, anchorBottom);
        path.close();
        break;

      case 'top':
        final waveY = designHeight * coverage;
        path.moveTo(0, 0);
        path.lineTo(0, waveY);
        path.quadraticBezierTo(screenW / 2, waveY + curve, screenW, waveY);
        path.lineTo(screenW, 0);
        path.close();
        break;

      case 'left':
        final waveX = screenW * coverage;
        path.moveTo(0, 0);
        path.lineTo(waveX, 0);
        path.quadraticBezierTo(waveX + curve, screenH / 2, waveX, screenH);
        path.lineTo(0, screenH);
        path.close();
        break;

      case 'right':
        final waveX = screenW * (1 - coverage);
        path.moveTo(screenW, 0);
        path.lineTo(waveX, 0);
        path.quadraticBezierTo(waveX - curve, screenH / 2, waveX, screenH);
        path.lineTo(screenW, screenH);
        path.close();
        break;

      case 'top-left':
        final w = screenW * coverage;
        final h = designHeight * coverage;
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.quadraticBezierTo(w + curve, h + curve, 0, h);
        path.close();
        break;

      case 'top-right':
        final w = screenW * (1 - coverage);
        final h = designHeight * coverage;
        path.moveTo(screenW, 0);
        path.lineTo(screenW, h);
        path.quadraticBezierTo(w - curve, h + curve, w, 0);
        path.close();
        break;

      case 'bottom-left':
        final w = screenW * coverage;
        final h = designHeight * (1 - coverage);
        final anchorBottom = max(screenH, 4000.0);
        path.moveTo(0, anchorBottom);
        path.lineTo(0, h);
        path.quadraticBezierTo(w + curve, h - curve, w, anchorBottom);
        path.close();
        break;

      case 'bottom-right':
        final w = screenW * (1 - coverage);
        final h = designHeight * (1 - coverage);
        final anchorBottom = max(screenH, 4000.0);
        path.moveTo(screenW, anchorBottom);
        path.lineTo(w, anchorBottom);
        path.quadraticBezierTo(w - curve, h - curve, screenW, h);
        path.close();
        break;

      default:
        path.addRect(Offset.zero & size);
    }

    return path;
  }

  void _drawRings(Canvas canvas, Size size) {
    if (ringConfig == null) return;

    final paint = Paint()
      ..color = ringConfig!.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringConfig!.width;

    final cx = spotlightRect.center.dx;
    final cy = spotlightRect.center.dy;

    // Parity Fix: Opacity step depends on shape
    final opacityStep = ringConfig!.shape == 'rectangle' ? 0.2 : 0.15;

    for (int i = 0; i < ringConfig!.count; i++) {
      final opacity = (0.8 - (i * opacityStep)).clamp(0.0, 1.0);
      paint.color = ringConfig!.color.withOpacity(opacity);

      if (ringConfig!.shape == 'circle') {
        final radius =
            ringConfig!.radius + i * (ringConfig!.width + ringConfig!.gap);

        if (ringConfig!.arcPercent >= 100) {
          canvas.drawCircle(Offset(cx, cy), radius, paint);
        } else {
          // Partial arc logic
          final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
          final startAngle = ((ringConfig!.arcStartAngle - 90) * pi) / 180;
          final sweepAngle = ((ringConfig!.arcPercent / 100) * 360 * pi) / 180;
          canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
        }
      } else {
        final innerEdgeOffset =
            ringConfig!.gap + i * (ringConfig!.width + ringConfig!.gap);
        final rectEdgeOffset = innerEdgeOffset + ringConfig!.width / 2;

        final rW = spotlightRect.width + rectEdgeOffset * 2;
        final rH = spotlightRect.height + rectEdgeOffset * 2;
        final rX = spotlightRect.left - rectEdgeOffset;
        final rY = spotlightRect.top - rectEdgeOffset;

        final maxRingRx = min(rW, rH) / 2;
        final ringRx = min(spotlightRadius + rectEdgeOffset, maxRingRx);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(rX, rY, rW, rH),
            Radius.circular(ringRx),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CoachmarkPainter oldDelegate) {
    return spotlightRect != oldDelegate.spotlightRect ||
        overlayColor != oldDelegate.overlayColor ||
        coachmarkShape != oldDelegate.coachmarkShape;
  }
}
