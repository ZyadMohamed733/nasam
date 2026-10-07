import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_form_status.dart';

/// The second factor of login (`POST /auth/verify-otp` /
/// `POST /auth/resend-otp`), not part of password reset -- see
/// docs/plans/AUTH_INTEGRATION_PLAN.md.
class OtpCubit extends Cubit<AuthFormStatus> {
  OtpCubit(this._verify, this._resend) : super(const AuthFormIdle());

  final VerifyOtpUseCase _verify;
  final ResendOtpUseCase _resend;

  Future<void> submit({required String username, required String code}) async {
    if (state is AuthFormSubmitting) return;
    emit(const AuthFormSubmitting());

    final result = await _verify(username: username.trim(), code: code);
    if (isClosed) return;

    emit(
      result.fold(
        AuthFormFailed.new,
        // The session is already persisted by the repository, same as a
        // non-2FA login -- nothing further to carry.
        (_) => const AuthFormSucceeded(),
      ),
    );
  }

  /// Asks for a fresh code. Deliberately does not move the form into
  /// submitting: the code fields stay usable while the new message is on its
  /// way, and a failure here should not read as a rejected code.
  ///
  /// Shares its rate limit with the code `login` itself sent -- a 429 here
  /// means that budget is spent, not just this button's.
  Future<void> resend(String username) async {
    await _resend(username.trim());
  }
}
