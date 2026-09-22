/// Wire shape for `PATCH /auth/reset-password`'s body (`ResetPasswordDto`).
class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
  });

  final String resetToken;
  final String newPassword;

  Map<String, dynamic> toJson() => {
    'resetToken': resetToken,
    'newPassword': newPassword,
  };
}
