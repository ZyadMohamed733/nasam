import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/tracked_asset.dart';
import '../../../domain/entities/tracked_asset_details.dart';
import '../../../domain/entities/tracking_vehicle.dart';
import '../../tracking_style.dart';
import '../../tracking_units.dart';
import '../tracking_asset_detail_field.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetTrackingTab extends StatelessWidget {
  const TrackingAssetTrackingTab({
    super.key,
    required this.asset,
    required this.details,
  });

  final TrackedAsset asset;
  final TrackedAssetDetails details;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final units = TrackingUnits.of(context);
    final status = asset.status == VehicleStatus.moving
        ? l.assetDetailsRunning
        : TrackingStyle.label(l, asset.status);

    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(
          label: l.assetDetailsSpeed,
          value: units.speedKph(details.speedKph),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsDuration,
          value: units.hours(details.durationHours),
        ),
        TrackingAssetDetailField(label: l.assetDetailsStatus, value: status),
        TrackingAssetDetailField(
          label: l.assetDetailsConnection,
          value: l.relativeMinutesAgo(details.connectionMinutesAgo),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsGpsTime,
          value: DateFormat.yMMMd(locale).add_jm().format(details.lastGpsAt),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsDistance,
          value: units.distanceKm(details.distanceKm),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsFuel,
          value: units.percent(details.fuelPercent),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsIdleTime,
          value: units.hours(details.idleHours),
        ),
      ],
    );
  }
}
