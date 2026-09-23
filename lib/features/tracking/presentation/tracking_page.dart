import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../domain/tracking_vehicle.dart';
import 'dummy_data/tracking_all_dummy_data.dart';
import 'cubit/tracking_cubit.dart';
import 'widgets/tracking_controls.dart';
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

class _TrackingViewState extends State<_TrackingView>
    with SingleTickerProviderStateMixin {
  final _drawer = AdvancedDrawerController();
  // Keep the transition alive across visibility-driven rebuilds. The package
  // recreates its default controller in didUpdateWidget, which skips motion.
  late final _drawerAnimation = AnimationController(vsync: this);
  late final _drawerFade = CurvedAnimation(
    parent: _drawerAnimation,
    curve: Curves.easeInOutCubic,
  );
  GoogleMapController? _mapController;
  var _mapType = MapType.normal;
  var _summaryExpanded = false;
  static const _summaryMinSize = .23;
  static const _summaryMaxSize = .75;
  late final _summaryController = DraggableScrollableController();

  // Cycled by the layers control; hybrid adds satellite imagery under the
  // road overlay, terrain adds elevation shading.
  static const _mapTypes = [MapType.normal, MapType.hybrid, MapType.terrain];

  @override
  void dispose() {
    _summaryController.dispose();
    _drawerFade.dispose();
    _drawerAnimation.dispose();
    _drawer.dispose();
    super.dispose();
  }

  void _cycleMapType() => setState(() {
    _mapType = _mapTypes[(_mapTypes.indexOf(_mapType) + 1) % _mapTypes.length];
  });

  bool _onSummaryExtentChanged(DraggableScrollableNotification notification) {
    final expanded = notification.extent >= _summaryMaxSize - .005;
    final collapsed = notification.extent <= _summaryMinSize + .005;
    if ((expanded && !_summaryExpanded) || (collapsed && _summaryExpanded)) {
      setState(() => _summaryExpanded = expanded);
    }
    return false;
  }

  void _toggleSummary() {
    if (!_summaryController.isAttached) return;
    _summaryController.animateTo(
      _summaryController.size < .5 ? _summaryMaxSize : _summaryMinSize,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

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
          animationCurve: Curves.easeInOutCubic,
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : Durations.long2,
          animateChildDecoration: true,
          controller: _drawer,
          animationController: _drawerAnimation,
          drawerSlideRatio: Directionality.of(context) == TextDirection.rtl
              ? -AppSizes.drawerSlideRatio
              : AppSizes.drawerSlideRatio,
          rtlOpening: Directionality.of(context) == TextDirection.rtl,
          disabledGestures: true, // Map drags must not open the drawer.
          openRatio:
              (AppSizes.drawerMaxWidth / MediaQuery.sizeOf(context).width)
                  .clamp(0.0, AppSizes.drawerOpenRatio),
          openScale: AppSizes.drawerOpenScale,
          initialDrawerScale: AppSizes.drawerInitialScale,
          backdrop: const AppDrawerBackground(),
          childDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.r32),
          ),
          drawer: FadeTransition(
            opacity: _drawerFade,
            child: AppDrawer(
              showBackground: false,
              onLogout: () async {
                await getIt<LogoutUseCase>()();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ),
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
                    MediaQuery.sizeOf(context).height *
                    (_summaryExpanded ? _summaryMaxSize : _summaryMinSize);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: TrackingMap(
                        vehicles: state.vehicles,
                        bottomInset: bottomInset,
                        mapType: _mapType,
                        onMapReady: (controller) => _mapController = controller,
                        onVehicleTap: (vehicle) {
                          final id = int.tryParse(vehicle.id);
                          if (id == null || TrackingAllDummyData.vehicles.isEmpty) {
                            return;
                          }
                          final detailsVehicle = TrackingAllDummyData
                              .vehicles[(id - 1) % TrackingAllDummyData.vehicles.length];
                          context.push(
                            AppRoutes.trackingVehicleDetails,
                            extra: detailsVehicle,
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      bottom: bottomInset,
                      child: TrackingControls(
                        openDrawer: _drawer.showDrawer,
                        onLayersTap: _cycleMapType,
                        onZoomIn: () => _mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        ),
                        onZoomOut: () => _mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        ),
                      ),
                    ),
                    NotificationListener<DraggableScrollableNotification>(
                      onNotification: _onSummaryExtentChanged,
                      child: DraggableScrollableSheet(
                        controller: _summaryController,
                        initialChildSize: _summaryMinSize,
                        minChildSize: _summaryMinSize,
                        maxChildSize: _summaryMaxSize,
                        snap: true,
                        snapSizes: const [_summaryMinSize, _summaryMaxSize],
                        builder: (context, scrollController) => TrackingSummary(
                          state: state,
                          expanded: _summaryExpanded,
                          scrollController: scrollController,
                          sheetController: _summaryController,
                          minSheetExtent: _summaryMinSize,
                          maxSheetExtent: _summaryMaxSize,
                          onShowTap: _toggleSummary,
                        ),
                      ),
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
