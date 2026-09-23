import 'package:flutter/material.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/tracking_vehicle.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_vehicle_detail_field.dart';
import 'tracking_vehicle_details_list.dart';

class TrackingVehicleInformationTab extends StatelessWidget {
  const TrackingVehicleInformationTab({super.key, required this.vehicle});

  final TrackingAllDummyVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TrackingVehicleDetailsList(
      children: [
        TrackingVehicleDetailField(label: l.vehicleDetailsName, value: l.vehicleDetailsDemoName),
        TrackingVehicleDetailField(label: l.vehicleDetailsType, value: l.vehicleDetailsTruckType),
        TrackingVehicleDetailField(label: l.vehicleDetailsCompany, value: l.vehicleDetailsCompanyName),
        TrackingVehicleDetailField(label: l.vehicleDetailsPlateNumber, value: TrackingVehicleDetailsDummyData.details.plateNumber),
        TrackingVehicleDetailField(label: l.vehicleDetailsDriver, value: vehicle.driver),
        TrackingVehicleDetailField(label: l.vehicleDetailsSupervisor, value: l.vehicleDetailsSupervisorName),
      ],
    );
  }
}
