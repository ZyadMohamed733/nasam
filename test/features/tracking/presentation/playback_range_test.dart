import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/tracking/presentation/playback_range.dart';

void main() {
  final now = DateTime(2026, 9, 24, 15, 45);
  final today = DateTime(2026, 9, 24);

  PlaybackRange parse(String? from, String? to) =>
      PlaybackRange.fromQuery(from: from, to: to, now: now);

  test('a valid range is kept, as whole days', () {
    final range = parse('2026-09-01', '2026-09-10T18:00:00');
    expect(range.from, DateTime(2026, 9, 1));
    expect(range.to, DateTime(2026, 9, 10));
  });

  test('missing values fall back to today', () {
    expect(parse(null, null), PlaybackRange.today(now: now));
    expect(parse(null, null).from, today);
  });

  test('unparseable values fall back to today', () {
    final range = parse('yesterday', '2026-13-45');
    expect(range.from, today);
    expect(range.to, today);
  });

  // The date picker asserts when opened outside its bounds, so these must
  // never reach it.
  test('a future date falls back to today', () {
    expect(parse('2027-01-01', null).from, today);
  });

  test('a date older than the picker reaches falls back to today', () {
    expect(parse('2020-01-01', null).from, today);
    expect(
      parse('2025-09-24', null).from,
      PlaybackRange.earliest(today),
      reason: 'exactly a year back is the oldest valid day',
    );
  });

  test('a to before from is pulled up to from', () {
    final range = parse('2026-09-10', '2026-09-01');
    expect(range.from, DateTime(2026, 9, 10));
    expect(range.to, DateTime(2026, 9, 10));
  });
}
