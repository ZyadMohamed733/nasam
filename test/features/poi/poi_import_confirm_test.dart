import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/app_status_tones.dart';
import 'package:nasam/features/poi/presentation/widgets/import/poi_import_confirm_view.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_stepper.dart';
import 'package:nasam/shared/widgets/app_summary_tile.dart';

import '../../helpers/poi_import_screen.dart';

void main() {
  Future<void> openConfirm(WidgetTester tester) async {
    final (cubit, _) = await pumpPoiImportPage(tester);
    await cubit.pick();
    await cubit.validate();
    cubit.preview();
    await cubit.confirm();
    await tester.pumpAndSettle();
  }

  testWidgets('every step done, no bottom bar', (tester) async {
    await openConfirm(tester);
    expect(tester.widget<AppStepper>(find.byType(AppStepper)).current, 4);
    expect(find.byIcon(Icons.check), findsNWidgets(4));
    expect(find.byKey(AppFormBottomBar.primaryKey), findsNothing);
  });

  testWidgets('four tiles from the real import, info first (the start)', (
    tester,
  ) async {
    await openConfirm(tester);
    final tiles = tester
        .widgetList<AppSummaryTile>(find.byType(AppSummaryTile))
        .toList();
    expect(
      [for (final t in tiles) (t.tone, t.value)],
      [
        (AppTone.info, 24),
        (AppTone.success, 20),
        (AppTone.danger, 3),
        (AppTone.warning, 1),
      ],
    );
    final first = tester.getRect(find.byWidget(tiles.first));
    final last = tester.getRect(find.byWidget(tiles.last));
    expect(first.left, greaterThan(last.left), reason: 'RTL');
  });

  testWidgets('the link is a brand-coloured text button', (tester) async {
    await openConfirm(tester);
    final link = tester.widget<AppButton>(
      find.byKey(PoiImportConfirmView.showOnMapKey),
    );
    expect(link.variant, AppButtonVariant.tertiary);
    expect(link.label, 'عرض النقاط على الخريطة');
    expect(link.labelColor, const Color(0xFF2E1F68));
  });
}
