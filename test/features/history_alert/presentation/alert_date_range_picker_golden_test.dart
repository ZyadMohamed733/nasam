@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/presentation/widget/alert_date_range_picker_sheet.dart';

import '../../../helpers/widget_harness.dart';

/// The custom range picker ("Date & Time pickers", `988-17176`) with a range
/// across two months chosen, on the 402×874 design frame, across
/// Arabic/English and light/dark. Generated and compared on macOS only.
///
/// Written to `goldens/alert_range_picker/<language>_<theme>.png`.
void main() {
  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      final file = '${language}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpInApp(
          tester,
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AlertDateRangePickerSheet(
                  today: DateTime(2026, 10, 13),
                  from: DateTime(2026, 9, 23),
                  to: DateTime(2026, 10, 7, 23, 59),
                ),
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
          matchesGoldenFile('goldens/alert_range_picker/$file.png'),
        );
      });
    }
  }
}
