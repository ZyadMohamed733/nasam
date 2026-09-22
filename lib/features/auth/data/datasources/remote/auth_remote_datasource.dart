import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/exception_mapper.dart';
import '../../models/auth_session_model.dart';
import '../../models/forget_password_request_model.dart';
import '../../models/login_request_model.dart';
import '../../models/refresh_token_request_model.dart';
import '../../models/resend_otp_request_model.dart';
import '../../models/reset_password_request_model.dart';
import '../../models/user_model.dart';
import '../../models/verify_otp_request_model.dart';

/// What `POST /auth/login` answers when the account has 2FA enabled: `200`
/// with `{ requiresOtp: true }` and no tokens. [AuthRemoteDataSourceImpl.login]
/// returns null in this case rather than throwing -- it is not an error.
abstract class AuthRemoteDataSource {
  Future<AuthSessionModel?> login({
    required String username,
    required String password,
  });

  Future<AuthSessionModel> verifyOtp({
    required String username,
    required String code,
  });

  Future<void> resendOtp(String username);

  /// [refreshToken] is threaded back into the returned model by the caller
  /// (see [AuthRepositoryImpl.refreshAccessToken]) since the response
  /// itself does not carry one.
  Future<({String accessToken, UserModel user})> refreshAccessToken(
    String refreshToken,
  );

  /// [refreshToken] is nullable and, when null, sent with no body at all --
  /// `RefreshTokenDto.refreshToken` is optional on the wire, and there is
  /// nothing useful to send when the local session already has no token
  /// (e.g. a second logout call, or one after a failed refresh already
  /// cleared storage).
  Future<void> logout(String? refreshToken);

  Future<void> forgetPassword(String email);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthSessionModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: LoginRequestModel(
          username: username,
          password: password,
        ).toJson(),
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      if (data['requiresOtp'] == true) return null;

      return AuthSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String username,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/verify-otp',
        data: VerifyOtpRequestModel(username: username, code: code).toJson(),
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AuthSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<void> resendOtp(String username) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/resend-otp',
        data: ResendOtpRequestModel(username: username).toJson(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<({String accessToken, UserModel user})> refreshAccessToken(
    String refreshToken,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-access-token',
        data: RefreshTokenRequestModel(refreshToken: refreshToken).toJson(),
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return (
        accessToken: data['accessToken'] as String,
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<void> logout(String? refreshToken) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/logout',
        data: refreshToken == null
            ? const <String, dynamic>{}
            : RefreshTokenRequestModel(refreshToken: refreshToken).toJson(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<void> forgetPassword(String email) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/forget-password',
        data: ForgetPasswordRequestModel(email: email).toJson(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/auth/reset-password',
        data: ResetPasswordRequestModel(
          resetToken: resetToken,
          newPassword: newPassword,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }
}
