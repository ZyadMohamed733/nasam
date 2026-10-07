import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/password_rules.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_form_status.dart';

/// Adds the live rule breakdown the checklist renders.
///
/// The rules are recomputed on every keystroke rather than only on submit,
/// which is the point of a checklist: it tells you what is still missing while
/// you type, instead of rejecting you afterwards.
class NewPasswordState {
  const NewPasswordState({
    this.status = const AuthFormIdle(),
    this.rules = const PasswordRules({}),
    this.matches = false,
  });

  final AuthFormStatus status;
  final PasswordRules rules;
  final bool matches;

  bool get canSubmit => rules.isValid && matches;

  NewPasswordState copyWith({
    AuthFormStatus? status,
    PasswordRules? rules,
    bool? matches,
  }) => NewPasswordState(
    status: status ?? this.status,
    rules: rules ?? this.rules,
    matches: matches ?? this.matches,
  );
}
class NewPasswordCubit extends Cubit<NewPasswordState> {
  NewPasswordCubit(this._resetPassword) : super(const NewPasswordState());

  final ResetPasswordUseCase _resetPassword;

  String _password = '';
  String _confirmation = '';

  void onPasswordChanged(String value) {
    _password = value;
    _emitRules();
  }

  void onConfirmationChanged(String value) {
    _confirmation = value;
    _emitRules();
  }

  void _emitRules() {
    emit(
      state.copyWith(
        rules: PasswordRules.of(_password),
        // An empty confirmation is not a match, or the button would enable
        // before the second field has been touched at all.
        matches: _confirmation.isNotEmpty && _confirmation == _password,
      ),
    );
  }

  Future<void> submit(String resetToken) async {
    if (state.status is AuthFormSubmitting || !state.canSubmit) return;
    emit(state.copyWith(status: const AuthFormSubmitting()));

    final result = await _resetPassword(
      resetToken: resetToken,
      newPassword: _password,
    );
    if (isClosed) return;

    emit(
      state.copyWith(
        status: result.fold(
          AuthFormFailed.new,
          (_) => const AuthFormSucceeded(),
        ),
      ),
    );
  }
}
