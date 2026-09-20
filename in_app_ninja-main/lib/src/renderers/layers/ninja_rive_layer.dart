import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'package:rive/rive.dart';
import 'ninja_layer_utils.dart';
import '../../utils/ninja_logger.dart';

/// NinjaRiveLayer — Flutter equivalent of RiveRenderer.tsx
/// Mirrors the Lottie layer architecture exactly:
///   ClipRRect → AspectRatio → Shadow Container → SizedBox → ImageFiltered → Opacity
class NinjaRiveLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(String, Map<String, dynamic>?)? onAction;
  // Dashboard Parity: isActive controls carousel slide visibility playback.
  final bool isActive;

  const NinjaRiveLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scale = 1.0,
    this.onAction,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<NinjaRiveLayer> createState() => _NinjaRiveLayerState();
}

class _NinjaRiveLayerState extends State<NinjaRiveLayer> {
  // Rive runtime controllers
  StateMachineController? _stateMachineController;
  Artboard? _artboard;
  double? _nativeAspectRatio;
  bool _isLoaded = false;
  bool _hasError = false;

  bool _areMapsEqual(Map? map1, Map? map2) {
    if (identical(map1, map2)) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NinjaRiveLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldContent =
        oldWidget.layer['content'] as Map<String, dynamic>? ?? {};
    final newContent =
        widget.layer['content'] as Map<String, dynamic>? ?? {};

    // Reload if URL changed
    final oldUrl = oldContent['riveUrl']?.toString() ?? '';
    final newUrl = newContent['riveUrl']?.toString() ?? '';
    if (oldUrl != newUrl) {
      _loadRiveFile();
      return;
    }

    // Handle isActive and autoPlay changes (carousel playback parity)
    final oldAutoPlay = oldContent['autoPlay'] ?? true;
    final newAutoPlay = newContent['autoPlay'] ?? true;
    if ((widget.isActive != oldWidget.isActive || oldAutoPlay != newAutoPlay) &&
        _stateMachineController != null) {
      _stateMachineController!.isActive = newAutoPlay && widget.isActive;
    }

    // Apply input changes (using shallow map equality check to prevent infinite triggers)
    final oldInputs = oldContent['riveInputs'] as Map<String, dynamic>?;
    final newInputs = newContent['riveInputs'] as Map<String, dynamic>?;
    if (!_areMapsEqual(oldInputs, newInputs)) {
      _applyInputs(newInputs);
    }
  }

  Future<void> _loadRiveFile() async {
    final content =
        widget.layer['content'] as Map<String, dynamic>? ?? {};
    final url = content['riveUrl']?.toString();

    // Clean up old controller and clear states immediately to prevent memory leaks and frame flicker
    _stateMachineController?.dispose();
    _stateMachineController = null;
    _artboard = null;
    _nativeAspectRatio = null;

    if (url == null || url.isEmpty) {
      setState(() {
        _isLoaded = false;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoaded = false;
      _hasError = false;
    });

    try {
      final file = await RiveFile.network(url);
      if (!mounted) return;

      // Race condition guard: Ensure the URL we finished loading is still the current URL
      final currentContent =
          widget.layer['content'] as Map<String, dynamic>? ?? {};
      if (currentContent['riveUrl']?.toString() != url) {
        return;
      }

      final artboardName = content['artboardName']?.toString();
      final artboard = artboardName != null && artboardName.isNotEmpty
          ? file.artboardByName(artboardName)
          : file.mainArtboard;

      if (artboard == null) {
        setState(() => _hasError = true);
        return;
      }

      // Get native aspect ratio
      final nativeW = artboard.width;
      final nativeH = artboard.height;
      double? ratio;
      if (nativeW > 0 && nativeH > 0) {
        ratio = nativeW / nativeH;
      }

      // Set up state machine controller
      StateMachineController? smController;

      final smName = content['stateMachineName']?.toString();
      if (smName != null && smName.isNotEmpty) {
        smController =
            StateMachineController.fromArtboard(artboard, smName);
      } else {
        // Default: try first state machine
        for (final sm in artboard.stateMachines) {
          smController =
              StateMachineController.fromArtboard(artboard, sm.name);
          if (smController != null) break;
        }
      }

      if (smController != null) {
        artboard.addController(smController);
        // Respect autoPlay from content (default true)
        final autoPlay = content['autoPlay'] ?? true;
        smController.isActive = autoPlay && widget.isActive;
      }

      setState(() {
        _artboard = artboard;
        _stateMachineController = smController;
        _nativeAspectRatio = ratio;
        _isLoaded = true;
        _hasError = false;
      });

      // Apply initial inputs
      _applyInputs(content['riveInputs'] as Map<String, dynamic>?);
    } catch (e) {
      NinjaLog.d('AppNinja', 'NinjaRiveLayer: Error loading .riv: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoaded = false;
        });
      }
    }
  }

  void _applyInputs(Map<String, dynamic>? inputs) {
    if (inputs == null || _stateMachineController == null) return;

    for (final entry in inputs.entries) {
      final inputName = entry.key;
      final value = entry.value;

      for (final smi in _stateMachineController!.inputs) {
        if (smi.name == inputName) {
          if (smi is SMIBool && value is bool) {
            smi.value = value;
          } else if (smi is SMINumber && value is num) {
            smi.value = value.toDouble();
          } else if (smi is SMITrigger && value == true) {
            smi.fire();
          }
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content =
        widget.layer['content'] as Map<String, dynamic>? ?? {};
    final style =
        widget.layer['style'] as Map<String, dynamic>? ?? {};

    // 1. Dimensions (same logic as NinjaLottieLayer)
    final explicitWidth = style['width'] ?? widget.layer['size']?['width'];
    final explicitHeight = style['height'] ?? widget.layer['size']?['height'];

    double? width = NinjaLayerUtils.parseResponsiveSize(
        explicitWidth, context,
        isVertical: false, parentSize: widget.parentSize);
    double? height = NinjaLayerUtils.parseResponsiveSize(
        explicitHeight, context,
        isVertical: true, parentSize: widget.parentSize);

    // 2. Object Fit
    final objectFit = style['objectFit']?.toString() ?? 'contain';
    BoxFit fit = NinjaLayerUtils.parseBoxFit(objectFit);

    // 3. Border Radius
    BorderRadius borderRadius;
    if (style['borderRadius'] is Map) {
      final br = style['borderRadius'] as Map;
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(
            NinjaLayerUtils.parseDouble(br['topLeft']) ?? 0 * widget.scale),
        topRight: Radius.circular(
            NinjaLayerUtils.parseDouble(br['topRight']) ?? 0 * widget.scale),
        bottomRight: Radius.circular(
            NinjaLayerUtils.parseDouble(br['bottomRight']) ?? 0 * widget.scale),
        bottomLeft: Radius.circular(
            NinjaLayerUtils.parseDouble(br['bottomLeft']) ?? 0 * widget.scale),
      );
    } else {
      double r =
          (NinjaLayerUtils.parseDouble(style['borderRadius']) ?? 0) *
              widget.scale;
      borderRadius = BorderRadius.circular(r);
    }

    // 4. Opacity
    double opacity =
        NinjaLayerUtils.parseDouble(style['opacity']) ?? 1.0;

    // 5. Filters (blur, brightness, contrast, grayscale)
    final filterMap = style['filter'];
    double blurValue = 0;
    double brightnessValue = 100;
    double contrastValue = 100;
    double grayscaleValue = 0;

    if (filterMap is Map) {
      blurValue = (NinjaLayerUtils.parseDouble(filterMap['blur']) ?? 0) *
          widget.scale;
      brightnessValue =
          NinjaLayerUtils.parseDouble(filterMap['brightness']) ?? 100;
      contrastValue =
          NinjaLayerUtils.parseDouble(filterMap['contrast']) ?? 100;
      grayscaleValue =
          NinjaLayerUtils.parseDouble(filterMap['grayscale']) ?? 0;
    }

    // 6. Shadow
    List<BoxShadow>? shadows;
    if (style['shadowEnabled'] == true) {
      var parsedShadows = NinjaLayerUtils.parseShadowFromStyle(style, context);
      if (parsedShadows != null) {
        shadows = parsedShadows.map((s) => BoxShadow(
          color: s.color,
          blurRadius: s.blurRadius * widget.scale,
          spreadRadius: s.spreadRadius * widget.scale,
          offset: Offset(s.offset.dx * widget.scale, s.offset.dy * widget.scale),
        )).toList();
      } else {
        shadows = [
          BoxShadow(
            color: NinjaLayerUtils.parseColor(style['shadowColor']) ?? Colors.black,
            blurRadius: (NinjaLayerUtils.parseDouble(style['shadowBlur'], context) ?? 0.0) * widget.scale,
            offset: Offset(
                (NinjaLayerUtils.parseDouble(style['shadowOffsetX'] ?? 0, context) ?? 0.0) * widget.scale,
                (NinjaLayerUtils.parseDouble(style['shadowOffsetY'] ?? 4, context) ?? 4.0) * widget.scale),
            spreadRadius: (NinjaLayerUtils.parseDouble(style['shadowSpread'], context) ?? 0.0) * widget.scale,
          )
        ];
      }
    } else {
      var parsedShadows = NinjaLayerUtils.parseShadows(style['boxShadow'], context);
      if (parsedShadows != null) {
        shadows = parsedShadows
            .map((s) => BoxShadow(
                  color: s.color,
                  blurRadius: s.blurRadius * widget.scale,
                  spreadRadius: s.spreadRadius * widget.scale,
                  offset: Offset(s.offset.dx * widget.scale, s.offset.dy * widget.scale),
                ))
            .toList();
      }
    }

    // 7. Aspect ratio
    double? aspectRatio = _nativeAspectRatio;
    if (style['aspectRatio'] != null) {
      aspectRatio = NinjaLayerUtils.parseDouble(style['aspectRatio']);
    }

    // --- BUILD THE RIVE WIDGET ---
    Widget riveWidget;

    if (!_isLoaded || _artboard == null) {
      // Placeholder / error state
      riveWidget = Container(
        width: width ?? 100,
        height: height ?? 100,
        color: _hasError ? Colors.red[50] : Colors.grey[200],
        child: Center(
          child: _hasError
              ? const Icon(Icons.broken_image, color: Colors.red)
              : const Icon(Icons.play_circle_outline,
                  color: Colors.grey),
        ),
      );
    } else {
      riveWidget = Rive(
        artboard: _artboard!,
        fit: fit,
        alignment: Alignment.center,
      );
    }

    // --- WIDGET COMPOSITION PIPELINE (1:1 with LottieRenderer/NinjaLottieLayer) ---
    // Pipeline: ColorFiltered → ClipRRect → AspectRatio → Shadow → SizedBox → Blur → Opacity

    // CSS filter emulation: brightness, contrast, grayscale
    if (brightnessValue != 100 || contrastValue != 100 || grayscaleValue > 0) {
      if (grayscaleValue > 0) {
        final g = grayscaleValue / 100.0;
        final inv = 1 - g;
        final matrix = <double>[
          inv + 0.2126 * g, 0.7152 * g, 0.0722 * g, 0, 0,
          0.2126 * g, inv + 0.7152 * g, 0.0722 * g, 0, 0,
          0.2126 * g, 0.7152 * g, inv + 0.0722 * g, 0, 0,
          0, 0, 0, 1, 0,
        ];
        riveWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: riveWidget);
      }
      if (brightnessValue != 100) {
        final b = brightnessValue / 100.0;
        final matrix = <double>[
          b, 0, 0, 0, 0,
          0, b, 0, 0, 0,
          0, 0, b, 0, 0,
          0, 0, 0, 1, 0,
        ];
        riveWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: riveWidget);
      }
      if (contrastValue != 100) {
        final c = contrastValue / 100.0;
        final t = 0.5 * (1 - c) * 255;
        final matrix = <double>[
          c, 0, 0, 0, t,
          0, c, 0, 0, t,
          0, 0, c, 0, t,
          0, 0, 0, 1, 0,
        ];
        riveWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: riveWidget);
      }
    }

    // ClipRRect for borderRadius
    riveWidget = ClipRRect(
      borderRadius: borderRadius,
      child: riveWidget,
    );

    // AspectRatio
    bool hasExplicitWidth = explicitWidth != null;
    bool hasExplicitHeight = explicitHeight != null;
    if (aspectRatio != null && (!hasExplicitWidth || !hasExplicitHeight)) {
      riveWidget = AspectRatio(
        aspectRatio: aspectRatio,
        child: riveWidget,
      );
    }

    // Shadow container
    if (shadows != null && shadows.isNotEmpty) {
      riveWidget = Container(
        decoration: BoxDecoration(
          boxShadow: shadows,
          borderRadius: borderRadius,
        ),
        child: riveWidget,
      );
    }

    // SizedBox for explicit dimensions
    riveWidget = SizedBox(
      width: width,
      height: height,
      child: riveWidget,
    );

    // Blur filter
    if (blurValue > 0) {
      riveWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(
            sigmaX: blurValue, sigmaY: blurValue),
        child: riveWidget,
      );
    }

    // Opacity
    if (opacity < 1.0) {
      riveWidget = Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: riveWidget,
      );
    }

    // Action wrapper
    if (widget.onAction != null) {
      final action = content['action'] as Map<String, dynamic>?;
      if (action != null) {
        riveWidget = GestureDetector(
          onTap: () => widget.onAction!(
              action['type']?.toString() ?? 'tap', action),
          child: riveWidget,
        );
      }
    }

    return riveWidget;
  }
}
