import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main destinations fade; drill-down steps also move in reading direction.
Page<void> appTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  bool slide = false,
}) {
  if (MediaQuery.disableAnimationsOf(context)) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }

  final direction = Directionality.of(context) == TextDirection.rtl
      ? -1.0
      : 1.0;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: RepaintBoundary(child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Also respond if reduced motion is enabled during an active transition.
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final progress = animation.drive(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: progress,
        child: slide
            ? SlideTransition(
                position: progress.drive(
                  Tween<Offset>(
                    begin: Offset(0.06 * direction, 0),
                    end: Offset.zero,
                  ),
                ),
                child: child,
              )
            : child,
      );
    },
  );
}
