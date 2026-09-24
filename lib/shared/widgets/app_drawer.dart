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
    this.onSearch,
  });

  final VoidCallback onLogout;

  /// A sign-out is under way: the entry shows progress and ignores taps.
  final bool loggingOut;

  /// The signed-in user. Left out when unknown rather than filled with a
  /// placeholder that reads as someone's name.
  final String? profileName;
  final String? profileRole;

  /// Opens the host's search. Without one the search button is not shown:
  /// a search box that goes nowhere is a dead control.
  final VoidCallback? onSearch;
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
            // Fills the height when there is room, so the sign-out block
            // sits at the bottom, and scrolls when there is not — without
            // IntrinsicHeight's extra layout pass over the whole column.
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
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
                      if (onSearch case final onSearch?) ...[
                        _SearchButton(onTap: onSearch),
                        const SizedBox(height: AppSizes.p12),
                      ],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (profileName case final name?)
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: text.bodySmall?.copyWith(
                                          color: palette.profileText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (profileRole case final role?) ...[
                                      const SizedBox(height: AppSizes.p4),
                                      Text(
                                        role,
                                        style: text.labelSmall?.copyWith(
                                          color: palette.background,
                                        ),
                                      ),
                                    ],
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Opens the host's search: styled as the design's search box, but a
/// button, since the drawer has no list of its own to search.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = AppDrawerTheme.of(context);
    final radius = BorderRadius.circular(AppSizes.r8);
    return Semantics(
      button: true,
      label: l.trackingSearch,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: palette.muted),
              borderRadius: radius,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
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
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: palette.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
    // An entry with nowhere to go yet is disabled and says so, rather than
    // looking like a link that does nothing. The selected entry is where the
    // user already is.
    final unavailable = onTap == null && !selected && !busy;
    return Semantics(
      selected: selected,
      button: !selected,
      enabled: !unavailable,
      hint: unavailable ? AppLocalizations.of(context)!.comingSoon : null,
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
