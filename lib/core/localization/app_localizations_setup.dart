import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';

class AppLocalizationsSetup {
  /// Arabic first, and deliberately so: it is the product's own language and
  /// the one the design is authored in. The order matters because Flutter
  /// falls back to the first entry when it cannot match the device.
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static Locale localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode) {
        return supportedLocale;
      }
    }
    // A device set to a language we do not carry lands on Arabic, not English.
    return supportedLocales.first;
  }
}
