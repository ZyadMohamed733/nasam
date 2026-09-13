import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The onboarding progress indicator.
///
/// The design gives the block as 60x8 with three dots. It does not give the
/// per-dot split, and two readings both sum to 60: three 8pt dots with 18pt
/// gaps, or an elongated active dot — 24 + 8 + 8 with 10pt gaps — which is the
/// commoner onboarding pattern and what is used here. Both are one constructor
/// argument apart, so correct it here if the design says otherwise.
///
/// Direction is not handled manually: a [Row] already lays out right-to-left
/// under an RTL [Directionality], so the progression runs the way the reader
/// does.
class AppPageDots extends StatelessWidget {
  const AppPageDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.dotSize = 8.0,
    this.activeDotWidth = 24.0,
    this.gap = 10.0,
  }) : assert(count > 0, 'A page indicator needs at least one page'),
       assert(
         activeIndex >= 0 && activeIndex < count,
         'activeIndex must be within the page count',
       );

  final int count;
  final int activeIndex;
  final double dotSize;
  final double activeDotWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Semantics(
      label: 'Page ${activeIndex + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: gap),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: i == activeIndex ? activeDotWidth : dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: i == activeIndex
                    ? semantic.primary
                    : semantic.containerBorder,
                borderRadius: BorderRadius.circular(AppSizes.r4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
