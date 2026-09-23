import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/tracking_vehicle.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../../tracking_style.dart';
import '../tracking_asset_detail_field.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetTrackingTab extends StatelessWidget {
  const TrackingAssetTrackingTab({super.key, required this.asset});

  final TrackingAllDummyAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final details = TrackingAssetDetailsDummyData.details;
    final locale = Localizations.localeOf(context).toString();
    final status = asset.status == VehicleStatus.moving
        ? l.assetDetailsRunning
        : TrackingStyle.label(l, asset.status);

    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(label: l.assetDetailsSpeed, value: '${details.speedKph} km/h'),
        TrackingAssetDetailField(label: l.assetDetailsDuration, value: '${details.durationHours} h'),
        TrackingAssetDetailField(label: l.assetDetailsStatus, value: status),
        TrackingAssetDetailField(label: l.assetDetailsConnection, value: l.relativeMinutesAgo(details.connectionMinutesAgo)),
        TrackingAssetDetailField(label: l.assetDetailsGpsTime, value: DateFormat.yMMMd(locale).add_jm().format(details.lastGpsAt)),
        TrackingAssetDetailField(label: l.assetDetailsDistance, value: '${details.distanceKm} km'),
        TrackingAssetDetailField(label: l.assetDetailsFuel, value: '${details.fuelPercent}%'),
        TrackingAssetDetailField(label: l.assetDetailsIdleTime, value: '${details.idleHours} h'),
      ],
    );
  }
}
