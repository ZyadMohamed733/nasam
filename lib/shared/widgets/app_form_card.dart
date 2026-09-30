import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// A form's card (`539:13749`): white, radius 16, a soft shadow, 16 in from
/// the sides and 24 from the top and bottom. A Bold 16 title and a 14
/// subtitle 3 below it, then [children] 18 apart.
class AppFormCard extends StatelessWidget {
  const AppFormCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );
  static const double titleGap = 3;
  static const double gap = 18;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final text = context.textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: s.containerBackground,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: [
          BoxShadow(
            color: s.cardShadow,
            offset: const Offset(0, 2),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: gap,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: titleGap,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    // Bold 16 on a 20 line.
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: s.textColor,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: text.bodySmall?.copyWith(color: s.textPlaceholder),
                  ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
