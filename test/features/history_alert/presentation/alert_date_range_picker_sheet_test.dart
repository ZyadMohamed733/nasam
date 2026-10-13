import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/presentation/widget/alert_date_range_picker_sheet.dart';
import 'package:nasam/shared/widgets/app_button.dart';

import '../../../helpers/widget_harness.dart';

typedef Picker = AlertDateRangePickerSheet;

final today = DateTime(2026, 10, 13);

/// Opens the picker; the getter reads what it closed with.
Future<({AlertDateRange? result, bool closed}) Function()> openPicker(
  WidgetTester tester, {
  DateTime? from,
  DateTime? to,
  Locale locale = const Locale('en'),
  List<TimeOfDay>? times,
}) async {
  AlertDateRange? result;
  var closed = false;
  final queuedTimes = [...?times];
  await pumpInApp(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showModalBottomSheet<AlertDateRange>(
            context: context,
            isScrollControlled: true,
            builder: (_) => AlertDateRangePickerSheet(
              today: today,
              from: from,
              to: to,
              pickTime: (_, initial) async =>
                  queuedTimes.isEmpty ? initial : queuedTimes.removeAt(0),
            ),
          );
          closed = true;
        },
        child: const Text('open'),
      ),
    ),
    locale: locale,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => (result: result, closed: closed);
}

Future<void> tapDay(WidgetTester tester, DateTime day) async {
  final finder = find.byKey(Picker.dayKey(day));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(Picker.saveKey));
  await tester.tap(find.byKey(Picker.saveKey));
  await tester.pumpAndSettle();
}

bool isSelected(WidgetTester tester, DateTime day) =>
    tester
        .getSemantics(find.byKey(Picker.dayKey(day)))
        .flagsCollection
        .isSelected ==
    Tristate.isTrue;

void main() {
  testWidgets('shows last month and this month, nothing after today', (
    tester,
  ) async {
    await openPicker(tester);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    // The 14th is tomorrow: drawn, but not selectable.
    final tomorrow = DateTime(2026, 10, 14);
    expect(find.byKey(Picker.dayKey(tomorrow)), findsOneWidget);
    await tapDay(tester, tomorrow);
    final saveButton = tester.widget<AppButton>(find.byKey(Picker.saveKey));
    expect(saveButton.onPressed, isNull);
    // Already on the current month: no paging forward.
    final next = tester.widget<IconButton>(find.byKey(Picker.nextKey));
    expect(next.onPressed, isNull);
  });

  testWidgets('a first tap, a second tap: the whole days between', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final read = await openPicker(tester);
    await tapDay(tester, DateTime(2026, 9, 28));
    await tapDay(tester, DateTime(2026, 10, 3));
    expect(isSelected(tester, DateTime(2026, 9, 28)), isTrue);
    expect(isSelected(tester, DateTime(2026, 10, 1)), isTrue);
    expect(isSelected(tester, DateTime(2026, 10, 3)), isTrue);
    expect(isSelected(tester, DateTime(2026, 10, 4)), isFalse);
    await save(tester);
    expect(read().result, (
      from: DateTime(2026, 9, 28),
      to: DateTime(2026, 10, 3, 23, 59),
    ));
    handle.dispose();
  });

  testWidgets('one tap is a single day', (tester) async {
    final read = await openPicker(tester);
    await tapDay(tester, DateTime(2026, 10, 5));
    await save(tester);
    expect(read().result, (
      from: DateTime(2026, 10, 5),
      to: DateTime(2026, 10, 5, 23, 59),
    ));
  });

  testWidgets('a tap before the start, or after a full range, starts over', (
    tester,
  ) async {
    final read = await openPicker(tester);
    await tapDay(tester, DateTime(2026, 10, 5));
    await tapDay(tester, DateTime(2026, 10, 2));
    await tapDay(tester, DateTime(2026, 10, 8));
    await tapDay(tester, DateTime(2026, 10, 10));
    await save(tester);
    expect(read().result, (
      from: DateTime(2026, 10, 10),
      to: DateTime(2026, 10, 10, 23, 59),
    ));
  });

  testWidgets('each end takes its time from the time picker', (tester) async {
    final read = await openPicker(
      tester,
      times: const [
        TimeOfDay(hour: 8, minute: 30),
        TimeOfDay(hour: 17, minute: 15),
      ],
    );
    await tapDay(tester, DateTime(2026, 10, 1));
    await tapDay(tester, DateTime(2026, 10, 2));
    await tester.ensureVisible(find.byKey(Picker.fromTimeKey));
    await tester.tap(find.byKey(Picker.fromTimeKey));
    await tester.pump();
    await tester.tap(find.byKey(Picker.toTimeKey));
    await tester.pump();
    expect(find.text('8:30 AM'), findsOneWidget);
    expect(find.text('5:15 PM'), findsOneWidget);
    await save(tester);
    expect(read().result, (
      from: DateTime(2026, 10, 1, 8, 30),
      to: DateTime(2026, 10, 2, 17, 15),
    ));
  });

  testWidgets('one day ending before it starts cannot be saved', (
    tester,
  ) async {
    await openPicker(
      tester,
      times: const [
        TimeOfDay(hour: 18, minute: 0),
        TimeOfDay(hour: 9, minute: 0),
      ],
    );
    await tapDay(tester, DateTime(2026, 10, 1));
    await tester.ensureVisible(find.byKey(Picker.fromTimeKey));
    await tester.tap(find.byKey(Picker.fromTimeKey));
    await tester.pump();
    await tester.tap(find.byKey(Picker.toTimeKey));
    await tester.pump();
    expect(find.text('To Date must be on or after From Date.'), findsOneWidget);
    final saveButton = tester.widget<AppButton>(find.byKey(Picker.saveKey));
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('opens on a range already chosen, with its times', (
    tester,
  ) async {
    final read = await openPicker(
      tester,
      from: DateTime(2026, 8, 3, 6),
      to: DateTime(2026, 8, 9, 20, 45),
    );
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('6:00 AM'), findsOneWidget);
    expect(find.text('8:45 PM'), findsOneWidget);
    await save(tester);
    expect(read().result, (
      from: DateTime(2026, 8, 3, 6),
      to: DateTime(2026, 8, 9, 20, 45),
    ));
  });

  testWidgets('paging back shows the months before', (tester) async {
    await openPicker(tester);
    await tester.tap(find.byKey(Picker.previousKey));
    await tester.pump();
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('October 2026'), findsNothing);
  });

  testWidgets('"Today" is a label, not a button', (tester) async {
    final handle = tester.ensureSemantics();
    await openPicker(tester);
    final today = find.byKey(Picker.todayKey);
    expect(
      find.descendant(of: today, matching: find.text('Today')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: today, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      tester
          .getSemantics(today)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('Arabic: Arabic numerals, Sunday first from the right', (
    tester,
  ) async {
    await openPicker(tester, locale: const Locale('ar'));
    expect(find.text('١٣'), findsWidgets);
    // 4 Oct 2026 is a Sunday: the right-most day of its week.
    final sunday = tester.getRect(
      find.byKey(Picker.dayKey(DateTime(2026, 10, 4))),
    );
    final saturday = tester.getRect(
      find.byKey(Picker.dayKey(DateTime(2026, 10, 10))),
    );
    expect(sunday.top, saturday.top);
    expect(sunday.left, greaterThan(saturday.left));
  });

  testWidgets('cancel closes with nothing', (tester) async {
    final read = await openPicker(tester);
    await tapDay(tester, DateTime(2026, 10, 1));
    await tester.tap(find.byKey(Picker.cancelKey));
    await tester.pumpAndSettle();
    expect(read().closed, isTrue);
    expect(read().result, isNull);
  });
}
