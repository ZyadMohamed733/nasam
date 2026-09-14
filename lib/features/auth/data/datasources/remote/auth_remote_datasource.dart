import 'package:injectable/injectable.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/auth_tokens_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset(String email);

  Future<String> verifyResetCode({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

/// Stands in for the auth API, which does not exist yet.
///
/// The slice above this is real — repository, usecases, cubits and screens are
/// all production code — so when the endpoints land, only this class is
/// replaced with a Dio implementation and nothing else changes. It is
/// registered as the `AuthRemoteDataSource` for now; swapping the binding is
/// the whole migration.
///
/// It answers predictably rather than randomly, so the error paths in the UI
/// can actually be walked through:
///
///  * any password but [_validPassword] fails sign-in
///  * [_unknownEmail] is not recognised for a reset
///  * any code but [_validCode] is rejected
///
/// Each call waits [_latency], because a form that never shows its loading
/// state is a form whose loading state has never been looked at.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  const AuthRemoteDataSourceMock();

  static const Duration _latency = Duration(milliseconds: 600);
  static const String _validPassword = 'Nasam@123';
  static const String _unknownEmail = 'unknown@nasam.sa';
  static const String _validCode = '123456';
  static const String _resetToken = 'mock-reset-token';

  @override
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    if (password != _validPassword) {
      throw const AuthException(
        message: 'Those credentials were not recognised.',
        code: '401',
      );
    }

    final issued = DateTime.now().millisecondsSinceEpoch;
    return AuthTokensModel(
      accessToken: 'mock_access_token_$issued',
      refreshToken: 'mock_refresh_token_$issued',
    );
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(_latency);

    if (email.trim().toLowerCase() == _unknownEmail) {
      throw const AuthException(
        message: 'No account uses that address.',
        code: '404',
      );
    }
  }

  @override
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(_latency);

    if (code != _validCode) {
      throw const AuthException(
        message: 'That code is not correct.',
        code: '400',
      );
    }
    return _resetToken;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await Future<void>.delayed(_latency);

    if (resetToken != _resetToken) {
      throw const AuthException(
        message: 'That reset link is no longer valid.',
        code: '400',
      );
    }
  }
}
