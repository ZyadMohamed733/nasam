import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/theme/app_drawer_theme.dart';

/// Where a drawer entry leads.
enum DrawerDestination {
  trackingDashboard,
  pointsOfInterest,
  geofences,
  settings,
  alertsLog,
}

/// Something in a [DrawerMenuSection]: a collapsible [DrawerMenuGroup], or a
/// [DrawerMenuEntry] of its own.
sealed class DrawerMenuItem {
  const DrawerMenuItem();
  String get label;
}

/// A destination: inside a [DrawerMenuGroup], or directly in a section.
@immutable
class DrawerMenuEntry extends DrawerMenuItem {
  const DrawerMenuEntry({
    required this.destination,
    required this.label,
    required this.icon,
  });

  final DrawerDestination destination;
  @override
  final String label;
  final IconData icon;
}

/// A collapsible group of entries.
@immutable
class DrawerMenuGroup extends DrawerMenuItem {
  const DrawerMenuGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.entries,
  });

  /// Stable across rebuilds and languages; keys the expanded state.
  final String id;
  @override
  final String label;
  final IconData icon;
  final List<DrawerMenuEntry> entries;
}

/// A labelled section of groups and entries.
@immutable
class DrawerMenuSection {
  const DrawerMenuSection({required this.label, required this.items});

  final String label;
  final List<DrawerMenuItem> items;
}

/// The app's menu, as the design lays it out.
List<DrawerMenuSection> appDrawerMenu(AppLocalizations l) => [
  DrawerMenuSection(
    label: l.trackingSystems,
    items: [
      DrawerMenuGroup(
        id: 'fleet',
        label: l.trackingFleet,
        icon: Icons.person_pin_circle_outlined,
        entries: [
          DrawerMenuEntry(
            destination: DrawerDestination.trackingDashboard,
            label: l.trackingTitle,
            icon: Icons.location_on_outlined,
          ),
          DrawerMenuEntry(
            destination: DrawerDestination.pointsOfInterest,
            label: l.trackingPoi,
            icon: Icons.share_location_outlined,
          ),
          DrawerMenuEntry(
            destination: DrawerDestination.geofences,
            label: l.trackingGeofences,
            icon: Icons.straighten_outlined,
          ),
        ],
      ),
    ],
  ),
  // Settings and the alerts log sit side by side, not one inside the
  // other. Settings has no sub-pages yet, so it is an entry, not a group:
  // a group that expands to nothing would be a control that does nothing.
  DrawerMenuSection(
    label: l.trackingSettings,
    items: [
      DrawerMenuEntry(
        destination: DrawerDestination.settings,
        label: l.trackingSettings,
        icon: Icons.settings_outlined,
      ),
      DrawerMenuEntry(
        destination: DrawerDestination.alertsLog,
        label: l.drawerAlertsLog,
        icon: Icons.notifications_none_outlined,
      ),
    ],
  ),
];

/// Folds text for matching: case, Arabic diacritics and tatweel, and the
/// letter forms people type interchangeably (أ إ آ → ا, ة → ه, ى → ي), so
/// "لوحه" finds "لوحة" and "track" finds "Tracking".
String foldForSearch(String text) => text
    .toLowerCase()
    .replaceAll(RegExp('[ً-ْٰـ]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .trim();

/// [menu] narrowed to [query].
///
/// A group whose own name matches keeps all its entries; otherwise it keeps
/// the entries that match, and is dropped if none do. An entry on its own is
/// kept if it matches. A section whose name matches keeps everything in it.
/// An empty query changes nothing.
List<DrawerMenuSection> filterDrawerMenu(
  List<DrawerMenuSection> menu,
  String query,
) {
  final q = foldForSearch(query);
  if (q.isEmpty) return menu;
  bool matches(String label) => foldForSearch(label).contains(q);

  DrawerMenuItem? narrow(DrawerMenuItem item) => switch (item) {
    _ when matches(item.label) => item,
    DrawerMenuEntry() => null,
    DrawerMenuGroup(:final entries) => switch (entries
        .where((e) => matches(e.label))
        .toList()) {
      final kept when kept.isNotEmpty => DrawerMenuGroup(
        id: item.id,
        label: item.label,
        icon: item.icon,
        entries: kept,
      ),
      _ => null,
    },
  };

  return [
    for (final section in menu)
      if (matches(section.label))
        section
      else if ([for (final item in section.items) ?narrow(item)]
          case final items when items.isNotEmpty)
        DrawerMenuSection(label: section.label, items: items),
  ];
}

/// The drawer's search field: filters the menu as the user types.
class DrawerMenuSearchField extends StatelessWidget {
  const DrawerMenuSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = AppDrawerTheme.of(context);
    final text = Theme.of(context).textTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.r8),
      borderSide: BorderSide(color: palette.muted),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: palette.foreground,
      style: text.labelMedium?.copyWith(color: palette.foreground),
      decoration: InputDecoration(
        hintText: l.trackingSearch,
        // Outlined on the drawer's colour, not the app's filled white field.
        filled: false,
        hintStyle: text.labelMedium?.copyWith(color: palette.muted),
        isDense: true,
        prefixIcon: Icon(
          Icons.search,
          size: AppSizes.iconSm,
          color: palette.muted,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: l.drawerClearSearch,
                  icon: Icon(
                    Icons.close,
                    size: AppSizes.iconSm,
                    color: palette.muted,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: palette.foreground),
        ),
      ),
    );
  }
}

/// A section label, a small heading above its groups.
class DrawerMenuSectionLabel extends StatelessWidget {
  const DrawerMenuSectionLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.p8),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppDrawerTheme.of(context).section,
      ),
    ),
  );
}

/// A group: a header that expands and collapses, and its entries indented
/// beneath it.
class DrawerMenuGroupTile extends StatelessWidget {
  const DrawerMenuGroupTile({
    super.key,
    required this.group,
    required this.expanded,
    required this.onToggle,
    required this.entryBuilder,
  });

  final DrawerMenuGroup group;
  final bool expanded;

  /// Null while the group is held open, as during a search.
  final VoidCallback? onToggle;
  final Widget Function(DrawerMenuEntry entry) entryBuilder;

  @override
  Widget build(BuildContext context) {
    final palette = AppDrawerTheme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : Durations.medium2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: onToggle != null,
          expanded: expanded,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppSizes.r8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                child: Row(
                  children: [
                    Icon(
                      group.icon,
                      size: AppSizes.drawerIconSize,
                      color: palette.foreground,
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Text(
                        group.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.foreground,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0 : .5,
                      duration: duration,
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: AppSizes.iconSm,
                        color: palette.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: duration,
            curve: Curves.easeInOut,
            alignment: AlignmentDirectional.topStart,
            child: expanded
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSizes.p20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final entry in group.entries) entryBuilder(entry),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}
