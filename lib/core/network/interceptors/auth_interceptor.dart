import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../constants/app_strings.dart';
import '../../services/secure_storage_service.dart';

/// Attaches the access token and refreshes it once on a 401.
///
/// Registered as a `@lazySingleton` — as a factory each request got its own
/// interceptor with no shared state, so a dashboard firing five parallel
/// requests against an expired token sent five concurrent refreshes. With
/// refresh-token rotation the first response invalidates the token the other
/// four are using, and the user is logged out mid-session.
@lazySingleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorageService);

  final SecureStorageService _secureStorageService;

  /// The single in-flight refresh. Concurrent 401s await this rather than
  /// starting their own.
  Completer<String?>? _inFlightRefresh;

  /// Swappable so tests can drive the refresh call without a real network.
  @visibleForTesting
  Dio Function(BaseOptions options)? refreshClientFactory;

  static const String _refreshPath = '/auth/refresh-access-token';

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
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra['isRetry'] == true) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshOnce(err.requestOptions);
    if (newAccessToken == null) {
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions;
      options.extra['isRetry'] = true;
      options.headers[AppStrings.headerAuthorization] =
          'Bearer $newAccessToken';
      handler.resolve(await _client(options).fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Coalesces concurrent refreshes onto one request.
  Future<String?> _refreshOnce(RequestOptions origin) {
    final inFlight = _inFlightRefresh;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _inFlightRefresh = completer;

    // The slot is cleared before the completer fires, so a 401 arriving after
    // this refresh settles starts a new one rather than reusing a stale result.
    unawaited(
      _performRefresh(origin)
          .then((token) {
            _inFlightRefresh = null;
            completer.complete(token);
          })
          .catchError((Object _) {
            _inFlightRefresh = null;
            completer.complete(null);
          }),
    );

    return completer.future;
  }

  Future<String?> _performRefresh(RequestOptions origin) async {
    final refreshToken = await _secureStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _secureStorageService.clearAll();
      return null;
    }

    try {
      final response = await _client(origin).post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );

      // The response is nested one level under `data`, same as every other
      // endpoint on this API ({ data: { accessToken, user } }) -- and there
      // is no `message` key on this one specifically. The refresh token is
      // not rotated, so the response carries no new one; the caller keeps
      // reusing the one already in secure storage.
      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      if (response.statusCode != 200 ||
          newAccessToken == null ||
          newAccessToken.isEmpty) {
        return null;
      }

      await _secureStorageService.saveAccessToken(newAccessToken);
      return newAccessToken;
    } on DioException catch (e) {
      // Only the refresh endpoint explicitly rejecting the token means the
      // session is gone. A timeout or a dropped connection is a network blip,
      // and wiping credentials for it logs the user out over nothing.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _secureStorageService.clearAll();
      }
      return null;
    }
  }

  Dio _client(RequestOptions origin) {
    // A separate Dio instance so the refresh call does not recurse through
    // this interceptor.
    final options = BaseOptions(
      baseUrl: origin.baseUrl,
      connectTimeout: origin.connectTimeout,
      receiveTimeout: origin.receiveTimeout,
      // Required on every call, refresh included -- a native request with
      // no Origin and no x-tenant header is answered 404, not 401, so a
      // missing header here would look like "refresh endpoint doesn't
      // exist" rather than an auth failure.
      headers: const {'x-tenant': 'saudi-tracking'},
    );
    final factory = refreshClientFactory;
    return factory == null ? Dio(options) : factory(options);
  }
}
