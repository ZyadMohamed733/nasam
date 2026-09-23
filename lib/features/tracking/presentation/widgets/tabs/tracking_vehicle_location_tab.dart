import 'package:flutter/material.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../tracking_vehicle_detail_field.dart';
import 'tracking_vehicle_details_list.dart';

class TrackingVehicleLocationTab extends StatelessWidget {
  const TrackingVehicleLocationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TrackingVehicleDetailsList(
      children: [
        TrackingVehicleDetailField(label: l.vehicleDetailsAddress, value: l.vehicleDetailsAddressValue),
      ],
    );
  }
}
