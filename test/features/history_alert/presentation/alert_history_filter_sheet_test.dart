import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/presentation/widget/alert_history_filter_sheet.dart';
import 'package:nasam/shared/widgets/app_button.dart';

import '../../../helpers/widget_harness.dart';

typedef Sheet = AlertHistoryFilterSheet;

/// 01:30 on 13 Oct in Riyadh.
final now = DateTime.utc(2026, 10, 12, 22, 30);

/// Opens the sheet over [current]; the returned getter reads what it popped
/// with, and whether it popped at all.
Future<({AlertHistoryFilter? result, bool closed}) Function()> openSheet(
  WidgetTester tester, {
  AlertHistoryFilter current = AlertHistoryFilter.none,
  Locale locale = const Locale('ar'),
  CustomRangePicker? pickCustomRange,
}) async {
  AlertHistoryFilter? result;
  var closed = false;
  await pumpInApp(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showAlertHistoryFilterSheet(
            context,
            current: current,
            clock: () => now,
            pickCustomRange: pickCustomRange ?? pickAlertCustomRange,
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

bool isSelected(WidgetTester tester, Key key) =>
    tester.getSemantics(find.byKey(key)).flagsCollection.isSelected ==
    Tristate.isTrue;

void main() {
  testWidgets('shows the design copy, with Downtime and without Geofence', (
    tester,
  ) async {
    await openSheet(tester);
    for (final text in [
      'تصفية اداره التنبيهات',
      'اختاري التصفيه المطلوبه لعرض التنبيهات المرتبطه',
      'نوع التنبيه',
      'الكل',
      'سرعه',
      'حساس',
      'توقف',
      'التاريخ',
      'اليوم',
      'أمس',
      'اخر 7 ايام',
      'آخر 30 يوم',
      'تاريخ مخصص',
      'تطبيق',
      'إعادة تعيين',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('نطاق جغرافي'), findsNothing);
    expect(find.text('إلغاء'), findsNothing);
  });

  testWidgets('starts on All with no date, as the story has no default', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    expect(isSelected(tester, Sheet.allTypesKey), isTrue);
    for (final type in Sheet.types) {
      expect(isSelected(tester, Sheet.typeKey(type)), isFalse);
    }
    for (final preset in Sheet.presets) {
      expect(isSelected(tester, Sheet.presetKey(preset)), isFalse);
    }
    handle.dispose();
  });

  testWidgets('Apply returns the chosen type and the preset resolved to days', (
    tester,
  ) async {
    final read = await openSheet(tester);
    await tester.tap(find.byKey(Sheet.typeKey(AlertType.downtime)));
    await tester.tap(find.byKey(Sheet.presetKey(AlertDatePreset.last7Days)));
    await tester.pump();
    await tester.tap(find.byKey(Sheet.applyKey));
    await tester.pumpAndSettle();

    final range = AlertHistoryFilter.rangeFor(AlertDatePreset.last7Days, now);
    expect(
      read().result,
      AlertHistoryFilter(
        type: AlertType.downtime,
        datePreset: AlertDatePreset.last7Days,
        from: range.from,
        to: range.to,
      ),
    );
  });

  testWidgets('tapping the selected date again clears it', (tester) async {
    final today = AlertHistoryFilter.rangeFor(AlertDatePreset.today, now);
    final read = await openSheet(
      tester,
      current: AlertHistoryFilter(
        datePreset: AlertDatePreset.today,
        from: today.from,
        to: today.to,
      ),
    );
    await tester.tap(find.byKey(Sheet.presetKey(AlertDatePreset.today)));
    await tester.pump();
    await tester.tap(find.byKey(Sheet.applyKey));
    await tester.pumpAndSettle();
    expect(read().result, AlertHistoryFilter.none);
  });

  testWidgets('Reset clears every filter and closes', (tester) async {
    final read = await openSheet(
      tester,
      current: const AlertHistoryFilter(type: AlertType.sensor),
    );
    await tester.tap(find.byKey(Sheet.resetKey));
    await tester.pumpAndSettle();
    expect(read().closed, isTrue);
    expect(read().result, AlertHistoryFilter.none);
    expect(find.byType(Sheet), findsNothing);
  });

  testWidgets('dismissing changes nothing', (tester) async {
    final read = await openSheet(tester);
    await tester.tap(find.byKey(Sheet.typeKey(AlertType.speed)));
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(read().closed, isTrue);
    expect(read().result, isNull);
  });

  testWidgets('a custom range is read as Saudi time and shown', (tester) async {
    final read = await openSheet(
      tester,
      locale: const Locale('en'),
      pickCustomRange: (context, {from, to}) async =>
          (from: DateTime(2026, 10, 1, 8), to: DateTime(2026, 10, 2, 17, 30)),
    );
    await tester.tap(find.byKey(Sheet.presetKey(AlertDatePreset.custom)));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 Oct 2026, 08:00 AM'), findsOneWidget);
    await tester.tap(find.byKey(Sheet.applyKey));
    await tester.pumpAndSettle();

    final result = read().result!;
    expect(result.datePreset, AlertDatePreset.custom);
    expect(result.from, DateTime.utc(2026, 10, 1, 5));
    expect(result.to, DateTime.utc(2026, 10, 2, 14, 30, 59, 999));
  });

  testWidgets('a range ending before it starts cannot be applied', (
    tester,
  ) async {
    final read = await openSheet(
      tester,
      locale: const Locale('en'),
      pickCustomRange: (context, {from, to}) async =>
          (from: DateTime(2026, 10, 2), to: DateTime(2026, 10, 1)),
    );
    await tester.tap(find.byKey(Sheet.presetKey(AlertDatePreset.custom)));
    await tester.pumpAndSettle();
    expect(find.text('To Date must be on or after From Date.'), findsOneWidget);
    final apply = tester.widget<AppButton>(find.byKey(Sheet.applyKey));
    expect(apply.onPressed, isNull);
    expect(read().closed, isFalse);
  });

  testWidgets('choices are 36 tall in 16 gutters, the buttons 44', (
    tester,
  ) async {
    await openSheet(tester);
    final sheet = tester.getRect(find.byType(Sheet));
    final all = tester.getRect(find.byKey(Sheet.allTypesKey));
    expect(all.height, 36);
    // Arabic: the first choice sits at the right gutter.
    expect(all.right, sheet.right - 16);
    expect(tester.getSize(find.byKey(Sheet.applyKey)).height, 44);
    expect(tester.getSize(find.byKey(Sheet.resetKey)).height, 44);
    expect(tester.getRect(find.byKey(Sheet.applyKey)).right, sheet.right - 16);
  });

  testWidgets('meets the tap target and labelling guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
