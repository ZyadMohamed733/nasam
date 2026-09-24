import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:nasam/features/auth/presentation/widgets/session_drawer.dart';

import '../../../../helpers/widget_harness.dart';

class _MockLogout extends Mock implements LogoutUseCase {}

void main() {
  testWidgets('sign-out shows progress and ignores further taps', (
    tester,
  ) async {
    final logout = _MockLogout();
    final gate = Completer<Either<Failure, Unit>>();
    when(() => logout()).thenAnswer((_) => gate.future);

    await pumpInApp(tester, SessionDrawer(cubit: LogoutCubit(logout)));
    await tester.pumpAndSettle();

    final entry = find.text('Logout');
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(entry, warnIfMissed: false);
    await tester.pump();
    verify(() => logout()).called(1);

    gate.complete(const Right(unit));
    await tester.pump();
  });
}
