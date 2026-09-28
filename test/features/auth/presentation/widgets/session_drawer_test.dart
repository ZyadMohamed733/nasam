import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/domain/entities/user_entity.dart';
import 'package:nasam/features/auth/domain/entities/user_type.dart';
import 'package:nasam/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/current_user_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:nasam/features/auth/presentation/widgets/session_drawer.dart';
import 'package:nasam/shared/widgets/app_drawer.dart';

import '../../../../helpers/widget_harness.dart';

class _MockLogout extends Mock implements LogoutUseCase {}

class _MockGetCurrentUser extends Mock implements GetCurrentUserUseCase {}

const _user = UserEntity(
  id: 'user-7',
  username: 'm.ahmed',
  email: 'm.ahmed@nasam.sa',
  nameEn: 'Mohamed Ahmed',
  nameAr: 'محمد أحمد',
  account: null,
  type: UserType.clientAdmin,
  permissions: [],
);

void main() {
  late _MockLogout logout;
  late _MockGetCurrentUser currentUser;

  setUp(() {
    logout = _MockLogout();
    when(logout.call).thenAnswer((_) async => const Right(unit));
    currentUser = _MockGetCurrentUser();
    when(currentUser.call).thenAnswer((_) async => const Right(_user));
  });

  Future<void> pumpDrawer(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    DrawerDestination? selected,
    ValueChanged<DrawerDestination>? onSelect,
  }) async {
    await pumpInApp(
      tester,
      SessionDrawer(
        cubit: LogoutCubit(logout),
        currentUserCubit: CurrentUserCubit(currentUser),
        selected: selected,
        onSelect: onSelect,
      ),
      locale: locale,
    );
    await tester.pumpAndSettle();
  }

  group('profile', () {
    testWidgets("shows the stored user's name and role", (tester) async {
      await pumpDrawer(tester);
      expect(find.text('Mohamed Ahmed'), findsOneWidget);
      expect(find.text('Client administrator'), findsOneWidget);
    });

    testWidgets('prefers the Arabic name under Arabic', (tester) async {
      await pumpDrawer(tester, locale: const Locale('ar'));
      expect(find.text('محمد أحمد'), findsOneWidget);
    });

    testWidgets('falls back to the username when there is no name', (
      tester,
    ) async {
      when(currentUser.call).thenAnswer(
        (_) async => const Right(
          UserEntity(
            id: 'u',
            username: 'm.ahmed',
            email: 'e',
            nameEn: ' ',
            nameAr: null,
            account: null,
            type: UserType.employee,
            permissions: [],
          ),
        ),
      );
      await pumpDrawer(tester);
      expect(find.text('m.ahmed'), findsOneWidget);
    });

    // No stand-in name: an unknown user shows none rather than someone's.
    testWidgets('shows no name when there is no stored profile', (
      tester,
    ) async {
      when(currentUser.call).thenAnswer((_) async => const Right(null));
      await pumpDrawer(tester);
      expect(find.text('Aya Al-Rashidi'), findsNothing);
      expect(find.text('System administrator'), findsNothing);
      expect(find.text('Logout'), findsOneWidget);
    });
  });

  group('menu entries', () {
    testWidgets('the current screen is marked, and tapping it is passed on', (
      tester,
    ) async {
      final selected = <DrawerDestination>[];
      await pumpDrawer(
        tester,
        selected: DrawerDestination.trackingDashboard,
        onSelect: selected.add,
      );

      final semantics = tester.getSemantics(find.text('Tracking dashboard'));
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);

      await tester.tap(find.text('Tracking dashboard'));
      expect(selected, [DrawerDestination.trackingDashboard]);
    });

    // Screens that do not exist yet are shown but cannot be tapped.
    testWidgets('entries without a screen are disabled, coming soon', (
      tester,
    ) async {
      final selected = <DrawerDestination>[];
      await pumpDrawer(tester, onSelect: selected.add);

      for (final label in ['Points of interest', 'Geofences', 'Alerts log']) {
        final node = tester.getSemantics(find.text(label));
        expect(node.flagsCollection.isEnabled, Tristate.isFalse, reason: label);
        expect(node.hint, 'Coming soon', reason: label);
        await tester.tap(find.text(label), warnIfMissed: false);
      }
      expect(selected, isEmpty);
    });

    testWidgets('without a handler no entry is live', (tester) async {
      await pumpDrawer(tester);
      final node = tester.getSemantics(find.text('Tracking dashboard'));
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
    });
  });

  testWidgets('sign-out shows progress and ignores further taps', (
    tester,
  ) async {
    final gate = Completer<Either<Failure, Unit>>();
    when(logout.call).thenAnswer((_) => gate.future);
    await pumpDrawer(tester);

    final entry = find.text('Logout');
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(entry, warnIfMissed: false);
    await tester.pump();
    verify(logout.call).called(1);

    gate.complete(const Right(unit));
    await tester.pump();
  });
}
