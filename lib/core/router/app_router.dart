import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/cubit/password_recovery_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/password_reset_success_page.dart';
import '../../features/auth/presentation/pages/reset_code_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/history_alert/presentation/pages/history_alert_page.dart';
import '../../features/history_alert/presentation/pages/history_alert_details_page.dart';
import '../../features/history_alert/domain/entities/history_alert.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/play_back/presentation/cubit/playback_map_cubit.dart';
import '../../features/play_back/presentation/pages/playback_map_page.dart';
import '../../features/play_back/presentation/pages/playback_page.dart';
import '../../features/play_back/presentation/cubit/playback_cubit.dart';
import '../../features/play_back/presentation/utils/playback_range.dart';
import '../../features/poi/presentation/cubit/poi_editor_cubit.dart';
import '../../features/poi/presentation/cubit/poi_import_cubit.dart';
import '../../features/poi/presentation/pages/poi_details_page.dart';
import '../../features/poi/presentation/pages/poi_editor_page.dart';
import '../../features/poi/presentation/pages/poi_import_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/tracking/presentation/cubit/asset_details_cubit.dart';
import '../../features/tracking/presentation/cubit/tracked_asset_cubit.dart';
import '../../features/tracking/presentation/cubit/tracking_cubit.dart';
import '../../features/tracking/presentation/pages/tracking_asset_details_page.dart';
import '../../shared/widgets/app_drawer.dart';
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
      // Password recovery. One shell around its three screens owns the
      // PasswordRecoveryCubit — the email, and the reset token once the code
      // is verified — so leaving the flow in any direction (back to login,
      // on to the success screen, a cold start into its middle) disposes the
      // cubit and the token with it. Nothing about the flow is in a URL.
      ShellRoute(
        pageBuilder: (context, state, child) => appTransitionPage(
          context: context,
          state: state,
          slide: true,
          child: BlocProvider(
            create: (_) => getIt<PasswordRecoveryCubit>(),
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.forgotPassword,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ForgotPasswordPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.resetCode,
            pageBuilder: (context, state) => appTransitionPage(
              context: context,
              state: state,
              slide: true,
              child: const ResetCodePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.newPassword,
            pageBuilder: (context, state) => appTransitionPage(
              context: context,
              state: state,
              slide: true,
              child: const NewPasswordPage(),
            ),
          ),
        ],
      ),
      // OTP verification is login's second factor, reached from `login` with
      // the username that started the attempt. Password recovery has its own
      // code screen (AppRoutes.resetCode). An arrival without that state
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
      GoRoute(
        path: AppRoutes.passwordResetSuccess,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          child: const PasswordResetSuccessPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.alertsLog,
        pageBuilder: (context, state) => appTransitionPage(
          context: context,
          state: state,
          slide: true,
          child: const HistoryAlertPage(),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.alertDetailsPattern,
            redirect: (context, state) =>
                state.extra is HistoryAlertEntity ? null : AppRoutes.alertsLog,
            pageBuilder: (context, state) => appTransitionPage(
              context: context,
              state: state,
              slide: true,
              child: HistoryAlertDetailsPage(
                alert: state.extra! as HistoryAlertEntity,
              ),
            ),
          ),
        ],
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
            child: HomePage(
              destination:
                  state.uri.path.startsWith('/poi/') ||
                      state.uri.queryParameters[AppRoutes.homeViewParam] ==
                          AppRoutes.poiView
                  ? DrawerDestination.pointsOfInterest
                  : DrawerDestination.trackingDashboard,
            ),
          ),
        ),
        // Nested, so a cold deep link to an asset builds home beneath it and
        // back goes home rather than out of the app. Each screen is given an
        // id and nothing else, and resolves its own asset: a link carries no
        // object, and an unknown id shows not-found rather than redirecting.
        routes: [
          GoRoute(
            path: 'poi/create',
            pageBuilder: (context, state) => appTransitionPage(
              context: context,
              state: state,
              slide: true,
              child: BlocProvider(
                create: (_) => getIt<PoiEditorCubit>(),
                child: const PoiEditorPage(),
              ),
            ),
          ),
          GoRoute(
            path: 'poi/import',
            pageBuilder: (context, state) => appTransitionPage(
              context: context,
              state: state,
              slide: true,
              child: BlocProvider(
                create: (_) => getIt<PoiImportCubit>(),
                child: const PoiImportPage(),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.poiDetailsPattern,
            pageBuilder: (context, state) {
              final id = state.pathParameters[AppRoutes.poiIdParam]!;
              return appTransitionPage(
                context: context,
                state: state,
                slide: true,
                child: BlocProvider(
                  create: (_) => getIt<PoiEditorCubit>()..load(id),
                  child: PoiDetailsPage(pointId: id),
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) {
                  final id = state.pathParameters[AppRoutes.poiIdParam]!;
                  return appTransitionPage(
                    context: context,
                    state: state,
                    slide: true,
                    child: BlocProvider(
                      create: (_) => getIt<PoiEditorCubit>()..load(id),
                      child: PoiEditorPage(pointId: id),
                    ),
                  );
                },
              ),
            ],
          ),
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
                        BlocProvider(create: (_) => getIt<PlaybackCubit>()),
                      ],
                      child: PlaybackPage(
                        assetId: assetId,
                        initialRange: PlaybackRange.fromQuery(
                          from: query[AppRoutes.fromDateParam],
                          to: query[AppRoutes.toDateParam],
                        ),
                      ),
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: AppRoutes.assetPlaybackMapPattern,
                    pageBuilder: (context, state) => appTransitionPage(
                      context: context,
                      state: state,
                      slide: true,
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) =>
                                getIt<TrackedAssetCubit>()
                                  ..load(_assetId(state)),
                          ),
                          BlocProvider(
                            create: (_) => getIt<PlaybackMapCubit>(),
                          ),
                        ],
                        child: PlaybackMapPage(
                          assetId: _assetId(state),
                          initialRange: PlaybackRange.fromQuery(
                            from: state
                                .uri
                                .queryParameters[AppRoutes.fromDateParam],
                            to: state
                                .uri
                                .queryParameters[AppRoutes.toDateParam],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
