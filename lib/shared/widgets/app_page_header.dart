import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import 'hit_target.dart';

/// A page's header (`647:7882`): a back chevron at the start, the title with
/// a subtitle under it, and an optional action at the end.
///
/// 71 tall at the design's text scale — 12 above and below a 47-tall text
/// block — and taller when the text grows. The chevron points back in either
/// direction: right under RTL, left under LTR.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  /// At the end, top-aligned with the title: View's 44×44 edit button.
  /// Wrap one drawn below 48 in a `HitTargetExtender`; this header is its
  /// `HitTargetScope`.
  final Widget? trailing;

  static const double height = 71;
  static const double paddingH = 16;
  static const double paddingV = 12;
  static const double chevron = 24;
  static const double gap = 4;
  static const double titleLineHeight = 1.3;

  static const backKey = ValueKey('app-page-header-back');

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final text = context.textTheme;
    return HitTargetScope(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: height),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HitTargetExtender(
                child: Semantics(
                  button: true,
                  label: MaterialLocalizations.of(context).backButtonTooltip,
                  excludeSemantics: true,
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  child: InkResponse(
                    key: backKey,
                    onTap: onBack ?? () => Navigator.maybePop(context),
                    radius: kMinInteractiveDimension / 2,
                    // matchTextDirection: points right under RTL.
                    child: Icon(
                      Icons.chevron_left,
                      size: chevron,
                      color: s.textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        height: titleLineHeight,
                        color: s.pageTitle,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: gap),
                      Text(
                        subtitle!,
                        style: text.bodySmall?.copyWith(
                          color: s.textPlaceholder,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: gap), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
