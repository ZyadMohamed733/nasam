import 'package:flutter/material.dart';

/// The playback screen's date range, as whole days, from a deep link.
///
/// The range arrives as `?from=&to=` ISO dates that anyone can edit, and the
/// date picker asserts if it is opened on a date outside its bounds — so an
/// unchecked link could crash the screen. Every value is clamped here instead:
/// missing, unparseable, in the future, or older than the picker allows falls
/// back to today, and a `to` before `from` is pulled up to `from`.
@immutable
class PlaybackRange {
  const PlaybackRange._(this.from, this.to);

  /// Parses the query values against [now] (defaulting to the clock).
  factory PlaybackRange.fromQuery({String? from, String? to, DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final start = _parse(from, today);
    final end = _parse(to, today);
    return PlaybackRange._(start, end.isBefore(start) ? start : end);
  }

  /// Today only — what the screen shows with no range in the link.
  factory PlaybackRange.today({DateTime? now}) =>
      PlaybackRange.fromQuery(now: now);

  /// How far back the picker reaches, as a whole day.
  static const lookback = Duration(days: 365);

  /// The picker's bounds for [today]. The page uses these, so the picker and
  /// the parser can never disagree about what is in range.
  static DateTime earliest(DateTime today) =>
      DateUtils.dateOnly(today).subtract(lookback);

  final DateTime from;
  final DateTime to;

  static DateTime _parse(String? raw, DateTime today) {
    final parsed = raw == null ? null : DateTime.tryParse(raw.trim());
    if (parsed == null) return today;
    final day = DateUtils.dateOnly(parsed);
    if (day.isAfter(today) || day.isBefore(earliest(today))) return today;
    return day;
  }

  @override
  bool operator ==(Object other) =>
      other is PlaybackRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'PlaybackRange($from → $to)';
}
