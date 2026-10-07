import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';
import '../utils/app_logger.dart';

/// The session's credentials and profile, in the platform keychain.
///
/// Registered through storage dependencies with [open], not constructed directly:
/// [open] is what guarantees the reinstall check has run before anything can
/// read a token.
class SecureStorageService {
  @visibleForTesting
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  /// The keys this app's session lives under. Signing out clears exactly
  /// these — never `deleteAll()`, which would take anything else stored in
  /// the keychain with it.
  static const List<String> authKeys = [
    AppStrings.keyAccessToken,
    AppStrings.keyRefreshToken,
    AppStrings.keyUserData,
  ];

  /// Builds the service for the app: clears a previous install's session if
  /// this is the first launch, then loads the access token into memory.
  ///
  /// iOS keeps keychain items across an uninstall, so a reinstalled app
  /// would otherwise wake up signed in as whoever used it last — on a phone
  /// that may have changed hands. SharedPreferences does not survive an
  /// uninstall, which is what makes its flag a reliable "first launch".
  static Future<SecureStorageService> open(
    FlutterSecureStorage storage,
    SharedPreferences prefs,
  ) async {
    final service = SecureStorageService(storage);
    if (prefs.getBool(AppStrings.keyAuthStorageInitialised) != true) {
      try {
        await service.clearAuth();
        await prefs.setBool(AppStrings.keyAuthStorageInitialised, true);
      } catch (e, stack) {
        // Leave the flag unset so the next launch tries again, rather than
        // failing startup over a keychain that is momentarily unavailable.
        AppLogger.e(
          'Could not clear a previous install\'s session',
          error: e,
          stackTrace: stack,
        );
      }
    }
    try {
      await service.getAccessToken();
    } catch (_) {
      // Not cached; the first real read tries again.
    }
    return service;
  }

  // The access token is read on every request by the auth interceptor, and a
  // keychain read is a platform-channel round trip. It is held here instead:
  // read once, written through on save, dropped on delete. Only this class
  // writes the key, so the copy cannot go stale behind its back.
  String? _accessToken;
  bool _accessTokenLoaded = false;
  Future<String?>? _pendingAccessTokenRead;

  /// Whether an access token is held. Meaningful once [open] has run.
  bool get hasAccessToken => _accessToken?.isNotEmpty ?? false;

  int _sessionVersion = 0;

  /// Bumped by every [clearAuth]. Work that started under one session — a
  /// token refresh already in flight when the user signs out — compares this
  /// before writing, so it cannot bring the ended session back.
  int get sessionVersion => _sessionVersion;

  /// Called when a token turns up on a read after [open] could not read the
  /// keychain — the app started believing it was signed out, and was not.
  /// Set by `AuthSessionNotifier`; this class cannot depend on it, since the
  /// notifier is built from this one.
  VoidCallback? onAccessTokenDiscovered;

  Future<void> saveAccessToken(String token) async {
    final version = _sessionVersion;
    await _storage.write(key: AppStrings.keyAccessToken, value: token);
    // Cleared while the write was in flight: the clear's delete was issued
    // after this write, so the keychain is empty, and the cache must be too.
    if (version != _sessionVersion) return;
    _accessToken = token;
    _accessTokenLoaded = true;
  }

  Future<String?> getAccessToken() async {
    if (_accessTokenLoaded) return _accessToken;
    // Callers arriving together share one read. A failed read is not
    // remembered, so the next call tries the keychain again.
    final read = _pendingAccessTokenRead ??= _storage.read(
      key: AppStrings.keyAccessToken,
    );
    try {
      final value = await read;
      // A save or delete that landed while the read was in flight wins.
      if (!_accessTokenLoaded) {
        _accessToken = value;
        _accessTokenLoaded = true;
        if (hasAccessToken) onAccessTokenDiscovered?.call();
      }
      return _accessToken;
    } finally {
      if (identical(_pendingAccessTokenRead, read)) {
        _pendingAccessTokenRead = null;
      }
    }
  }

  Future<void> deleteAccessToken() async {
    _accessToken = null;
    _accessTokenLoaded = true;
    await _storage.delete(key: AppStrings.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppStrings.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppStrings.keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppStrings.keyRefreshToken);
  }

  // User profile (identity, roles, tenant, etc. from /auth/login and
  // /auth/verify-otp) -- stored as its raw JSON string alongside the
  // tokens, in secure storage rather than SharedPreferences, since it is
  // account data rather than a disposable UI cache.
  Future<void> saveUser(String json) async {
    await _storage.write(key: AppStrings.keyUserData, value: json);
  }

  Future<String?> getUser() async {
    return _storage.read(key: AppStrings.keyUserData);
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: AppStrings.keyUserData);
  }

  /// Ends the session locally: the tokens and the profile, nothing else.
  ///
  /// The cached token is dropped first, so even if a keychain delete fails
  /// the app stops sending the token straight away.
  Future<void> clearAuth() async {
    _sessionVersion++;
    _accessToken = null;
    _accessTokenLoaded = true;
    await Future.wait([for (final key in authKeys) _storage.delete(key: key)]);
  }
}
