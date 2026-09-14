import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

@injectable
class RouteGuard {
  const RouteGuard(this._authService);
  final AuthService _authService;

  Future<String?> handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    // Splash and onboarding run before anyone has signed in, so neither is
    // subject to the auth check — splash is what decides where to go next, and
    // bouncing onboarding to login would make it unreachable.
    if (state.matchedLocation == AppRoutes.splash ||
        state.matchedLocation == AppRoutes.onboarding) {
      return null;
    }

    final isAuth = await _authService.isAuthenticated;
    final goingToLogin = state.matchedLocation == AppRoutes.login;

    if (!isAuth) {
      if (!goingToLogin) return AppRoutes.login;
    } else {
      if (goingToLogin) return AppRoutes.home;
    }

    return null;
  }
}
