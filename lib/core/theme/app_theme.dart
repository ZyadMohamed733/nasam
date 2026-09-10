import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_theme_data.dart';
import 'app_typography.dart';

class AppTheme {
  /// Lazily built, so the first read happens inside the `ScreenUtilInit`
  /// builder where `.sp` is resolvable — and then only once, rather than
  /// constructing a new [ThemeData] on every `MaterialApp` rebuild.
  static final ThemeData light = _build(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
    ),
    scaffoldBackground: AppColors.backgroundLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
    appBarTheme: AppThemeData.appBarThemeLight,
    inputDecorationTheme: AppThemeData.inputDecorationThemeLight,
    cardTheme: AppThemeData.cardThemeLight,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimaryDark,
    ),
    scaffoldBackground: AppColors.backgroundDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    appBarTheme: AppThemeData.appBarThemeDark,
    inputDecorationTheme: AppThemeData.inputDecorationThemeDark,
    cardTheme: AppThemeData.cardThemeDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color onSurfaceVariant,
    required AppBarTheme appBarTheme,
    required InputDecorationTheme inputDecorationTheme,
    required CardThemeData cardTheme,
  }) {
    final textTheme = AppTypography.textTheme(
      colorScheme.onSurface,
      onSurfaceVariant,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(onSurfaceVariant: onSurfaceVariant),
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: appBarTheme.copyWith(titleTextStyle: textTheme.headlineSmall),
      elevatedButtonTheme: AppThemeData.elevatedButtonTheme(
        colorScheme,
        textTheme,
      ),
      inputDecorationTheme: AppThemeData.applyText(
        inputDecorationTheme,
        textTheme,
        onSurfaceVariant,
      ),
      cardTheme: cardTheme,
    );
  }
}
