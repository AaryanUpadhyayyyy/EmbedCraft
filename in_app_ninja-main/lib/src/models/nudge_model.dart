// ignore_for_file: prefer_typing_uninitialized_variables

/// Nudge Model classes to support strict typing in FloaterRenderV2
/// Adapts from loose Map structures in Campaign

import '../renderers/layers/ninja_layer_utils.dart';

/// Safely cast a dynamic map to Map<String, dynamic>
/// Handles Map<dynamic, dynamic> from JSON decode and nested maps
Map<String, dynamic> _safeCast(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return {};
}

/// Safely cast a nullable dynamic map
Map<String, dynamic>? _safeCastNullable(dynamic value) {
  if (value == null) return null;
  return _safeCast(value);
}

class NudgeConfig {
  final Map<String, dynamic> raw; // Keep raw for fallback
  final NudgeStyle? style;
  final NudgeMedia? media;
  final NudgeAnimation? animation;
  final String? width;
  final String? height;
  final bool? expanded;
  final String? backgroundImageUrl;
  final String? backgroundColor;
  final String? borderColor;
  final num? borderWidth; // num to handle int/double
  final dynamic borderRadius; // Changed to dynamic to handle num or Map
  final Map<String, dynamic>? colors;
  final NudgeShadow? shadow;
  final Map<String, dynamic>? controls; // For close button etc
  final bool? showCloseButton;
  final NudgeBehavior? behavior;
  final String? position;
  final num? offsetX;
  final num? offsetY;
  final String? backgroundSize; // Added for parity
  final Map<String, dynamic>? overlay;
  final String? shape; // Added for parity
  final String? boxShadow; // Added for parity (fallback string)
  final String? borderStyle; // Added for parity
  final String? sizeUnit; // Added for parity

  NudgeConfig({
    required this.raw,
    this.style,
    this.media,
    this.animation,
    this.width,
    this.height,
    this.expanded,
    this.backgroundImageUrl,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.colors,
    this.shadow,
    this.controls,
    this.showCloseButton,
    this.behavior,
    this.position,
    this.offsetX,
    this.offsetY,
    this.backgroundSize,
    this.overlay,
    this.shape,
    this.boxShadow,
    this.borderStyle,
    this.sizeUnit,
  });

  factory NudgeConfig.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return NudgeConfig(
      raw: json,
      style: json['style'] != null ? NudgeStyle.fromJson(json['style']) : null,
      media: json['media'] != null ? NudgeMedia.fromJson(json['media']) : null,
      animation: json['animation'] != null
          ? NudgeAnimation.fromJson(json['animation'])
          : null,
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      expanded: json['expanded'] == true,
      backgroundImageUrl: json['backgroundImageUrl']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      borderColor: json['borderColor']?.toString(),
      borderWidth: json['borderWidth'],
      borderRadius: json['borderRadius'], // Can be Map or num
      colors: _safeCastNullable(json['colors']),
      shadow:
          json['shadow'] != null ? NudgeShadow.fromJson(json['shadow']) : null,
      controls: _safeCastNullable(json['controls']),
      // Missing fields added
      showCloseButton: json['showCloseButton'] == true,
      behavior: NudgeBehavior.fromJson(
          json['behavior'] ?? {}), // Ensure defaults apply even if missing
      position: json['position']?.toString(),
      offsetX: json['offsetX'],
      offsetY: json['offsetY'],
      backgroundSize: json['backgroundSize']?.toString(),
      overlay: _safeCastNullable(json['overlay']),
      shape: json['shape']?.toString(),
      boxShadow: json['boxShadow']?.toString(),
      borderStyle: json['borderStyle']?.toString(),
      sizeUnit: json['sizeUnit']?.toString(),
    );
  }
}

class NudgeBehavior {
  final bool? draggable;
  final bool? snapToCorner;
  final bool? doubleTapToDismiss;

  NudgeBehavior({this.draggable, this.snapToCorner, this.doubleTapToDismiss});

  factory NudgeBehavior.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return NudgeBehavior(
      draggable:
          NinjaLayerUtils.parseBoolean(json['draggable']), // Default NULL
      snapToCorner:
          NinjaLayerUtils.parseBoolean(json['snapToCorner']), // Default NULL
      doubleTapToDismiss:
          NinjaLayerUtils.parseBoolean(json['doubleTapToDismiss']) ??
              false, // Default false (safe)
    );
  }
}

class Layer {
  final String id;
  final String type;
  final String? name;
  final String? parent;
  final bool? visible;
  final NudgeStyle? style;
  final Map<String, dynamic> content;
  final Map<String, dynamic> raw;

  Layer({
    required this.id,
    required this.type,
    this.name,
    this.parent,
    this.visible,
    this.style,
    required this.content,
    required this.raw,
  });

  factory Layer.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return Layer(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'div',
      name: json['name']?.toString(),
      parent: json['parent']?.toString(),
      visible: json['visible'] != false,
      style: json['style'] != null ? NudgeStyle.fromJson(json['style']) : null,
      content: _safeCast(json['content']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;

  dynamic operator [](String key) => raw[key];
}

class NudgeStyle {
// ... existing NudgeStyle code ...
  final String? width; // String for %
  final String? height;
  final String? backgroundColor;
  final String? backgroundImage;

  // Flex
  final String? flexDirection;
  final String? alignItems;
  final String? justifyContent;
  final dynamic gap; // num or string px

  // Spacing
  final dynamic padding;
  final dynamic paddingTop;
  final dynamic paddingBottom;
  final dynamic paddingLeft;
  final dynamic paddingRight;

  final dynamic margin; // Support shorthand
  final dynamic marginTop;
  final dynamic marginBottom;
  final dynamic marginLeft;
  final dynamic marginRight;

  // Position
  final String? position; // absolute, relative
  final dynamic top;
  final dynamic bottom;
  final dynamic left;
  final dynamic right;

  // Border
  final dynamic borderRadius; // Can be Map or num
  final dynamic borderWidth;
  final String? borderColor;
  final String? borderStyle;

  // Misc
  final dynamic opacity;
  final Map<String, dynamic>? transform;
  final Map<String, dynamic>? filter;
  final dynamic zIndex;

  final Map<String, dynamic> _raw;

  NudgeStyle(
      {this.width,
      this.height,
      this.backgroundColor,
      this.backgroundImage,
      this.flexDirection,
      this.alignItems,
      this.justifyContent,
      this.gap,
      this.padding,
      this.paddingTop,
      this.paddingBottom,
      this.paddingLeft,
      this.paddingRight,
      this.margin,
      this.marginTop,
      this.marginBottom,
      this.marginLeft,
      this.marginRight,
      this.position,
      this.top,
      this.bottom,
      this.left,
      this.right,
      this.borderRadius,
      this.borderWidth,
      this.borderColor,
      this.borderStyle,
      this.opacity,
      this.transform,
      this.filter,
      this.zIndex,
      required Map<String, dynamic> raw})
      : _raw = raw;

  factory NudgeStyle.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return NudgeStyle(
      raw: json,
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      backgroundImage: json['backgroundImage']?.toString(),
      flexDirection: json['flexDirection']?.toString(),
      alignItems: json['alignItems']?.toString(),
      justifyContent: json['justifyContent']?.toString(),
      gap: json['gap'],
      padding: json['padding'],
      paddingTop: json['paddingTop'],
      paddingBottom: json['paddingBottom'],
      paddingLeft: json['paddingLeft'],
      paddingRight: json['paddingRight'],
      margin: json['margin'],
      marginTop: json['marginTop'],
      marginBottom: json['marginBottom'],
      marginLeft: json['marginLeft'],
      marginRight: json['marginRight'],
      position: json['position']?.toString(),
      top: json['top'],
      bottom: json['bottom'],
      left: json['left'],
      right: json['right'],
      borderRadius: json['borderRadius'],
      borderWidth: json['borderWidth'],
      borderColor: json['borderColor']?.toString(),
      borderStyle: json['borderStyle']?.toString(),
      opacity: json['opacity'],
      transform: _safeCastNullable(json['transform']),
      filter: _safeCastNullable(json['filter']),
      zIndex: json['zIndex'],
    );
  }

  dynamic operator [](String key) => _raw[key];
}

class NudgeMedia {
  final String? url;
  final String? type;
  final bool? autoPlay;
  final bool? muted;
  final bool? loop;
  final String? fit;

  NudgeMedia(
      {this.url, this.type, this.autoPlay, this.muted, this.loop, this.fit});

  factory NudgeMedia.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return NudgeMedia(
      url: json['url']?.toString(),
      type: json['type']?.toString(),
      autoPlay: json['autoPlay'] == true,
      muted: json['muted'] == true,
      loop: json['loop'] == true,
      fit: json['fit']?.toString(),
    );
  }
}

class NudgeAnimation {
  final String? type;
  final int? duration;
  final String? easing;

  NudgeAnimation({this.type, this.duration, this.easing});

  factory NudgeAnimation.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return NudgeAnimation(
      type: json['type']?.toString(),
      duration: int.tryParse(json['duration']?.toString() ?? ''),
      easing: json['easing']?.toString(),
    );
  }
}

class NudgeShadow {
  final String? color;
  final num? blur;
  final num? spread;
  final num? x;
  final num? y;

  NudgeShadow({this.color, this.blur, this.spread, this.x, this.y});

  factory NudgeShadow.fromJson(dynamic rawJson) {
    final json = _safeCast(rawJson);
    return NudgeShadow(
      color: json['color']?.toString(),
      blur: json['blur'],
      spread: json['spread'],
      x: json['x'],
      y: json['y'],
    );
  }
}
