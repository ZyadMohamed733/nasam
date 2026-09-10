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
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentLight,
      onSecondaryContainer: AppColors.textPrimaryLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      // The page background, as distinct from a card or app bar surface.
      surfaceContainerLowest: AppColors.backgroundLight,
      surfaceContainerHighest: AppColors.backgroundLight,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderLight,
      error: AppColors.error,
      onError: Colors.white,
      shadow: AppColors.shadow,
    ),
    scaffoldBackground: AppColors.backgroundLight,
    appBarTheme: AppThemeData.appBarThemeLight,
    inputDecorationTheme: AppThemeData.inputDecorationThemeLight,
    cardTheme: AppThemeData.cardThemeLight,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.accentLight,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.accent,
      onSecondaryContainer: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      surfaceContainerLowest: AppColors.backgroundDark,
      surfaceContainerHighest: AppColors.backgroundDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
      error: AppColors.error,
      onError: Colors.white,
      shadow: AppColors.shadow,
    ),
    scaffoldBackground: AppColors.backgroundDark,
    appBarTheme: AppThemeData.appBarThemeDark,
    inputDecorationTheme: AppThemeData.inputDecorationThemeDark,
    cardTheme: AppThemeData.cardThemeDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required AppBarTheme appBarTheme,
    required InputDecorationTheme inputDecorationTheme,
    required CardThemeData cardTheme,
  }) {
    final textTheme = AppTypography.textTheme(
      colorScheme.onSurface,
      colorScheme.onSurfaceVariant,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: appBarTheme.copyWith(titleTextStyle: textTheme.headlineSmall),
      elevatedButtonTheme: AppThemeData.elevatedButtonTheme(
        colorScheme,
        textTheme,
      ),
      outlinedButtonTheme: AppThemeData.outlinedButtonTheme(
        colorScheme,
        textTheme,
      ),
      inputDecorationTheme: AppThemeData.applyText(
        inputDecorationTheme,
        textTheme,
        colorScheme.onSurfaceVariant,
      ),
      cardTheme: cardTheme,
      dividerTheme: DividerThemeData(color: colorScheme.outline),
      drawerTheme: DrawerThemeData(backgroundColor: scaffoldBackground),
    );
  }
}
