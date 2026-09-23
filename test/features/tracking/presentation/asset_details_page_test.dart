import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset_details.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_details_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_notifications_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_details_cubit.dart';
import 'package:nasam/features/tracking/presentation/pages/tracking_asset_details_page.dart';

import '../../../helpers/widget_harness.dart';

class _MockGetDetails extends Mock implements GetAssetDetailsUseCase {}

class _MockGetNotifications extends Mock
    implements GetAssetNotificationsUseCase {}

const _asset = TrackedAsset(
  id: 'AST-1',
  name: 'Truck',
  code: 'AST-1',
  status: VehicleStatus.moving,
  assignedPerson: 'Aya Al-Rashidi',
  routeProgress: .5,
);

final _details = TrackedAssetDetails(
  assetId: 'AST-1',
  name: 'Truck',
  equipmentType: 'Equipment',
  companyName: 'Nasam',
  managerName: 'Ahmed',
  address: 'Riyadh',
  speedKph: 13,
  durationHours: 1,
  connectionMinutesAgo: 2,
  lastGpsAt: DateTime(2025, 10, 17, 9),
  distanceKm: 1,
  fuelPercent: 90,
  idleHours: 0,
  tankLevelPercent: 70,
  temperatureCelsius: 26,
  weightKg: 2000,
  sensorCode: 'IO9',
  sensorBatteryMillivolts: 2600,
  sensorDistanceKm: 10,
  fuelUsagePercent: 30,
  doorOpen: false,
  engineOn: true,
);

/// The alerts tab is last in a scrollable tab bar and starts off-screen on a
/// phone, so it is scrolled to before it is tapped, as a user would have to.
Future<void> _openAlertsTab(WidgetTester tester) async {
  final tab = find.text('Notifications');
  await tester.ensureVisible(tab);
  await tester.pumpAndSettle();
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  late _MockGetDetails getDetails;
  late _MockGetNotifications getNotifications;

  setUp(() {
    getDetails = _MockGetDetails();
    getNotifications = _MockGetNotifications();
    when(() => getDetails('AST-1')).thenAnswer((_) async => Right(_details));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await pumpInApp(
      tester,
      BlocProvider(
        create: (_) =>
            AssetDetailsCubit(getDetails, getNotifications)..load('AST-1'),
        child: const TrackingAssetDetailsPage(asset: _asset),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a failed alerts load leaves the other tabs usable, and the '
      'alerts tab retries only the alerts', (tester) async {
    var calls = 0;
    when(() => getNotifications('AST-1')).thenAnswer(
      (_) async => calls++ == 0
          ? const Left(ServerFailure(message: 'down'))
          : Right([
              TrackedAssetNotification(
                type: TrackingNotificationType.speeding,
                date: DateTime(2025, 10, 17, 9),
                speedKph: 90,
              ),
            ]),
    );

    await pumpPage(tester);

    // The information tab rendered from the details, untouched by the alerts.
    expect(find.text('Asset name'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);

    await _openAlertsTab(tester);

    // A failure, not the empty-state copy.
    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    expect(find.text('No notifications for this asset.'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Speed limit exceeded'), findsOneWidget);
    verify(() => getDetails('AST-1')).called(1);
    verify(() => getNotifications('AST-1')).called(2);
  });

  testWidgets('an asset with genuinely no alerts shows the empty state',
      (tester) async {
    when(
      () => getNotifications('AST-1'),
    ).thenAnswer((_) async => const Right([]));

    await pumpPage(tester);
    await _openAlertsTab(tester);

    expect(find.text('No notifications for this asset.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Retry'), findsNothing);
  });
}
