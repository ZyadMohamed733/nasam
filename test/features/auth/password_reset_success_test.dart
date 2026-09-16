import 'dart:io';
import 'dart:ui' as ui;

import 'package:dartz/dartz.dart' show Right, unit;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/constants/app_assets.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/theme/app_theme.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/new_password_cubit.dart';
import 'package:nasam/features/auth/presentation/pages/new_password_page.dart';
import 'package:nasam/features/auth/presentation/pages/password_reset_success_page.dart';
import 'package:nasam/features/auth/presentation/widgets/animated_success_icon.dart';

import '../../helpers/font_loader.dart';

class _Repository extends Mock implements AuthRepository {}

void main() {
  setUpAll(loadAppFonts);
  final captureKey = GlobalKey();

  Future<GoRouter> mount(
    WidgetTester tester, {
    NewPasswordCubit? cubit,
    bool reduceMotion = false,
    Size size = const Size(402, 874),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: cubit == null
          ? AppRoutes.passwordResetSuccess
          : AppRoutes.newPassword,
      routes: [
        GoRoute(
          path: AppRoutes.newPassword,
          builder: (context, state) =>
              NewPasswordPage(resetToken: 'verified-token', cubit: cubit),
        ),
        GoRoute(
          path: AppRoutes.passwordResetSuccess,
          builder: (context, state) => const PasswordResetSuccessPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) =>
              const Scaffold(body: Text('login destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (context, child) => MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          theme: AppTheme.light,
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduceMotion,
              textScaler: TextScaler.linear(textScale),
            ),
            child: RepaintBoundary(key: captureKey, child: child!),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future.wait([
        precacheImage(
          const AssetImage(AppAssets.passwordResetSuccess),
          captureKey.currentContext!,
        ),
        precacheImage(
          const AssetImage(AppAssets.splashBackground),
          captureKey.currentContext!,
        ),
      ]);
    });
    await tester.pump();
    return router;
  }

  testWidgets('success animates once, stays visible, and opens login', (
    tester,
  ) async {
    final router = await mount(tester);
    await tester.pumpAndSettle();
    expect(find.text('تم تغير كلمة المرور بنجاح'), findsOneWidget);
    expect(find.byType(AnimatedSuccessIcon), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AnimatedSuccessIcon),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 1);
    if (const bool.fromEnvironment('CAPTURE_SUCCESS')) {
      await tester.runAsync(() async {
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '/tmp/nasam-password-reset-success.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('login destination'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });

  testWidgets('successful reset replaces form with confirmation', (
    tester,
  ) async {
    final repository = _Repository();
    when(
      () => repository.resetPassword(
        resetToken: 'verified-token',
        newPassword: 'StrongPass1!',
      ),
    ).thenAnswer((_) async => const Right(unit));
    final cubit = NewPasswordCubit(ResetPasswordUseCase(repository));
    final router = await mount(tester, cubit: cubit);
    await tester.pumpAndSettle();
    cubit.onPasswordChanged('StrongPass1!');
    cubit.onConfirmationChanged('StrongPass1!');
    await cubit.submit('verified-token');
    await tester.pumpAndSettle();
    expect(find.byType(PasswordResetSuccessPage), findsOneWidget);
    expect(find.byType(NewPasswordPage), findsNothing);
    expect(router.canPop(), isFalse);
  });

  testWidgets('reduced motion is static and small screens can scroll', (
    tester,
  ) async {
    await mount(
      tester,
      reduceMotion: true,
      size: const Size(320, 480),
      textScale: 1.8,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AnimatedSuccessIcon),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 1);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.ensureVisible(find.text('تسجيل الدخول'));
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('login destination'), findsOneWidget);
  });
}
