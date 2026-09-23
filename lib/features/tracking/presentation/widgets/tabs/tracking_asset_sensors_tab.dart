import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_asset_detail_field.dart';
import '../tracking_asset_sensor_details_card.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetSensorsTab extends StatefulWidget {
  const TrackingAssetSensorsTab({super.key});

  @override
  State<TrackingAssetSensorsTab> createState() => _TrackingAssetSensorsTabState();
}

class _TrackingAssetSensorsTabState extends State<TrackingAssetSensorsTab> {
  bool _showWeightSensorDetails = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final details = TrackingAssetDetailsDummyData.details;
    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(label: l.assetDetailsTankLevel, value: '${details.tankLevelPercent}%'),
        TrackingAssetDetailField(label: l.assetDetailsTemperature, value: '${details.temperatureCelsius} °C'),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => setState(() => _showWeightSensorDetails = !_showWeightSensorDetails),
          child: TrackingAssetDetailField(
            label: l.assetDetailsWeight,
            value: '${details.weightKg} kg',
            highlighted: _showWeightSensorDetails,
          ),
        ),
        if (_showWeightSensorDetails) TrackingAssetSensorDetailsCard(details: details),
        TrackingAssetDetailField(label: l.assetDetailsFuelUsage, value: '${details.fuelUsagePercent}%'),
        TrackingAssetDetailField(label: l.assetDetailsDoor, value: details.doorOpen ? l.assetDetailsOpen : l.assetDetailsClosed),
        TrackingAssetDetailField(label: l.assetDetailsEngine, value: details.engineOn ? l.assetDetailsOn : l.assetDetailsOff),
      ],
    );
  }
}
