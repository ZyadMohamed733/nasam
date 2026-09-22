import 'user_model.dart';

/// Wire shape of the `data` payload on a successful (non-2FA) login,
/// verify-otp, or refresh-access-token response.
///
/// `refreshToken` is nullable here even though [toEntity] always needs one:
/// the refresh-access-token endpoint's `data` doesn't include it at all
/// (the token isn't rotated), so `AuthRemoteDataSourceImpl.refreshAccessToken`
/// fills it back in from the token it sent, rather than this model pretending
/// the server returned one.
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
