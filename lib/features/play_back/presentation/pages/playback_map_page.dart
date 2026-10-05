import 'package:flutter/material.dart';

import '../../../tracking/presentation/widgets/tracked_asset_gate.dart';
import '../utils/playback_range.dart';
import '../widgets/map/playback_map_view.dart';

class PlaybackMapPage extends StatelessWidget {
  const PlaybackMapPage({
    super.key,
    required this.assetId,
    required this.initialRange,
  });
  final String assetId;
  final PlaybackRange initialRange;
  @override
  Widget build(BuildContext context) => TrackedAssetGate(
    assetId: assetId,
    builder: (context, asset) =>
        PlaybackMapView(asset: asset, range: initialRange),
  );
}




