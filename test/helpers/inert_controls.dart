import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every tappable node in the semantics tree — what a screen reader offers —
/// except ones already selected, which re-selecting legitimately leaves
/// unchanged.
List<SemanticsNode> tappableNodes() => find.semantics
    .byAction(SemanticsAction.tap)
    .evaluate()
    .where(
      (node) =>
          node.getSemanticsData().flagsCollection.isSelected != Tristate.isTrue,
    )
    .toList();

/// Activates every tappable control on a freshly built screen, one per
/// rebuild, and returns the labels of those that changed nothing a user
/// could observe.
///
/// [fresh] builds the screen from scratch in the state under test.
/// [state] adds what the semantics tree cannot show — navigation logs,
/// camera moves, widget properties — to the before/after comparison.
Future<List<String>> findInertControls(
  WidgetTester tester, {
  required Future<void> Function() fresh,
  List<Object?> Function()? state,
}) async {
  String observable() {
    final root = RendererBinding
        .instance
        .renderViews
        .first
        .owner!
        .semanticsOwner!
        .rootSemanticsNode!;
    return [
      root
          .toStringDeep(childOrder: DebugSemanticsDumpOrder.traversalOrder)
          .replaceAll(RegExp(r'SemanticsNode#\d+'), 'node'),
      ...?state?.call(),
    ].join('\n');
  }

  await fresh();
  final total = tappableNodes().length;
  expect(total, greaterThan(0), reason: 'the screen offers no controls');

  final inert = <String>[];
  for (var i = 0; i < total; i++) {
    await fresh();
    final node = tappableNodes()[i];
    final label = node.getSemanticsData().label;
    final before = observable();
    tester.semantics.performAction(
      find.semantics.byPredicate((n) => n.id == node.id),
      SemanticsAction.tap,
    );
    // A fixed pump, not a settle: some effects (a sign-out spinner, a
    // playing timeline) never settle without the rest of the app.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    if (observable() == before) inert.add(label.isEmpty ? '#$i' : label);
  }
  return inert;
}
