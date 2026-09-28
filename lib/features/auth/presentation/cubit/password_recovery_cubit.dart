import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/verify_reset_otp_usecase.dart';
import 'auth_form_status.dart';

/// Where a password recovery stands.
///
/// Separate from login's OTP and session state: nothing here signs anyone
/// in or touches stored credentials.
@immutable
class PasswordRecoveryState {
  const PasswordRecoveryState({
    this.email = '',
    this.hasResetToken = false,
    this.request = const AuthFormIdle(),
    this.resend = const AuthFormIdle(),
    this.verify = const AuthFormIdle(),
  });

  /// The address the code was sent to; empty until a code has been sent.
  final String email;

  /// Whether a verified code has earned a reset token. The token itself is
  /// not part of the state — see [PasswordRecoveryCubit.resetToken] — so no
  /// state object, observer log or listener ever holds it.
  final bool hasResetToken;

  /// Sending the code from the email step.
  final AuthFormStatus request;

  /// Sending it again from the code step.
  final AuthFormStatus resend;

  /// Checking the code.
  final AuthFormStatus verify;

  PasswordRecoveryState copyWith({
    String? email,
    bool? hasResetToken,
    AuthFormStatus? request,
    AuthFormStatus? resend,
    AuthFormStatus? verify,
  }) => PasswordRecoveryState(
    email: email ?? this.email,
    hasResetToken: hasResetToken ?? this.hasResetToken,
    request: request ?? this.request,
    resend: resend ?? this.resend,
    verify: verify ?? this.verify,
  );

  @override
  bool operator ==(Object other) =>
      other is PasswordRecoveryState &&
      other.email == email &&
      other.hasResetToken == hasResetToken &&
      other.request == request &&
      other.resend == resend &&
      other.verify == verify;

  @override
  int get hashCode =>
      Object.hash(email, hasResetToken, request, resend, verify);

  /// Leaves out the email: bloc observers log state changes.
  @override
  String toString() =>
      'PasswordRecoveryState(request: ${request.runtimeType}, '
      'resend: ${resend.runtimeType}, verify: ${verify.runtimeType}, '
      'hasEmail: ${email.isNotEmpty}, hasResetToken: $hasResetToken)';
}

/// The password recovery flow: send a code to an email, check the code for
/// a reset token, and hold that token for the new-password step.
///
/// Scoped to the recovery screens by the router, so leaving them — back to
/// login, or on to the success screen — closes it, and the token goes with
/// it. The new password itself is submitted by `NewPasswordCubit`, which
/// owns the password rules.
@injectable
class PasswordRecoveryCubit extends Cubit<PasswordRecoveryState> {
  PasswordRecoveryCubit(
    this._forgetPassword,
    this._verifyResetOtp, {
    @ignoreParam PasswordRecoveryState initial = const PasswordRecoveryState(),
    @ignoreParam String? resetToken,
  }) : _resetToken = resetToken,
       super(initial.copyWith(hasResetToken: resetToken?.isNotEmpty ?? false));

  final ForgetPasswordUseCase _forgetPassword;
  final VerifyResetOtpUseCase _verifyResetOtp;

  /// Codes are six digits, kept as a string so leading zeros survive.
  static final _code = RegExp(r'^\d{6}$');

  /// The temporary token from a verified code, for the new-password step.
  /// In memory only, for this flow only: never persisted, put in a URL or
  /// logged, and dropped when the flow restarts, is left, or ends.
  String? _resetToken;
  String? get resetToken => _resetToken;

  /// Sends a code to [email] and starts the flow over for it: any token from
  /// an earlier code is dropped.
  Future<void> requestCode(String email) async {
    if (state.request is AuthFormSubmitting) return;
    final address = email.trim();
    _resetToken = null;
    emit(
      state.copyWith(
        hasResetToken: false,
        request: const AuthFormSubmitting(),
        resend: const AuthFormIdle(),
        verify: const AuthFormIdle(),
      ),
    );

    final result = await _forgetPassword(address);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => state.copyWith(request: AuthFormFailed(failure)),
        (_) =>
            state.copyWith(email: address, request: const AuthFormSucceeded()),
      ),
    );
  }

  /// Sends the code again, to the same address, through the same endpoint.
  Future<void> resendCode() async {
    if (state.resend is AuthFormSubmitting || state.email.isEmpty) return;
    _resetToken = null;
    emit(
      state.copyWith(
        hasResetToken: false,
        resend: const AuthFormSubmitting(),
        verify: const AuthFormIdle(),
      ),
    );

    final result = await _forgetPassword(state.email);
    if (isClosed) return;

    emit(
      state.copyWith(
        resend: result.fold(
          AuthFormFailed.new,
          (_) => const AuthFormSucceeded(),
        ),
      ),
    );
  }

  /// Checks [code] and, if it is good, keeps the reset token it earns.
  Future<void> verifyCode(String code) async {
    if (state.verify is AuthFormSubmitting ||
        state.email.isEmpty ||
        !_code.hasMatch(code)) {
      return;
    }
    emit(state.copyWith(verify: const AuthFormSubmitting()));

    final result = await _verifyResetOtp(email: state.email, code: code);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(verify: AuthFormFailed(failure))),
      (token) {
        _resetToken = token;
        emit(
          state.copyWith(
            hasResetToken: token.isNotEmpty,
            verify: const AuthFormSucceeded(),
          ),
        );
      },
    );
  }

  /// Drops the token: the new-password step was left, or finished. The
  /// email stays, so starting over can offer it again.
  void clearResetToken() {
    _resetToken = null;
    if (isClosed || !state.hasResetToken) return;
    emit(state.copyWith(hasResetToken: false, verify: const AuthFormIdle()));
  }

  @override
  Future<void> close() {
    _resetToken = null;
    return super.close();
  }
}
