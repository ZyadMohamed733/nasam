import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';

HistoryAlertEntity alertAt(DateTime at, {AlertType type = AlertType.speed}) =>
    HistoryAlertEntity(
      id: 'a',
      title: 'title',
      alertType: type,
      alertTypeLabel: type.name,
      assetName: 'asset',
      valueLabel: '',
      timestamp: at,
      location: '',
    );

void main() {
  // 01:30 on 13 Oct in Riyadh, still 12 Oct in UTC.
  final now = DateTime.utc(2026, 10, 12, 22, 30);

  group('rangeFor counts whole days on the Saudi calendar', () {
    test('today runs from Riyadh midnight to the last millisecond', () {
      final range = AlertHistoryFilter.rangeFor(AlertDatePreset.today, now);
      expect(range.from, DateTime.utc(2026, 10, 12, 21));
      expect(range.to, DateTime.utc(2026, 10, 13, 20, 59, 59, 999));
    });

    test('yesterday is the whole day before', () {
      final range = AlertHistoryFilter.rangeFor(AlertDatePreset.yesterday, now);
      expect(range.from, DateTime.utc(2026, 10, 11, 21));
      expect(range.to, DateTime.utc(2026, 10, 12, 20, 59, 59, 999));
    });

    test('last 7 and 30 days include today', () {
      final week = AlertHistoryFilter.rangeFor(AlertDatePreset.last7Days, now);
      expect(week.from, DateTime.utc(2026, 10, 6, 21));
      expect(week.to, DateTime.utc(2026, 10, 13, 20, 59, 59, 999));

      final month = AlertHistoryFilter.rangeFor(
        AlertDatePreset.last30Days,
        now,
      );
      expect(month.from, DateTime.utc(2026, 9, 13, 21));
      expect(month.to, week.to);
    });

    test('a custom range is not computed', () {
      expect(
        () => AlertHistoryFilter.rangeFor(AlertDatePreset.custom, now),
        throwsArgumentError,
      );
    });
  });

  test('instantOf reads a wall-clock time as Saudi time', () {
    expect(
      AlertHistoryFilter.instantOf(DateTime(2026, 10, 13, 9, 15)),
      DateTime.utc(2026, 10, 13, 6, 15),
    );
  });

  group('matches', () {
    final today = AlertHistoryFilter.rangeFor(AlertDatePreset.today, now);
    final filter = AlertHistoryFilter(
      type: AlertType.speed,
      datePreset: AlertDatePreset.today,
      from: today.from,
      to: today.to,
    );

    test('keeps an alert of the type inside the range, bounds included', () {
      expect(filter.matches(alertAt(today.from)), isTrue);
      expect(filter.matches(alertAt(today.to)), isTrue);
    });

    test('drops other types and alerts outside the range', () {
      expect(
        filter.matches(alertAt(today.from, type: AlertType.sensor)),
        isFalse,
      );
      expect(
        filter.matches(
          alertAt(today.from.subtract(const Duration(milliseconds: 1))),
        ),
        isFalse,
      );
      expect(
        filter.matches(alertAt(today.to.add(const Duration(milliseconds: 1)))),
        isFalse,
      );
    });

    test('none keeps everything', () {
      expect(AlertHistoryFilter.none.matches(alertAt(DateTime(2000))), isTrue);
    });
  });

  test('counts one badge per narrowing choice', () {
    expect(AlertHistoryFilter.none.activeCount, 0);
    expect(AlertHistoryFilter.none.isActive, isFalse);
    final typed = AlertHistoryFilter.none.withType(AlertType.downtime);
    expect(typed.activeCount, 1);
    final range = AlertHistoryFilter.rangeFor(AlertDatePreset.yesterday, now);
    final both = typed.withDates(
      AlertDatePreset.yesterday,
      from: range.from,
      to: range.to,
    );
    expect(both.activeCount, 2);
    expect(both.withType(null).withDates(null), AlertHistoryFilter.none);
  });

  test('a range that ends before it starts is invalid', () {
    final from = DateTime.utc(2026, 10, 13);
    final backwards = AlertHistoryFilter(
      datePreset: AlertDatePreset.custom,
      from: from,
      to: from.subtract(const Duration(minutes: 1)),
    );
    expect(backwards.hasValidRange, isFalse);
    expect(
      AlertHistoryFilter(
        datePreset: AlertDatePreset.custom,
        from: from,
        to: from,
      ).hasValidRange,
      isTrue,
    );
  });
}
