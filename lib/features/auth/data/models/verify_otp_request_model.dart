/// Wire shape for `POST /auth/verify-otp`'s body (`VerifyOtpDto`).
class VerifyOtpRequestModel {
  const VerifyOtpRequestModel({required this.username, required this.code});

  final String username;
  final String code;

  Map<String, dynamic> toJson() => {'username': username, 'code': code};
}
