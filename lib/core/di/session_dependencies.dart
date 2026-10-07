import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../auth/auth_session_notifier.dart';
import '../auth/token_refresher.dart';
import '../errors/error_reporter.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import 'network_dependencies.dart';

void registerSessionDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AuthSessionNotifier>(
    () => AuthSessionNotifier(getIt<SecureStorageService>()),
  );
  getIt.registerLazySingleton<TokenRefresher>(
    () => TokenRefresher(
      getIt<SecureStorageService>(),
      getIt<AuthSessionNotifier>(),
      getIt<Dio>(instanceName: authlessDioName),
      getIt<ErrorReporter>(),
    ),
  );
  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(getIt<SecureStorageService>()),
  );
}
