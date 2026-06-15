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
    return await _storage.read(key: AppStrings.keyAccessToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppStrings.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppStrings.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppStrings.keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppStrings.keyRefreshToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
