import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/history_alert.dart';

class HistoryAlertCard extends StatelessWidget {
  const HistoryAlertCard({super.key, required this.alert, this.onTap});

  final HistoryAlertEntity alert;
  final VoidCallback? onTap;

  String get _icon => switch (alert.alertType) {
    AlertType.speed => AppAssets.speedAlert,
    AlertType.geofence => AppAssets.geofenceAlert,
    AlertType.sensor => AppAssets.fuelAlert,
    AlertType.unknown => AppAssets.speedAlert,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    // Alerts are recorded in Saudi Arabia (+03:00). Keep that event time
    // stable when the user views the history from another device timezone.
    final saudiTime = alert.timestamp.toUtc().add(const Duration(hours: 3));
    final time = DateFormat('d MMMM yyyy — hh:mm a', locale).format(saudiTime);

    final detail = TextStyle(
      color: AppColors.neutral600,
      fontSize: 12.sp,
      height: 1.6,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                _icon,
                width: 32.w,
                height: 32.w,
                excludeFromSemantics: true,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        color: AppColors.neutralBlack,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text('${l.alertAsset}: ${alert.assetName}', style: detail),
                    Text(
                      '${l.alertType}: ${alert.alertTypeLabel}',
                      style: detail,
                    ),
                    Text('${l.alertValue}: ${alert.valueLabel}', style: detail),
                    Text('${l.alertTime}: $time', style: detail),
                    Text(
                      '${l.alertLocation}: ${alert.location}',
                      style: detail,
                    ),
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
