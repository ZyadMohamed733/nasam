import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display style
  static TextStyle get display => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        height: 1.2,
      );

  // Headings
  static TextStyle get h1 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        height: 1.25,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // Body text styles
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        height: 1.45,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Specific Use Styles
  static TextStyle get button => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
      );

  static TextStyle get label => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      );
}
