import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/password_reset_success_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/tracking/presentation/cubit/asset_details_cubit.dart';
import '../../features/tracking/presentation/cubit/asset_playback_cubit.dart';
import '../../features/tracking/presentation/cubit/tracked_asset_cubit.dart';
import '../../features/tracking/presentation/cubit/tracking_cubit.dart';
import '../../features/tracking/presentation/pages/tracking_asset_details_page.dart';
import '../../features/tracking/presentation/pages/tracking_asset_playback_page.dart';
import '../../features/tracking/presentation/playback_range.dart';
import '../auth/auth_session_notifier.dart';
import '../di/injection_container.dart';
import 'app_error_page.dart';
import 'app_routes.dart';
import 'app_transition_page.dart';
import 'return_path.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._routeGuard, this._session);

  final RouteGuard _routeGuard;

  /// Re-runs the guard whenever the session changes, so an expired session
  /// leaves the screen it was on for login, and a sign-in moves on from it.
  final AuthSessionNotifier _session;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter config = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: _session,
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
          // `returnTo` is untrusted input; only a validated in-app path survives.
          child: LoginPage(
            returnTo: ReturnPath.sanitize(
              state.uri.queryParameters[AppRoutes.returnToParam],
            ),
          ),
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
          child: OtpVerificationPage(
            username: state.extra! as String,
            returnTo: ReturnPath.sanitize(
              state.uri.queryParameters[AppRoutes.returnToParam],
            ),
          ),
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
          // Cubits are created here, through the container, and handed down —
          // the screens never build their own.
          child: BlocProvider(
            create: (_) => getIt<TrackingCubit>()..load(),
            child: const HomePage(),
          ),
        ),
        // Nested, so a cold deep link to an asset builds home beneath it and
        // back goes home rather than out of the app. Each screen is given an
        // id and nothing else, and resolves its own asset: a link carries no
        // object, and an unknown id shows not-found rather than redirecting.
        routes: [
          GoRoute(
            path: AppRoutes.assetDetailsPattern,
            pageBuilder: (context, state) {
              final assetId = _assetId(state);
              return appTransitionPage(
                context: context,
                state: state,
                slide: true,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => getIt<TrackedAssetCubit>()..load(assetId),
                    ),
                    BlocProvider(
                      create: (_) => getIt<AssetDetailsCubit>()..load(assetId),
                    ),
                  ],
                  child: TrackingAssetDetailsPage(assetId: assetId),
                ),
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.assetPlaybackPattern,
                pageBuilder: (context, state) {
                  final assetId = _assetId(state);
                  final query = state.uri.queryParameters;
                  return appTransitionPage(
                    context: context,
                    state: state,
                    slide: true,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) =>
                              getIt<TrackedAssetCubit>()..load(assetId),
                        ),
                        BlocProvider(
                          create: (_) => getIt<AssetPlaybackCubit>(),
                        ),
                      ],
                      child: TrackingAssetPlaybackPage(
                        assetId: assetId,
                        initialRange: PlaybackRange.fromQuery(
                          from: query[AppRoutes.fromDateParam],
                          to: query[AppRoutes.toDateParam],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The asset id from a tracking route. go_router has already decoded it.
String _assetId(GoRouterState state) =>
    state.pathParameters[AppRoutes.assetIdParam] ?? '';
