import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The app's single type scale, expressed as a Material [TextTheme].
///
/// Read it as `Theme.of(context).textTheme.*` — never as static getters. Sizes
/// use `.sp`, so this must be built inside the `ScreenUtilInit` builder, which
/// is what the lazy `static final` fields on `AppTheme` guarantee.
///
/// Every size and weight below is measured from `Nasam _ Mobile.fig`; the
/// design's own style name is in the trailing comment so a screen can be
/// checked against the file. Line heights the design gives in pixels are
/// written as the division that produced the multiplier, so the source number
/// stays visible.
///
/// Two caveats carried from the design system:
///
///  * Almarai ships only 400 and 700. The design asks for semibold on three
///    heading styles; those map to 700, the nearest real weight, rather than
///    letting the engine synthesise a fake one.
///  * TODO(design): the design sets Body/Body L R and Body/Body S R in Lama
///    Sans, which is commercial and unlicensed here. Both are on Almarai
///    below — `bodyMedium` and `labelMedium`. If a licence is bought, add the
///    family to pubspec and give those two styles a `fontFamily`.
abstract final class AppTypography {
  /// The design's "semibold". See the class doc.
  static const FontWeight _semibold = FontWeight.w700;

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      // Headings.
      displayLarge: TextStyle(
        fontSize: 40.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ), // Heading/H3
      displayMedium: TextStyle(
        fontSize: 32.sp,
        fontWeight: _semibold,
        height: 1.3,
        color: onSurface,
      ), // Heading/H4
      displaySmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: _semibold,
        height: 1.3,
        color: onSurface,
      ), // Heading/H5
      headlineMedium: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ), // Heading/H6
      headlineSmall: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: onSurface,
      ), // Heading/H7
      titleMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: onSurface,
      ), // Heading/H8
      // Body.
      bodyLarge: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        height: 20 / 18,
        color: onSurface,
      ), // Body/Body XL B
      bodyMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 16,
        color: onSurface,
      ), // Body/Body L R — Lama Sans in the design
      bodySmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurfaceVariant,
      ), // Body/Body M R
      labelLarge: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 13,
        color: onSurface,
      ), // Body/Footnote
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 12,
        color: onSurface,
      ), // Body/Body S R — Lama Sans in the design
      labelSmall: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: onSurfaceVariant,
      ), // Body/Caption M
    );
  }
}
