/// Wire shape for `POST /auth/resend-otp`'s body (`ResendOtpDto`).
class ResendOtpRequestModel {
  const ResendOtpRequestModel({required this.username});

  final String username;

  Map<String, dynamic> toJson() => {'username': username};
}
