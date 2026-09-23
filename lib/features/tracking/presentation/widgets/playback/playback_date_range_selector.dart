import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';

class PlaybackDateRangeSelector extends StatelessWidget {
  const PlaybackDateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Row(
      children: [
        Expanded(
          child: _PlaybackDateField(
            label: l.assetPlaybackFrom,
            date: startDate,
            locale: locale,
            onTap: onStartDateTap,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _PlaybackDateField(
            label: l.assetPlaybackTo,
            date: endDate,
            locale: locale,
            onTap: onEndDateTap,
          ),
        ),
      ],
    );
  }
}

class _PlaybackDateField extends StatelessWidget {
  const _PlaybackDateField({
    required this.label,
    required this.date,
    required this.locale,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 48.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: AppIconSize.small.value.r, color: scheme.onSurfaceVariant),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9.sp)),
                    Text(DateFormat.yMd(locale).format(date), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.sp)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
