import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_tokens_entity.dart';

abstract class AuthRepository {
  /// Signs in and persists the tokens, so that `AuthService.isAuthenticated`
  /// — and therefore `RouteGuard` — sees the session immediately afterwards.
  Future<Either<Failure, AuthTokensEntity>> login({
    required String email,
    required String password,
  });

  /// Starts a reset by sending a one-time code to [email].
  Future<Either<Failure, Unit>> requestPasswordReset(String email);

  /// Exchanges a one-time code for the token that authorises the actual reset,
  /// so the new-password step never has to resend the code itself.
  Future<Either<Failure, String>> verifyResetCode({
    required String email,
    required String code,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
