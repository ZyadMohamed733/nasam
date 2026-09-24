import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_assets.dart';
import 'package:nasam/core/theme/app_drawer_theme.dart';
import 'package:nasam/shared/widgets/app_drawer.dart';

import '../../helpers/widget_harness.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    testWidgets('$locale drawer scrolls with large text on a short screen', (
      tester,
    ) async {
      var loggedOut = false;
      await pumpInApp(
        tester,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: AppDrawer(
              onLogout: () => loggedOut = true,
              profileName: 'Test operator',
            ),
          ),
        ),
        locale: Locale(locale),
      );
      tester.view.physicalSize = const Size(320, 480);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final logout = find.text(locale == 'ar' ? 'تسجيل الخروج' : 'Logout');
      await tester.ensureVisible(logout);
      // The drawer is a sliver viewport: a scroll takes effect at the next
      // layout, so positions are stale until a pump.
      await tester.pump();
      await tester.tap(logout);
      expect(loggedOut, isTrue);
      await tester.ensureVisible(find.text('Test operator'));
      await tester.pump();
      expect(find.text('Test operator').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('changing drawer color keeps the separate bottom artwork', (
    tester,
  ) async {
    const color = Colors.green;
    await pumpInApp(
      tester,
      Builder(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            extensions: [
              AppDrawerTheme.of(context).copyWith(background: color),
            ],
          ),
          child: AppDrawer(onLogout: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final background = find.descendant(
      of: find.byType(AppDrawerBackground),
      matching: find.byType(ColoredBox),
    );
    expect(tester.widget<ColoredBox>(background).color, color);
    final artwork = tester
        .widgetList<Image>(find.byType(Image))
        .where(
          (image) =>
              image.image is AssetImage &&
              (image.image as AssetImage).assetName ==
                  AppAssets.drawerBottomBackground,
        );
    expect(artwork, hasLength(1));
  });
}
