import 'package:dio/dio.dart';
import '../../app/app_config.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  static Dio create({
    required AppConfig config,
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeoutMs,
        ),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Tells the backend to deliver the refresh token in the response
          // body instead of an HttpOnly cookie -- native clients have no
          // cookie jar for the API host to write into.
          'X-Client': 'mobile',
          // Multi-tenancy: every request must be scoped to a tenant.
          'x-tenant': 'saudi-tracking',
        },
      ),
    );

    // Add interceptors in order: Auth -> Logging -> Error
    dio.interceptors.addAll([
      authInterceptor,
      loggingInterceptor,
      errorInterceptor,
    ]);

    return dio;
  }
}
