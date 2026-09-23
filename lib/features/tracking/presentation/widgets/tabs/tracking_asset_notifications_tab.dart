import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/tracked_asset_details.dart';
import '../tracking_asset_notification_card.dart';

class TrackingAssetNotificationsTab extends StatelessWidget {
  const TrackingAssetNotificationsTab({
    super.key,
    required this.notifications,
    required this.assetName,
    required this.location,
  });

  final List<TrackedAssetNotification> notifications;
  final String assetName;
  final String location;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (notifications.isEmpty) {
      return Center(child: Text(l.assetDetailsEmptyAlerts));
    }
    return ListView.separated(
      padding: EdgeInsets.all(12.w),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) =>
          TrackingAssetNotificationCard(
            notification: notifications[index],
            assetName: assetName,
            location: location,
          ),
    );
  }
}
