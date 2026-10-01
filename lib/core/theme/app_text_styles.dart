import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The design's text styles, named after the Figma text styles.
///
/// Size, weight and line height only: colour always comes from a semantic
/// token (`AppSemanticColors`), so a style reads the same in either theme.
/// Sizes are `.sp`, like `AppTypography`, so read these inside the
/// `ScreenUtilInit` builder — in a `build` method, not in a static field.
///
/// Use these for POI and every new screen. `AppTypography`'s Material
/// `TextTheme` stays for what Material draws itself.
abstract final class AppTextStyles {
  static const String _family = 'Almarai';

  /// Figma's "normal" (auto) line height for Almarai: its ascent plus
  /// descent, 12.276 at 11 and 11.16 at 10 in the design file.
  static const double normalLineHeight = 1.116;

  /// Every style is 0% in Figma. Set explicitly: left null, a style would
  /// inherit Material 3's spacing (0.25–0.5) from the ambient text style.
  static const double letterSpacing = 0;

  /// Figma "Body M B": Almarai Bold 14 on a 20 line.
  static TextStyle get bodyMB => TextStyle(
    fontFamily: _family,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.w700,
    fontSize: 14.sp,
    height: 20 / 14,
  );

  /// Figma "Body M R": Almarai Regular 14 on a 20 line.
  static TextStyle get bodyMR => TextStyle(
    fontFamily: _family,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
    height: 20 / 14,
  );

  /// Figma "Body S R": Regular 12 at 1.3. The design sets it in Lama Sans,
  /// which is unlicensed here; Almarai substitutes.
  static TextStyle get bodySR => TextStyle(
    fontFamily: _family,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
    height: 1.3,
  );

  /// Figma "Caption M": Almarai Regular 11 at the normal line height.
  static TextStyle get captionM => TextStyle(
    fontFamily: _family,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.w400,
    fontSize: 11.sp,
    height: normalLineHeight,
  );

  /// Figma "Caption S": Almarai Regular 10 at the normal line height.
  static TextStyle get captionS => TextStyle(
    fontFamily: _family,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.w400,
    fontSize: 10.sp,
    height: normalLineHeight,
  );
}
