@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:nasam/features/play_back/presentation/utils/playback_range.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_asset_card.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_summary.dart';

import '../helpers/asset_screens.dart';
import '../helpers/fake_map_platform.dart';
import '../helpers/tracking_screen.dart';

/// The tracking screens across every combination that can break them
/// independently: English/LTR and Arabic/RTL, light and dark, text scale 1.0,
/// 1.3 and 1.5, on a 360×640 phone and an 800×1280 tablet.
///
/// Written to `goldens/tracking/<screen>_<device>_<theme>_<locale>_<scale>.png`.
/// Generated and compared on macOS only — other platforms rasterise text
/// differently — so they are skipped elsewhere; see the README.
void main() {
  const devices = {'phone': Size(360, 640), 'tablet': Size(800, 1280)};

  /// A day inside the playback fixture's recording, fixed so the screen's
  /// dates never change with the calendar.
  final playbackRange = PlaybackRange.fromQuery(
    from: '2026-01-15',
    to: '2026-01-15',
    now: DateTime(2026, 1, 20),
  );

  const card = TrackedAsset(
    id: 'AST-0017',
    name: 'Refrigerated truck 17',
    code: 'AST-0017',
    status: VehicleStatus.idle,
    assignedPerson: 'Aya Al-Rashidi',
    routeProgress: .4,
    statusDuration: Duration(minutes: 7, seconds: 9),
  );

  TrackedAsset cardWithStatus(VehicleStatus status) => TrackedAsset(
    id: card.id,
    name: card.name,
    code: card.code,
    status: status,
    assignedPerson: card.assignedPerson,
    routeProgress: card.routeProgress,
    statusDuration: card.statusDuration,
  );

  Finder inSheet(String text) => find.descendant(
    of: find.byType(TrackingSummary),
    matching: find.text(text),
  );

  Future<void> openSheet(WidgetTester tester, Locale locale) async {
    await tester.tap(inSheet(locale.languageCode == 'ar' ? 'عرض' : 'Show'));
    await tester.pumpAndSettle();
  }

  /// Screen name → how to put it on screen. Each gets the app shell, the
  /// locale, theme, scale and size from [pumpScreen].
  final screens =
      <
        String,
        Future<void> Function(
          WidgetTester tester,
          Future<void> Function(Widget) pump,
          Locale locale,
        )
      >{
        'tracking_collapsed': (tester, pump, locale) async {
          await pump(trackingScreen());
        },
        'tracking_expanded': (tester, pump, locale) async {
          await pump(trackingScreen());
          await openSheet(tester, locale);
        },
        'drawer_open': (tester, pump, locale) async {
          await pump(trackingScreen());
          tester
              .widget<AdvancedDrawer>(find.byType(AdvancedDrawer))
              .controller!
              .showDrawer();
          await tester.pumpAndSettle();
        },
        'asset_card': (tester, pump, locale) async {
          // In a scroll view, as in the list: under bounded height the
          // card's column would stretch to fill the screen.
          await pump(
            const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: TrackingAssetCard(asset: card),
            ),
          );
        },
        for (final status in VehicleStatus.values)
          'asset_card_${status.name}': (tester, pump, locale) async {
            await pump(
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: TrackingAssetCard(asset: cardWithStatus(status)),
              ),
            );
          },
        'details_information': (tester, pump, locale) async {
          await pump(assetDetailsScreen());
        },
        'playback': (tester, pump, locale) async {
          await pump(assetPlaybackScreen(fixtureAssetId, playbackRange));
        },
      };

  /// Image and SVG assets load through the bundle on real IO, which the
  /// fake clock never completes: resolve them on real time, then repaint.
  Future<void> loadAssets(WidgetTester tester) async {
    for (var round = 0; round < 2; round++) {
      await tester.runAsync(() async {
        final context = tester.element(find.byType(MaterialApp));
        for (final image in tester.widgetList<Image>(find.byType(Image))) {
          await precacheImage(image.image, context);
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
    }
  }

  for (final MapEntry(key: screen, value: show) in screens.entries) {
    for (final MapEntry(key: device, value: size) in devices.entries) {
      for (final dark in [false, true]) {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          for (final scale in [1.0, 1.3, 1.5]) {
            final theme = dark ? 'dark' : 'light';
            final name =
                '${screen}_${device}_${theme}_${locale.languageCode}_$scale';
            testWidgets(name, skip: !Platform.isMacOS, (tester) async {
              GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
              registerTrackingScreenFakes();
              final nav = recordingRouter();
              await show(
                tester,
                (widget) => pumpScreen(
                  tester,
                  widget,
                  router: nav.router,
                  size: size,
                  textScale: scale,
                  locale: locale,
                  dark: dark,
                ),
                locale,
              );
              await loadAssets(tester);

              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile('goldens/tracking/$name.png'),
              );

              // Unmount so nothing holding a timer outlives the test.
              await tester.pumpWidget(const SizedBox());
            });
          }
        }
      }
    }
  }
}
