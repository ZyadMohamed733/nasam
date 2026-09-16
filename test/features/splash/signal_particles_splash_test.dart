import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/constants/app_assets.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/features/splash/presentation/pages/splash_page.dart';
import 'package:nasam/features/splash/presentation/widgets/signal_particles_splash.dart';

class _MockStorage extends Mock implements StorageService {}

void main() {
  testWidgets('GIF timing matches single-cycle completion', (tester) async {
    await tester.runAsync(() async {
      final bytes = await File(AppAssets.splashParticles).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        expect(codec.frameCount, 99);
        var duration = Duration.zero;
        for (var i = 0; i < codec.frameCount; i++) {
          final frame = await codec.getNextFrame();
          duration += frame.duration;
          expect(frame.image.width, 540);
          expect(frame.image.height, 1174);
          if (i == codec.frameCount - 1) {
            expect(frame.duration, const Duration(milliseconds: 40));
          }
          frame.image.dispose();
        }
        expect(duration, const Duration(seconds: 4));
      } finally {
        codec.dispose();
      }
    });
  });

  testWidgets('reduced motion completes once without playing the GIF', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SignalParticlesSplash(onCompleted: () => completions++),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 5));
    expect(completions, 1);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.splashParticles,
      ),
      findsNothing,
    );
  });

  for (final seenOnboarding in [false, true]) {
    testWidgets('completion routes with onboarding=$seenOnboarding', (
      tester,
    ) async {
      final storage = _MockStorage();
      when(() => storage.hasSeenOnboarding).thenReturn(seenOnboarding);
      final router = GoRouter(
        initialLocation: AppRoutes.splash,
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => SplashPage(storage: storage),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Text('home destination'),
          ),
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => const Text('onboarding destination'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          seenOnboarding ? 'home destination' : 'onboarding destination',
        ),
        findsOneWidget,
      );
    });
  }
}
