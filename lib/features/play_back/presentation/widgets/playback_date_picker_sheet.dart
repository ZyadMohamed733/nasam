import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';

/// Custom date and time picker for playback, presented inside a modal sheet.
///
/// The constructor and result contract are kept stable: save pops the selected
/// [DateTime], while cancel and the close affordance pop `null`.
class PlaybackDatePickerSheet extends StatefulWidget {
  const PlaybackDatePickerSheet({
    super.key,
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<PlaybackDatePickerSheet> createState() =>
      _PlaybackDatePickerSheetState();
}

class _PlaybackDatePickerSheetState extends State<PlaybackDatePickerSheet> {
  late DateTime _selectedDate = widget.initialDate;
  late DateTime _visibleMonth = DateTime(
    widget.initialDate.year,
    widget.initialDate.month,
  );
  late bool _isPm = widget.initialDate.hour >= 12;
  late final TextEditingController _hourController = TextEditingController(
    text: _displayHour(widget.initialDate.hour),
  );
  late final TextEditingController _minuteController = TextEditingController(
    text: widget.initialDate.minute.toString().padLeft(2, '0'),
  );
  bool _arabicNumerals = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final useArabicNumerals =
        Localizations.localeOf(context).languageCode == 'ar';
    if (useArabicNumerals == _arabicNumerals) return;
    _arabicNumerals = useArabicNumerals;
    _hourController.text = _localizeNumerals(
      _hourController.text,
      useArabicNumerals,
    );
    _minuteController.text = _localizeNumerals(
      _minuteController.text,
      useArabicNumerals,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int get _firstMonth =>
      widget.firstDate.year * 12 + widget.firstDate.month - 1;
  int get _lastMonth => widget.lastDate.year * 12 + widget.lastDate.month - 1;
  int get _visibleMonthIndex =>
      _visibleMonth.year * 12 + _visibleMonth.month - 1;

  void _moveMonth(int amount) {
    final nextIndex = _visibleMonthIndex + amount;
    if (nextIndex < _firstMonth || nextIndex > _lastMonth) return;
    setState(() {
      _visibleMonth = DateTime(nextIndex ~/ 12, nextIndex % 12 + 1);
    });
  }

  Future<void> _selectYear() async {
    final years = List<int>.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );
    final selectedYear = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          return ListTile(
            selected: year == _visibleMonth.year,
            title: Text(_localizeNumerals(year.toString(), _arabicNumerals)),
            onTap: () => Navigator.of(context).pop(year),
          );
        },
      ),
    );
    if (selectedYear == null || !mounted) return;
    setState(() {
      final selectedMonth = _visibleMonth.month;
      final yearMonth = selectedYear * 12 + selectedMonth - 1;
      final clampedMonthIndex = yearMonth
          .clamp(_firstMonth, _lastMonth)
          .toInt();
      _visibleMonth = DateTime(
        clampedMonthIndex ~/ 12,
        clampedMonthIndex % 12 + 1,
      );
    });
  }

  List<DateTime> get _calendarDays {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    // Sunday first, as the design lays the week out; the rows follow the
    // text direction, so in Arabic Sunday is the right-most column.
    final leadingDays = firstOfMonth.weekday % 7;
    final firstCell = firstOfMonth.subtract(Duration(days: leadingDays));
    return List<DateTime>.generate(
      42,
      (index) => firstCell.add(Duration(days: index)),
    );
  }

  bool _isEnabled(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return !day.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
        !day.isAfter(DateUtils.dateOnly(widget.lastDate));
  }

  void _save() {
    final displayedHour =
        int.tryParse(_toWesternNumerals(_hourController.text)) ?? 12;
    final minute =
        int.tryParse(_toWesternNumerals(_minuteController.text)) ?? 0;
    final hour12 = displayedHour.clamp(1, 12).toInt();
    final hour24 = (hour12 % 12) + (_isPm ? 12 : 0);
    Navigator.of(context).pop(
      DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour24,
        minute.clamp(0, 59).toInt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final accent = scheme.primary;
    final muted = scheme.onSurfaceVariant;
    final monthName = DateFormat.MMMM(locale).format(_visibleMonth);
    final weekdays = List<DateTime>.generate(
      7,
      (index) => DateTime(2023, 12, 31 + index), // Sunday through Saturday.
    );
    final calendarDays = _calendarDays;

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 8.h, 12.w, 14.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              textDirection: ui.TextDirection.ltr,
              children: [
                IconButton(
                  tooltip: l.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: muted, size: 20.r),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              textDirection: ui.TextDirection.ltr,
              children: [
                InkWell(
                  onTap: _selectYear,
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _localizeNumerals(
                            _visibleMonth.year.toString(),
                            _arabicNumerals,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: muted,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18.r,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).previousMonthTooltip,
                  onPressed: _visibleMonthIndex > _firstMonth
                      ? () => _moveMonth(-1)
                      : null,
                  icon: Icon(
                    Icons.chevron_left,
                    size: 20.r,
                    textDirection: ui.TextDirection.ltr,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Text(monthName, style: theme.textTheme.bodyMedium),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
                  onPressed: _visibleMonthIndex < _lastMonth
                      ? () => _moveMonth(1)
                      : null,
                  icon: Icon(
                    Icons.chevron_right,
                    size: 20.r,
                    textDirection: ui.TextDirection.ltr,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        for (final day in weekdays)
                          Expanded(
                            child: Center(
                              child: Text(
                                DateFormat.E(locale).format(day),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  for (var week = 0; week < 6; week++)
                    SizedBox(
                      height: 36.h,
                      child: Row(
                        children: [
                          for (var weekday = 0; weekday < 7; weekday++)
                            Expanded(
                              child: _buildDay(
                                context,
                                date: calendarDays[week * 7 + weekday],
                                muted: muted,
                                accent: accent,
                                arabicNumerals: _arabicNumerals,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l.playbackTime, style: theme.textTheme.labelMedium),
            ),
            SizedBox(height: 5.h),
            _buildTimeInput(context, l),
            SizedBox(height: 12.h),
            Row(
              textDirection: ui.TextDirection.ltr,
              children: [
                Expanded(
                  flex: 1,
                  child: AppButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: l.cancel,
                    variant: AppButtonVariant.secondary,
                    height: 40.h,
                    labelStyle: theme.textTheme.labelMedium,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 5,
                  child: AppButton(
                    onPressed: _save,
                    label: l.save,
                    height: 40.h,
                    labelStyle: theme.textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(
    BuildContext context, {
    required DateTime date,
    required Color muted,
    required Color accent,
    required bool arabicNumerals,
  }) {
    final theme = Theme.of(context);
    final inMonth = date.month == _visibleMonth.month;
    final enabled = _isEnabled(date);
    final selected = DateUtils.isSameDay(date, _selectedDate);
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : !enabled || !inMonth
        ? muted.withValues(alpha: enabled ? 0.55 : 0.3)
        : theme.colorScheme.onSurface;

    return Center(
      child: SizedBox(
        width: 34.r,
        height: 34.r,
        child: Material(
          color: selected
              ? accent
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled
                ? () => setState(() {
                    _selectedDate = DateUtils.dateOnly(date);
                    if (!inMonth) {
                      _visibleMonth = DateTime(date.year, date.month);
                    }
                  })
                : null,
            child: Center(
              child: Text(
                _localizeNumerals(date.day.toString(), arabicNumerals),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // time
  Widget _buildTimeInput(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    final timeInputTheme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        bodyMedium: theme.textTheme.bodyLarge,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Theme(
        data: timeInputTheme,
        child: Row(
          textDirection: ui.TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _periodOption(context, label: l.morning, isPm: false),
                _periodOption(context, label: l.evening, isPm: true),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 36.w,
                    child: _timeField(context, _hourController, l.hour),
                  ),
                  Text(':', style: theme.textTheme.bodyLarge),
                  SizedBox(
                    width: 36.w,
                    child: _timeField(context, _minuteController, l.minute),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //_periodOption
  Widget _periodOption(
    BuildContext context, {
    required String label,
    required bool isPm,
  }) {
    final selected = _isPm == isPm;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(4.r),
      onTap: () => setState(() => _isPm = isPm),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(7.w, 3.h, 7.w, 3.h),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _timeField(
    BuildContext context,
    TextEditingController controller,
    String semanticLabel,
  ) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticLabel,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textDirection: ui.TextDirection.ltr,
        maxLength: 2,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩]')),
        ],
        decoration: const InputDecoration(
          counterText: '',
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: theme.textTheme.bodyMedium,
        onChanged: (value) {
          final digits = _localizeNumerals(value, _arabicNumerals);
          if (digits != value) {
            controller.value = controller.value.copyWith(
              text: digits,
              selection: TextSelection.collapsed(offset: digits.length),
            );
          }
        },
      ),
    );
  }

  static String _displayHour(int hour) =>
      (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0');

  static String _localizeNumerals(String value, bool arabic) =>
      arabic ? value.toArabicNumerals() : _toWesternNumerals(value);

  static String _toWesternNumerals(String value) {
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    var result = value;
    for (var index = 0; index < eastern.length; index++) {
      result = result.replaceAll(eastern[index], '$index');
    }
    return result;
  }
}
