import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_vehicle_detail_field.dart';
import '../tracking_vehicle_sensor_details_card.dart';
import 'tracking_vehicle_details_list.dart';

class TrackingVehicleAssetsTab extends StatefulWidget {
  const TrackingVehicleAssetsTab({super.key});

  @override
  State<TrackingVehicleAssetsTab> createState() => _TrackingVehicleAssetsTabState();
}

class _TrackingVehicleAssetsTabState extends State<TrackingVehicleAssetsTab> {
  bool _showWeightSensorDetails = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final details = TrackingVehicleDetailsDummyData.details;
    return TrackingVehicleDetailsList(
      children: [
        TrackingVehicleDetailField(label: l.vehicleDetailsTankLevel, value: '${details.tankLevelPercent}%'),
        TrackingVehicleDetailField(label: l.vehicleDetailsTemperature, value: '${details.temperatureCelsius} °C'),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => setState(() => _showWeightSensorDetails = !_showWeightSensorDetails),
          child: TrackingVehicleDetailField(
            label: l.vehicleDetailsWeight,
            value: '${details.weightKg} kg',
            highlighted: _showWeightSensorDetails,
          ),
        ),
        if (_showWeightSensorDetails) TrackingVehicleSensorDetailsCard(details: details),
        TrackingVehicleDetailField(label: l.vehicleDetailsFuelUsage, value: '${details.fuelUsagePercent}%'),
        TrackingVehicleDetailField(label: l.vehicleDetailsDoor, value: details.doorOpen ? l.vehicleDetailsOpen : l.vehicleDetailsClosed),
        TrackingVehicleDetailField(label: l.vehicleDetailsEngine, value: details.engineOn ? l.vehicleDetailsOn : l.vehicleDetailsOff),
      ],
    );
  }
}
