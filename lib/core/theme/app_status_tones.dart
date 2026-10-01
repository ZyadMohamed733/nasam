import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Which status a chip, badge or summary tile shows.
enum AppTone {
  /// Duplicate.
  warning,

  /// Invalid, failed.
  danger,

  /// Valid, succeeded.
  success,

  /// All, total.
  info,
}

/// One status tone: a fill, the border around it and the text on it.
/// Chips (`561:13778`), their count badges and summary tiles (`561:16911`)
/// all draw from it.
@immutable
class AppStatusTone {
  const AppStatusTone({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;

  AppStatusTone lerp(AppStatusTone other, double t) => AppStatusTone(
    background: Color.lerp(background, other.background, t)!,
    border: Color.lerp(border, other.border, t)!,
    foreground: Color.lerp(foreground, other.foreground, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is AppStatusTone &&
      other.background == background &&
      other.border == border &&
      other.foreground == foreground;

  @override
  int get hashCode => Object.hash(background, border, foreground);
}

/// The four status tones, per brightness. Read with [AppStatusTones.of].
@immutable
class AppStatusTones extends ThemeExtension<AppStatusTones> {
  const AppStatusTones({
    required this.warning,
    required this.danger,
    required this.success,
    required this.info,
  });

  final AppStatusTone warning;
  final AppStatusTone danger;
  final AppStatusTone success;
  final AppStatusTone info;

  AppStatusTone operator [](AppTone tone) => switch (tone) {
    AppTone.warning => warning,
    AppTone.danger => danger,
    AppTone.success => success,
    AppTone.info => info,
  };

  static const light = AppStatusTones(
    warning: AppStatusTone(
      background: AppColors.amber50,
      border: AppColors.amber200,
      foreground: AppColors.amber800,
    ),
    danger: AppStatusTone(
      background: AppColors.rose50,
      border: AppColors.rose200,
      foreground: AppColors.rose600,
    ),
    success: AppStatusTone(
      background: AppColors.mint50,
      border: AppColors.mint200,
      foreground: AppColors.mint800,
    ),
    info: AppStatusTone(
      background: AppColors.bluePurple25,
      border: AppColors.violet200,
      foreground: AppColors.violet700,
    ),
  );

  /// AWAITING DESIGN — every value: the light hue as text on a dark tint.
  static const dark = AppStatusTones(
    warning: AppStatusTone(
      background: AppColors.neutral900, // AWAITING DESIGN
      border: AppColors.amber800, // AWAITING DESIGN
      foreground: AppColors.amber200, // AWAITING DESIGN
    ),
    danger: AppStatusTone(
      background: AppColors.neutral900, // AWAITING DESIGN
      border: AppColors.rose600, // AWAITING DESIGN
      foreground: AppColors.rose200, // AWAITING DESIGN
    ),
    success: AppStatusTone(
      background: AppColors.neutral900, // AWAITING DESIGN
      border: AppColors.mint800, // AWAITING DESIGN
      foreground: AppColors.mint200, // AWAITING DESIGN
    ),
    info: AppStatusTone(
      background: AppColors.neutral900, // AWAITING DESIGN
      border: AppColors.violet700, // AWAITING DESIGN
      foreground: AppColors.violet200, // AWAITING DESIGN
    ),
  );

  @override
  bool operator ==(Object other) =>
      other is AppStatusTones &&
      other.warning == warning &&
      other.danger == danger &&
      other.success == success &&
      other.info == info;

  @override
  int get hashCode => Object.hash(warning, danger, success, info);

  /// The theme's, or the default for its brightness — never a null.
  static AppStatusTones of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppStatusTones>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  AppStatusTones copyWith({
    AppStatusTone? warning,
    AppStatusTone? danger,
    AppStatusTone? success,
    AppStatusTone? info,
  }) => AppStatusTones(
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    success: success ?? this.success,
    info: info ?? this.info,
  );

  @override
  AppStatusTones lerp(covariant AppStatusTones? other, double t) {
    if (other == null) return this;
    return AppStatusTones(
      warning: warning.lerp(other.warning, t),
      danger: danger.lerp(other.danger, t),
      success: success.lerp(other.success, t),
      info: info.lerp(other.info, t),
    );
  }
}
