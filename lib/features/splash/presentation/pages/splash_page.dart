import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../widgets/pixel_swap_splash.dart';

/// The launch screen, and the only place that decides where a cold start goes.
///
/// Two splashes used to exist: this page, which faded to home on a two-second
/// timer, and a [PixelSwapSplash] built inline in the router whose
/// `onCompleted` was an empty lambda — so the animation finished and nothing
/// happened. The reveal animation is the design's; the routing decision is
/// this page's; there is now one of each.
///
/// Only two destinations are chosen here: the intro, for anyone who has not
/// seen it, or home. Home is not an assertion that the user is signed in —
/// `RouteGuard` turns it into the login screen when they are not, which keeps
/// the auth rule in one place rather than splitting it across two.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key, this.storage});

  /// Injected in tests; resolved from the container otherwise.
  final StorageService? storage;

  @override
  Widget build(BuildContext context) {
    final store = storage ?? getIt<StorageService>();

    return PixelSwapSplash(
      emblem: const AppLogo(size: AppLogoSize.large),
      // What the reveal wipes onto. The real destination is a route, not a
      // widget, so this is the plate the animation ends on rather than the
      // next screen itself.
      next: const ColoredBox(color: AppColors.darkPurple800),
      onCompleted: () {
        if (!context.mounted) return;
        context.go(
          store.hasSeenOnboarding ? AppRoutes.home : AppRoutes.onboarding,
        );
      },
    );
  }
}
