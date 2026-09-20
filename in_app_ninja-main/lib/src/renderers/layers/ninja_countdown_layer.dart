import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ninja_layer_utils.dart'; // Ensure this path is correct

class NinjaCountdownLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(String action, Map<String, dynamic> data)? onAction;

  const NinjaCountdownLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scale = 1.0,
    this.onAction,
  }) : super(key: key);

  @override
  State<NinjaCountdownLayer> createState() => _NinjaCountdownLayerState();
}

class _NinjaCountdownLayerState extends State<NinjaCountdownLayer> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant NinjaCountdownLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // BUG 13 FIX: Only restart timer if targetDate actually changed
    final oldTarget =
        (oldWidget.layer['content'] as Map<String, dynamic>?)?['targetDate'];
    final newTarget =
        (widget.layer['content'] as Map<String, dynamic>?)?['targetDate'];
    if (oldTarget != newTarget) {
      _timer?.cancel();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final targetDateStr = content['targetDate']?.toString();
    final useLocalTime = content['useLocalTime'] != false; // Default true

    // BUG 12 FIX: If no targetDate, show zeros (TSX parity)
    if (targetDateStr == null || targetDateStr.isEmpty) {
      if (mounted) setState(() => _timeLeft = Duration.zero);
      return;
    }

    DateTime? targetDateNullable = DateTime.tryParse(targetDateStr);

    if (targetDateNullable == null) {
      // Parity Fix: React generates `NaN` for invalid dates, resolving to 0s immediately.
      // We no longer inject an artificial 24-hour timer.
      if (mounted) setState(() => _timeLeft = Duration.zero);
      return;
    }

    DateTime targetDate = targetDateNullable;

    if (useLocalTime) {
      targetDate = targetDate.toLocal();
    } else {
      targetDate = targetDate.toUtc();
    }

    _tick(targetDate);
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _tick(targetDate));
  }

  void _tick(DateTime targetDate) {
    final now = DateTime.now();
    final diff = targetDate.difference(now);

    if (diff.isNegative) {
      if (!_isExpired) {
        _isExpired = true;
        _handleExpiry();
      }
      _timer?.cancel();
      if (mounted) setState(() => _timeLeft = Duration.zero);
    } else {
      if (mounted) setState(() => _timeLeft = diff);
    }
  }

  void _handleExpiry() {
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final onExpiry = content['onExpiry']?.toString() ?? 'none';

    if (onExpiry == 'redirect') {
      final url = content['expiryUrl']?.toString();
      if (url != null && widget.onAction != null) {
        widget.onAction!('open_url', {'url': url});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final style = widget.layer['style'] as Map<String, dynamic>? ?? {};
    final scale = widget.scale;

    // --- Expiry Handling ---
    if (_isExpired) {
      final onExpiry = content['onExpiry']?.toString() ?? 'none';
      if (onExpiry == 'hide') return const SizedBox.shrink();
      if (onExpiry == 'message') {
        final msg = content['expiryMessage']?.toString() ?? 'Expired';
        // BUG 17 FIX: Try style['fontSize'] first, then content['fontSize']
        final fontSize = (NinjaLayerUtils.parseDouble(style['fontSize']) ??
                NinjaLayerUtils.parseDouble(content['fontSize']) ??
                16.0) *
            scale;
        final color =
            NinjaLayerUtils.parseColor(content['digitColor']) ?? Colors.black;
        // Basic centered message
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0 * scale),
          child: Text(msg,
              style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: content['fontFamily']?.toString() ?? 'Inter')),
        );
      }
    }

    // --- Container Props ---
    final bgColor = NinjaLayerUtils.parseColor(style['backgroundColor']);

    // FIX: Manual Padding Scaling (Like ButtonLayer)
    // BUG 10 FIX: Handle object-form padding { top, right, bottom, left }
    final rawPadding = style['padding'];
    double? genericPadding;
    double pTopRaw, pRightRaw, pBottomRaw, pLeftRaw;

    if (rawPadding is Map) {
      // Object form: { top: N, right: N, bottom: N, left: N }
      pTopRaw = NinjaLayerUtils.parseDouble(rawPadding['top']) ?? 0.0;
      pRightRaw = NinjaLayerUtils.parseDouble(rawPadding['right']) ?? 0.0;
      pBottomRaw = NinjaLayerUtils.parseDouble(rawPadding['bottom']) ?? 0.0;
      pLeftRaw = NinjaLayerUtils.parseDouble(rawPadding['left']) ?? 0.0;
    } else {
      if (rawPadding is num) genericPadding = rawPadding.toDouble();
      if (genericPadding == null && rawPadding != null) {
        genericPadding = NinjaLayerUtils.parseDouble(rawPadding);
      }
      pTopRaw = NinjaLayerUtils.parseDouble(
              style['paddingTop'] ?? style['paddingVertical']) ??
          genericPadding ??
          0.0;
      pRightRaw = NinjaLayerUtils.parseDouble(
              style['paddingRight'] ?? style['paddingHorizontal']) ??
          genericPadding ??
          0.0;
      pBottomRaw = NinjaLayerUtils.parseDouble(
              style['paddingBottom'] ?? style['paddingVertical']) ??
          genericPadding ??
          0.0;
      pLeftRaw = NinjaLayerUtils.parseDouble(
              style['paddingLeft'] ?? style['paddingHorizontal']) ??
          genericPadding ??
          0.0;
    }

    final scaledPadding = EdgeInsets.only(
      top: pTopRaw * scale,
      right: pRightRaw * scale,
      bottom: pBottomRaw * scale,
      left: pLeftRaw * scale,
    );

    final borderRadius =
        (NinjaLayerUtils.parseDouble(style['borderRadius']) ?? 0) * scale;
    final borderWidth =
        (NinjaLayerUtils.parseDouble(style['borderWidth']) ?? 0) * scale;
    final borderColor = NinjaLayerUtils.parseColor(style['borderColor']);
    // Container Shadow
    // SDK Support for Shadow Offset X (Parity with Dashboard)
    final shadowEnabled = style['shadowEnabled'] == true;
    final containerShadows = shadowEnabled
        ? [
            BoxShadow(
              color: (NinjaLayerUtils.parseColor(style['shadowColor']) ??
                      Colors.black)
                  .withOpacity(
                      NinjaLayerUtils.parseDouble(style['shadowOpacity']) ??
                          0.25),
              offset: Offset(
                  (NinjaLayerUtils.parseDouble(style['shadowOffsetX']) ?? 0.0) *
                      scale,
                  (NinjaLayerUtils.parseDouble(style['shadowOffsetY']) ?? 4.0) *
                      scale),
              blurRadius:
                  (NinjaLayerUtils.parseDouble(style['shadowBlur']) ?? 0.0) *
                      scale,
              spreadRadius:
                  (NinjaLayerUtils.parseDouble(style['shadowSpread']) ?? 0.0) *
                      scale,
            )
          ]
        : NinjaLayerUtils.parseShadows(style['boxShadow'], context);

    // --- Flex Layout Props ---
    final gap = (NinjaLayerUtils.parseDouble(style['gap']) ?? 4.0) * scale;
    final justifyContent = style['justifyContent']?.toString() ?? 'center';
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
    if (justifyContent == 'flex-start')
      mainAxisAlignment = MainAxisAlignment.start;
    if (justifyContent == 'flex-end') mainAxisAlignment = MainAxisAlignment.end;
    if (justifyContent == 'space-between')
      mainAxisAlignment = MainAxisAlignment.spaceBetween;
    if (justifyContent == 'space-around')
      mainAxisAlignment = MainAxisAlignment.spaceAround;
    // BUG 14 FIX: Add space-evenly support
    if (justifyContent == 'space-evenly')
      mainAxisAlignment = MainAxisAlignment.spaceEvenly;

    // --- Content Props ---
    final showDays = content['showDays'] != false;
    final showHours = content['showHours'] != false;
    final showMinutes = content['showMinutes'] != false;
    final showSeconds = content['showSeconds'] != false;
    // BUG 2 FIX: Default to 'digital' not 'box' (TSX parity)
    final preset = content['preset']?.toString() ?? 'digital';
    final showSeparator = content['showSeparator'] != false; // Default true

    // --- Typography & Colors ---
    // Digit Color: content.digitColor -> style.color -> black
    // BUG 11 FIX: Default to #000 like TSX (was #111827)
    final digitColor = NinjaLayerUtils.parseColor(content['digitColor']) ??
        NinjaLayerUtils.parseColor(style['color']) ??
        const Color(0xFF000000);

    // Label Color: content.labelColor -> digitColor (with fallback opacity logic later)
    final labelColorProp = NinjaLayerUtils.parseColor(content['labelColor']);

    final fontFamily = content['fontFamily']?.toString() ?? 'Inter';
    // FIX: Font Size Source (Data Binding Risk)
    // React reads from style.fontSize first, then defaults.
    final fontSizeRaw = NinjaLayerUtils.parseDouble(style['fontSize']) ??
        NinjaLayerUtils.parseDouble(content['fontSize']) ??
        32.0;
    final fontSize = fontSizeRaw * scale;
    final fontWeight = NinjaLayerUtils.parseFontWeight(content['fontWeight']) ??
        FontWeight.bold;

    // --- Unit Time Calculation with Rollover ---
    int days = _timeLeft.inDays;
    int hours = _timeLeft.inHours % 24;
    int minutes = _timeLeft.inMinutes % 60;
    int seconds = _timeLeft.inSeconds % 60;

    // Rollover logic if units are hidden
    if (!showDays) {
      hours += days * 24;
      days = 0;
    }
    if (!showHours) {
      minutes += hours * 60;
      hours = 0;
    }
    if (!showMinutes) {
      seconds += minutes * 60;
      minutes = 0;
    }

    // --- Builders ---

    Widget buildUnit(int value, String label, int max) {
      if (preset == 'ring') {
        return _buildRingUnit(
          value: value,
          max: max,
          label: label,
          scale: scale,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          digitColor: digitColor,
          labelColorProp: labelColorProp,
          content: content,
          context: context,
        );
      } else {
        return _buildBoxUnit(
          value: value,
          label: label,
          scale: scale,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          digitColor: digitColor,
          labelColorProp: labelColorProp,
          content: content,
          context: context,
        );
      }
    }

    Widget buildSeparator() {
      // Separator Props
      // CD1 Fix: TSX defaults to '#111827', not '#000000'
      final sepColor = NinjaLayerUtils.parseColor(content['separatorColor']) ??
          NinjaLayerUtils.parseColor(style['color']) ??
          const Color(0xFF111827);
      final sepOffsetY =
          (NinjaLayerUtils.parseDouble(content['separatorOffsetY']) ?? 0.0) *
              scale;
      final sepFontSizeVal =
          NinjaLayerUtils.parseDouble(content['separatorFontSize']);
      final sepFontSize = sepFontSizeVal != null
          ? sepFontSizeVal * scale
          : fontSize; // Default to digit size if not set, or inherit

      // BUG 5+21 FIX: No internal padding — parent CSS gap handles spacing.
      // In Dart, we inject SizedBox(width: gap) before/after in the assembly.
      return Transform.translate(
        offset: Offset(0, sepOffsetY),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: sepFontSize,
            color: sepColor.withOpacity(0.5),
            fontFamily: fontFamily,
            height: 1.0,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      );
    }

    // --- Assembly ---
    // BUG 3 FIX: Use 'days','hours','minutes','seconds' as keys (TSX parity)
    // BUG 21 FIX: Separator spacing — inject gap SizedBoxes around separator
    List<Widget> children = [];
    if (showDays) {
      children.add(buildUnit(days, 'days', 30));
      if (showHours || showMinutes || showSeconds) {
        if (showSeparator) {
          children.add(SizedBox(width: gap));
          children.add(buildSeparator());
          children.add(SizedBox(width: gap));
        } else {
          children.add(SizedBox(width: gap));
        }
      }
    }
    if (showHours) {
      children.add(buildUnit(hours, 'hours', 24));
      if (showMinutes || showSeconds) {
        if (showSeparator) {
          children.add(SizedBox(width: gap));
          children.add(buildSeparator());
          children.add(SizedBox(width: gap));
        } else {
          children.add(SizedBox(width: gap));
        }
      }
    }
    if (showMinutes) {
      children.add(buildUnit(minutes, 'minutes', 60));
      if (showSeconds) {
        if (showSeparator) {
          children.add(SizedBox(width: gap));
          children.add(buildSeparator());
          children.add(SizedBox(width: gap));
        } else {
          children.add(SizedBox(width: gap));
        }
      }
    }
    if (showSeconds) {
      children.add(buildUnit(seconds, 'seconds', 60));
    }

    // BUG 9 FIX: Apply style.opacity
    final opacity = NinjaLayerUtils.parseDouble(style['opacity']) ?? 1.0;

    Widget container = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.transparent, width: borderWidth)
            : null,
        boxShadow: containerShadows,
      ),
      padding: scaledPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Hug content
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );

    if (opacity < 1.0) {
      container = Opacity(opacity: opacity.clamp(0.0, 1.0), child: container);
    }
    return container;
  }

  // --- Box Unit Builder ---
  Widget _buildBoxUnit({
    required int value,
    required String label,
    required double scale,
    required double fontSize,
    required String fontFamily,
    required FontWeight fontWeight,
    required Color digitColor,
    required Color? labelColorProp,
    required Map<String, dynamic> content,
    required BuildContext context,
  }) {
    // 4. Box Sizing & Flip Logic
    // Preset determination (TSX Parity: 'digital' is default)
    final preset = content['preset']?.toString().toLowerCase() ?? 'digital';
    final isBoxPreset = preset == 'box'; // Strict check for 'box' preset
    final isFlip = preset == 'flip';

    // Min Width & Padding
    // React Parity: minWidth & padding only apply if preset == 'box'
    final minWidth = isBoxPreset ? (fontSize * 1.5) : 0.0;
    final paddingH = isBoxPreset ? (8.0 * scale) : 0.0;
    final paddingV = isBoxPreset ? (4.0 * scale) : 0.0;

    // Background Color Logic
    Color unitBg;
    if (content['unitBackgroundColor'] != null) {
      unitBg = NinjaLayerUtils.parseColor(content['unitBackgroundColor'])!;
    } else if (content['tileColor'] != null) {
      unitBg = NinjaLayerUtils.parseColor(content['tileColor'])!;
    } else {
      // React: isBox ? white : transparent
      unitBg = isBoxPreset ? Colors.white : Colors.transparent;
    }

    // BUG 4 FIX: Box preset defaults to 1px border, 8px radius (TSX parity)
    final unitBorderW =
        (NinjaLayerUtils.parseDouble(content['unitBorderWidth']) ??
                (isBoxPreset ? 1.0 : 0.0)) *
            scale;
    final unitRadius =
        (NinjaLayerUtils.parseDouble(content['unitBorderRadius']) ??
                (isBoxPreset ? 8.0 : 0.0)) *
            scale;
    final unitBorderColor =
        NinjaLayerUtils.parseColor(content['unitBorderColor']) ??
            const Color(0xFFE5E7EB);

    // 2. Unit Shadow
    // FIX: Unit Shadow Logic (Strictness Mismatch)
    final shadowEnabled = isBoxPreset && content['unitShadowEnabled'] == true;
    List<BoxShadow>? unitShadows;
    if (shadowEnabled) {
      final sx =
          (NinjaLayerUtils.parseDouble(content['unitShadowX']) ?? 0.0) * scale;
      final sy =
          (NinjaLayerUtils.parseDouble(content['unitShadowY']) ?? 0.0) * scale;
      final blur =
          (NinjaLayerUtils.parseDouble(content['unitShadowBlur']) ?? 0.0) *
              scale;
      final spread =
          (NinjaLayerUtils.parseDouble(content['unitShadowSpread']) ?? 0.0) *
              scale;
      final opacity =
          NinjaLayerUtils.parseDouble(content['unitShadowOpacity']) ?? 0.25;
      final color = NinjaLayerUtils.parseColor(content['unitShadowColor']) ??
          Colors.black;

      unitShadows = [
        BoxShadow(
          color: color.withOpacity(opacity),
          offset: Offset(sx, sy),
          blurRadius: blur,
          spreadRadius: spread,
        )
      ];
    }

    // 3. Labels — BUG 3 FIX: Use label key directly (matches TSX JSON keys)
    final Map<String, dynamic> defaultLabels = {
      'days': 'Days',
      'hours': 'Hrs',
      'minutes': 'Mins',
      'seconds': 'Secs'
    };
    final labels = content['labels'] as Map<String, dynamic>? ?? defaultLabels;
    final labelText = labels[label] ?? defaultLabels[label] ?? label;
    final showLabels = content['showLabels'] != false;
    final labelUnscaledSize =
        (NinjaLayerUtils.parseDouble(content['labelFontSize']) ?? 12.0);
    final labelSize = content['labelFontSize'] != null
        ? labelUnscaledSize * scale
        : fontSize * 0.4; // Fallback relative

    // CD2 Fix: TSX label fallback is style.color || '#111827', not digitColor's #000 default
    final layerStyle = widget.layer['style'] as Map<String, dynamic>? ?? {};
    final effectiveLabelColor = labelColorProp ??
        NinjaLayerUtils.parseColor(content['digitColor']) ??
        NinjaLayerUtils.parseColor(layerStyle['color']) ??
        const Color(0xFF111827);
    final labelOpacity = labelColorProp != null ? 1.0 : 0.6;

    return Container(
      // Margin for gap is handled by parent Row mostly
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Box
          Container(
            constraints:
                isBoxPreset ? BoxConstraints(minWidth: minWidth) : null,
            padding:
                EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unitBg,
              borderRadius: BorderRadius.circular(unitRadius),
              border: unitBorderW > 0
                  ? Border.all(color: unitBorderColor, width: unitBorderW)
                  : null,
              boxShadow: unitShadows,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: digitColor,
                    fontFamily: fontFamily,
                    height: 1.0, // Strict height for vertically centering
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                // Flip Divider Line (Visual Parity)
                // BUG 22 FIX: TSX uses 1px unscaled
                if (isFlip)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 1.0, // Unscaled 1px like TSX
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // The Label
          // BUG 6 FIX: TSX has gap(2) + marginTop(4|2) = 6|4 total
          if (showLabels) ...[
            SizedBox(
                height: (isBoxPreset ? 6.0 : 4.0) *
                    scale), // TSX: gap(2) + marginTop(4|2)
            Text(
              labelText.toUpperCase(), // React: textTransform: 'uppercase'
              style: TextStyle(
                fontSize: labelSize,
                color: effectiveLabelColor.withOpacity(labelOpacity),
                fontFamily: fontFamily,
                // BUG 19 FIX: Inherit container fontWeight (TSX CSS inheritance)
                fontWeight: fontWeight,
                height: 1.0,
              ),
            )
          ]
        ],
      ),
    );
  }

  // --- Ring Unit Builder ---
  Widget _buildRingUnit({
    required int value,
    required int max,
    required String label,
    required double scale,
    required double fontSize,
    required String fontFamily,
    required FontWeight fontWeight,
    required Color digitColor,
    required Color? labelColorProp,
    required Map<String, dynamic> content,
    required BuildContext context,
  }) {
    // Ring Logic from React
    // size = fontSize * 2
    // strokeWidth = 4 * scale
    final size = fontSize * 2.0;
    final strokeWidth = 4.0 * scale;
    final ringColor = NinjaLayerUtils.parseColor(content['ringColor']) ??
        const Color(0xFF6366F1);

    // Label Logic — BUG 3 FIX: Use label key directly
    final Map<String, dynamic> defaultLabels = {
      'days': 'Days',
      'hours': 'Hrs',
      'minutes': 'Mins',
      'seconds': 'Secs'
    };
    final labels = content['labels'] as Map<String, dynamic>? ?? defaultLabels;
    final labelText = labels[label] ?? defaultLabels[label] ?? label;
    final showLabels = content['showLabels'] != false;
    final labelUnscaledSize =
        (NinjaLayerUtils.parseDouble(content['labelFontSize']) ?? 12.0);
    // React fallback for ring label: 0.35em
    final labelSize = content['labelFontSize'] != null
        ? labelUnscaledSize * scale
        : fontSize * 0.35;

    // CD2 Fix: TSX label fallback is style.color || '#111827' for ring labels too
    final layerStyle = widget.layer['style'] as Map<String, dynamic>? ?? {};
    final effectiveLabelColor = labelColorProp ??
        NinjaLayerUtils.parseColor(content['digitColor']) ??
        NinjaLayerUtils.parseColor(layerStyle['color']) ??
        const Color(0xFF111827);
    final labelOpacity = labelColorProp != null ? 1.0 : 0.6;

    final progress = (value / max).clamp(0.0, 1.0);

    // BUG 8 FIX: Remove spurious horizontal padding (TSX has none)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // BUG 16 FIX: Smooth ring progress animation (1s linear)
              _AnimatedRing(
                progress: progress,
                size: size,
                strokeWidth: strokeWidth,
                trackColor: const Color(0xFFE5E7EB),
                progressColor: ringColor,
              ),
              // Text Center
              Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize:
                      fontSize, // React: 1em (relative to container font size)
                  fontWeight: fontWeight,
                  color: digitColor,
                  fontFamily: fontFamily,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ],
          ),
        ),
        if (showLabels) ...[
          // BUG 7 FIX: TSX gap(4) + marginTop(2) = 6px total
          SizedBox(height: 6.0 * scale), // TSX: gap(4) + marginTop(2)
          Text(
            labelText.toUpperCase(),
            style: TextStyle(
              fontSize: labelSize,
              color: effectiveLabelColor.withOpacity(labelOpacity),
              fontFamily: fontFamily,
              // BUG 19 FIX: Inherit container fontWeight
              fontWeight: fontWeight,
              height: 1.0,
            ),
          )
        ]
      ],
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (-pi/2)
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  // BUG 20 FIX: Add trackColor check
  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}

/// BUG 16 FIX: Animated ring widget that smoothly transitions progress.
/// Matches TSX: `transition: 'stroke-dashoffset 1s linear'`
class _AnimatedRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  const _AnimatedRing({
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = AlwaysStoppedAnimation(_currentProgress);
  }

  @override
  void didUpdateWidget(covariant _AnimatedRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      final oldProgress = _animation.value;
      _animation = Tween<double>(
        begin: oldProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      _controller.forward(from: 0.0);
      _currentProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: RingPainter(
            progress: _animation.value,
            strokeWidth: widget.strokeWidth,
            trackColor: widget.trackColor,
            progressColor: widget.progressColor,
          ),
        );
      },
    );
  }
}
