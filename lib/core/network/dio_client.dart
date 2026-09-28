import 'package:dio/dio.dart';

import '../../app/app_config.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/language_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// The injectable name of the client without the auth interceptor.
const String bareDioName = 'bareDio';

class DioClient {
  /// What every client talks to the API with: the flavor's host, the same
  /// timeouts, and the same headers. Shared so the refresh client cannot
  /// silently lose a header the main one has.
  static BaseOptions baseOptions(AppConfig config) => BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
    receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
    sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
    headers: {
      AppStrings.headerContentType: 'application/json',
      AppStrings.headerAccept: 'application/json',
      ...config.apiHeaders,
    },
  );

  static Dio create({
    required AppConfig config,
    required AuthInterceptor authInterceptor,
    required LanguageInterceptor languageInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    final dio = Dio(baseOptions(config));

    // In order: Auth -> Language -> Logging -> Error
    dio.interceptors.addAll([
      authInterceptor,
      languageInterceptor,
      loggingInterceptor,
      errorInterceptor,
    ]);

    return dio;
  }

  /// The same client without [AuthInterceptor], for the token refresh and
  /// the retry after it: going through the interceptor would recurse on the
  /// refresh endpoint's own 401. Created once and kept, not per refresh.
  static Dio bare({
    required AppConfig config,
    required LoggingInterceptor loggingInterceptor,
  }) => Dio(baseOptions(config))..interceptors.add(loggingInterceptor);
}
