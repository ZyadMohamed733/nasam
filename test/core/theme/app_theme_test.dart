import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/app_theme.dart';

void main() {
  Widget harness({required Widget child, TextScaler? textScaler}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: textScaler ?? TextScaler.noScaling),
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('textTheme is populated, so pages can read it from context', (
    tester,
  ) async {
    late TextTheme textTheme;
    await tester.pumpWidget(
      harness(
        child: Builder(
          builder: (context) {
            textTheme = Theme.of(context).textTheme;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(textTheme.headlineMedium?.fontSize, isNotNull);
    expect(textTheme.bodyMedium?.fontSize, isNotNull);
    expect(textTheme.labelLarge?.fontWeight, FontWeight.w600);
  });

  // The accessibility regression the scaffold previously had: system font size
  // must still reach rendered text.
  testWidgets('MediaQuery.textScaler still scales rendered text', (
    tester,
  ) async {
    Future<double> renderedFontSize(TextScaler scaler) async {
      await tester.pumpWidget(
        harness(
          textScaler: scaler,
          child: Builder(
            builder: (context) =>
                Text('Fleet', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      );
      final richText = tester.widget<RichText>(find.byType(RichText));
      final style = (richText.text as TextSpan).style!;
      return richText.textScaler.scale(style.fontSize!);
    }

    final normal = await renderedFontSize(TextScaler.noScaling);
    final scaled = await renderedFontSize(const TextScaler.linear(2));

    expect(scaled, greaterThan(normal));
  });

  testWidgets('light and dark are distinct and both carry a colorScheme', (
    tester,
  ) async {
    await tester.pumpWidget(harness(child: const SizedBox()));

    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(
      AppTheme.light.colorScheme.surface,
      isNot(AppTheme.dark.colorScheme.surface),
    );
  });

  // Guards the reason these are `static final` rather than getters.
  testWidgets('the theme is built once, not per rebuild', (tester) async {
    await tester.pumpWidget(harness(child: const SizedBox()));
    expect(identical(AppTheme.light, AppTheme.light), isTrue);
  });
}
