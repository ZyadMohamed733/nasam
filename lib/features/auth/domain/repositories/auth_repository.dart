import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../entities/login_result.dart';

abstract class AuthRepository {
  /// Signs in. On [LoginSucceeded], the session (tokens + user) has already
  /// been persisted, so `AuthService.isAuthenticated` -- and therefore
  /// `RouteGuard` -- sees it immediately afterwards. On [LoginRequiresOtp],
  /// nothing is persisted yet; call [verifyOtp] to finish.
  Future<Either<Failure, LoginResult>> login({
    required String username,
    required String password,
  });

  /// Finishes a 2FA sign-in started by [login]. Persists the session on
  /// success, same as a non-2FA [login].
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String username,
    required String code,
  });

  /// Requests a fresh OTP for the login attempt in progress. Shares its
  /// rate limit with the code `login` itself sends -- a 429 here means
  /// `login`'s OTP budget is spent too.
  Future<Either<Failure, Unit>> resendOtp(String username);

  /// Exchanges the stored refresh token for a new access token, persisting
  /// both the new access token and the refreshed user profile on success.
  /// The refresh token itself is not rotated by the API, so the returned
  /// session reuses whichever one was already stored.
  Future<Either<Failure, AuthSessionEntity>> refreshAccessToken();

  /// Ends the session. Clears the local session (tokens + user) regardless
  /// of whether the network call succeeds -- signing out is a local fact,
  /// and the server call is best-effort cleanup, not a precondition for it.
  Future<Either<Failure, Unit>> logout();

  /// Starts a password reset by emailing [email] a reset link. Always
  /// succeeds with the same message whether or not the address has an
  /// account -- never signal existence either way.
  Future<Either<Failure, Unit>> forgetPassword(String email);

  /// Completes a reset using the token from the emailed link.
  Future<Either<Failure, Unit>> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
