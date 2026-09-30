import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/hit_target.dart';

/// A 20×20 tap counter — a control drawn below the 48 minimum.
class _Dot extends StatelessWidget {
  const _Dot(this.onTap, {super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: const SizedBox.square(dimension: 20),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

void main() {
  const dot = ValueKey('dot');

  testWidgets('a touch in the 48 square reaches the control even past a '
      'parent too small to contain it', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      HitTargetScope(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            // The row is only 20 tall; the square reaches 14 above and below.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HitTargetExtender(child: _Dot(() => taps++, key: dot)),
              ],
            ),
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(dot));
    expect(rect.size, const Size(20, 20), reason: 'no layout change');

    await tester.tapAt(rect.center.translate(0, -23));
    await tester.tapAt(rect.center.translate(23, 23));
    expect(taps, 2);

    await tester.tapAt(rect.center.translate(0, -25));
    await tester.tapAt(rect.center.translate(25, 0));
    expect(taps, 2, reason: 'outside the 48 square');
  });

  testWidgets('does not take touches from a drawn control painted over its '
      'square', (tester) async {
    var dotTaps = 0, fieldTaps = 0;
    await _pump(
      tester,
      HitTargetScope(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HitTargetExtender(child: _Dot(() => dotTaps++, key: dot)),
            const SizedBox(height: 4),
            // Starts 4 below the dot: inside its square.
            HitTargetExtender.obstacle(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => fieldTaps++,
                child: const SizedBox(width: 100, height: 40),
              ),
            ),
          ],
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(dot));
    await tester.tapAt(rect.bottomCenter.translate(0, 6));
    expect((dotTaps, fieldTaps), (0, 1));
    await tester.tapAt(rect.bottomCenter.translate(0, 2));
    expect((dotTaps, fieldTaps), (1, 1), reason: 'the gap is still the dot');
  });

  testWidgets('takes touches over a control painted under it', (tester) async {
    var dotTaps = 0, rowTaps = 0;
    await _pump(
      tester,
      HitTargetScope(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              HitTargetExtender.obstacle(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => rowTaps++,
                  child: const SizedBox(width: 200, height: 44),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: HitTargetExtender(
                  child: _Dot(() => dotTaps++, key: dot),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(dot));
    await tester.tapAt(rect.centerLeft.translate(-12, 0));
    expect((dotTaps, rowTaps), (1, 0));
    await tester.tapAt(rect.centerLeft.translate(-20, 0));
    expect((dotTaps, rowTaps), (1, 1));
  });

  testWidgets('where two squares overlap, the nearer control wins', (
    tester,
  ) async {
    var first = 0, second = 0;
    await _pump(
      tester,
      HitTargetScope(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HitTargetExtender(child: _Dot(() => first++, key: dot)),
              const SizedBox(width: 20),
              HitTargetExtender(child: _Dot(() => second++)),
            ],
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(dot));
    await tester.tapAt(rect.centerRight.translate(8, 0));
    await tester.tapAt(rect.centerRight.translate(12, 0));
    expect((first, second), (1, 1));
  });

  testWidgets('reports the 48 square as the merged semantics node', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      HitTargetScope(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: HitTargetExtender(
            child: Semantics(
              button: true,
              label: 'Close',
              child: _Dot(() {}, key: dot),
            ),
          ),
        ),
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Close'));
    expect(node.rect.size, const Size(48, 48));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets('asserts when there is no scope to route its touches', (
    tester,
  ) async {
    await _pump(tester, HitTargetExtender(child: _Dot(() {})));
    expect(tester.takeException(), isAssertionError);
  });
}
