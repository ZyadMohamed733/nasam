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
import 'cubit/tracking_cubit.dart';
import 'widgets/tracking_controls.dart';
import 'widgets/tracking_map.dart';
import 'widgets/tracking_summary.dart';

/// The map, the drawer and the fleet sheet.
///
/// Expects a [TrackingCubit] above it. The route creates that cubit through
/// `getIt`; the page never builds its own, so it can be pumped in a test over
/// a cubit in any state.
class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) => const _TrackingView();
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
                final bottomInset =
                    MediaQuery.sizeOf(context).height *
                    (_summaryExpanded ? _summaryMaxSize : _summaryMinSize);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: TrackingMap(
                        vehicles: data.vehicles,
                        bottomInset: bottomInset,
                        mapType: _mapType,
                        onMapReady: (controller) => _mapController = controller,
                        onVehicleTap: (vehicle) {
                          final asset = context
                              .read<TrackingCubit>()
                              .assetForVehicle(vehicle);
                          if (asset == null) return;
                          context.push(AppRoutes.assetDetails(asset.id));
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
                          state: data,
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
