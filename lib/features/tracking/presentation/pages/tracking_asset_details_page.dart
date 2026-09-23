import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracked_asset_details.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../widgets/tabs/tracking_asset_information_tab.dart';
import '../widgets/tabs/tracking_asset_location_tab.dart';
import '../widgets/tabs/tracking_asset_notifications_tab.dart';
import '../widgets/tabs/tracking_asset_sensors_tab.dart';
import '../widgets/tabs/tracking_asset_tracking_tab.dart';

class TrackingAssetDetailsPage extends StatefulWidget {
  const TrackingAssetDetailsPage({super.key, required this.asset});

  final TrackedAsset asset;

  @override
  State<TrackingAssetDetailsPage> createState() =>
      _TrackingAssetDetailsPageState();
}

class _TrackingAssetDetailsPageState extends State<TrackingAssetDetailsPage> {
  late final Future<_DetailsBundle> _bundle = _load();

  Future<_DetailsBundle> _load() async {
    final repository = getIt<TrackingRepository>();
    final details = await repository.getAssetDetails(widget.asset.id);
    final notifications = await repository.getAssetNotifications(
      widget.asset.id,
    );
    return _DetailsBundle(
      details: details.getOrElse(() => throw StateError('details unavailable')),
      notifications: notifications.getOrElse(() => const []),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
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
                asset.name,
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
        body: FutureBuilder<_DetailsBundle>(
          future: _bundle,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) return Center(child: Text(l.errorGeneric));
            return TabBarView(
              children: [
                TrackingAssetInformationTab(
                  asset: asset,
                  details: data.details,
                ),
                TrackingAssetTrackingTab(asset: asset, details: data.details),
                TrackingAssetLocationTab(details: data.details),
                TrackingAssetSensorsTab(details: data.details),
                TrackingAssetNotificationsTab(
                  notifications: data.notifications,
                  assetName: data.details.name,
                  location: data.details.address,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The two records the five tabs share, loaded once for the screen.
class _DetailsBundle {
  const _DetailsBundle({required this.details, required this.notifications});

  final TrackedAssetDetails details;
  final List<TrackedAssetNotification> notifications;
}
