import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/theme/app_theme.dart';

/// Sizes the test surface to the design frame at 1:1 so that `.sp` resolves to
/// the design's own points and a measured height can be compared against a
/// number read off the Figma file.
///
/// The default 800x600 surface scales every `.sp` by about two, which makes
/// design-point assertions meaningless. Worse, `ScreenUtil` keeps its scale in
/// a singleton seeded by the first widget built in the file, so a test that
/// sets the frame for itself still gets the previous test's scale — which is
/// why this belongs in [pumpInApp] rather than in individual tests.
void useDesignFrame(WidgetTester tester) {
  tester.view.physicalSize = const Size(
    AppSizes.designWidth,
    AppSizes.designHeight,
  );
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Pumps [child] inside the same shell the app uses: the design frame, the
/// real theme and the localisation delegates.
///
/// `AppTheme` is read inside the `ScreenUtilInit` builder because its text
/// styles use `.sp`, which is only resolvable there.
///
/// Pass [appBar] to mount a [PreferredSizeWidget] in the slot it is built for
/// — measuring one in the body gives the body's height, not the bar's.
Future<void> pumpInApp(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  bool dark = false,
  PreferredSizeWidget? appBar,
}) {
  useDesignFrame(tester);
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(AppSizes.designWidth, AppSizes.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Scaffold(
          appBar: appBar,
          body: Center(child: child),
        ),
      ),
    ),
  );
}
