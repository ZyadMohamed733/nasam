import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/tracking_vehicle.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../../tracking_style.dart';
import '../tracking_vehicle_detail_field.dart';
import 'tracking_vehicle_details_list.dart';

class TrackingVehicleTrackingTab extends StatelessWidget {
  const TrackingVehicleTrackingTab({super.key, required this.vehicle});

  final TrackingAllDummyVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final details = TrackingVehicleDetailsDummyData.details;
    final locale = Localizations.localeOf(context).toString();
    final status = vehicle.status == VehicleStatus.moving
        ? l.vehicleDetailsRunning
        : TrackingStyle.label(l, vehicle.status);

    return TrackingVehicleDetailsList(
      children: [
        TrackingVehicleDetailField(label: l.vehicleDetailsSpeed, value: '${details.speedKph} km/h'),
        TrackingVehicleDetailField(label: l.vehicleDetailsDuration, value: '${details.durationHours} h'),
        TrackingVehicleDetailField(label: l.vehicleDetailsStatus, value: status),
        TrackingVehicleDetailField(label: l.vehicleDetailsConnection, value: l.relativeMinutesAgo(details.connectionMinutesAgo)),
        TrackingVehicleDetailField(label: l.vehicleDetailsGpsTime, value: DateFormat.yMMMd(locale).add_jm().format(details.lastGpsAt)),
        TrackingVehicleDetailField(label: l.vehicleDetailsDistance, value: '${details.distanceKm} km'),
        TrackingVehicleDetailField(label: l.vehicleDetailsFuel, value: '${details.fuelPercent}%'),
        TrackingVehicleDetailField(label: l.vehicleDetailsIdleTime, value: '${details.idleHours} h'),
      ],
    );
  }
}
