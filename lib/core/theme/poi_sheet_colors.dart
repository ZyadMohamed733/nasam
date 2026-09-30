import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// The POI sheet's colours, per brightness (Figma `647:8266` and the row
/// `507:16775`).
///
/// The light values are the design's. The design has no dark POI sheet, so
/// every dark value is marked AWAITING DESIGN: each is picked from the
/// existing palette to keep the light role (fill, border, text, accent)
/// readable on the dark container colour, not transcribed from a frame.
@immutable
class PoiSheetColors extends ThemeExtension<PoiSheetColors> {
  const PoiSheetColors({
    required this.handle,
    required this.link,
    required this.icon,
    required this.searchFill,
    required this.searchBorder,
    required this.searchIcon,
    required this.searchText,
    required this.rowFill,
    required this.rowSelectedFill,
    required this.rowBorder,
    required this.rowText,
    required this.iconBoxFill,
    required this.iconBoxIcon,
  });

  /// The drag handle's bar.
  final Color handle;

  /// The header's "show" link.
  final Color link;

  /// The header's close icon and each row's menu dots.
  final Color icon;

  final Color searchFill;
  final Color searchBorder;
  final Color searchIcon;

  /// Typed text; the hint is this at half opacity, as the design draws it.
  final Color searchText;

  final Color rowFill;

  /// NOT IN THE DESIGN: the design has no selected row. See docs/backlog.md.
  final Color rowSelectedFill;
  final Color rowBorder;
  final Color rowText;
  final Color iconBoxFill;
  final Color iconBoxIcon;

  static final light = PoiSheetColors(
    handle: AppColors.neutral150Handle,
    link: AppColors.bluePurple700,
    icon: AppColors.neutral700,
    searchFill: AppColors.inputFill,
    searchBorder: AppColors.neutral200,
    searchIcon: AppColors.gray400,
    searchText: AppColors.gray700,
    rowFill: AppColors.neutralWhite,
    rowSelectedFill: AppColors.bluePurple25.withValues(alpha: .5),
    rowBorder: AppColors.neutral200,
    rowText: AppColors.neutral950,
    iconBoxFill: AppColors.bluePurple25,
    iconBoxIcon: AppColors.violet500,
  );

  /// AWAITING DESIGN — every value. Placed on the dark container colour
  /// (`neutral800`) the way the light ones sit on white.
  static final dark = PoiSheetColors(
    handle: AppColors.neutral600, // AWAITING DESIGN
    link: AppColors.bluePurple200, // AWAITING DESIGN
    icon: AppColors.neutral300, // AWAITING DESIGN
    searchFill: AppColors.neutral900, // AWAITING DESIGN
    searchBorder: AppColors.neutral600, // AWAITING DESIGN
    searchIcon: AppColors.neutral400, // AWAITING DESIGN
    searchText: AppColors.neutral100, // AWAITING DESIGN
    rowFill: AppColors.neutral800, // AWAITING DESIGN
    rowSelectedFill: AppColors.bluePurple700.withValues(
      alpha: .5,
    ), // AWAITING DESIGN
    rowBorder: AppColors.neutral600, // AWAITING DESIGN
    rowText: AppColors.neutral50, // AWAITING DESIGN
    iconBoxFill: AppColors.bluePurple700, // AWAITING DESIGN
    iconBoxIcon: AppColors.bluePurple200, // AWAITING DESIGN
  );

  /// The theme's, or the default for its brightness if a theme was built
  /// without one — never a null to force-unwrap.
  static PoiSheetColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<PoiSheetColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  PoiSheetColors copyWith({
    Color? handle,
    Color? link,
    Color? icon,
    Color? searchFill,
    Color? searchBorder,
    Color? searchIcon,
    Color? searchText,
    Color? rowFill,
    Color? rowSelectedFill,
    Color? rowBorder,
    Color? rowText,
    Color? iconBoxFill,
    Color? iconBoxIcon,
  }) => PoiSheetColors(
    handle: handle ?? this.handle,
    link: link ?? this.link,
    icon: icon ?? this.icon,
    searchFill: searchFill ?? this.searchFill,
    searchBorder: searchBorder ?? this.searchBorder,
    searchIcon: searchIcon ?? this.searchIcon,
    searchText: searchText ?? this.searchText,
    rowFill: rowFill ?? this.rowFill,
    rowSelectedFill: rowSelectedFill ?? this.rowSelectedFill,
    rowBorder: rowBorder ?? this.rowBorder,
    rowText: rowText ?? this.rowText,
    iconBoxFill: iconBoxFill ?? this.iconBoxFill,
    iconBoxIcon: iconBoxIcon ?? this.iconBoxIcon,
  );

  @override
  PoiSheetColors lerp(covariant PoiSheetColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return PoiSheetColors(
      handle: mix(handle, other.handle),
      link: mix(link, other.link),
      icon: mix(icon, other.icon),
      searchFill: mix(searchFill, other.searchFill),
      searchBorder: mix(searchBorder, other.searchBorder),
      searchIcon: mix(searchIcon, other.searchIcon),
      searchText: mix(searchText, other.searchText),
      rowFill: mix(rowFill, other.rowFill),
      rowSelectedFill: mix(rowSelectedFill, other.rowSelectedFill),
      rowBorder: mix(rowBorder, other.rowBorder),
      rowText: mix(rowText, other.rowText),
      iconBoxFill: mix(iconBoxFill, other.iconBoxFill),
      iconBoxIcon: mix(iconBoxIcon, other.iconBoxIcon),
    );
  }
}
