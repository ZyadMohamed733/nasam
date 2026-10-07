import 'package:dio/dio.dart';

import '../../../../../core/errors/exception_mapper.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/interceptors/auth_interceptor.dart';
import '../../models/auth_session_model.dart';
import '../../models/forget_password_request_model.dart';
import '../../models/login_request_model.dart';
import '../../models/refresh_token_request_model.dart';
import '../../models/resend_otp_request_model.dart';
import '../../models/reset_password_request_model.dart';
import '../../models/verify_otp_request_model.dart';
import '../../models/verify_reset_otp_request_model.dart';

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

  /// [refreshToken] is nullable and, when null, sent with no body at all --
  /// `RefreshTokenDto.refreshToken` is optional on the wire, and there is
  /// nothing useful to send when the local session already has no token
  /// (e.g. a second logout call, or one after a failed refresh already
  /// cleared storage).
  Future<void> logout(String? refreshToken);

  // Password recovery. Sent without the session (see
  // AuthInterceptor.unauthenticated): the user is signed out, and a 401 here
  // must not trigger a token refresh.

  /// Emails [email] a six-digit reset code. Resending is the same call.
  Future<void> forgetPassword(String email);

  /// Exchanges the emailed code for a short-lived reset token. Throws a
  /// [ServerException] if the response carries no token.
  Future<String> verifyResetOtp({required String email, required String code});

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
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
        options: AuthInterceptor.unauthenticated(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/auth/verify-reset-otp',
        data: VerifyResetOtpRequestModel(email: email, code: code).toJson(),
        options: AuthInterceptor.unauthenticated(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
    // Documented as `{ message, resetToken }`, unlike the other auth
    // endpoints' `{ data: … }`; either shape is read, so the flow survives
    // the backend aligning this one. Without a token there is no next step,
    // so a 200 without one is an unexpected response, not a success.
    final body = response.data;
    final nested = body?['data'];
    final token =
        body?['resetToken'] ??
        (nested is Map<String, dynamic> ? nested['resetToken'] : null);
    if (token is! String || token.isEmpty) {
      throw const ServerException(
        message: 'The server did not return a reset token.',
        code: 'missing_reset_token',
      );
    }
    return token;
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
        options: AuthInterceptor.unauthenticated(),
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    }
  }
}
