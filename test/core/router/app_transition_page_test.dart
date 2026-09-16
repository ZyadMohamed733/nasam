import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nasam/core/router/app_transition_page.dart';

void main() {
  Future<GoRouter> mount(
    WidgetTester tester, {
    bool reduceMotion = false,
    TextDirection direction = TextDirection.ltr,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('start')),
        ),
        GoRoute(
          path: '/next',
          pageBuilder: (context, state) => appTransitionPage(
            context: context,
            state: state,
            child: const Scaffold(body: Text('destination')),
          ),
        ),
        GoRoute(
          path: '/detail',
          pageBuilder: (context, state) => appTransitionPage(
            context: context,
            state: state,
            slide: true,
            child: const Scaffold(body: Text('detail')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: Directionality(textDirection: direction, child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('replacement fades in and completes within 300ms', (
    tester,
  ) async {
    final router = await mount(tester);
    router.go('/next');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('destination'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, greaterThan(0));
    expect(fade.opacity.value, lessThan(1));
    await tester.pump(const Duration(milliseconds: 210));
    expect(fade.opacity.value, 1);
    expect(router.canPop(), isFalse);
  });

  for (final direction in TextDirection.values) {
    testWidgets('push/pop slides in $direction reading direction', (
      tester,
    ) async {
      final router = await mount(tester, direction: direction);
      final popped = router.push<void>('/detail');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final slide = tester.widget<SlideTransition>(
        find
            .ancestor(
              of: find.text('detail'),
              matching: find.byType(SlideTransition),
            )
            .first,
      );
      expect(
        slide.position.value.dx,
        direction == TextDirection.rtl ? lessThan(0) : greaterThan(0),
      );
      await tester.pumpAndSettle();
      expect(router.canPop(), isTrue);
      router.pop();
      await tester.pump();
      await tester.pumpAndSettle();
      await popped;
      expect(find.text('start'), findsOneWidget);
      expect(find.text('detail'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion replaces screens without a transition', (
    tester,
  ) async {
    final router = await mount(tester, reduceMotion: true);
    router.go('/next');
    await tester.pump();
    await tester.pump();
    expect(find.text('destination'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('destination'),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
