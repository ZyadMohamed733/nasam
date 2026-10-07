import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors/error_reporter.dart';
import '../services/secure_storage_service.dart';
import 'auth_session_notifier.dart';

/// The app's one way of exchanging the refresh token for an access token.
///
/// The auth interceptor calls it on a 401. Nothing else refreshes — the
/// repository's separate refresh path and its use case were removed, so there
/// is one place that decides when a session is over.
///
/// It lives in core and takes no feature types: the interceptor is core, and
/// core must not reach into `features/auth`.
class TokenRefresher {
  TokenRefresher(
    this._storage,
    this._session,
    this._client,
    this._errors,
  );

  final SecureStorageService _storage;
  final AuthSessionNotifier _session;
  final ErrorReporter _errors;

  /// Long-lived and without the auth interceptor, so the refresh call cannot
  /// recurse into it.
  final Dio _client;

  static const String refreshPath = '/auth/refresh-access-token';

  /// Answers from the refresh endpoint that mean the refresh token itself is
  /// no good: rejected (401/403), or not something the server will accept
  /// (400/422). Anything else — a timeout, no connection, a 5xx — says
  /// nothing about the token, and ending the session over it would sign the
  /// user out for a network blip.
  static const Set<int> _rejections = {400, 401, 403, 422};

  /// The single in-flight refresh. Concurrent 401s await this rather than
  /// starting their own: with refresh-token rotation, the first response
  /// would invalidate the token the others were using.
  Completer<String?>? _inFlight;

  /// A new access token, or null if there is none to be had.
  Future<String?> refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _inFlight = completer;

    // The slot is cleared before the completer fires, so a 401 arriving after
    // this refresh settles starts a new one rather than reusing a stale result.
    unawaited(
      _perform()
          .then((token) {
            _inFlight = null;
            completer.complete(token);
          })
          .catchError((Object _) {
            _inFlight = null;
            completer.complete(null);
          }),
    );

    return completer.future;
  }

  Future<String?> _perform() async {
    // The session this refresh belongs to. If it ends while the request is
    // out — the user signs out — the answer is for a session that no longer
    // exists, and writing it would sign them back in.
    final version = _storage.sessionVersion;
    bool sessionEnded() => _storage.sessionVersion != version;

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _endSession();
      return null;
    }

    try {
      final response = await _client.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refreshToken': refreshToken},
      );

      // Nested under `data` like every endpoint on this API:
      // { data: { accessToken, user } }. The refresh token is not rotated,
      // so there is no new one to store.
      if (sessionEnded()) return null;

      final data = response.data?['data'];
      final accessToken = data is Map<String, dynamic>
          ? data['accessToken']
          : null;
      if (accessToken is! String || accessToken.isEmpty) {
        // A 200 without a token is the server's fault, not the user's: the
        // refresh token may be perfectly good. Report it and leave the
        // session alone; the request that 401'd fails as it would have.
        _errors.report(
          const ApiContractViolation(
            refreshPath,
            '200 response without data.accessToken',
          ),
          StackTrace.current,
          source: ErrorSource.contract,
        );
        return null;
      }

      await _storage.saveAccessToken(accessToken);
      final user = (data as Map<String, dynamic>)['user'];
      if (user is Map<String, dynamic> && !sessionEnded()) {
        await _storage.saveUser(jsonEncode(user));
      }
      return sessionEnded() ? null : accessToken;
    } on DioException catch (e) {
      if (!sessionEnded() && _rejections.contains(e.response?.statusCode)) {
        await _endSession();
      }
      return null;
    }
  }

  Future<void> _endSession() async {
    try {
      await _storage.clearAuth();
    } finally {
      _session.expire();
    }
  }
}
