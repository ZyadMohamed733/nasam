import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class AppThemeData {
  static AppBarTheme get appBarThemeLight => const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      );

  static AppBarTheme get appBarThemeDark => const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      );

  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          textStyle: AppTextStyles.button,
        ),
      );

  static InputDecorationTheme get inputDecorationThemeLight => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
        ),
      );

  static InputDecorationTheme get inputDecorationThemeDark => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
        ),
      );

  static CardThemeData get cardThemeLight => CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          side: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      );

  static CardThemeData get cardThemeDark => CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          side: const BorderSide(color: AppColors.borderDark, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      );
}
