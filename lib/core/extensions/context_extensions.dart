import 'package:flutter/material.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // Translation helper function
  String tr(String key) {
    // Basic dynamic dictionary support if needed, otherwise fall back to string representations
    // or direct lookup if needed, but typical usage is context.l10n.<key>
    // For general keys, we can look up via a map or return standard string fallback.
    // Let's also check if we can do custom dictionary mapping.
    return key; 
  }

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}
