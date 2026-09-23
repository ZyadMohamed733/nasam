import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/tracked_asset_details.dart';
import 'tracking_asset_detail_field.dart';

class TrackingAssetNotificationCard extends StatelessWidget {
  const TrackingAssetNotificationCard({
    super.key,
    required this.notification,
    required this.assetName,
    required this.location,
  });

  final TrackedAssetNotification notification;

  /// Which asset raised the alert, and where. Both were localisation keys, so
  /// every alert in the list named the same asset at the same address.
  final String assetName;
  final String location;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final type = switch (notification.type) {
      TrackingNotificationType.speeding => l.assetDetailsSpeedingAlert,
      TrackingNotificationType.stopped => l.assetDetailsStoppedAlert,
      TrackingNotificationType.geofence =>
        l.assetDetailsGeofenceAlert,
    };

    return AppCard(
      elevation: 0,
      borderRadius: 12.r,
      padding: EdgeInsets.all(10.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _NotificationValue(
                  label: l.assetDetailsAlertName,
                  value: assetName,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _NotificationValue(
                  label: l.assetDetailsAlertType,
                  value: type,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _NotificationValue(
                  label: l.assetDetailsAlertSpeed,
                  value: '${notification.speedKph} km/h',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _NotificationValue(
                  label: l.assetDetailsAlertDate,
                  value: DateFormat.yMMMd(locale).add_jm().format(
                    notification.date,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TrackingAssetDetailField(
            label: l.assetDetailsAlertLocation,
            value: location,
          ),
        ],
      ),
    );
  }
}

class _NotificationValue extends StatelessWidget {
  const _NotificationValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
