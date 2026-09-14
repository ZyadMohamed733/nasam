import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
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
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            final isLast = state.pageIndex == pages.length - 1;

            return Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppButton(
                      // Skip disappears on the last slide, where the primary
                      // action already finishes.
                      onPressed: isLast ? null : cubit.finish,
                      label: l10n.onboardingSkip,
                      variant: AppButtonVariant.tertiary,
                      width: AppSizes.iconButtonMedium * 2,
                    ),
                  ),
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
                  const SizedBox(height: AppSizes.p24),
                  AppPageDots(
                    count: pages.length,
                    activeIndex: state.pageIndex,
                  ),
                  const SizedBox(height: AppSizes.p24),
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
                    label: isLast ? l10n.onboardingStart : l10n.onboardingNext,
                    width: AppSizes.onboardingButtonWidth,
                  ),
                  const SizedBox(height: AppSizes.p16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
