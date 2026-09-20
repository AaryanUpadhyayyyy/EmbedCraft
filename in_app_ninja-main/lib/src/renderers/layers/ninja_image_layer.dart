import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'ninja_layer_utils.dart';

class NinjaImageLayer extends StatelessWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(String, Map<String, dynamic>?)? onAction;

  const NinjaImageLayer(
      {Key? key,
      required this.layer,
      this.parentSize,
      this.scale = 1.0,
      this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = layer['content'] as Map<String, dynamic>? ?? {};
    final style = layer['style'] as Map<String, dynamic>? ?? {};

    // 1. Get Image Source
    final rawUrl = content['imageUrl'] as String? ?? content['url'] as String?;
    final url = rawUrl != null ? NinjaLayerUtils.resolveText(rawUrl) : null;

    // FIX: Shadow Logic (Support Editor Sliders)
    List<BoxShadow>? shadows;
    if (style['shadowEnabled'] == true) {
      shadows = (NinjaLayerUtils.parseShadowFromStyle(style, context) ??
          [
            BoxShadow(
              color: NinjaLayerUtils.parseColor(style['shadowColor']) ??
                  Colors.black,
              // FIX: Scale Shadow Props
              blurRadius:
                  (NinjaLayerUtils.parseDouble(style['shadowBlur'], context) ??
                          0.0) *
                      scale,
              offset: Offset(
                  0,
                  (NinjaLayerUtils.parseDouble(
                              style['shadowOffsetY'] ?? 4, context) ??
                          4.0) *
                      scale), // Force X=0 and Scale
              spreadRadius: (NinjaLayerUtils.parseDouble(
                          style['shadowSpread'], context) ??
                      0.0) *
                  scale,
            )
          ]);
    } else {
      // Fallback to string parsing
      var parsedShadows =
          NinjaLayerUtils.parseShadows(style['boxShadow'], context);
      if (parsedShadows != null) {
        shadows = parsedShadows
            .map((s) => BoxShadow(
                  color: s.color,
                  // FIX: Scale Shadow Props
                  blurRadius: s.blurRadius * scale,
                  spreadRadius: s.spreadRadius * scale,
                  offset: Offset(
                      0, s.offset.dy * scale), // Force X to 0 and Scale Y
                ))
            .toList();
      }
    }

    // 2. Dimensions
    final width = NinjaLayerUtils.parseResponsiveSize(style['width'], context,
        isVertical: false, parentSize: parentSize);
    final height = NinjaLayerUtils.parseResponsiveSize(style['height'], context,
        isVertical: true, parentSize: parentSize);

    // 3. Styling Properties
    // 3. Styling Properties
    // FIX: Handle Object/Map for Border Radius (Parity)
    BorderRadius borderRadius;
    final dynamic rawRadius = style['borderRadius'];
    if (rawRadius is Map) {
      // FIX: Scale Radius Values
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(
            (NinjaLayerUtils.parseDouble(rawRadius['topLeft'], context) ?? 0) *
                scale),
        topRight: Radius.circular(
            (NinjaLayerUtils.parseDouble(rawRadius['topRight'], context) ?? 0) *
                scale),
        bottomLeft: Radius.circular(
            (NinjaLayerUtils.parseDouble(rawRadius['bottomLeft'], context) ??
                    0) *
                scale),
        bottomRight: Radius.circular(
            (NinjaLayerUtils.parseDouble(rawRadius['bottomRight'], context) ??
                    0) *
                scale),
      );
    } else {
      final r = NinjaLayerUtils.parseDouble(rawRadius, context) ?? 0;
      borderRadius = BorderRadius.circular(r * scale); // FIX: Scale Radius
    }

    final fitStr = style['objectFit'] ??
        'cover'; // Default changed to cover to match Dashboard parity
    final opacity = NinjaLayerUtils.parseDouble(style['opacity']) ?? 1.0;
    // Aspect Ratio
    final aspectRatio = NinjaLayerUtils.parseDouble(style['aspectRatio']);

    // Filters
    final filters =
        style['filter']; // Object { blur, brightness, contrast, grayscale }
    // FIX: Safe parsing without type cast to avoid crash on string values
    final double rawBlur = filters is Map
        ? (NinjaLayerUtils.parseDouble(filters['blur']?.toString(), context) ??
            0)
        : 0;
    final double blur = (rawBlur / 2.0) * scale;

    // FIX: Safe parsing for brightness, contrast, grayscale
    final double brightness = filters is Map
        ? (double.tryParse(filters['brightness']?.toString() ?? '') ?? 100)
        : 100;
    final double contrast = filters is Map
        ? (double.tryParse(filters['contrast']?.toString() ?? '') ?? 100)
        : 100;
    final double grayscale = filters is Map
        ? (double.tryParse(filters['grayscale']?.toString() ?? '') ?? 0)
        : 0;

    // Map CSS ObjectFit to Flutter BoxFit
    BoxFit fit;
    switch (fitStr) {
      case 'contain':
        fit = BoxFit.contain;
        break;
      case 'fill':
        fit = BoxFit.fill;
        break;
      case 'none':
        fit = BoxFit.none;
        break;
      case 'scale-down':
        fit = BoxFit.scaleDown;
        break;
      case 'cover':
      default:
        fit = BoxFit.cover;
        break;
    }

    // 4. Border (Optional)
    final borderWidth =
        (NinjaLayerUtils.parseDouble(style['borderWidth'], context) ?? 0) *
            scale; // FIX: Scale Border Width
    final borderColor =
        NinjaLayerUtils.parseColor(style['borderColor']) ?? Colors.transparent;

    // --- WIDGET CONSTRUCTION ---

    // A. Base Image
    Widget imageWidget;

    // FIX: Prevent CRASH by checking URL before Image.network
    if (url != null && url.isNotEmpty) {
      imageWidget = Image.network(
        url,
        width: width, // Explicit dimensions if set
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width ?? 100,
            height: height ?? 100,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      // Render Error Placeholder directly if URL is empty
      imageWidget = Container(
        width: width ?? 100,
        height: height ?? 100,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    // B. Apply Color Matrix Filters (Brightness, Contrast, Grayscale)
    // We combine these into a single ColorFilter matrix if possible, or chain them.
    // Standard Matrix helpers:
    // Brightness: Multiplies RGB. 100% = 1.0.
    // Contrast: Scales deviation from gray.
    // Grayscale: Standard matrix.

    if (brightness != 100 || contrast != 100 || grayscale > 0) {
      // 1. Grayscale
      if (grayscale > 0) {
        final g = grayscale / 100.0; // 0.0 to 1.0
        // R'= G'= B' = 0.2126R + 0.7152G + 0.0722B
        // Mix original (1-g) with grayscale (g)
        final inv = 1 - g;
        final matrix = <double>[
          inv + 0.2126 * g,
          0.7152 * g,
          0.0722 * g,
          0,
          0,
          0.2126 * g,
          inv + 0.7152 * g,
          0.0722 * g,
          0,
          0,
          0.2126 * g,
          0.7152 * g,
          inv + 0.0722 * g,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ];
        imageWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: imageWidget);
      }

      // 2. Brightness (Simple RGB scaling)
      if (brightness != 100) {
        final b = brightness / 100.0;
        // Matrix: R*b, G*b, B*b
        final matrix = <double>[
          b,
          0,
          0,
          0,
          0,
          0,
          b,
          0,
          0,
          0,
          0,
          0,
          b,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ];
        imageWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: imageWidget);
      }

      // 3. Contrast
      if (contrast != 100) {
        final c = contrast / 100.0;
        final offset = 128 * (1 - c); // 0.5 offset? Usually 128 in 255 space.
        // Flutter uses 0-1 range for raw Matrix... wait ColorFilter can handle values > 1
        // A common contrast matrix:
        // R' = c(R - 0.5) + 0.5  (Scales around mid-gray)
        //    = cR - 0.5c + 0.5
        //    = cR + 0.5(1-c)
        final t = 0.5 *
            (1 - c) *
            255; // Translation needs to be in 0-255 space if using matrix?
        // ACTUALLY: flutter ColorFilter.matrix last column is 0-255 offset.

        final matrix = <double>[
          c,
          0,
          0,
          0,
          t,
          0,
          c,
          0,
          0,
          t,
          0,
          0,
          c,
          0,
          t,
          0,
          0,
          0,
          1,
          0,
        ];
        imageWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: imageWidget);
      }
    }

    // C. Apply Blur (ImageFilter)
    if (blur > 0) {
      imageWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: imageWidget,
      );
    }

    // Clip Radius for Image Content (Important if image spills out of border radius)
    // Note: If we have a border, we might clip at container, but clipping here is safer for the image itself.
    if (borderRadius != BorderRadius.zero) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius, // Use the Geometry object
        child: imageWidget,
      );
    }

    // D. Wrap in AspectRatio if applied
    if (aspectRatio != null && aspectRatio > 0) {
      imageWidget = AspectRatio(
        aspectRatio: aspectRatio,
        child: imageWidget,
      );
    }

    // E. Container for Border and Shadow
    // If we have Shadow or Border, we need a Container.
    // IMPORTANT: If we use Container with decoration, it handles the background. The image is a CHILD.
    // If we want shadow on the IMAGE shape, Container shadow works if box is opaque.
    // If we have shadows, we generally wrap.

    // E. Container for Border and Shadow
    // If we have Shadow or Border, we need a Container.

    // E. Container for Border and Shadow (Existing logic...)
    final borderStyle = style['borderStyle']?.toString().toLowerCase();
    final isDashed = borderStyle == 'dashed' || borderStyle == 'dotted';
    final hasBorder = borderWidth > 0 && borderStyle != 'none';

    Widget finalWidget = imageWidget;

    if (hasBorder || (shadows != null && shadows.isNotEmpty) || opacity < 1.0) {
      Widget container = Container(
        width: aspectRatio != null ? null : width,
        height: aspectRatio != null ? null : height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: (hasBorder && !isDashed)
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          boxShadow: shadows,
        ),
        clipBehavior: Clip.none,
        child: opacity < 1.0
            ? Opacity(opacity: opacity, child: imageWidget)
            : imageWidget,
      );

      if (isDashed && hasBorder) {
        finalWidget = CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: borderColor,
            strokeWidth: borderWidth,
            borderRadius: borderRadius,
            borderStyle: borderStyle ?? 'dashed',
            gap: (borderStyle == 'dotted'
                    ? (borderWidth * 2)
                    : (borderWidth * 3)) *
                scale,
          ),
          child: container,
        );
      } else {
        finalWidget = container;
      }
    } else {
      if (opacity < 1.0) {
        finalWidget = Opacity(opacity: opacity, child: imageWidget);
      }
    }

    // F. Click Action Handler
    final clickActionMap = layer['clickAction'] as Map<String, dynamic>? ??
        layer['content']?['clickAction'] as Map<String, dynamic>?;
    final actionProp = layer['content']?['action'];

    if ((clickActionMap != null || actionProp != null) && onAction != null) {
      finalWidget = GestureDetector(
        onTap: () {
          if (clickActionMap != null) {
            final type = clickActionMap['type'] ?? 'submit';
            onAction!(type, clickActionMap);
          } else if (actionProp != null) {
            final actionStr = actionProp is Map ? actionProp['type'] : actionProp.toString();
            final actionData = actionProp is Map ? (actionProp as Map<String, dynamic>) : <String, dynamic>{};
            onAction!(actionStr, actionData);
          }
        },
        behavior: HitTestBehavior.opaque, // Ensure tap is caught
        child: finalWidget,
      );
    }

    return finalWidget;
  }
}

// Ported from NinjaButtonLayer for Parity
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
