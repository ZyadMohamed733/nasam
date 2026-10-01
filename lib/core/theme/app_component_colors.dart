import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Colours of the shared flow components — stepper, data table, pagination,
/// file drop zone, result card — per brightness, from the POI import flow
/// (`647:7950`–`647:8007`).
///
/// Every dark value is marked AWAITING DESIGN: the flow has no dark frames.
@immutable
class AppComponentColors extends ThemeExtension<AppComponentColors> {
  const AppComponentColors({
    required this.sectionTitle,
    required this.headerDivider,
    required this.tableHeaderFill,
    required this.tableBorder,
    required this.tableFooterBorder,
    required this.pageButtonBorder,
    required this.pageButtonText,
    required this.pageButtonActive,
    required this.pageButtonActiveText,
    required this.dropZoneFill,
    required this.dropZoneBorder,
    required this.dropZoneTitle,
    required this.dropZoneHint,
    required this.stepperActive,
    required this.stepperDoneLabel,
    required this.stepperInactive,
    required this.stepperInactiveLabel,
    required this.elevationShadow,
    required this.iconTileFill,
    required this.infoCardFill,
  });

  /// A section's title in a flow (`561:13775`).
  final Color sectionTitle;

  /// The 1px line under a page header (`647:7951`).
  final Color headerDivider;

  /// A data table's header row (`561:7024`).
  final Color tableHeaderFill;

  /// A data table's cell borders.
  final Color tableBorder;

  /// The pagination footer's border (`561:13933`).
  final Color tableFooterBorder;

  /// A page button's border (`561:13935`).
  final Color pageButtonBorder;

  /// A page button's number, and the footer's total.
  final Color pageButtonText;

  /// The current page's fill (`561:13939`).
  final Color pageButtonActive;

  /// The current page's number.
  final Color pageButtonActiveText;

  /// A file drop zone's dashed box (`561:5445`).
  final Color dropZoneFill;

  /// Its dashed border.
  final Color dropZoneBorder;

  /// Its instruction (`561:5449`).
  final Color dropZoneTitle;

  /// Its format and size hint (`561:5451`).
  final Color dropZoneHint;

  /// A stepper's done and current dots and lines (`561:12169`, overriding the component's #9B51E0).
  final Color stepperActive;

  /// The labels of the current step and those before it (`561:5304`).
  final Color stepperDoneLabel;

  /// Steps still to come: the dot's centre and the line (`561:5212`).
  final Color stepperInactive;

  /// Their labels (`561:5239`).
  final Color stepperInactiveLabel;

  /// The 10% black under raised cards (`561:12184`, `561:16904`).
  final Color elevationShadow;

  /// A filled icon tile (`561:16906`).
  final Color iconTileFill;

  /// A result card (`561:16904`).
  final Color infoCardFill;

  static const light = AppComponentColors(
    sectionTitle: AppColors.slate900,
    headerDivider: AppColors.neutral200,
    tableHeaderFill: AppColors.neutral50,
    tableBorder: AppColors.neutral50,
    tableFooterBorder: AppColors.gray100,
    pageButtonBorder: AppColors.gray200,
    pageButtonText: AppColors.gray400,
    pageButtonActive: AppColors.bluePurple600,
    pageButtonActiveText: AppColors.neutralWhite,
    dropZoneFill: AppColors.neutral50,
    dropZoneBorder: AppColors.slate200,
    dropZoneTitle: AppColors.slate950,
    dropZoneHint: AppColors.slate500,
    stepperActive: AppColors.bluePurple500,
    stepperDoneLabel: AppColors.indigo700,
    stepperInactive: AppColors.neutral150Cool,
    stepperInactiveLabel: AppColors.neutral600,
    elevationShadow: AppColors.transparentBlack10,
    iconTileFill: AppColors.bluePurple700,
    infoCardFill: AppColors.bluePurple50,
  );

  static const dark = AppComponentColors(
    sectionTitle: AppColors.neutral50, // AWAITING DESIGN
    headerDivider: AppColors.neutral600, // AWAITING DESIGN
    tableHeaderFill: AppColors.neutral900, // AWAITING DESIGN
    tableBorder: AppColors.neutral700, // AWAITING DESIGN
    tableFooterBorder: AppColors.neutral700, // AWAITING DESIGN
    pageButtonBorder: AppColors.neutral600, // AWAITING DESIGN
    pageButtonText: AppColors.neutral300, // AWAITING DESIGN
    pageButtonActive: AppColors.bluePurple400, // AWAITING DESIGN
    pageButtonActiveText: AppColors.neutralWhite, // AWAITING DESIGN
    dropZoneFill: AppColors.neutral900, // AWAITING DESIGN
    dropZoneBorder: AppColors.neutral600, // AWAITING DESIGN
    dropZoneTitle: AppColors.neutral50, // AWAITING DESIGN
    dropZoneHint: AppColors.neutral300, // AWAITING DESIGN
    stepperActive: AppColors.bluePurple200, // AWAITING DESIGN
    stepperDoneLabel: AppColors.bluePurple200, // AWAITING DESIGN
    stepperInactive: AppColors.neutral600, // AWAITING DESIGN
    stepperInactiveLabel: AppColors.neutral300, // AWAITING DESIGN
    elevationShadow: AppColors.transparentBlack20, // AWAITING DESIGN
    iconTileFill: AppColors.bluePurple500, // AWAITING DESIGN
    infoCardFill: AppColors.bluePurple700, // AWAITING DESIGN
  );

  /// The theme's, or the default for its brightness — never a null.
  static AppComponentColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppComponentColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  AppComponentColors copyWith({
    Color? sectionTitle,
    Color? headerDivider,
    Color? tableHeaderFill,
    Color? tableBorder,
    Color? tableFooterBorder,
    Color? pageButtonBorder,
    Color? pageButtonText,
    Color? pageButtonActive,
    Color? pageButtonActiveText,
    Color? dropZoneFill,
    Color? dropZoneBorder,
    Color? dropZoneTitle,
    Color? dropZoneHint,
    Color? stepperActive,
    Color? stepperDoneLabel,
    Color? stepperInactive,
    Color? stepperInactiveLabel,
    Color? elevationShadow,
    Color? iconTileFill,
    Color? infoCardFill,
  }) => AppComponentColors(
    sectionTitle: sectionTitle ?? this.sectionTitle,
    headerDivider: headerDivider ?? this.headerDivider,
    tableHeaderFill: tableHeaderFill ?? this.tableHeaderFill,
    tableBorder: tableBorder ?? this.tableBorder,
    tableFooterBorder: tableFooterBorder ?? this.tableFooterBorder,
    pageButtonBorder: pageButtonBorder ?? this.pageButtonBorder,
    pageButtonText: pageButtonText ?? this.pageButtonText,
    pageButtonActive: pageButtonActive ?? this.pageButtonActive,
    pageButtonActiveText: pageButtonActiveText ?? this.pageButtonActiveText,
    dropZoneFill: dropZoneFill ?? this.dropZoneFill,
    dropZoneBorder: dropZoneBorder ?? this.dropZoneBorder,
    dropZoneTitle: dropZoneTitle ?? this.dropZoneTitle,
    dropZoneHint: dropZoneHint ?? this.dropZoneHint,
    stepperActive: stepperActive ?? this.stepperActive,
    stepperDoneLabel: stepperDoneLabel ?? this.stepperDoneLabel,
    stepperInactive: stepperInactive ?? this.stepperInactive,
    stepperInactiveLabel: stepperInactiveLabel ?? this.stepperInactiveLabel,
    elevationShadow: elevationShadow ?? this.elevationShadow,
    iconTileFill: iconTileFill ?? this.iconTileFill,
    infoCardFill: infoCardFill ?? this.infoCardFill,
  );

  @override
  AppComponentColors lerp(covariant AppComponentColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppComponentColors(
      sectionTitle: mix(sectionTitle, other.sectionTitle),
      headerDivider: mix(headerDivider, other.headerDivider),
      tableHeaderFill: mix(tableHeaderFill, other.tableHeaderFill),
      tableBorder: mix(tableBorder, other.tableBorder),
      tableFooterBorder: mix(tableFooterBorder, other.tableFooterBorder),
      pageButtonBorder: mix(pageButtonBorder, other.pageButtonBorder),
      pageButtonText: mix(pageButtonText, other.pageButtonText),
      pageButtonActive: mix(pageButtonActive, other.pageButtonActive),
      pageButtonActiveText: mix(
        pageButtonActiveText,
        other.pageButtonActiveText,
      ),
      dropZoneFill: mix(dropZoneFill, other.dropZoneFill),
      dropZoneBorder: mix(dropZoneBorder, other.dropZoneBorder),
      dropZoneTitle: mix(dropZoneTitle, other.dropZoneTitle),
      dropZoneHint: mix(dropZoneHint, other.dropZoneHint),
      stepperActive: mix(stepperActive, other.stepperActive),
      stepperDoneLabel: mix(stepperDoneLabel, other.stepperDoneLabel),
      stepperInactive: mix(stepperInactive, other.stepperInactive),
      stepperInactiveLabel: mix(
        stepperInactiveLabel,
        other.stepperInactiveLabel,
      ),
      elevationShadow: mix(elevationShadow, other.elevationShadow),
      iconTileFill: mix(iconTileFill, other.iconTileFill),
      infoCardFill: mix(infoCardFill, other.infoCardFill),
    );
  }
}
