import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nasam/features/play_back/presentation/widgets/map/playback_googlemap.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/utils/bidi.dart';
import '../../../../../shared/widgets/app_bar_widget.dart';
import '../../../../tracking/domain/entities/tracked_asset.dart';
import '../../../../tracking/presentation/widgets/tracking_controls.dart';
import '../../cubit/playback_map_cubit.dart';
import '../../cubit/playback_map_state.dart';
import '../../utils/playback_range.dart';
import '../playback_date_picker_sheet.dart';
import '../playback_info_bottom_sheet.dart';
import 'panel_widget.dart';

class PlaybackMapView extends StatefulWidget {
  const PlaybackMapView({super.key, required this.asset, required this.range});
  final TrackedAsset asset;
  final PlaybackRange range;
  @override
  State<PlaybackMapView> createState() => PlaybackMapViewState();
}

class PlaybackMapViewState extends State<PlaybackMapView> {
  late DateTime _from = widget.range.from, _to = widget.range.to;
  GoogleMapController? _nativeController;
  MapType _mapType = MapType.normal;
  Future<void> _zoom(bool inward) async {
    final controller = _nativeController;
    if (controller == null) return;
    try {
      await controller.animateCamera(
        inward ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      );
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context.read<PlaybackMapCubit>().load(
    assetId: widget.asset.id,
    from: _from,
    to: _to.add(const Duration(days: 1)),
  );
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
      builder: (ctx) => PlaybackDatePickerSheet(
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final assetCode = joinIsolated([
      widget.asset.code,
      widget.asset.name,
    ], ' · ');
    return Scaffold(
      appBar: NasamAppBar(
        showLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: l.playbackBack,
          icon: SvgPicture.asset(
            AppAssets.arrowBackButton,
            width: 8,
            height: 16,
          ),
        ),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.assetPlaybackTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              assetCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
              buildWhen: (a, b) =>
              a.runtimeType != b.runtimeType ||
                  a is PlaybackMapLoaded &&
                      b is PlaybackMapLoaded &&
                      (a.points != b.points ||
                          a.currentIndex != b.currentIndex),
              builder: (context, state) {
                if (state is! PlaybackMapLoaded) {
                  return ColoredBox(color: scheme.surfaceContainerLow);
                }
                return PlaybackGoogleMap(
                  points: state.points,
                  index: state.currentIndex,
                  mapType: _mapType,
                  bottomInset: 215,
                  onCreated: (controller) => _nativeController = controller,
                );
              },
            ),
          ),
          Positioned.fill(
            child: BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
              buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
              builder: (context, state) => state is PlaybackMapLoading
                  ? const IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox.shrink(),
            ),
          ),
          BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
            buildWhen: (a, b) => a.runtimeType != b.runtimeType,
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
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PanelWidget(
              from: _from,
              to: _to,
              onPick: _pick,
              onLoad: _load,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaybackInfo() {
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
          child: PlaybackInfoBottomSheet(asset: widget.asset),
        ),
      ),
    );
  }

}
