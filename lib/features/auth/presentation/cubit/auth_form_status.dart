import '../../../../core/errors/failures.dart';

/// Where a submittable auth form is in its one round trip.
///
/// All four auth screens do the same thing — take some input, call one
/// usecase, then either move on or show why not — so they share one status
/// rather than each declaring its own idle/loading/failure trio.
sealed class AuthFormStatus {
  const AuthFormStatus();
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
}
