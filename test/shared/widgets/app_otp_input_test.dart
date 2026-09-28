import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/app_otp_input.dart';
import 'package:pinput/pinput.dart';

import '../../helpers/widget_harness.dart';

void main() {
  group('AppOtpInput', () {
    // Pinput presents the code as one field and draws the boxes itself, so
    // these reach for its editable rather than for a box.
    Finder editable() => find.descendant(
      of: find.byType(Pinput),
      matching: find.byType(EditableText),
    );

    // Teardown matters here: the countdown is a periodic timer, and a test
    // that leaves one pending fails the whole file.
    Future<void> unmount(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    testWidgets('asks Pinput for one box per digit', (tester) async {
      await pumpInApp(tester, const AppOtpInput(length: 4));
      expect(tester.widget<Pinput>(find.byType(Pinput)).length, 4);
      await unmount(tester);
    });

    testWidgets('reports the code once every box is filled', (tester) async {
      String? completed;
      final changes = <String>[];
      await pumpInApp(
        tester,
        AppOtpInput(
          length: 4,
          onChanged: changes.add,
          onCompleted: (v) => completed = v,
        ),
      );

      await tester.enterText(editable(), '12');
      await tester.pump();
      expect(completed, isNull, reason: 'not complete yet');
      expect(changes.last, '12');

      await tester.enterText(editable(), '1234');
      await tester.pump();
      expect(completed, '1234');
      await unmount(tester);
    });

    // A code reads and fills left to right in both languages; only the text
    // around the boxes follows the locale.
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('boxes run left to right (${locale.languageCode})', (
        tester,
      ) async {
        await pumpInApp(tester, const AppOtpInput(length: 4), locale: locale);

        await tester.enterText(editable(), '1234');
        await tester.pump();

        final xs = [
          for (final digit in ['1', '2', '3', '4'])
            tester.getCenter(find.text(digit)).dx,
        ];
        expect(xs, orderedEquals([...xs]..sort()), reason: '1 is leftmost');
        final row = find.ancestor(
          of: find.byType(Pinput),
          matching: find.byType(Directionality),
        );
        expect(
          tester.widget<Directionality>(row.first).textDirection,
          TextDirection.ltr,
        );
        // The rest of the block keeps the page's direction.
        expect(
          Directionality.of(tester.element(find.byType(AppOtpInput))),
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        await unmount(tester);
      });
    }

    // Pinput ships with no input formatters, so without ours a paste or a
    // hardware keyboard puts letters in a numeric code.
    testWidgets('rejects non-digits', (tester) async {
      final changes = <String>[];
      await pumpInApp(tester, AppOtpInput(length: 4, onChanged: changes.add));

      await tester.enterText(editable(), 'a1b2');
      await tester.pump();

      expect(changes.last, '12');
      await unmount(tester);
    });

    testWidgets('counts down and takes its duration from the caller', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const AppOtpInput(validity: Duration(seconds: 90)),
        locale: const Locale('ar'),
      );

      expect(find.textContaining('01:30'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('01:29'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('says so when the code expires', (tester) async {
      await pumpInApp(
        tester,
        const AppOtpInput(validity: Duration(seconds: 2)),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('The code has expired.'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('resending restarts the countdown', (tester) async {
      var resends = 0;
      await pumpInApp(
        tester,
        AppOtpInput(
          validity: const Duration(seconds: 30),
          onResend: () => resends++,
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      expect(find.textContaining('00:25'), findsOneWidget);

      await tester.tap(find.text('Resend code'));
      await tester.pump();

      expect(resends, 1);
      expect(find.textContaining('00:30'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('the resend action is disabled without a handler', (
      tester,
    ) async {
      await pumpInApp(tester, const AppOtpInput());
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
      await unmount(tester);
    });

    testWidgets('renders the submit action between countdown and resend', (
      tester,
    ) async {
      await pumpInApp(tester, const AppOtpInput(action: Text('SUBMIT')));

      final submitY = tester.getTopLeft(find.text('SUBMIT')).dy;
      final resendY = tester.getTopLeft(find.text('Resend code')).dy;
      expect(submitY, lessThan(resendY));
      await unmount(tester);
    });
  });
}
