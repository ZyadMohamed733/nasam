import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/app_config.dart';
import '../../network/dio_client.dart';
import '../../network/interceptors/auth_interceptor.dart';
import '../../network/interceptors/error_interceptor.dart';
import '../../network/interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AppConfig config,
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    ErrorInterceptor errorInterceptor,
  ) {
    return DioClient.create(
      config: config,
      authInterceptor: authInterceptor,
      loggingInterceptor: loggingInterceptor,
      errorInterceptor: errorInterceptor,
    );
  }

  @Named(bareDioName)
  @lazySingleton
  Dio bareDio(AppConfig config, LoggingInterceptor loggingInterceptor) =>
      DioClient.bare(config: config, loggingInterceptor: loggingInterceptor);
}
