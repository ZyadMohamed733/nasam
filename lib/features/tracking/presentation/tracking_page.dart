import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../domain/tracking_vehicle.dart';
import 'cubit/tracking_cubit.dart';
import 'tracking_style.dart';
import 'widgets/tracking_controls.dart';
import 'widgets/tracking_drawer.dart';
import 'widgets/tracking_map.dart';
import 'widgets/tracking_summary.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key, required this.repository});
  final TrackingRepository repository;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => TrackingCubit(repository)..load(),
    child: const _TrackingView(),
  );
}

class _TrackingView extends StatefulWidget {
  const _TrackingView();
  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> {
  final _drawer = AdvancedDrawerController();
  GoogleMapController? _mapController;
  var _mapType = MapType.normal;

  // Cycled by the layers control; hybrid adds satellite imagery under the
  // road overlay, terrain adds elevation shading.
  static const _mapTypes = [MapType.normal, MapType.hybrid, MapType.terrain];

  @override
  void dispose() {
    _drawer.dispose();
    super.dispose();
  }

  void _cycleMapType() => setState(() {
    _mapType = _mapTypes[(_mapTypes.indexOf(_mapType) + 1) % _mapTypes.length];
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ValueListenableBuilder<AdvancedDrawerValue>(
      valueListenable: _drawer,
      builder: (context, value, _) => PopScope(
        canPop: !value.visible,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && value.visible) _drawer.hideDrawer();
        },
        child: AdvancedDrawer(
          controller: _drawer,
          rtlOpening: Directionality.of(context) == TextDirection.rtl,
          disabledGestures: true, // Map drags must not open the drawer.
          openRatio: .73,
          openScale: .94,
          initialDrawerScale: 1,
          backdropColor: TrackingStyle.drawer,
          childDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
          ),
          drawer: const TrackingDrawer(),
          child: Scaffold(
            body: BlocBuilder<TrackingCubit, TrackingState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.failed) {
                  return Center(
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
                  );
                }
                final bottomInset =
                    174.0 + MediaQuery.paddingOf(context).bottom;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: TrackingMap(
                        vehicles: state.vehicles,
                        bottomInset: bottomInset,
                        mapType: _mapType,
                        onMapReady: (controller) => _mapController = controller,
                      ),
                    ),
                    Positioned.fill(
                      bottom: bottomInset,
                      child: TrackingControls(
                        openDrawer: _drawer.showDrawer,
                        onLayersTap: _cycleMapType,
                        onZoomIn: () =>
                            _mapController?.animateCamera(CameraUpdate.zoomIn()),
                        onZoomOut: () =>
                            _mapController?.animateCamera(CameraUpdate.zoomOut()),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TrackingSummary(state: state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
