import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/theme/tracking_colors.dart';
import 'package:nasam/core/utils/bidi.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/presentation/tracking_style.dart';
import 'package:nasam/features/tracking/presentation/tracking_units.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_asset_card.dart';

import '../../../helpers/widget_harness.dart';

/// Resolves [TrackingUnits] for [locale] without the full app shell.
Future<TrackingUnits> _units(WidgetTester tester, Locale locale) async {
  late TrackingUnits units;
  await tester.pumpWidget(
    Localizations(
      locale: locale,
      delegates: AppLocalizationsSetup.localizationsDelegates,
      child: Builder(
        builder: (context) {
          units = TrackingUnits.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return units;
}

TrackedAsset _asset({Duration? inStatus}) => TrackedAsset(
  id: 'AST-1',
  name: 'Truck',
  code: 'AST-1',
  status: VehicleStatus.idle,
  assignedPerson: 'Aya Al-Rashidi',
  routeProgress: .4,
  statusDuration: inStatus,
);

void main() {
  group('units', () {
    testWidgets('English', (tester) async {
      final u = await _units(tester, const Locale('en'));
      expect(u.speedKph(62.26), '62.3 km/h');
      expect(u.distanceKm(1234.5), '1,234.5 km');
      expect(u.weightKg(18000), '18,000 kg');
      expect(u.hours(3), '3 h');
      expect(u.celsius(-4.5), '-4.5 °C');
      expect(u.percent(71), '71%');
      expect(u.duration(const Duration(seconds: 429)), '07m 09s');
      expect(u.duration(const Duration(seconds: 3725)), '1h 02m');
    });

    testWidgets('Arabic takes its units and number format from the locale', (
      tester,
    ) async {
      final u = await _units(tester, const Locale('ar'));
      final number = u.number(1234.5);
      expect(u.speedKph(1234.5), '$number كم/س');
      expect(u.percent(71), '${u.number(71)}٪');
      expect(u.duration(const Duration(seconds: 429)), contains(' م '));
      expect(u.distanceKm(1), isNot(contains('km')));
    });
  });

  group('asset card', () {
    testWidgets('shows how long the asset has been in its status', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        TrackingAssetCard(asset: _asset(inStatus: const Duration(seconds: 429))),
      );
      expect(
        find.text(joinIsolated(['AST-1', '07m 09s'], ' • ')),
        findsOneWidget,
      );
    });

    testWidgets('shows no time when the source gives none', (tester) async {
      await pumpInApp(tester, TrackingAssetCard(asset: _asset()));
      expect(find.text(joinIsolated(['AST-1'], ' • ')), findsOneWidget);
      expect(find.textContaining('٠٧'), findsNothing);
    });
  });

  group('TrackingColors', () {
    Future<Color> statusIn(WidgetTester tester, ThemeData theme) async {
      late Color color;
      await tester.pumpWidget(
        Theme(
          data: theme,
          child: Builder(
            builder: (context) {
              color = TrackingStyle.status(context, VehicleStatus.stopped);
              return const SizedBox();
            },
          ),
        ),
      );
      return color;
    }

    // A theme built without the extension must not crash on a `!`.
    testWidgets('falls back to the brightness default', (tester) async {
      expect(
        await statusIn(tester, ThemeData()),
        TrackingColors.light.stopped,
      );
      expect(
        await statusIn(tester, ThemeData(brightness: Brightness.dark)),
        TrackingColors.dark.stopped,
      );
    });

    testWidgets('the app theme carries a dark variant', (tester) async {
      await pumpInApp(tester, const SizedBox(), dark: true);
      final context = tester.element(find.byType(SizedBox));
      expect(TrackingColors.of(context), same(TrackingColors.dark));
    });
  });
}
