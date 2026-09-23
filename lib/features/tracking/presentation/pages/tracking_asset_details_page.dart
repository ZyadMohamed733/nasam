import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../dummy_data/tracking_all_dummy_data.dart';
import '../widgets/tabs/tracking_asset_sensors_tab.dart';
import '../widgets/tabs/tracking_asset_information_tab.dart';
import '../widgets/tabs/tracking_asset_location_tab.dart';
import '../widgets/tabs/tracking_asset_notifications_tab.dart';
import '../widgets/tabs/tracking_asset_tracking_tab.dart';

class TrackingAssetDetailsPage extends StatelessWidget {
  const TrackingAssetDetailsPage({
    super.key,
    required this.asset,
  });

  final TrackingAllDummyAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 62.h,
          iconTheme: IconThemeData(size: AppIconSize.medium.value.r),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.assetDetailsDemoName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                asset.code,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44.h),
            child: TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
              labelStyle: TextStyle(fontSize: 12.sp),
              tabs: [
                Tab(text: l.assetDetailsInformation),
                Tab(text: l.assetDetailsTracking),
                Tab(text: l.assetDetailsLocation),
                Tab(text: l.assetDetailsAssets),
                Tab(text: l.assetDetailsNotifications),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            TrackingAssetInformationTab(asset: asset),
            TrackingAssetTrackingTab(asset: asset),
            const TrackingAssetLocationTab(),
            const TrackingAssetSensorsTab(),
            const TrackingAssetNotificationsTab(),
          ],
        ),
      ),
    );
  }
}
