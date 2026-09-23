import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/tracked_asset.dart';
import '../widgets/tracking_asset_card.dart';
import '../widgets/tracking_asset_search_field.dart';

/// The asset list inside the fleet sheet.
///
/// Renders what it is given. Filtering and search belong to `TrackingCubit`:
/// this page used to hold its own query and re-filter on every keystroke, so
/// the search reset whenever the sheet rebuilt and could not be tested without
/// pumping a widget.
class TrackingAssetsPage extends StatelessWidget {
  const TrackingAssetsPage({
    super.key,
    required this.title,
    required this.assets,
    required this.onQueryChanged,
  });

  final String title;

  /// Already narrowed by the selected status and the committed search.
  final List<TrackedAsset> assets;

  /// Every keystroke; the cubit debounces.
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Column(
          children: [
            TrackingAssetSearchField(onChanged: onQueryChanged),
            SizedBox(height: 8.h),
            for (final asset in assets) ...[
              TrackingAssetCard(asset: asset),
              SizedBox(height: 6.h),
            ],
          ],
        ),
      ),
    );
  }
}
