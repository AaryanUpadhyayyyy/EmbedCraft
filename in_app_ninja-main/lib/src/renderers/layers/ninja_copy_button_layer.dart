import 'package:flutter/material.dart';
import 'dart:ui'; // For PathMetric
import 'package:flutter/services.dart';
import '../../utils/ninja_sdk_safe.dart';
import 'ninja_layer_utils.dart';
import '../../utils/ninja_logger.dart';

class NinjaCopyButtonLayer extends StatelessWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(String action, Map<String, dynamic> data)? onAction;

  const NinjaCopyButtonLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scale = 1.0,
    this.onAction,
  }) : super(key: key);

  void _handleCopy(BuildContext context, String text, bool showToast, String? message) {
    ninjaSdkSafeUnawaited(
      Clipboard.setData(ClipboardData(text: text)).then((_) {
        NinjaLog.d('AppNinja', "Copied to clipboard: $text");
        if (showToast && message != null) {
          try {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(message), 
                 duration: const Duration(seconds: 2),
                 behavior: SnackBarBehavior.floating,
               )
             );
          } catch (e) {
            NinjaLog.d('AppNinja', "Could not show toast: $e");
          }
        }
      }),
      context: 'NinjaCopyButtonLayer Clipboard.setData',
    );
  }

  @override
  Widget build(BuildContext context) {
    NinjaLog.d('AppNinja', "NinjaCopyButtonLayer: Building copy button ${layer['id']}");
    final content = layer['content'] as Map<String, dynamic>? ?? {};
    final style = layer['style'] as Map<String, dynamic>? ?? {};

    // --- Style Properties ---
    // Typography
    // FIX: Use scale for font size (React Parity) - Removed context to prevent double scaling
    final fontSizeRaw = NinjaLayerUtils.parseDouble(style['fontSize']);
    final fontSize = ((fontSizeRaw == null || fontSizeRaw == 0) ? 14.0 : fontSizeRaw) * scale;
    
    // FIX: Default to w500 (Medium) matching NinjaButtonLayer
    final fontWeight = NinjaLayerUtils.parseFontWeight(style['fontWeight']?.toString()) ?? FontWeight.w500;
    final textColor = NinjaLayerUtils.parseColor(content['textColor']) ?? Colors.black;
    
    // FIX: Font Family Resolution (Content > Style > Inherit)
    String? fontFamily = (content['fontFamily'] as String?)?.trim() ?? (style['fontFamily'] as String?)?.trim() ?? 'inherit';

    // Decoration
    final backgroundColor = NinjaLayerUtils.parseColor(style['backgroundColor']) ?? Colors.transparent;
    final borderColor = NinjaLayerUtils.parseColor(style['borderColor']) ?? const Color(0xFFD1D5DB); // Default gray
    
    final borderWidthRaw = NinjaLayerUtils.parseDouble(style['borderWidth'] ?? 1);
    final borderWidth = (borderWidthRaw ?? 1.0) * scale;
    
    final borderRadiusRaw = NinjaLayerUtils.parseDouble(style['borderRadius'] ?? 6);
    final borderRadiusVal = (borderRadiusRaw ?? 6.0) * scale;
    
    final borderStyle = style['borderStyle']?.toString().toLowerCase() ?? 'solid';
    final isDashed = borderStyle == 'dashed' || borderStyle == 'dotted';

    // Shadows
    List<BoxShadow>? shadows;
    if (style['shadowEnabled'] == true) {
       final color = NinjaLayerUtils.parseColor(style['shadowColor']) ?? Colors.black;
       final blur = (NinjaLayerUtils.parseDouble(style['shadowBlur']) ?? 0.0) * scale;
       final spread = (NinjaLayerUtils.parseDouble(style['shadowSpread']) ?? 0.0) * scale;
       final offsetY = (NinjaLayerUtils.parseDouble(style['shadowOffsetY'] ?? 4) ?? 4.0) * scale;
       
       shadows = [
         BoxShadow(
           color: color,
           offset: Offset(0, offsetY),
           blurRadius: blur,
           spreadRadius: spread,
         )
       ];
    } else {
       // Note: NinjaLayerUtils.parseShadows might not be scale-aware. 
       // For MVP parity with existing util usage, we leave as is if not explicit style.
       shadows = NinjaLayerUtils.parseShadows(style['boxShadow'], context);
    }

    // Padding Logic (Matches NinjaButtonLayer & React Parity)
    final rawPadding = style['padding'];
    double? genericPadding;
    if (rawPadding is num) genericPadding = rawPadding.toDouble();
    if (genericPadding == null && rawPadding != null) {
        genericPadding = NinjaLayerUtils.parseDouble(rawPadding);
    }
    
    // React code: pRight defaults to 0 if 'padding' undefined. 
    // const pRight = ... (style.padding !== undefined ? style.padding : 0);
    final defaultSidePadding = (genericPadding == null && style['padding'] == null) ? 0.0 : 0.0;
    
    final pTopRaw = NinjaLayerUtils.parseDouble(style['paddingTop'] ?? style['paddingVertical']) ?? genericPadding ?? 0.0; 
    final pRightRaw = NinjaLayerUtils.parseDouble(style['paddingRight'] ?? style['paddingHorizontal']) ?? genericPadding ?? defaultSidePadding;
    final pBottomRaw = NinjaLayerUtils.parseDouble(style['paddingBottom'] ?? style['paddingVertical']) ?? genericPadding ?? 0.0;
    final pLeftRaw = NinjaLayerUtils.parseDouble(style['paddingLeft'] ?? style['paddingHorizontal']) ?? genericPadding ?? defaultSidePadding;

    // Apply Scale
    final pTop = pTopRaw * scale;
    final pRight = pRightRaw * scale;
    final pBottom = pBottomRaw * scale;
    final pLeft = pLeftRaw * scale;
    
    // Border Width Adjustment for Box Model Parity
    final double actualBorderWidth = (borderWidth > 0 && borderStyle != 'none') ? borderWidth : 0.0;
    final effectivePadding = EdgeInsets.only(
         top: pTop + actualBorderWidth, 
         right: pRight + actualBorderWidth, 
         bottom: pBottom + actualBorderWidth, 
         left: pLeft + actualBorderWidth
    );

    // Offsets (Scaled)
    final textOffsetX = (NinjaLayerUtils.parseDouble(style['textOffsetX'], context, false) ?? 0.0) * scale;
    final textOffsetY = (NinjaLayerUtils.parseDouble(style['textOffsetY'], context, true) ?? 0.0) * scale;
    final iconOffsetX = (NinjaLayerUtils.parseDouble(style['iconOffsetX'], context, false) ?? 0.0) * scale;
    final iconOffsetY = (NinjaLayerUtils.parseDouble(style['iconOffsetY'], context, true) ?? 0.0) * scale;

    // Content
    final rawCopyText = (content['copyText'] ?? content['valueToCopy']) as String?;
    final resolvedCopyText = rawCopyText != null ? NinjaLayerUtils.resolveText(rawCopyText) : '';
    final displayText = resolvedCopyText.isNotEmpty ? resolvedCopyText : 'Copy Code';
    final showToast = content['showToast'] == true;
    final rawToast = content['toastMessage'] as String?;
    final resolvedToast = rawToast != null ? NinjaLayerUtils.resolveText(rawToast) : '';
    final toastMessage = resolvedToast.isNotEmpty ? resolvedToast : 'Copied to clipboard!';
    final triggerMode = content['copyTrigger'] ?? 'anywhere'; // 'anywhere' | 'icon'
    
    // Icon
    final iconName = content['copyIcon'] as String? ?? 'Copy';
    IconData iconData;
    switch (iconName) {
      // Copy Specific
      // FIX: React Editor shows 'Layout' icon for 'Clipboard' option. 
      // We aligned React Renderer to use Layout. Now SDK must match.
      case 'Clipboard': iconData = Icons.dashboard_outlined; break;
      case 'FileText': iconData = Icons.description_outlined; break;
      case 'Link': iconData = Icons.link; break;
      case 'Share': iconData = Icons.share_outlined; break;
      // Generic (Button Parity)
      case 'ArrowRight': iconData = Icons.arrow_forward; break;
      case 'ArrowLeft': iconData = Icons.arrow_back; break;
      case 'Play': iconData = Icons.play_arrow; break;
      case 'Search': iconData = Icons.search; break;
      case 'Home': iconData = Icons.home; break;
      case 'X': iconData = Icons.close; break;
      case 'Download': iconData = Icons.download; break;
      case 'Upload': iconData = Icons.upload; break;
      case 'User': iconData = Icons.person; break;
      case 'Settings': iconData = Icons.settings; break;
      // Common
      case 'Check': iconData = Icons.check; break;
      case 'Copy': 
      default: iconData = Icons.copy_outlined; break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
         // Resolve Dimensions
         var width = NinjaLayerUtils.parseResponsiveSize(
           style['width'], context, isVertical: false, constraints: constraints, parentSize: parentSize
         );
         
         // Fix: Auto Width Behavior
         // If width is null (auto), check if we should expand or shrink.
         // In Dashboard (Flex Column), 'auto' width typically means 'stretch' (100%) if alignItems is stretch (default).
         // However, LayoutBuilder might give us loose constraints.
         // If we are unbounded, 'auto' means Intrinsic (shrink wrap).
         // If we are bounded (stretch), 'auto' means fill.
         if (width == null) {
            if (constraints.hasBoundedWidth && constraints.maxWidth != double.infinity) {
               // We are in a bounded container (e.g. stretch alignment). 
               // Default behavior for Block/Flex item is to fill width.
               width = constraints.maxWidth;
            } else {
               // Unbounded (e.g. center/start alignment). Shrink wrap.
               width = null; 
            }
         }

         var height = NinjaLayerUtils.parseResponsiveSize(
           style['height'], context, isVertical: true, constraints: constraints, parentSize: parentSize
         );
         // Height auto usually means Intrinsic.
         if (height == null) {
            height = null; // Let content decide
         }
         
         // DASHBOARD PARITY: Button fills 100% implicitly if positioned or checking constraints
         final hasWidthConstraint = constraints.hasBoundedWidth && constraints.maxWidth != double.infinity;
         final hasHeightConstraint = constraints.hasBoundedHeight && constraints.maxHeight != double.infinity;

         // Action Callback
         void triggerAction() {
            if (resolvedCopyText.isEmpty) return;
            _handleCopy(context, resolvedCopyText, showToast, toastMessage);
         }
         
          // Build Icon Component (Conditional Interactive)
          Widget iconWidget = Transform.translate(
             offset: Offset(iconOffsetX, iconOffsetY),
             child: Icon(
               iconData,
               size: (16.0 * scale), // Scaled Icon Size
               color: textColor,
             ),
          );

          // Always apply padding to match React layout (hardcoded 4px in React -> fixed here too)
          iconWidget = Padding(
            padding: const EdgeInsets.all(4.0), // FIX: React CopyButton uses fixed '4px' padding on icon wrapper
            child: iconWidget,
          );

          if (triggerMode == 'icon') {
             // Wrap icon in InkWell/Gesture for icon-only trigger
             iconWidget = Material(
               color: Colors.transparent,
               child: InkWell(
                 onTap: triggerAction,
                 borderRadius: BorderRadius.circular(4.0 * scale),
                 child: iconWidget,
               ),
             );
          }

          Widget contentWidget = Container(
             padding: effectivePadding,
             alignment: Alignment.center, // Ensure content centers vertically/horizontally
             child: Row(
               mainAxisSize: hasWidthConstraint ? MainAxisSize.max : MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.spaceBetween, // React Parity: space-between
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Flexible(
                   fit: FlexFit.loose,
                   child: Transform.translate(
                     offset: Offset(textOffsetX, textOffsetY),
                     child: () {
                         // Font Logic (Parity with ButtonLayer)
                         String? effectiveFontFamily = fontFamily;
                         if (effectiveFontFamily == 'inherit') effectiveFontFamily = null;
                         
                         final fontUrl = content['fontUrl'] as String?;
                         if (fontUrl != null && fontUrl.isNotEmpty) {
                            final urlFamily = NinjaLayerUtils.getFontFamilyFromUrl(fontUrl);
                            if (urlFamily != null) effectiveFontFamily = urlFamily;
                         }

                         TextStyle textStyle = TextStyle(
                           fontSize: fontSize,
                           fontWeight: fontWeight,
                           color: textColor,
                           height: 1.0, // React Parity
                           leadingDistribution: TextLeadingDistribution.proportional, // Web Parity
                           letterSpacing: 0.4 * scale, // Web Default Spacing Parity
                         );
                         
                         if (fontFamily == null || fontFamily == 'inherit') {
                            // FIX: Default to 'Inter' for web parity
                            textStyle = textStyle.copyWith(fontFamily: 'Inter'); 
                         } else if (effectiveFontFamily != null) {
                            final googleFont = NinjaLayerUtils.getGoogleFont(effectiveFontFamily, textStyle: textStyle);
                            if (googleFont != null) {
                               textStyle = googleFont;
                            } else {
                               textStyle = textStyle.copyWith(fontFamily: effectiveFontFamily);
                            }
                         }

                         return Text(
                           displayText,
                           textAlign: TextAlign.left, // React Parity: textAlign left
                           style: textStyle,
                           overflow: TextOverflow.ellipsis,
                           maxLines: 1,
                           textScaler: TextScaler.noScaling,
                         );
                     }(),
                   ),
                 ),
                 SizedBox(width: 8.0 * scale), // FIX: React uses safeScale(8, scale) for gap
                 iconWidget,
               ],
             ),
          );
          
          // Decoration Logic
          final innerDecoration = BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadiusVal),
              // Solid border handled here
              border: (actualBorderWidth > 0 && !isDashed && borderStyle != 'none')
                  ? Border.all(color: borderColor, width: borderWidth)
                  : null,
          );

          final shadowDecoration = BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadiusVal),
              boxShadow: shadows,
          );

          // Interaction Wrapper
          Widget interactiveContent = Material(
             color: Colors.transparent,
             child: Ink(
                decoration: innerDecoration,
                width: hasWidthConstraint ? double.infinity : null,
                height: hasHeightConstraint ? double.infinity : null,
                child: triggerMode == 'anywhere' 
                  ? InkWell(
                      onTap: triggerAction,
                      borderRadius: BorderRadius.circular(borderRadiusVal),
                      child: contentWidget,
                    )
                  : contentWidget,
             ),
          );

          // Outer Container (Shadows)
          Widget outerContainer = Container(
             width: width,
             height: height,
             decoration: shadowDecoration,
             child: interactiveContent,
          );

          // Dashed Border Wrapper
          if (isDashed && actualBorderWidth > 0) {
             return CustomPaint(
               foregroundPainter: _DashedBorderPainter(
                 color: borderColor,
                 strokeWidth: borderWidth,
                 radius: borderRadiusVal,
                 borderStyle: borderStyle, // 'dashed' or 'dotted'
                 // FIX: Tuned for CSS Parity (Standard 1:1, Shorter Dashes)
                 // User Critique: 3x was too long. 1.5x gap was unbalanced.
                 // New: Dash = 2x, Gap = 2x. (Balanced, reduced, fits more dashes).
                 dashPattern: borderStyle == 'dotted' ? [borderWidth, borderWidth] : [borderWidth * 2, borderWidth * 0.5],
               ),
               child: outerContainer,
             );
          }

          return outerContainer;
      }
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final List<double> dashPattern; // [dashLength, gapLength]
  final String borderStyle;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
    this.borderStyle = 'dashed',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isDotted = borderStyle == 'dotted';
    
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = isDotted ? StrokeCap.round : StrokeCap.butt;

    // Adjust rect to center the stroke
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();
    
    final double dashSize = dashPattern[0];
    final double gapSize = dashPattern.length > 1 ? dashPattern[1] : dashPattern[0];
    
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        if (isDotted) {
           // Dot is just a point with Round Cap (0 length)
           // But previously we used 0.1 length. 
           // If we use 0 length with Round Cap, it draws a perfect circle of diameter=strokeWidth.
           dashedPath.addPath(
            metric.extractPath(distance, distance),
            Offset.zero,
          );
          distance += gapSize + strokeWidth; // Spacing is gap + diameter
        } else {
          // Dash
          final double length = (distance + dashSize > metric.length) ? (metric.length - distance) : dashSize;
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
          distance += dashSize + gapSize;
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
           dashPattern != oldDelegate.dashPattern ||
           borderStyle != oldDelegate.borderStyle;
  }
}
