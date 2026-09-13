import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/widgets/pixel_swap_splash.dart';
import '../constants/app_assets.dart';
import 'app_error_page.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._routeGuard);

  final RouteGuard _routeGuard;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter config = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) => _routeGuard.handleRedirect(context, state),
    errorBuilder: (context, state) => AppErrorPage(error: state.error),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => PixelSwapSplash(
          emblem: SvgPicture.asset(AppAssets.logoVector),
          next: Container(),
          onCompleted: () => {},
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
