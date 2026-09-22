/// Wire shape for `POST /auth/refresh-access-token` and `POST /auth/logout`
/// bodies (`RefreshTokenDto`).
///
/// `refreshToken` is optional on the wire (a same-site web client relies on
/// the HttpOnly cookie instead), but this app is a native client with no
/// cookie jar, so it always sends one.
class RefreshTokenRequestModel {
  const RefreshTokenRequestModel({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
