import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracked_asset.dart';
import '../cubit/asset_details_cubit.dart';
import '../widgets/tabs/tracking_asset_information_tab.dart';
import '../widgets/tabs/tracking_asset_location_tab.dart';
import '../widgets/tabs/tracking_asset_notifications_tab.dart';
import '../widgets/tabs/tracking_asset_sensors_tab.dart';
import '../widgets/tabs/tracking_asset_tracking_tab.dart';
import '../widgets/tracked_asset_gate.dart';

/// An asset's five-tab details screen, opened by id.
///
/// Expects a TrackedAssetCubit and an [AssetDetailsCubit] above it, both
/// created and loaded by the route. The asset itself is resolved from the id,
/// so the screen works the same from a list tap and from a cold deep link.
class TrackingAssetDetailsPage extends StatelessWidget {
  const TrackingAssetDetailsPage({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) => TrackedAssetGate(
    assetId: assetId,
    builder: (context, asset) => _AssetDetailsView(asset: asset),
  );
}

class _AssetDetailsView extends StatelessWidget {
  const _AssetDetailsView({required this.asset});

  final TrackedAsset asset;

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
        body: BlocBuilder<AssetDetailsCubit, AssetDetailsState>(
          builder: (context, state) => switch (state) {
            AssetDetailsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            AssetDetailsFailure() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.errorGeneric),
                  TextButton(
                    onPressed: () =>
                        context.read<AssetDetailsCubit>().load(asset.id),
                    child: Text(l.retry),
                  ),
                ],
              ),
            ),
            AssetDetailsLoaded(:final details, :final alerts) => TabBarView(
              children: [
                TrackingAssetInformationTab(asset: asset, details: details),
                TrackingAssetTrackingTab(asset: asset, details: details),
                TrackingAssetLocationTab(details: details),
                TrackingAssetSensorsTab(details: details),
                TrackingAssetNotificationsTab(
                  alerts: alerts,
                  assetName: details.name,
                  location: details.address,
                  onRetry: context.read<AssetDetailsCubit>().retryAlerts,
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
