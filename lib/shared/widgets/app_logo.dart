import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

/// The three sizes the design draws the logo at.
enum AppLogoSize {
  /// 24 — inline, beside text.
  small(24.0),

  /// 48 — the auth screens.
  medium(48.0),

  /// 80 — a screen's focal mark.
  large(80.0);

  const AppLogoSize(this.value);

  final double value;
}

/// The Nasam mark, at one of the design's three sizes.
///
/// Drawn from `logo_mark.png`, not from `Vector.svg`. That file is an SVG only
/// by extension: Figma exported it as a 1MB base64 PNG inside a `<pattern>`
/// fill, and flutter_svg does not support pattern fills, so it renders as
/// nothing at all. Until a true vector export exists, the PNG is the asset
/// that actually draws.
///
/// The mark is multi-colour, so it is drawn as authored rather than tinted to
/// the theme — unlike the single-colour glyphs in `AppIcons`.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppLogoSize.medium, this.semanticsLabel});

  final AppLogoSize size;

  /// Defaults to null, which hides the mark from the accessibility tree — the
  /// right behaviour when it sits next to the app name. Pass a label on any
  /// screen where the logo is the only identification.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoMark,
      width: size.value,
      height: size.value,
      semanticLabel: semanticsLabel,
      excludeFromSemantics: semanticsLabel == null,
      fit: BoxFit.contain,
    );
  }
}
