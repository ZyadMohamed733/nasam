import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../home/presentation/widgets/home_scaffold.dart';

import '../cubit/tracking_cubit.dart';
import '../widgets/tracking_controls.dart';
import '../widgets/tracking_map.dart';
import '../widgets/tracking_summary.dart';

/// The map, the drawer and the fleet sheet.
///
/// Expects a [TrackingCubit] above it. The route creates that cubit through
/// `getIt`; the page never builds its own, so it can be pumped in a test over
/// a cubit in any state.
class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key, this.openDrawer});

  final VoidCallback? openDrawer;

  @override
  Widget build(BuildContext context) => openDrawer != null
      ? _TrackingView(openDrawer: openDrawer!)
      : HomeScaffold(
          builder: (context, openDrawer) =>
              _TrackingView(openDrawer: openDrawer),
        );
}

class _TrackingView extends StatefulWidget {
  const _TrackingView({required this.openDrawer});
  final VoidCallback openDrawer;
  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> {
  final _map = TrackingMapController();
  var _mapType = MapType.normal;
  late final _summaryController = DraggableScrollableController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  /// The fleet sheet's header as laid out — handle, title and chips at the
  /// current text scale. The collapsed sheet is exactly this tall.
  double? _headerHeight;

  /// The sheet's extent as it last reported it, as a fraction of the body.
  /// Null until it first moves: it is then at its collapsed size.
  double? _sheetExtent;

  /// The sizes last built with, for the toggle.
  var _sheetSizes = (min: 0.0, max: 1.0);

  /// Until the header has been measured once.
  static const _headerEstimate = 160.0;

  /// The open sheet's share of the body, from the design.
  static const _expandedFraction = .75;

  /// However short the screen, the open sheet is at least this much taller
  /// than the collapsed one, so the list is always reachable.
  static const _minimumTravel = .1;

  // Cycled by the layers control; hybrid adds satellite imagery under the
  // road overlay, terrain adds elevation shading.
  static const _mapTypes = [MapType.normal, MapType.hybrid, MapType.terrain];

  @override
  void dispose() {
    _summaryController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _cycleMapType() => setState(() {
    _mapType = _mapTypes[(_mapTypes.indexOf(_mapType) + 1) % _mapTypes.length];
  });

  /// The sheet's collapsed and open sizes for a body [available] tall.
  ///
  /// From the space the sheet actually has, not the screen: the body is
  /// shorter than the screen by whatever sits above it.
  ({double min, double max}) _sizesFor(double available, double bottomSafe) {
    final collapsed = (_headerHeight ?? _headerEstimate) + bottomSafe;
    final min = (collapsed / available).clamp(0.0, 1.0 - _minimumTravel);
    final max = (min + _minimumTravel).clamp(_expandedFraction, 1.0);
    return (min: min, max: max);
  }

  bool _onSummaryExtentChanged(DraggableScrollableNotification notification) {
    if (notification.extent != _sheetExtent) {
      setState(() => _sheetExtent = notification.extent);
    }
    return false;
  }

  void _onHeaderSize(Size size) {
    if (size.height == _headerHeight) return;
    setState(() {
      // A sheet resting collapsed stays collapsed at the new size.
      final extent = _sheetExtent;
      if (extent != null && (extent - _sheetSizes.min).abs() < .01) {
        _sheetExtent = null;
      }
      _headerHeight = size.height;
    });
  }

  bool get _summaryExpanded {
    final extent = _sheetExtent ?? _sheetSizes.min;
    return extent > (_sheetSizes.min + _sheetSizes.max) / 2;
  }

  void _toggleSummary() {
    if (!_summaryController.isAttached) return;
    _summaryController.animateTo(
      _summaryExpanded ? _sheetSizes.min : _sheetSizes.max,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<TrackingCubit>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocConsumer<TrackingCubit, TrackingState>(
        // A failed refresh keeps the last fleet on screen and says so
        // here, rather than replacing the map with an error page.
        listenWhen: (_, state) =>
            state is TrackingFailure && state.previous != null,
        listener: (context, _) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l.errorGeneric),
                action: SnackBarAction(
                  label: l.retry,
                  onPressed: context.read<TrackingCubit>().load,
                ),
              ),
            );
        },
        builder: (context, state) {
          final data = state.visible;
          if (data == null) {
            return switch (state) {
              TrackingEmpty() => Center(child: Text(l.emptyState)),
              TrackingFailure() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.errorGeneric),
                    TextButton(
                      onPressed: context.read<TrackingCubit>().load,
                      child: Text(l.retry),
                    ),
                  ],
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            };
          }
          return LayoutBuilder(
            builder: (context, constraints) =>
                _fleet(context, data, constraints.maxHeight),
          );
        },
      ),
    );
  }

  Widget _fleet(BuildContext context, TrackingLoaded data, double available) {
    final sizes = _sheetSizes = _sizesFor(
      available,
      MediaQuery.paddingOf(context).bottom,
    );
    final extent = (_sheetExtent ?? sizes.min).clamp(sizes.min, sizes.max);
    // What the sheet covers, so the map frames the fleet above it and the
    // controls stay clear of it — at whatever height it has been dragged to.
    final bottomInset = extent * available;
    return Stack(
      children: [
        Positioned.fill(
          child: TrackingMap(
            vehicles: data.vehicles,
            bottomInset: bottomInset,
            mapType: _mapType,
            controller: _map,
            onVehicleTap: (vehicle) {
              final asset = context.read<TrackingCubit>().assetForVehicle(
                vehicle,
              );
              if (asset == null) return;
              context.push(AppRoutes.assetDetails(asset.id));
            },
          ),
        ),
        Positioned.fill(
          bottom: bottomInset,
          child: TrackingControls(
            openDrawer: widget.openDrawer,
            // Pushed over Home, so back returns to this map.
            onNotificationsTap: () => context.push(AppRoutes.alertsLog),
            onLayersTap: _cycleMapType,
            onZoomIn: _map.zoomIn,
            onZoomOut: _map.zoomOut,
          ),
        ),
        NotificationListener<DraggableScrollableNotification>(
          onNotification: _onSummaryExtentChanged,
          child: DraggableScrollableSheet(
            controller: _summaryController,
            initialChildSize: sizes.min,
            minChildSize: sizes.min,
            maxChildSize: sizes.max,
            snap: true,
            snapSizes: [sizes.min, sizes.max],
            builder: (context, scrollController) => TrackingSummary(
              state: data,
              expanded: _summaryExpanded,
              scrollController: scrollController,
              searchController: _searchController,
              searchFocusNode: _searchFocus,
              onToggle: _toggleSummary,
              onHeaderSize: _onHeaderSize,
              onClearFilters: _clearFilters,
            ),
          ),
        ),
      ],
    );
  }
}
