import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../app_ninja.dart';
import '../../utils/ninja_logger.dart';

import '../../utilities/sharedHelper/design_scale.dart';

class NinjaLayerUtils {

  // ✅ BUNDLED FONTS: Pre-cached fonts for instant loading
  // These fonts work offline and load instantly via google_fonts package
  static const List<String> supportedFonts = [
    // Sans-Serif
    'Roboto', 'Inter', 'Poppins', 'Open Sans', 'Lato',
    'Montserrat', 'Nunito', 'Raleway', 'Ubuntu', 'Source Sans Pro',
    // Serif
    'Playfair Display', 'Merriweather', 'Lora', 'PT Serif',
    // Monospace
    'Fira Code', 'Source Code Pro', 'JetBrains Mono',
    // Decorative
    'Pacifico', 'Dancing Script', 'Lobster',
  ];

  /// Resolves dynamic placeholders to their active State values.
  static String resolveText(String text) {
    if (text.isEmpty) return text;
    String resolved = text;
    
    final rewardName = AppNinja.stwRewardName;
    final spinsLeft = AppNinja.stwSpinsLeft.toString();
    final maxSpins = AppNinja.stwMaxSpins.toString();
    final couponCode = AppNinja.stwRewardDetails['couponCode']?.toString() 
                     ?? AppNinja.stwRewardDetails['code']?.toString() 
                     ?? '';

    // First replace spins_left and max_spins
    resolved = resolved.replaceAll('{{spins_left}}', spinsLeft)
                       .replaceAll('{{max_spins}}', maxSpins);

    // Now resolve any other placeholder dynamically
    final templateRegExp = RegExp(r'\{\{([^}]+)\}\}');
    resolved = resolved.replaceAllMapped(templateRegExp, (match) {
      final key = match.group(1)!.trim();
      
      // Map legacy placeholders
      final actualKey = (key == 'reward_name' || key == 'section_name') ? 'name' : key;
      
      if (actualKey == 'name') {
        return rewardName;
      }
      
      final details = AppNinja.stwRewardDetails;

      // Local helper to look up properties
      dynamic getPropValue(String k) {
        if (details.containsKey(k)) return details[k];
        
        // Check under nested configs
        for (var configName in ['couponConfig', 'pointsConfig', 'featureConfig']) {
          if (details.containsKey(configName) && details[configName] is Map) {
            final config = details[configName] as Map;
            if (config.containsKey(k)) return config[k];
          }
        }
        return null;
      }

      // Convert actualKey to camelCase
      String camelKey = actualKey;
      if (actualKey.contains('_')) {
        final parts = actualKey.split('_');
        camelKey = parts[0] + parts.sublist(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join('');
      }

      // Handle coupon_code lookup specifically
      if (actualKey == 'coupon_code') {
        final val = getPropValue('couponCode') ?? getPropValue('code');
        if (val != null) return val.toString();
        // Fallback to local couponCode variable computed above
        if (couponCode.isNotEmpty) return couponCode;
      }

      // Handle icon / imageUrl lookup specifically
      if (actualKey == 'icon' || actualKey == 'iconUrl' || actualKey == 'icon_url' || actualKey == 'imageUrl' || actualKey == 'image_url') {
        final val = getPropValue('iconUrl') ?? getPropValue('icon') ?? getPropValue('imageUrl') ?? getPropValue('image_url');
        if (val != null) return val.toString();
      }

      // Handle generic value lookup specifically
      if (actualKey == 'value') {
        final val = getPropValue('couponValue') ?? getPropValue('amount') ?? getPropValue('value');
        if (val != null) return val.toString();
      }

      // General lookups
      final originalVal = getPropValue(actualKey);
      if (originalVal != null) return originalVal.toString();

      final camelVal = getPropValue(camelKey);
      if (camelVal != null) return camelVal.toString();

      return '';
    });

    return resolved;
  }

  static dynamic _interpolateRecursively(dynamic data, Map<String, dynamic> mappedData, RegExp templateRegExp) {
    if (data is String && data.contains('{{')) {
      String newValue = data;
      final matches = templateRegExp.allMatches(data);
      for (final match in matches) {
        final placeholder = match.group(0)!;
        final path = match.group(1)!.trim();
        dynamic dataValue = mappedData;
        
        // Handle custom flat placeholders mapped to nested objects
        if (path == 'coupon_code') {
          if (mappedData['couponConfig'] is Map && mappedData['couponConfig']['code'] != null) {
            dataValue = mappedData['couponConfig']['code'];
          } else {
            dataValue = null;
          }
        } else if (path == 'coupon_value') {
          if (mappedData['couponConfig'] is Map && mappedData['couponConfig']['couponValue'] != null) {
            dataValue = mappedData['couponConfig']['couponValue'];
          } else {
            dataValue = null;
          }
        } else if (path == 'coupon_type') {
          if (mappedData['couponConfig'] is Map && mappedData['couponConfig']['couponType'] != null) {
            dataValue = mappedData['couponConfig']['couponType'];
          } else {
            dataValue = null;
          }
        } else if (path == 'points') {
          if (mappedData['pointsConfig'] is Map && mappedData['pointsConfig']['points'] != null) {
            dataValue = mappedData['pointsConfig']['points'];
          } else {
            dataValue = null;
          }
        } else if (path == 'total_quantity') {
          if (mappedData['inventory'] is Map && mappedData['inventory']['total_quantity'] != null) {
            dataValue = mappedData['inventory']['total_quantity'];
          } else {
            dataValue = null;
          }
        } else {
          // Standard nested path resolution
          for (var p in path.split('.')) {
            if (dataValue is Map && dataValue.containsKey(p)) {
              dataValue = dataValue[p];
            } else {
              dataValue = null;
              break;
            }
          }
        }

        if (dataValue != null) {
          newValue = newValue.replaceAll(placeholder, dataValue.toString());
        }
      }
      return newValue;
    } else if (data is Map) {
      final newMap = <String, dynamic>{};
      data.forEach((key, value) {
        newMap[key.toString()] = _interpolateRecursively(value, mappedData, templateRegExp);
      });
      return newMap;
    } else if (data is List) {
      return data.map((item) => _interpolateRecursively(item, mappedData, templateRegExp)).toList();
    }
    return data;
  }

  /// Synchronously injects mappedData into layer string contents over {{placeholder}} paths.
  static Map<String, dynamic> applyMappedData(Map<String, dynamic> layerInfo, Map<String, dynamic>? mappedData) {
    if (mappedData == null) return layerInfo;

    final templateRegExp = RegExp(r'\{\{([^}]+)\}\}');
    Map<String, dynamic> resolvedLayer = _interpolateRecursively(layerInfo, mappedData, templateRegExp) as Map<String, dynamic>;
    
    // Save context inside layer so child containers inherit it!
    resolvedLayer['mappedState'] = mappedData;
    
    return resolvedLayer;
  }

  /// Check if a font is in the supported bundled fonts list
  static bool isSupportedFont(String fontFamily) {
    final cleanName = fontFamily
        .split(',')
        .first
        .trim()
        .replaceAll("'", "")
        .replaceAll('"', "");
    return supportedFonts
        .any((f) => f.toLowerCase() == cleanName.toLowerCase());
  }

  static double? parseDouble(dynamic value,
      [BuildContext? context, bool isVertical = false]) {
    if (value == null) return null;
    double? result;

    if (value is num) {
      result = value.toDouble();
    } else if (value is String) {
      // Percentage check
      if (value.trim().endsWith('%')) return null;
      // FIX: Mimic React's parseFloat behavior - extract leading number from string
      // parseFloat("12px") -> 12, parseFloat("14.5em") -> 14.5, parseFloat("100") -> 100
      final match = RegExp(r'^-?\d+\.?\d*').firstMatch(value.trim());
      if (match != null) {
        result = double.tryParse(match.group(0)!);
      }
    }

    // Dynamic Density: RE-ENABLED for Layout Sync.
    // Dashboard (375px) vs Device (e.g. 400px).
    // Images scale with width (Aspect Ratio). Fixed coords MUST scale too used to prevent overlap.
    if (context != null && result != null) {
      final size = MediaQuery.of(context).size;
      if (isVertical) {
        // Fix 16: Vertical Positioning scales with HEIGHT to match 'cover' background behavior
        return result * (size.height / kNinjaDesignHeight);
      } else {
        // Horizontal / Size uses WIDTH scaling
        return result * (size.width / kNinjaDesignWidth);
      }
    }

    return result;
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final match = RegExp(r'^-?\d+').firstMatch(value.trim());
      if (match != null) {
        return int.tryParse(match.group(0)!);
      }
    }
    return null;
  }

  static bool? parseBoolean(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final v = value.toLowerCase().trim();
      if (v == 'true' || v == '1' || v == 'yes' || v == 'on') return true;
      if (v == 'false' || v == '0' || v == 'no' || v == 'off' || v.isEmpty)
        return false;
      return null;
    }
    if (value is num) {
      if (value == 1) return true;
      if (value == 0) return false;
      return null;
    }
    return null;
  }

  static double? parseSize(dynamic value,
      [BuildContext? context, bool isVertical = false]) {
    if (value == 'auto' || value == null) return null;
    return parseDouble(value, context, isVertical);
  }

  /// Solves the required container height to fit all layers.
  /// Handles both fixed pixels (Top + Height) and percentages (Top / (1 - Pct)).
  static double solveRequiredHeight(List<dynamic> layers) {
    double maxH = 0.0;

    for (var layer in layers) {
      if (layer is! Map<String, dynamic>) continue;

      final style = layer['style'] as Map<String, dynamic>? ?? {};
      // Skip non-absolute (flow) layers for this calculation, or assume flow adds to height separately?
      // For now focusing on absolute layers which caused the collapse.
      if (style['position'] != 'absolute') continue;

      final top = parseDouble(style['top']) ??
          0; // Context missing in static calc, acceptable?
      final hVal = style['height'];

      if (hVal is String && hVal.trim().endsWith('%')) {
        // Percentage Case: P = Top / (1 - Pct)
        try {
          final pct = double.parse(hVal.replaceAll('%', '')) / 100.0;
          if (pct < 1.0) {
            final req = top / (1.0 - pct);
            if (req > maxH) maxH = req;
          }
        } catch (_) {}
      } else {
        // Pixel Case: P = Top + Height
        final h = parseSize(hVal) ?? 0;
        if (top + h > maxH) maxH = top + h;
      }
    }

    return maxH;
  }

  /// Parses a size value, handling px (10px) and % (50%) values.
  /// For percentages, [context] and [isVertical] are required to resolve against viewport.
  /// [constraints] can be provided to resolve % against the parent container instead of screen.
  static double? parseResponsiveSize(dynamic value, BuildContext context,
      {bool isVertical = false,
      BoxConstraints? constraints,
      Size? parentSize}) {
    if (value == null) return null;

    if (value is String && value.trim().endsWith('%')) {
      try {
        final pct = double.parse(value.replaceAll('%', '')) / 100.0;

        // 0. Priority: Explicit Parent Size (passed from Container)
        // This ensures % is relative to the Nudge Container, not Screen/Constraints
        if (parentSize != null) {
          return isVertical ? parentSize.height * pct : parentSize.width * pct;
        }

        // 1. Try resolving against Parent Constraints (LayoutBuilder)
        if (constraints != null) {
          if (isVertical && constraints.hasBoundedHeight) {
            return constraints.maxHeight * pct;
          }
          if (!isVertical && constraints.hasBoundedWidth) {
            return constraints.maxWidth * pct;
          }
        }

        // 2. Fallback to Screen Size (MediaQuery)
        final screenSize = MediaQuery.of(context).size;
        final total = isVertical ? screenSize.height : screenSize.width;
        return total * pct;
      } catch (_) {
        return null;
      }
    }

    // For PIXEL values: Use screen-based scaling (not container-relative)
    // This ensures sizes (width, height, fontSize) scale correctly
    // Container-relative scaling is handled in NinjaLayerBuilder._buildPositioned for positions only
    return parseSize(value, context, isVertical);
  }

  /// PARITY FIX: Get container-relative scale factor
  /// Dashboard formula: containerDim / designDim
  static double getScale(Size parentSize, {bool isVertical = false}) {
    if (isVertical) {
      return parentSize.height / kNinjaDesignHeight;
    }
    return parentSize.width / kNinjaDesignWidth;
  }

  /// PARITY FIX: Scale a value using container-relative scale
  /// Dashboard formula: px × (containerDim / designDim)
  static double? scaleValue(dynamic value, Size parentSize,
      {bool isVertical = false}) {
    if (value == null) return null;
    final str = value.toString().trim();
    // Percentages resolve against parent
    if (str.endsWith('%')) {
      final pct = double.tryParse(str.replaceAll('%', ''));
      if (pct == null) return null;
      return (isVertical ? parentSize.height : parentSize.width) * pct / 100;
    }
    // Pixels scale with container
    final px = double.tryParse(str.replaceAll('px', ''));
    if (px == null) return null;
    return px * getScale(parentSize, isVertical: isVertical);
  }

  /// PARITY FIX: Convert pixel position to container-relative position
  /// Dashboard formula: (px / designDim) × 100 → CSS percentage → applied to container
  static double? toPercentOfContainer(dynamic value,
      {required bool isVertical, required Size parentSize}) {
    if (value == null) return null;
    final str = value.toString().trim();
    // Already percentage - resolve against parent
    if (str.endsWith('%')) {
      final pct = double.tryParse(str.replaceAll('%', ''));
      if (pct == null) return null;
      return (isVertical ? parentSize.height : parentSize.width) * pct / 100;
    }
    // Pixel - convert using design baseline
    final px = double.tryParse(str.replaceAll('px', ''));
    if (px == null) return null;
    final designDim = isVertical ? kNinjaDesignHeight : kNinjaDesignWidth;
    final containerDim = isVertical ? parentSize.height : parentSize.width;
    final pct = (px / designDim) * 100; // Dashboard percentage
    final result = (pct / 100) * containerDim; // Apply to container
    NinjaLog.d('AppNinja', 
        'InAppNinja: 🔢 toPercent: $px / $designDim = ${pct.toStringAsFixed(2)}% → ${result.toStringAsFixed(2)}px of ${containerDim}px');
    return result;
  }

  static Color? parseColor(dynamic value) {
    if (value == null) return null;
    if (value is Color) return value;
    if (value is! String) return null;
    if (value.isEmpty) return null;

    // Check for named colors or transparent
    if (value == 'transparent') return Colors.transparent;

    try {
      // Hex
      if (value.startsWith('#')) {
        var hex = value.replaceAll('#', '');
        if (hex.length == 3) {
          hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
        } else if (hex.length == 4) {
          hex = '${hex[3]}${hex[3]}${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
        } else if (hex.length == 6) {
          hex = 'FF$hex'; // Add full opacity (AARRGGBB)
        } else if (hex.length == 8) {
          // CRITICAL FIX: CSS/Dashboard uses #RRGGBBAA, Flutter uses #AARRGGBB
          // Example: #EC489969 (CSS) → #69EC4899 (Flutter)
          // Split: RRGGBB (first 6) + AA (last 2)
          final rgb = hex.substring(0, 6); // EC4899
          final alpha = hex.substring(6); // 69
          hex = alpha + rgb; // 69EC4899 ✅
        }
        return Color(int.parse(hex, radix: 16));
      }

      // RGBA
      if (value.startsWith('rgba')) {
        final parts = value.substring(5, value.length - 1).split(',');
        if (parts.length == 4) {
          return Color.fromRGBO(
            int.parse(parts[0].trim()),
            int.parse(parts[1].trim()),
            int.parse(parts[2].trim()),
            double.parse(parts[3].trim()),
          );
        }
      }

      // RGB
      if (value.startsWith('rgb')) {
        final parts = value.substring(4, value.length - 1).split(',');
        if (parts.length == 3) {
          return Color.fromARGB(
            255,
            int.parse(parts[0].trim()),
            int.parse(parts[1].trim()),
            int.parse(parts[2].trim()),
          );
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static FontWeight? parseFontWeight(dynamic value) {
    if (value == null) return null;

    // ... (existing parseFontWeight implementation)
    // Handle numeric weights (100-900)
    if (value is num) {
      final weight = value.toInt();
      if (weight <= 100) return FontWeight.w100;
      if (weight <= 200) return FontWeight.w200;
      if (weight <= 300) return FontWeight.w300;
      if (weight <= 400) return FontWeight.w400;
      if (weight <= 500) return FontWeight.w500;
      if (weight <= 600) return FontWeight.w600;
      if (weight <= 700) return FontWeight.w700;
      if (weight <= 800) return FontWeight.w800;
      return FontWeight.w900;
    }

    // Handle string values (case-insensitive)
    final str = value.toString().toLowerCase().trim();

    // Try parsing as number first
    final numWeight = int.tryParse(str);
    if (numWeight != null) {
      if (numWeight <= 100) return FontWeight.w100;
      if (numWeight <= 200) return FontWeight.w200;
      if (numWeight <= 300) return FontWeight.w300;
      if (numWeight <= 400) return FontWeight.w400;
      if (numWeight <= 500) return FontWeight.w500;
      if (numWeight <= 600) return FontWeight.w600;
      if (numWeight <= 700) return FontWeight.w700;
      if (numWeight <= 800) return FontWeight.w800;
      return FontWeight.w900;
    }

    // Handle text names
    switch (str) {
      case 'thin':
        return FontWeight.w100;
      case 'extralight':
      case 'extra light':
      case 'ultra light':
        return FontWeight.w200;
      case 'light':
        return FontWeight.w300;
      case 'regular':
      case 'normal':
        return FontWeight.w400;
      case 'medium':
        return FontWeight.w500;
      case 'semibold':
      case 'semi bold':
      case 'demi bold':
        return FontWeight.w600;
      case 'bold':
        return FontWeight.w700;
      case 'extrabold':
      case 'extra bold':
      case 'ultra bold':
        return FontWeight.w800;
      case 'black':
      case 'heavy':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  /// Converts a flat list of layers into a nested tree structure based on 'parent' ID.
  /// Returns a list of root layers (layers with no parent or parent not found in list).
  /// Note: This mutates the 'children' property of the layer maps in the returned structure.
  static List<Map<String, dynamic>> buildLayerTree(List<dynamic> flatLayers) {
    if (flatLayers.isEmpty) return [];

    // 1. Deep Copy & Map by ID to avoid mutating original list references if they are used elsewhere
    final Map<String, Map<String, dynamic>> idMap = {};
    final List<Map<String, dynamic>> allLayers = [];

    for (var raw in flatLayers) {
      if (raw is Map) {
        final layer = Map<String, dynamic>.from(
            raw); // Deep copy only top level, nested maps should be handled if modified deep
        // Ensure children list is initialized and empty for rebuilding
        layer['children'] = <Map<String, dynamic>>[];

        // Preserve original ID or generate one if missing? usually ID is present.
        final id = layer['id']?.toString();
        if (id != null) {
          idMap[id] = layer;
        }
        allLayers.add(layer);
      }
    }

    // 2. Assign Children to Parents
    final List<Map<String, dynamic>> rootLayers = [];

    for (var layer in allLayers) {
      final parentId = layer['parent']?.toString();
      if (parentId != null && idMap.containsKey(parentId)) {
        // Add to parent's children
        // We cast to List<Map<...>> because we initialized it as such above
        (idMap[parentId]!['children'] as List).add(layer);
      } else {
        // No parent (or parent not in this list) -> Root Layer
        rootLayers.add(layer);
      }
    }

    // 3. Sort children?
    // The renderers usually handle sorting (e.g. by zIndex or order).
    // NinjaContainerLayer sorts its children.
    // However, for correct order in 'children' array (flow items), we should respect the original order
    // or sort by 'order' property if present.
    // Let's assume the flat list came in roughly correct order or 'order' property is the truth.
    // For safety, we can sort all children lists by 'order'.

    void sortChildren(List<dynamic> layers) {
      layers.sort((a, b) {
        final aOrder = (a['position']?['order'] as num?) ?? 0;
        final bOrder = (b['position']?['order'] as num?) ?? 0;
        return aOrder.compareTo(bOrder);
      });
      // Recurse? No need if we iterate allLayers, but children lists are newly formed.
      // Actually 'allLayers' contains the references to the same objects in 'rootLayers' and 'children' lists.
      // But 'idMap[parentId]!['children']' is a specific list we populated.
    }

    // Sort roots
    sortChildren(rootLayers);

    // Sort all children lists
    for (var layer in allLayers) {
      if ((layer['children'] as List).isNotEmpty) {
        sortChildren(layer['children'] as List);
      }
    }

    return rootLayers;
  }

  /// Tries to load a Google Font by name. Returns null if not found or empty.
  static TextStyle? getGoogleFont(String? fontFamily, {TextStyle? textStyle}) {
    if (fontFamily == null || fontFamily.isEmpty) return null;
    try {
      // Normalize name: Remove quotes, take first in comma-separated list
      // e.g. "'Open Sans', sans-serif" -> "Open Sans"
      var cleanName = fontFamily.split(',').first.trim();
      cleanName = cleanName.replaceAll("'", "").replaceAll('"', "");

      return GoogleFonts.getFont(cleanName, textStyle: textStyle);
    } catch (_) {
      return null;
    }
  }

  static String? getFontFamilyFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final family = uri.queryParameters['family'];
      if (family != null) {
        // Handle "BBH+Bogle" -> "BBH Bogle"
        // Handle "Robin:wght@400;700" -> "Robin"
        String clean = family.replaceAll('+', ' ');
        if (clean.contains(':')) {
          clean = clean.split(':').first;
        }
        return clean;
      }
    } catch (_) {}
    return null;
  }

  static EdgeInsets? parsePadding(dynamic value, [BuildContext? context]) {
    // 1. Explicit Map: {top: 10, right: 0...}
    if (value is Map) {
      return EdgeInsets.only(
        top: parseDouble(value['top'], context, true) ?? 0,
        right: parseDouble(value['right'], context, false) ?? 0,
        bottom: parseDouble(value['bottom'], context, true) ?? 0,
        left: parseDouble(value['left'], context, false) ?? 0,
      );
    }

    // 2. Shorthand CSS syntax
    if (value != null) {
      if (value is String && value.contains(' ')) {
        final parts = value.trim().split(RegExp(r'\s+'));
        if (parts.length == 2) {
          final v = parseDouble(parts[0], context, true) ?? 0;
          final h = parseDouble(parts[1], context, false) ?? 0;
          return EdgeInsets.symmetric(vertical: v, horizontal: h);
        } else if (parts.length == 3) {
          final top = parseDouble(parts[0], context, true) ?? 0;
          final horiz = parseDouble(parts[1], context, false) ?? 0;
          final bottom = parseDouble(parts[2], context, true) ?? 0;
          return EdgeInsets.only(top: top, left: horiz, right: horiz, bottom: bottom);
        } else if (parts.length == 4) {
          final top = parseDouble(parts[0], context, true) ?? 0;
          final right = parseDouble(parts[1], context, false) ?? 0;
          final bottom = parseDouble(parts[2], context, true) ?? 0;
          final left = parseDouble(parts[3], context, false) ?? 0;
          return EdgeInsets.only(top: top, right: right, bottom: bottom, left: left);
        }
      }

      // Uniform length fallback
      final uniform = parseDouble(value, context);
      if (uniform != null && uniform > 0) {
        return EdgeInsets.all(uniform);
      }
    }

    return null;
  }

  /// Parses padding that can include percentage values.
  /// Percentages are resolved against [parentSize].
  static EdgeInsets? parseResponsivePadding(
      dynamic value, BuildContext context, Size parentSize) {
    if (value is Map) {
      return EdgeInsets.only(
        top: parseResponsiveSize(value['top'], context,
                isVertical: true, parentSize: parentSize) ??
            0,
        right: parseResponsiveSize(value['right'], context,
                isVertical: false, parentSize: parentSize) ??
            0,
        bottom: parseResponsiveSize(value['bottom'], context,
                isVertical: true, parentSize: parentSize) ??
            0,
        left: parseResponsiveSize(value['left'], context,
                isVertical: false, parentSize: parentSize) ??
            0,
      );
    }

    if (value is String) {
      // Handle shorthand "10% 5%" or more
      if (value.contains(' ')) {
        final parts = value.trim().split(RegExp(r'\s+'));
        if (parts.length == 2) {
          final v = parseResponsiveSize(parts[0], context,
                  isVertical: true, parentSize: parentSize) ??
              0;
          final h = parseResponsiveSize(parts[1], context,
                  isVertical: false, parentSize: parentSize) ??
              0;
          return EdgeInsets.symmetric(vertical: v, horizontal: h);
        } else if (parts.length == 3) {
          final top = parseResponsiveSize(parts[0], context, isVertical: true, parentSize: parentSize) ?? 0;
          final horiz = parseResponsiveSize(parts[1], context, isVertical: false, parentSize: parentSize) ?? 0;
          final bottom = parseResponsiveSize(parts[2], context, isVertical: true, parentSize: parentSize) ?? 0;
          return EdgeInsets.only(top: top, left: horiz, right: horiz, bottom: bottom);
        } else if (parts.length == 4) {
          final top = parseResponsiveSize(parts[0], context, isVertical: true, parentSize: parentSize) ?? 0;
          final right = parseResponsiveSize(parts[1], context, isVertical: false, parentSize: parentSize) ?? 0;
          final bottom = parseResponsiveSize(parts[2], context, isVertical: true, parentSize: parentSize) ?? 0;
          final left = parseResponsiveSize(parts[3], context, isVertical: false, parentSize: parentSize) ?? 0;
          return EdgeInsets.only(top: top, right: right, bottom: bottom, left: left);
        }
      }

      // Uniform percent "5%" -> 5% of width usually in CSS vertical padding is relative to width too?
      // Actually in CSS padding-top: 10% is 10% of WIDTH.
      // But for "Responsive" parity in Flutter, usually vertical% is height% and horizontal% is width%.
      // Let's stick to isVertical logic for intuitive UI unless user complains.
      final uniform = parseResponsiveSize(value, context,
          isVertical: false, parentSize: parentSize);
      if (uniform != null) return EdgeInsets.all(uniform);
    }

    return parsePadding(value, context);
  }

  /// Parses border radius that can include percentage values (e.g. "50%").
  /// [refDimension] is the size to apply percentage to (usually min(width, height) for circular).
  static double parseResponsiveBorderRadius(
      dynamic value, BuildContext context, double refDimension) {
    if (value is String && value.trim().endsWith('%')) {
      try {
        final pct = double.parse(value.replaceAll('%', '')) / 100.0;
        return refDimension * pct;
      } catch (_) {}
    }
    return parseDouble(value, context) ?? 0.0;
  }

  /// Parses a complex borderRadius which can be a number (all) or a Map (topLeft, etc).
  static BorderRadius? parseBorderRadius(dynamic value,
      {BuildContext? context}) {
    if (value == null) return null;

    // 1. Number (Uniform)
    if (value is num) {
      return BorderRadius.circular(value.toDouble());
    }
    if (value is String) {
      final parsed = parseDouble(value, context);
      if (parsed != null) {
        return BorderRadius.circular(parsed);
      }
    }

    // 2. Map (Corner specific)
    if (value is Map) {
      // Keys: topLeft, top_left, etc.
      double getRad(String k1, String k2) {
        final v = value[k1] ?? value[k2];
        return parseDouble(v, context) ?? 0.0;
      }

      return BorderRadius.only(
        topLeft: Radius.circular(getRad('topLeft', 'top_left')),
        topRight: Radius.circular(getRad('topRight', 'top_right')),
        bottomLeft: Radius.circular(getRad('bottomLeft', 'bottom_left')),
        bottomRight: Radius.circular(getRad('bottomRight', 'bottom_right')),
      );
    }

    return null;
  }

  static List<BoxShadow>? parseShadows(dynamic value, [BuildContext? context]) {
    // Forced Rebuild
    if (value == null) return null;

    // Case 1: List of Maps (Structured)
    if (value is List) {
      final List<BoxShadow> shadows = [];
      for (var s in value) {
        if (s is Map) {
          shadows.add(BoxShadow(
            color: parseColor(s['color']) ?? Colors.black.withOpacity(0.1),
            offset: Offset(
              parseDouble(s['x'], context, false) ?? 0,
              parseDouble(s['y'], context, true) ?? 0,
            ),
            blurRadius: math.max(0.0, parseDouble(s['blur'], context) ?? 0),
            spreadRadius: parseDouble(s['spread'], context) ?? 0,
          ));
        }
      }
      return shadows.isNotEmpty ? shadows : null;
    }

    // Case 2: String preset (Legacy/CSS)
    if (value is String && value.isNotEmpty) {
      // Try generic regex parsing: "0px 8px 16px rgba(0,0,0,0.2)"
      // Matches: Xpx Ypx Blurpx Color (Spread optional)
      // Regex: (-?\d+)px (-?\d+)px (-?\d+)px (?:(-?\d+)px )?(rgba?\(.*?\)|#[0-9a-fA-F]+)
      final regex = RegExp(
          r'(-?\d+)px\s+(-?\d+)px\s+(-?\d+)px\s+(?:(-?\d+)px\s+)?(rgba?\(.*?\)|#[0-9a-fA-F]+)');
      final match = regex.firstMatch(value);

      if (match != null) {
        final x = parseDouble(match.group(1), context, false) ?? 0;
        final y = parseDouble(match.group(2), context, true) ?? 0;
        final blur = parseDouble(match.group(3), context) ?? 0;
        final spread = match.group(4) != null
            ? (parseDouble(match.group(4), context) ?? 0)
            : 0.0;
        final colorStr = match.group(5);
        final color = parseColor(colorStr) ?? Colors.black.withOpacity(0.2);

        return [
          BoxShadow(
            color: color,
            offset: Offset(x, y),
            blurRadius: math.max(0.0, blur),
            spreadRadius: spread,
          )
        ];
      }

      if (value.contains('rgba(0,0,0,0.1)')) {
        // Soft
        return [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: parseDouble(8, context) ?? 8,
              offset: Offset(0, parseDouble(2, context, true) ?? 2))
        ];
      }
      if (value.contains('rgba(0,0,0,0.25)')) {
        // Hard
        return [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: parseDouble(24, context) ?? 24,
              offset: Offset(0, parseDouble(8, context, true) ?? 8))
        ];
      }
    }

    return null;
  }

  /// Parses shadows from either discrete properties (New) or specific boxShadow string/list (Legacy).
  static List<BoxShadow>? parseShadowFromStyle(Map<String, dynamic> style,
      [BuildContext? context]) {
    // 0. Nested Object (Dashboard Parity - used by ContainerRenderer)
    if (style['shadow'] is Map) {
      final shadowObj = style['shadow'] as Map;
      if (shadowObj['enabled'] == false) return null;

      final color = parseColor(shadowObj['color']) ??
          const Color(0x1A000000); // rgba(0,0,0,0.1)
      final blur =
          parseDouble(shadowObj['blur'], context) ?? 10.0; // TSX default
      final spread = parseDouble(shadowObj['spread'], context) ?? 0.0;
      final x = parseDouble(shadowObj['x'], context, false) ?? 0.0;
      final y =
          parseDouble(shadowObj['y'], context, true) ?? 2.0; // TSX default

      return [
        BoxShadow(
          color: color,
          offset: Offset(x, y),
          blurRadius: blur,
          spreadRadius: spread,
        )
      ];
    }

    // 1. New Discrete Properties (Floater Parity)
    if (style['shadowEnabled'] == true) {
      final color = parseColor(style['shadowColor']) ?? Colors.black;
      final blur = parseDouble(style['shadowBlur'], context) ?? 0.0;
      final spread = parseDouble(style['shadowSpread'], context) ?? 0.0;
      final offsetY = parseDouble(style['shadowOffsetY'], context, true) ?? 4.0;
      // Note: Floater doesn't use shadowOffsetX in Dart yet, adding fallback for x
      final offsetX =
          parseDouble(style['shadowOffsetX'], context, false) ?? 0.0;

      return [
        BoxShadow(
          color: color,
          offset: Offset(offsetX, offsetY),
          blurRadius: blur,
          spreadRadius: spread,
        )
      ];
    }

    // 2. Fallback to existing logic
    return parseShadows(style['boxShadow'], context);
  }

  static Gradient? parseGradient(dynamic value) {
    if (value == null || value is! Map) return null;

    final type = value['type'] as String? ?? 'linear';
    final colorsList = value['colors'] as List?;
    final stopsList = value['stops'] as List?;
    final angle = (value['angle'] as num?)?.toDouble() ?? 0.0; // Assume degrees

    if (colorsList == null || colorsList.isEmpty) return null;

    final colors =
        colorsList.map((c) => parseColor(c) ?? Colors.transparent).toList();
    final stops = stopsList?.map((s) => (s as num).toDouble()).toList();

    if (type == 'linear') {
      // Convert Angle to Alignment (Approximate)
      // 0deg = Bottom to Top? CSS 180deg = Top to Bottom
      // Simple alignment for now:
      return LinearGradient(
        colors: colors,
        stops: stops,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        transform: GradientRotation(angle * 3.14159 / 180),
      );
    }

    return null;
  }

  static BoxFit parseBoxFit(dynamic value) {
    final str = value?.toString();

    // Handle '100% 100%' - CSS stretches to fill both dimensions
    if (str == '100% 100%' || str == '100%') {
      return BoxFit.fill;
    }

    switch (str) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
      case 'stretch':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'cover':
        return BoxFit.cover;
      default:
        return BoxFit.cover; // PARITY FIX: Match Dashboard (was contain)
    }
  }

  static List<dynamic> sortLayers(List<dynamic> layers) {
    if (layers.isEmpty) return [];

    // FIX: Typed wrapper to handle various Map types (LinkedHashMap etc)
    List<Map<String, dynamic>> wrapped = [];

    for (int i = 0; i < layers.length; i++) {
      final item = layers[i];
      // Robust check: Ensure item is a Map before processing
      if (item is Map) {
        try {
          // Safe Conversion to Map<String, dynamic>
          wrapped.add(
              {'data': Map<String, dynamic>.from(item), 'originalIndex': i});
        } catch (e) {
          NinjaLog.d('LayerUtils', "sortLayers: Skipped invalid layer item: $item");
        }
      }
    }

    wrapped.sort((a, b) {
      final layerA = a['data'] as Map<String, dynamic>;
      final layerB = b['data'] as Map<String, dynamic>;

      final zA = parseDouble(layerA['style']?['zIndex'] ?? layerA['zIndex'])
              ?.toInt() ??
          0;
      final zB = parseDouble(layerB['style']?['zIndex'] ?? layerB['zIndex'])
              ?.toInt() ??
          0;

      if (zA != zB) {
        return zA.compareTo(zB); // Lower Z -> Lower in Stack (Back)
      }

      // If Z is equal, Keep Original Order (Standard DOM/Flutter behavior).
      // Later in list = Higher Z (Front) AND Lower in Flow (Bottom).
      return a['originalIndex'].compareTo(b['originalIndex']);
    });

    return wrapped.map((w) => w['data']).toList();
  }

  static double? safeScale(dynamic val, double factor,
      [BuildContext? context]) {
    if (val == null) return null;
    final strVal = val.toString().trim();
    if (strVal.endsWith('%') ||
        strVal.endsWith('vh') ||
        strVal.endsWith('vw')) {
      return parseDouble(val, context, false);
    }

    final num = double.tryParse(strVal.replaceAll('px', ''));
    if (num == null || num.isNaN) {
      return parseDouble(val, context, false);
    }
    return num * factor;
  }

  static Widget applyFilterString(Widget child, Map? filter) {
    if (filter == null) return child;
    Widget content = child;

    final blur =
        filter['blur'] is num ? (filter['blur'] as num).toDouble() : 0.0;
    if (blur > 0) {
      content = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      );
    }

    final grayscale = filter['grayscale'] is num
        ? (filter['grayscale'] as num).toDouble()
        : 0.0;
    if (grayscale > 0) {
      const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);
      content = ColorFiltered(colorFilter: greyscaleFilter, child: content);
    }

    // Brightness support
    if (filter['brightness'] != null) {
      double b = double.tryParse(
              filter['brightness'].toString().replaceAll('%', '')) ??
          100;
      double factor = b / 100;
      if (factor != 1.0) {
        final matrix = <double>[
          factor,
          0,
          0,
          0,
          0,
          0,
          factor,
          0,
          0,
          0,
          0,
          0,
          factor,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ];
        content = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: content);
      }
    }

    // Contrast support
    if (filter['contrast'] != null) {
      double c =
          double.tryParse(filter['contrast'].toString().replaceAll('%', '')) ??
              100;
      double contrast = c / 100;
      if (contrast != 1.0) {
        double offset = 127.5 * (1 - contrast);
        final matrix = <double>[
          contrast,
          0,
          0,
          0,
          offset,
          0,
          contrast,
          0,
          0,
          offset,
          0,
          0,
          contrast,
          0,
          offset,
          0,
          0,
          0,
          1,
          0,
        ];
        content = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: content);
      }
    }

    return content;
  }

  static Widget applyTransform(Widget child, Map<String, dynamic>? transform) {
    if (transform == null) return child;

    double rotate =
        double.tryParse(transform['rotate']?.toString() ?? '0') ?? 0;
    double scale = double.tryParse(transform['scale']?.toString() ?? '1') ?? 1;
    double tx = 0;
    double ty = 0;

    if (transform['translateX'] != null) {
      tx = double.tryParse(
              transform['translateX'].toString().replaceAll('px', '')) ??
          0;
    }
    if (transform['translateY'] != null) {
      ty = double.tryParse(
              transform['translateY'].toString().replaceAll('px', '')) ??
          0;
    }

    if (rotate == 0 && scale == 1 && tx == 0 && ty == 0) return child;

    Matrix4 matrix = Matrix4.identity()
      ..translate(tx, ty)
      ..rotateZ(rotate * math.pi / 180)
      ..scale(scale);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: child,
    );
  }

  static List<BoxShadow>? parseShadowObject(
      Map? shadow, double scale, dynamic rawBoxShadow) {
    if (shadow != null) {
      if (shadow['enabled'] == false) return null;

      final x = safeScale(shadow['x'] ?? 0, scale) ?? 0.0;
      final y = safeScale(shadow['y'] ?? 2, scale) ?? 2.0;
      final blurRadius = safeScale(shadow['blur'] ?? 10, scale) ?? 10.0;
      final spreadRadius = safeScale(shadow['spread'] ?? 0, scale) ?? 0.0;
      final colorStr = shadow['color'] ?? 'rgba(0,0,0,0.1)';
      final color = parseColor(colorStr) ?? const Color(0x1A000000);

      return [
        BoxShadow(
          color: color,
          offset: Offset(x, y),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ];
    }
    return parseShadows(rawBoxShadow, null);
  }

  static Alignment parseAlignment(String value) {
    final v = value.toLowerCase();
    bool hasTop = v.contains('top');
    bool hasBottom = v.contains('bottom');
    bool hasLeft = v.contains('left');
    bool hasRight = v.contains('right');

    if (hasTop && hasLeft) return Alignment.topLeft;
    if (hasTop && hasRight) return Alignment.topRight;
    if (hasTop) return Alignment.topCenter;

    if (hasBottom && hasLeft) return Alignment.bottomLeft;
    if (hasBottom && hasRight) return Alignment.bottomRight;
    if (hasBottom) return Alignment.bottomCenter;

    if (hasLeft) return Alignment.centerLeft;
    if (hasRight) return Alignment.centerRight;

    return Alignment.center;
  }
}

class NinjaVideoStatusNotification extends Notification {
  final bool isPlaying;
  NinjaVideoStatusNotification(this.isPlaying);
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final double gap;
  final BorderStyle style;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.gap = 5.0,
    this.style = BorderStyle.solid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isDotted = style == BorderStyle.none;
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

    if (style == BorderStyle.solid && !isDotted) {
      canvas.drawPath(path, paint);
      return;
    }

    final Path dashedPath = Path();
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        if (isDotted) {
          dashedPath.addPath(
              metric.extractPath(distance, distance + 0.1), Offset.zero);
          distance += gap + strokeWidth;
        } else {
          dashedPath.addPath(
              metric.extractPath(distance, distance + gap), Offset.zero);
          distance += gap * 2;
        }
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius ||
        gap != oldDelegate.gap ||
        style != oldDelegate.style;
  }
}
