import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_bar_widget.dart';
import '../../domain/entities/history_alert.dart';

class HistoryAlertDetailsPage extends StatelessWidget {
  const HistoryAlertDetailsPage({super.key, required this.alert});

  final HistoryAlertEntity alert;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final saudiTime = alert.timestamp.toUtc().add(const Duration(hours: 3));
    final formattedTime = DateFormat(
      'd MMMM yyyy — hh:mm a',
      Localizations.localeOf(context).toString(),
    ).format(saudiTime);

    return Directionality(
      // Keep this feature's physical alignment tied to the selected app
      // language. Some navigation entry points can retain an LTR subtree.
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: NasamAppBar(
          centerTitle: false,
          titleWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                textAlign: TextAlign.start,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                l.alertDetailsSubtitle,
                textAlign: TextAlign.start,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.pop(),
            icon: IconTheme(
              data: IconThemeData(size: AppIconSize.medium.value),
              child: const BackButtonIcon(),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 12.w, 20.h),
          children: [
            _DetailsCard(
              title: l.assetDetailsInformation,
              rows: [
                _DetailRow(label: l.assetDetailsAlertName, value: alert.title),
                _DetailRow(label: l.alertAsset, value: alert.assetName),
                _DetailRow(
                  label: l.assetDetailsAlertType,
                  value: alert.alertTypeLabel,
                ),
                _DetailRow(label: l.alertTime, value: formattedTime),
                _DetailRow(label: l.alertLocation, value: alert.location),
              ],
            ),
            if (alert.alertType == AlertType.speed) ...[
              SizedBox(height: 10.h),
              _DetailsCard(
                title: l.alertDetailsSpeedInfo,
                rows: [
                  _DetailRow(
                    label: l.alertDetailsRecordedSpeed,
                    value: alert.valueLabel,
                    valueColor:
                        alert.speedLimit != null &&
                            alert.value != null &&
                            alert.value! > alert.speedLimit!
                        ? theme.colorScheme.error
                        : null,
                  ),
                  if (alert.speedLimit != null)
                    _DetailRow(
                      label: l.alertDetailsSpeedLimit,
                      value:
                          '${alert.speedLimit} ${l.assetPlaybackKilometersPerHour}',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.title, required this.rows});

  final String title;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = _localeDirection(context);
    final textAlignment = textDirection == ui.TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 8.h, end: 2.w),
            child: Text(
              title,
              textDirection: textDirection,
              textAlign: textAlignment,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) SizedBox(height: 5.h),
            _DetailRowTile(row: rows[index]),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

class _DetailRowTile extends StatelessWidget {
  const _DetailRowTile({required this.row});

  final _DetailRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = _localeDirection(context);
    final textAlignment = textDirection == ui.TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(10.w, 8.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.h),
          Text(
            row.label,
            textDirection: textDirection,
            textAlign: textAlignment,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            row.value,
            textDirection: textDirection,
            textAlign: textAlignment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: row.valueColor ?? AppColors.neutralBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

ui.TextDirection _localeDirection(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar'
    ? ui.TextDirection.rtl
    : ui.TextDirection.ltr;
