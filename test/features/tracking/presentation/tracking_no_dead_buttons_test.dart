import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_summary.dart';

import '../../../helpers/fake_map_platform.dart';
import '../../../helpers/tracking_screen.dart';

class _MockRouter extends Mock implements GoRouter {}

/// Every control a user can activate on the tracking screen must do
/// something they can observe. Enabled-but-inert controls are the bug this
/// guards: each one is found through the semantics tree — what a screen
/// reader offers — activated on a fresh screen, and checked for an effect.
void main() {
  for (final drawerOpen in [false, true]) {
    testWidgets(
      'no enabled control is a no-op, drawer ${drawerOpen ? 'open' : 'closed'}',
      (tester) async {
        final semantics = tester.ensureSemantics();
        late FakeMapPlatform platform;
        final pushes = <String>[];
        final router = _MockRouter();
        when(
          () => router.push<Object?>(any(), extra: any(named: 'extra')),
        ).thenAnswer((invocation) async {
          pushes.add(invocation.positionalArguments.first as String);
          return null;
        });

        /// Everything a tap could change that the user would see.
        String observable() {
          final root = RendererBinding
              .instance
              .renderViews
              .first
              .owner!
              .semanticsOwner!
              .rootSemanticsNode!;
          final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
          final drawer = tester.widget<AdvancedDrawer>(
            find.byType(AdvancedDrawer),
          );
          return [
            root
                .toStringDeep(
                  childOrder: DebugSemanticsDumpOrder.traversalOrder,
                )
                .replaceAll(RegExp(r'SemanticsNode#\d+'), 'node'),
            pushes.length,
            platform.cameraMoves.length,
            map.mapType,
            drawer.controller!.value.visible,
          ].join('\n');
        }

        Future<List<SemanticsNode>> freshScreen() async {
          platform = FakeMapPlatform(createsMap: true);
          await tester.pumpWidget(const SizedBox());
          await pumpTrackingScreen(
            tester,
            size: const Size(402, 874),
            platform: platform,
            wrap: (screen) =>
                InheritedGoRouter(goRouter: router, child: screen),
          );
          await tester.tap(
            find.descendant(
              of: find.byType(TrackingSummary),
              matching: find.text('Show'),
            ),
          );
          await tester.pumpAndSettle();
          if (drawerOpen) {
            tester
                .widget<AdvancedDrawer>(find.byType(AdvancedDrawer))
                .controller!
                .showDrawer();
            await tester.pumpAndSettle();
          }
          platform.cameraMoves.clear();
          return find.semantics
              .byAction(SemanticsAction.tap)
              .evaluate()
              .where(
                // Re-selecting what is already selected changes nothing, and
                // should not.
                (node) =>
                    node.getSemanticsData().flagsCollection.isSelected !=
                    Tristate.isTrue,
              )
              .toList();
        }

        final total = (await freshScreen()).length;
        expect(total, greaterThan(drawerOpen ? 0 : 10), reason: 'built');

        final inert = <String>[];
        for (var i = 0; i < total; i++) {
          final node = (await freshScreen())[i];
          final label = node.getSemanticsData().label;
          final before = observable();
          tester.semantics.performAction(
            find.semantics.byPredicate((n) => n.id == node.id),
            SemanticsAction.tap,
          );
          // A fixed pump, not a settle: signing out shows a spinner until
          // the router — absent here — moves the user on.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          if (observable() == before) inert.add(label.isEmpty ? '#$i' : label);
        }

        expect(inert, isEmpty, reason: 'enabled controls that did nothing');
        semantics.dispose();
      },
    );
  }
}
