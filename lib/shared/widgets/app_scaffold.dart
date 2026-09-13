import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/di/injection_container.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/router/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/websocket_service.dart';
import 'app_bar_widget.dart';
import 'app_drawer.dart';

/// A navigation destination shown in the drawer on phones and the rail on
/// wider screens, so the two cannot drift apart.
class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

const List<AppDestination> kAppDestinations = [
  AppDestination(
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
    route: AppRoutes.home,
  ),
];

/// The one place the breakpoint is applied: [Drawer] on phones, a persistent
/// [NavigationRail] on tablet and desktop. Features get the reflow by using
/// this rather than by each deciding for itself.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showAppBar = true,
    this.showDrawer = false,
    this.useSafeArea = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.wsService,
    this.authService,
  });

  final Widget body;
  final String? title;
  final bool showAppBar;

  /// Opt-in: a page without navigation targets should not show a drawer.
  final bool showDrawer;

  /// Opt-in: the map this app is built around needs a full-bleed body, so
  /// insets are the exception rather than the default.
  final bool useSafeArea;

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  /// Overridable for tests. This shared shell is the single place the chrome's
  /// dependencies are resolved, so the leaf widgets take theirs by constructor
  /// and never reach for the service locator themselves.
  final WebSocketService? wsService;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final ws = wsService ?? getIt<WebSocketService>();
    final auth = authService ?? getIt<AuthService>();

    return ResponsiveLayout(
      mobile: _buildMobile(context, ws, auth),
      tablet: _buildWide(context, ws),
    );
  }

  Widget _wrappedBody() => useSafeArea ? SafeArea(child: body) : body;

  Widget _buildMobile(
    BuildContext context,
    WebSocketService ws,
    AuthService auth,
  ) {
    return Scaffold(
      appBar: showAppBar
          ? NasamAppBar(
              title: title,
              wsService: ws,
              showLeading: showDrawer,
            )
          : null,
      drawer: showDrawer ? AppDrawer(authService: auth) : null,
      body: _wrappedBody(),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildWide(BuildContext context, WebSocketService ws) {
    return Scaffold(
      appBar: showAppBar
          ? NasamAppBar(title: title, wsService: ws, showLeading: false)
          : null,
      body: Row(
        children: [
          if (showDrawer) ...[
            const _NavigationRail(destinations: kAppDestinations),
            const VerticalDivider(width: 1, thickness: 1),
          ],
          Expanded(child: _wrappedBody()),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.destinations});

  final List<AppDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = destinations.indexWhere((d) => d.route == location);

    return NavigationRail(
      selectedIndex: selected == -1 ? null : selected,
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
        child: Icon(Icons.local_shipping_rounded, size: AppSizes.iconLg),
      ),
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            label: Text(destination.label),
          ),
      ],
      onDestinationSelected: (index) => context.go(destinations[index].route),
    );
  }
}
