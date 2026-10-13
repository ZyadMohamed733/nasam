import 'history_alert.dart';

/// The quick date choices in the filter sheet. [custom] carries a range the
/// user picked; the others are resolved against the clock when applied.
enum AlertDatePreset { today, yesterday, last7Days, last30Days, custom }

/// What Alert History is narrowed to (NASAM-621).
///
/// Empty by default: the story applies no type and no date range until the
/// user picks one, so [none] is both the initial filter and what Reset
/// returns to.
class AlertHistoryFilter {
  const AlertHistoryFilter({this.type, this.datePreset, this.from, this.to})
    : assert(
        (datePreset == null) == (from == null && to == null),
        'A date preset and its bounds are set together.',
      );

  static const none = AlertHistoryFilter();

  /// Alerts are dated on the Saudi calendar until the company time zone
  /// comes from the API.
  static const Duration saudiUtcOffset = Duration(hours: 3);

  /// Null is "All".
  final AlertType? type;
  final AlertDatePreset? datePreset;

  /// Inclusive bounds, as UTC instants. Set exactly when [datePreset] is.
  final DateTime? from;
  final DateTime? to;

  bool get isActive => activeCount > 0;

  /// One per narrowing choice — the filter button's badge.
  int get activeCount => (type == null ? 0 : 1) + (datePreset == null ? 0 : 1);

  bool get hasValidRange {
    final from = this.from;
    final to = this.to;
    return from == null || to == null || !to.isBefore(from);
  }

  /// [preset]'s inclusive bounds around [now], counted in whole days on the
  /// calendar [utcOffset] ahead of UTC. "Last 7 days" is today and the six
  /// before it.
  static ({DateTime from, DateTime to}) rangeFor(
    AlertDatePreset preset,
    DateTime now, {
    Duration utcOffset = saudiUtcOffset,
  }) {
    final local = now.toUtc().add(utcOffset);
    final today = DateTime.utc(local.year, local.month, local.day);
    final (firstDay, lastDay) = switch (preset) {
      AlertDatePreset.today => (today, today),
      AlertDatePreset.yesterday => (_addDays(today, -1), _addDays(today, -1)),
      AlertDatePreset.last7Days => (_addDays(today, -6), today),
      AlertDatePreset.last30Days => (_addDays(today, -29), today),
      AlertDatePreset.custom => throw ArgumentError.value(
        preset,
        'preset',
        'A custom range is picked, not computed.',
      ),
    };
    return (
      from: firstDay.subtract(utcOffset),
      to: _addDays(
        lastDay,
        1,
      ).subtract(utcOffset).subtract(const Duration(milliseconds: 1)),
    );
  }

  /// The UTC instant of a wall-clock time read on the calendar [utcOffset]
  /// ahead of UTC — how a picked custom date becomes a bound.
  static DateTime instantOf(
    DateTime wallClock, {
    Duration utcOffset = saudiUtcOffset,
  }) => DateTime.utc(
    wallClock.year,
    wallClock.month,
    wallClock.day,
    wallClock.hour,
    wallClock.minute,
  ).subtract(utcOffset);

  /// Calendar arithmetic in UTC, so a day is always 24 hours.
  static DateTime _addDays(DateTime day, int days) =>
      DateTime.utc(day.year, day.month, day.day + days);

  AlertHistoryFilter withType(AlertType? type) => AlertHistoryFilter(
    type: type,
    datePreset: datePreset,
    from: from,
    to: to,
  );

  AlertHistoryFilter withDates(
    AlertDatePreset? preset, {
    DateTime? from,
    DateTime? to,
  }) => AlertHistoryFilter(type: type, datePreset: preset, from: from, to: to);

  @override
  bool operator ==(Object other) =>
      other is AlertHistoryFilter &&
      other.type == type &&
      other.datePreset == datePreset &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(type, datePreset, from, to);
}
