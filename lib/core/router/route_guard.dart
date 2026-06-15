import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

@injectable
class RouteGuard {
  const RouteGuard(this._authService);
  final AuthService _authService;

  Future<String?> initRoute(BuildContext context, GoRouterState state) async {
    final isAuth = await _authService.isAuthenticated;
    final goingToLogin = state.matchedLocation == AppRoutes.login;
    final goingToSplash = state.matchedLocation == AppRoutes.splash;

    if (!isAuth) {
      // Redirect to login if user is not authenticated and trying to access restricted routes
      if (!goingToLogin && !goingToSplash) {
        return AppRoutes.login;
      }
    } else {
      // Redirect to home if user is authenticated and trying to hit the login page
      if (goingToLogin) {
        return AppRoutes.home;
      }
    }

    return null; // No redirection required
  }
}
