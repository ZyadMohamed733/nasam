import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// The tracking screens' colours, per brightness.
///
/// Status colours are text as well as fills — chip and badge labels at
/// 11sp — so each is picked to reach WCAG AA (4.5:1) on its own surface,
/// including the 7% tint the chips sit on. The light moving green is the
/// design's; its idle amber (#AC7600, 3.6:1) and stopped red (#E0004D,
/// 4.4:1) did not reach AA and are darkened here. The dark values have no
/// design source yet; they are the light hues lifted until they pass on the
/// dark container colour. Both want design sign-off.
@immutable
class TrackingColors extends ThemeExtension<TrackingColors> {
  const TrackingColors({
    required this.moving,
    required this.idle,
    required this.stopped,
    required this.offline,
    required this.accent,
    required this.playbackPrimary,
  });

  final Color moving;
  final Color idle;
  final Color stopped;
  final Color offline;

  /// Brand colour for text and small marks on a surface — links, the
  /// "all" chip. The dark theme's `primary` is too dark to read there.
  final Color accent;

  /// The playback screen's primary, which the design sets darker than the
  /// app's in light mode.
  final Color playbackPrimary;

  static const light = TrackingColors(
    moving: AppColors.mint800,
    idle: Color(0xFF8A5E00),
    stopped: Color(0xFFC20042),
    offline: AppColors.neutral700,
    accent: AppColors.bluePurple500,
    playbackPrimary: AppColors.bluePurple700,
  );

  static const dark = TrackingColors(
    moving: Color(0xFF5FD394),
    idle: Color(0xFFF5C451),
    stopped: Color(0xFFFFA8C2),
    offline: AppColors.neutral200,
    accent: Color(0xFFC9C2E8),
    playbackPrimary: AppColors.bluePurple500,
  );

  /// The theme's, or the default for its brightness if a theme was built
  /// without one — never a null to force-unwrap.
  static TrackingColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<TrackingColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  TrackingColors copyWith({
    Color? moving,
    Color? idle,
    Color? stopped,
    Color? offline,
    Color? accent,
    Color? playbackPrimary,
  }) => TrackingColors(
    moving: moving ?? this.moving,
    idle: idle ?? this.idle,
    stopped: stopped ?? this.stopped,
    offline: offline ?? this.offline,
    accent: accent ?? this.accent,
    playbackPrimary: playbackPrimary ?? this.playbackPrimary,
  );

  @override
  TrackingColors lerp(covariant TrackingColors? other, double t) {
    if (other == null) return this;
    return TrackingColors(
      moving: Color.lerp(moving, other.moving, t)!,
      idle: Color.lerp(idle, other.idle, t)!,
      stopped: Color.lerp(stopped, other.stopped, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      playbackPrimary: Color.lerp(playbackPrimary, other.playbackPrimary, t)!,
    );
  }
}
