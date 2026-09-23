import 'package:flutter/material.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../tracking_asset_detail_field.dart';
import 'tracking_asset_details_list.dart';

class TrackingAssetLocationTab extends StatelessWidget {
  const TrackingAssetLocationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TrackingAssetDetailsList(
      children: [
        TrackingAssetDetailField(label: l.assetDetailsAddress, value: l.assetDetailsAddressValue),
      ],
    );
  }
}
