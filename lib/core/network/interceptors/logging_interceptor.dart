import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../utils/app_logger.dart';

@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Redact sensitive authorization headers for logging
    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = '[REDACTED]';
    }

    AppLogger.i('--> HTTP ${options.method} ${options.uri}');
    AppLogger.d('Headers: $headers');
    if (options.data != null) {
      AppLogger.d('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.i('<-- HTTP ${response.statusCode} ${response.requestOptions.uri}');
    if (response.data != null) {
      AppLogger.d('Response: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.w(
      '<-- HTTP ERROR: ${err.message}\n'
      'URL: ${err.requestOptions.uri}\n'
      'Status: ${err.response?.statusCode}\n'
      'Response: ${err.response?.data}',
    );
    handler.next(err);
  }
}
