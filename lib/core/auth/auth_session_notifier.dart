import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../services/secure_storage_service.dart';

enum AuthSessionStatus {
  signedIn,

  /// Never signed in on this launch, or signed out on purpose.
  signedOut,

  /// Ended by the server: the refresh token was rejected. The user did not
  /// choose this, so the app says so and brings them back afterwards.
  expired,
}

/// The session as the app shell sees it, and the router's refresh signal.
///
/// GoRouter listens to this, so any change re-runs the route guard: an
/// expired session is sent to login from wherever it was, and a sign-in on
/// the login screen moves on without the screen navigating by hand.
///
/// It only reports; the credentials themselves are in [SecureStorageService],
/// which the guard still reads. This never says "signed in" on its own.
@lazySingleton
class AuthSessionNotifier extends ValueNotifier<AuthSessionStatus> {
  AuthSessionNotifier(SecureStorageService storage)
    : super(
        storage.hasAccessToken
            ? AuthSessionStatus.signedIn
            : AuthSessionStatus.signedOut,
      );

  bool _endedByUser = false;

  /// True after the user signed out on purpose, until they sign in again.
  /// The guard uses it to send them to a plain login, with no screen to
  /// return to — the next person to sign in may not be them.
  bool get endedByUser => _endedByUser;

  /// A session was persisted: login or OTP succeeded.
  void signIn() {
    _endedByUser = false;
    value = AuthSessionStatus.signedIn;
  }

  /// The user signed out.
  void signOut() {
    _endedByUser = true;
    value = AuthSessionStatus.signedOut;
  }

  /// The server ended the session. Only a live session can expire: a 401
  /// while already signed out is not news, and must not raise the notice.
  void expire() {
    if (value != AuthSessionStatus.signedIn) return;
    _endedByUser = false;
    value = AuthSessionStatus.expired;
  }

  /// The expiry has been shown to the user; it is not shown again.
  void acknowledgeExpiry() {
    if (value == AuthSessionStatus.expired) {
      value = AuthSessionStatus.signedOut;
    }
  }
}
