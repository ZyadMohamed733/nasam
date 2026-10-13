import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/map_sheet_header.dart';

/// A picked range as wall-clock times: `from` at its start time, `to` at
/// its end time.
typedef AlertDateRange = ({DateTime from, DateTime to});

/// The custom range picker ("Date & Time pickers", `988-17176`): two months,
/// a tap for the first day and a tap for the last, and a time for each end
/// chosen with the platform time picker.
///
/// [today] is the last selectable day — alerts are history. Returns the
/// range on Save, or null when dismissed.
Future<AlertDateRange?> showAlertDateRangePicker(
  BuildContext context, {
  required DateTime today,
  DateTime? from,
  DateTime? to,
}) => showModalBottomSheet<AlertDateRange>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colorScheme.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
  ),
  builder: (context) =>
      AlertDateRangePickerSheet(today: today, from: from, to: to),
);

class AlertDateRangePickerSheet extends StatefulWidget {
  const AlertDateRangePickerSheet({
    super.key,
    required this.today,
    this.from,
    this.to,
    this.pickTime = _platformTimePicker,
  });

  /// The last selectable day; only its date is read.
  final DateTime today;
  final DateTime? from;
  final DateTime? to;

  /// Opens a time picker; replaceable in tests.
  final Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initial)
  pickTime;

  /// The story sets no limit on how far back; the calendar needs a first
  /// month.
  static final DateTime firstDay = DateTime(2000);

  static const double dayHeight = 36;
  static const double dayCircle = 34;

  static const saveKey = ValueKey('alert-range-save');
  static const cancelKey = ValueKey('alert-range-cancel');
  static const todayKey = ValueKey('alert-range-today');
  static const fromTimeKey = ValueKey('alert-range-from-time');
  static const toTimeKey = ValueKey('alert-range-to-time');
  static const previousKey = ValueKey('alert-range-previous');
  static const nextKey = ValueKey('alert-range-next');

  static ValueKey<String> dayKey(DateTime day) =>
      ValueKey('alert-range-day-${day.year}-${day.month}-${day.day}');

  static Future<TimeOfDay?> _platformTimePicker(
    BuildContext context,
    TimeOfDay initial,
  ) => showTimePicker(context: context, initialTime: initial);

  @override
  State<AlertDateRangePickerSheet> createState() =>
      _AlertDateRangePickerSheetState();
}

class _AlertDateRangePickerSheetState extends State<AlertDateRangePickerSheet> {
  late final DateTime _today = DateUtils.dateOnly(widget.today);
  late DateTime? _start = _day(widget.from);
  late DateTime? _end = _day(widget.to);
  late TimeOfDay _startTime = widget.from == null
      ? const TimeOfDay(hour: 0, minute: 0)
      : TimeOfDay.fromDateTime(widget.from!);
  late TimeOfDay _endTime = widget.to == null
      ? const TimeOfDay(hour: 23, minute: 59)
      : TimeOfDay.fromDateTime(widget.to!);

  /// The lower of the two months shown; the upper is the one before it.
  late DateTime _month = _monthOf(_end ?? _start ?? _today);

  static DateTime? _day(DateTime? value) =>
      value == null ? null : DateUtils.dateOnly(value);

  static DateTime _monthOf(DateTime day) => DateTime(day.year, day.month);

  DateTime get _lastMonth => _monthOf(_today);

  /// The first month the pair can start with, so the upper month is never
  /// before [AlertDateRangePickerSheet.firstDay].
  DateTime get _firstLowerMonth {
    final first = AlertDateRangePickerSheet.firstDay;
    return DateTime(first.year, first.month + 1);
  }

  void _moveMonths(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  void _tapDay(DateTime day) => setState(() {
    final start = _start;
    if (start == null || _end != null || day.isBefore(start)) {
      _start = day;
      _end = null;
    } else {
      _end = day;
    }
  });

  DateTime get _rangeEnd => _end ?? _start!;

  DateTime _at(DateTime day, TimeOfDay time) =>
      DateTime(day.year, day.month, day.day, time.hour, time.minute);

  bool get _valid {
    final start = _start;
    if (start == null) return false;
    return !_at(_rangeEnd, _endTime).isBefore(_at(start, _startTime));
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await widget.pickTime(
      context,
      start ? _startTime : _endTime,
    );
    if (picked == null || !mounted) return;
    setState(() => start ? _startTime = picked : _endTime = picked);
  }

  void _save() => Navigator.of(context).pop<AlertDateRange>((
    from: _at(_start!, _startTime),
    to: _at(_rangeEnd, _endTime),
  ));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final hasRange = _start != null;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.p16,
          0,
          AppSizes.p16,
          AppSizes.p16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MapSheetHandle(color: s.divider),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l.playbackChooseDay,
                      style: AppTextStyles.bodyMB.copyWith(color: s.textColor),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  key: AlertDateRangePickerSheet.todayKey,
                  onPressed: () => setState(() => _month = _lastMonth),
                  // The theme's buttons are full width; this one hugs its
                  // label in the header row.
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, AppSizes.iconButtonMedium),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p12,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_downward, size: AppSizes.iconSm),
                  label: Text(
                    l.alertFilterToday,
                    style: AppTextStyles.bodySR.copyWith(color: s.textColor),
                  ),
                ),
                IconButton(
                  key: AlertDateRangePickerSheet.cancelKey,
                  tooltip: l.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: s.iconSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p8),
            for (final (index, month) in [
              DateTime(_month.year, _month.month - 1),
              _month,
            ].indexed) ...[
              if (index > 0) const SizedBox(height: AppSizes.p12),
              _MonthCard(
                month: month,
                today: _today,
                start: _start,
                end: _end,
                onTapDay: _tapDay,
                // Each card moves the pair, so both can page.
                onPrevious: _month.isAfter(_firstLowerMonth)
                    ? () => _moveMonths(-1)
                    : null,
                onNext: _month.isBefore(_lastMonth)
                    ? () => _moveMonths(1)
                    : null,
                showNavigationKeys: index == 0,
              ),
            ],
            const SizedBox(height: AppSizes.p16),
            Text(
              l.playbackTime,
              style: AppTextStyles.bodyMB.copyWith(color: s.textColor),
            ),
            const SizedBox(height: AppSizes.p8),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    key: AlertDateRangePickerSheet.fromTimeKey,
                    label: l.alertFilterFrom,
                    time: _startTime,
                    onTap: () => _pickTime(start: true),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: _TimeField(
                    key: AlertDateRangePickerSheet.toTimeKey,
                    label: l.alertFilterTo,
                    time: _endTime,
                    onTap: () => _pickTime(start: false),
                  ),
                ),
              ],
            ),
            if (hasRange && !_valid) ...[
              const SizedBox(height: AppSizes.p8),
              Text(
                l.alertFilterInvalidRange,
                style: AppTextStyles.bodySR.copyWith(color: s.failText),
              ),
            ],
            const SizedBox(height: AppSizes.p24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: AlertDateRangePickerSheet.saveKey,
                    label: l.save,
                    onPressed: _valid ? _save : null,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                IntrinsicWidth(
                  child: AppButton(
                    label: l.cancel,
                    variant: AppButtonVariant.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One month: its name between the paging arrows, the weekday row, then
/// the days. The range draws as a band with filled ends; today is ringed.
class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.today,
    required this.start,
    required this.end,
    required this.onTapDay,
    required this.onPrevious,
    required this.onNext,
    required this.showNavigationKeys,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime> onTapDay;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool showNavigationKeys;

  /// Sunday first, as the design's calendar is laid out.
  List<DateTime?> get _cells {
    final first = DateTime(month.year, month.month);
    final leading = first.weekday % 7;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final count = ((leading + days) / 7).ceil() * 7;
    return List.generate(count, (index) {
      final day = index - leading + 1;
      return day < 1 || day > days
          ? null
          : DateTime(month.year, month.month, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final locale = Localizations.localeOf(context);
    final arabic = locale.languageCode == 'ar';
    final material = MaterialLocalizations.of(context);
    final cells = _cells;
    // 4 Jan 2026 is a Sunday.
    final weekdays = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale.toString()).format(DateTime(2026, 1, 4 + i)),
    ];
    String digits(int value) => arabic ? '$value'.toArabicNumerals() : '$value';

    return Container(
      padding: const EdgeInsets.all(AppSizes.p8),
      decoration: BoxDecoration(
        color: s.infoValueSurface,
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                key: showNavigationKeys
                    ? AlertDateRangePickerSheet.previousKey
                    : null,
                tooltip: material.previousMonthTooltip,
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${DateFormat.MMMM(locale.toString()).format(month)} '
                  '${digits(month.year)}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMB.copyWith(color: s.textColor),
                ),
              ),
              IconButton(
                key: showNavigationKeys
                    ? AlertDateRangePickerSheet.nextKey
                    : null,
                tooltip: material.nextMonthTooltip,
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: [
              for (final name in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: AppTextStyles.captionS.copyWith(
                        color: s.textPlaceholder,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.p4),
          for (var week = 0; week < cells.length ~/ 7; week++)
            SizedBox(
              height: AlertDateRangePickerSheet.dayHeight,
              child: Row(
                children: [
                  for (var weekday = 0; weekday < 7; weekday++)
                    Expanded(
                      child: switch (cells[week * 7 + weekday]) {
                        final day? => _Day(
                          key: AlertDateRangePickerSheet.dayKey(day),
                          label: digits(day.day),
                          semanticsLabel: material.formatFullDate(day),
                          enabled: !day.isAfter(today),
                          isToday: DateUtils.isSameDay(day, today),
                          isEndpoint:
                              DateUtils.isSameDay(day, start) ||
                              DateUtils.isSameDay(day, end),
                          inRange: _inRange(day),
                          onTap: () => onTapDay(day),
                        ),
                        null => const SizedBox.shrink(),
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _inRange(DateTime day) {
    final start = this.start;
    final end = this.end;
    if (start == null || end == null) return false;
    return !day.isBefore(start) && !day.isAfter(end);
  }
}

class _Day extends StatelessWidget {
  const _Day({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.enabled,
    required this.isToday,
    required this.isEndpoint,
    required this.inRange,
    required this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final bool enabled;
  final bool isToday;
  final bool isEndpoint;
  final bool inRange;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final scheme = context.colorScheme;
    final foreground = isEndpoint
        ? s.primaryButtonText
        : enabled
        ? s.textColor
        : s.textPlaceholder.withValues(alpha: .5);
    return Semantics(
      button: true,
      enabled: enabled,
      selected: isEndpoint || inRange,
      label: semanticsLabel,
      excludeSemantics: true,
      child: ColoredBox(
        color: inRange ? scheme.primaryContainer : Colors.transparent,
        child: Center(
          child: SizedBox.square(
            dimension: AlertDateRangePickerSheet.dayCircle,
            child: Material(
              color: isEndpoint
                  ? s.primaryButtonBackground
                  : Colors.transparent,
              shape: CircleBorder(
                side: isToday && !isEndpoint
                    ? BorderSide(color: s.primaryButtonBackground)
                    : BorderSide.none,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? onTap : null,
                child: Center(
                  child: Text(
                    label,
                    style:
                        (isEndpoint
                                ? AppTextStyles.bodyMB
                                : AppTextStyles.bodyMR)
                            .copyWith(color: foreground),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled time that opens the time picker.
class _TimeField extends StatelessWidget {
  const _TimeField({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final formatted = MaterialLocalizations.of(context).formatTimeOfDay(time);
    final radius = BorderRadius.circular(AppSizes.r8);
    return Semantics(
      button: true,
      label: '$label $formatted',
      excludeSemantics: true,
      child: Material(
        color: s.pageBackground,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: s.containerBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
              child: Row(
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySR.copyWith(
                      color: s.textPlaceholder,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatted,
                    style: AppTextStyles.bodyMB.copyWith(color: s.textColor),
                  ),
                  const SizedBox(width: AppSizes.p8),
                  Icon(
                    Icons.schedule,
                    size: AppSizes.iconSm,
                    color: s.iconSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
