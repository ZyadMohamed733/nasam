import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/play_back/presentation/widgets/playback_date_picker_sheet.dart';

import '../../../helpers/widget_harness.dart';

Future<void> pumpPicker(WidgetTester tester, Locale locale) => pumpInApp(
  tester,
  PlaybackDatePickerSheet(
    title: 'Choose day',
    initialDate: DateTime(2026, 10, 13),
    firstDate: DateTime(2026),
    lastDate: DateTime(2026, 12, 31),
  ),
  locale: locale,
);

void main() {
  // October 2026: the 13th is a Tuesday, the 17th a Saturday, the 18th a
  // Sunday. Each appears once in the six-week grid.
  final days = {'13': 'Tue', '17': 'Sat', '18': 'Sun'};

  testWidgets('each day sits under its own weekday', (tester) async {
    await pumpPicker(tester, const Locale('en'));
    for (final MapEntry(key: day, value: weekday) in days.entries) {
      expect(
        tester.getCenter(find.text(day)).dx,
        moreOrLessEquals(tester.getCenter(find.text(weekday)).dx, epsilon: 1),
        reason: '$day October 2026 is a $weekday',
      );
    }
  });

  testWidgets('Arabic: the week runs Sunday to Saturday from the right', (
    tester,
  ) async {
    await pumpPicker(tester, const Locale('ar'));
    final sunday = tester.getCenter(find.text('١٨')).dx;
    final saturday = tester.getCenter(find.text('١٧')).dx;
    final tuesday = tester.getCenter(find.text('١٣')).dx;
    // Sunday is the right-most column, Saturday the left-most.
    expect(sunday, greaterThan(tuesday));
    expect(tuesday, greaterThan(saturday));
    expect(
      sunday,
      moreOrLessEquals(tester.getCenter(find.text('الأحد')).dx, epsilon: 1),
    );
  });
}
