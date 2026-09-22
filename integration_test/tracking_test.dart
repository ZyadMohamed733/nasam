import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/theme/app_theme.dart';
import 'package:nasam/features/tracking/data/dummy_tracking_repository.dart';
import 'package:nasam/features/tracking/presentation/tracking_page.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_controls.dart';

/// Runs the real native map without requiring a backend login.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native map clusters fleet and opens Arabic drawer', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(AppSizes.designWidth, AppSizes.designHeight),
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: TrackingPage(repository: DummyTrackingRepository()),
        ),
      ),
    );
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(seconds: 1));
      final maps = tester.widgetList<GoogleMap>(find.byType(GoogleMap));
      if (maps.isNotEmpty && maps.single.markers.isNotEmpty) break;
    }
    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(map.markers.length, greaterThan(3));
    expect(map.markers.length, lessThan(68));
    expect(map.markers.where((m) => m.anchor.dy != .5), isNotEmpty);
    expect(tester.takeException(), isNull);
    final cluster = map.markers.firstWhere((marker) => marker.onTap != null);
    cluster.onTap!();
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(seconds: 1));
      final focused = tester.widget<GoogleMap>(find.byType(GoogleMap));
      if (!focused.markers.any(
            (marker) => marker.markerId == cluster.markerId,
          ) &&
          focused.markers.where((marker) => marker.anchor.dy != .5).length >
              3) {
        break;
      }
    }
    final focused = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(
      focused.markers.any((marker) => marker.markerId == cluster.markerId),
      false,
    );
    expect(
      focused.markers.where((marker) => marker.anchor.dy != .5).length,
      greaterThan(3),
    );
    await tester.tap(
      find.byWidgetPredicate((w) => w is TrackingIconButton && w.menu),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aya Al-Rashidi').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
