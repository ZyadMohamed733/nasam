import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shared drawer palette, independent of the decorative PNG.
class AppDrawerTheme extends ThemeExtension<AppDrawerTheme> {
  const AppDrawerTheme({
    this.background = const Color(0xFF2E2166),
    this.foreground = AppColors.neutralWhite,
    this.muted = const Color(0xFFDDD4F0),
    this.section = AppColors.darkPurple200,
    this.selected = AppColors.bluePurple50,
    this.profileText = const Color(0xFF171129),
    this.avatarBackground = AppColors.neutral200,
    this.avatarForeground = AppColors.neutral600,
  });
  final Color background;
  final Color foreground;
  final Color muted;
  final Color section;
  final Color selected;
  final Color profileText;
  final Color avatarBackground;
  final Color avatarForeground;
  static AppDrawerTheme of(BuildContext context) =>
      Theme.of(context).extension<AppDrawerTheme>() ?? const AppDrawerTheme();
  @override
  AppDrawerTheme copyWith({
    Color? background,
    Color? foreground,
    Color? muted,
    Color? section,
    Color? selected,
    Color? profileText,
    Color? avatarBackground,
    Color? avatarForeground,
  }) => AppDrawerTheme(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    muted: muted ?? this.muted,
    section: section ?? this.section,
    selected: selected ?? this.selected,
    profileText: profileText ?? this.profileText,
    avatarBackground: avatarBackground ?? this.avatarBackground,
    avatarForeground: avatarForeground ?? this.avatarForeground,
  );
  @override
  AppDrawerTheme lerp(covariant AppDrawerTheme? other, double t) {
    if (other == null) return this;
    return AppDrawerTheme(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      section: Color.lerp(section, other.section, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      profileText: Color.lerp(profileText, other.profileText, t)!,
      avatarBackground: Color.lerp(
        avatarBackground,
        other.avatarBackground,
        t,
      )!,
      avatarForeground: Color.lerp(
        avatarForeground,
        other.avatarForeground,
        t,
      )!,
    );
  }
}
