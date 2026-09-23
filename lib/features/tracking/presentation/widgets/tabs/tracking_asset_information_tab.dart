import 'package:flutter/material.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/tracking_vehicle.dart';
import '../../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_asset_detail_field.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetInformationTab extends StatelessWidget {
  const TrackingAssetInformationTab({super.key, required this.asset});

  final TrackingAllDummyAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(label: l.assetDetailsName, value: l.assetDetailsDemoName),
        TrackingAssetDetailField(label: l.assetDetailsType, value: l.assetDetailsEquipmentType),
        TrackingAssetDetailField(label: l.assetDetailsCompany, value: l.assetDetailsCompanyName),
        TrackingAssetDetailField(label: l.assetDetailsId, value: TrackingAssetDetailsDummyData.details.assetId),
        TrackingAssetDetailField(label: l.assetDetailsAssignedPerson, value: asset.assignedPerson),
        TrackingAssetDetailField(label: l.assetDetailsManager, value: l.assetDetailsManagerName),
      ],
    );
  }
}
