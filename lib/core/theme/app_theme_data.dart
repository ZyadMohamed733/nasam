import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Component themes, each built from the semantic token set for one brightness.
///
/// These used to exist as hand-duplicated `...Light` / `...Dark` pairs. Now
/// that both modes are described by the same [AppSemanticColors] field names,
/// one builder per component covers both and the two modes cannot drift.
class AppThemeData {
  static AppBarTheme appBarTheme(AppSemanticColors s) => AppBarTheme(
    backgroundColor: s.containerBackground,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: s.iconPrimary),
    actionsIconTheme: IconThemeData(color: s.iconPrimary),
  );

  static ElevatedButtonThemeData elevatedButtonTheme(
    AppSemanticColors s,
    TextTheme textTheme,
  ) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
      backgroundColor: s.primaryButtonBackground,
      foregroundColor: s.primaryButtonText,
      // The design specifies a real disabled fill rather than an opacity, but
      // says nothing about disabled *text*; white on the light-mode 30% tint is
      // thin. AppButton owns the button states properly in step 06 — this is
      // only the fallback for bare ElevatedButtons.
      disabledBackgroundColor: s.primaryButtonDisabled,
      disabledForegroundColor: s.primaryButtonText,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      textStyle: textTheme.labelLarge,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? s.primaryButtonHover
            : null,
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme(
    AppSemanticColors s,
    TextTheme textTheme,
  ) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
      backgroundColor: s.secondaryButtonBackground,
      foregroundColor: s.secondaryButtonText,
      disabledForegroundColor: s.iconDisabled,
      side: BorderSide(color: s.secondaryButtonOutline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      textStyle: textTheme.labelLarge,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? s.secondaryButtonHover
            : null,
      ),
    ),
  );

  /// Fills in the text-dependent slots once the [TextTheme] exists.
  static InputDecorationTheme applyText(
    InputDecorationTheme base,
    TextTheme textTheme,
    Color onSurfaceVariant,
  ) => base.copyWith(
    labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
    hintStyle: textTheme.bodyMedium?.copyWith(
      color: onSurfaceVariant.withValues(alpha: 0.6),
    ),
  );

  static InputDecorationTheme inputDecorationTheme(AppSemanticColors s) {
    OutlineInputBorder border(Color color, [double width = 1.0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: s.containerBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p12,
      ),
      border: border(s.containerBorder),
      enabledBorder: border(s.containerBorder),
      focusedBorder: border(s.primary, 1.5),
      errorBorder: border(s.failText),
      focusedErrorBorder: border(s.failText, 1.5),
    );
  }

  static CardThemeData cardTheme(AppSemanticColors s) => CardThemeData(
    color: s.containerBackground,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      side: BorderSide(color: s.containerBorder, width: 0.5),
    ),
    margin: EdgeInsets.zero,
  );
}
