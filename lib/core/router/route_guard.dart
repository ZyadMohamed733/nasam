import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../services/auth_service.dart';
import 'app_routes.dart';
import 'return_path.dart';

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
    AppRoutes.passwordResetSuccess,
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
      if (isPublic) return null;
      // Keep where they were going, so a deep link that meets the login
      // screen still ends up where it pointed. Only a validated in-app path is
      // carried — see ReturnPath — and home is left off as the default anyway.
      final target = ReturnPath.sanitize(state.uri.toString());
      return target == null || target == AppRoutes.home
          ? AppRoutes.login
          : AppRoutes.loginReturningTo(target);
    }

    // Someone already signed in has no business in the sign-in flow. If the
    // link they followed was carrying a target, honour it rather than
    // dropping them on home.
    if (isPublic) {
      return ReturnPath.sanitize(
            state.uri.queryParameters[AppRoutes.fromParam],
          ) ??
          AppRoutes.home;
    }
    return null;
  }
}
