import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_logo.dart';

/// The shell every auth screen sits in.
///
/// The design puts these screens on a dark violet backdrop with the brand
/// lockup, a heading and a line of explanation over it, and drops the form into
/// a white card floating on top. Four screens repeating that by hand is four
/// chances to drift, so it lives here.
///
/// It is dark regardless of the app's theme. The backdrop is a fixed violet
/// artwork, so the card, its text and the headings above it are pinned to the
/// values that read against it rather than taken from the semantic tokens —
/// those follow the user's light/dark choice, which the artwork does not.
///
/// It scrolls, because the keyboard takes roughly half a phone screen and these
/// screens are only comfortably short until someone focuses a field.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.card,
    this.subtitle,
    this.below = const [],
  });

  final String title;
  final String? subtitle;

  /// The form. Laid out inside the white card, stretched to its width.
  final List<Widget> card;

  /// Anything that belongs on the backdrop *under* the card rather than inside
  /// it — the new-password rule checklist is the case the design has.
  final List<Widget> below;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bluePurple700,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Reuse the splash raster and image cache so the handoff has no
          // background jump or first-use SVG parsing during navigation.
          Image.asset(
            AppAssets.splashBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            excludeFromSemantics: true,
          ),
          SafeArea(
            child: SingleChildScrollView(
              // The design insets the auth card 21 a side, giving it 360 of a
              // 402 frame — wider than the 16 general screens use.
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p20,
                vertical: AppSizes.p24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.p48),
                  const _BrandLockup(),
                  const SizedBox(height: AppSizes.p32),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.displaySmall?.copyWith(
                      color: AppColors.neutralWhite,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.bluePurple200,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.p32),
                  _FormCard(children: card),
                  if (below.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.p24),
                    ...below,
                  ],
                  const SizedBox(height: AppSizes.p32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The white sheet the form sits on.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Horizontal 20 is measured; vertical reads larger than that in the
      // reference, though the card's rounded corners make its true top edge
      // hard to pin from a screenshot. Worth confirming against the Figma.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p20,
        vertical: AppSizes.p24,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// The wordmark beside the mark, as the design sets it.
///
/// TODO(design): the wordmark is type here, not artwork. Only the hexagon was
/// exported (`logo_mark.png`), so "NASAM" is set in Almarai and will not match
/// the drawn letterforms. Ask for the full lockup as one asset and this widget
/// becomes a single image.
class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    // Pinned LTR. A lockup is a fixed mark, not a sentence — letting the Row
    // follow Directionality mirrors it to "mark NASAM" under Arabic, which is
    // not a thing the brand has.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NASAM',
            style: context.textTheme.headlineMedium?.copyWith(
              color: AppColors.neutralWhite,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: AppSizes.p8),
          const AppLogo(size: AppLogoSize.medium, semanticsLabel: 'Nasam'),
        ],
      ),
    );
  }
}
