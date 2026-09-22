import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/forget_password_usecase.dart';
import 'auth_form_status.dart';

@injectable
class ForgotPasswordCubit extends Cubit<AuthFormStatus> {
  ForgotPasswordCubit(this._forgetPassword) : super(const AuthFormIdle());

  final ForgetPasswordUseCase _forgetPassword;

  Future<void> submit(String email) async {
    if (state is AuthFormSubmitting) return;
    emit(const AuthFormSubmitting());

    final result = await _forgetPassword(email.trim());
    if (isClosed) return;

    emit(result.fold(AuthFormFailed.new, (_) => const AuthFormSucceeded()));
  }
}
