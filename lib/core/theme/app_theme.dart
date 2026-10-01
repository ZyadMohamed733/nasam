import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_component_colors.dart';
import 'app_drawer_theme.dart';
import 'app_status_tones.dart';
import 'app_theme_data.dart';
import 'app_typography.dart';
import 'poi_sheet_colors.dart';
import 'tracking_colors.dart';

class AppTheme {
  /// Lazily built, so the first read happens inside the `ScreenUtilInit`
  /// builder where `.sp` is resolvable — and then only once, rather than
  /// constructing a new [ThemeData] on every `MaterialApp` rebuild.
  static final ThemeData light = _build(
    brightness: Brightness.light,
    semantic: AppSemanticColors.light,
    appBarTheme: AppThemeData.appBarTheme(AppSemanticColors.light),
    inputDecorationTheme: AppThemeData.inputDecorationTheme(
      AppSemanticColors.light,
    ),
    cardTheme: AppThemeData.cardTheme(AppSemanticColors.light),
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    semantic: AppSemanticColors.dark,
    appBarTheme: AppThemeData.appBarTheme(AppSemanticColors.dark),
    inputDecorationTheme: AppThemeData.inputDecorationTheme(
      AppSemanticColors.dark,
    ),
    cardTheme: AppThemeData.cardTheme(AppSemanticColors.dark),
  );

  /// Maps the design's semantic tokens onto the M3 roles. Only the roles that
  /// have a real token are set; anything absent from the design is left to
  /// Material's own derivation rather than invented here.
  static ColorScheme _scheme(Brightness brightness, AppSemanticColors s) {
    final base = brightness == Brightness.light
        ? const ColorScheme.light()
        : const ColorScheme.dark();
    return base.copyWith(
      primary: s.primary,
      onPrimary: s.primaryButtonText,
      primaryContainer: brightness == Brightness.light
          ? AppColors.bluePurple50
          : AppColors.bluePurple700,
      onPrimaryContainer: brightness == Brightness.light
          ? AppColors.bluePurple700
          : AppColors.bluePurple50,
      secondary: s.secondary,
      onSecondary: AppColors.neutralWhite,
      secondaryContainer: brightness == Brightness.light
          ? AppColors.purple100
          : AppColors.purple800,
      onSecondaryContainer: brightness == Brightness.light
          ? AppColors.purple800
          : AppColors.purple100,
      surface: s.containerBackground,
      onSurface: s.textColor,
      onSurfaceVariant: s.textPlaceholder,
      // Elevation levels have to be distinguishable: lowest is the page it
      // sits on, highest is a raised container. In light mode the design gives
      // both tokens #FFFFFF, so these stay equal there by design, not by bug —
      // light-mode separation comes from `containerBorder`, not from fill.
      surfaceContainerLowest: s.pageBackground,
      surfaceContainerHighest: s.containerBackground,
      outline: s.containerBorder,
      outlineVariant: s.divider,
      error: s.failText,
      onError: AppColors.neutralWhite,
      errorContainer: s.failBackground,
      onErrorContainer: AppColors.red800,
      shadow: AppColors.transparentBlack20,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors semantic,
    required AppBarTheme appBarTheme,
    required InputDecorationTheme inputDecorationTheme,
    required CardThemeData cardTheme,
  }) {
    final colorScheme = _scheme(brightness, semantic);
    final textTheme = AppTypography.textTheme(
      colorScheme.onSurface,
      colorScheme.onSurfaceVariant,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // The design sets essentially all text in Almarai. Declared here rather
      // than per-style so anything Material draws for us — dialogs, pickers,
      // tooltips — picks it up too, instead of falling back to the platform
      // face and rendering Arabic in whatever the OS happens to ship.
      fontFamily: 'Almarai',
      colorScheme: colorScheme,
      // Carries the tokens M3 has no role for — button and icon states — so
      // widgets never have to import AppColors to get a themed colour.
      extensions: <ThemeExtension<dynamic>>[
        semantic,
        const AppDrawerTheme(),
        brightness == Brightness.dark
            ? TrackingColors.dark
            : TrackingColors.light,
        brightness == Brightness.dark
            ? PoiSheetColors.dark
            : PoiSheetColors.light,
        brightness == Brightness.dark
            ? AppStatusTones.dark
            : AppStatusTones.light,
        brightness == Brightness.dark
            ? AppComponentColors.dark
            : AppComponentColors.light,
      ],
      scaffoldBackgroundColor: semantic.pageBackground,
      textTheme: textTheme,
      appBarTheme: appBarTheme.copyWith(
        titleTextStyle: textTheme.headlineSmall,
      ),
      elevatedButtonTheme: AppThemeData.elevatedButtonTheme(
        semantic,
        textTheme,
      ),
      outlinedButtonTheme: AppThemeData.outlinedButtonTheme(
        semantic,
        textTheme,
      ),
      inputDecorationTheme: AppThemeData.applyText(
        inputDecorationTheme,
        textTheme,
        colorScheme.onSurfaceVariant,
      ),
      cardTheme: cardTheme,
      dividerTheme: DividerThemeData(color: semantic.divider),
      drawerTheme: DrawerThemeData(backgroundColor: semantic.pageBackground),
    );
  }
}
