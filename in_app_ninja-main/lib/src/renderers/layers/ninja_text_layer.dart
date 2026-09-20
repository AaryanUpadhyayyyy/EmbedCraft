import 'package:flutter/material.dart';
import 'dart:ui'; // For PathMetric
import 'ninja_layer_utils.dart';

class NinjaTextLayer extends StatelessWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale; // Global scale factor

  const NinjaTextLayer(
      {Key? key, required this.layer, this.parentSize, this.scale = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = layer['content'] as Map<String, dynamic>? ?? {};
    final style = layer['style'] as Map<String, dynamic>? ?? {};

    // 1. Content
    final text =
        NinjaLayerUtils.resolveText(content['text']?.toString() ?? 'Text');

    // 2. Typography
    // FIX: Default font size 14.0 to match React, and apply scale
    // CRITICAL: Do NOT pass context to parseDouble — it would apply deviceWidth/designWidth scaling internally,
    // and then `* scale` below applies the same ratio again, causing double-scaling.
    final fontSizeRaw =
        NinjaLayerUtils.parseDouble(content['fontSize']) ?? NinjaLayerUtils.parseDouble(style['fontSize']) ?? 14.0;
    final fontSize = fontSizeRaw * scale;

    final fontWeightStr = (content['fontWeight'] ?? style['fontWeight'])?.toString();
    final fontWeight = NinjaLayerUtils.parseFontWeight(fontWeightStr);
    final textColor =
        NinjaLayerUtils.parseColor(content['textColor']) ?? Colors.black;
    final textAlignStr = content['textAlign']?.toString() ?? 'left';

    TextAlign textAlign;
    switch (textAlignStr) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      default:
        textAlign = TextAlign.left;
    }

    // Size (Text can have explicit size too)
    // For width/height, NinjaLayerUtils.parseResponsiveSize handles generic sizing.
    // If pixels, we manually scale them if needed, but parseResponsiveSize usually does context scaling.
    // However, here we want "Design Scale".
    // If logic in parseResponsiveSize relies on context, it might conflict with explicit scale.
    // React parity suggests scaling explicit pixel widths too.
    // But let's leave generic sizing for now and focus on text-specifics as requested.
    final width = NinjaLayerUtils.parseResponsiveSize(style['width'], context,
        isVertical: false, parentSize: parentSize);
    final height = NinjaLayerUtils.parseResponsiveSize(style['height'], context,
        isVertical: true, parentSize: parentSize);

    // Background/Border
    final bgColor = NinjaLayerUtils.parseColor(style['backgroundColor']);
    final paddingRaw = NinjaLayerUtils.parsePadding(style['padding'], context);
    // Scale padding manually if it's not null
    final padding = paddingRaw != null
        ? EdgeInsets.fromLTRB(paddingRaw.left * scale, paddingRaw.top * scale,
            paddingRaw.right * scale, paddingRaw.bottom * scale)
        : EdgeInsets.zero; // FIX: Explicit zero for strict parity

    final radius =
        (NinjaLayerUtils.parseDouble(style['borderRadius'], context) ?? 0) *
            scale;

    // Font Family
    String? fontFamily =
        (style['fontFamily'] as String?) ?? (content['fontFamily'] as String?);
    final fontUrl = content['fontUrl'] as String?;

    if (fontUrl != null && fontUrl.isNotEmpty) {
      final urlFamily = NinjaLayerUtils.getFontFamilyFromUrl(fontUrl);
      if (urlFamily != null) fontFamily = urlFamily;
    }

    // FIX: React parity - Exact match Dashboard default of 1.4
    final lineHeight =
        NinjaLayerUtils.parseDouble(content['lineHeight']) ?? 1.4;

    // FIX: Text Shadow Logic
    List<Shadow>? textShadows;
    if (content['textShadowX'] != null ||
        content['textShadowY'] != null ||
        content['textShadowBlur'] != null) {
      textShadows = [
        Shadow(
          offset: Offset(
            (NinjaLayerUtils.parseDouble(content['textShadowX']) ?? 0) * scale,
            (NinjaLayerUtils.parseDouble(content['textShadowY']) ?? 0) * scale,
          ),
          blurRadius:
              (NinjaLayerUtils.parseDouble(content['textShadowBlur']) ?? 0) *
                  scale,
          color: NinjaLayerUtils.parseColor(content['textShadowColor']) ??
              Colors.black,
        )
      ];
    }

    // FIX: Text Decoration
    TextDecoration textDecoration = TextDecoration.none;
    final decorationStr = content['textDecoration']?.toString().toLowerCase();
    if (decorationStr != null) {
      List<TextDecoration> decorations = [];
      if (decorationStr.contains('underline'))
        decorations.add(TextDecoration.underline);
      if (decorationStr.contains('line-through'))
        decorations.add(TextDecoration.lineThrough);

      if (decorations.isNotEmpty) {
        textDecoration = TextDecoration.combine(decorations);
      }
    }

    // FIX: Letter Spacing Logic 0 vs Null
    // React treats missing as 'normal' (null equivalent) and 0 as '0px'.
    // We must preserve explicit 0.0.
    double? letterSpacing;
    if (content['letterSpacing'] != null) {
      // CRITICAL: No context — scale is applied manually below to avoid double-scaling
      final val =
          NinjaLayerUtils.parseDouble(content['letterSpacing']) ?? 0.0;
      if (val != 0) {
        letterSpacing = val * scale;
      }
    } else {
      // FIX: Web Default Parity - Add 0.4px (scaled) tracking to mimic 'normal' web spacing
      letterSpacing = 0.4 * scale;
    }

    TextStyle textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      height: lineHeight,
      leadingDistribution: TextLeadingDistribution
          .proportional, // FIX: Proportional handles custom font ascenders better than even
      letterSpacing: letterSpacing, // Pass explicit 0.0 or null
      shadows: textShadows,
      decoration: textDecoration,
    );

    // ... (Google Font logic remains same)

    if (fontFamily != null && fontFamily != 'inherit') {
      final googleFont =
          NinjaLayerUtils.getGoogleFont(fontFamily, textStyle: textStyle);
      if (googleFont != null) {
        textStyle = googleFont;
      } else {
        textStyle = textStyle.copyWith(fontFamily: fontFamily);
      }
    } else {
      // FIX: Default to 'Inter' for web parity when fontFamily is null or 'inherit'
      final googleFont = NinjaLayerUtils.getGoogleFont('Inter', textStyle: textStyle);
      if (googleFont != null) {
        textStyle = googleFont;
      } else {
        textStyle = textStyle.copyWith(fontFamily: 'Inter');
      }
    }

    // FIX: Text Transform
    String displayedText = text;
    final textTransform = content['textTransform']?.toString().toLowerCase();
    if (textTransform == 'uppercase') {
      displayedText = text.toUpperCase();
    } else if (textTransform == 'lowercase') {
      displayedText = text.toLowerCase();
    } else if (textTransform == 'capitalize') {
      if (displayedText.isNotEmpty) {
        // FIX: Capitalize every word (Title Case)
        displayedText = displayedText.split(' ').map((word) {
          if (word.isEmpty) return word;
          return "${word[0].toUpperCase()}${word.substring(1)}";
        }).join(' ');
      }
    }

    // Text Stroke
    // FIX: Multiply by 2. Flutter renders stroke INSIDE/CENTER but paints Fill ON TOP.
    // This hides half the stroke. To match Web's visual weight, we double the width.
    // CRITICAL: No context — scale is applied manually to avoid double-scaling
    final strokeWidth =
        ((NinjaLayerUtils.parseDouble(content['textStrokeWidth']) ??
                    0.0) *
                scale) *
            2;
    final strokeColor =
        NinjaLayerUtils.parseColor(content['textStrokeColor']) ?? Colors.black;

    // FIX: Overflow Protection — Dashboard Parity
    // Dashboard only uses textOverflow:'ellipsis' when maxLines is set:
    //   textOverflow: layer.content?.maxLines ? 'ellipsis' : undefined
    // In Flutter, setting TextOverflow.ellipsis WITHOUT maxLines causes the
    // paragraph engine to treat text as single-line (no wrapping).
    // Fix: Only use ellipsis when maxLines is explicitly set.
    final int? maxLines = NinjaLayerUtils.parseInt(content['maxLines']);
    final TextOverflow textOverflow = maxLines != null
        ? TextOverflow.ellipsis
        : TextOverflow.visible; // visible = prevents sub-pixel clipping of font ascenders/bounds

    Widget textWidget;

    // CSS Parity: Force strict line-height adherence by stripping native font margins
    const textHeightSettings = TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
    );

    if (strokeWidth > 0) {
      textWidget = Stack(
        children: [
          // Stroke Layer
          Text(
            displayedText,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: textOverflow,
            textScaler: TextScaler.noScaling,
            textHeightBehavior: textHeightSettings,
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
          ),
          // Fill Layer
          Text(
            displayedText,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: textOverflow,
            textScaler: TextScaler.noScaling,
            textHeightBehavior: textHeightSettings,
            style: textStyle.copyWith(shadows: []),
          ),
        ],
      );
    } else {
      textWidget = Text(
        displayedText,
        style: textStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: textOverflow,
        textScaler: TextScaler.noScaling,
        textHeightBehavior: textHeightSettings,
      );
    }

    // Text Offset
    // CRITICAL: No context — scale is applied manually to avoid double-scaling
    final textOffsetX =
        (NinjaLayerUtils.parseDouble(content['textOffsetX']) ?? 0.0) *
            scale;
    final textOffsetY =
        (NinjaLayerUtils.parseDouble(content['textOffsetY']) ?? 0.0) *
            scale;

    if (textOffsetX != 0 || textOffsetY != 0) {
      textWidget = Transform.translate(
        offset: Offset(textOffsetX, textOffsetY),
        child: textWidget,
      );
    }

    // Parse Box Shadow Manually to apply scale
    List<BoxShadow>? manualBoxShadow;
    // FIX: Commented out for parity. React TextRenderer doesn't internally support box shadow (it's handled by wrapper).
    // In Flutter, TooltipRendererV2 wrapper already handles this.
    /*
    final boxShadowStr = style['boxShadow']?.toString();
    if (boxShadowStr != null && boxShadowStr != 'none' && boxShadowStr.isNotEmpty) {
       try {
           manualBoxShadow = NinjaLayerUtils.parseShadows([boxShadowStr]); 
           if (manualBoxShadow != null) {
              manualBoxShadow = manualBoxShadow.map((s) => BoxShadow(
                 color: s.color,
                 offset: s.offset * scale,
                 blurRadius: s.blurRadius * scale,
                 spreadRadius: s.spreadRadius * scale,
              )).toList();
           }
       } catch (e) {
         // Fallback
       }
    }
    */

    // FIX: Border Safety
    final borderWidthRaw = NinjaLayerUtils.parseDouble(style['borderWidth']);
    final hasBorder = borderWidthRaw != null && borderWidthRaw > 0;
    final borderWidth = (borderWidthRaw ?? 0) * scale;
    final borderColor =
        NinjaLayerUtils.parseColor(style['borderColor']) ?? Colors.transparent;

    // FIX: Border style for dashed/dotted support
    final borderStyle = style['borderStyle']?.toString() ?? 'solid';
    final isDashed = borderStyle == 'dashed' || borderStyle == 'dotted';

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: bgColor != null || (hasBorder && !isDashed)
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(radius),
              // FIX: Only solid borders via BoxDecoration
              border: (hasBorder && !isDashed)
                  ? Border.all(color: borderColor, width: borderWidth)
                  : null,
              boxShadow: manualBoxShadow,
            )
          : null,
      alignment: width != null ? _getAlignment(textAlign) : null,
      child: textWidget,
    );

    // FIX: Wrap with CustomPaint for dashed/dotted borders
    if (isDashed && hasBorder) {
      container = CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: borderColor,
          strokeWidth: borderWidth,
          borderRadius: BorderRadius.circular(radius),
          borderStyle: borderStyle,
          gap:
              (borderStyle == 'dotted' ? (borderWidth * 2) : (borderWidth * 3)),
        ),
        child: container,
      );
    }

    // FIX: Opacity
    final opacity = NinjaLayerUtils.parseDouble(style['opacity']) ?? 1.0;
    if (opacity < 1.0) {
      return Opacity(opacity: opacity, child: container);
    }

    return container;
  }

  Alignment _getAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.topCenter; // FIX: Vertical Top
      case TextAlign.right:
        return Alignment.topRight; // FIX: Vertical Top
      default:
        return Alignment.topLeft; // FIX: Vertical Top
    }
  }
}

/// CustomPainter for dashed and dotted borders with CSS-like rendering
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

    final Path dashedPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;

      while (distance < metric.length) {
        if (isDotted) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + 0.1),
            Offset.zero,
          );
          distance += gap + strokeWidth;
        } else {
          dashedPath.addPath(
            metric.extractPath(distance, distance + gap),
            Offset.zero,
          );
          distance += gap * 2;
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
