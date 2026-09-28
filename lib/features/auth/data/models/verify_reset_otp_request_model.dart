/// Wire shape for `POST /auth/verify-reset-otp`'s body.
///
/// [code] is a string on purpose: a code such as `012345` is six characters,
/// and a number would lose its leading zero.
class VerifyResetOtpRequestModel {
  const VerifyResetOtpRequestModel({required this.email, required this.code});

  final String email;
  final String code;

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}
