import 'user_entity.dart';

/// What a completed sign-in (`login` without 2FA, `verify-otp`, or a
/// successful `refresh-access-token`) yields: tokens plus the profile that
/// came back alongside them.
///
/// Supersedes the old `AuthTokensEntity`, which carried only the two tokens
/// -- every one of these responses also returns `user`, and callers need it
/// at the same time they need the tokens (persisting both is one atomic
/// "sign-in happened" step in `AuthRepositoryImpl`).
///
/// Deliberately has no `toString` override beyond the default: these are
/// bearer credentials, and the logging interceptor already redacts them in
/// transit -- printing them here would defeat that.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;

  /// The refresh-access-token endpoint does not rotate this value -- a
  /// refresh reuses whichever token was already stored rather than
  /// receiving a new one back.
  final String refreshToken;
  final UserEntity user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSessionEntity &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          user == other.user;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, user);
}
