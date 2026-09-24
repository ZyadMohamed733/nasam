/// Wire shape for `POST /auth/login`'s body (`LoginDto`).
class LoginRequestModel {
  const LoginRequestModel({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}
