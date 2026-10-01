import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// A box with a dashed 1px border, drawn inside its edge.
///
/// Defaults are the POI form's location box (`539:13758`): 8 on, 8 off,
/// radius 8, the container-border colour, no fill, content inset 8 by 4. The
/// file drop zone (`561:5445`) sets its own.
class AppDashedBox extends StatelessWidget {
  const AppDashedBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.color,
    this.fill,
    this.dash = defaultDash,
    this.gap = defaultGap,
    this.radius = AppSizes.r8,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// The border. Defaults to the container-border token.
  final Color? color;

  /// Painted inside the border.
  final Color? fill;
  final double dash;
  final double gap;
  final double radius;

  static const double defaultDash = 8;
  static const double defaultGap = 8;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(
      color: color ?? context.semanticColors.containerBorder,
      fill: fill,
      radius: radius,
      dash: dash,
      gap: gap,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.fill,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final Color? fill;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = this.fill;
    if (fill != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        Paint()..color = fill,
      );
    }
    // Inside the edge, like the design's inside stroke.
    final rect = (Offset.zero & size).deflate(.5);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap;
}
