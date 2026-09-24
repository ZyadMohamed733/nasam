import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/tracked_asset_details.dart';
import '../../tracking_units.dart';
import '../tracking_asset_detail_field.dart';
import '../tracking_asset_sensor_details_card.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetSensorsTab extends StatefulWidget {
  const TrackingAssetSensorsTab({super.key, required this.details});

  final TrackedAssetDetails details;

  @override
  State<TrackingAssetSensorsTab> createState() =>
      _TrackingAssetSensorsTabState();
}

class _TrackingAssetSensorsTabState extends State<TrackingAssetSensorsTab> {
  bool _showWeightSensorDetails = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final details = widget.details;
    final units = TrackingUnits.of(context);
    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(
          label: l.assetDetailsTankLevel,
          value: units.percent(details.tankLevelPercent),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsTemperature,
          value: units.celsius(details.temperatureCelsius),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => setState(
            () => _showWeightSensorDetails = !_showWeightSensorDetails,
          ),
          child: TrackingAssetDetailField(
            label: l.assetDetailsWeight,
            value: units.weightKg(details.weightKg),
            highlighted: _showWeightSensorDetails,
          ),
        ),
        if (_showWeightSensorDetails)
          TrackingAssetSensorDetailsCard(details: details),
        TrackingAssetDetailField(
          label: l.assetDetailsFuelUsage,
          value: units.percent(details.fuelUsagePercent),
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsDoor,
          value: details.doorOpen ? l.assetDetailsOpen : l.assetDetailsClosed,
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsEngine,
          value: details.engineOn ? l.assetDetailsOn : l.assetDetailsOff,
        ),
      ],
    );
  }
}
