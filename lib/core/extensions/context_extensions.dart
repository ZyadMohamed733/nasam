import 'package:flutter/material.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  /// The design tokens Material 3 has no [ColorScheme] role for — the button
  /// and icon states, the hover fills, the success/fail pair.
  ///
  /// Falls back to the token set for the ambient brightness rather than
  /// throwing, so a widget still renders under a bare `MaterialApp` that was
  /// built without `AppTheme` — a test harness, usually.
  AppSemanticColors get semanticColors =>
      theme.extension<AppSemanticColors>() ??
      (theme.brightness == Brightness.dark
          ? AppSemanticColors.dark
          : AppSemanticColors.light);
}
