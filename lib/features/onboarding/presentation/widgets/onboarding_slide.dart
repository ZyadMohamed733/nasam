import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';

/// One onboarding slide: full-bleed artwork above, copy below.
///
/// The artwork runs edge to edge and up under the status bar — it is not
/// inset by the screen padding the copy uses, and it is not wrapped in a
/// `SafeArea`. Two gradients sit over it: a violet wash at the top, which is
/// what makes white status-bar glyphs and the skip action readable against any
/// photograph, and a fade to the page colour at the bottom, so the image meets
/// the copy without a hard seam.
///
/// Both ramps are sampled from the design's own overlay export rather than
/// guessed — colour, opacity and stops all come from reading its pixels down
/// the middle. The violet is opaque at the very top, which is the point: it has
/// to carry white status-bar glyphs over whatever photograph is behind it.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;

  /// Sampled from `Over Lay.png`, the design's overlay layer exported on its
  /// own. It is not one of the palette's violets — the nearest, bluePurple500,
  /// is duller and reads as a different wash — so it is kept here, next to the
  /// thing it belongs to, rather than added to the token set as a colour the
  /// design system does not actually define.
  static const Color _overlayViolet = Color(0xFF5B21B6);

  /// The design draws the artwork 501 tall in an 874 frame. Held as a
  /// proportion rather than a fixed 501 so it keeps that share of a screen
  /// that is not the design's, instead of eating a short screen whole.
  static const double _imageHeightRatio = 501 / AppSizes.designHeight;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final page = semantic.pageBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * _imageHeightRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image,
                fit: BoxFit.cover,
                // The copy says everything the artwork does.
                excludeFromSemantics: true,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_overlayViolet, Color(0x005B21B6)],
                    stops: [0.0, 0.58],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    // Three stops, not two: the export holds near-full opacity
                    // for the first stretch and only then falls away, so a
                    // straight ramp leaves the seam visible.
                    colors: [
                      page,
                      page.withValues(alpha: 0.85),
                      page.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.15, 0.46],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        const _SheetHandle(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.p24,
              AppSizes.screenPadding,
              AppSizes.p8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // No textAlign: `start` already resolves to the right under
                // Arabic, which is how the design sets both of these.
                Text(title, style: context.textTheme.displayMedium),
                const SizedBox(height: AppSizes.p12),
                Text(
                  body,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: semantic.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The short bar the design draws where the artwork meets the copy.
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34,
        height: 4,
        decoration: BoxDecoration(
          color: context.semanticColors.containerBorder,
          borderRadius: BorderRadius.circular(AppSizes.r4),
        ),
      ),
    );
  }
}
