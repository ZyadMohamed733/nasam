import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../tracking/domain/entities/tracked_asset.dart';
import '../../../../tracking/presentation/widgets/tracking_controls.dart';
import '../../cubit/playback_map_cubit.dart';
import '../../cubit/playback_map_state.dart';
import '../playback_info_bottom_sheet.dart';

class PlaybackControllersWidget extends StatelessWidget {
  const PlaybackControllersWidget({
    super.key,
    required this.nativeController,
    required this.asset,
    required this.onCycleMapType,
  });

  final GoogleMapController? nativeController;
  final TrackedAsset asset;
  final VoidCallback onCycleMapType;

  Future<void> _zoom(bool inward) async {
    final controller = nativeController;
    if (controller == null) return;
    try {
      await controller.animateCamera(
        inward ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      );
    } catch (_) {
      // The map can be disposed while a camera animation is in flight.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is! PlaybackMapLoaded) return const SizedBox.shrink();
        return PositionedDirectional(
          start: TrackingControlsLayout.toolColumnInset,
          top: TrackingControlsLayout.compactToolColumnTop,
          child: Column(
            children: [
              TrackingIconButton(
                asset: AppAssets.mapZoomIn,
                label: l.trackingZoomIn,
                onTap: nativeController == null ? null : () => _zoom(true),
              ),
              TrackingIconButton(
                asset: AppAssets.mapZoomOut,
                label: l.trackingZoomOut,
                onTap: nativeController == null ? null : () => _zoom(false),
              ),
              TrackingIconButton(
                asset: AppAssets.mapLayers,
                label: l.trackingLayers,
                onTap: onCycleMapType,
              ),
              TrackingIconButton(
                asset: AppAssets.infoCircle,
                label: l.playbackInfo,
                materialIcon: Icons.info_outline,
                onTap: () => _showPlaybackInfo(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlaybackInfo(BuildContext context) {
    final playbackCubit = context.read<PlaybackMapCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      builder: (_) => BlocProvider.value(
        value: playbackCubit,
        child: FractionallySizedBox(
          heightFactor: .9,
          child: PlaybackInfoBottomSheet(asset: asset),
        ),
      ),
    );
  }
}
