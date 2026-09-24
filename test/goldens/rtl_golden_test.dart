@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/constants/app_assets.dart';
import 'package:nasam/core/constants/app_icons.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:nasam/core/theme/app_theme.dart';
import 'package:nasam/shared/widgets/app_bar_widget.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_logo.dart';
import 'package:nasam/shared/widgets/app_otp_input.dart';
import 'package:nasam/shared/widgets/app_page_dots.dart';
import 'package:nasam/shared/widgets/app_text_field.dart';

/// Golden files are rendered by the host platform's font stack, so these are
/// tagged `golden`, generated on macOS, and compared only on macOS (see the
/// README). The real fonts come from test/flutter_test_config.dart. Run locally with:
///   flutter test --tags golden
///   flutter test --tags golden --update-goldens
///
/// Every shared widget is captured across the four combinations that can break
/// it independently: light and dark against English and Arabic.
void main() {
  Widget harness({
    required Locale locale,
    required bool dark,
    required Widget child,
  }) {
    return ScreenUtilInit(
      designSize: const Size(AppSizes.designWidth, AppSizes.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      // AppTheme is lazily built and must first be read inside this builder,
      // where `.sp` is resolvable — so it is resolved here, not at the call
      // site where the test is registered.
      builder: (context, _) => MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Runs one widget through light/dark x en/ar, writing
  /// `goldens/<name>_<theme>_<locale>.png` for each.
  void matrix(
    String name,
    Widget Function() build, {
    required Finder Function() finder,
    bool settle = true,
    ImageProvider? precache,
  }) {
    for (final (themeName, dark) in [('light', false), ('dark', true)]) {
      for (final localeCode in ['en', 'ar']) {
        testWidgets('$name $themeName $localeCode', skip: !Platform.isMacOS, (
          tester,
        ) async {
          final widget = harness(
            locale: Locale(localeCode),
            dark: dark,
            child: build(),
          );

          if (precache != null) {
            // Image decoding is genuinely asynchronous and cannot complete
            // under the fake clock. Waiting a fixed number of frames is a
            // race — it passes only once the cache is warm, so the first
            // combination in the matrix captures an empty frame. Resolving
            // the provider explicitly is deterministic.
            await tester.runAsync(() async {
              await tester.pumpWidget(widget);
              await precacheImage(
                precache,
                tester.element(find.byType(MaterialApp)),
              );
            });
            await tester.pump();
          } else {
            await tester.pumpWidget(widget);
            if (settle) await tester.pumpAndSettle();
          }

          await expectLater(
            finder(),
            matchesGoldenFile('goldens/${name}_${themeName}_$localeCode.png'),
          );

          // Unmount so any widget holding a timer disposes before the test
          // framework checks for pending ones.
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  WebSocketService fakeSocket() => WebSocketService(
    const AppConfig(
      flavor: Flavor.dev,
      baseUrl: 'http://localhost',
      appName: 'Nasam',
      wsUrl: 'ws://localhost',
      tenant: 'test-tenant',
    ),
  );

  matrix(
    'app_button_primary',
    () =>
        const AppButton(onPressed: _noop, label: 'متابعة', icon: AppIcons.user),
    finder: () => find.byType(AppButton),
  );

  matrix(
    'app_button_secondary',
    () => const AppButton(
      onPressed: _noop,
      label: 'إلغاء',
      variant: AppButtonVariant.secondary,
    ),
    finder: () => find.byType(AppButton),
  );

  matrix(
    'app_button_disabled',
    () => const AppButton(onPressed: null, label: 'متابعة'),
    finder: () => find.byType(AppButton),
  );

  matrix(
    'app_text_field',
    () => const AppTextField(label: 'اسم السائق', hint: 'الاسم الكامل'),
    finder: () => find.byType(AppTextField),
  );

  matrix(
    'app_text_field_error',
    () => const AppTextField(
      label: 'البريد الإلكتروني',
      hint: 'name@example.com',
      errorText: 'يرجى إدخال بريد إلكتروني صحيح.',
    ),
    finder: () => find.byType(AppTextField),
  );

  // The regression the scaffold previously shipped: forcing direction from the
  // app locale mis-rendered a plate number inside an Arabic build.
  matrix(
    'app_text_field_force_ltr',
    () => const AppTextField(
      label: 'رقم اللوحة',
      hint: '1234 ABC',
      forceLtr: true,
    ),
    finder: () => find.byType(AppTextField),
  );

  matrix(
    'app_page_dots',
    () => const AppPageDots(count: 3, activeIndex: 1),
    finder: () => find.byType(AppPageDots),
  );

  matrix(
    'app_logo',
    () => const AppLogo(size: AppLogoSize.medium),
    finder: () => find.byType(AppLogo),
    precache: const AssetImage(AppAssets.logoMark),
  );

  matrix(
    'app_otp_input',
    () => AppOtpInput(onResend: () {}),
    finder: () => find.byType(AppOtpInput),
    // The countdown ticks forever; settling would never return.
    settle: false,
  );

  matrix(
    'app_bar',
    () => Material(
      child: NasamAppBar(title: 'الرئيسية', wsService: fakeSocket()),
    ),
    finder: () => find.byType(NasamAppBar),
    settle: false,
  );
}

void _noop() {}
