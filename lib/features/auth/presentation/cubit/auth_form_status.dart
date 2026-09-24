import '../../../../core/errors/failures.dart';

/// Where a submittable auth form is in its one round trip.
///
/// All four auth screens do the same thing — take some input, call one
/// usecase, then either move on or show why not — so they share one status
/// rather than each declaring its own idle/loading/failure trio.
///
/// States are values. Equality is by type, plus payload where there is one:
/// without it, two `AuthFormFailed`s carrying the same failure compared by
/// identity, so a test expecting the state it had just caused could never
/// match it — the payload-less states only appeared to work because `const`
/// constructors are canonicalised to one instance.
sealed class AuthFormStatus {
  const AuthFormStatus();

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthFormIdle extends AuthFormStatus {
  const AuthFormIdle();
}

class AuthFormSubmitting extends AuthFormStatus {
  const AuthFormSubmitting();
}

class AuthFormSucceeded extends AuthFormStatus {
  const AuthFormSucceeded();
}

class AuthFormFailed extends AuthFormStatus {
  const AuthFormFailed(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is AuthFormFailed && other.failure == failure;

  @override
  int get hashCode => Object.hash(AuthFormFailed, failure);
}

/// The account has 2FA enabled: `POST /auth/login` answered with
/// `requiresOtp: true` and no tokens. Not a failure -- `LoginPage` uses this
/// to navigate to the OTP screen instead of home, carrying [username] since
/// `verifyOtp`/`resendOtp` are keyed by it, not by a token the app was never
/// given.
class LoginNeedsOtp extends AuthFormStatus {
  const LoginNeedsOtp(this.username);
  final String username;

  @override
  bool operator ==(Object other) =>
      other is LoginNeedsOtp && other.username == username;

  @override
  int get hashCode => Object.hash(LoginNeedsOtp, username);
}
