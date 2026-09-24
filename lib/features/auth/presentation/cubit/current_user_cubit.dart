import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

sealed class CurrentUserState {
  const CurrentUserState();
}

final class CurrentUserLoading extends CurrentUserState {
  const CurrentUserLoading();

  @override
  bool operator ==(Object other) => other is CurrentUserLoading;

  @override
  int get hashCode => (CurrentUserLoading).hashCode;
}

final class CurrentUserLoaded extends CurrentUserState {
  const CurrentUserLoaded(this.user);
  final UserEntity user;

  @override
  bool operator ==(Object other) =>
      other is CurrentUserLoaded && other.user == user;

  @override
  int get hashCode => user.hashCode;
}

/// No profile to show: nobody signed in, or the stored one unreadable. The
/// drawer shows no name rather than a placeholder that looks like one.
final class CurrentUserUnavailable extends CurrentUserState {
  const CurrentUserUnavailable();

  @override
  bool operator ==(Object other) => other is CurrentUserUnavailable;

  @override
  int get hashCode => (CurrentUserUnavailable).hashCode;
}

/// The signed-in user, for the drawer's profile block.
@injectable
class CurrentUserCubit extends Cubit<CurrentUserState> {
  CurrentUserCubit(this._getCurrentUser) : super(const CurrentUserLoading());

  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> load() async {
    final result = await _getCurrentUser();
    if (isClosed) return;
    emit(
      result.fold(
        (_) => const CurrentUserUnavailable(),
        (user) => user == null
            ? const CurrentUserUnavailable()
            : CurrentUserLoaded(user),
      ),
    );
  }
}
