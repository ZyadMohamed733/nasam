import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../dummy_data/tracking_all_dummy_data.dart';
import 'tracking_vehicle_detail_field.dart';

class TrackingVehicleNotificationCard extends StatelessWidget {
  const TrackingVehicleNotificationCard({
    super.key,
    required this.notification,
  });

  final TrackingVehicleNotificationSample notification;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final type = switch (notification.type) {
      TrackingDummyNotificationType.speeding => l.vehicleDetailsSpeedingAlert,
      TrackingDummyNotificationType.stopped => l.vehicleDetailsStoppedAlert,
      TrackingDummyNotificationType.geofence =>
        l.vehicleDetailsGeofenceAlert,
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
                  label: l.vehicleDetailsAlertName,
                  value: l.vehicleDetailsDemoName,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _NotificationValue(
                  label: l.vehicleDetailsAlertType,
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
                  label: l.vehicleDetailsAlertSpeed,
                  value: '${notification.speedKph} km/h',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _NotificationValue(
                  label: l.vehicleDetailsAlertDate,
                  value: DateFormat.yMMMd(locale).add_jm().format(
                    notification.date,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TrackingVehicleDetailField(
            label: l.vehicleDetailsAlertLocation,
            value: l.vehicleDetailsAddressValue,
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
