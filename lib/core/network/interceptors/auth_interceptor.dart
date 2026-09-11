import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../constants/app_strings.dart';
import '../../services/secure_storage_service.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorageService);
  final SecureStorageService _secureStorageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[AppStrings.headerAuthorization] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Check if the error is 401 Unauthorized
    if (response != null && response.statusCode == 401) {
      // Avoid infinite retry loop
      if (err.requestOptions.extra['isRetry'] == true) {
        handler.next(err);
        return;
      }

      final refreshToken = await _secureStorageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Perform refresh using a separate Dio instance to avoid interceptor recursion
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              connectTimeout: err.requestOptions.connectTimeout,
              receiveTimeout: err.requestOptions.receiveTimeout,
            ),
          );

          final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data != null) {
            final data = refreshResponse.data!;
            final newAccessToken = data['accessToken'] as String?;
            final newRefreshToken = data['refreshToken'] as String?;

            if (newAccessToken != null) {
              await _secureStorageService.saveAccessToken(newAccessToken);
              if (newRefreshToken != null) {
                await _secureStorageService.saveRefreshToken(newRefreshToken);
              }

              // Retry original request with the new token
              final options = err.requestOptions;
              options.extra['isRetry'] = true;
              options.headers[AppStrings.headerAuthorization] =
                  'Bearer $newAccessToken';

              final retryResponse = await refreshDio.fetch<dynamic>(options);
              handler.resolve(retryResponse);
              return;
            }
          }
        } catch (_) {
          // Token refresh failed, clear credentials and bubble error up
          await _secureStorageService.clearAll();
        }
      } else {
        await _secureStorageService.clearAll();
      }
    }

    handler.next(err);
  }
}
