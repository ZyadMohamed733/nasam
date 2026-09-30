import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:nasam/core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dateTimeLabel = DateFormat.yMMMd(locale).add_jm().format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '* ',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 11.sp,
                  color: scheme.error,
                ),
              ),
              TextSpan(text: label),
            ],
          ),
          textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.right,
          style: theme.textTheme.labelMedium?.copyWith(fontSize: 11.sp),
        ),
        SizedBox(height: 6.h),
        Material(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 48.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                textDirection: ui.TextDirection.ltr,
                children: [
                  SvgPicture.asset(AppAssets.calender, width: 16.r, height: 16.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      dateTimeLabel,
                      textDirection: ui.TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
