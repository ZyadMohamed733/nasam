import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/app_component_colors.dart';
import 'package:nasam/core/theme/app_status_tones.dart';
import 'package:nasam/core/theme/app_text_styles.dart';
import 'package:nasam/core/theme/tracking_colors.dart';

import '../../helpers/widget_harness.dart';

void main() {
  test('the light tones are the design\'s fill / border / text', () {
    const tones = AppStatusTones.light;
    expect(
      [for (final t in AppTone.values) tones[t]],
      const [
        AppStatusTone(
          background: Color(0xFFFFF9EB),
          border: Color(0xFFFFDA85),
          foreground: Color(0xFF8A6100),
        ),
        AppStatusTone(
          background: Color(0xFFFEF0F4),
          border: Color(0xFFFBB1C4),
          foreground: Color(0xFFD50B3E),
        ),
        AppStatusTone(
          background: Color(0xFFEEFBF4),
          border: Color(0xFFB2EECC),
          foreground: Color(0xFF17663A),
        ),
        AppStatusTone(
          background: Color(0xFFF4F1FD),
          border: Color(0xFFC6B6F7),
          foreground: Color(0xFF4316CA),
        ),
      ],
    );
  });

  test('tracking\'s moving green is the success tone\'s text', () {
    expect(
      TrackingColors.light.moving,
      AppStatusTones.light.success.foreground,
    );
  });

  test('lerp runs per tone, and stops at its ends', () {
    const light = AppStatusTones.light, dark = AppStatusTones.dark;
    expect(light.lerp(dark, 0), light);
    expect(light.lerp(dark, 1).danger, dark.danger);
    expect(light.lerp(null, .5), light);
  });

  test('component colours: the import flow\'s values', () {
    const c = AppComponentColors.light;
    expect(c.sectionTitle, const Color(0xFF1C2530));
    expect(c.tableHeaderFill, const Color(0xFFF6F6F6));
    expect(c.tableFooterBorder, const Color(0xFFF3F4F6));
    expect(c.pageButtonBorder, const Color(0xFFE8EAF0));
    expect(c.pageButtonText, const Color(0xFF9CA3AF));
    expect(c.pageButtonActive, const Color(0xFF3E2A8B));
    expect(c.dropZoneBorder, const Color(0xFFDDE3ED));
    expect(c.stepperActive, const Color(0xFF4D34AE));
    expect(c.stepperInactive, const Color(0xFFE0E0E7));
    expect(c.stepperInactiveLabel, const Color(0xFF818181));
  });

  testWidgets('the theme carries both extensions, per brightness', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      late AppStatusTones tones;
      late AppComponentColors colors;
      await pumpInApp(
        tester,
        Builder(
          builder: (context) {
            tones = AppStatusTones.of(context);
            colors = AppComponentColors.of(context);
            return const SizedBox();
          },
        ),
        dark: dark,
      );
      // Switching brightness animates the theme; read it once settled.
      await tester.pumpAndSettle();
      final want = dark ? AppStatusTones.dark : AppStatusTones.light;
      for (final tone in AppTone.values) {
        expect(tones[tone], want[tone]);
      }
      expect(
        colors.sectionTitle,
        (dark ? AppComponentColors.dark : AppComponentColors.light)
            .sectionTitle,
      );
    }
  });

  testWidgets('the import flow\'s text styles', (tester) async {
    late List<TextStyle> styles;
    await pumpInApp(
      tester,
      Builder(
        builder: (context) {
          styles = [
            AppTextStyles.bodyXLB,
            AppTextStyles.bodyMM,
            AppTextStyles.bodySR20,
            AppTextStyles.footnote,
            AppTextStyles.captionSB,
          ];
          return const SizedBox();
        },
      ),
    );
    expect(
      [for (final s in styles) (s.fontSize, s.fontWeight, s.height)],
      [
        (18.0, FontWeight.w700, 20 / 18),
        (14.0, FontWeight.w500, 20 / 14),
        (12.0, FontWeight.w400, 20 / 12),
        (13.0, FontWeight.w400, 20 / 13),
        (10.0, FontWeight.w700, AppTextStyles.normalLineHeight),
      ],
    );
    for (final s in styles) {
      expect(s.letterSpacing, 0);
      expect(s.fontFamily, 'Almarai');
    }
  });
}
