import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../auth/auth_session_notifier.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';
import 'return_path.dart';

@injectable
class RouteGuard {
  const RouteGuard(this._authService, this._session);
  final AuthService _authService;
  final AuthSessionNotifier _session;

  /// Reachable without a session — the whole point of them is that the user
  /// cannot sign in yet. Password reset belongs here too: a user who has
  /// forgotten their password is by definition not authenticated.
  static const Set<String> _publicRoutes = {
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.resetCode,
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
      // A deliberate sign-out starts clean: whoever signs in next may not be
      // the person who left, and has no business landing on their screen.
      if (_session.endedByUser) return AppRoutes.login;
      // Keep where they were going, so a protected location that meets the
      // login screen still ends up where it pointed. Only a validated in-app path is
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
            state.uri.queryParameters[AppRoutes.returnToParam],
          ) ??
          AppRoutes.home;
    }
    return null;
  }
}
