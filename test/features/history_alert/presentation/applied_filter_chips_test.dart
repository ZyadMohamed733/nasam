import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/presentation/widget/applied_filter_chips.dart';
import 'package:nasam/features/history_alert/presentation/widget/search_bar_widget.dart';

import '../../../helpers/widget_harness.dart';

final now = DateTime.utc(2026, 10, 12, 22, 30);
final week = AlertHistoryFilter.rangeFor(AlertDatePreset.last7Days, now);
final speedThisWeek = AlertHistoryFilter(
  type: AlertType.speed,
  datePreset: AlertDatePreset.last7Days,
  from: week.from,
  to: week.to,
);

/// The search row and the chips under it, as the list page lays them out.
Widget header(
  AlertHistoryFilter filter, {
  ValueChanged<AlertHistoryFilter>? onChanged,
}) => SizedBox(
  width: 402,
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchBarWidget(
          controller: TextEditingController(),
          onSearchChanged: (_) {},
          onFilterPressed: () {},
          filterCount: filter.activeCount,
        ),
        const SizedBox(height: 8),
        AppliedFilterChips(filter: filter, onChanged: onChanged ?? (_) {}),
      ],
    ),
  ),
);

void main() {
  testWidgets('no filter: no chips and no badge', (tester) async {
    await pumpInApp(tester, header(AlertHistoryFilter.none));
    expect(find.byKey(AppliedFilterChips.typeKey), findsNothing);
    expect(find.byKey(AppliedFilterChips.dateKey), findsNothing);
    expect(find.byKey(SearchBarWidget.badgeKey), findsNothing);
  });

  testWidgets('a chip per filter, and the count on the filter button', (
    tester,
  ) async {
    await pumpInApp(tester, header(speedThisWeek), locale: const Locale('ar'));
    expect(
      find.descendant(
        of: find.byKey(AppliedFilterChips.typeKey),
        matching: find.text('سرعه'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(AppliedFilterChips.dateKey),
        matching: find.text('اخر 7 ايام'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(SearchBarWidget.badgeKey),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the badge sits on the button\'s top-end corner, the chips '
      'from the start', (tester) async {
    await pumpInApp(tester, header(speedThisWeek), locale: const Locale('ar'));
    final button = tester.getRect(find.byKey(SearchBarWidget.filterButtonKey));
    final badge = tester.getRect(find.byKey(SearchBarWidget.badgeKey));
    expect(badge.size, const Size.square(SearchBarWidget.badgeSize));
    // Arabic: the button's end is its left.
    expect(badge.center.dx, button.left + SearchBarWidget.badgeInset);
    expect(badge.center.dy, button.top + SearchBarWidget.badgeInset);

    final type = tester.getRect(find.byKey(AppliedFilterChips.typeKey));
    final date = tester.getRect(find.byKey(AppliedFilterChips.dateKey));
    expect(type.height, 28);
    expect(type.right, 402 - 12);
    expect(date.right, type.left - 8);
  });

  testWidgets('removing a chip drops only its filter', (tester) async {
    final changes = <AlertHistoryFilter>[];
    await pumpInApp(tester, header(speedThisWeek, onChanged: changes.add));
    await tester.tap(find.byKey(AppliedFilterChips.typeKey));
    await tester.tap(find.byKey(AppliedFilterChips.dateKey));
    expect(changes, [
      speedThisWeek.withType(null),
      const AlertHistoryFilter(type: AlertType.speed),
    ]);
  });

  testWidgets('a custom range reads as its first and last day', (tester) async {
    final custom = AlertHistoryFilter(
      datePreset: AlertDatePreset.custom,
      from: AlertHistoryFilter.instantOf(DateTime(2026, 10, 1, 8)),
      to: AlertHistoryFilter.instantOf(DateTime(2026, 10, 2, 17)),
    );
    await pumpInApp(tester, header(custom));
    expect(find.text('1 Oct – 2 Oct'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('chips are labelled buttons with full tap targets', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    // The chips alone: the search field above them is 44 tall, a known gap
    // outside this widget.
    await pumpInApp(
      tester,
      Padding(
        padding: const EdgeInsets.all(12),
        child: AppliedFilterChips(filter: speedThisWeek, onChanged: (_) {}),
      ),
    );
    expect(find.bySemanticsLabel('Remove filter: Speed'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
