import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../widgets/signal_particles_splash.dart';

/// Plays the launch animation, then chooses onboarding or home.
/// The route guard redirects home to login when the user is signed out.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key, this.storage});

  /// Injected in tests; resolved from the container otherwise.
  final StorageService? storage;

  @override
  Widget build(BuildContext context) {
    final store = storage ?? getIt<StorageService>();

    return SignalParticlesSplash(
      onCompleted: () {
        if (!context.mounted) return;
        context.go(
          store.hasSeenOnboarding ? AppRoutes.home : AppRoutes.onboarding,
        );
      },
    );
  }
}
