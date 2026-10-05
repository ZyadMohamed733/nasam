import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../poi/presentation/cubit/poi_cubit.dart';
import '../../../poi/presentation/pages/poi_page.dart';
import '../../../tracking/presentation/pages/tracking_page.dart';
import '../widgets/home_scaffold.dart';

/// Tracking and POI are destinations within Home, sharing a single drawer;
/// the drawer's alerts log opens as its own page above Home.
/// A visited map remains mounted so switching preserves camera/search state.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.destination = DrawerDestination.trackingDashboard,
  });
  final DrawerDestination destination;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _poiVisited = false;
  @override
  void initState() {
    super.initState();
    _poiVisited = _isPoi;
  }

  bool get _isPoi => widget.destination == DrawerDestination.pointsOfInterest;
  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPoi) _poiVisited = true;
  }

  void _select(DrawerDestination destination) {
    if (destination == widget.destination) return;
    switch (destination) {
      // The alerts log is its own page over Home, not a Home tab: pushed,
      // so its back button returns to the map the user left.
      case DrawerDestination.alertsLog:
        context.push(AppRoutes.alertsLog);
      case DrawerDestination.pointsOfInterest:
        context.go(AppRoutes.poi);
      case _:
        context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) => HomeScaffold(
    selected: widget.destination,
    available: const {
      DrawerDestination.trackingDashboard,
      DrawerDestination.pointsOfInterest,
      DrawerDestination.alertsLog,
    },
    onSelect: _select,
    onBack: _isPoi ? () => _select(DrawerDestination.trackingDashboard) : null,
    builder: (context, openDrawer) => IndexedStack(
      index: _isPoi ? 1 : 0,
      children: [
        TrackingPage(openDrawer: openDrawer),
        if (_poiVisited)
          BlocProvider(
            create: (_) => getIt<PoiCubit>()..load(),
            child: PoiPage(openDrawer: openDrawer),
          )
        else
          const SizedBox.shrink(),
      ],
    ),
  );
}
