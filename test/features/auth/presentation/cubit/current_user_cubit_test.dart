import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/domain/entities/user_entity.dart';
import 'package:nasam/features/auth/domain/entities/user_type.dart';
import 'package:nasam/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/current_user_cubit.dart';

class _MockGetCurrentUser extends Mock implements GetCurrentUserUseCase {}

const _user = UserEntity(
  id: 'u',
  username: 'aya',
  email: 'aya@nasam.sa',
  nameEn: 'Aya',
  nameAr: null,
  account: null,
  type: UserType.admin,
  permissions: [],
);

void main() {
  late _MockGetCurrentUser get;
  setUp(() => get = _MockGetCurrentUser());

  blocTest<CurrentUserCubit, CurrentUserState>(
    'a stored user is loaded',
    setUp: () => when(get.call).thenAnswer((_) async => const Right(_user)),
    build: () => CurrentUserCubit(get),
    act: (c) => c.load(),
    expect: () => const [CurrentUserLoaded(_user)],
  );

  blocTest<CurrentUserCubit, CurrentUserState>(
    'nobody stored is unavailable',
    setUp: () => when(get.call).thenAnswer((_) async => const Right(null)),
    build: () => CurrentUserCubit(get),
    act: (c) => c.load(),
    expect: () => const [CurrentUserUnavailable()],
  );

  blocTest<CurrentUserCubit, CurrentUserState>(
    'an unreadable profile is unavailable, not an error screen',
    setUp: () => when(
      get.call,
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'bad json'))),
    build: () => CurrentUserCubit(get),
    act: (c) => c.load(),
    expect: () => const [CurrentUserUnavailable()],
  );
}
