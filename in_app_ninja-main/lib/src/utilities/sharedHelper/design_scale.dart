import 'package:flutter/material.dart';

/// Dashboard / TSX layout baseline (iPhone 14 Pro logical canvas).
const double kNinjaDesignWidth = 393.0;
const double kNinjaDesignHeight = 852.0;

/// Responsive scale from the physical view size (ignores keyboard insets).
///
/// Matches floater / modal parity in the campaign renderer.
class DesignScale {
  const DesignScale({required this.scaleX, required this.scaleY});

  final double scaleX;
  final double scaleY;

  static DesignScale fromContext(BuildContext context) {
    final view = View.of(context);
    final w = view.physicalSize.width / view.devicePixelRatio;
    final h = view.physicalSize.height / view.devicePixelRatio;
    return DesignScale(
      scaleX: w / kNinjaDesignWidth,
      scaleY: h / kNinjaDesignHeight,
    );
  }
}
