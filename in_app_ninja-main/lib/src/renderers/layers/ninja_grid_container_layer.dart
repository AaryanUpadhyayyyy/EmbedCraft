import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ninja_layer_utils.dart';
import '../../app_ninja.dart';
import '../../utils/ninja_logger.dart';

class NinjaGridContainerLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final List<dynamic>? allLayers;
  final double scale;
  final double scaleY;
  final Widget Function(
      Map<String, dynamic> childLayer, Map<String, dynamic>? mappedData,
      {double? parentWidth, double? parentHeight})? renderChild;

  const NinjaGridContainerLayer({
    Key? key,
    required this.layer,
    this.allLayers,
    this.scale = 1.0,
    this.scaleY = 1.0,
    this.renderChild,
  }) : super(key: key);

  @override
  _NinjaGridContainerLayerState createState() =>
      _NinjaGridContainerLayerState();
}

class _NinjaGridContainerLayerState extends State<NinjaGridContainerLayer>
    with SingleTickerProviderStateMixin {
  List<dynamic>? fetchedData;
  bool isLoading = false;
  String? error;
  AnimationController? _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _fetchDataSource();
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  String _interpolate(String template, Map<String, dynamic> variables) {
    String result = template;
    final regex = RegExp(r'\{\{\s*([a-zA-Z0-9_\-\.]+)\s*\}\}');
    result = result.replaceAllMapped(regex, (match) {
      final key = match.group(1);
      if (variables.containsKey(key)) {
        return variables[key]?.toString() ?? '';
      }
      return match.group(0) ?? '';
    });
    return result;
  }

  dynamic _traversePath(dynamic data, String path) {
    if (path.isEmpty || data == null) return data;
    final parts = path.split('.');
    dynamic current = data;
    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  Future<void> _fetchDataSource() async {
    final content = widget.layer['content'] ?? {};
    final String? rawUrl = content['dataSourceUrl'];

    if (rawUrl == null || rawUrl.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 1. Gather all identified user attributes for interpolation
      final userDetails = await AppNinja.getUserDetails();
      final String userId = userDetails?['user_id']?.toString() ?? '';
      final Map<String, dynamic> userAttrs = {
        'userId': userId,
        'user_id': userId,
        ...?AppNinja.currentUserProperties,
      };

      // 2. Interpolate URL
      String fetchUrl = _interpolate(rawUrl, userAttrs);
      if (fetchUrl.startsWith('/')) {
        fetchUrl = '${AppNinja.baseUrl}$fetchUrl';
      }

      // Default relative path appends for backward compatibility if userId isn't in URL already
      if (rawUrl.startsWith('/') && !fetchUrl.contains('userId=')) {
        final separator = fetchUrl.contains('?') ? '&' : '?';
        fetchUrl += '${separator}userId=${Uri.encodeComponent(userId)}';
      }

      NinjaLog.d('AppNinja', '[NinjaGrid] Fetching: $fetchUrl');

      // 3. Build and interpolate Headers
      final apiKey = AppNinja.getApiKey();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (apiKey != null && apiKey.isNotEmpty) {
        headers['x-api-key'] = apiKey;
      }

      final String? rawHeadersJson = content['dataSourceHeaders'];
      if (rawHeadersJson != null && rawHeadersJson.isNotEmpty) {
        try {
          final decodedHeaders = json.decode(rawHeadersJson);
          if (decodedHeaders is Map) {
            decodedHeaders.forEach((key, val) {
              final String interpolatedVal = _interpolate(val.toString(), userAttrs);
              headers[key.toString()] = interpolatedVal;
            });
          }
        } catch (e) {
          // Raw string fallback (e.g. key-value lines)
          rawHeadersJson.split('\n').forEach((line) {
            final idx = line.indexOf(':');
            if (idx != -1) {
              final k = line.substring(0, idx).trim();
              final v = line.substring(idx + 1).trim();
              if (k.isNotEmpty) {
                headers[k] = _interpolate(v, userAttrs);
              }
            }
          });
        }
      }

      // 4. Dispatch correct HTTP Method (GET or POST)
      final String method = (content['dataSourceMethod']?.toString() ?? 'GET').toUpperCase();
      http.Response response;

      if (method == 'POST') {
        response = await http.post(
          Uri.parse(fetchUrl),
          headers: headers,
          body: json.encode(userAttrs),
        ).timeout(const Duration(seconds: 15));
      } else {
        response = await http.get(
          Uri.parse(fetchUrl),
          headers: headers,
        ).timeout(const Duration(seconds: 15));
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final decodedData = json.decode(response.body);
          setState(() {
            // 5. Traverse response JSON using Response Data Path
            final String? path = content['responseDataPath'];
            final dynamic rawTarget = (path != null && path.isNotEmpty) 
                ? _traversePath(decodedData, path) 
                : decodedData;

            // Flexible array parsing identical to React Dashboard
            List<dynamic> arr = [];
            if (rawTarget is List) {
              arr = rawTarget;
            } else if (rawTarget is Map<String, dynamic>) {
              var extracted = rawTarget['data'] ??
                  rawTarget['items'] ??
                  rawTarget['rewards'] ??
                  rawTarget['results'];
              if (extracted is List) {
                arr = extracted;
              } else {
                arr = [rawTarget]; // wrap single object
              }
            } else if (rawTarget != null) {
              arr = [rawTarget];
            }

            // Client-side sorting for Reward Repo: "pending" (unscratched) rewards first
            if (arr.isNotEmpty && arr[0] is Map && arr[0].containsKey('status')) {
              arr.sort((a, b) {
                final statusA = a['status']?.toString().toLowerCase() ?? '';
                final statusB = b['status']?.toString().toLowerCase() ?? '';
                if (statusA == 'pending' && statusB != 'pending') return -1;
                if (statusB == 'pending' && statusA != 'pending') return 1;
                return 0;
              });
            }

            fetchedData = arr;
            isLoading = false;
          });
        } catch (e) {
          NinjaLog.d('AppNinja', '[NinjaGrid] JSON parsing error: $e');
          setState(() {
            error = 'Invalid data configuration received.';
            isLoading = false;
          });
        }
      } else {
        NinjaLog.d('AppNinja', 
            '[NinjaGrid] Fetch failed: ${response.statusCode} ${response.body}');
        setState(() {
          error = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      NinjaLog.d('AppNinja', '[NinjaGrid] Fetch error: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildSkeletonCard({
    required double width,
    required double height,
    required BorderRadius borderRadius,
    required Color cardBgColor,
    required double animValue,
    required Color containerBgColor,
  }) {
    final Color referenceColor = (cardBgColor != Colors.transparent)
        ? cardBgColor
        : (containerBgColor != Colors.transparent ? containerBgColor : const Color(0xFFFFFFFF));
        
    final double luminance = referenceColor.computeLuminance();
    final bool isDark = luminance < 0.35;

    final Color effectiveCardBg = cardBgColor != Colors.transparent
        ? cardBgColor
        : (isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF));
        
    final Color borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    
    final Color shimmerBase = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final Color shimmerHighlight = isDark ? const Color(0xFF4B5563) : const Color(0xFFF3F4F6);

    final shimmerGradient = LinearGradient(
      colors: [shimmerBase, shimmerHighlight, shimmerBase],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment(animValue * 4 - 2, -0.3),
      end: Alignment(animValue * 4, 0.3),
    );

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(12 * widget.scale),
      decoration: BoxDecoration(
        color: effectiveCardBg,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: 1 * widget.scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: shimmerGradient,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 14 * widget.scaleY,
            width: double.infinity * 0.8,
            decoration: BoxDecoration(
              gradient: shimmerGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 10 * widget.scaleY,
            width: double.infinity * 0.6,
            decoration: BoxDecoration(
              gradient: shimmerGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 32 * widget.scaleY,
            width: double.infinity * 0.85,
            decoration: BoxDecoration(
              gradient: shimmerGradient,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = widget.layer['content'] ?? {};
    final Map<String, dynamic> style = widget.layer['style'] ?? {};

    // Grid Setup
    final int span = NinjaLayerUtils.parseInt(content['span']) ?? 2;
    final double gridGapX =
        NinjaLayerUtils.safeScale(content['gridGapX'], widget.scale) ?? 0.0;
    final double gridGapY =
        NinjaLayerUtils.safeScale(content['gridGapY'], widget.scaleY) ?? 0.0;

    // UI Layout overrides
    final backgroundColor =
        NinjaLayerUtils.parseColor(style['backgroundColor']);
    // Dashboard Parity: borderRadius and boxShadow are handled by the outer DraggableLayerWrapper/FloaterRenderV2 wrapper.
    // We strictly apply ONLY backgroundColor internally to map the GridStyle.

    // Dashboard Parity: Dynamic Aspect Ratio Calculation
    // REMOVED: Dashboard CSS Grid natively auto-sizes based on content.
    // Forcing calculatedAspectRatio causes grid items to render as squares instead of their intrinsic dimensions!
    final List<Map<String, dynamic>> children = widget.allLayers != null
        ? widget.allLayers!
            .where((l) => l is Map && l['parent'] == widget.layer['id'])
            .cast<Map<String, dynamic>>()
            .toList()
        : (widget.layer['children'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];

    Widget containerWidget;

    if (isLoading && content['shimmerEnabled'] != false) {
      containerWidget = Container(
        color: backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double exactParentWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
                
            final double cellWidth =
                ((exactParentWidth - (gridGapX * (span - 1))) / span) - 0.001;
                
            // Try to extract card styling from the template grid_item
            final gridItems = children.where((c) => c['type'] == 'grid_item').toList();
            double itemHeight = 180.0 * widget.scaleY; // premium default height
            BorderRadius itemBorderRadius = BorderRadius.circular(13.0);
            Color itemBgColor = const Color(0xFFF9FAFB);
            
            if (gridItems.isNotEmpty) {
              final firstItem = gridItems.first;
              final itemStyle = firstItem['style'] as Map<String, dynamic>? ?? {};
              
              if (itemStyle['height'] != null) {
                final h = NinjaLayerUtils.parseDouble(itemStyle['height']);
                if (h != null && h > 0) {
                  itemHeight = h * widget.scaleY;
                }
              }
              
              final radiusRaw = itemStyle['borderRadius'];
              if (radiusRaw is Map) {
                itemBorderRadius = BorderRadius.only(
                  topLeft: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['topLeft']) ?? 13.0) * widget.scale),
                  topRight: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['topRight']) ?? 13.0) * widget.scale),
                  bottomLeft: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['bottomLeft']) ?? 13.0) * widget.scale),
                  bottomRight: Radius.circular((NinjaLayerUtils.parseDouble(radiusRaw['bottomRight']) ?? 13.0) * widget.scale),
                );
              } else if (radiusRaw != null) {
                final r = NinjaLayerUtils.parseDouble(radiusRaw);
                if (r != null) {
                  itemBorderRadius = BorderRadius.circular(r * widget.scale);
                }
              }
              
              final parsedBg = NinjaLayerUtils.parseColor(itemStyle['backgroundColor']);
              if (parsedBg != null) {
                itemBgColor = parsedBg;
              }
            }
            
            return AnimatedBuilder(
              animation: _shimmerController!,
              builder: (context, child) {
                final double animValue = _shimmerController!.value;
                return Wrap(
                  spacing: gridGapX,
                  runSpacing: gridGapY,
                  children: List.generate(span * 2, (index) {
                    return _buildSkeletonCard(
                      width: cellWidth,
                      height: itemHeight,
                      borderRadius: itemBorderRadius,
                      cardBgColor: itemBgColor,
                      animValue: animValue,
                      containerBgColor: backgroundColor ?? const Color(0xFFFFFFFF),
                    );
                  }),
                );
              },
            );
          }
        ),
      );
    } else if (error != null) {
      containerWidget = Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)));
    } else {
      final dataArray = fetchedData ??
          (content['dataSourceUrl']?.isEmpty ?? true ? [{}] : []);



      containerWidget = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = MediaQuery.of(context).size;
            final exactParentWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : screenSize.width;

            final gridItems = children.where((c) => c['type'] == 'grid_item').toList();
            final emptyStateLayers = children.where((c) => c['type'] != 'grid_item').toList();

            // EMPTY STATE FALLBACK
            if (dataArray.isEmpty && emptyStateLayers.isNotEmpty) {
                if (widget.renderChild != null) {
                    // Dashboard Parity: Force relative positioning and full size
                    // Render ALL fallback children vertically, just like React
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: emptyStateLayers.map((child) {
                        final fallbackLayer = Map<String, dynamic>.from(child);
                        final fallbackStyle = Map<String, dynamic>.from(fallbackLayer['style'] ?? {});
                        
                        fallbackStyle['position'] = 'relative';
                        fallbackStyle['width'] = '100%';
                        if (!fallbackStyle.containsKey('height')) {
                           fallbackStyle['height'] = '100%'; 
                        }
                        if (!fallbackStyle.containsKey('minHeight')) {
                           fallbackStyle['minHeight'] = '100%'; 
                        }
                        fallbackStyle['top'] = 0;
                        fallbackStyle['left'] = 0;
                        fallbackLayer['style'] = fallbackStyle;

                        return widget.renderChild!(fallbackLayer, null,
                            parentWidth: exactParentWidth,
                            parentHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : null
                        );
                      }).toList(),
                    );
                }
                return const SizedBox();
            }

            // Calculate pixel-perfect fractional width for grid masonry parity
            // (TotalWidth - TotalGaps) / columns (Subtract 0.001 to avoid flutter precision drift wrapping)
            final double cellWidth =
                ((exactParentWidth - (gridGapX * (span - 1))) / span) - 0.001;

            // Dashboard Parity: Native Wrap implementation
            // Eliminates IntrinsicHeight crashes and avoids GridView square-ratio forcing.
            // Grid cells dynamically take the height of their respective children.
            Widget gridContent = Wrap(
              spacing: gridGapX,
              runSpacing: gridGapY,
              children: List.generate(dataArray.length, (itemIndex) {
                final mappedData = dataArray[itemIndex];

                final childWidgets = gridItems.map((templateChild) {
                  if (widget.renderChild != null) {
                    // Dashboard Parity: Force relative positioning for mapped grid items, but preserve user's width/height!
                    final gridItemLayer = Map<String, dynamic>.from(templateChild);
                    final gridItemStyle = Map<String, dynamic>.from(gridItemLayer['style'] ?? {});
                    gridItemStyle['position'] = 'relative';
                    gridItemStyle['top'] = 0;
                    gridItemStyle['left'] = 0;
                    gridItemLayer['style'] = gridItemStyle;
                    gridItemLayer['is_grid_item'] = true; // Inject flag for gamification wrappers

                    return widget.renderChild!(gridItemLayer, mappedData,
                        parentWidth: cellWidth,
                        parentHeight: null, // Allow unbounded height to let items size to their contents, just like CSS Grid auto rows!
                        );
                  }
                  return const SizedBox();
                }).toList();

                return SizedBox(
                  width: cellWidth,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: childWidgets.length == 1
                        ? childWidgets.first
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: childWidgets),
                  ),
                );
              }),
            );

            // Dashboard parity: 'overflowY: auto' is hardcoded in GridContainerRenderer.tsx
            // thus grid containers are always scrollable if their content overflows the bounded height.
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              child: gridContent,
            );
          },
        ),
      );
    }

    return containerWidget;
  }
}
