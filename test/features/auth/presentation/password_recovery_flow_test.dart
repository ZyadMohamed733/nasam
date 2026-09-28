import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/constants/app_strings.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nasam/features/auth/presentation/cubit/password_recovery_cubit.dart';
import 'package:nasam/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:nasam/features/auth/presentation/pages/new_password_page.dart';
import 'package:nasam/features/auth/presentation/pages/reset_code_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/app_harness.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

/// Password recovery through the real router, container, repository, use
/// cases and cubits. Only the remote data source is faked, so no email is
/// sent and no password changes.
void main() {
  const email = 'user@example.com';
  const password = 'Str0ng!Pass';
  late _MockRemote remote;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({
      AppStrings.keyAuthStorageInitialised: true,
      AppStrings.keyUserLocale: 'en',
    });
    FlutterSecureStorage.setMockInitialValues({});
    await configureDependencies(
      const AppConfig(
        flavor: Flavor.dev,
        appName: 'Nasam',
        baseUrl: 'https://api.test/api/v1',
        wsUrl: 'wss://ws.test',
        tenant: 'test-tenant',
      ),
    );
    getIt.allowReassignment = true;
    remote = _MockRemote();
    getIt.registerSingleton<AuthRemoteDataSource>(remote);

    when(() => remote.forgetPassword(any())).thenAnswer((_) async {});
    when(
      () => remote.verifyResetOtp(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async => 'tok-1');
    when(
      () => remote.resetPassword(
        resetToken: any(named: 'resetToken'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    getIt.allowReassignment = false;
    await getIt.reset();
  });

  PasswordRecoveryCubit recoveryOf(WidgetTester tester, Type page) =>
      tester.element(find.byType(page)).read<PasswordRecoveryCubit>();

  /// Login → forgot password → code sent → on the code screen.
  Future<AppRouter> toCodeScreen(WidgetTester tester) async {
    final router = await openApp(tester, AppRoutes.login);
    await tester.tap(find.text('Forgot your password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordPage), findsOneWidget);

    await tester.enterText(find.byType(EditableText), email);
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    verify(() => remote.forgetPassword(email)).called(1);
    expect(currentLocation(router), AppRoutes.resetCode);
    return router;
  }

  /// …then a code with a leading zero → on the new-password screen.
  Future<AppRouter> toNewPasswordScreen(WidgetTester tester) async {
    final router = await toCodeScreen(tester);
    await tester.enterText(find.byType(EditableText), '012345');
    await tester.pumpAndSettle();

    verify(() => remote.verifyResetOtp(email: email, code: '012345')).called(1);
    expect(currentLocation(router), AppRoutes.newPassword);
    return router;
  }

  Future<void> enterPassword(WidgetTester tester) async {
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), password);
    await tester.pump();
  }

  testWidgets('email → code → new password → success → login', (tester) async {
    final router = await toNewPasswordScreen(tester);
    final recovery = recoveryOf(tester, NewPasswordPage);
    expect(recovery.resetToken, 'tok-1');

    await enterPassword(tester);
    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();

    // The token from verification, the new password, and nothing else.
    verify(
      () => remote.resetPassword(resetToken: 'tok-1', newPassword: password),
    ).called(1);
    expect(currentLocation(router), AppRoutes.passwordResetSuccess);

    // The flow is gone, and its token with it; nothing to go back to.
    expect(recovery.isClosed, isTrue);
    expect(recovery.resetToken, isNull);
    expect(router.config.canPop(), isFalse);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(currentLocation(router), AppRoutes.login);
    // Not signed in automatically.
    verifyNever(
      () => remote.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    );
    expect(await getIt<AuthService>().isAuthenticated, isFalse);
  });

  testWidgets('a rejected code stays on the code screen; resend works', (
    tester,
  ) async {
    when(
      () => remote.verifyResetOtp(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenThrow(const ValidationException(message: 'Invalid or expired OTP.'));
    final router = await toCodeScreen(tester);

    await tester.enterText(find.byType(EditableText), '000000');
    await tester.pumpAndSettle();

    expect(currentLocation(router), AppRoutes.resetCode);
    expect(find.text('Invalid or expired OTP.'), findsOneWidget);

    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();

    verify(() => remote.forgetPassword(email)).called(1); // the resend
    expect(find.text('A new code has been sent.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // stop the countdown
  });

  testWidgets('a 200 without a reset token does not move on', (tester) async {
    when(
      () => remote.verifyResetOtp(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenThrow(
      const ServerException(
        message: 'The server did not return a reset token.',
        code: 'missing_reset_token',
      ),
    );
    final router = await toCodeScreen(tester);

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pumpAndSettle();

    expect(currentLocation(router), AppRoutes.resetCode);
    expect(recoveryOf(tester, ResetCodePage).resetToken, isNull);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
      reason: 'a localized message, not the raw server text',
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a rejected password can be corrected and retried', (
    tester,
  ) async {
    final router = await toNewPasswordScreen(tester);
    var calls = 0;
    when(
      () => remote.resetPassword(
        resetToken: any(named: 'resetToken'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async {
      if (calls++ == 0) {
        throw const ValidationException(
          message: 'New password must differ from the current one.',
        );
      }
    });

    await enterPassword(tester);
    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();

    expect(currentLocation(router), AppRoutes.newPassword);
    expect(
      find.text('New password must differ from the current one.'),
      findsOneWidget,
    );
    expect(find.text('Request a new code'), findsOneWidget);
    expect(recoveryOf(tester, NewPasswordPage).resetToken, 'tok-1');

    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();
    expect(currentLocation(router), AppRoutes.passwordResetSuccess);
  });

  testWidgets('an expired token: start over from the email step', (
    tester,
  ) async {
    when(
      () => remote.resetPassword(
        resetToken: any(named: 'resetToken'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenThrow(
      const ValidationException(message: 'Reset token is invalid or expired.'),
    );
    final router = await toNewPasswordScreen(tester);
    final recovery = recoveryOf(tester, NewPasswordPage);

    await enterPassword(tester);
    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request a new code'));
    await tester.pumpAndSettle();

    expect(currentLocation(router), AppRoutes.forgotPassword);
    expect(recovery.resetToken, isNull);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.controller.text, email, reason: 'the address is kept');
  });

  testWidgets('going back from the new password drops the token', (
    tester,
  ) async {
    final router = await toNewPasswordScreen(tester);
    final recovery = recoveryOf(tester, NewPasswordPage);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(currentLocation(router), AppRoutes.resetCode);
    expect(recovery.resetToken, isNull);
    expect(recovery.state.hasResetToken, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the new-password screen cannot be opened without a code', (
    tester,
  ) async {
    final router = await openApp(tester, AppRoutes.newPassword);
    await tester.pumpAndSettle();
    expect(currentLocation(router), AppRoutes.forgotPassword);
    verifyNever(
      () => remote.resetPassword(
        resetToken: any(named: 'resetToken'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });
}
