@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/presentation/widget/alert_history_filter_sheet.dart';

import '../../../helpers/widget_harness.dart';

/// The filter sheet ("Bottom Sheet Filter", `988-17176`) on the 402×874
/// design frame, empty and with a type and a date chosen, across
/// Arabic/English and light/dark. Generated and compared on macOS only.
///
/// Written to `goldens/alert_filter_sheet/<state>_<language>_<theme>.png`.
void main() {
  final now = DateTime.utc(2026, 10, 12, 22, 30);
  final week = AlertHistoryFilter.rangeFor(AlertDatePreset.last7Days, now);
  final states = {
    'empty': AlertHistoryFilter.none,
    'chosen': AlertHistoryFilter(
      type: AlertType.speed,
      datePreset: AlertDatePreset.last7Days,
      from: week.from,
      to: week.to,
    ),
  };

  for (final MapEntry(key: name, value: current) in states.entries) {
    for (final language in ['ar', 'en']) {
      for (final dark in [false, true]) {
        final file = '${name}_${language}_${dark ? 'dark' : 'light'}';
        testWidgets(file, (tester) async {
          await pumpInApp(
            tester,
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showAlertHistoryFilterSheet(
                  context,
                  current: current,
                  clock: () => now,
                ),
                child: const Text('open'),
              ),
            ),
            locale: Locale(language),
            dark: dark,
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/alert_filter_sheet/$file.png'),
          );
        });
      }
    }
  }
}
