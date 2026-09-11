@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/theme/app_theme.dart';
import 'package:nasam/shared/widgets/app_text_field.dart';

/// Golden files are rendered by the host platform's font stack, so these are
/// tagged `golden` and excluded on CI, which runs Linux while the goldens are
/// generated on macOS. Run locally with:
///   flutter test --tags golden
///   flutter test --tags golden --update-goldens
void main() {
  Widget harness({required Locale locale, required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Scaffold(
          body: Center(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
  }

  group('AppTextField', () {
    testWidgets('en renders LTR', (tester) async {
      await tester.pumpWidget(
        harness(
          locale: const Locale('en'),
          child: const AppTextField(label: 'Driver name', hint: 'Full name'),
        ),
      );
      await expectLater(
        find.byType(AppTextField),
        matchesGoldenFile('goldens/app_text_field_en.png'),
      );
    });

    testWidgets('ar renders RTL', (tester) async {
      await tester.pumpWidget(
        harness(
          locale: const Locale('ar'),
          child: const AppTextField(label: 'اسم السائق', hint: 'الاسم الكامل'),
        ),
      );
      await expectLater(
        find.byType(AppTextField),
        matchesGoldenFile('goldens/app_text_field_ar.png'),
      );
    });

    // The regression the scaffold previously shipped: forcing direction from
    // the app locale mis-rendered a plate number inside an Arabic build.
    testWidgets('ar keeps an LTR-only field left-to-right', (tester) async {
      await tester.pumpWidget(
        harness(
          locale: const Locale('ar'),
          child: const AppTextField(
            label: 'رقم اللوحة',
            hint: '1234 ABC',
            forceLtr: true,
          ),
        ),
      );
      await expectLater(
        find.byType(AppTextField),
        matchesGoldenFile('goldens/app_text_field_ar_force_ltr.png'),
      );
    });
  });
}
