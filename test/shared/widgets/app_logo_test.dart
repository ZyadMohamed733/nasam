import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_assets.dart';
import 'package:nasam/shared/widgets/app_logo.dart';

import '../../helpers/widget_harness.dart';

void main() {
  group('AppLogo', () {
    testWidgets('renders each design size as a square of that size', (
      tester,
    ) async {
      for (final size in AppLogoSize.values) {
        await pumpInApp(tester, AppLogo(size: size));
        expect(
          tester.getSize(find.byType(AppLogo)),
          Size(size.value, size.value),
          reason: size.name,
        );
      }
    });

    // Vector.svg is an SVG only by extension — Figma wrapped a bitmap in a
    // <pattern> fill, which flutter_svg cannot draw, so it renders as nothing.
    testWidgets('draws the raster mark, not the unsupported SVG', (
      tester,
    ) async {
      await pumpInApp(tester, const AppLogo());

      final image = tester.widget<Image>(
        find.descendant(of: find.byType(AppLogo), matching: find.byType(Image)),
      );
      expect((image.image as AssetImage).assetName, AppAssets.logoMark);
    });

    testWidgets('is hidden from screen readers unless given a label', (
      tester,
    ) async {
      await pumpInApp(tester, const AppLogo());
      expect(find.bySemanticsLabel('Nasam'), findsNothing);

      await pumpInApp(tester, const AppLogo(semanticsLabel: 'Nasam'));
      expect(find.bySemanticsLabel('Nasam'), findsOneWidget);
    });
  });
}
