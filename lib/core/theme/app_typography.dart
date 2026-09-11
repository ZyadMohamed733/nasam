import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The app's single type scale, expressed as a Material [TextTheme].
///
/// Read it as `Theme.of(context).textTheme.*` — never as static getters. Sizes
/// use `.sp`, so this must be built inside the `ScreenUtilInit` builder, which
/// is what the lazy `static final` fields on `AppTheme` guarantee.
abstract final class AppTypography {
  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16.sp, height: 1.5, color: onSurface),
      bodyMedium: TextStyle(fontSize: 14.sp, height: 1.45, color: onSurface),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        height: 1.4,
        color: onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11.sp,
        letterSpacing: 0.4,
        color: onSurfaceVariant,
      ),
    );
  }
}
