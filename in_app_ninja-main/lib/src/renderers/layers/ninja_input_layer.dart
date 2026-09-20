import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/ninja_input_registry.dart';
import 'ninja_layer_utils.dart';
import '../../utils/ninja_logger.dart';

class NinjaInputLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final double scale; // Horizontal Scale
  final double scaleY; // Vertical Scale
  final Size? parentSize;
  final Function(String action, Map<String, dynamic> data)? onAction;

  const NinjaInputLayer(
      {Key? key,
      required this.layer,
      this.parentSize,
      this.onAction,
      this.scale = 1.0,
      this.scaleY = 1.0})
      : super(key: key);

  @override
  State<NinjaInputLayer> createState() => _NinjaInputLayerState();
}

class _NinjaInputLayerState extends State<NinjaInputLayer> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;
  String? _validationError; // Local validation error state
  bool _isSubmitPressed = false; // For submit icon animation

  @override
  void initState() {
    super.initState();
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final variableName =
        content['variableName'] as String? ?? 'input_${widget.layer['id']}';

    // Fix: Restore value from registry if available (prevents reset/blink on rebuild)
    final savedValue = NinjaInputRegistry.getValue(variableName);
    final initialText = savedValue?.toString() ?? content['default'] ?? '';

    _controller = TextEditingController(text: initialText);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Fix: Listen for clear events (e.g. from Submit button)
    NinjaInputRegistry.clearNotifier.addListener(_onRegistryClear);
  }

  @override
  void dispose() {
    NinjaInputRegistry.clearNotifier.removeListener(_onRegistryClear);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onRegistryClear() {
    if (mounted) {
      _controller.clear();
      setState(() {
        // Clear validation errors if any
        _validationError = null;
      });
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  bool _validate() {
    final layer = widget.layer;
    final content = layer['content'] as Map<String, dynamic>? ?? {};

    final required = content['required'] == true;
    final validationRegex = content['validationRegex'] as String?;
    final errorMsg = content['errorMessage'] as String? ?? 'Invalid input';
    final value = _controller.text;

    // 1. Check Required
    if (required && value.trim().isEmpty) {
      setState(() {
        _validationError = errorMsg.isNotEmpty ? errorMsg : 'Field is required';
      });
      return false;
    }

    // 2. Check Regex
    if (validationRegex != null &&
        validationRegex.isNotEmpty &&
        value.isNotEmpty) {
      try {
        final regex = RegExp(validationRegex);
        if (!regex.hasMatch(value)) {
          setState(() {
            _validationError = errorMsg;
          });
          return false;
        }
      } catch (e) {
        NinjaLog.d('InputLayer', 'Invalid regex pattern: $validationRegex');
      }
    }

    setState(() {
      _validationError = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Web Parity Scale - Use passed scale
    final scale = widget.scale;
    final scaleY = widget.scaleY;
    final layer = widget.layer;
    final content = layer['content'] as Map<String, dynamic>? ?? {};
    final style = layer['style'] as Map<String, dynamic>? ?? {};

    // --- Content Properties ---
    final label = content['label'] as String?;
    final labelFontSizeRaw =
        NinjaLayerUtils.parseDouble(style['labelFontSize']);
    final labelFontSize = (labelFontSizeRaw ?? 12.0) * scale;
    final labelFontWeight =
        NinjaLayerUtils.parseFontWeight(style['labelFontWeight']?.toString()) ??
            FontWeight.w500;

    final helperText = content['helperText'] as String?;
    final placeholder = content['placeholder'] as String? ?? '';
    final variableName =
        content['variableName'] as String? ?? 'input_${layer['id']}';
    final required = content['required'] == true;
    // Don't show backend error if local validation exists
    final hasError = _validationError != null;
    final errorMessage = _validationError;

    // Input Type & Keyboard
    final inputType = content['inputType'] as String? ?? 'text';
    final keyboardTypeStr = content['keyboardType'] as String?;
    final isMultiline = inputType == 'multiline';

    TextInputType keyboardType;
    switch (keyboardTypeStr) {
      case 'emailAddress':
        keyboardType = TextInputType.emailAddress;
        break;
      case 'number':
        keyboardType = TextInputType.number;
        break;
      case 'phone':
        keyboardType = TextInputType.phone;
        break;
      case 'url':
        keyboardType = TextInputType.url;
        break;
      default:
        keyboardType =
            isMultiline ? TextInputType.multiline : TextInputType.text;
    }

    // --- Style Properties ---
    // Typography
    // Typography
    // Fix: React treats 0 as falsey for fontSize, defaulting to 14.
    final fontSizeRaw =
        NinjaLayerUtils.parseDouble(content['fontSize']) ?? 14.0;
    // Fix: Remove context from parseDouble to avoid Double Scaling
    // If parseDouble uses context, it uses MediaQuery. If we are ALREADY scaled by Floater Transform, we double scale.
    // By multiplying explicitly by widget.scale, we align with CopyButton/Button logic.
    final fontSize = ((fontSizeRaw == 0) ? 14.0 : fontSizeRaw) * scale;

    // Map string weight to FontWeight
    final fontWeightStr =
        (style['fontWeight'] ?? content['fontWeight'])?.toString();
    final fontWeight = NinjaLayerUtils.parseFontWeight(fontWeightStr);

    final textColor = NinjaLayerUtils.parseColor(content['textColor']) ??
        const Color(0xFF111827);
    final textAlignStr = style['textAlign']?.toString() ?? 'left';
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

    // Colors
    final backgroundColor =
        NinjaLayerUtils.parseColor(style['backgroundColor']) ?? Colors.white;
    final borderColor = NinjaLayerUtils.parseColor(style['borderColor']) ??
        const Color(0xFFD1D5DB);
    final focusBorderColor =
        NinjaLayerUtils.parseColor(style['focusBorderColor']) ??
            const Color(0xFF6366F1);
    final errorColor = NinjaLayerUtils.parseColor(style['errorColor']) ??
        const Color(0xFFEF4444);
    final labelColor = NinjaLayerUtils.parseColor(style['labelColor']) ??
        const Color(0xFF374151);
    final helperColor = NinjaLayerUtils.parseColor(style['helperColor']) ??
        const Color(0xFF6B7280);
    final placeholderColor =
        NinjaLayerUtils.parseColor(style['placeholderColor']) ??
            const Color(0xFF9CA3AF);

    // Dimensions & Box Model
    // React InputRenderer has explicit width: '100%'.
    // Dart: If style['width'] is null, parseResponsiveSize returns null.
    // Fix: Valid Auto Logic - If auto (null), fill available space if bounded, else standard.
    // We cannot use LayoutBuilder here easily as we are not returning one directly at root?
    // Wait, NinjaInputLayer returns Opacity > Container. We can wrap Opacity in LayoutBuilder?
    // Actually, we should use LayoutBuilder higher up or just return LayoutBuilder.
    // For now, let's use the parentSize if available, but if user explicitly wants auto, we need to respect constraints.
    // But NinjaInputLayer is already receiving parentSize!
    // And if parentSize is valid, width 'auto' (null) should imply 'stretch' in Column usually?
    // No, 'auto' in Column (crossAxis=Start) implies shrink.
    // Let's stick to safe fallback: If width is null, use null (shrink wrap/expand by flex).
    // BUT we need to avoid double.infinity crash if we try to force it.

    // Better Fix: Wrap in LayoutBuilder to get real constraints like CopyButtonLayer
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = NinjaLayerUtils.parseResponsiveSize(style['width'], context,
            isVertical: false,
            constraints: constraints,
            parentSize: widget.parentSize);

        if (width == null) {
          if (constraints.hasBoundedWidth &&
              constraints.maxWidth != double.infinity) {
            width = constraints.maxWidth; // Fill bounded width
          } else {
            width = widget.parentSize
                ?.width; // Fallback to parent width if known (often same as constraints)
            // If still null, it remains null (shrink wrap)
          }
        }

        var height = NinjaLayerUtils.parseResponsiveSize(
            style['height'], context,
            isVertical: true,
            constraints: constraints,
            parentSize: widget.parentSize);

        // Generic Padding Scaling (Top/Bottom only due to React quirks)
        final pTopRaw = NinjaLayerUtils.parseDouble(style['paddingTop'] ??
                style['paddingVertical'] ??
                style['padding']) ??
            10.0;
        final pBottomRaw = NinjaLayerUtils.parseDouble(style['paddingBottom'] ??
                style['paddingVertical'] ??
                style['padding']) ??
            10.0;

        // React Logic Replication (The "Logical Issue"):
        // React's input renderer ignores 'paddingHorizontal' for Left/Right due to an overriding logic bug.
        // Left: explicitly 'paddingLeft' OR 10.0.
        // Right: if submitButton needed ? 40.0 : 12.0. (Ignores even 'paddingRight').

        final pLeftRaw = NinjaLayerUtils.parseDouble(
            style['paddingLeft'] ?? 10.0); // Ignores paddingHorizontal

        final bool showSubmit = content['showSubmitButton'] == true;
        // Note: React uses 40px paddingRight for button.
        // In Flutter, SuffixIcon adds width.
        // If we use SuffixIcon, we shouldn't add 40px contentPadding, or we double up.
        // React's 40px is "Total Clearance".
        // Flutter SuffixIcon (18) + Pad(6) + Margin(8) = 32px width.
        // So we need 8px extra contentPadding to reach 40px?
        // OR we just use React's non-button default (12) and let Suffix push text?
        // Let's stick to the React Logic: Right is 12 if no button.
        final pRightRaw = showSubmit
            ? 12.0
            : 12.0; // Wait, if showSubmit is true, React sets 40.
        // But in Flutter, SuffixIcon handles the clearance dynamically.
        // IF I set contentPadding.right to 40 AND have an icon, text is pushed 40 + IconWidth.
        // So for Flutter, if showSubmit is true, we usually want minimal padding (0?) or correct padding.
        // BUT the user says "Logical Issue in React". I should match the "Default" logic.
        // Let's implement the React "Default" (12) and "Left" (10) parity.

        final padding = EdgeInsets.fromLTRB(
            (pLeftRaw ?? 10.0) * scale,
            pTopRaw * scaleY,
            (pRightRaw) * scale, // 12.0 * scale
            pBottomRaw * scaleY);

        // Fix: Removed Strict Padding Override (40px) - SuffixIcon handles it.

        final borderRadiusRaw = NinjaLayerUtils.parseDouble(
            (style['borderRadius'] == 0 || style['borderRadius'] == null)
                ? 6
                : style['borderRadius']);
        final borderRadiusVal = (borderRadiusRaw ?? 6.0) * scale;

        // Border Logic (Matches NinjaCopyButtonLayer)
        final borderWidthRaw =
            NinjaLayerUtils.parseDouble(style['borderWidth'] ?? 1);
        final borderWidthVal = (borderWidthRaw ?? 1.0) * scale;
        final borderStyle =
            style['borderStyle']?.toString().toLowerCase() ?? 'solid';
        // Fix: Use CustomPainter for ALL borders to ensure consistent rendering (Solid/Dashed/Dotted)
        final bool usePainter = borderStyle != 'none';
        final double actualBorderWidth =
            (borderWidthVal > 0 && borderStyle != 'none')
                ? borderWidthVal
                : 0.0;

        // Compensate Padding for Border (Box Model Parity)
        final effectivePadding = EdgeInsets.only(
            top: padding.top + actualBorderWidth,
            right: padding.right + actualBorderWidth,
            bottom: padding.bottom + actualBorderWidth,
            left: padding.left + actualBorderWidth);

        final opacity = NinjaLayerUtils.parseDouble(style['opacity']) ?? 1.0;

        // ... (Shadows logic same as before) ...
        // Fix: Valid Shadow Logic
        List<BoxShadow>? shadows;
        if (style['shadowEnabled'] == true) {
          final color =
              NinjaLayerUtils.parseColor(style['shadowColor']) ?? Colors.black;
          final blur =
              (NinjaLayerUtils.parseDouble(style['shadowBlur']) ?? 0.0) * scale;
          final spread =
              (NinjaLayerUtils.parseDouble(style['shadowSpread']) ?? 0.0) *
                  scale;
          final rawOffsetY = style['shadowOffsetY'];
          final offsetYVal = (rawOffsetY == 0) ? 4.0 : (rawOffsetY ?? 4);
          final offsetY =
              (NinjaLayerUtils.parseDouble(offsetYVal) ?? 4.0) * scale;

          shadows = [
            BoxShadow(
              color: color,
              offset: Offset(0, offsetY),
              blurRadius: blur,
              spreadRadius: spread,
            )
          ];
        } else {
          shadows = NinjaLayerUtils.parseShadowFromStyle(style, context);
        }

        // Font Family
        String? fontFamily = (content['fontFamily'] as String?)?.trim() ??
            (style['fontFamily'] as String?)?.trim() ??
            'inherit';
        final fontUrl = content['fontUrl'] as String?;
        if (fontUrl != null && fontUrl.isNotEmpty) {
          final urlFamily = NinjaLayerUtils.getFontFamilyFromUrl(fontUrl);
          if (urlFamily != null) fontFamily = urlFamily;
        }

        // Offsets
        final textOffsetX =
            (NinjaLayerUtils.parseDouble(style['textOffsetX']) ?? 0.0) * scale;
        final textOffsetY =
            (NinjaLayerUtils.parseDouble(style['textOffsetY']) ?? 0.0) * scale;
        final iconOffsetX =
            (NinjaLayerUtils.parseDouble(style['iconOffsetX']) ?? 0.0) * scale;
        final iconOffsetY =
            (NinjaLayerUtils.parseDouble(style['iconOffsetY']) ?? 0.0) * scale;

        // Calculate effective Border
        final effectiveBorderColor = hasError
            ? errorColor
            : (_isFocused ? focusBorderColor : borderColor);

        // Build Text Style
        TextStyle textStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          // Fix: Parity - Remove height: 1.4 from Input to match browser default (~1.15)
          // height: 1.4,
          leadingDistribution: TextLeadingDistribution.proportional,
          letterSpacing: 0.4 * scale,
        );

        if (fontFamily != null && fontFamily != 'inherit') {
          final googleFont =
              NinjaLayerUtils.getGoogleFont(fontFamily, textStyle: textStyle);
          if (googleFont != null) {
            textStyle = googleFont;
          } else {
            textStyle = textStyle.copyWith(fontFamily: fontFamily);
          }
        }

        // Container Content

        return Opacity(
          opacity: opacity,
          child: Container(
            width: width,
            height: height,
            // Fix: Removed Outer Constraints. Height logic is now handled by internal sizing (Label + InputBox).
            // If 'height' is explicit, Container enforces it.
            // If 'height' is null (auto), Column calculates size.
            // constraints: ... REMOVED
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  height != null ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // Label
                if (label != null && label.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      text: label,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: labelFontWeight,
                        color: labelColor,
                        fontFamily: textStyle.fontFamily,
                        height: 1.4, // React Parity: Label uses 1.4
                      ),
                      children: [
                        if (required)
                          WidgetSpan(
                              child: SizedBox(
                                  width: 2.0 *
                                      scale)), // Fix: Pixel parity (2px gap)
                        if (required)
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: errorColor),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.0 * scaleY),
                ],

                // Input Field Wrapper (Background, Border, Shadow)
                // Fix: Click-to-Focus Area (GestureDetector)
                // Input Field Wrapper (Background, Border, Shadow)
                // Fix: Auto Height logic
                // If height is fixed (!= null), we Expand to fill it.
                // If height is auto (== null), we allow it to match child size (Flexible loose), so it grows with fontSize.
                // Input Field Wrapper (Background, Border, Shadow)
                // React Logic:
                // - If container Height is Fixed: Input fills it (flex: 1).
                // - If container Height is Auto: Input grows with Content (FontSize + Padding), respected by MinHeight.
                (height != null)
                    ? Expanded(
                        child: _buildInputWrapper(
                            scale,
                            scaleY,
                            isMultiline,
                            backgroundColor,
                            borderRadiusVal,
                            usePainter,
                            hasError,
                            errorColor,
                            focusBorderColor,
                            borderColor,
                            actualBorderWidth,
                            shadows,
                            textOffsetX,
                            textOffsetY,
                            textAlign,
                            textStyle,
                            keyboardType,
                            content,
                            placeholderColor,
                            effectivePadding,
                            variableName,
                            borderStyle,
                            padding,
                            widget.layer,
                            iconOffsetX,
                            iconOffsetY // Passed icon offsets
                            ),
                      )
                    : _buildInputWrapper(
                        // Auto Height: Let child resize itself
                        scale,
                        scaleY,
                        isMultiline,
                        backgroundColor,
                        borderRadiusVal,
                        usePainter,
                        hasError,
                        errorColor,
                        focusBorderColor,
                        borderColor,
                        actualBorderWidth,
                        shadows,
                        textOffsetX,
                        textOffsetY,
                        textAlign,
                        textStyle,
                        keyboardType,
                        content,
                        placeholderColor,
                        effectivePadding,
                        variableName,
                        borderStyle,
                        padding,
                        widget.layer,
                        iconOffsetX,
                        iconOffsetY // Passed icon offsets
                        ),

                // Helper/Error Text
                if (hasError) ...[
                  SizedBox(height: 4.0 * scaleY),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      fontSize: 11.0 * scale,
                      color: errorColor,
                      height: 1.4,
                      fontFamily: textStyle.fontFamily,
                      leadingDistribution: TextLeadingDistribution.proportional,
                      letterSpacing: 0.4 * scale,
                    ),
                  ),
                ] else if (helperText != null && helperText.isNotEmpty) ...[
                  SizedBox(height: 4.0 * scaleY),
                  Text(
                    helperText,
                    style: TextStyle(
                      fontSize: 11.0 * scale,
                      color: helperColor,
                      height: 1.4,
                      fontFamily: textStyle.fontFamily,
                      leadingDistribution: TextLeadingDistribution.proportional,
                      letterSpacing: 0.4 * scale,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Extracted Helper for Input Wrapper
  Widget _buildInputWrapper(
      double scale,
      double scaleY,
      bool isMultiline,
      Color? backgroundColor,
      double borderRadiusVal,
      bool useCustomBorder,
      bool hasError,
      Color errorColor,
      Color focusBorderColor,
      Color borderColor,
      double actualBorderWidth,
      List<BoxShadow>? shadows,
      double textOffsetX,
      double textOffsetY,
      TextAlign textAlign,
      TextStyle textStyle,
      TextInputType keyboardType,
      Map<String, dynamic> content,
      Color placeholderColor,
      EdgeInsets effectivePadding,
      String variableName,
      String borderStyle,
      EdgeInsets padding,
      Map<String, dynamic> layer,
      double iconOffsetX,
      double iconOffsetY // Added icon params
      ) {
    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        // Fix: MinHeight Logic (Wrapper)
        constraints: BoxConstraints(
            minHeight: isMultiline ? (60.0 * scaleY) : (36.0 * scaleY)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadiusVal),
          border: useCustomBorder
              ? null
              : Border.all(
                  color: hasError
                      ? errorColor
                      : (_isFocused ? focusBorderColor : borderColor),
                  width: actualBorderWidth,
                ),
          boxShadow: shadows,
        ),
        child: Stack(
          alignment: isMultiline
              ? Alignment.topLeft
              : Alignment.centerLeft, // Fix: Vertical Center for Input
          children: [
            // 1. Text Field (Fills space, Padding handles clearance)
            Transform.translate(
              offset: Offset(textOffsetX, textOffsetY),
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: true,
                  textAlign: textAlign,
                  textAlignVertical: isMultiline
                      ? TextAlignVertical.top
                      : TextAlignVertical.center, // Fix: Center Text
                  style: textStyle,
                  // Fix: Multiline Alignment
                  maxLines: isMultiline ? null : 1,
                  minLines: isMultiline ? 2 : 1,
                  keyboardType: keyboardType, // Access local variable
                  obscureText: content['inputType'] == 'password',
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    hintText: content['placeholder'] ?? 'Enter text...',
                    hintStyle: textStyle.copyWith(
                      color: placeholderColor,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    // Fix: Padding Logic (Direct Parity)
                    contentPadding: EdgeInsets.fromLTRB(
                        padding!.left,
                        padding.top,
                        // If button exists, Force 40px right padding on text to avoid overlap
                        // Else use parsed right padding (usually 12 or 10)
                        (content['showSubmitButton'] == true)
                            ? (40.0 * scale)
                            : padding.right,
                        padding.bottom),
                  ),
                  onChanged: (val) {
                    NinjaInputRegistry.register(variableName, val);
                    if (_validationError != null && val.isNotEmpty) {
                      setState(() {
                        _validationError = null;
                      });
                    }
                  },
                ),
              ),
            ),

            // 2. Dashed Border Overlay (if needed)
            if (useCustomBorder)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DashedBorderPainter(
                      color: hasError
                          ? errorColor
                          : (_isFocused ? focusBorderColor : borderColor),
                      strokeWidth: actualBorderWidth,
                      radius: borderRadiusVal,
                      dashPattern: [
                        4.0 * scale,
                        4.0 * scale
                      ], // Match copy button defaults
                      borderStyle: borderStyle,
                    ),
                  ),
                ),
              ),

            // 3. Suffix Button (Layered on top)
            if (content['showSubmitButton'] == true)
              Positioned(
                right: 8.0 * scale, // React: right: 8px
                top: 0,
                bottom: 0,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(
                        iconOffsetX, iconOffsetY), // Fix: Apply Icon Offsets
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isSubmitPressed = true),
                      onTapUp: (_) => setState(() => _isSubmitPressed = false),
                      onTapCancel: () =>
                          setState(() => _isSubmitPressed = false),
                      onTap: () {
                        // Validate logic
                        final val = _controller.text;
                        bool isValid = true;

                        // Required Check
                        if (content['required'] == true && val.trim().isEmpty) {
                          setState(() {
                            _validationError =
                                content['errorMessage'] ?? 'Field is required';
                          });
                          isValid = false;
                        }

                        // Regex Check
                        if (isValid && content['validationRegex'] != null) {
                          try {
                            final reg = RegExp(content['validationRegex']);
                            if (!reg.hasMatch(val)) {
                              setState(() {
                                _validationError =
                                    content['errorMessage'] ?? 'Invalid input';
                              });
                              isValid = false;
                            }
                          } catch (_) {}
                        }

                        if (isValid) {
                          // Fix: Default to 'submit' if no action explicit (Parity with React default)
                          final action = widget.layer['action'] ??
                              content['action'] ??
                              {'type': 'submit'};
                          if (widget.onAction != null && action['type'] != 'none') {
                            widget.onAction?.call(action['type'] ?? 'submit',
                                {'input': val, ...?action});
                          }
                        }
                      },
                      child: AnimatedScale(
                        scale: _isSubmitPressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            // Wrap for hit test area?
                            padding: EdgeInsets.all(6.0 * scale),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0 * scale),
                              // React has hover effect, we skip for now or add InkWell
                            ),
                            child: _buildSuffixIcon(content['submitIcon'],
                                isFocused: _isFocused ||
                                    (layer['style']?['focusBorderColor'] !=
                                        null),
                                scale: scale),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(String? iconName,
      {required bool isFocused, required double scale}) {
    IconData iconData;
    switch (iconName) {
      case 'ArrowRight':
        iconData = Icons.arrow_forward;
        break;
      case 'Check':
        iconData = Icons.check;
        break;
      case 'Search':
        iconData = Icons.search;
        break;
      case 'Plus':
        iconData = Icons.add;
        break;
      case 'Send':
      default:
        iconData = Icons.send;
        break;
    }

    final style = widget.layer['style'] as Map<String, dynamic>? ?? {};
    final focusColor = NinjaLayerUtils.parseColor(style['focusBorderColor']) ??
        const Color(0xFF6366F1);
    final iconSize = 18.0 * scale;

    return Icon(
      iconData,
      size: iconSize,
      color: isFocused ? focusColor : const Color(0xFF9CA3AF),
    );
  }
}

// Copied from ninja_copy_button_layer.dart for self-contained parity
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
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth,
          size.height - strokeWidth),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);

    if (borderStyle == 'solid') {
      canvas.drawPath(path, paint);
      return;
    }

    final Path dashedPath = Path();

    final double dashSize = dashPattern[0];
    final double gapSize =
        dashPattern.length > 1 ? dashPattern[1] : dashPattern[0];

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        if (isDotted) {
          dashedPath.addPath(
            metric.extractPath(distance, distance),
            Offset.zero,
          );
          distance += gapSize + strokeWidth;
        } else {
          final double length = (distance + dashSize > metric.length)
              ? (metric.length - distance)
              : dashSize;
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
