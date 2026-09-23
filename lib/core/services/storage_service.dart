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

  // Onboarding
  //
  // Deliberately in SharedPreferences rather than secure storage: it is not a
  // secret, and it must survive a logout — someone who signs out has still
  // seen the intro and should not be shown it again.
  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(AppStrings.keyOnboardingSeen, true);
  }

  bool get hasSeenOnboarding =>
      _prefs.getBool(AppStrings.keyOnboardingSeen) ?? false;

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
