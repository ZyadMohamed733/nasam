import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../poi/presentation/cubit/poi_cubit.dart';
import '../../../poi/presentation/pages/poi_page.dart';
import '../../../history_alert/presentation/pages/history_alert_page.dart';
import '../../../tracking/presentation/pages/tracking_page.dart';
import '../widgets/home_scaffold.dart';

/// Tracking, POI and the alerts log are destinations within Home, sharing a
/// single drawer.
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
  bool _alertsVisited = false;
  @override
  void initState() {
    super.initState();
    _poiVisited = _isPoi;
    _alertsVisited = _isAlerts;
  }

  bool get _isPoi => widget.destination == DrawerDestination.pointsOfInterest;
  bool get _isAlerts => widget.destination == DrawerDestination.alertsLog;
  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPoi) _poiVisited = true;
    if (_isAlerts) _alertsVisited = true;
  }

  void _select(DrawerDestination destination) {
    if (destination == widget.destination) return;
    switch (destination) {
      case DrawerDestination.alertsLog:
        context.go(AppRoutes.alerts);
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
    onBack: _isPoi || _isAlerts
        ? () => _select(DrawerDestination.trackingDashboard)
        : null,
    builder: (context, openDrawer) => IndexedStack(
      index: _isPoi
          ? 1
          : _isAlerts
          ? 2
          : 0,
      children: [
        TrackingPage(openDrawer: openDrawer),
        if (_poiVisited)
          BlocProvider(
            create: (_) => getIt<PoiCubit>()..load(),
            child: PoiPage(openDrawer: openDrawer),
          )
        else
          const SizedBox.shrink(),
        if (_alertsVisited)
          HistoryAlertPage(
            onBack: () => _select(DrawerDestination.trackingDashboard),
            openDrawer: openDrawer,
          )
        else
          const SizedBox.shrink(),
      ],
    ),
  );
}
