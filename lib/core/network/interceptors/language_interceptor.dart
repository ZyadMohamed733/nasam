import 'dart:ui' show PlatformDispatcher;

import 'package:dio/dio.dart';

import '../../../app/app_settings_controller.dart';
import '../../constants/app_strings.dart';

/// Sends the app's current language as `x-lang`, so the backend's messages —
/// shown to the user as they are, such as "account not found" — arrive in
/// the language the screen is in.
///
/// Read per request, not once: the user can switch language at any time.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._settings);

  final AppSettingsController _settings;

  /// What the backend accepts. Anything else is sent as English.
  static const supported = {'en', 'ar'};

  /// The app's language: the user's choice, or the device's when they follow
  /// the system.
  String get language {
    final code =
        (_settings.locale ?? PlatformDispatcher.instance.locale).languageCode;
    return supported.contains(code) ? code : 'en';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[AppStrings.headerLanguage] = language;
    handler.next(options);
  }
}
