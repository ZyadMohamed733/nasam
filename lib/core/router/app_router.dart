import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/tracking/presentation/dummy_data/tracking_all_dummy_data.dart';
import '../../features/tracking/presentation/pages/tracking_vehicle_details_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/password_reset_success_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_error_page.dart';
import 'app_routes.dart';
import 'app_transition_page.dart';
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
    errorPageBuilder: (context, state) => appTransitionPage(
      context: context,
      state: state,
      child: AppErrorPage(error: state.error),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: false,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: false,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: true,
          child: const ForgotPasswordPage(),
        ),
      ),
      // OTP verification is login's second factor now, reached from `login`
      // with the username that started the attempt -- not from
      // forgot-password, which is web-only (see
      // docs/plans/AUTH_INTEGRATION_PLAN.md). An arrival without that state
      // (a cold deep link, a resume after the app was evicted) restarts the
      // flow at login rather than building with a placeholder.
      GoRoute(
        path: AppRoutes.otpVerification,
        redirect: (context, state) =>
            state.extra is String ? null : AppRoutes.login,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: true,
          child: OtpVerificationPage(username: state.extra! as String),
        ),
      ),
      // newPassword/passwordResetSuccess below carry the reset token from
      // the emailed link. Nothing currently navigates to them -- reset is
      // web-only for now -- but the implementation is correct and complete
      // against PATCH /auth/reset-password, ready for a future deep-link
      // handler to land on (see docs/plans/AUTH_INTEGRATION_PLAN.md).
      GoRoute(
        path: AppRoutes.newPassword,
        redirect: (context, state) =>
            state.extra is String ? null : AppRoutes.forgotPassword,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: true,
          child: NewPasswordPage(resetToken: state.extra! as String),
        ),
      ),
      GoRoute(
        path: AppRoutes.passwordResetSuccess,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          child: const PasswordResetSuccessPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: false,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.trackingVehicleDetails,
        redirect: (context, state) =>
            state.extra is TrackingAllDummyVehicle ? null : AppRoutes.home,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: true,
          child: TrackingVehicleDetailsPage(
            vehicle: state.extra! as TrackingAllDummyVehicle,
          ),
        ),
      ),
    ],
  );
}
