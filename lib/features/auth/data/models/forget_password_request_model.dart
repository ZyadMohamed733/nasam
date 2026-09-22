/// Wire shape for `POST /auth/forget-password`'s body (`ForgetPasswordDto`).
class ForgetPasswordRequestModel {
  const ForgetPasswordRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}
