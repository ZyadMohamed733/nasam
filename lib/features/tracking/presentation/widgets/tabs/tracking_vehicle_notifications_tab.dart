import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_vehicle_notification_card.dart';

class TrackingVehicleNotificationsTab extends StatelessWidget {
  const TrackingVehicleNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = TrackingVehicleDetailsDummyData.notifications;
    final l = AppLocalizations.of(context)!;
    if (notifications.isEmpty) return Center(child: Text(l.vehicleDetailsEmptyAlerts));
    return ListView.separated(
      padding: EdgeInsets.all(12.w),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => TrackingVehicleNotificationCard(notification: notifications[index]),
    );
  }
}
