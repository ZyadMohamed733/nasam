import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/app_otp_input.dart';

import '../../helpers/widget_harness.dart';

void main() {
  group('AppOtpInput', () {
    Finder boxAt(int i) => find
        .descendant(of: find.byType(AppOtpInput), matching: find.byType(TextField))
        .at(i);

    // Teardown matters here: the countdown is a periodic timer, and a test
    // that leaves one pending fails the whole file.
    Future<void> unmount(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    testWidgets('renders one box per digit', (tester) async {
      await pumpInApp(tester, const AppOtpInput(length: 4));
      expect(
        find.descendant(
          of: find.byType(AppOtpInput),
          matching: find.byType(TextField),
        ),
        findsNWidgets(4),
      );
      await unmount(tester);
    });

    testWidgets('typing a digit advances to the next box', (tester) async {
      await pumpInApp(tester, const AppOtpInput(length: 4));

      await tester.enterText(boxAt(0), '1');
      await tester.pump();

      expect(tester.widget<TextField>(boxAt(1)).focusNode?.hasFocus, isTrue);
      await unmount(tester);
    });

    testWidgets('reports the code once every box is filled', (tester) async {
      String? completed;
      await pumpInApp(
        tester,
        AppOtpInput(length: 4, onCompleted: (v) => completed = v),
      );

      for (var i = 0; i < 4; i++) {
        await tester.enterText(boxAt(i), '${i + 1}');
        await tester.pump();
      }

      expect(completed, '1234');
      await unmount(tester);
    });

    testWidgets('rejects non-digits', (tester) async {
      String? changed;
      await pumpInApp(
        tester,
        AppOtpInput(length: 4, onChanged: (v) => changed = v),
      );

      await tester.enterText(boxAt(0), 'a');
      await tester.pump();

      expect(changed ?? '', isEmpty);
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

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
      await unmount(tester);
    });
  });
}
