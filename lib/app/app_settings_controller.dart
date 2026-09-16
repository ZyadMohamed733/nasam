import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../core/services/storage_service.dart';

/// Holds the user's locale and theme choices and persists them.
///
/// Without this, `StorageService.getLocale()` had no caller and `MaterialApp`
/// hardcoded `ThemeMode.system` with no `locale:`, so an Arabic-speaking
/// operator on an English phone had no way to switch the app to Arabic.
@lazySingleton
class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._storage)
    : _locale = _parseLocale(_storage.getLocale()),
      _themeMode = _parseThemeMode(_storage.getThemeMode());

  final StorageService _storage;

  Locale? _locale;
  ThemeMode _themeMode;

  /// `null` means follow the device locale.
  Locale? get locale => _locale;

  ThemeMode get themeMode => _themeMode;

  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _storage.saveLocale(locale?.languageCode ?? _systemValue);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.saveThemeMode(mode.name);
  }

  static const String _systemValue = 'system';

  static Locale? _parseLocale(String? code) {
    if (code == null || code.isEmpty) return const Locale('ar');
    if (code == _systemValue) return null;
    return Locale(code);
  }

  static ThemeMode _parseThemeMode(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
