import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../app/app_config.dart';
import '../../app/app_settings_controller.dart';
import '../auth/token_refresher.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/language_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../services/secure_storage_service.dart';

const String authlessDioName = 'authlessDio';

void registerNetworkDependencies(GetIt getIt) {
  getIt.registerFactory<ErrorInterceptor>(() => ErrorInterceptor());
  getIt.registerFactory<LoggingInterceptor>(() => LoggingInterceptor());
  getIt.registerLazySingleton<LanguageInterceptor>(
    () => LanguageInterceptor(getIt<AppSettingsController>()),
  );
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      getIt<SecureStorageService>(),
      getIt<TokenRefresher>(),
      getIt<Dio>(instanceName: authlessDioName),
    ),
  );

  getIt.registerLazySingleton<Dio>(
    () => DioClient.bare(
      config: getIt<AppConfig>(),
      loggingInterceptor: getIt<LoggingInterceptor>(),
    ),
    instanceName: authlessDioName,
  );
  getIt.registerLazySingleton<Dio>(
    () => DioClient.create(
      config: getIt<AppConfig>(),
      authInterceptor: getIt<AuthInterceptor>(),
      languageInterceptor: getIt<LanguageInterceptor>(),
      loggingInterceptor: getIt<LoggingInterceptor>(),
      errorInterceptor: getIt<ErrorInterceptor>(),
    ),
  );
}
