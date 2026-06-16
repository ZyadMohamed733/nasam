import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

@injectable
class RouteGuard {
  const RouteGuard(this._authService);
  final AuthService _authService;

  Future<String?> handleRedirect(BuildContext context, GoRouterState state) async {
    // Let splash through immediately, no auth check needed
    if (state.matchedLocation == AppRoutes.splash) return null;

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
