import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset_details.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_playback_segment.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_details_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_notifications_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_playback_segments_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_details_cubit.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_playback_cubit.dart';

class _MockGetDetails extends Mock implements GetAssetDetailsUseCase {}

class _MockGetNotifications extends Mock
    implements GetAssetNotificationsUseCase {}

class _MockGetSegments extends Mock implements GetPlaybackSegmentsUseCase {}

final _details = TrackedAssetDetails(
  assetId: 'AST-1',
  name: 'Truck',
  equipmentType: 'معدة',
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
final _alert = TrackedAssetNotification(
  type: TrackingNotificationType.speeding,
  date: DateTime(2025, 10, 17, 9),
  speedKph: 90,
);
final _leg = TrackingPlaybackSegment(
  startedAt: DateTime(2025, 10, 17, 8),
  endedAt: DateTime(2025, 10, 17, 9),
  distanceKm: 4,
  durationMinutes: 60,
  maxSpeedKph: 50,
  startPlace: 'A',
  endPlace: 'B',
);
const _failure = ServerFailure(message: 'down');

void main() {
  group('AssetDetailsCubit', () {
    late _MockGetDetails getDetails;
    late _MockGetNotifications getNotifications;

    setUp(() {
      getDetails = _MockGetDetails();
      getNotifications = _MockGetNotifications();
    });

    AssetDetailsCubit build() => AssetDetailsCubit(getDetails, getNotifications);

    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'loading → loaded with details and alerts',
      setUp: () {
        when(() => getDetails('AST-1')).thenAnswer((_) async => Right(_details));
        when(
          () => getNotifications('AST-1'),
        ).thenAnswer((_) async => Right([_alert]));
      },
      build: build,
      act: (c) => c.load('AST-1'),
      expect: () => [
        const AssetDetailsLoading(),
        AssetDetailsLoaded(
          details: _details,
          alerts: AssetAlertsLoaded([_alert]),
        ),
      ],
    );

    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'a details failure fails the screen',
      setUp: () {
        when(
          () => getDetails('AST-1'),
        ).thenAnswer((_) async => const Left(_failure));
        when(
          () => getNotifications('AST-1'),
        ).thenAnswer((_) async => Right([_alert]));
      },
      build: build,
      act: (c) => c.load('AST-1'),
      expect: () => const [
        AssetDetailsLoading(),
        AssetDetailsFailure(_failure),
      ],
    );

    // Alerts are one tab of five; losing them must not lose the screen, and
    // must not pass for "no alerts" either.
    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'an alerts failure still loads, with the failure carried for the tab',
      setUp: () {
        when(() => getDetails('AST-1')).thenAnswer((_) async => Right(_details));
        when(
          () => getNotifications('AST-1'),
        ).thenAnswer((_) async => const Left(_failure));
      },
      build: build,
      act: (c) => c.load('AST-1'),
      expect: () => [
        const AssetDetailsLoading(),
        AssetDetailsLoaded(
          details: _details,
          alerts: const AssetAlertsFailed(_failure),
        ),
      ],
    );

    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'retry from failure goes back through loading',
      setUp: () {
        when(() => getDetails('AST-1')).thenAnswer((_) async => Right(_details));
        when(
          () => getNotifications('AST-1'),
        ).thenAnswer((_) async => const Right([]));
      },
      build: build,
      seed: () => const AssetDetailsFailure(_failure),
      act: (c) => c.load('AST-1'),
      expect: () => [
        const AssetDetailsLoading(),
        AssetDetailsLoaded(
          details: _details,
          alerts: const AssetAlertsLoaded([]),
        ),
      ],
    );

    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'retrying the alerts re-requests them alone, details untouched',
      setUp: () {
        when(() => getDetails('AST-1')).thenAnswer((_) async => Right(_details));
        var calls = 0;
        when(() => getNotifications('AST-1')).thenAnswer(
          (_) async => calls++ == 0 ? const Left(_failure) : Right([_alert]),
        );
      },
      build: build,
      act: (c) async {
        await c.load('AST-1');
        await c.retryAlerts();
      },
      skip: 2, // loading, then loaded with the failed alerts
      expect: () => [
        AssetDetailsLoaded(
          details: _details,
          alerts: const AssetAlertsLoading(),
        ),
        AssetDetailsLoaded(
          details: _details,
          alerts: AssetAlertsLoaded([_alert]),
        ),
      ],
      verify: (_) {
        verify(() => getDetails('AST-1')).called(1);
        verify(() => getNotifications('AST-1')).called(2);
      },
    );

    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'an alerts retry that fails again stays a failure, not an empty list',
      setUp: () {
        when(() => getDetails('AST-1')).thenAnswer((_) async => Right(_details));
        when(
          () => getNotifications('AST-1'),
        ).thenAnswer((_) async => const Left(_failure));
      },
      build: build,
      act: (c) async {
        await c.load('AST-1');
        await c.retryAlerts();
      },
      skip: 2,
      expect: () => [
        AssetDetailsLoaded(
          details: _details,
          alerts: const AssetAlertsLoading(),
        ),
        AssetDetailsLoaded(
          details: _details,
          alerts: const AssetAlertsFailed(_failure),
        ),
      ],
    );

    blocTest<AssetDetailsCubit, AssetDetailsState>(
      'an alerts retry before the details have loaded does nothing',
      build: build,
      act: (c) => c.retryAlerts(),
      expect: () => const <AssetDetailsState>[],
      verify: (_) => verifyNever(() => getNotifications(any())),
    );
  });

  group('AssetPlaybackCubit', () {
    late _MockGetSegments getSegments;
    final from = DateTime(2025, 10, 17);
    final to = DateTime(2025, 10, 18);

    setUp(() => getSegments = _MockGetSegments());

    AssetPlaybackCubit build() => AssetPlaybackCubit(getSegments);

    void serve(Either<Failure, List<TrackingPlaybackSegment>> result) => when(
      () => getSegments(
        assetId: any(named: 'assetId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => result);

    blocTest<AssetPlaybackCubit, AssetPlaybackState>(
      'loading → loaded',
      setUp: () => serve(Right([_leg])),
      build: build,
      act: (c) => c.load(assetId: 'AST-1', from: from, to: to),
      expect: () => [
        const AssetPlaybackLoading(),
        AssetPlaybackLoaded([_leg]),
      ],
    );

    blocTest<AssetPlaybackCubit, AssetPlaybackState>(
      'loading → failure',
      setUp: () => serve(const Left(_failure)),
      build: build,
      act: (c) => c.load(assetId: 'AST-1', from: from, to: to),
      expect: () => const [
        AssetPlaybackLoading(),
        AssetPlaybackFailure(_failure),
      ],
    );

    // A slow answer for an old range must not overwrite a newer one.
    test('a response to a superseded range is dropped', () async {
      final slow = Completer<Either<Failure, List<TrackingPlaybackSegment>>>();
      final newRange = DateTime(2025, 10, 20);
      when(
        () => getSegments(assetId: 'AST-1', from: from, to: to),
      ).thenAnswer((_) => slow.future);
      when(
        () => getSegments(
          assetId: 'AST-1',
          from: newRange,
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => const Right([]));
      final cubit = build();

      final stale = cubit.load(assetId: 'AST-1', from: from, to: to);
      await cubit.load(
        assetId: 'AST-1',
        from: newRange,
        to: newRange.add(const Duration(days: 1)),
      );
      slow.complete(Right([_leg]));
      await stale;

      expect(cubit.state, const AssetPlaybackLoaded([]));
      await cubit.close();
    });
  });
}
