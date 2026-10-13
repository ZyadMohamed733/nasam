import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/history_alert.dart';
import '../utils/alert_history_format.dart';

class HistoryAlertCard extends StatelessWidget {
  const HistoryAlertCard({super.key, required this.alert, this.onTap});

  final HistoryAlertEntity alert;
  final VoidCallback? onTap;

  String get _icon => switch (alert.alertType) {
    AlertType.speed => AppAssets.speedAlert,
    AlertType.geofence => AppAssets.geofenceAlert,
    AlertType.sensor => AppAssets.fuelAlert,
    // The design has no downtime icon yet.
    AlertType.downtime => AppAssets.alertNotification,
    AlertType.unknown => AppAssets.speedAlert,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final time = AlertHistoryFormat.time(context, alert.occurredAt);

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
                      AlertHistoryFormat.text(context, alert.alertName),
                      style: TextStyle(
                        color: AppColors.neutralBlack,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${l.alertAsset}: '
                      '${AlertHistoryFormat.asset(context, alert.asset)}',
                      style: detail,
                    ),
                    Text(
                      '${l.alertType}: '
                      '${AlertHistoryFormat.typeLabel(l, alert.alertType)}',
                      style: detail,
                    ),
                    Text(
                      '${l.alertValue}: '
                      '${AlertHistoryFormat.text(context, alert.triggeredValue)}',
                      style: detail,
                    ),
                    Text('${l.alertTime}: $time', style: detail),
                    Text(
                      '${l.alertLocation}: '
                      '${AlertHistoryFormat.location(l, alert.location)}',
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
