import 'package:flutter/material.dart';

/// Every icon the app draws, in one place.
///
/// ## These are placeholders
///
/// The design uses the Solar icon set. Those glyphs are not exported yet, so
/// each entry below is the nearest Material icon — close enough in weight and
/// shape to build and review screens against, but not the design's geometry.
///
/// Swapping to the real thing is meant to be one edit per icon, here, and
/// nothing at the call sites. When the SVGs land:
///
///  1. Export from Figma at 24x24, single colour, no embedded fills — an
///     embedded fill defeats the `ColorFilter` tint and the icon stops
///     following the theme.
///  2. Save as `assets/icons/<snake_case name>.svg`, matching the design's
///     component name. Add the style as a suffix only where a flow uses more
///     than one style of the same icon: `user.svg`, `menu.svg`,
///     `user_bold.svg`.
///  3. Register the path in `AppAssets` and add it to `AppAssets.all`, so the
///     asset test fails if the file is missing.
///  4. Replace the `IconData` here with the path and switch call sites from
///     `Icon` to `SvgPicture.asset`.
///
/// Sizes come from [AppIconSize]; call sites should not pass raw numbers.
abstract final class AppIcons {
  /// Solar / User / Bold. Placeholder: filled, matching Bold's weight.
  static const IconData user = Icons.person_rounded;

  /// Solar / Hamburger Menu / Outline.
  static const IconData menu = Icons.menu_rounded;

  /// "Onward" — the arrow the onboarding and auth buttons carry.
  ///
  /// A plain constant, and it must stay one: `arrow_forward_rounded` is
  /// declared with `matchTextDirection: true`, so Flutter already mirrors it
  /// under RTL and it points left in Arabic on its own. Picking
  /// `arrow_back_rounded` for RTL instead flips an already-flipped glyph and
  /// lands back where it started, pointing the wrong way.
  static const IconData forward = Icons.arrow_forward_rounded;
}

/// The two sizes the design draws icons at: 16 inline beside text, 24
/// standalone. Exposed as an enum so call sites cannot invent a third.
enum AppIconSize {
  /// 16 — inline, beside a label.
  small(16.0),

  /// 24 — standalone.
  medium(24.0);

  const AppIconSize(this.value);

  final double value;
}
