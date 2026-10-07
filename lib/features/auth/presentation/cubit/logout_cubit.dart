import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/logout_usecase.dart';

sealed class LogoutState {
  const LogoutState();

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class LogoutIdle extends LogoutState {
  const LogoutIdle();
}

final class LogoutInProgress extends LogoutState {
  const LogoutInProgress();
}

/// Signed out locally. There is no failure state: the repository clears the
/// session whatever the server says, so every attempt ends here.
final class LogoutDone extends LogoutState {
  const LogoutDone();
}

/// Drives the drawer's sign-out.
///
/// It does not navigate. The repository tells `AuthSessionNotifier`, and the
/// router's guard sends the user to login from wherever they are.
class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._logout) : super(const LogoutIdle());

  final LogoutUseCase _logout;

  Future<void> logout() async {
    // One sign-out per tap sequence: a second tap while the first is in
    // flight, or after it finished, does nothing.
    if (state is! LogoutIdle) return;
    emit(const LogoutInProgress());
    await _logout();
    if (!isClosed) emit(const LogoutDone());
  }
}
