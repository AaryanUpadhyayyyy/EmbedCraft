import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../utils/ninja_logger.dart';

const _progressReportStep = 0.1;

/// How accurate should the progress be tracked.
enum ScratchAccuracy {
  /// Low accuracy, higher performance.
  low,

  /// Medium accuracy, medium performance
  medium,

  /// High accuracy, lower performance.
  high,
}

double _getAccuracyValue(ScratchAccuracy accuracy) {
  switch (accuracy) {
    case ScratchAccuracy.low:
      return 10.0;
    case ScratchAccuracy.medium:
      return 30.0;
    case ScratchAccuracy.high:
      return 100.0;
  }
}

class ScratchPoint {
  ScratchPoint(this.position, this.size);

  // Null position is dedicated for point which closes the continuous drawing
  final Offset? position;
  final double size;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScratchPoint &&
        other.position == position &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(position, size);
}

/// Custom painter object which handles revealing of color/image
class ScratchPainter extends CustomPainter {
  ScratchPainter({
    required this.points,
    required this.color,
    required this.onDraw,
    this.image,
    this.imageFit,
  });

  /// List of revealed points from scratcher
  final List<ScratchPoint?> points;

  /// Background color of the scratch area
  final Color color;

  /// Callback called each time the painter is redrawn
  final void Function(Size) onDraw;

  /// Path to local image which can be used as scratch area
  final ui.Image? image;

  /// Determine how the image should fit the scratch area
  final BoxFit? imageFit;

  Paint _getMainPaint(double strokeWidth) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..blendMode = BlendMode.clear
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(size);

    canvas.saveLayer(null, Paint());

    final areaRect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(areaRect, Paint()..color = color);
    if (image != null && imageFit != null) {
      final imageSize = Size(image!.width.toDouble(), image!.height.toDouble());
      final sizes = applyBoxFit(imageFit!, imageSize, size);
      final inputSubrect =
          Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      final outputSubrect =
          Alignment.center.inscribe(sizes.destination, areaRect);

      canvas.drawImageRect(image!, inputSubrect, outputSubrect, Paint());
    }

    var path = Path();
    var isStarted = false;
    ScratchPoint? previousPoint;

    for (final point in points) {
      if (point == null) {
        if (previousPoint != null) {
          canvas.drawPath(path, _getMainPaint(previousPoint.size));
        }

        path = Path();
        isStarted = false;
      } else {
        final position = point.position;
        if (!isStarted) {
          isStarted = true;
          path.moveTo(position!.dx, position.dy);
        } else {
          path.lineTo(position!.dx, position.dy);
        }
      }

      previousPoint = point;
    }

    if (previousPoint != null) {
      canvas.drawPath(path, _getMainPaint(previousPoint.size));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}

/// NinjaScratcher widget which covers given child with scratchable overlay.
class NinjaScratcher extends StatefulWidget {
  NinjaScratcher({
    Key? key,
    required this.child,
    this.enabled = true,
    this.threshold,
    this.brushSize = 25,
    this.accuracy = ScratchAccuracy.high,
    this.color = Colors.black,
    this.image,
    this.rebuildOnResize = true,
    this.onChange,
    this.onThreshold,
    this.onScratchStart,
    this.onScratchUpdate,
    this.onScratchEnd,
  }) : super(key: key);

  /// Widget rendered under the scratch area.
  final Widget child;

  /// Whether new scratches can be applied
  final bool enabled;

  /// Percentage level of scratch area which should be revealed to complete.
  final double? threshold;

  /// Size of the brush. The bigger it is the faster user can scratch the card.
  final double brushSize;

  /// Determines how accurate the progress should be reported.
  /// Lower accuracy means higher performance.
  final ScratchAccuracy accuracy;

  /// Color used to cover the child widget.
  final Color color;

  /// Image widget used to cover the child widget.
  final Image? image;

  /// Determines if the scratcher should rebuild itself when space constraints change (resize).
  final bool rebuildOnResize;

  /// Callback called when new part of area is revealed (min 0.1% difference, or progress == 100).
  final Function(double value)? onChange;

  /// Callback called when threshold is reached.
  final VoidCallback? onThreshold;

  /// Callback called when scratching starts
  final VoidCallback? onScratchStart;

  /// Callback called during scratching
  final VoidCallback? onScratchUpdate;

  /// Callback called when scratching ends
  final VoidCallback? onScratchEnd;

  @override
  NinjaScratcherState createState() => NinjaScratcherState();
}

class NinjaScratcherState extends State<NinjaScratcher> {
  ui.Image? _resolvedImage;
  ImageProvider? _lastImageProvider;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  Offset? _lastPosition;
  List<ScratchPoint?> points = [];
  late Set<Offset> checkpoints;
  Set<Offset> checked = {};
  int totalCheckpoints = 0;
  double progress = 0;
  double progressReported = 0;
  bool thresholdReported = false;
  bool isFinished = false;
  bool canScratch = true;
  Duration? transitionDuration;
  Size? _lastKnownSize;

  // DEBUG
  final String _debugId = DateTime.now().millisecondsSinceEpoch.toString();



  @override
  void initState() {
    super.initState();
    NinjaLog.d('AppNinja', "NinjaScratcher [$_debugId]: initState()");
    _loadImage();
  }

  @override
  void didUpdateWidget(NinjaScratcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    NinjaLog.d('AppNinja', "NinjaScratcher [$_debugId]: dispose()");
    _cleanUpImageListener();
    super.dispose();
  }

  void _cleanUpImageListener() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  void _loadImage() {
    if (widget.image == null) {
      _cleanUpImageListener();
      _resolvedImage = null;
      _lastImageProvider = null;
      return;
    }

    final imageProvider = widget.image!.image;
    if (_lastImageProvider == imageProvider) {
      return;
    }

    _cleanUpImageListener();
    _lastImageProvider = imageProvider;

    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    _imageStream = stream;
    _imageStreamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (mounted) {
          setState(() {
            _resolvedImage = info.image;
          });
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        NinjaLog.d('AppNinja', 'NinjaScratcher: Error loading scratcher image: $exception');
      },
    );
    stream.addListener(_imageStreamListener!);
  }

  double _distanceSqToSegment(Offset p, Offset a, Offset b) {
    final abX = b.dx - a.dx;
    final abY = b.dy - a.dy;
    final apX = p.dx - a.dx;
    final apY = p.dy - a.dy;
    
    final abLenSq = abX * abX + abY * abY;
    if (abLenSq == 0) {
      return apX * apX + apY * apY;
    }
    
    final t = (apX * abX + apY * abY) / abLenSq;
    final clampedT = t.clamp(0.0, 1.0);
    
    final projX = a.dx + abX * clampedT;
    final projY = a.dy + abY * clampedT;
    
    final dx = p.dx - projX;
    final dy = p.dy - projY;
    
    return dx * dx + dy * dy;
  }

  bool isPointScratched(Offset localPosition) {
    if (isFinished) {
      NinjaLog.d('AppNinja', "isPointScratched: isFinished = true, returning true");
      return true;
    }
    final radius = widget.brushSize / 2;
    final radiusSq = radius * radius;
    bool matched = false;
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      if (point == null || point.position == null) continue;
      
      // 1. Check point itself
      final dx = point.position!.dx - localPosition.dx;
      final dy = point.position!.dy - localPosition.dy;
      if (dx * dx + dy * dy <= radiusSq) {
        matched = true;
        break;
      }
      
      // 2. Check segment to next point
      if (i < points.length - 1) {
        final nextPoint = points[i + 1];
        if (nextPoint != null && nextPoint.position != null) {
          if (_distanceSqToSegment(localPosition, point.position!, nextPoint.position!) <= radiusSq) {
            matched = true;
            break;
          }
        }
      }
    }
    NinjaLog.d('AppNinja', "isPointScratched: tap at $localPosition, points count: ${points.length}, brushSize: ${widget.brushSize}, matched: $matched");
    return matched;
  }

  @override
  Widget build(BuildContext context) {
    return ScratchHitTestRedirector(
      isPointScratched: isPointScratched,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: canScratch
            ? (details) {
                widget.onScratchStart?.call();
                if (widget.enabled) {
                  _addPoint(details.localPosition);
                }
              }
            : null,
        onPanUpdate: canScratch
            ? (details) {
                widget.onScratchUpdate?.call();
                if (widget.enabled) {
                  _addPoint(details.localPosition);
                }
              }
            : null,
        onPanEnd: canScratch
            ? (details) {
                widget.onScratchEnd?.call();
                if (widget.enabled) {
                  setState(() => points.add(null));
                }
              }
            : null,
        child: AnimatedSwitcher(
          duration: transitionDuration ?? Duration.zero,
          child: isFinished
              ? widget.child
              : CustomPaint(
                  foregroundPainter: ScratchPainter(
                    image: _resolvedImage,
                    imageFit: widget.image == null
                        ? null
                        : widget.image!.fit ?? BoxFit.cover,
                    points: points,
                    color: widget.color,
                    onDraw: (size) {
                      if (_lastKnownSize == null) {
                        _setCheckpoints(size);
                      } else if (_lastKnownSize != size &&
                          widget.rebuildOnResize) {
                        NinjaLog.d('AppNinja', "NinjaScratcher [$_debugId]: Calling reset() due to resize from $_lastKnownSize to $size");
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          reset();
                        });
                      }

                      _lastKnownSize = size;
                    },
                  ),
                  child: widget.child,
                ),
        ),
      ),
    );
  }


  bool _inCircle(Offset center, Offset point, double radius) {
    final dX = center.dx - point.dx;
    final dY = center.dy - point.dy;
    final multi = dX * dX + dY * dY;
    final distance = sqrt(multi).roundToDouble();

    return distance <= radius;
  }

  void _addPoint(Offset position) {
    if (_lastPosition == position) {
      return;
    }
    _lastPosition = position;

    ui.Offset? point = position;
    final scratchPoint = ScratchPoint(point, widget.brushSize);

    if (points.isNotEmpty && points.contains(scratchPoint)) {
      if (points.last == null) {
        return;
      } else {
        point = null;
      }
    }

    setState(() {
      points.add(scratchPoint);
    });

    if (point != null && !checked.contains(point)) {
      checked.add(point);

      final radius = widget.brushSize / 2;
      checkpoints.removeWhere(
        (checkpoint) => _inCircle(checkpoint, point!, radius),
      );

      progress =
          ((totalCheckpoints - checkpoints.length) / totalCheckpoints) * 100;
      if (progress - progressReported >= _progressReportStep ||
          progress == 100) {
        progressReported = progress;
        widget.onChange?.call(progress);
      }

      if (!thresholdReported &&
          widget.threshold != null &&
          progress >= widget.threshold!) {
        thresholdReported = true;
        widget.onThreshold?.call();
      }

      if (progress == 100) {
        isFinished = true;
      }
    }
  }

  void _setCheckpoints(Size size) {
    final calculated = _calculateCheckpoints(size).toSet();

    checkpoints = calculated;
    totalCheckpoints = calculated.length;
  }

  List<Offset> _calculateCheckpoints(Size size) {
    final accuracy = _getAccuracyValue(widget.accuracy);
    final xOffset = size.width / accuracy;
    final yOffset = size.height / accuracy;

    final points = <Offset>[];
    for (var x = 0; x < accuracy; x++) {
      for (var y = 0; y < accuracy; y++) {
        final point = Offset(
          x * xOffset,
          y * yOffset,
        );
        points.add(point);
      }
    }

    return points;
  }

  void reset({Duration? duration}) {
    NinjaLog.d('AppNinja', "NinjaScratcher [$_debugId]: reset() called. Clearing points!");
    setState(() {
      transitionDuration = duration;
      isFinished = false;
      canScratch = duration == null;
      thresholdReported = false;

      _lastPosition = null;
      points = [];
      checked = {};
      progress = 0;
      progressReported = 0;
    });

    if (duration != null) {
      Future.delayed(duration, () {
        setState(() {
          canScratch = true;
        });
      });
    }

    if (_lastKnownSize != null) {
      _setCheckpoints(_lastKnownSize!);
    } else {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        _setCheckpoints(renderBox.size);
      }
    }
    widget.onChange?.call(0);
  }

  void reveal({Duration? duration}) {
    setState(() {
      transitionDuration = duration;
      isFinished = true;
      canScratch = false;
      if (!thresholdReported && widget.threshold != null) {
        thresholdReported = true;
        widget.onThreshold?.call();
      }
    });

    widget.onChange?.call(100);
  }
}

class ScratchHitTestRedirector extends SingleChildRenderObjectWidget {
  final bool Function(Offset localPosition) isPointScratched;

  const ScratchHitTestRedirector({
    Key? key,
    required Widget child,
    required this.isPointScratched,
  }) : super(key: key, child: child);

  @override
  RenderScratchHitTestRedirector createRenderObject(BuildContext context) {
    return RenderScratchHitTestRedirector(isPointScratched: isPointScratched);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderScratchHitTestRedirector renderObject) {
    renderObject.isPointScratched = isPointScratched;
  }
}

class RenderScratchHitTestRedirector extends RenderProxyBox {
  bool Function(Offset localPosition) isPointScratched;

  RenderScratchHitTestRedirector({
    required this.isPointScratched,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final scratched = isPointScratched(position);
    NinjaLog.d('AppNinja', "RenderScratchHitTestRedirector.hitTest: position=$position, scratched=$scratched");
    if (scratched) {
      return false;
    }
    return super.hitTest(result, position: position);
  }
}
