import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nasam splash — "pixel swap" reveal.
///
/// Direct port of the HTML/canvas controller. Zero dependencies: pure Flutter,
/// one [CustomPainter], one [AnimationController]. No Rive, no Lottie, no asset
/// beyond the emblem itself.
///
/// Layering matches the original stacking context:
///   background plate -> radial glow -> `next` screen -> dots -> emblem
///
/// ```dart
/// PixelSwapSplash(
///   next: const OnboardingPage(),
///   onCompleted: () => context.go('/onboarding'),
/// )
/// ```
///
/// Architectural note: this is presentation-only — no domain or data layer, no
/// Cubit. The animation owns no business state; a controller here would be
/// ceremony around a single [AnimationController]. Navigation is pushed out to
/// `onCompleted` so the widget stays reusable and the router stays in charge.

// -----------------------------------------------------------------------------
// Config
// -----------------------------------------------------------------------------

@immutable
class PixelSwapConfig {
  const PixelSwapConfig({
    this.background = const Color(0xFF1D0B3E),
    this.glow = const Color(0xFF9354C9),
    this.dotColors = const [
      Color(0xFFA020B0),
      Color(0xFF9354C9),
      Color(0xFF5B3BD6),
    ],
    this.reveal = const Duration(milliseconds: 1350),
    this.hold = const Duration(milliseconds: 550),
    this.swap = const Duration(milliseconds: 850),
    this.emblemHeight = 128,
    this.emblemAspect = 183 / 212,
    this.glowDiameter = 500,
    this.glowOpacity = 0.14,
    this.seed = 7,
  });

  /// The original HTML palette, if you want the sky/indigo look back.
  const PixelSwapConfig.sky()
    : background = const Color(0xFF0B0E14),
      glow = const Color(0xFF0EA5E9),
      dotColors = const [
        Color(0xFF38BDF8),
        Color(0xFF0EA5E9),
        Color(0xFF6366F1),
      ],
      reveal = const Duration(milliseconds: 1350),
      hold = const Duration(milliseconds: 550),
      swap = const Duration(milliseconds: 850),
      emblemHeight = 128,
      emblemAspect = 1,
      glowDiameter = 360,
      glowOpacity = 0.12,
      seed = 7;

  final Color background;
  final Color glow;

  /// Three-stop ramp applied across the grid diagonal.
  final List<Color> dotColors;

  final Duration reveal;
  final Duration hold;
  final Duration swap;

  /// Drawn height of the emblem in design pixels (design frame is 390 x 844).
  final double emblemHeight;

  /// Width / height of the emblem artwork **cropped to its alpha box**.
  /// The dot grid is derived from this — get it wrong and dots sit outside the
  /// mark. For the Nasam logo the crop is 183 x 212.
  final double emblemAspect;

  final double glowDiameter;
  final double glowOpacity;

  /// Fixed seed keeps every cold start identical. Pass `null` for fresh chaos.
  final int? seed;

  Duration get total => reveal + hold + swap;
}

// -----------------------------------------------------------------------------
// Silhouette
// -----------------------------------------------------------------------------

/// Hexagon ring, resampled from the alpha channel of the Nasam logo at
/// 14 rows x 12 columns. The column count is not arbitrary: it is
/// `round(rows * emblemAspect)`, which is what keeps the cells square and the
/// cloud the same shape as the artwork.
const List<List<int>> kNasamMatrix = [
  [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
  [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
  [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
  [1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
  [1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1],
  [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1],
  [1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1],
  [1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1],
  [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1],
  [1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1],
  [1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
  [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
  [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
];

// -----------------------------------------------------------------------------
// Easing (ported 1:1 from the canvas controller)
// -----------------------------------------------------------------------------

double _easeOutCubic(double x) {
  final u = 1 - x;
  return 1 - u * u * u;
}

double _easeOutBack(double x) {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  final u = x - 1;
  return 1 + c3 * u * u * u + c1 * u * u;
}

// -----------------------------------------------------------------------------
// Particle
// -----------------------------------------------------------------------------

@immutable
class _Particle {
  const _Particle({
    required this.start,
    required this.target,
    required this.exit,
    required this.size,
    required this.radius,
    required this.color,
    required this.delayMs,
  });

  final Offset start;
  final Offset target;
  final Offset exit;
  final double size;
  final double radius;
  final Color color;
  final double delayMs;
}

// -----------------------------------------------------------------------------
// Widget
// -----------------------------------------------------------------------------

class PixelSwapSplash extends StatefulWidget {
  const PixelSwapSplash({
    super.key,
    required this.emblem,
    this.next,
    this.onCompleted,
    this.config = const PixelSwapConfig(),
  });

  /// The crisp mark shown during the hold. Use an SVG (`SvgPicture.asset`) or a
  /// PNG exported at 3x — it is drawn at [PixelSwapConfig.emblemHeight] logical
  /// pixels, so a 128 px source will look soft on a modern phone.
  final Widget emblem;

  /// Optional destination screen. Fades and scales in underneath the scattering
  /// dots, exactly as the onboarding screen did in the original.
  final Widget? next;

  final VoidCallback? onCompleted;
  final PixelSwapConfig config;

  @override
  State<PixelSwapSplash> createState() => _PixelSwapSplashState();
}

class _PixelSwapSplashState extends State<PixelSwapSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completedFired = false;

  // Particles depend on the laid-out size, so they are memoised against it
  // rather than rebuilt every frame.
  Size? _builtFor;
  List<_Particle> _particles = const [];

  PixelSwapConfig get _cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cfg.total)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _fireCompleted();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting: land on the end state at once.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
      _fireCompleted();
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PixelSwapSplash old) {
    super.didUpdateWidget(old);
    if (old.config.total != _cfg.total) _controller.duration = _cfg.total;
    if (old.config != widget.config) {
      _builtFor = null; // force the particle cache to rebuild
    }
  }

  void _fireCompleted() {
    if (_completedFired) return;
    _completedFired = true;
    // Defer so callers can navigate without tearing down mid-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCompleted?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _revealMs => _cfg.reveal.inMilliseconds.toDouble();
  double get _holdMs => _cfg.hold.inMilliseconds.toDouble();
  double get _swapMs => _cfg.swap.inMilliseconds.toDouble();
  double get _totalMs => _cfg.total.inMilliseconds.toDouble();

  /// Layout derived from the emblem's drawn content box — never a square guess.
  _Geometry _geometry(Size size) {
    final s = size.width / 390.0;
    final emblemH = _cfg.emblemHeight * s;
    final emblemW = emblemH * _cfg.emblemAspect;
    final centre = Offset(size.width / 2, size.height / 2 - 20 * s);
    return _Geometry(
      scale: s,
      emblemSize: Size(emblemW, emblemH),
      centre: centre,
    );
  }

  List<_Particle> _buildParticles(Size size) {
    final g = _geometry(size);
    final s = g.scale;
    final rnd = math.Random(_cfg.seed);

    final rows = kNasamMatrix.length;
    final cols = kNasamMatrix.first.length;
    final cellW = g.emblemSize.width / cols;
    final cellH = g.emblemSize.height / rows;
    final dot = 0.75 * math.min(cellW, cellH);
    final left = g.centre.dx - g.emblemSize.width / 2;
    final top = g.centre.dy - g.emblemSize.height / 2;

    final out = <_Particle>[];

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (kNasamMatrix[r][c] != 1) continue;

        // Cell CENTRE, not corner. This is what keeps every dot inside the
        // silhouette it was sampled from.
        final target = Offset(
          left + (c + 0.5) * cellW,
          top + (r + 0.5) * cellH,
        );

        final angle = rnd.nextDouble() * math.pi * 2;
        final spawn = (140 + rnd.nextDouble() * 160) * s;
        final exitAngle = angle + (rnd.nextDouble() - 0.5) * 0.8;
        final exitDist = (240 + rnd.nextDouble() * 200) * s;

        final ratio = (r / rows + c / cols) / 2;
        final color = ratio < 0.4
            ? _cfg.dotColors[0]
            : (ratio < 0.75 ? _cfg.dotColors[1] : _cfg.dotColors[2]);

        // Normalised radial distance -> wave-like stagger.
        final dist =
            math.sqrt(
              math.pow((c + 0.5 - cols / 2) / cols, 2) +
                  math.pow((r + 0.5 - rows / 2) / rows, 2),
            ) *
            2;

        out.add(
          _Particle(
            start: target + Offset(math.cos(angle), math.sin(angle)) * spawn,
            target: target,
            exit:
                target +
                Offset(math.cos(exitAngle), math.sin(exitAngle)) * exitDist,
            size: dot,
            radius: 1.5 * s,
            color: color,
            delayMs: math.min(1.0, dist) * 320 + rnd.nextDouble() * 140,
          ),
        );
      }
    }

    // Wordmark micro-pixels under the mark.
    final wmWidth = 110 * s;
    final wmLeft = (size.width - wmWidth) / 2;
    final wmY = top + g.emblemSize.height + 24 * s;
    var idx = 0;
    for (var c = 0; c < 16; c++) {
      if (c % 3 == 0) continue;
      final target = Offset(wmLeft + c * (wmWidth / 16), wmY);
      final angle = rnd.nextDouble() * math.pi * 2;
      final d = (100 + rnd.nextDouble() * 80) * s;
      final dir = Offset(math.cos(angle), math.sin(angle));
      out.add(
        _Particle(
          start: target + dir * d,
          target: target,
          exit: target + dir * (d * 2.2),
          size: 3.5 * s,
          radius: 1.0 * s,
          color: _cfg.dotColors[1],
          delayMs: 240 + idx * 25,
        ),
      );
      idx++;
    }

    return out;
  }

  /// Emblem opacity/scale, matching the CSS transitions on `#logo-wrapper`.
  ({double opacity, double scale}) _emblemState(double ms) {
    if (ms < _revealMs) return (opacity: 0, scale: 0.96);
    if (ms < _revealMs + _holdMs) {
      final t = ((ms - _revealMs) / 350).clamp(0.0, 1.0);
      final e = Curves.easeOutExpo.transform(t);
      return (opacity: e, scale: 0.96 + 0.04 * e);
    }
    final t = ((ms - _revealMs - _holdMs) / _swapMs).clamp(0.0, 1.0);
    return (opacity: math.max(0.0, 1 - t * 3.5), scale: 1 + t * 0.08);
  }

  /// `next` fades in once the dots start scattering (HTML: progress > 0.15).
  ({double opacity, double scale}) _nextState(double ms) {
    final start = _revealMs + _holdMs + _swapMs * 0.15;
    if (ms <= start) return (opacity: 0, scale: 0.96);
    final t = ((ms - start) / (_totalMs - start)).clamp(0.0, 1.0);
    final e = Curves.easeOutExpo.transform(t);
    return (opacity: e, scale: 0.96 + 0.04 * e);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _cfg.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_builtFor != size) {
            _particles = _buildParticles(size);
            _builtFor = size;
          }
          final g = _geometry(size);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final ms = _controller.value * _totalMs;
              final emblem = _emblemState(ms);
              final next = _nextState(ms);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Halo — static, painted once behind everything.
                  Center(
                    child: Transform.translate(
                      offset: Offset(0, g.centre.dy - size.height / 2),
                      child: _Glow(config: _cfg, scale: g.scale),
                    ),
                  ),

                  if (widget.next != null && next.opacity > 0)
                    Opacity(
                      opacity: next.opacity,
                      child: Transform.scale(
                        scale: next.scale,
                        child: widget.next,
                      ),
                    ),

                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _PixelSwapPainter(
                        particles: _particles,
                        elapsedMs: ms,
                        revealMs: _revealMs,
                        holdMs: _holdMs,
                        swapMs: _swapMs,
                      ),
                    ),
                  ),

                  if (emblem.opacity > 0)
                    Center(
                      child: Transform.translate(
                        offset: Offset(0, g.centre.dy - size.height / 2),
                        child: Transform.scale(
                          scale: emblem.scale,
                          child: Opacity(
                            opacity: emblem.opacity.clamp(0.0, 1.0),
                            child: SizedBox(
                              height: g.emblemSize.height,
                              width: g.emblemSize.width,
                              child: widget.emblem,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

@immutable
class _Geometry {
  const _Geometry({
    required this.scale,
    required this.emblemSize,
    required this.centre,
  });

  final double scale;
  final Size emblemSize;
  final Offset centre;
}

// -----------------------------------------------------------------------------
// Glow
// -----------------------------------------------------------------------------

/// Radial halo behind the mark. The stops are fitted to the reference render:
/// the ground peaks at ~14 % of [PixelSwapConfig.glow] over the background
/// directly behind the logo and reaches nothing by the edge. The extra stops
/// exist to kill the visible ring a two-stop falloff produces.
class _Glow extends StatelessWidget {
  const _Glow({required this.config, required this.scale});

  final PixelSwapConfig config;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final a = config.glowOpacity;
    final d = config.glowDiameter * scale;
    return IgnorePointer(
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            stops: const [0.0, 0.44, 0.59, 0.74, 0.88, 1.0],
            colors: [
              config.glow.withValues(alpha: a),
              config.glow.withValues(alpha: a * 0.79),
              config.glow.withValues(alpha: a * 0.61),
              config.glow.withValues(alpha: a * 0.30),
              config.glow.withValues(alpha: a * 0.10),
              config.glow.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Painter
// -----------------------------------------------------------------------------

class _PixelSwapPainter extends CustomPainter {
  _PixelSwapPainter({
    required this.particles,
    required this.elapsedMs,
    required this.revealMs,
    required this.holdMs,
    required this.swapMs,
  });

  final List<_Particle> particles;
  final double elapsedMs;
  final double revealMs;
  final double holdMs;
  final double swapMs;

  // Reused across every dot — allocating a Paint per particle per frame is the
  // classic way to make a 60 fps painter drop frames.
  final Paint _paint = Paint()..isAntiAlias = true;
  final Paint _sheen = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    if (elapsedMs < revealMs) {
      _paintReveal(canvas);
    } else if (elapsedMs < revealMs + holdMs) {
      _paintHold(canvas);
    } else {
      _paintSwap(canvas);
    }
  }

  void _paintReveal(Canvas canvas) {
    for (final p in particles) {
      final effective = math.max(0.0, elapsedMs - p.delayMs);
      final duration = math.max(revealMs - p.delayMs, 1.0);
      final progress = math.min(1.0, effective / duration);
      final e = _easeOutCubic(progress);

      _drawDot(
        canvas,
        Offset.lerp(p.start, p.target, e)!,
        p.size,
        p.radius,
        p.color,
        math.min(1.0, e * 1.4),
      );
    }
  }

  void _paintHold(Canvas canvas) {
    // Dimmed so the crisp emblem on top carries the frame.
    for (final p in particles) {
      _drawDot(canvas, p.target, p.size, p.radius, p.color, 0.25);
    }
  }

  void _paintSwap(Canvas canvas) {
    final t = math.min(1.0, (elapsedMs - revealMs - holdMs) / swapMs);
    final e = _easeOutBack(math.min(1.0, t * 1.1));
    final alpha = math.max(0.0, 1 - math.pow(t, 1.8).toDouble());

    for (final p in particles) {
      _drawDot(
        canvas,
        Offset.lerp(p.target, p.exit, e)!,
        math.max(1.0, p.size * (1 - t * 0.45)),
        p.radius,
        p.color,
        alpha,
      );
    }
  }

  void _drawDot(
    Canvas canvas,
    Offset c,
    double size,
    double radius,
    Color color,
    double alpha,
  ) {
    if (alpha <= 0) return;
    final a = alpha.clamp(0.0, 1.0);

    _paint.color = color.withValues(alpha: a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: size, height: size),
        Radius.circular(radius),
      ),
      _paint,
    );

    // Bright core for the technological sheen, same threshold as the canvas.
    if (a > 0.7) {
      _sheen.color = Colors.white.withValues(alpha: a * 0.25);
      canvas.drawRect(
        Rect.fromCenter(center: c, width: size * 0.4, height: size * 0.4),
        _sheen,
      );
    }
  }

  @override
  bool shouldRepaint(_PixelSwapPainter old) =>
      old.elapsedMs != elapsedMs || !identical(old.particles, particles);
}
