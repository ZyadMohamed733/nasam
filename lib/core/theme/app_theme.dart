import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_theme_data.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      appBarTheme: AppThemeData.appBarThemeLight,
      elevatedButtonTheme: AppThemeData.elevatedButtonTheme,
      inputDecorationTheme: AppThemeData.inputDecorationThemeLight,
      cardTheme: AppThemeData.cardThemeLight,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accentLight,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimaryDark,
      ),
      appBarTheme: AppThemeData.appBarThemeDark,
      elevatedButtonTheme: AppThemeData.elevatedButtonTheme,
      inputDecorationTheme: AppThemeData.inputDecorationThemeDark,
      cardTheme: AppThemeData.cardThemeDark,
    );
  }
}
