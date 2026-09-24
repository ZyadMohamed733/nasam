import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/theme/app_drawer_theme.dart';
import 'app_logo.dart';

/// Full-bleed decoration shared by the standard and animated drawer shells.
class AppDrawerBackground extends StatelessWidget {
  const AppDrawerBackground({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppDrawerTheme.of(context).background,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: AspectRatio(
            aspectRatio: AppSizes.drawerArtworkAspectRatio,
            child: Image.asset(
              AppAssets.drawerBottomBackground,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The app's single drawer content. Hosts supply account data and actions.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onLogout,
    this.profileName,
    this.profileRole,
    this.showBackground = true,
    this.loggingOut = false,
  });

  final VoidCallback onLogout;

  /// A sign-out is under way: the entry shows progress and ignores taps.
  final bool loggingOut;
  final String? profileName;
  final String? profileRole;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = AppDrawerTheme.of(context);
    final text = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showBackground) const AppDrawerBackground(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSizes.p16,
              end: AppSizes.p16,
              top: AppSizes.p4,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const AppLogo(size: AppLogoSize.drawer),
                            const SizedBox(width: AppSizes.p8),
                            Flexible(
                              child: Text(
                                AppConstants.appName.toUpperCase(),
                                style: text.headlineMedium?.copyWith(
                                  color: palette.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p24),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: palette.muted),
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.p12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: AppSizes.iconSm,
                                  color: palette.muted,
                                ),
                                const SizedBox(width: AppSizes.p8),
                                Flexible(
                                  child: Text(
                                    l.trackingSearch,
                                    style: text.labelMedium?.copyWith(
                                      color: palette.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        _Section(label: l.trackingSystems),
                        _Entry(
                          label: l.trackingFleet,
                          icon: Icons.settings_input_component_outlined,
                          expanded: true,
                        ),
                        _Entry(
                          label: l.trackingTitle,
                          icon: Icons.location_on_outlined,
                          selected: true,
                        ),
                        _Entry(
                          label: l.trackingPoi,
                          icon: Icons.pin_drop_outlined,
                        ),
                        _Entry(
                          label: l.trackingGeofences,
                          icon: Icons.straighten_outlined,
                        ),
                        _Entry(
                          label: l.trackingAssignments,
                          icon: Icons.link,
                          expanded: false,
                        ),
                        const SizedBox(height: AppSizes.p8),
                        _Section(label: l.trackingSettings),
                        _Entry(
                          label: l.trackingSettings,
                          icon: Icons.settings_outlined,
                          expanded: true,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSizes.p16),
                        _Entry(
                          label: l.trackingLogout,
                          icon: Icons.logout_rounded,
                          busy: loggingOut,
                          onTap: loggingOut ? null : onLogout,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: AppSizes.drawerFooterHeight,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: AppSizes.drawerAvatarRadius,
                                  backgroundColor: palette.avatarBackground,
                                  child: Icon(
                                    Icons.person,
                                    color: palette.avatarForeground,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.p12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        profileName ?? l.drawerDemoProfileName,
                                        style: text.bodySmall?.copyWith(
                                          color: palette.profileText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSizes.p4),
                                      Text(
                                        profileRole ?? l.trackingAdmin,
                                        style: text.labelSmall?.copyWith(
                                          color: palette.background,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: AppDrawerTheme.of(context).section),
  );
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.label,
    required this.icon,
    this.expanded,
    this.selected = false,
    this.busy = false,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final bool? expanded;
  final bool selected;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppDrawerTheme.of(context);
    final color = selected ? palette.background : palette.foreground;
    return Semantics(
      selected: selected,
      child: Material(
        type: selected ? MaterialType.canvas : MaterialType.transparency,
        color: selected ? palette.selected : null,
        borderRadius: BorderRadius.circular(AppSizes.r8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.p8,
              horizontal: AppSizes.p4,
            ),
            child: Row(
              children: [
                if (busy)
                  SizedBox.square(
                    dimension: AppSizes.drawerIconSize,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  )
                else
                  Icon(icon, size: AppSizes.drawerIconSize, color: color),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
                if (expanded != null)
                  Icon(
                    expanded!
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: AppSizes.iconSm,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
