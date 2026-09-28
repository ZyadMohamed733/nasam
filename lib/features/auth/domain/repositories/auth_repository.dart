import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../entities/login_result.dart';
import '../entities/user_entity.dart';

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

  /// Ends the session. Clears the local session (tokens + user) whatever the
  /// network call does, including throwing something unexpected -- signing
  /// out is a local fact, and the server call is best-effort cleanup, not a
  /// precondition for it. The token refresh is not here: it belongs to
  /// `TokenRefresher` in core, the app's only refresh path.
  Future<Either<Failure, Unit>> logout();

  /// The signed-in user's profile as last stored at sign-in, or null when
  /// nobody is signed in. Local only: no network call.
  Future<Either<Failure, UserEntity?>> currentUser();

  /// Starts a password reset by emailing [email] a six-digit code. Also how
  /// the code is resent. An unknown address is a 404 from this backend.
  Future<Either<Failure, Unit>> forgetPassword(String email);

  /// Exchanges the emailed code for a temporary reset token. [code] is a
  /// string so leading zeros survive. The token is for this recovery only:
  /// callers keep it in memory and never persist or log it.
  Future<Either<Failure, String>> verifyResetOtp({
    required String email,
    required String code,
  });

  /// Sets a new password using the token from [verifyResetOtp]. Does not
  /// sign the user in.
  Future<Either<Failure, Unit>> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
