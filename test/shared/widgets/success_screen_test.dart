import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/success_confetti.dart';
import 'package:nasam/shared/widgets/success_screen.dart';

import '../../helpers/widget_harness.dart';

void main() {
  testWidgets('supports non-auth copy, artwork and caller-owned action', (
    tester,
  ) async {
    var calls = 0;
    await pumpInApp(
      tester,
      SuccessScreen(
        title: 'Subscription activated',
        message: 'Your plan is ready.',
        actionLabel: 'View subscription',
        onAction: () => calls++,
        icon: const Icon(
          Icons.workspace_premium,
          key: ValueKey('custom-success'),
        ),
        showConfetti: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subscription activated'), findsOneWidget);
    expect(find.text('Your plan is ready.'), findsOneWidget);
    expect(find.byKey(const ValueKey('custom-success')), findsOneWidget);
    expect(find.byType(SuccessConfetti), findsNothing);
    await tester.tap(find.text('View subscription'));
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
