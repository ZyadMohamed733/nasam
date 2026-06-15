import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../network/dio_client.dart';
import '../../network/interceptors/auth_interceptor.dart';
import '../../network/interceptors/error_interceptor.dart';
import '../../network/interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    ErrorInterceptor errorInterceptor,
  ) {
    return DioClient.create(
      authInterceptor: authInterceptor,
      loggingInterceptor: loggingInterceptor,
      errorInterceptor: errorInterceptor,
    );
  }
}
