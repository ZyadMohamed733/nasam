import 'package:flutter/material.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/tracked_asset_details.dart';
import '../tracking_asset_detail_field.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetLocationTab extends StatelessWidget {
  const TrackingAssetLocationTab({super.key, required this.details});

  final TrackedAssetDetails details;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(
          label: l.assetDetailsAddress,
          value: details.address,
        ),
      ],
    );
  }
}
