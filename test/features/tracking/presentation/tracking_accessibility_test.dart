import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_asset_card.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_summary.dart';

import '../../../helpers/tracking_screen.dart';
import '../../../helpers/widget_harness.dart';

const _asset = TrackedAsset(
  id: 'AST-0017',
  name: 'Refrigerated truck 17',
  code: 'AST-0017',
  status: VehicleStatus.idle,
  assignedPerson: 'Aya Al-Rashidi',
  routeProgress: .4,
);

Future<void> _meetsAllGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('tracking screen, sheet collapsed, $theme', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpTrackingScreen(tester, dark: dark);
      await _meetsAllGuidelines(tester);
      semantics.dispose();
    });

    testWidgets('tracking screen, sheet open, $theme', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpTrackingScreen(tester, dark: dark);
      await tester.tap(
        find.descendant(
          of: find.byType(TrackingSummary),
          matching: find.text('Show'),
        ),
      );
      await tester.pumpAndSettle();
      await _meetsAllGuidelines(tester);
      semantics.dispose();
    });

    testWidgets('asset card, $theme', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpInApp(
        tester,
        const Padding(
          padding: EdgeInsets.all(16),
          child: TrackingAssetCard(asset: _asset),
        ),
        dark: dark,
      );
      await tester.pumpAndSettle();
      await _meetsAllGuidelines(tester);
      semantics.dispose();
    });
  }
}
