import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../auth/token_refresher.dart';
import '../../constants/app_strings.dart';
import '../../services/secure_storage_service.dart';
import '../dio_client.dart';

/// Attaches the access token and, on a 401, refreshes it once and retries.
///
/// Registered as a `@lazySingleton` so every request shares one
/// [TokenRefresher]; the refresher is what keeps parallel 401s down to one
/// refresh. Deciding whether the session is over is the refresher's job, not
/// this class's.
@lazySingleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage,
    this._refresher,
    @Named(bareDioName) this._retryClient,
  );

  final SecureStorageService _storage;
  final TokenRefresher _refresher;

  /// Replays the failed request. Without this interceptor, so a retry that
  /// 401s again is handed back rather than refreshed forever.
  final Dio _retryClient;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Served from memory after the first read; see SecureStorageService.
    final token = await _storage.getAccessToken();
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
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra['isRetry'] == true) {
      handler.next(err);
      return;
    }

    // If the session ends while the refresh is out, the request belonged to
    // a session that is gone; replaying it would act for a signed-out user.
    final version = _storage.sessionVersion;
    final newAccessToken = await _refresher.refresh();
    if (newAccessToken == null || _storage.sessionVersion != version) {
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions;
      options.extra['isRetry'] = true;
      options.headers[AppStrings.headerAuthorization] =
          'Bearer $newAccessToken';
      handler.resolve(await _retryClient.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
