import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';

class _MockLogout extends Mock implements LogoutUseCase {}

void main() {
  late _MockLogout logout;

  setUp(() {
    logout = _MockLogout();
    when(() => logout()).thenAnswer((_) async => const Right(unit));
  });

  blocTest<LogoutCubit, LogoutState>(
    'shows progress, then done',
    build: () => LogoutCubit(logout),
    act: (cubit) => cubit.logout(),
    expect: () => const [LogoutInProgress(), LogoutDone()],
  );

  blocTest<LogoutCubit, LogoutState>(
    'a double tap signs out once',
    setUp: () {
      final gate = Completer<Either<Failure, Unit>>();
      when(() => logout()).thenAnswer((_) => gate.future);
      Future<void>.delayed(
        Duration.zero,
        () => gate.complete(const Right(unit)),
      );
    },
    build: () => LogoutCubit(logout),
    act: (cubit) async {
      await Future.wait([cubit.logout(), cubit.logout()]);
      await cubit.logout(); // and a tap after it finished
    },
    expect: () => const [LogoutInProgress(), LogoutDone()],
    verify: (_) => verify(() => logout()).called(1),
  );

  // The repository has already signed out locally whatever the server said;
  // the drawer must not sit on an error the user cannot act on.
  blocTest<LogoutCubit, LogoutState>(
    'a server error still ends in done',
    setUp: () => when(() => logout()).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'down', code: '500')),
    ),
    build: () => LogoutCubit(logout),
    act: (cubit) => cubit.logout(),
    expect: () => const [LogoutInProgress(), LogoutDone()],
  );
}
