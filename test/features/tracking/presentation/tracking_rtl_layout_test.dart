import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_controls.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_map.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_summary.dart';

import '../../../helpers/tracking_screen.dart';

/// The menu, the tool column and the room the map keeps for it all sit on
/// the start side: the left in English, the right in Arabic.
void main() {
  for (final (locale, rtl) in const [
    (Locale('en'), false),
    (Locale('ar'), true),
  ]) {
    group(locale.languageCode, () {
      testWidgets('the tool column and the map padding follow the start side', (
        tester,
      ) async {
        await pumpTrackingScreen(tester, locale: locale);
        final screen = tester.getRect(find.byType(TrackingMap));

        final menu = tester.getCenter(
          find.byWidgetPredicate((w) => w is TrackingIconButton && w.menu),
        );
        final l = lookupAppLocalizations(locale);
        final layers = tester.getCenter(
          find.byWidgetPredicate(
            (w) => w is TrackingIconButton && w.label == l.trackingLayers,
          ),
        );
        bool onStart(Offset p) =>
            rtl ? p.dx > screen.center.dx : p.dx < screen.center.dx;
        expect(onStart(menu), isTrue, reason: 'menu');
        expect(onStart(layers), isTrue, reason: 'tool column');

        final padding = tester
            .widget<GoogleMap>(find.byType(GoogleMap))
            .padding;
        final start = rtl ? padding.right : padding.left;
        final end = rtl ? padding.left : padding.right;
        expect(start, TrackingMapLayout.toolColumnClearance);
        expect(end, TrackingMapLayout.edgeInset);
      });

      testWidgets('typed search text starts at the start edge', (tester) async {
        await pumpTrackingScreen(tester, locale: locale);
        await tester.tap(
          find.text(lookupAppLocalizations(locale).trackingShow),
        );
        await tester.pumpAndSettle();
        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TrackingSummary),
            matching: find.byType(TextField),
          ),
        );
        expect(field.textAlign, TextAlign.start);
      });
    });
  }
}
