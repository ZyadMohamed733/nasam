import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/theme/app_drawer_theme.dart';
import 'app_logo.dart';
import 'drawer_menu.dart';

export 'drawer_menu.dart' show DrawerDestination;

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
///
/// The menu is [appDrawerMenu]: sections of collapsible groups, filtered by
/// the search field at the top. An entry is live only when the host handles
/// [onSelect] and its destination is in [available]; the rest are shown,
/// disabled, and announced as coming soon.
class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
    required this.onLogout,
    this.profileName,
    this.profileRole,
    this.showBackground = true,
    this.loggingOut = false,
    this.selected,
    this.onSelect,
    this.available = const {DrawerDestination.trackingDashboard},
  });

  final VoidCallback onLogout;

  /// A sign-out is under way: the entry shows progress and ignores taps.
  final bool loggingOut;

  /// The signed-in user. Left out when unknown rather than filled with a
  /// placeholder that reads as someone's name.
  final String? profileName;
  final String? profileRole;
  final bool showBackground;

  /// Where the user is now; highlighted.
  final DrawerDestination? selected;

  /// Called when a live entry is tapped. The host navigates, or closes the
  /// drawer when the entry is where the user already is.
  final ValueChanged<DrawerDestination>? onSelect;

  /// Destinations that exist in the app so far.
  final Set<DrawerDestination> available;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _search = TextEditingController();
  String _query = '';

  /// Groups the user has open. All start open, as the design shows them.
  final Set<String> _open = {'fleet'};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(String id) => setState(() {
    if (!_open.remove(id)) _open.add(id);
  });

  Widget _entry(DrawerMenuEntry entry, {bool indented = true}) {
    final live =
        widget.onSelect != null && widget.available.contains(entry.destination);
    return _Entry(
      label: entry.label,
      icon: entry.icon,
      indented: indented,
      selected: entry.destination == widget.selected,
      onTap: live ? () => widget.onSelect!(entry.destination) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = AppDrawerTheme.of(context);
    final text = Theme.of(context).textTheme;
    final searching = foldForSearch(_query).isNotEmpty;
    final sections = filterDrawerMenu(appDrawerMenu(l), _query);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.showBackground) const AppDrawerBackground(),
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
                      DrawerMenuSearchField(
                        controller: _search,
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      for (final section in sections) ...[
                        DrawerMenuSectionLabel(label: section.label),
                        for (final item in section.items)
                          switch (item) {
                            DrawerMenuGroup() => DrawerMenuGroupTile(
                              key: ValueKey(item.id),
                              group: item,
                              // A search holds every group with a match open.
                              expanded: searching || _open.contains(item.id),
                              onToggle: searching
                                  ? null
                                  : () => _toggle(item.id),
                              entryBuilder: _entry,
                            ),
                            DrawerMenuEntry() => _entry(item, indented: false),
                          },
                      ],
                      if (sections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.p16,
                          ),
                          child: Text(
                            l.drawerNoResults,
                            textAlign: TextAlign.center,
                            style: text.labelMedium?.copyWith(
                              color: palette.muted,
                            ),
                          ),
                        ),
                      const Spacer(),
                      const SizedBox(height: AppSizes.p16),
                      Divider(color: palette.muted.withValues(alpha: .4)),
                      _Entry(
                        label: l.trackingLogout,
                        icon: Icons.logout_rounded,
                        busy: widget.loggingOut,
                        onTap: widget.loggingOut ? null : widget.onLogout,
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
                                    if (widget.profileName case final name?)
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: text.bodySmall?.copyWith(
                                          color: palette.profileText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (widget.profileRole
                                        case final role?) ...[
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

class _Entry extends StatelessWidget {
  const _Entry({
    required this.label,
    required this.icon,
    this.indented = false,
    this.selected = false,
    this.busy = false,
    this.onTap,
  });
  final String label;
  final IconData icon;

  /// A group's entry, drawn smaller-weighted under its header.
  final bool indented;
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.p8,
                horizontal: AppSizes.p8,
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
                    Icon(
                      icon,
                      size: indented
                          ? AppSizes.iconSm
                          : AppSizes.drawerIconSize,
                      color: color,
                    ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
