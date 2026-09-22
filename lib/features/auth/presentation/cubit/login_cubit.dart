import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/login_result.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_form_status.dart';

@injectable
class LoginCubit extends Cubit<AuthFormStatus> {
  LoginCubit(this._login) : super(const AuthFormIdle());

  final LoginUseCase _login;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state is AuthFormSubmitting) return;
    emit(const AuthFormSubmitting());

    final result = await _login(
      username: username.trim(),
      password: password,
    );
    if (isClosed) return;

    emit(
      result.fold(AuthFormFailed.new, (loginResult) => switch (loginResult) {
        // The session is already persisted by the repository, so there is
        // nothing to carry into the state: the page only needs to know it
        // may navigate.
        LoginSucceeded() => const AuthFormSucceeded(),
        LoginRequiresOtp(:final username) => LoginNeedsOtp(username),
      }),
    );
  }
}
