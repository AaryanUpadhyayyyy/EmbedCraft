import 'package:flutter/material.dart';
import 'dart:ui'; // For PathMetric
import 'ninja_layer_utils.dart';
import '../../app_ninja.dart'; // For AppNinja.triggerSpin()
import '../../utils/ninja_logger.dart';

class NinjaButtonLayer extends StatelessWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale; // FIX: Container-relative scale factor
  final Function(String action, Map<String, dynamic> data)? onAction;

  const NinjaButtonLayer({
    Key? key, 
    required this.layer, 
    this.parentSize, 
    this.scale = 1.0, // Default to 1.0 for backwards compatibility
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NinjaLog.d('ButtonLayer', "NinjaButtonLayer: Building button ${layer['id']}");
    final content = layer['content'] as Map<String, dynamic>? ?? {};
    final style = layer['style'] as Map<String, dynamic>? ?? {};

    // 1. Content
    // FIX: React only uses 'label', not 'text' fallback
    final text = NinjaLayerUtils.resolveText(content['label']?.toString() ?? 'Button');
    final iconName = content['buttonIcon'] as String?;
    final iconPosition = content['buttonIconPosition'] as String? ?? 'right';
    
    // 2. Core Styles
    // FIX: Use passed scale parameter instead of screen-based parseDouble
    final fontSizeRaw = NinjaLayerUtils.parseDouble(content['fontSize']) ?? NinjaLayerUtils.parseDouble(style['fontSize']) ?? 14.0;
    final fontSize = fontSizeRaw * scale;
    // Map string weight to FontWeight
    // FIX: Priority content > style (React Parity)
    final fontWeightStr = (content['fontWeight'] ?? style['fontWeight'])?.toString();
    // FIX: Default to w500 (Medium) matching React
    final fontWeight = NinjaLayerUtils.parseFontWeight(fontWeightStr) ?? FontWeight.w500;

    // FIX: Theme Color Priority: style > content > Default Indigo (React Parity)
    final themeColor = NinjaLayerUtils.parseColor(style['backgroundColor']) ?? 
                       NinjaLayerUtils.parseColor(content['themeColor']) ?? 
                       const Color(0xFF6366F1); // Indigo 
    var textColor = NinjaLayerUtils.parseColor(content['textColor']) ?? Colors.white;
    
    // Decoration
    // Decoration
    var bgColor = NinjaLayerUtils.parseColor(style['backgroundColor']) ?? themeColor;
    // FIX: Use scale parameter for container-relative sizing
    final radiusRaw = NinjaLayerUtils.parseDouble(style['borderRadius']) ?? 8.0;
    final radius = radiusRaw * scale;
    final borderWidthRaw = NinjaLayerUtils.parseDouble(style['borderWidth']);
    var borderWidth = borderWidthRaw != null ? borderWidthRaw * scale : null;
    var borderColor = NinjaLayerUtils.parseColor(style['borderColor']);

    // VARIANT LOGIC (Matches React ButtonRenderer)
    final variant = content['buttonVariant']?.toString() ?? 'primary';
    
    switch (variant) {
      case 'secondary':
        // Secondary: ThemeColor BG with 20% opacity, ThemeColor Text
        // Only override if style.backgroundColor is NOT explicitly set
        if (style['backgroundColor'] == null) {
          bgColor = themeColor.withOpacity(0.125); // FIX: Hex 20 is approx 12.5% (Match React)
        }
        textColor = themeColor; // Ensure text matches theme
        break;
      case 'outline':
        // Outline: Transparent BG, ThemeColor Text, 2px Border
        if (style['backgroundColor'] == null) {
          bgColor = Colors.transparent;
        }
        textColor = themeColor;
        
        // Force border width if undefined
        if (borderWidth == null) {
           borderWidth = NinjaLayerUtils.parseDouble(2, context); 
        }
        
        // Default border color to theme if undefined
        borderColor ??= themeColor;
        break;
      case 'ghost':
        // Ghost: Transparent BG, ThemeColor Text
        if (style['backgroundColor'] == null) {
          bgColor = Colors.transparent;
        }
        textColor = themeColor;
        break;
      case 'primary':
      default:
        // Primary: ThemeColor BG (already set as default), White Text (default)
        break;
    }
    
    // Finalize defaults after variant logic
    final double resolvedBorderWidth = borderWidth ?? 0.0;
    final Color resolvedBorderColor = borderColor ?? Colors.transparent;

    // Offsets — FIX: Use container-relative scaling (× scale) matching Dashboard's safeScale(val, scale)
    // Dashboard uses safeScale(textOffsetX, scale) for BOTH X and Y — NOT screen-based.
    final textOffsetX = (NinjaLayerUtils.parseDouble(style['textOffsetX']) ?? 0.0) * scale;
    final textOffsetY = (NinjaLayerUtils.parseDouble(style['textOffsetY']) ?? 0.0) * scale;
    final iconOffsetX = (NinjaLayerUtils.parseDouble(style['iconOffsetX']) ?? 0.0) * scale;
    final iconOffsetY = (NinjaLayerUtils.parseDouble(style['iconOffsetY']) ?? 0.0) * scale;

    // Common

    return LayoutBuilder(
      builder: (context, constraints) {
        // DASHBOARD PARITY: Button fills 100% of its positioned container
        // Width/Height are applied at Positioned level in NinjaLayerBuilder
        // This matches Dashboard's ButtonRenderer which uses width: '100%', height: '100%'

        // 3. Handle Padding (Parity Logic: padding is fallback, granular overrides win)
        final pDefault = NinjaLayerUtils.parseDouble(style['padding'], context) ?? 0.0;
        
        // Note: NinjaLayerUtils.parsePadding uses padding if present, but we need granular overrides.
        // If paddingTop is set, use it. If not, use paddingVertical. If not, use padding (as number).
        // Wait, 'padding' can be a map or number in React.
        // Let's implement the React logic exactly:
        // pTop = layer.style?.paddingTop ?? layer.style?.paddingVertical ?? (layer.style?.padding != null ? layer.style.padding : 10);
        
        final rawPadding = style['padding'];
        double? genericPadding;
        if (rawPadding is num) genericPadding = rawPadding.toDouble();
        if (genericPadding == null && rawPadding != null) {
            // FIX: Parse without context for container-relative scaling
            genericPadding = NinjaLayerUtils.parseDouble(rawPadding);
        }
        
        // FIX: Default padding to 0 — explicit padding is always saved by ButtonEditor.
        // The 10/12 in dashboard ButtonRenderer.tsx are fallbacks for unsaved layers only.
        // In production, paddingVertical/paddingHorizontal are ALWAYS in the API data.
        final pTopRaw = NinjaLayerUtils.parseDouble(style['paddingTop'] ?? style['paddingVertical']) ?? genericPadding ?? 0.0;
        final pRightRaw = NinjaLayerUtils.parseDouble(style['paddingRight'] ?? style['paddingHorizontal']) ?? genericPadding ?? 0.0;
        final pBottomRaw = NinjaLayerUtils.parseDouble(style['paddingBottom'] ?? style['paddingVertical']) ?? genericPadding ?? 0.0;
        final pLeftRaw = NinjaLayerUtils.parseDouble(style['paddingLeft'] ?? style['paddingHorizontal']) ?? genericPadding ?? 0.0;
        
        final finalPTop = pTopRaw * scale;
        final finalPRight = pRightRaw * scale;
        final finalPBottom = pBottomRaw * scale;
        final finalPLeft = pLeftRaw * scale;

        // Check for Dashed/Dotted Border
        final borderStyle = style['borderStyle']?.toString().toLowerCase();
        final isDashed = borderStyle == 'dashed' || borderStyle == 'dotted';
        
        // FIX: Do NOT add borderWidth to padding.
        // In CSS box-sizing: border-box, the content area can be 0px but text still renders
        // (overflow: visible + flex centering). In Flutter, adding borderWidth to padding
        // CONSTRAINS the child to 0px, hiding the text entirely.
        // Flutter's BoxDecoration border is painted (not laid out), so padding alone is correct.
        final effectivePadding = EdgeInsets.only(
             top: finalPTop, 
             right: finalPRight, 
             bottom: finalPBottom, 
             left: finalPLeft
        );

        // Font Family Resolution (FIX: Content > Style > Inherit)
        String? fontFamily = (content['fontFamily'] as String?) ?? (style['fontFamily'] as String?) ?? 'inherit';
        final fontUrl = content['fontUrl'] as String?;
        if (fontUrl != null && fontUrl.isNotEmpty) {
           final urlFamily = NinjaLayerUtils.getFontFamilyFromUrl(fontUrl);
           if (urlFamily != null) fontFamily = urlFamily;
        }

        TextStyle textStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          // FIX: React uses lineHeight: 1
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.proportional, // Web Parity
          // FIX: Dashboard ButtonRenderer sets NO letterSpacing — removed phantom 0.4*scale
        );

        if (fontFamily == 'inherit') {
           // FIX: Default to 'Inter' for web parity
           final googleFont = NinjaLayerUtils.getGoogleFont('Inter', textStyle: textStyle);
           if (googleFont != null) {
              textStyle = googleFont;
           } else {
              textStyle = textStyle.copyWith(fontFamily: 'Inter'); 
           }
        } else {
           final googleFont = NinjaLayerUtils.getGoogleFont(fontFamily, textStyle: textStyle);
           if (googleFont != null) {
              textStyle = googleFont;
           } else {
              textStyle = textStyle.copyWith(fontFamily: fontFamily);
           }
        }

        // Content Widgets
        Widget textWidget = Transform.translate(
            offset: Offset(textOffsetX, textOffsetY),
            child: Text(
                text,
                style: textStyle,
                textAlign: TextAlign.center,
                softWrap: false, // Prevent wrapping
                overflow: TextOverflow.visible,
                textScaler: TextScaler.noScaling, // FIX: Prevent OS text scaling
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
            ),
        );

        Widget? iconWidget;
        if (iconName != null && iconName.isNotEmpty) {
             iconWidget = Transform.translate(
                offset: Offset(iconOffsetX, iconOffsetY),
                child: _buildIcon(iconName, textStyle.color ?? Colors.white),
             );
        }

        List<Widget> children = [];
        if (iconPosition == 'left') {
             if (iconWidget != null) {
                 children.add(iconWidget);
                 children.add(const SizedBox(width: 8.0)); // FIX: Fixed 8px gap (Unscaled)
             }
             children.add(textWidget);
        } else {
             children.add(textWidget);
             if (iconWidget != null) {
                 children.add(const SizedBox(width: 8.0)); // FIX: Fixed 8px gap (Unscaled)
                 children.add(iconWidget);
             }
        }

        // DASHBOARD PARITY: Fill parent if constrained, otherwise use intrinsic size
        // This prevents crashes when Positioned has no explicit dimensions
        final hasWidthConstraint = constraints.hasBoundedWidth && constraints.maxWidth != double.infinity;
        final hasHeightConstraint = constraints.hasBoundedHeight && constraints.maxHeight != double.infinity;
        
        // Shared Decoration (Shadow will be separate to avoid clipping)
        final innerDecoration = BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          // Use standard border ONLY if not dashed/dotted AND not none
          border: (resolvedBorderWidth > 0 && !isDashed && borderStyle != 'none')
             ? Border.all(color: resolvedBorderColor, width: resolvedBorderWidth) 
             : null,
          // BoxShadow moved to OUTER wrapper to avoid Material clipping
        );
        
        // Shadow Decoration (for outer wrapper)
        // FIX: Always construct shadow manually to ensure values are scaled (Utils might not scale)
        final shadowDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: style['shadowEnabled'] == true 
              ? [
                  BoxShadow(
                    color: NinjaLayerUtils.parseColor(style['shadowColor']) ?? Colors.black, 
                    blurRadius: NinjaLayerUtils.parseDouble(style['shadowBlur'], context) ?? 0.0,
                    offset: Offset(0, NinjaLayerUtils.parseDouble(style['shadowOffsetY'] ?? 4, context) ?? 4.0),
                    spreadRadius: NinjaLayerUtils.parseDouble(style['shadowSpread'], context) ?? 0.0,
                  )
                ]
              : null,
        );

        Widget buttonContent = Container(
           padding: effectivePadding, // Padding stays inside
           // FIX: Center content vertically when parent constrains height
           alignment: Alignment.center,
           child: FittedBox(
               fit: BoxFit.scaleDown,
               child: Row(
                  mainAxisSize: hasWidthConstraint ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
               ),
           ),
        );

        Widget buttonContainer;

        // FIX: Button ALWAYS renders with Ripple (Parity with React's <button>)
        // Structure: Container(Shadow) -> Material -> Ink(BG+Border) -> InkWell(Ripple) -> Content
        // Shadow is on the OUTER container so it is NOT clipped by Material.
        
        // Determine action callback (empty if no action configured)
        VoidCallback? tapCallback;
        if (content['action'] != null) {
           final actionStr = content['action'] is Map ? content['action']['type'] : content['action'].toString();
           tapCallback = () {
             // Parity: React dispatches window.dispatchEvent(new CustomEvent('spinTheWheel'))
             // when a button has action.type='spin_wheel'. Flutter equivalent: AppNinja.triggerSpin()
             if (actionStr == 'spin_wheel') {
               AppNinja.triggerSpin();
               return; // Do NOT close/dismiss — just spin
             }
             if (onAction != null) {
               if (content['action'] is Map) {
                  onAction!(actionStr, content['action']);
               } else {
                  onAction!(actionStr, {});
               }
             }
           };
        }
        
        // Always use Material/Ink/InkWell for consistent visual behavior (always ripples)
        Widget innerWidget = Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: innerDecoration, // BG + Border only
            width: hasWidthConstraint ? double.infinity : null,
            height: hasHeightConstraint ? double.infinity : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius), // Clip ripple
              // FIX: Always provide onTap (even empty) so InkWell shows ripple like web <button>
              onTap: tapCallback ?? () {},
              child: buttonContent,
            ),
          ),
        );
        
        // Wrap with Shadow Container
        buttonContainer = Container(
          decoration: shadowDecoration, // Shadow applied here - NOT clipped
          child: innerWidget,
        );

        // Wrap with CustomPaint if Dashed/Dotted
        if (isDashed && resolvedBorderWidth > 0) {
           return CustomPaint(
             // FIX: Use foregroundPainter so border draws ON TOP of background
             foregroundPainter: _DashedBorderPainter(
               color: resolvedBorderColor,
               strokeWidth: resolvedBorderWidth,
               radius: radius,
               borderStyle: borderStyle ?? 'dashed',
               // FIX: 3:2 ratio for cleaner CSS look (dashWidth:gapWidth)
               gap: borderStyle == 'dotted' ? (resolvedBorderWidth * 2) : (resolvedBorderWidth * 3),
             ),
             child: buttonContainer,
           );
        }
        
        return buttonContainer;
      }
    );
  }

  Widget _buildIcon(String iconName, Color color) {
    IconData iconData;
    switch (iconName) {
      case 'ArrowRight': iconData = Icons.arrow_forward; break;
      case 'ArrowLeft': iconData = Icons.arrow_back; break;
      case 'Play': iconData = Icons.play_arrow; break;
      case 'Search': iconData = Icons.search; break;
      case 'Home': iconData = Icons.home; break;
      case 'Check': iconData = Icons.check; break;
      case 'X': iconData = Icons.close; break;
      case 'Download': iconData = Icons.download; break;
      case 'Upload': iconData = Icons.upload; break;
      case 'User': iconData = Icons.person; break;
      case 'Settings': iconData = Icons.settings; break;
      default: return const SizedBox.shrink();
    }
    
    // Dashboard icons are fixed 16px (NOT scaled via safeScale). Container sizing handles proportions.
    return Icon(iconData, color: color, size: 16);
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double gap;
  final String borderStyle;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    this.gap = 5.0,
    this.borderStyle = 'dashed',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isDotted = borderStyle == 'dotted';
    
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = isDotted ? StrokeCap.round : StrokeCap.butt; // FIX: Butt for dashed, Round for dotted

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    
    final Path dashedPath = Path();
    
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      
      while (distance < metric.length) {
        if (isDotted) {
          // FIX: For dotted, we "extract" a tiny path of 0.1 length with round caps to make it a circle
          dashedPath.addPath(
            metric.extractPath(distance, distance + 0.1),
            Offset.zero,
          );
          // For dotted, gap is the distance between dots
          distance += gap + strokeWidth;
        } else {
          // Standard dashed logic
          dashedPath.addPath(
            metric.extractPath(distance, distance + gap),
            Offset.zero,
          );
          distance += gap * 2; // Dash + Gap
        }
      }
    }
    
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
           strokeWidth != oldDelegate.strokeWidth ||
           radius != oldDelegate.radius ||
           gap != oldDelegate.gap ||
           borderStyle != oldDelegate.borderStyle;
  }
}
