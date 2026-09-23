import 'package:flutter/material.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/tracked_asset.dart';
import '../../../domain/entities/tracked_asset_details.dart';
import '../tracking_asset_detail_field.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetInformationTab extends StatelessWidget {
  const TrackingAssetInformationTab({
    super.key,
    required this.asset,
    required this.details,
  });

  final TrackedAsset asset;
  final TrackedAssetDetails details;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Name, type, company and manager come from the record. They used to be
    // localisation keys, which meant every asset in the fleet claimed the same
    // name and the same owner, in whichever language the app was set to.
    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(
          label: l.assetDetailsName,
          value: details.name,
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsType,
          value: details.equipmentType,
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsCompany,
          value: details.companyName,
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsId,
          value: details.assetId,
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsAssignedPerson,
          value: asset.assignedPerson,
        ),
        TrackingAssetDetailField(
          label: l.assetDetailsManager,
          value: details.managerName,
        ),
      ],
    );
  }
}
