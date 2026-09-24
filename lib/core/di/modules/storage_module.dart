import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/secure_storage_service.dart';

@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // first_unlock keeps tokens readable to background work after a reboot;
    // synchronizable: false keeps them off the user's iCloud Keychain, so a
    // session cannot follow them onto another device.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Resolved up front, so the reinstall check in [SecureStorageService.open]
  /// has finished before anything can ask for a token.
  @singleton
  @preResolve
  Future<SecureStorageService> secureStorageService(
    FlutterSecureStorage storage,
    SharedPreferences prefs,
  ) => SecureStorageService.open(storage, prefs);
}
