import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// A box with the design's dashed 1px border (`539:13758`): 8 on, 8 off,
/// radius 8, the container-border colour, content inset 8 by 4.
class AppDashedBox extends StatelessWidget {
  const AppDashedBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const double dash = 8;
  static const double gap = 8;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(
      color: context.semanticColors.containerBorder,
      radius: AppSizes.r8,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // Inside the edge, like the design's inside stroke.
    final rect = (Offset.zero & size).deflate(.5);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final PathMetric metric in path.computeMetrics()) {
      for (
        var d = 0.0;
        d < metric.length;
        d += AppDashedBox.dash + AppDashedBox.gap
      ) {
        canvas.drawPath(metric.extractPath(d, d + AppDashedBox.dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
