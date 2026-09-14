import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/verify_reset_code_usecase.dart';
import 'auth_form_status.dart';

/// Succeeds with the reset token, which the next screen needs.
class OtpVerified extends AuthFormSucceeded {
  const OtpVerified(this.resetToken);
  final String resetToken;
}

@injectable
class OtpCubit extends Cubit<AuthFormStatus> {
  OtpCubit(this._verify, this._requestReset) : super(const AuthFormIdle());

  final VerifyResetCodeUseCase _verify;
  final RequestPasswordResetUseCase _requestReset;

  Future<void> submit({required String email, required String code}) async {
    if (state is AuthFormSubmitting) return;
    emit(const AuthFormSubmitting());

    final result = await _verify(email: email.trim(), code: code);
    if (isClosed) return;

    emit(result.fold(AuthFormFailed.new, OtpVerified.new));
  }

  /// Asks for a fresh code. Deliberately does not move the form into
  /// submitting: the code fields stay usable while the new message is on its
  /// way, and a failure here should not read as a rejected code.
  Future<void> resend(String email) async {
    await _requestReset(email.trim());
  }
}
