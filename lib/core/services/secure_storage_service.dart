import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_strings.dart';

@lazySingleton
class SecureStorageService {
  const SecureStorageService(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppStrings.keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppStrings.keyAccessToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppStrings.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppStrings.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppStrings.keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppStrings.keyRefreshToken);
  }

  // User profile (identity, roles, tenant, etc. from /auth/login and
  // /auth/verify-otp) -- stored as its raw JSON string alongside the
  // tokens, in secure storage rather than SharedPreferences, since it is
  // account data rather than a disposable UI cache.
  Future<void> saveUser(String json) async {
    await _storage.write(key: AppStrings.keyUserData, value: json);
  }

  Future<String?> getUser() async {
    return _storage.read(key: AppStrings.keyUserData);
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: AppStrings.keyUserData);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
