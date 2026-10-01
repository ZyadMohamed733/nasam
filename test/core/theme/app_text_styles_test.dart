import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/app_text_styles.dart';

import '../../helpers/widget_harness.dart';

/// The named styles match the Figma text styles on the 402 design frame,
/// where `.sp` is 1.
void main() {
  testWidgets('each style is its Figma text style', (tester) async {
    late Map<String, TextStyle> styles;
    await pumpInApp(
      tester,
      Builder(
        builder: (context) {
          styles = {
            'bodyMB': AppTextStyles.bodyMB,
            'bodyMR': AppTextStyles.bodyMR,
            'bodySR': AppTextStyles.bodySR,
            'captionM': AppTextStyles.captionM,
            'captionS': AppTextStyles.captionS,
          };
          return const SizedBox();
        },
      ),
    );
    const expected = {
      'bodyMB': (FontWeight.w700, 14.0, 20 / 14),
      'bodyMR': (FontWeight.w400, 14.0, 20 / 14),
      'bodySR': (FontWeight.w400, 12.0, 1.3),
      'captionM': (FontWeight.w400, 11.0, AppTextStyles.normalLineHeight),
      'captionS': (FontWeight.w400, 10.0, AppTextStyles.normalLineHeight),
    };
    for (final MapEntry(key: name, value: (weight, size, height))
        in expected.entries) {
      final style = styles[name]!;
      expect(style.fontFamily, 'Almarai', reason: name);
      expect(style.fontWeight, weight, reason: name);
      expect(style.fontSize, size, reason: name);
      expect(style.height, height, reason: name);
      expect(style.letterSpacing, 0, reason: name);
      expect(style.color, isNull, reason: '$name: colour is a token');
    }
  });
}
