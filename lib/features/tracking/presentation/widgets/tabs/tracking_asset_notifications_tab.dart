import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_asset_notification_card.dart';

class TrackingAssetNotificationsTab extends StatelessWidget {
  const TrackingAssetNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = TrackingAssetDetailsDummyData.notifications;
    final l = AppLocalizations.of(context)!;
    if (notifications.isEmpty) return Center(child: Text(l.assetDetailsEmptyAlerts));
    return ListView.separated(
      padding: EdgeInsets.all(12.w),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => TrackingAssetNotificationCard(notification: notifications[index]),
    );
  }
}
