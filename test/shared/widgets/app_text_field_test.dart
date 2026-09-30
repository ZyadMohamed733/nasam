import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/shared/widgets/app_text_field.dart';

import '../../helpers/widget_harness.dart';

void main() {
  InputDecoration decorationOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).decoration!;

  group('AppTextField forceLtr', () {
    // The RTL goldens cover this visually, but they are tagged `golden` and
    // skipped on CI, so the behaviour needs a guard that actually runs there.
    testWidgets('pins both the content and the hint to LTR', (tester) async {
      await pumpInApp(
        tester,
        const AppTextField(
          label: 'رقم اللوحة',
          hint: '1234 ABC',
          forceLtr: true,
        ),
        locale: const Locale('ar'),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, TextDirection.ltr);
      // Without this the hint is laid out in the ambient RTL directionality and
      // bidi reorders it to "ABC 1234" — a format the field never produces.
      expect(decorationOf(tester).hintTextDirection, TextDirection.ltr);
    });

    testWidgets('leaves direction to the content by default', (tester) async {
      await pumpInApp(
        tester,
        const AppTextField(label: 'اسم السائق', hint: 'الاسم الكامل'),
        locale: const Locale('ar'),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, isNull);
      expect(decorationOf(tester).hintTextDirection, isNull);
    });
  });

  group('AppTextField block', () {
    testWidgets('measures the design block heights at the design text scale', (
      tester,
    ) async {
      await pumpInApp(tester, const AppTextField(label: 'Driver name'));
      final plain = tester.getSize(find.byType(AppTextField)).height;

      await pumpInApp(
        tester,
        const AppTextField(label: 'Driver name', helperText: 'As on licence'),
      );
      final withHelper = tester.getSize(find.byType(AppTextField)).height;

      // On the design frame these are the design's own numbers: a 20pt label,
      // an 8pt gap, the 44pt input, then another 8pt gap and an 11pt helper.
      expect(plain, AppSizes.inputBlockHeight);
      expect(withHelper, AppSizes.inputBlockWithHelper);
    });

    // A fixed-height label box clipped Arabic to its bottom half, because every
    // size in the type scale is a .sp and scales while a hard box does not.
    testWidgets('grows instead of clipping when text is scaled up', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: AppTextField(
            label: 'اسم السائق',
            helperText: 'الاسم كما في الرخصة',
          ),
        ),
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppTextField)).height,
        greaterThan(AppSizes.inputBlockWithHelper),
      );
    });

    testWidgets('shows an external error in place of the helper', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const AppTextField(
          label: 'Email',
          helperText: 'Work address',
          errorText: 'That address is not valid.',
        ),
      );

      expect(find.text('That address is not valid.'), findsOneWidget);
      expect(find.text('Work address'), findsNothing);
    });

    testWidgets('validates through the enclosing Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpInApp(
        tester,
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Email',
            validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'a@b.com');
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Required'), findsNothing);
    });
  });

  group('AppTextField parameters a real form needs', () {
    testWidgets('forwards onChanged, and the form params reach the field', (
      tester,
    ) async {
      final changes = <String>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await pumpInApp(
        tester,
        AppTextField(
          label: 'Email',
          onChanged: changes.add,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode, same(focusNode));
      expect(field.textInputAction, TextInputAction.next);
      expect(field.autofillHints, contains(AutofillHints.email));

      await tester.enterText(find.byType(TextField), '12a3');
      await tester.pump();
      // The formatter is applied, so the callback sees the filtered value.
      expect(changes.last, '123');
    });

    testWidgets('disabled stops input', (tester) async {
      await pumpInApp(
        tester,
        const AppTextField(label: 'Email', enabled: false),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });
  });

  group('AppTextField.search', () {
    const colors = AppSearchFieldColors(
      fill: Color(0xFFFBFBFB),
      border: Color(0xFFD9D9D9),
      icon: Color(0xFF9CA3AF),
      text: Color(0xFF374151),
    );

    Future<List<String>> pumpSearch(
      WidgetTester tester,
      TextEditingController controller,
    ) async {
      final changes = <String>[];
      await pumpInApp(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppTextField.search(
            controller: controller,
            hint: 'بحث',
            clearTooltip: 'مسح البحث',
            onChanged: changes.add,
            searchColors: colors,
          ),
        ),
        locale: const Locale('ar'),
      );
      return changes;
    }

    testWidgets('draws a 40 box in a 48 touch target', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpSearch(tester, controller);

      final box = tester.getRect(find.byKey(AppTextField.searchBoxKey));
      final field = tester.getRect(find.byType(TextField));
      expect(box.height, AppSizes.searchFieldHeight);
      expect(field.height, kMinInteractiveDimension);
      expect(box.center, field.center);
      final decoration =
          tester
                  .widget<DecoratedBox>(find.byKey(AppTextField.searchBoxKey))
                  .decoration
              as BoxDecoration;
      expect(decoration.color, colors.fill);
      expect(decoration.borderRadius, BorderRadius.circular(10));
      expect(
        decorationOf(tester).hintStyle?.color,
        colors.text.withValues(alpha: .5),
      );
    });

    testWidgets('shows clear only with a query, and clearing reports it', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = await pumpSearch(tester, controller);
      expect(find.byTooltip('مسح البحث'), findsNothing);

      await tester.enterText(find.byType(TextField), 'وقود');
      await tester.pump();
      expect(find.byTooltip('مسح البحث'), findsOneWidget);
      final clear = tester.getRect(find.byTooltip('مسح البحث'));
      final box = tester.getRect(find.byKey(AppTextField.searchBoxKey));
      expect(clear.top, greaterThanOrEqualTo(box.top - 4));

      await tester.tap(find.byTooltip('مسح البحث'));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(changes, ['وقود', '']);
      expect(find.byTooltip('مسح البحث'), findsNothing);
    });
  });
}
