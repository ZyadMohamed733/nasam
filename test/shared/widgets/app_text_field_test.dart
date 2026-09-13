import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/app_text_field.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    ),
  );

  InputDecoration decorationOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).decoration!;

  group('AppTextField forceLtr', () {
    // The RTL goldens cover this visually, but they are tagged `golden` and
    // skipped on CI, so the behaviour needs a guard that actually runs there.
    testWidgets('pins both the content and the hint to LTR', (tester) async {
      await pump(
        tester,
        const AppTextField(
          label: 'رقم اللوحة',
          hint: '1234 ABC',
          forceLtr: true,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, TextDirection.ltr);
      // Without this the hint is laid out in the ambient RTL directionality and
      // bidi reorders it to "ABC 1234" — a format the field never produces.
      expect(decorationOf(tester).hintTextDirection, TextDirection.ltr);
    });

    testWidgets('leaves direction to the content by default', (tester) async {
      await pump(
        tester,
        const AppTextField(label: 'اسم السائق', hint: 'الاسم الكامل'),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, isNull);
      expect(decorationOf(tester).hintTextDirection, isNull);
    });
  });
}
