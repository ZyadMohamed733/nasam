import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_dots.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_slide.dart';

/// The three-slide intro.
///
/// Presentation only — see [OnboardingCubit] for why there is no data or
/// domain layer here.
///
/// Direction is left to `Directionality`: a [PageView] already advances
/// right-to-left under Arabic, so "next" moves the way the reader does without
/// the page reversing anything itself.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.cubit});

  /// Injected in tests; resolved from the container otherwise.
  final OnboardingCubit? cubit;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static List<({String image, String title, String body})> _slides(
    AppLocalizations l10n,
  ) => [
    (
      image: AppAssets.onboarding1,
      title: l10n.onboardingTitle1,
      body: l10n.onboardingBody1,
    ),
    (
      image: AppAssets.onboarding2,
      title: l10n.onboardingTitle2,
      body: l10n.onboardingBody2,
    ),
    (
      image: AppAssets.onboarding3,
      title: l10n.onboardingTitle3,
      body: l10n.onboardingBody3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => widget.cubit ?? getIt<OnboardingCubit>(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (previous, current) =>
            !previous.isComplete && current.isComplete,
        // The cubit records that the intro is done; routing stays here.
        listener: (context, _) => context.go(AppRoutes.home),
        child: _OnboardingView(controller: _controller, slides: _slides),
      ),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({required this.controller, required this.slides});

  final PageController controller;
  final List<({String image, String title, String body})> Function(
    AppLocalizations,
  )
  slides;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = slides(l10n);
    final cubit = context.read<OnboardingCubit>();

    return Scaffold(
      backgroundColor: context.semanticColors.pageBackground,
      // Deliberately no SafeArea around the whole page: the artwork runs up
      // under the status bar. Only the bottom inset is honoured, for the home
      // indicator.
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                final isLast = state.pageIndex == pages.length - 1;

                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: controller,
                        onPageChanged: cubit.onPageChanged,
                        itemCount: pages.length,
                        itemBuilder: (context, i) => OnboardingSlide(
                          image: pages[i].image,
                          title: pages[i].title,
                          body: pages[i].body,
                        ),
                      ),
                    ),
                    AppButton(
                      onPressed: () {
                        if (isLast) {
                          cubit.finish();
                        } else {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      label: isLast
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                      trailingIcon: AppIcons.forward,
                      width: AppSizes.onboardingButtonWidth,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppPageDots(
                      count: pages.length,
                      activeIndex: state.pageIndex,
                    ),
                    const SizedBox(height: AppSizes.p24),
                  ],
                );
              },
            ),
          ),
          // Sits on the artwork rather than above it, so it reads as part of
          // the image the way the design draws it. `end` is the left edge under
          // Arabic, which is where it belongs.
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + AppSizes.p8,
            end: AppSizes.p8,
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
              buildWhen: (a, b) => a.pageIndex != b.pageIndex,
              builder: (context, state) {
                final isLast = state.pageIndex == pages.length - 1;
                return _SkipAction(
                  // Skip disappears on the last slide, where the primary action
                  // already finishes.
                  onPressed: isLast ? null : cubit.finish,
                  label: l10n.onboardingSkip,
                  icon: AppIcons.forward,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The skip affordance, drawn over the artwork.
///
/// Not an [AppButton]: it is white-on-photograph rather than theme-coloured,
/// which no button variant describes, and inventing a fourth variant for one
/// call site would put a rule in the design system the design does not have.
class _SkipAction extends StatelessWidget {
  const _SkipAction({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onPressed == null ? 0 : 1,
      duration: const Duration(milliseconds: 150),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neutralWhite,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p12,
            vertical: AppSizes.p8,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: context.textTheme.labelLarge),
            const SizedBox(width: AppSizes.p4),
            Icon(icon, size: AppIconSize.small.value),
          ],
        ),
      ),
    );
  }
}
