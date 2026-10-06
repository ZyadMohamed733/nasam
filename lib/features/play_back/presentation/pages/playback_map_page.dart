import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_result_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator_widget.dart';
import '../../../tracking/domain/entities/tracked_asset.dart';
import '../../../tracking/presentation/widgets/tracked_asset_gate.dart';
import '../../../tracking/presentation/widgets/tracking_controls.dart';
import '../cubit/playback_map_cubit.dart';
import '../cubit/playback_map_state.dart';
import '../utils/playback_range.dart';
import '../widgets/map/panel_widget.dart';
import '../widgets/map/playback_googlemap.dart';
import '../widgets/map/playback_map_appbar.dart';
import '../widgets/playback_date_picker_sheet.dart';
import '../widgets/playback_info_bottom_sheet.dart';

class PlaybackMapPage extends StatefulWidget {
  const PlaybackMapPage({
    super.key,
    required this.assetId,
    required this.initialRange,
  });

  final String assetId;
  final PlaybackRange initialRange;

  @override
  State<PlaybackMapPage> createState() => PlaybackMapPageState();
}

class PlaybackMapPageState extends State<PlaybackMapPage> {
  late DateTime _from = widget.initialRange.from;
  late DateTime _to = widget.initialRange.to;
  TrackedAsset? _asset;
  String? _loadedAssetId;
  GoogleMapController? _nativeController;
  MapType _mapType = MapType.normal;

  @override
  Widget build(BuildContext context) => TrackedAssetGate(
    assetId: widget.assetId,
    builder: (context, asset) {
      if (_loadedAssetId != asset.id) {
        _asset = asset;
        _loadedAssetId = asset.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _loadedAssetId == asset.id) _load();
        });
      }
      return _buildPage(context, asset);
    },
  );

  Widget _buildPage(BuildContext context, TrackedAsset asset) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PlaybackMapAppbar(asset: asset, onBack: () => context.pop()),
      body: BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
        builder: (context, state) => switch (state) {
          PlaybackMapLoading() => ColoredBox(
            color: scheme.surfaceContainerLow,
            child: const Center(child: LoadingIndicatorWidget()),
          ),
          PlaybackMapFailure(:final failure) => ColoredBox(
            color: scheme.surfaceContainerLow,
            child: AppErrorWidget(
              message: l.errorGeneric,
              retryLabel: l.retry,
              onRetry: _load,
              type: AppErrorWidget.typeForFailure(failure),
            ),
          ),
          PlaybackMapEmpty() => ColoredBox(
            color: scheme.surfaceContainerLow,
            child: EmptyResultWidget(
              message: l.assetPlaybackEmpty,
              type: EmptyResultType.playbackRoute,
              retryLabel: l.retry,
              onRetry: _load,
            ),
          ),
          PlaybackMapLoaded(:final points, :final currentIndex) => Stack(
            children: [
              Positioned.fill(
                child: PlaybackGoogleMap(
                  points: points,
                  index: currentIndex,
                  mapType: _mapType,
                  bottomInset: 215,
                  onCreated: (controller) => _nativeController = controller,
                ),
              ),
              PositionedDirectional(
                start: TrackingControlsLayout.toolColumnInset,
                top: TrackingControlsLayout.compactToolColumnTop,
                child: Column(
                  children: [
                    TrackingIconButton(
                      asset: AppAssets.mapZoomIn,
                      label: l.trackingZoomIn,
                      onTap: _nativeController == null
                          ? null
                          : () => _zoom(true),
                    ),
                    TrackingIconButton(
                      asset: AppAssets.mapZoomOut,
                      label: l.trackingZoomOut,
                      onTap: _nativeController == null
                          ? null
                          : () => _zoom(false),
                    ),
                    TrackingIconButton(
                      asset: AppAssets.mapLayers,
                      label: l.trackingLayers,
                      onTap: () => setState(
                        () => _mapType = switch (_mapType) {
                          MapType.normal => MapType.hybrid,
                          MapType.hybrid => MapType.terrain,
                          _ => MapType.normal,
                        },
                      ),
                    ),
                    TrackingIconButton(
                      asset: AppAssets.infoCircle,
                      label: l.playbackInfo,
                      materialIcon: Icons.info_outline,
                      onTap: _showPlaybackInfo,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PanelWidget(from: _from, to: _to, onPick: _pick),
              ),
            ],
          ),
        },
      ),
    );
  }

  void _load() {
    final asset = _asset;
    if (asset == null) return;
    _nativeController = null;
    context.read<PlaybackMapCubit>().load(
      assetId: asset.id,
      from: _from,
      to: _to.add(const Duration(days: 1)),
    );
  }

  void _showPlaybackInfo() {
    final asset = _asset;
    if (asset == null) return;
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

  Future<void> _pick() async {
    final l = AppLocalizations.of(context)!;
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r12)),
      ),
      builder: (context) => PlaybackDatePickerSheet(
        title: l.playbackChooseDay,
        initialDate: _from,
        firstDate: PlaybackRange.earliest(DateUtils.dateOnly(DateTime.now())),
        lastDate: DateUtils.dateOnly(DateTime.now()),
      ),
    );
    if (date != null && mounted) {
      setState(() => _from = _to = DateUtils.dateOnly(date));
      _load();
    }
  }

  Future<void> _zoom(bool inward) async {
    final controller = _nativeController;
    if (controller == null) return;
    try {
      await controller.animateCamera(
        inward ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      );
    } catch (_) {}
  }
}
