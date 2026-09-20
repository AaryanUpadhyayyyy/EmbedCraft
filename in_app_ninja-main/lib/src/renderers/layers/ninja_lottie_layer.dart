import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'dart:convert';
import 'dart:typed_data';
import 'package:lottie/lottie.dart';
import 'ninja_layer_utils.dart';

class NinjaLottieLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(String, Map<String, dynamic>?)? onAction;
  // Dashboard Parity: isActive controls carousel slide visibility playback.
  // TSX LottieRenderer.tsx line 137-145: useEffect pauses/plays based on isActive.
  final bool isActive;

  const NinjaLottieLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scale = 1.0,
    this.onAction,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<NinjaLottieLayer> createState() => _NinjaLottieLayerState();
}

class _NinjaLottieLayerState extends State<NinjaLottieLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // Dashboard Parity: Store native animation aspect ratio for auto-dimension sizing.
  // Equivalent to the dashboard's useState<string>(animAspectRatio).
  double? _nativeAspectRatio;
  Duration? _baseDuration;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NinjaLottieLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Dashboard Parity: isActive carousel playback control
    // TSX LottieRenderer.tsx line 137-145:
    //   if (isActive && autoPlay) animRef.current.play();
    //   else if (!isActive) animRef.current.pause();
    if (widget.isActive != oldWidget.isActive && _baseDuration != null) {
      final newContent = widget.layer['content'] as Map<String, dynamic>? ?? {};
      final autoPlay = newContent['autoPlay'] ?? true;
      if (widget.isActive && autoPlay) {
        if ((newContent['loop'] ?? true) == true) {
          _controller.repeat();
        } else {
          _controller.forward();
        }
      } else if (!widget.isActive) {
        _controller.stop();
      }
    }

    if (widget.layer != oldWidget.layer) {
      final oldContent = oldWidget.layer['content'] as Map<String, dynamic>? ?? {};
      final newContent = widget.layer['content'] as Map<String, dynamic>? ?? {};

      final oldAutoPlay = oldContent['autoPlay'] ?? true;
      final newAutoPlay = newContent['autoPlay'] ?? true;

      final oldLoop = oldContent['loop'] ?? true;
      final newLoop = newContent['loop'] ?? true;

      final oldSpeed = NinjaLayerUtils.parseDouble(oldContent['speed']) ?? 1.0;
      final newSpeed = NinjaLayerUtils.parseDouble(newContent['speed']) ?? 1.0;

      bool playbackChanged = false;

      if (oldSpeed != newSpeed && _baseDuration != null) {
        final v = newSpeed > 0 ? newSpeed : 1.0;
        _controller.duration = Duration(milliseconds: (_baseDuration!.inMilliseconds / v).round());
        playbackChanged = true;
      }

      if (oldAutoPlay != newAutoPlay || oldLoop != newLoop) {
        playbackChanged = true;
      }

      if (playbackChanged && _baseDuration != null) {
        if (newAutoPlay && widget.isActive) {
          if (newLoop) {
            _controller.repeat();
          } else {
            if (!_controller.isAnimating) {
              _controller.forward(from: 0.0);
            }
          }
        } else {
          _controller.stop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    final style = widget.layer['style'] as Map<String, dynamic>? ?? {};

    // 1. Get Lottie Source
    String? url = content['lottieUrl'] as String?;
    String? rawJson = content['lottieJson'] as String?;
    
    // Dashboard Parity: resolve mapped_key for dynamic lottie URL
    final mappedState = widget.layer['mappedState'] as Map<String, dynamic>?;
    final mappedKey = content['mapped_key'] as String?;
    
    if (mappedState != null && mappedKey != null && mappedKey.isNotEmpty) {
      final paths = mappedKey.split('.');
      dynamic value = mappedState;
      for (final p in paths) {
        if (value is Map && value.containsKey(p)) {
          value = value[p];
        } else {
          value = null;
          break;
        }
      }
      if (value != null) {
        url = value.toString();
      }
    }
    
    // 2. Playback config
    final autoPlay = content['autoPlay'] ?? true;
    final loop = content['loop'] ?? true;
    final speed = NinjaLayerUtils.parseDouble(content['speed']) ?? 1.0;

    // 3. Shadow Logic
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

    // 4. Dimensions (Dashboard Parity: Fallback to layer.size if style.width is missing)
    final explicitWidth = style['width'] ?? widget.layer['size']?['width'];
    final explicitHeight = style['height'] ?? widget.layer['size']?['height'];

    final width = NinjaLayerUtils.parseResponsiveSize(explicitWidth, context,
        isVertical: false, parentSize: widget.parentSize);
    final height = NinjaLayerUtils.parseResponsiveSize(explicitHeight, context,
        isVertical: true, parentSize: widget.parentSize);

    // 5. Styling Properties (same pattern as NinjaImageLayer)
    BorderRadius borderRadius;
    final dynamic rawRadius = style['borderRadius'];
    if (rawRadius is Map) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular((NinjaLayerUtils.parseDouble(rawRadius['topLeft'], context) ?? 0) * widget.scale),
        topRight: Radius.circular((NinjaLayerUtils.parseDouble(rawRadius['topRight'], context) ?? 0) * widget.scale),
        bottomLeft: Radius.circular((NinjaLayerUtils.parseDouble(rawRadius['bottomLeft'], context) ?? 0) * widget.scale),
        bottomRight: Radius.circular((NinjaLayerUtils.parseDouble(rawRadius['bottomRight'], context) ?? 0) * widget.scale),
      );
    } else {
      final r = NinjaLayerUtils.parseDouble(rawRadius, context) ?? 0;
      borderRadius = BorderRadius.circular(r * widget.scale);
    }

    // Dashboard Parity: objectFit defaults to 'contain' (matching LottieRenderer.tsx line 45)
    final fitStr = style['objectFit'] ?? 'contain';
    final opacity = NinjaLayerUtils.parseDouble(style['opacity']) ?? 1.0;
    // Aspect Ratio from style (user-configured)
    final styleAspectRatio = NinjaLayerUtils.parseDouble(style['aspectRatio']);

    // Filters (same as NinjaImageLayer)
    final filters = style['filter'];
    final double rawBlur = filters is Map
        ? (NinjaLayerUtils.parseDouble(filters['blur']?.toString(), context) ?? 0)
        : 0;
    final double blur = (rawBlur / 2.0) * widget.scale;
    final double brightness = filters is Map
        ? (double.tryParse(filters['brightness']?.toString() ?? '') ?? 100)
        : 100;
    final double contrast = filters is Map
        ? (double.tryParse(filters['contrast']?.toString() ?? '') ?? 100)
        : 100;
    final double grayscale = filters is Map
        ? (double.tryParse(filters['grayscale']?.toString() ?? '') ?? 0)
        : 0;

    BoxFit fit;
    switch (fitStr) {
      case 'cover':
        fit = BoxFit.cover;
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
      case 'contain':
      default:
        fit = BoxFit.contain;
        break;
    }

    // --- WIDGET CONSTRUCTION (matches NinjaImageLayer pattern exactly) ---

    // A. Base Lottie Widget
    Widget lottieWidget;

    if (rawJson != null && rawJson.trim().isNotEmpty) {
      try {
        final bytes = utf8.encode(rawJson);
        lottieWidget = Lottie.memory(
          Uint8List.fromList(bytes),
          width: width,
          height: height,
          fit: fit,
          controller: _controller,
          onLoaded: (composition) {
            _baseDuration = composition.duration;
            _controller.duration = composition.duration;
            
            // Dashboard Parity: Read native animation dimensions for aspect-ratio.
            final nativeW = composition.bounds.width;
            final nativeH = composition.bounds.height;
            if (nativeW > 0 && nativeH > 0) {
              final newRatio = nativeW / nativeH;
              if (_nativeAspectRatio != newRatio) {
                setState(() {
                  _nativeAspectRatio = newRatio;
                });
              }
            }

            final v = speed > 0 ? speed : 1.0;
            _controller.duration = Duration(milliseconds: (_baseDuration!.inMilliseconds / v).round());
            // Dashboard Parity: Only auto-play if isActive (carousel slide visible)
            // TSX: isActive useEffect gates play/pause independently of autoPlay config
            if (autoPlay && widget.isActive) {
              if (loop) {
                _controller.repeat();
              } else {
                _controller.forward(from: 0.0);
              }
            } else {
              _controller.value = 0;
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width ?? 100,
              height: height ?? 100,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      } catch (e) {
        lottieWidget = Container(
          width: width ?? 100,
          height: height ?? 100,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    } else if (url != null && url.isNotEmpty) {
      lottieWidget = Lottie.network(
        url,
        width: width,
        height: height,
        fit: fit,
        controller: _controller,
        onLoaded: (composition) {
          _baseDuration = composition.duration;
          _controller.duration = composition.duration;
          
          // Dashboard Parity: Read native animation dimensions for aspect-ratio.
          // This is the Dart equivalent of the dashboard's DOMLoaded → setAnimAspectRatio.
          final nativeW = composition.bounds.width;
          final nativeH = composition.bounds.height;
          if (nativeW > 0 && nativeH > 0) {
            final newRatio = nativeW / nativeH;
            if (_nativeAspectRatio != newRatio) {
              setState(() {
                _nativeAspectRatio = newRatio;
              });
            }
          }

          final v = speed > 0 ? speed : 1.0;
          _controller.duration = Duration(milliseconds: (_baseDuration!.inMilliseconds / v).round());
          // Dashboard Parity: Only auto-play if isActive (carousel slide visible)
          if (autoPlay && widget.isActive) {
            if (loop) {
              _controller.repeat();
            } else {
              _controller.forward(from: 0.0);
            }
          } else {
            _controller.value = 0;
          }
        },
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
      lottieWidget = Container(
        width: width ?? 100,
        height: height ?? 100,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    // B. Apply Color Matrix Filters (same as NinjaImageLayer)
    if (brightness != 100 || contrast != 100 || grayscale > 0) {
      if (grayscale > 0) {
        final g = grayscale / 100.0;
        final inv = 1 - g;
        final matrix = <double>[
          inv + 0.2126 * g, 0.7152 * g, 0.0722 * g, 0, 0,
          0.2126 * g, inv + 0.7152 * g, 0.0722 * g, 0, 0,
          0.2126 * g, 0.7152 * g, inv + 0.0722 * g, 0, 0,
          0, 0, 0, 1, 0,
        ];
        lottieWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: lottieWidget);
      }
      if (brightness != 100) {
        final b = brightness / 100.0;
        final matrix = <double>[
          b, 0, 0, 0, 0,
          0, b, 0, 0, 0,
          0, 0, b, 0, 0,
          0, 0, 0, 1, 0,
        ];
        lottieWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: lottieWidget);
      }
      if (contrast != 100) {
        final c = contrast / 100.0;
        final t = 0.5 * (1 - c) * 255;
        final matrix = <double>[
          c, 0, 0, 0, t,
          0, c, 0, 0, t,
          0, 0, c, 0, t,
          0, 0, 0, 1, 0,
        ];
        lottieWidget = ColorFiltered(
            colorFilter: ColorFilter.matrix(matrix), child: lottieWidget);
      }
    }

    // C. Clip Border Radius (Matches CSS inner content clipping)
    if (borderRadius != BorderRadius.zero) {
      lottieWidget = ClipRRect(
        borderRadius: borderRadius,
        child: lottieWidget,
      );
    }

    // D. AspectRatio wrapper
    final effectiveAspectRatio = (explicitWidth == null || explicitHeight == null)
        ? (_nativeAspectRatio ?? styleAspectRatio)
        : styleAspectRatio;

    if (effectiveAspectRatio != null && effectiveAspectRatio > 0) {
      lottieWidget = AspectRatio(
        aspectRatio: effectiveAspectRatio,
        child: lottieWidget,
      );
    }

    // E. Container for Shadow (Matches CSS box-shadow)
    Widget finalWidget = lottieWidget;
    if (shadows != null && shadows.isNotEmpty) {
      finalWidget = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadows,
        ),
        clipBehavior: Clip.none,
        child: finalWidget,
      );
    }

    // F. Enforce explicit dimensions (Matches CSS width/height bounds)
    finalWidget = SizedBox(
      width: width,
      height: height,
      child: finalWidget,
    );

    // G. Apply Blur (Matches CSS filter: blur() affecting entire element + shadow)
    if (blur > 0) {
      finalWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: finalWidget,
      );
    }

    // H. Apply Opacity (Matches CSS opacity affecting entire element + shadow)
    if (opacity < 1.0) {
      finalWidget = Opacity(opacity: opacity, child: finalWidget);
    }

    // I. Click Action Handler
    final clickActionMap = widget.layer['clickAction'] as Map<String, dynamic>? ??
        widget.layer['content']?['clickAction'] as Map<String, dynamic>?;
    final actionProp = widget.layer['content']?['action'];

    if ((clickActionMap != null || actionProp != null) && widget.onAction != null) {
      finalWidget = GestureDetector(
        onTap: () {
          if (clickActionMap != null) {
            final type = clickActionMap['type'] ?? 'submit';
            widget.onAction!(type, clickActionMap);
          } else if (actionProp != null) {
            final actionStr = actionProp is Map ? actionProp['type'] : actionProp.toString();
            final actionData = actionProp is Map ? (actionProp as Map<String, dynamic>) : <String, dynamic>{};
            widget.onAction!(actionStr, actionData);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: finalWidget,
      );
    }

    return finalWidget;
  }
}
