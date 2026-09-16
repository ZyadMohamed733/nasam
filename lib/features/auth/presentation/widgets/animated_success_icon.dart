import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

/// A single circular sweep that resolves into the supplied success artwork.
class AnimatedSuccessIcon extends StatefulWidget {
  const AnimatedSuccessIcon({super.key, this.size = 96});

  final double size;

  @override
  State<AnimatedSuccessIcon> createState() => _AnimatedSuccessIconState();
}

class _AnimatedSuccessIconState extends State<AnimatedSuccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            child: Image.asset(
              AppAssets.passwordResetSuccess,
              fit: BoxFit.contain,
            ),
            builder: (context, child) {
              final progress = _controller.value;
              final reveal = const Interval(
                0.55,
                1,
                curve: Curves.easeOutCubic,
              ).transform(progress);
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (reveal < 1)
                    CustomPaint(
                      painter: _SuccessRingPainter(progress, 1 - reveal),
                    ),
                  Opacity(
                    opacity: reveal,
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * reveal,
                      child: child,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SuccessRingPainter extends CustomPainter {
  const _SuccessRingPainter(this.progress, this.opacity);

  final double progress;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple500.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final sweep = Curves.easeInOutCubic.transform((progress / 0.7).clamp(0, 1));
    canvas.drawArc(
      (Offset.zero & size).deflate(4),
      -math.pi / 2 + sweep * 2 * math.pi,
      (0.08 + 0.92 * sweep) * 2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SuccessRingPainter oldDelegate) =>
      progress != oldDelegate.progress || opacity != oldDelegate.opacity;
}
