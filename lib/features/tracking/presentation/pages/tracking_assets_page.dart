import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../widgets/tracking_asset_card.dart';
import '../widgets/tracking_asset_search_field.dart';

class TrackingAssetsPage extends StatefulWidget {
  const TrackingAssetsPage({
    super.key,
    required this.title,
    required this.status,
    required this.assets,
  });

  final String title;
  final VehicleStatus? status;
  final List<TrackedAsset> assets;

  @override
  State<TrackingAssetsPage> createState() => _TrackingAssetsPageState();
}

class _TrackingAssetsPageState extends State<TrackingAssetsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final assets = widget.assets.where((asset) {
      final matchesStatus = widget.status == null || asset.status == widget.status;
      final matchesQuery = asset.name.toLowerCase().contains(query) ||
          asset.code.toLowerCase().contains(query) ||
          asset.assignedPerson.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    });

    return Semantics(
      label: widget.title,
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Column(
          children: [
            TrackingAssetSearchField(
              onChanged: (value) => setState(() => _query = value),
            ),
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
