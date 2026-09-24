import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/theme/app_theme.dart';

/// Starts the real app — container router, guard and all — at [location].
///
/// The platform's initial route is set before the router exists, which is
/// how go_router picks its first location; nothing here navigates. The
/// container must already be configured, with any overrides registered.
Future<AppRouter> openApp(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(
    AppSizes.designWidth,
    AppSizes.designHeight,
  );
  tester.view.devicePixelRatio = 1.0;
  tester.binding.platformDispatcher.defaultRouteNameTestValue = location;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.binding.platformDispatcher.clearDefaultRouteNameTestValue();
  });

  final router = getIt<AppRouter>();
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(AppSizes.designWidth, AppSizes.designHeight),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(
        routerConfig: router.config,
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Where the router is now, query included.
String currentLocation(AppRouter router) =>
    router.config.routerDelegate.currentConfiguration.uri.toString();
