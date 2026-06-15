import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  static Dio create({
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.nasam.app/v1';
    final connectTimeout = int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '15000') ?? 15000;
    final receiveTimeout = int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '30000') ?? 30000;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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
