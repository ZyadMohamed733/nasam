import 'auth_session_entity.dart';

/// What `POST /auth/login` yields.
///
/// A 2FA-enabled account answers `200` with `{ requiresOtp: true }` and no
/// tokens -- that is a normal outcome of a correct password, not a failure,
/// so it must never be forced through `Left(Failure)`; [LoginRequiresOtp] is
/// a `Right` value exactly like [LoginSucceeded].
sealed class LoginResult {
  const LoginResult();
}

/// The account has 2FA enabled. Call `verifyOtp`/`resendOtp` with [username]
/// next -- the login attempt they belong to expires in 30 minutes.
class LoginRequiresOtp extends LoginResult {
  const LoginRequiresOtp(this.username);
  final String username;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequiresOtp &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}

/// Sign-in is complete. [session] has already been persisted by the
/// repository by the time this is returned.
class LoginSucceeded extends LoginResult {
  const LoginSucceeded(this.session);
  final AuthSessionEntity session;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginSucceeded &&
          runtimeType == other.runtimeType &&
          session == other.session;

  @override
  int get hashCode => session.hashCode;
}
