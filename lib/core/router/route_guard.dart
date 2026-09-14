import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

@injectable
class RouteGuard {
  const RouteGuard(this._authService);
  final AuthService _authService;

  /// Reachable without a session — the whole point of them is that the user
  /// cannot sign in yet. Password reset belongs here too: a user who has
  /// forgotten their password is by definition not authenticated.
  static const Set<String> _publicRoutes = {
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.otpVerification,
    AppRoutes.newPassword,
  };

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
    final isPublic = _publicRoutes.contains(state.matchedLocation);

    if (!isAuth) {
      return isPublic ? null : AppRoutes.login;
    }
    // Someone already signed in has no business in the sign-in flow.
    return isPublic ? AppRoutes.home : null;
  }
}
