import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_logo.dart';

/// The shell every auth screen sits in.
///
/// The design's auth screens share one layout: a back affordance with no
/// title, the mark at 48, a heading and a line of explanation, then a 328pt
/// column of form. Four screens repeating that by hand is four chances to
/// drift, so it lives here.
///
/// It scrolls. The keyboard takes roughly half a phone screen, and these
/// screens are only comfortably short until someone opens one on a small
/// device in landscape with a password field focused.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// The first screen of the flow has nowhere to go back to.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Scaffold(
      backgroundColor: semantic.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSizes.appBarHeight,
              child: showBack && context.canPop()
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        // Directional, so it points the way back in both
                        // scripts rather than always pointing left.
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        iconSize: AppSizes.iconSm,
                        color: semantic.iconPrimary,
                        onPressed: context.pop,
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPadding,
                ),
                child: Center(
                  child: SizedBox(
                    width: AppSizes.formContentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSizes.p32),
                        const Align(child: AppLogo()),
                        const SizedBox(height: AppSizes.p32),
                        Text(title, style: context.textTheme.displaySmall),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            subtitle!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: semantic.textPlaceholder,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSizes.p32),
                        ...children,
                        const SizedBox(height: AppSizes.p32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
