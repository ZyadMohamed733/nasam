import 'package:dio/dio.dart';

import '../../auth/token_refresher.dart';
import '../../constants/app_strings.dart';
import '../../services/secure_storage_service.dart';

/// Attaches the access token and, on a 401, refreshes it once and retries.
///
/// Registered as a lazy singleton so every request shares one
/// [TokenRefresher]; the refresher is what keeps parallel 401s down to one
/// refresh. Deciding whether the session is over is the refresher's job, not
/// this class's.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage,
    this._refresher,
    this._retryClient,
  );

  final SecureStorageService _storage;
  final TokenRefresher _refresher;

  /// `RequestOptions.extra` key marking a request that must go out without
  /// the session: no bearer token, and a 401 is handed back as it is rather
  /// than refreshing. For endpoints used by someone who is signed out —
  /// password recovery — where a stale token must not be sent and a failed
  /// refresh must not end or expire anything. Use [unauthenticated].
  static const String skipAuthKey = 'skipAuth';

  /// Request options for an endpoint that does not take the session.
  static Options unauthenticated() => Options(extra: {skipAuthKey: true});

  static bool _skipsAuth(RequestOptions options) =>
      options.extra[skipAuthKey] == true;

  /// Replays the failed request. Without this interceptor, so a retry that
  /// 401s again is handed back rather than refreshed forever.
  final Dio _retryClient;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_skipsAuth(options)) {
      handler.next(options);
      return;
    }
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
        _skipsAuth(err.requestOptions) ||
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
