import 'package:flutter/material.dart';
import 'ninja_layer_utils.dart';
import 'ninja_scratch_foil_layer.dart';

/// NinjaGridElementLayer
///
/// Represents a single item template inside a Grid Container loop.
/// This widget receives a `dataItem` (a single JSON object from the fetched array)
/// and a `renderChild` callback that recursively builds all child layers
/// with the mapped data context applied.
///
/// Architecture:
/// - The Grid Container fetches the data array from `dataSourceUrl`
/// - For each item in the array, it creates a NinjaGridElementLayer
/// - This layer passes the dataItem to the renderChild callback
/// - The callback resolves `mapped_key` fields and `statusBindingKey` etc.
///   before building each child widget
class NinjaGridElementLayer extends StatelessWidget {
  final Map<String, dynamic> layer;
  final Map<String, dynamic>? dataItem;
  final int index;
  final double scale;
  final double scaleY;
  final List<dynamic> allLayers;
  final Widget Function(Map<String, dynamic> childLayer, Map<String, dynamic>? mappedData) renderChild;
  final Function(String, Map<String, dynamic>?)? onAction;

  const NinjaGridElementLayer({
    Key? key,
    required this.layer,
    this.dataItem,
    this.index = 0,
    this.scale = 1.0,
    this.scaleY = 1.0,
    required this.allLayers,
    required this.renderChild,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = layer['style'] as Map<String, dynamic>? ?? {};
    final children = layer['children'] as List<dynamic>? ?? [];

    // Resolve child layers from allLayers using children IDs
    List<Map<String, dynamic>> childLayers = [];
    for (var childId in children) {
      final childLayer = allLayers.firstWhere(
        (l) => l['id'] == childId,
        orElse: () => null,
      );
      if (childLayer != null) {
        childLayers.add(Map<String, dynamic>.from(childLayer));
      }
    }

    // If no explicit children array, find by parent reference
    if (childLayers.isEmpty) {
      childLayers = allLayers
          .where((l) => l['parent'] == layer['id'])
          .map((l) => Map<String, dynamic>.from(l))
          .toList();
    }

    // BUG FIX: Strip invisible layers BEFORE widget mapping so gap spacers are
    // never injected around hidden elements (CSS display:none parity).
    childLayers = childLayers.where((l) => l['visible'] != false).toList();

    // Parse styling
    Color? bgColor = NinjaLayerUtils.parseColor(style['backgroundColor']);

    // Border
    double borderRadius = (NinjaLayerUtils.parseDouble(style['borderRadius']) ?? 0) * scale;
    double borderWidth = (NinjaLayerUtils.parseDouble(style['borderWidth']) ?? 0) * scale;
    Color? borderColor = NinjaLayerUtils.parseColor(style['borderColor']);

    // Extract paddingX/paddingY as baseline fallbacks 
    final paddingX = NinjaLayerUtils.parseDouble(style['paddingX']);
    final paddingY = NinjaLayerUtils.parseDouble(style['paddingY']);
    
    double pTop = paddingY != null ? paddingY * scale : 0;
    double pBottom = paddingY != null ? paddingY * scale : 0;
    double pLeft = paddingX != null ? paddingX * scale : 0;
    double pRight = paddingX != null ? paddingX * scale : 0;

    // Explicit `padding` object completely overrides baseline fallbacks (Dashboard Parity)
    final rawPadding = style['padding'];
    if (rawPadding is Map) {
      pTop = (NinjaLayerUtils.parseDouble(rawPadding['top']) ?? 0) * scale;
      pRight = (NinjaLayerUtils.parseDouble(rawPadding['right']) ?? 0) * scale;
      pBottom = (NinjaLayerUtils.parseDouble(rawPadding['bottom']) ?? 0) * scale;
      pLeft = (NinjaLayerUtils.parseDouble(rawPadding['left']) ?? 0) * scale;
    } else if (rawPadding is num) {
      final p = rawPadding.toDouble() * scale;
      pTop = pRight = pBottom = pLeft = p;
    }

    // Flex layout properties
    final String flexDir = style['flexDirection']?.toString() ?? 'column';
    final Axis direction = flexDir == 'row' ? Axis.horizontal : Axis.vertical;
    
    final String alignItemsStr = style['alignItems']?.toString() ?? 'stretch';
    final CrossAxisAlignment crossAxis;
    switch (alignItemsStr) {
      case 'center':
        crossAxis = CrossAxisAlignment.center;
        break;
      case 'flex-end':
      case 'end':
        crossAxis = CrossAxisAlignment.end;
        break;
      case 'flex-start':
      case 'start':
        crossAxis = CrossAxisAlignment.start;
        break;
      default:
        crossAxis = CrossAxisAlignment.stretch;
    }

    final String justifyStr = style['justifyContent']?.toString() ?? 'flex-start';
    final MainAxisAlignment mainAxis;
    switch (justifyStr) {
      case 'center':
        mainAxis = MainAxisAlignment.center;
        break;
      case 'flex-end':
      case 'end':
        mainAxis = MainAxisAlignment.end;
        break;
      case 'space-between':
        mainAxis = MainAxisAlignment.spaceBetween;
        break;
      case 'space-around':
        mainAxis = MainAxisAlignment.spaceAround;
        break;
      case 'space-evenly':
        mainAxis = MainAxisAlignment.spaceEvenly;
        break;
      default:
        mainAxis = MainAxisAlignment.start;
    }

    final double gap = (NinjaLayerUtils.parseDouble(style['gap']) ?? 0) * scale;

    // BUG FIX: Resolve explicit width/height from style so percentage/pixel values
    // from the dashboard JSON are honoured (e.g. width:"80%" must not shrink to min content).
    final parentW = MediaQuery.of(context).size.width;
    final parentH = MediaQuery.of(context).size.height;

    double? resolvedWidth;
    double? resolvedHeight;
    final rawW = style['width'];
    final rawH = style['height'];
    if (rawW != null) {
      final wStr = rawW.toString();
      if (wStr.endsWith('%')) {
        final pct = double.tryParse(wStr.replaceAll('%', ''));
        if (pct != null) resolvedWidth = parentW * pct / 100.0;
      } else {
        resolvedWidth = (NinjaLayerUtils.parseDouble(style['width']) ?? 0) * scale;
        if (resolvedWidth == 0) resolvedWidth = null;
      }
    }
    if (rawH != null) {
      final hStr = rawH.toString();
      if (hStr.endsWith('%')) {
        final pct = double.tryParse(hStr.replaceAll('%', ''));
        if (pct != null) resolvedHeight = parentH * pct / 100.0;
      } else {
        resolvedHeight = (NinjaLayerUtils.parseDouble(style['height']) ?? 0) * scaleY;
        if (resolvedHeight == 0) resolvedHeight = null;
      }
    }

    // Build children with mapped data
    List<Widget> childWidgets = childLayers.map((childLayer) {
      return renderChild(childLayer, dataItem);
    }).toList();

    // Inject gap spacers between children
    if (gap > 0 && childWidgets.length > 1) {
      List<Widget> spaced = [];
      for (int i = 0; i < childWidgets.length; i++) {
        spaced.add(childWidgets[i]);
        if (i < childWidgets.length - 1) {
          spaced.add(SizedBox(
            width: direction == Axis.horizontal ? gap : 0,
            height: direction == Axis.vertical ? gap : 0,
          ));
        }
      }
      childWidgets = spaced;
    }

    Widget container = Container(
      width: resolvedWidth,
      height: resolvedHeight,
      padding: EdgeInsets.only(top: pTop, right: pRight, bottom: pBottom, left: pLeft),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: Flex(
        direction: direction,
        mainAxisSize: resolvedWidth != null ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: crossAxis,
        mainAxisAlignment: mainAxis,
        children: childWidgets,
      ),
    );

    final actionObj = layer['action'];
    final actionType = actionObj is Map ? actionObj['type'] : layer['actionType'];
    final actionData = actionObj is Map ? Map<String, dynamic>.from(actionObj) : layer;
    
    if (actionType != null && onAction != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onAction!(actionType.toString(), actionData);
        },
        child: container,
      );
    }
    
    return container;
  }
}
