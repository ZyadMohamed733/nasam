import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../dummy_data/tracking_all_dummy_data.dart';
import '../widgets/tabs/tracking_vehicle_assets_tab.dart';
import '../widgets/tabs/tracking_vehicle_information_tab.dart';
import '../widgets/tabs/tracking_vehicle_location_tab.dart';
import '../widgets/tabs/tracking_vehicle_notifications_tab.dart';
import '../widgets/tabs/tracking_vehicle_tracking_tab.dart';

class TrackingVehicleDetailsPage extends StatelessWidget {
  const TrackingVehicleDetailsPage({
    super.key,
    required this.vehicle,
  });

  final TrackingAllDummyVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 62.h,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.vehicleDetailsDemoName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                vehicle.code,
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
                Tab(text: l.vehicleDetailsInformation),
                Tab(text: l.vehicleDetailsTracking),
                Tab(text: l.vehicleDetailsLocation),
                Tab(text: l.vehicleDetailsAssets),
                Tab(text: l.vehicleDetailsNotifications),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            TrackingVehicleInformationTab(vehicle: vehicle),
            TrackingVehicleTrackingTab(vehicle: vehicle),
            const TrackingVehicleLocationTab(),
            const TrackingVehicleAssetsTab(),
            const TrackingVehicleNotificationsTab(),
          ],
        ),
      ),
    );
  }
}
