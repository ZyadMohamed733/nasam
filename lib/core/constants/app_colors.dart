import 'package:flutter/material.dart';

/// The design system's **primitive** layer: the raw palette, named after the
/// colour rather than the job. Nothing outside [AppSemanticColors] and the
/// theme should read these directly — a widget that needs "the disabled button
/// background" wants the semantic token, not `bluePurple500 at 30%`.
///
/// Values are transcribed from `Nasam _ Mobile.fig`.
abstract final class AppColors {
  // Blue-purple — the brand ramp.
  static const Color bluePurple50 = Color(0xFFEDEBF7);
  static const Color bluePurple200 = Color(0xFFB8AEDF);
  static const Color bluePurple400 = Color(0xFF715DBE);
  static const Color bluePurple500 = Color(0xFF4D34AE);
  static const Color bluePurple700 = Color(0xFF2E1F68);

  // Purple — the secondary ramp.
  static const Color purple100 = Color(0xFFE9D3EC);
  static const Color purple500 = Color(0xFF972FA3);
  static const Color purple800 = Color(0xFF3C1341);
  static const Color purple900 = Color(0xFF1E0921);

  // Dark purple — splash and deep surfaces.
  static const Color darkPurple50 = Color(0xFFDC9CE6);
  static const Color darkPurple200 = Color(0xFFB26DBD);
  static const Color darkPurple500 = Color(0xFF5D0E6A);
  static const Color darkPurple700 = Color(0xFF380840);
  static const Color darkPurple800 = Color(0xFF25062A);

  // Neutrals.
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF6F6F6);
  static const Color neutral100 = Color(0xFFECECEC);
  static const Color neutral200 = Color(0xFFD9D9D9);
  static const Color neutral300 = Color(0xFFC7C7C7);
  static const Color neutral400 = Color(0xFFB4B4B4);
  static const Color neutral500 = Color(0xFFA1A1A1);
  static const Color neutral600 = Color(0xFF818181);
  static const Color neutral700 = Color(0xFF616161);

  static const Color neutral800 = Color(0xFF404040);

  static const Color neutral900 = Color(0xFF202020);
  static const Color neutralBlack = Color(0xFF000000);

  // Status.
  static const Color green600 = Color(0xFF15A42B);
  static const Color green800 = Color(0xFF156622);
  static const Color red50 = Color(0xFFFFF0F2);
  static const Color red100 = Color(0xFFFFDEE2);
  static const Color red500 = Color(0xFFFF2D45);
  static const Color red800 = Color(0xFFAA0A1D);

  // Transparencies. The design names these by their opacity, so keep that.
  static const Color transparentBlack10 = Color(0x1A000000);
  static const Color transparentBlack20 = Color(0x33000000);
  static const Color transparentWhite10 = Color(0x1AFFFFFF);
  static const Color transparentWhite15 = Color(0x26FFFFFF);
  static const Color transparentBluePurple10 = Color(0x1A391399);
  static const Color transparentBluePurple30 = Color(0x4D391399);

  static const Color transparent = Colors.transparent;
}

/// The design system's **semantic** layer: one field per named token in the
/// Figma library, carrying the light or dark value for that token.
///
/// It is a [ThemeExtension] rather than a bare constant class so that widgets
/// reach it through `Theme.of(context)` and therefore follow the active
/// brightness automatically:
///
/// ```dart
/// final semantic = Theme.of(context).extension<AppSemanticColors>()!;
/// ```
///
/// Tokens that map cleanly onto a Material 3 [ColorScheme] role (surface,
/// outline, error…) are *also* wired into the scheme in `AppTheme`, so prefer
/// `colorScheme` where a role exists and reach for this extension only for the
/// tokens M3 has no room for — the button and icon states, mostly.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.primary,
    required this.secondary,
    required this.pageBackground,
    required this.containerBackground,
    required this.containerBorder,
    required this.divider,
    required this.hover,
    required this.textColor,
    required this.textPlaceholder,
    required this.primaryButtonBackground,
    required this.primaryButtonText,
    required this.primaryButtonHover,
    required this.primaryButtonDisabled,
    required this.secondaryButtonBackground,
    required this.secondaryButtonOutline,
    required this.secondaryButtonText,
    required this.secondaryButtonHover,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconDisabled,
    required this.successText,
    required this.failText,
    required this.failBackground,
    required this.warningText,
    required this.infoText,
  });

  final Color primary;
  final Color secondary;

  final Color pageBackground;
  final Color containerBackground;
  final Color containerBorder;
  final Color divider;
  final Color hover;

  final Color textColor;
  final Color textPlaceholder;

  final Color primaryButtonBackground;
  final Color primaryButtonText;
  final Color primaryButtonHover;
  final Color primaryButtonDisabled;

  final Color secondaryButtonBackground;
  final Color secondaryButtonOutline;
  final Color secondaryButtonText;
  final Color secondaryButtonHover;

  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconDisabled;

  final Color successText;
  final Color failText;
  final Color failBackground;

  /// NOT IN THE DESIGN SYSTEM. The Figma library defines success and fail but
  /// no warning or info token, while the app already has states that need them
  /// (the WebSocket "connecting" dot, the warning and info snackbars and
  /// dialogs). Rather than invent an amber and a blue that exist nowhere in the
  /// palette, both are mapped onto the secondary and primary ramps. Ask the
  /// designer for real tokens; changing these two lines is then the whole job.
  final Color warningText;
  final Color infoText;

  static const AppSemanticColors light = AppSemanticColors(
    primary: AppColors.bluePurple500,
    secondary: AppColors.purple500,
    pageBackground: AppColors.neutralWhite,
    containerBackground: AppColors.neutralWhite,
    containerBorder: AppColors.neutral200,
    divider: AppColors.neutral200,
    hover: AppColors.neutral50,
    textColor: AppColors.neutral900,
    textPlaceholder: AppColors.neutral600,
    primaryButtonBackground: AppColors.bluePurple700,
    primaryButtonText: AppColors.neutralWhite,
    primaryButtonHover: AppColors.bluePurple400,
    primaryButtonDisabled: AppColors.transparentBluePurple30,
    secondaryButtonBackground: AppColors.neutralWhite,
    secondaryButtonOutline: AppColors.neutral400,
    secondaryButtonText: AppColors.neutral800,
    secondaryButtonHover: AppColors.transparentBlack10,
    iconPrimary: AppColors.neutral900,
    iconSecondary: AppColors.neutral600,
    iconDisabled: AppColors.neutral300,
    successText: AppColors.green600,
    failText: AppColors.red500,
    failBackground: AppColors.red50,
    warningText: AppColors.purple500,
    infoText: AppColors.bluePurple500,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    primary: AppColors.bluePurple500,
    secondary: AppColors.purple500,
    pageBackground: AppColors.neutral900,
    containerBackground: AppColors.neutral800,
    containerBorder: AppColors.neutral600,
    divider: AppColors.neutral50,
    hover: AppColors.neutral700,
    textColor: AppColors.neutral50,
    textPlaceholder: AppColors.neutral200,
    primaryButtonBackground: AppColors.bluePurple700,
    primaryButtonText: AppColors.neutralWhite,
    primaryButtonHover: AppColors.bluePurple400,
    primaryButtonDisabled: AppColors.transparentBluePurple10,
    secondaryButtonBackground: AppColors.transparentWhite10,
    secondaryButtonOutline: AppColors.neutral300,
    secondaryButtonText: AppColors.neutral400,
    secondaryButtonHover: AppColors.transparentWhite15,
    iconPrimary: AppColors.neutral200,
    iconSecondary: AppColors.neutral200,
    iconDisabled: AppColors.neutral800,
    successText: AppColors.green800,
    failText: AppColors.red800,
    failBackground: AppColors.red100,
    warningText: AppColors.darkPurple50,
    infoText: AppColors.bluePurple200,
  );

  @override
  AppSemanticColors copyWith({
    Color? primary,
    Color? secondary,
    Color? pageBackground,
    Color? containerBackground,
    Color? containerBorder,
    Color? divider,
    Color? hover,
    Color? textColor,
    Color? textPlaceholder,
    Color? primaryButtonBackground,
    Color? primaryButtonText,
    Color? primaryButtonHover,
    Color? primaryButtonDisabled,
    Color? secondaryButtonBackground,
    Color? secondaryButtonOutline,
    Color? secondaryButtonText,
    Color? secondaryButtonHover,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconDisabled,
    Color? successText,
    Color? failText,
    Color? failBackground,
    Color? warningText,
    Color? infoText,
  }) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      pageBackground: pageBackground ?? this.pageBackground,
      containerBackground: containerBackground ?? this.containerBackground,
      containerBorder: containerBorder ?? this.containerBorder,
      divider: divider ?? this.divider,
      hover: hover ?? this.hover,
      textColor: textColor ?? this.textColor,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      primaryButtonBackground:
          primaryButtonBackground ?? this.primaryButtonBackground,
      primaryButtonText: primaryButtonText ?? this.primaryButtonText,
      primaryButtonHover: primaryButtonHover ?? this.primaryButtonHover,
      primaryButtonDisabled:
          primaryButtonDisabled ?? this.primaryButtonDisabled,
      secondaryButtonBackground:
          secondaryButtonBackground ?? this.secondaryButtonBackground,
      secondaryButtonOutline:
          secondaryButtonOutline ?? this.secondaryButtonOutline,
      secondaryButtonText: secondaryButtonText ?? this.secondaryButtonText,
      secondaryButtonHover: secondaryButtonHover ?? this.secondaryButtonHover,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      successText: successText ?? this.successText,
      failText: failText ?? this.failText,
      failBackground: failBackground ?? this.failBackground,
      warningText: warningText ?? this.warningText,
      infoText: infoText ?? this.infoText,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      primary: mix(primary, other.primary),
      secondary: mix(secondary, other.secondary),
      pageBackground: mix(pageBackground, other.pageBackground),
      containerBackground: mix(containerBackground, other.containerBackground),
      containerBorder: mix(containerBorder, other.containerBorder),
      divider: mix(divider, other.divider),
      hover: mix(hover, other.hover),
      textColor: mix(textColor, other.textColor),
      textPlaceholder: mix(textPlaceholder, other.textPlaceholder),
      primaryButtonBackground: mix(
        primaryButtonBackground,
        other.primaryButtonBackground,
      ),
      primaryButtonText: mix(primaryButtonText, other.primaryButtonText),
      primaryButtonHover: mix(primaryButtonHover, other.primaryButtonHover),
      primaryButtonDisabled: mix(
        primaryButtonDisabled,
        other.primaryButtonDisabled,
      ),
      secondaryButtonBackground: mix(
        secondaryButtonBackground,
        other.secondaryButtonBackground,
      ),
      secondaryButtonOutline: mix(
        secondaryButtonOutline,
        other.secondaryButtonOutline,
      ),
      secondaryButtonText: mix(secondaryButtonText, other.secondaryButtonText),
      secondaryButtonHover: mix(
        secondaryButtonHover,
        other.secondaryButtonHover,
      ),
      iconPrimary: mix(iconPrimary, other.iconPrimary),
      iconSecondary: mix(iconSecondary, other.iconSecondary),
      iconDisabled: mix(iconDisabled, other.iconDisabled),
      successText: mix(successText, other.successText),
      failText: mix(failText, other.failText),
      failBackground: mix(failBackground, other.failBackground),
      warningText: mix(warningText, other.warningText),
      infoText: mix(infoText, other.infoText),
    );
  }
}
