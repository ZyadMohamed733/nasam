import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/features/poi/domain/entities/poi_draft.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_icon.dart';

import '../../helpers/widget_harness.dart';

/// The four POI icons are the designer's stroke SVGs (Solar: Map Point,
/// Hospital, Buildings, Gas Station), recoloured through `ColorFilter`.
void main() {
  testWidgets('every POI icon renders, tinted, at the list and picker sizes', (
    tester,
  ) async {
    const icons = ValueKey('icons');
    await pumpInApp(
      tester,
      RepaintBoundary(
        key: icons,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final size in [20.0, 24.0])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final icon in PoiIcon.values)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: PoiIconImage(
                        icon: icon,
                        size: size,
                        color: AppColors.violet500,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
    expect(pictures, hasLength(PoiIcon.values.length * 2));
    for (final picture in pictures) {
      expect(
        picture.colorFilter,
        const ColorFilter.mode(AppColors.violet500, BlendMode.srcIn),
      );
    }
    await expectLater(
      find.byKey(icons),
      matchesGoldenFile('goldens/poi_icons.png'),
    );
  });
}
