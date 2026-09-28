import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_asset_card.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_map.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_summary.dart';
import 'package:nasam/shared/widgets/app_drawer.dart';

import '../../../helpers/tracking_screen.dart';

/// The sheet's asset search field; the drawer has its own.
Finder sheetSearch() => find.descendant(
  of: find.byType(TrackingSummary),
  matching: find.byType(TextField),
);

/// [text] inside the fleet sheet; the drawer repeats some of the labels.
Finder inSheet(String text) => find.descendant(
  of: find.byType(TrackingSummary),
  matching: find.text(text),
);

void main() {
  group('the collapsed sheet fits on 360×640', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      for (final scale in const [1.0, 1.5]) {
        testWidgets('${locale.languageCode} at text scale $scale', (
          tester,
        ) async {
          await pumpTrackingScreen(tester, textScale: scale, locale: locale);
          final l = lookupAppLocalizations(locale);

          expect(tester.takeException(), isNull, reason: 'no overflow');
          final sheet = tester.getRect(find.byType(TrackingSummary));
          final screen = tester.getRect(find.byType(TrackingMap));
          // The whole header is on screen, inside the sheet: title, toggle
          // and every chip row, not clipped at the bottom edge.
          for (final finder in [
            inSheet(l.trackingTitle),
            inSheet(l.trackingShow),
            inSheet(l.trackingAll),
            inSheet(l.trackingMoving),
          ]) {
            final rect = tester.getRect(finder);
            expect(rect.top, greaterThanOrEqualTo(sheet.top));
            expect(rect.bottom, lessThanOrEqualTo(screen.bottom));
          }
          expect(inSheet(l.trackingShow).hitTestable(), findsOneWidget);

          // And it opens without overflowing either.
          await tester.tap(inSheet(l.trackingShow));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(TrackingAssetCard), findsWidgets);
        });
      }
    }
  });

  group("the sheet's extent drives the map's bottom padding", () {
    double mapInset(WidgetTester tester) =>
        tester.widget<GoogleMap>(find.byType(GoogleMap)).padding.bottom;

    /// How much of the map the sheet covers, as laid out.
    double sheetCover(WidgetTester tester) =>
        tester.getRect(find.byType(TrackingMap)).bottom -
        tester.getRect(find.byType(TrackingSummary)).top;

    testWidgets('collapsed, open, and mid-drag', (tester) async {
      await pumpTrackingScreen(tester);
      final collapsed = mapInset(tester);
      expect(collapsed, moreOrLessEquals(sheetCover(tester), epsilon: 1));

      await tester.tap(inSheet('Show'));
      await tester.pumpAndSettle();
      final open = mapInset(tester);
      expect(open, moreOrLessEquals(sheetCover(tester), epsilon: 1));
      expect(open, greaterThan(collapsed));

      // Dragged part way, before it snaps: the padding follows the finger,
      // not the nearest resting size.
      final gesture = await tester.startGesture(
        tester.getCenter(inSheet('Tracking dashboard')),
      );
      await gesture.moveBy(const Offset(0, 60));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      final dragged = mapInset(tester);
      expect(dragged, moreOrLessEquals(sheetCover(tester), epsilon: 1));
      expect(dragged, lessThan(open));
      expect(dragged, greaterThan(collapsed));
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  testWidgets('a search that matches nothing offers Clear filters', (
    tester,
  ) async {
    await pumpTrackingScreen(tester);
    await tester.tap(inSheet('Show'));
    await tester.pumpAndSettle();
    final cards = tester.widgetList(find.byType(TrackingAssetCard)).length;
    expect(cards, greaterThan(0));

    await tester.enterText(sheetSearch(), 'no-such-asset-xyz');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(find.byType(TrackingAssetCard), findsNothing);
    expect(find.text('No assets match your search.'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('No assets match your search.'), findsNothing);
    expect(tester.widgetList(find.byType(TrackingAssetCard)).length, cards);
    expect(
      tester.widget<TextField>(sheetSearch()).controller!.text,
      isEmpty,
      reason: 'the typed text goes too',
    );
  });

  testWidgets("the drawer's Tracking dashboard entry closes the drawer", (
    tester,
  ) async {
    await pumpTrackingScreen(tester, size: const Size(402, 874));
    final drawer = tester.widget<AdvancedDrawer>(find.byType(AdvancedDrawer));
    drawer.controller!.showDrawer();
    await tester.pumpAndSettle();

    // This screen is the tracking dashboard: the entry is selected, and
    // tapping it takes the user back to it.
    final entry = find
        .descendant(
          of: find.byType(AppDrawer),
          matching: find.text('Tracking dashboard'),
        )
        .hitTestable();
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(drawer.controller!.value.visible, isFalse);
  });
}
