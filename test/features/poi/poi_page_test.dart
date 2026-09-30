import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nasam/features/poi/presentation/pages/poi_page.dart';

import '../../helpers/poi_screen.dart';

void main() {
  const pump = pumpPoiPage;

  testWidgets(
    'Show expands, search filters, action sheets cancel and confirm deletion',
    (tester) async {
      final cubit = await pump(tester);
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).markers.length,
        4,
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Hide'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Manhole');
      await tester.pumpAndSettle();
      expect(cubit.state.visiblePoints.single.name, 'Manhole');
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).markers.length,
        1,
      );
      await tester.tap(find.byTooltip('Point of interest actions'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cubit.state.visiblePoints.single.name, 'Manhole');
      await tester.tap(find.byTooltip('Point of interest actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(cubit.state.visiblePoints, isEmpty);
      await tester.tap(find.bySemanticsLabel('Layers'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).mapType,
        MapType.hybrid,
      );
      expect(tester.takeException(), isNull);
    },
  );
  // The design frame, 402×874, collapsed (the design's own state: its
  // header link reads "عرض") and open.
  for (final (name, language, dark, scale) in const [
    ('ar', 'ar', false, 1.0),
    ('en', 'en', false, 1.0),
    ('ar_dark', 'ar', true, 1.0),
    ('ar_1.5', 'ar', false, 1.5),
  ]) {
    testWidgets('POI visual baseline $name', (tester) async {
      await pump(tester, language: language, dark: dark, scale: scale);
      await expectLater(
        find.byType(PoiPage),
        matchesGoldenFile('goldens/poi_landing_$name.png'),
      );
      await tester.tap(find.text(language == 'ar' ? 'عرض' : 'Show'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(PoiPage),
        matchesGoldenFile('goldens/poi_expanded_$name.png'),
      );
    });
  }
  for (final size in [
    const Size(320, 568),
    const Size(402, 874),
    const Size(800, 1024),
    const Size(844, 390),
  ]) {
    for (final language in ['ar', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('responsive $size $language dark=$dark enlarged text', (
          tester,
        ) async {
          await pump(
            tester,
            size: size,
            language: language,
            dark: dark,
            scale: 1.5,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(language == 'ar' ? 'عرض' : 'Show'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.enterText(find.byType(TextField), 'nothing');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
