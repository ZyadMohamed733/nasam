import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/widgets/session_drawer.dart';

/// Shared Home navigation chrome. Feature pages supply only their content.
class HomeScaffold extends StatefulWidget {
  const HomeScaffold({
    super.key,
    required this.builder,
    this.selected = DrawerDestination.trackingDashboard,
    this.available = const {DrawerDestination.trackingDashboard},
    this.onSelect,
    this.onBack,
  });
  final Widget Function(BuildContext context, VoidCallback openDrawer) builder;
  final DrawerDestination selected;
  final Set<DrawerDestination> available;
  final ValueChanged<DrawerDestination>? onSelect;
  final VoidCallback? onBack;
  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold>
    with SingleTickerProviderStateMixin {
  final _drawer = AdvancedDrawerController();
  late final _drawerAnimation = AnimationController(vsync: this);
  late final _drawerFade = CurvedAnimation(
    parent: _drawerAnimation,
    curve: Curves.easeInOutCubic,
  );
  @override
  void dispose() {
    _drawerFade.dispose();
    _drawerAnimation.dispose();
    _drawer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AdvancedDrawerValue>(
      valueListenable: _drawer,
      builder: (context, value, _) {
        Future<bool> handleBack() async {
          if (ModalRoute.of(context)?.isCurrent != true) return false;
          if (value.visible) {
            _drawer.hideDrawer();
            return true;
          }
          if (widget.onBack != null) {
            widget.onBack!();
            return true;
          }
          return false;
        }

        final content = PopScope(
          canPop: !value.visible && widget.onBack == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              if (value.visible) {
                _drawer.hideDrawer();
              } else {
                widget.onBack?.call();
              }
            }
          },
          child: AdvancedDrawer(
            animationCurve: Curves.easeInOutCubic,
            animationDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : Durations.long2,
            animateChildDecoration: true,
            controller: _drawer,
            animationController: _drawerAnimation,
            drawerSlideRatio: Directionality.of(context) == TextDirection.rtl
                ? -AppSizes.drawerSlideRatio
                : AppSizes.drawerSlideRatio,
            rtlOpening: Directionality.of(context) == TextDirection.rtl,
            disabledGestures: true, // Map drags must not open the drawer.
            openRatio:
                (AppSizes.drawerMaxWidth / MediaQuery.sizeOf(context).width)
                    .clamp(0.0, AppSizes.drawerOpenRatio),
            openScale: AppSizes.drawerOpenScale,
            initialDrawerScale: AppSizes.drawerInitialScale,
            backdrop: const AppDrawerBackground(),
            childDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.r32),
            ),
            drawer: FadeTransition(
              opacity: _drawerFade,
              child: SessionDrawer(
                showBackground: false,
                selected: widget.selected,
                available: widget.available,
                onSelect: (destination) {
                  _drawer.hideDrawer();
                  widget.onSelect?.call(destination);
                },
              ),
            ),
            child: widget.builder(context, _drawer.showDrawer),
          ),
        );
        // go_router may not dispatch PopScope at its root route.
        // Listen to the Router back dispatcher as well, but never intercept
        // a details page or modal that is above Home.
        return Router.maybeOf(context) == null
            ? content
            : BackButtonListener(
                onBackButtonPressed: handleBack,
                child: content,
              );
      },
    );
  }
}
