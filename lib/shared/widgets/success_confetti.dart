import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative paper pieces, driven by the success screen's one-shot timeline.
class SuccessConfetti extends StatelessWidget {
  const SuccessConfetti({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(painter: _ConfettiPainter(animation)),
      ),
    ),
  );
}

class _Piece {
  _Piece(math.Random random)
    : x = random.nextDouble(),
      delay = random.nextDouble() * 1.25,
      speed = 0.38 + random.nextDouble() * 0.22,
      phase = random.nextDouble() * math.pi * 2,
      spin = (random.nextDouble() - 0.5) * 7,
      size = 3 + random.nextDouble() * 4,
      kind = random.nextInt(3),
      color = _colors[random.nextInt(_colors.length)];

  static const _colors = [
    Color(0xFF58C4AC),
    Color(0xFFF0BE4F),
    Color(0xFFF6A5AA),
    Color(0xFFA8DDD2),
  ];
  final double x, delay, speed, phase, spin, size;
  final int kind;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;
  static final _pieces = _createPieces();
  static List<_Piece> _createPieces() {
    final random = math.Random(917);
    return List.generate(155, (_) => _Piece(random));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = animation.value * 5 - 0.7;
    if (elapsed <= 0 || animation.value >= 1) return;
    final fade = ((4.3 - elapsed) / 0.6).clamp(0.0, 1.0);
    final scale = (size.width / 402).clamp(0.7, 1.5);
    final paint = Paint();
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (final piece in _pieces) {
      final age = elapsed - piece.delay;
      if (age < 0) continue;
      final y = (-0.08 + age * piece.speed) * size.height;
      if (y > size.height + 32) continue;
      final x =
          piece.x * size.width + math.sin(age * 2 + piece.phase) * 24 * scale;
      paint.color = piece.color.withValues(alpha: fade * 0.85);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.phase + age * piece.spin);
      final width = piece.size * scale;
      if (piece.kind == 0) {
        canvas.drawCircle(Offset.zero, width * 0.55, paint);
      } else {
        final flutter = 0.25 + 0.75 * math.cos(age * 4 + piece.phase).abs();
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: width * flutter,
            height: width * (piece.kind == 1 ? 3.1 : 1),
          ),
          paint,
        );
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
