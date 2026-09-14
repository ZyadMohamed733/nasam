import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';

/// One onboarding slide: artwork above, then a title and a line of body copy.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            // The artwork carries no information the copy does not, so it is
            // decorative as far as a screen reader is concerned.
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: AppSizes.p32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.displaySmall,
        ),
        const SizedBox(height: AppSizes.p12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.semanticColors.textPlaceholder,
          ),
        ),
      ],
    );
  }
}
