import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
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
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // The two steps below carry state from the previous one — the address,
      // then the reset token — and neither means anything without it. Rather
      // than let them build with a placeholder, an arrival without that state
      // restarts the flow: it is what a cold deep link, or a resume after the
      // app was evicted, actually amounts to.
      GoRoute(
        path: AppRoutes.otpVerification,
        redirect: (context, state) =>
            state.extra is String ? null : AppRoutes.forgotPassword,
        builder: (context, state) =>
            OtpVerificationPage(email: state.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        redirect: (context, state) =>
            state.extra is String ? null : AppRoutes.forgotPassword,
        builder: (context, state) =>
            NewPasswordPage(resetToken: state.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
