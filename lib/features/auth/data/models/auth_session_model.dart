import 'user_model.dart';

/// Wire shape of the `data` payload on a successful (non-2FA) login or
/// verify-otp response. (The token refresh does not use it: that response is
/// read by `TokenRefresher` in core.)
///
/// `refreshToken` is nullable because the API only puts it in the body when
/// asked with `X-Client: mobile`; `AuthRepositoryImpl` falls back to the
/// stored one rather than this model pretending the server returned one.
class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String?,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );

  final String accessToken;
  final String? refreshToken;
  final UserModel user;
}
