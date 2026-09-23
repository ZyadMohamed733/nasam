import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../cubit/asset_details_cubit.dart';
import '../tracking_asset_notification_card.dart';

/// The alerts tab.
///
/// Renders the alerts' own state rather than a bare list, because "could not
/// load" and "there are none" are different answers and used to look the
/// same: a failed request produced an empty list and the empty-state copy.
class TrackingAssetNotificationsTab extends StatelessWidget {
  const TrackingAssetNotificationsTab({
    super.key,
    required this.alerts,
    required this.assetName,
    required this.location,
    required this.onRetry,
  });

  final AssetAlerts alerts;
  final String assetName;
  final String location;

  /// Re-requests the alerts alone.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (alerts) {
      AssetAlertsLoading() => const Center(child: CircularProgressIndicator()),
      AssetAlertsFailed() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.errorGeneric, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
      AssetAlertsLoaded(:final notifications) when notifications.isEmpty =>
        Center(child: Text(l.assetDetailsEmptyAlerts)),
      AssetAlertsLoaded(:final notifications) => ListView.separated(
        padding: EdgeInsets.all(12.w),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) => TrackingAssetNotificationCard(
          notification: notifications[index],
          assetName: assetName,
          location: location,
        ),
      ),
    };
  }
}
