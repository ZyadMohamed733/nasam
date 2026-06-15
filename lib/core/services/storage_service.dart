import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

@lazySingleton
class StorageService {
  const StorageService(this._prefs);
  final SharedPreferences _prefs;

  // Locale settings
  Future<void> saveLocale(String localeCode) async {
    await _prefs.setString(AppStrings.keyUserLocale, localeCode);
  }

  String? getLocale() {
    return _prefs.getString(AppStrings.keyUserLocale);
  }

  // Theme settings
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppStrings.keyThemeMode, themeMode);
  }

  String? getThemeMode() {
    return _prefs.getString(AppStrings.keyThemeMode);
  }

  // User data caching (non-sensitive layout caches, etc.)
  Future<void> saveUserData(String jsonString) async {
    await _prefs.setString(AppStrings.keyUserData, jsonString);
  }

  String? getUserData() {
    return _prefs.getString(AppStrings.keyUserData);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
