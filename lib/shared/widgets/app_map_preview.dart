import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_outline_icon_button.dart';
import 'hit_target.dart';

/// A small, non-interactive map (`734:7683`, `553:4385`): rounded 8, the
/// design's pin with its halo over the centre, and a 40×40 full-screen button
/// 12 down and 7 in from the end.
///
/// [map] is drawn centred on the location; the pin marks that centre. Taps
/// on the map itself do nothing — the full-screen button is the way in.
class AppMapPreview extends StatelessWidget {
  const AppMapPreview({
    super.key,
    required this.map,
    required this.height,
    this.showPin = true,
    this.onFullscreen,
    this.fullscreenTooltip,
  });

  final Widget map;
  final double height;

  /// Off until there is a location to mark.
  final bool showPin;
  final VoidCallback? onFullscreen;
  final String? fullscreenTooltip;

  static const double buttonSize = 40;
  static const double buttonTop = 12;
  static const double buttonEnd = 7;

  /// Material's full-screen glyph fills about 14 of a 24 box: the design's
  /// bracket is about 15.
  static const double buttonIcon = 24;

  static const fullscreenKey = ValueKey('app-map-preview-fullscreen');

  @override
  Widget build(BuildContext context) {
    final tooltip = fullscreenTooltip;
    return HitTargetScope(
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r8),
          child: Stack(
            children: [
              Positioned.fill(child: IgnorePointer(child: map)),
              if (showPin)
                const Center(child: IgnorePointer(child: AppMapPin())),
              if (onFullscreen != null && tooltip != null)
                PositionedDirectional(
                  top: buttonTop,
                  end: buttonEnd,
                  child: HitTargetExtender(
                    child: AppOutlineIconButton(
                      key: fullscreenKey,
                      size: buttonSize,
                      tooltip: tooltip,
                      onPressed: onFullscreen,
                      icon: const Icon(Icons.fullscreen, size: buttonIcon),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The design's location pin: a filled pin in the action colour with a white
/// dot, its tip on the centre of two soft halo rings.
///
/// The design draws this into a map bitmap rather than as a vector, so it is
/// rebuilt here from the Material `location_on` glyph.
class AppMapPin extends StatelessWidget {
  const AppMapPin({super.key});

  /// The box the pin is centred in; its centre is the pin's tip.
  static const double size = 76;
  static const double pin = 36;
  static const double haloOuter = 20;
  static const double haloInner = 12;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size.square(size),
    painter: AppMapPinPainter(
      color: context.semanticColors.actionIcon,
      dot: context.semanticColors.containerBackground,
      halo: context.semanticColors.mapPinHalo,
    ),
  );
}

/// Paints [AppMapPin] on a canvas: in a widget, or into a map marker bitmap.
class AppMapPinPainter extends CustomPainter {
  const AppMapPinPainter({
    required this.color,
    required this.dot,
    required this.halo,
  });

  final Color color;
  final Color dot;
  final Color halo;

  @override
  void paint(Canvas canvas, Size size) {
    final tip = size.center(Offset.zero);
    canvas
      ..drawCircle(
        tip,
        AppMapPin.haloOuter,
        Paint()..color = halo.withValues(alpha: .2),
      )
      ..drawCircle(
        tip,
        AppMapPin.haloInner,
        Paint()..color = halo.withValues(alpha: .25),
      );
    // location_on is drawn in a 24 box: body x 5–19, tip at y 22, hole
    // centred at (12, 9) with radius 2.5.
    const scale = AppMapPin.pin / 24;
    final origin = tip - const Offset(12 * scale, 22 * scale);
    canvas.drawCircle(
      origin + const Offset(12 * scale, 9 * scale),
      3.5 * scale,
      Paint()..color = dot,
    );
    final glyph = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(Icons.location_on.codePoint),
        style: TextStyle(
          fontFamily: Icons.location_on.fontFamily,
          package: Icons.location_on.fontPackage,
          fontSize: AppMapPin.pin,
          height: 1,
          color: color,
        ),
      ),
    )..layout();
    glyph.paint(canvas, origin);
    glyph.dispose();
  }

  @override
  bool shouldRepaint(AppMapPinPainter old) =>
      old.color != color || old.dot != dot || old.halo != halo;
}
