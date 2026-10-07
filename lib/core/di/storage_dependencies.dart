import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';

Future<void> registerStorageDependencies(GetIt getIt) async {
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      // first_unlock keeps tokens readable to background work after a reboot;
      // synchronizable: false keeps them off the user's iCloud Keychain, so a
      // session cannot follow them onto another device.
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Resolve the reinstall check before any dependency can ask for a token.
  final secureStorageService = await SecureStorageService.open(
    getIt<FlutterSecureStorage>(),
    sharedPreferences,
  );
  getIt.registerSingleton<SecureStorageService>(secureStorageService);

  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SharedPreferences>()),
  );
}
