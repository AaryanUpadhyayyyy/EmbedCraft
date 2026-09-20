import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui; // For PathMetric and ImageFilter
import 'ninja_layer_utils.dart'; // We still need this for core parsing (colors, etc), but we will build styling locally
import 'ninja_scratch_foil_layer.dart';
import '../nudge_renderers/Floater_render_v2.dart';

// Helpers are now imported from NinjaLayerUtils to reduce file size

class NinjaContainerLayer extends StatelessWidget {
  final Map<String, dynamic> layer;
  final List<dynamic>? allLayers; // Maps to `layers` in ContainerRendererProps
  final double scale;
  final double scaleY;
  final Widget Function(Map<String, dynamic> layer,
      {double? parentWidth, double? parentHeight})? renderChild;

  // Additional Flutter properties needed for context
  final Size? parentSize;
  final Size? scaleSize;
  final Function(String action, Map<String, dynamic> data)? onAction;

  final bool isActive;

  const NinjaContainerLayer({
    Key? key,
    required this.layer,
    this.allLayers,
    this.scale = 1.0,
    this.scaleY = 1.0,
    this.renderChild,
    this.parentSize,
    this.scaleSize,
    this.onAction,
    this.isActive = true,
    // Add legacy prop to not break compilation elsewhere, but we ignore it.
    bool skipWrapperDecoration = false,
    bool isRoot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mimic TSX: const children = layers.filter(l => l.parent === layer.id);
    final List<Map<String, dynamic>> children = allLayers != null
        ? allLayers!
            .where((l) => l is Map && l['parent'] == layer['id'])
            .cast<Map<String, dynamic>>()
            .toList()
        : (layer['children'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    final style = layer['style'] ?? {};

    // 1. Resolve Glassmorphism (backdropFilter)
    final backdropFilterData = style['backdropFilter'];
    final bool isGlassEnabled =
        backdropFilterData is Map && backdropFilterData['enabled'] == true;
    final double glassBlurValue = isGlassEnabled
        ? (NinjaLayerUtils.safeScale(backdropFilterData['blur'] ?? 10, scale) ??
            10.0)
        : 0.0;

    // 2. Resolve Shadow
    final boxShadows = NinjaLayerUtils.parseShadowObject(
        style['shadow'], scale, style['boxShadow']);

    // Construct Styles mapping directly to TSX order:

    // Layout - PARITY FIX: React ContainerRenderer uses layoutMode to determine layout
    // layoutMode='free' (default) -> display: 'block' (no flex, children positioned freely)
    // layoutMode='auto' -> display: 'flex' (flex flow with alignment)
    final layoutMode = style['layoutMode']?.toString() ?? 'free';
    final display = layoutMode == 'auto'
        ? (style['display']?.toString().toLowerCase() ?? 'flex')
        : 'block';
    final flexDirection = layoutMode == 'auto'
        ? (style['flexDirection']?.toString().toLowerCase() ?? 'column')
        : 'column';
    final alignItems = layoutMode == 'auto'
        ? (style['alignItems']?.toString().toLowerCase() ?? 'stretch')
        : 'stretch';
    final justifyContent = layoutMode == 'auto'
        ? (style['justifyContent']?.toString().toLowerCase() ?? 'flex-start')
        : 'flex-start';
    final gap = layoutMode == 'auto'
        ? (NinjaLayerUtils.safeScale(style['gap'] ?? 0, scale) ?? 0.0)
        : 0.0;

    // Visuals
    final backgroundColor =
        NinjaLayerUtils.parseColor(style['backgroundColor']);
    final backgroundImage = style['backgroundImage'];
    final backgroundSize = style['backgroundSize']?.toString() ?? 'cover';
    final backgroundPosition =
        style['backgroundPosition']?.toString() ?? 'center';

    DecorationImage? imageDecoration;
    Gradient? gradientDecoration;
    if (backgroundImage != null && backgroundImage.toString().isNotEmpty) {
      if (style['background'] is Map &&
          style['background']['type'] == 'linear-gradient') {
        gradientDecoration = NinjaLayerUtils.parseGradient(style['background']);
      } else if (!backgroundImage.toString().startsWith('linear-gradient')) {
        String url = backgroundImage.toString();
        if (url.startsWith('url(') && url.endsWith(')')) {
          url = url.substring(4, url.length - 1).replaceAll('"', '').replaceAll("'", "").trim();
        }
        // FIX: Skip backgroundImage when the raw URL is purely a template
        // placeholder (e.g. "{{icon}}", "{{imageUrl}}"). These template vars
        // are resolved by child media layers; rendering them ALSO as the
        // container background causes double-rendering of the reward icon.
        final _templateOnlyRegex = RegExp(r'^\{\{[^}]+\}\}$');
        final bool isTemplateOnly = _templateOnlyRegex.hasMatch(url.trim());
        if (!isTemplateOnly) {
          final resolvedUrl = NinjaLayerUtils.resolveText(url);
          if (resolvedUrl.isNotEmpty && resolvedUrl.startsWith('http')) {
            imageDecoration = DecorationImage(
              image: NetworkImage(resolvedUrl),
              fit: NinjaLayerUtils.parseBoxFit(backgroundSize),
              alignment: NinjaLayerUtils.parseAlignment(backgroundPosition),
            );
          }
        }
      }
    }

    // Borders
    final borderWidth =
        NinjaLayerUtils.safeScale(style['borderWidth'], scale) ?? 0.0;
    final borderStyle = style['borderStyle']?.toString();
    final borderColor =
        NinjaLayerUtils.parseColor(style['borderColor']) ?? Colors.transparent;

    BorderRadius? radius;
    if (style['borderRadius'] is Map) {
      final br = style['borderRadius'] as Map;
      radius = BorderRadius.only(
        topLeft: Radius.circular(
            NinjaLayerUtils.safeScale(br['topLeft'] ?? 0, scale) ?? 0.0),
        topRight: Radius.circular(
            NinjaLayerUtils.safeScale(br['topRight'] ?? 0, scale) ?? 0.0),
        bottomRight: Radius.circular(
            NinjaLayerUtils.safeScale(br['bottomRight'] ?? 0, scale) ?? 0.0),
        bottomLeft: Radius.circular(
            NinjaLayerUtils.safeScale(br['bottomLeft'] ?? 0, scale) ?? 0.0),
      );
    } else {
      radius = BorderRadius.circular(
          NinjaLayerUtils.safeScale(style['borderRadius'] ?? 0, scale) ?? 0.0);
    }

    // Effects
    final opacity =
        NinjaLayerUtils.parseDouble(style['opacity'])?.clamp(0.0, 1.0) ?? 1.0;

    // Build the Box Decoration
    final decoration = BoxDecoration(
      color: backgroundColor,
      image: imageDecoration,
      gradient: gradientDecoration,
      borderRadius: radius,
      boxShadow: boxShadows,
      border: (borderWidth > 0 &&
              borderStyle != 'none' &&
              (borderStyle == null || borderStyle == 'solid'))
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );

    // Padding (Dynamic with Scale Parity)
    final paddingMap = style['padding'] is Map ? style['padding'] : null;
    double pTop = NinjaLayerUtils.safeScale(
            paddingMap?['top'] ?? style['paddingTop'], scaleY) ??
        0.0;
    double pBottom = NinjaLayerUtils.safeScale(
            paddingMap?['bottom'] ?? style['paddingBottom'], scaleY) ??
        0.0;
    double pLeft = NinjaLayerUtils.safeScale(
            paddingMap?['left'] ?? style['paddingLeft'], scale) ??
        0.0;
    double pRight = NinjaLayerUtils.safeScale(
            paddingMap?['right'] ?? style['paddingRight'], scale) ??
        0.0;

    final double? paddingX =
        NinjaLayerUtils.safeScale(style['paddingX'], scale);
    final double? paddingY =
        NinjaLayerUtils.safeScale(style['paddingY'], scaleY);

    if (paddingX != null) {
      pLeft = paddingX;
      pRight = paddingX;
    }
    if (paddingY != null) {
      pTop = paddingY;
      pBottom = paddingY;
    }

    final EdgeInsetsGeometry containerPadding =
        EdgeInsets.only(top: pTop, bottom: pBottom, left: pLeft, right: pRight);

    // Overflow
    final String overflowX = style['overflowX']?.toString() ?? 'hidden';
    final String overflowY = style['overflowY']?.toString() ??
        (style['overflow'] == 'scroll'
            ? 'auto'
            : (style['overflow']?.toString() ?? 'hidden'));
    final bool isScrollableX = overflowX == 'auto' || overflowX == 'scroll';
    final bool isScrollableY = overflowY == 'auto' || overflowY == 'scroll';
    final bool clipsContent = overflowX != 'visible' || overflowY != 'visible';

    // Flex/Block Mappings
    MainAxisAlignment mainAxis = _mapJustifyContent(justifyContent);
    CrossAxisAlignment crossAxis = _mapAlignItems(alignItems);
    Axis direction =
        flexDirection.contains('row') ? Axis.horizontal : Axis.vertical;

    // Build Children
    Widget contentWidget;

    if (children.isEmpty) {
      contentWidget = const SizedBox.shrink();
    } else {
      // Wrap in LayoutBuilder to discover THIS container's resolved size
      contentWidget = LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = MediaQuery.of(context).size;
          // Apply strict screen-size simulated bounding boxes to ensure CSS `<100%>` calculations never fail recursively
          final resolvedWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : ((parentSize != null && parentSize!.width.isFinite) ? parentSize!.width : screenSize.width);
          final resolvedHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : ((parentSize != null && parentSize!.height.isFinite) ? parentSize!.height : screenSize.height);

          // CSS PARITY FIX: The LayoutBuilder now resolves the PADDING BOX (outer bounds),
          // because we removed padding from the outer container.
          // Absolute children position relative to the padding box. Relative children inside the padded flow.

          final contentBoxWidth = resolvedWidth.isFinite
              ? (resolvedWidth - pLeft - pRight)
              : resolvedWidth;
          final contentBoxHeight = resolvedHeight.isFinite
              ? (resolvedHeight - pTop - pBottom)
              : resolvedHeight;

          List<Widget> flexWidgets = [];
          List<Widget> combinedStackChildren = [];
          bool hasExpandedChild = false;
          bool flowWidgetInserted = false;

          final childLayoutMode = style['layoutMode']?.toString();

          for (var originalChildData in NinjaLayerUtils.sortLayers(children)
              .where((c) => c is Map && c['visible'] != false)) {
            // Inherently enforce relative flow if container is in Auto Flow
            Map<String, dynamic> childData =
                Map<String, dynamic>.from(originalChildData);

            // Context Propagation: Pass down data bindings (e.g. {{item.name}}) to all nested children
            if (layer.containsKey('mappedState')) {
              childData['mappedState'] = layer['mappedState'];
            }

            if (childLayoutMode == 'auto') {
              // DASHBOARD PARITY: scratch_foil is NEVER part of auto-flow.
              // FloaterRenderer.tsx forces scratch_foil to position:absolute
              // covering the entire parent (top:0, left:0, right:0, bottom:0, 100%x100%).
              if (childData['type'] == 'scratch_foil') {
                final childStyle =
                    Map<String, dynamic>.from(childData['style'] ?? {});
                childStyle['position'] = 'absolute';
                childStyle['top'] = '0';
                childStyle['left'] = '0';
                childStyle['right'] = '0';
                childStyle['bottom'] = '0';
                childStyle['width'] = '100%';
                childStyle['height'] = '100%';
                childData['style'] = childStyle;
              } else {
                final childStyle =
                    Map<String, dynamic>.from(childData['style'] ?? {});
                childStyle['position'] = 'relative';
                childStyle.remove('top');
                childStyle.remove('left');
                childStyle.remove('bottom');
                childStyle.remove('right');
                childStyle.remove('transform');
                childData['style'] = childStyle;
              }
            } else {
              // FREE layout mode: scratch_foil still needs absolute overlay
              if (childData['type'] == 'scratch_foil') {
                final childStyle =
                    Map<String, dynamic>.from(childData['style'] ?? {});
                childStyle['position'] = 'absolute';
                childStyle['top'] = '0';
                childStyle['left'] = '0';
                childStyle['right'] = '0';
                childStyle['bottom'] = '0';
                childStyle['width'] = '100%';
                childStyle['height'] = '100%';
                childData['style'] = childStyle;
              }
            }

            Widget childWidget;
            // CSS PARITY: Determine child position type BEFORE rendering
            // Absolute children use padding-box dimensions, relative use content-box
            final childStyle = childData['style'] ?? {};
            final isChildAbsolute = childStyle['position'] == 'absolute' ||
                childStyle['position'] == 'fixed';
            final childParentWidth =
                isChildAbsolute ? resolvedWidth : contentBoxWidth;
            final childParentHeight =
                isChildAbsolute ? resolvedHeight : contentBoxHeight;

            if (renderChild != null) {
              childWidget = renderChild!(
                childData,
                parentWidth: childParentWidth,
                parentHeight: childParentHeight,
              );
            } else {
              // Fallback if renderChild is somehow not passed
              childWidget = buildFloaterLayerGlobally(
                childData,
                scale,
                scaleY,
                allLayers ?? [],
                (a, d) {
                  if (onAction != null) onAction!(a, d ?? {});
                },
                parentWidth: childParentWidth,
                parentHeight: childParentHeight,
                isActive: isActive,
              );
            }

            final isAbsolute = isChildAbsolute ||
                childWidget
                    is Positioned; // PARITY FIX: Safety guard. Tooltips return Positioned blocks dynamically.

            if (isAbsolute) {
              combinedStackChildren.add(childWidget);
            } else {
              // Z-Index Interleaving: Insert flow widget marker exactly where the first relative item appears
              if (!flowWidgetInserted) {
                combinedStackChildren
                    .add(const SizedBox(key: ValueKey('_flow_placeholder')));
                flowWidgetInserted = true;
              }

              final flexGrow =
                  NinjaLayerUtils.parseDouble(childStyle['flexGrow']);
              if (display == 'flex' && flexGrow != null && flexGrow > 0) {
                childWidget =
                    Expanded(flex: flexGrow.toInt(), child: childWidget);
                hasExpandedChild = true;
              }
              flexWidgets.add(childWidget);
            }
          }

          // Build the base flow (Flex or Column)
          Widget flowWidget;
          if (display == 'flex') {
            if (style['flexWrap'] == 'wrap' ||
                style['flexWrap'] == 'wrap-reverse') {
              flowWidget = Wrap(
                direction: direction,
                spacing: gap,
                runSpacing: gap,
                alignment: _mapWrapAlignment(justifyContent),
                crossAxisAlignment: _mapWrapCrossAlignment(alignItems),
                children: flexWidgets,
              );
            } else {
              // Handle TSX Flex Gap injection
              if (gap > 0 &&
                  flexWidgets.length > 1 &&
                  mainAxis != MainAxisAlignment.spaceBetween &&
                  mainAxis != MainAxisAlignment.spaceAround) {
                List<Widget> spacedChildren = [];
                for (int i = 0; i < flexWidgets.length; i++) {
                  spacedChildren.add(flexWidgets[i]);
                  if (i < flexWidgets.length - 1) {
                    spacedChildren.add(SizedBox(
                      width: direction == Axis.horizontal ? gap : 0,
                      height: direction == Axis.vertical ? gap : 0,
                    ));
                  }
                }
                flexWidgets = spacedChildren;
              }

              // CSS flex-flow parity:
              // Flutter's strict Flex restricts children strictly to bounding boxes and throws
              // RenderFlex Overflows when pixel gaps or inner padding break bounds.
              // CSS inherently allows items to overflow their flex-flow axis visually without crashing constraints.
              // By wrapping Flex exclusively in an unbounded simulated scrolling axis, we mimic HTML node bleeding,
              // then rely entirely on clipBehavior (Clip.hardEdge vs Clip.none) to enforce the actual overflow mode.
              if (!hasExpandedChild && !isScrollableX && !isScrollableY) {
                flowWidget = SingleChildScrollView(
                  scrollDirection: direction == Axis.horizontal
                      ? Axis.horizontal
                      : Axis.vertical,
                  physics:
                      const NeverScrollableScrollPhysics(), // Purely for resolving Unbounded layout constraints
                  clipBehavior: clipsContent ? Clip.hardEdge : Clip.none,
                  child: Flex(
                    direction: direction,
                    mainAxisAlignment: mainAxis,
                    crossAxisAlignment: crossAxis,
                    mainAxisSize: MainAxisSize.min,
                    children: flexWidgets,
                  ),
                );
              } else {
                flowWidget = Flex(
                  direction: direction,
                  mainAxisAlignment: mainAxis,
                  crossAxisAlignment: crossAxis,
                  clipBehavior: clipsContent ? Clip.hardEdge : Clip.none,
                  children: flexWidgets,
                );
              }
            }
          } else {
            // Fallback Block (Vertical list)
            flowWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: flexWidgets,
            );
          }

          // Wrap the flow widget in Padding so relative children are pushed inward!
          Widget paddedFlowWidget = Padding(
            padding: containerPadding,
            child: flowWidget,
          );

          // Combine flow content with Absolute Positioned children BEFORE scrolling
          Widget stackInner;
          if (combinedStackChildren.length > 1 ||
              (combinedStackChildren.length == 1 &&
                  combinedStackChildren[0].key !=
                      const ValueKey('_flow_placeholder'))) {
            List<Widget> finalStackChildren = combinedStackChildren.map((w) {
              if (w.key == const ValueKey('_flow_placeholder'))
                return paddedFlowWidget;
              return w;
            }).toList();

            stackInner = Stack(
              clipBehavior: Clip.none,
              children: finalStackChildren,
            );
          } else {
            stackInner = paddedFlowWidget;
          }

          Widget scrollWidget = stackInner;

          if (isScrollableX) {
            scrollWidget = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              child: scrollWidget,
            );
          }

          if (isScrollableY) {
            scrollWidget = SingleChildScrollView(
              scrollDirection: Axis.vertical,
              clipBehavior: Clip.hardEdge,
              child: scrollWidget,
            );
          }

          final bool hideScrollbar = style['hideScrollbar'] == true;
          if (hideScrollbar && (isScrollableX || isScrollableY)) {
            scrollWidget = ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: scrollWidget,
            );
          } else if (!hideScrollbar && (isScrollableX || isScrollableY)) {
            final Color thumbColor =
                NinjaLayerUtils.parseColor(style['scrollbarThumbColor']) ??
                    const Color(0xFFCBD5E1);
            final Color trackColor =
                NinjaLayerUtils.parseColor(style['scrollbarTrackColor']) ??
                    Colors.transparent;

            scrollWidget = ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(thumbColor),
                trackColor: MaterialStateProperty.all(trackColor),
                thickness: MaterialStateProperty.all(6.0),
                radius: const Radius.circular(4.0),
                trackVisibility: MaterialStateProperty.all(
                    style['scrollbarTrackColor'] != null),
                thumbVisibility: MaterialStateProperty.all(true),
              ),
              child: Scrollbar(
                child: scrollWidget,
              ),
            );
          }

          final builtContent =
              (isScrollableX || isScrollableY) ? scrollWidget : stackInner;
          return builtContent;
        }, // end LayoutBuilder builder
      ); // end LayoutBuilder
    }

    final explicitWidthRaw = style['width'] ??
        ((layer.containsKey('size') && layer['size'] is Map)
            ? layer['size']['width']
            : null);
    final explicitWidth = explicitWidthRaw == 'auto' || explicitWidthRaw == null
        ? null
        : NinjaLayerUtils.parseResponsiveSize(explicitWidthRaw, context,
            isVertical: false, parentSize: parentSize);

    final explicitHeightRaw = style['height'] ??
        ((layer.containsKey('size') && layer['size'] is Map)
            ? layer['size']['height']
            : null);
    double? explicitHeight =
        explicitHeightRaw == 'auto' || explicitHeightRaw == null
            ? null
            : NinjaLayerUtils.parseResponsiveSize(explicitHeightRaw, context,
                isVertical: true, parentSize: parentSize);

    if (explicitHeight == double.infinity) {
        explicitHeight = null; // Prevent BoxConstraints forces an infinite height
    }

    // Apply Dashed Borders
    Widget containerWidget;
    if (borderWidth > 0 &&
        (borderStyle == 'dashed' || borderStyle == 'dotted')) {
      containerWidget = CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: borderColor,
          strokeWidth: borderWidth,
          style: borderStyle == 'dotted' ? BorderStyle.none : BorderStyle.solid,
          borderRadius: radius,
          gap: borderStyle == 'dotted' ? (borderWidth * 2) : (borderWidth * 3),
        ),
        child: Container(
          width: explicitWidth ?? double.infinity,
          height: explicitHeight,
          clipBehavior: Clip.none,
          decoration: decoration.copyWith(border: null),
          child: contentWidget,
        ),
      );
    } else {
      containerWidget = Container(
        width: explicitWidth ?? double.infinity,
        height:
            explicitHeight, // FIX: Respect explicit bounds when layout is not auto!
        clipBehavior: Clip.none,
        decoration: decoration,
        child: contentWidget,
      );
    }

    // Apply clipping
    if (clipsContent) {
      containerWidget = ClipRRect(
        borderRadius: radius,
        child: containerWidget,
      );
    }

    // Apply Filters
    containerWidget =
        NinjaLayerUtils.applyFilterString(containerWidget, style['filter']);

    // Apply Glassmorphism
    if (isGlassEnabled && glassBlurValue > 0) {
      containerWidget = Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: dart_ui.ImageFilter.blur(
                    sigmaX: glassBlurValue, sigmaY: glassBlurValue),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          containerWidget,
        ],
      );
    }

    // Apply Opacity
    if (opacity < 1.0) {
      containerWidget = Opacity(opacity: opacity, child: containerWidget);
    }

    // Dashboard Parity: Apply click actions natively on containers/cards
    // This allows Grid Items and wrapper cards to initiate navigation, matching TSX DraggableLayerWrapper behavior.
    final actionObj = layer['action'];
    final actionType = actionObj is Map ? actionObj['type'] : layer['actionType'];
    final actionData = actionObj is Map ? Map<String, dynamic>.from(actionObj) : layer;
    
    if (actionType != null && onAction != null) {
      containerWidget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onAction!(actionType.toString(), actionData),
        child: containerWidget,
      );
    }

    return containerWidget;
  }

  // --- Mappings ---

  MainAxisAlignment _mapJustifyContent(String value) {
    switch (value) {
      case 'center':
        return MainAxisAlignment.center;
      case 'flex-end':
      case 'end':
        return MainAxisAlignment.end;
      case 'space-between':
        return MainAxisAlignment.spaceBetween;
      case 'space-around':
        return MainAxisAlignment.spaceAround;
      case 'space-evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _mapAlignItems(String? value) {
    switch (value) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'flex-end':
      case 'end':
        return CrossAxisAlignment.end;
      case 'flex-start':
      case 'start':
        return CrossAxisAlignment.start;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        // FIX 1: By default, Web/DOM aligns items via 'stretch' in flex containers.
        // Flutter defaults to shrinking. Force CSS parity default.
        return CrossAxisAlignment.stretch;
    }
  }

  WrapAlignment _mapWrapAlignment(String value) {
    switch (value) {
      case 'center':
        return WrapAlignment.center;
      case 'flex-end':
      case 'end':
        return WrapAlignment.end;
      case 'space-between':
        return WrapAlignment.spaceBetween;
      case 'space-around':
        return WrapAlignment.spaceAround;
      case 'space-evenly':
        return WrapAlignment.spaceEvenly;
      default:
        return WrapAlignment.start;
    }
  }

  WrapCrossAlignment _mapWrapCrossAlignment(String value) {
    switch (value) {
      case 'center':
        return WrapCrossAlignment.center;
      case 'flex-end':
      case 'end':
        return WrapCrossAlignment.end;
      default:
        return WrapCrossAlignment.start;
    }
  }
}
