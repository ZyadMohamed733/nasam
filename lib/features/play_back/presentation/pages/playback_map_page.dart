import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/error_reporter.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../../../core/utils/bidi.dart';
import '../../../../shared/widgets/action_icon.dart';
import '../../../../shared/widgets/app_bar_widget.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../tracking/domain/entities/tracked_asset.dart';
import '../../../tracking/presentation/widgets/tracked_asset_gate.dart';
import '../../../tracking/presentation/widgets/tracking_controls.dart';
import '../../../tracking/presentation/widgets/tracking_map.dart';
import '../../../tracking/presentation/widgets/tracking_marker_factory.dart';
import '../../domain/entities/playback_point.dart';
import '../cubit/playback_map_cubit.dart';
import '../utils/playback_range.dart';
import '../widgets/playback_date_picker_sheet.dart';

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
        _PlaybackMapView(asset: asset, range: initialRange),
  );
}

class _PlaybackMapView extends StatefulWidget {
  const _PlaybackMapView({required this.asset, required this.range});
  final TrackedAsset asset;
  final PlaybackRange range;
  @override
  State<_PlaybackMapView> createState() => _PlaybackMapViewState();
}

class _PlaybackMapViewState extends State<_PlaybackMapView> {
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
          icon: const Icon(Icons.arrow_back),
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
                return _PlaybackGoogleMap(
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
                      asset: AppAssets.videoCameraRecord,
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
                    ),
                  ],
                ),
              );
            },
          ),
          Align(alignment: Alignment.bottomCenter, child: _panel(context)),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<PlaybackMapCubit>().state;
    final loaded = state is PlaybackMapLoaded ? state : null;
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSizes.p16,
        AppSizes.p16,
        AppSizes.p16,
        MediaQuery.paddingOf(context).bottom + AppSizes.p8,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.r24),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: .12),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _pick,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: AppSizes.iconSm,
                  ),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Text(
                      '${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jm().format(_from)} - ${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jm().format(_to)}',
                      maxLines: 2,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          if (state is PlaybackMapLoading)
            const Padding(
              padding: EdgeInsets.all(AppSizes.p8),
              child: CircularProgressIndicator(),
            )
          else if (state is PlaybackMapFailure)
            Row(
              children: [
                Expanded(child: Text(l.errorGeneric)),
                SizedBox(
                  width: 104,
                  child: AppButton(
                    onPressed: _load,
                    label: l.retry,
                    variant: AppButtonVariant.tertiary,
                  ),
                ),
              ],
            )
          else if (state is PlaybackMapEmpty)
            Text(l.assetPlaybackEmpty)
          else if (loaded != null) ...[
            _scrubber(context, loaded),
             SizedBox(height: AppSizes.p8),
            Row(
              textDirection: ui.TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppAssetsIconWidget(
                  label: l.playbackPrevious,
                  onPressed: context.read<PlaybackMapCubit>().previous,
                  asset: AppAssets.skipPrevious,
                  size: AppSizes.iconSm,
                    boxDecoration: BoxDecoration(
                      color: TrackingColors.of(
                        context,
                      ).playbackPrimary.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                ),
                 SizedBox(width: AppSizes.p16),
                AppAssetsIconWidget(
                  asset: loaded.isPlaying
                      ? AppAssets.pauseIcon
                      : AppAssets.playIcon,
                  label: loaded.isPlaying
                      ? l.assetPlaybackPause
                      : l.assetPlaybackPlay,
                  onPressed: context.read<PlaybackMapCubit>().toggle,
                  containerSize: 46,
                  size: AppSizes.iconSm,
                  boxDecoration: BoxDecoration(
                    color: TrackingColors.of(context).playbackPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                AppAssetsIconWidget(
                  asset: AppAssets.skipNext,
                  label: l.playbackNext,
                  onPressed: context.read<PlaybackMapCubit>().next,
                  size: AppSizes.iconSm,
                  boxDecoration: BoxDecoration(
                    color: TrackingColors.of(
                      context,
                    ).playbackPrimary.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _scrubber(BuildContext context, PlaybackMapLoaded state) {
    final points = state.points;
    final start = points.first.recordedAt, end = points.last.recordedAt;
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TrackingColors.of(context).playbackPrimary,
            thumbColor: TrackingColors.of(context).playbackPrimary,
            inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          ),
          child: Slider(
            value: state.currentIndex.toDouble(),
            min: 0,
            max: (points.length - 1).toDouble(),
            onChanged: (v) => context.read<PlaybackMapCubit>().seek(v.round()),
            semanticFormatterCallback: (v) => DateFormat.Hm().format(
              points[v.round().clamp(0, points.length - 1)].recordedAt,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.Hm().format(start),
              semanticsLabel: '',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TrackingColors.of(context).playbackPrimary,
              ),
            ),
            Text(
              DateFormat.Hm().format(end),
              semanticsLabel: '',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TrackingColors.of(context).playbackPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlaybackGoogleMap extends StatefulWidget {
  const _PlaybackGoogleMap({
    required this.points,
    required this.index,
    required this.mapType,
    required this.bottomInset,
    required this.onCreated,
  });
  final List<PlaybackPoint> points;
  final int index;
  final MapType mapType;
  final double bottomInset;
  final ValueChanged<GoogleMapController> onCreated;
  @override
  State<_PlaybackGoogleMap> createState() => _PlaybackGoogleMapState();
}

class _PlaybackGoogleMapState extends State<_PlaybackGoogleMap> {
  GoogleMapController? _controller;
  TrackingMarkerFactory? _markerFactory;
  BitmapDescriptor? _currentMarkerIcon;
  int _markerGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_markerFactory == null) {
      _markerFactory = TrackingMarkerFactory(
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
      _updateCurrentMarker();
    }
  }

  @override
  void didUpdateWidget(covariant _PlaybackGoogleMap old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  Future<void> _updateCurrentMarker() async {
    if (_markerFactory == null) return;
    final generation = ++_markerGeneration;
    try {
      final icon = await _markerFactory!.playbackCurrent();
      if (!mounted || generation != _markerGeneration) return;
      setState(() => _currentMarkerIcon = icon);
    } catch (error, stack) {
      reportError(error, stack, source: ErrorSource.handled);
    }
  }

  @override
  void dispose() {
    _markerGeneration++;
    _markerFactory?.dispose();
    super.dispose();
  }

  Future<void> _fit() async {
    final c = _controller;
    if (c == null || widget.points.isEmpty) {
      return;
    }
    final p = widget.points;
    double minLat = p.first.latitude,
        maxLat = minLat,
        minLng = p.first.longitude,
        maxLng = minLng;
    for (final x in p) {
      minLat = minLat < x.latitude ? minLat : x.latitude;
      maxLat = maxLat > x.latitude ? maxLat : x.latitude;
      minLng = minLng < x.longitude ? minLng : x.longitude;
      maxLng = maxLng > x.longitude ? maxLng : x.longitude;
    }
    try {
      await c.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          TrackingMapLayout.fleetFitPadding,
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    final p = widget.points;
    final start = LatLng(p.first.latitude, p.first.longitude),
        end = LatLng(p.last.latitude, p.last.longitude),
        current = p[widget.index.clamp(0, p.length - 1)];
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: start, zoom: 12),
      padding: EdgeInsetsDirectional.only(
        top:
            MediaQuery.paddingOf(context).top +
            TrackingMapLayout.topBarClearance,
        bottom: widget.bottomInset,
        start: TrackingMapLayout.toolColumnClearance,
        end: TrackingMapLayout.edgeInset,
      ).resolve(Directionality.of(context)),
      mapType: widget.mapType,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: p.map((e) => LatLng(e.latitude, e.longitude)).toList(),
          color: Theme.of(context).colorScheme.primary,
          width: 3,
          geodesic: true,
        ),
      },
      markers: {
        Marker(
          markerId: const MarkerId('start'),
          position: start,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: end,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(current.latitude, current.longitude),
          rotation:
              (current.headingDegrees +
                  TrackingMarkerFactory.playbackArrowBearingCorrection) %
              360,
          anchor: const Offset(.5, .5),
          icon:
              _currentMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      },
      onMapCreated: (c) {
        _controller = c;
        widget.onCreated(c);
        _fit();
      },
    );
  }
}
