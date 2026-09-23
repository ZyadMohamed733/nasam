import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_assets_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracking_vehicles_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracking_cubit.dart';

class _MockGetVehicles extends Mock implements GetTrackingVehiclesUseCase {}

class _MockGetAssets extends Mock implements GetTrackedAssetsUseCase {}

const _truck = TrackedAsset(
  id: 'AST-1',
  name: 'Truck',
  code: 'AST-1',
  status: VehicleStatus.moving,
  assignedPerson: 'Aya Al-Rashidi',
  routeProgress: .5,
);
const _van = TrackedAsset(
  id: 'AST-2',
  name: 'Van',
  code: 'AST-2',
  status: VehicleStatus.stopped,
  assignedPerson: 'Omar Hassan',
  routeProgress: .1,
);
const _truckGps = TrackingVehicle(
  id: '1',
  assetId: 'AST-1',
  latitude: 24.9,
  longitude: 46.3,
  status: VehicleStatus.moving,
);
const _vanGps = TrackingVehicle(
  id: '2',
  assetId: 'AST-2',
  latitude: 24.8,
  longitude: 46.4,
  status: VehicleStatus.stopped,
);

const _vehicles = [_truckGps, _vanGps];
const _assets = [_truck, _van];
const _loaded = TrackingLoaded(vehicles: _vehicles, assets: _assets);
const _failure = ServerFailure(message: 'down');

void main() {
  late _MockGetVehicles getVehicles;
  late _MockGetAssets getAssets;

  setUp(() {
    getVehicles = _MockGetVehicles();
    getAssets = _MockGetAssets();
  });

  TrackingCubit build() => TrackingCubit(getVehicles, getAssets);

  void serve({
    Either<Failure, List<TrackingVehicle>> vehicles = const Right(_vehicles),
    Either<Failure, List<TrackedAsset>> assets = const Right(_assets),
  }) {
    when(() => getVehicles()).thenAnswer((_) async => vehicles);
    when(() => getAssets()).thenAnswer((_) async => assets);
  }

  test('starts in TrackingInitial', () {
    expect(build().state, const TrackingInitial());
  });

  group('first load', () {
    blocTest<TrackingCubit, TrackingState>(
      'initial → loading → loaded',
      setUp: serve,
      build: build,
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(), _loaded],
    );

    blocTest<TrackingCubit, TrackingState>(
      'a vehicles failure fails the load, with nothing to fall back on',
      setUp: () => serve(vehicles: const Left(_failure)),
      build: build,
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(), TrackingFailure(_failure)],
    );

    blocTest<TrackingCubit, TrackingState>(
      'an assets failure fails it too — a map with no list has no design',
      setUp: () => serve(assets: const Left(_failure)),
      build: build,
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(), TrackingFailure(_failure)],
    );

    blocTest<TrackingCubit, TrackingState>(
      'no vehicles and no assets is empty, not loaded',
      setUp: () => serve(vehicles: const Right([]), assets: const Right([])),
      build: build,
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(), TrackingEmpty()],
    );

    // Proves parallelism rather than asserting it: neither request is
    // allowed to finish until both have been made.
    test('requests vehicles and assets in parallel', () async {
      final vehicles = Completer<Either<Failure, List<TrackingVehicle>>>();
      final assets = Completer<Either<Failure, List<TrackedAsset>>>();
      when(() => getVehicles()).thenAnswer((_) => vehicles.future);
      when(() => getAssets()).thenAnswer((_) => assets.future);
      final cubit = build();

      final load = cubit.load();
      await Future<void>.delayed(Duration.zero);

      verify(() => getVehicles()).called(1);
      verify(() => getAssets()).called(1);

      vehicles.complete(const Right(_vehicles));
      assets.complete(const Right(_assets));
      await load;
      expect(cubit.state, _loaded);
      await cubit.close();
    });

    blocTest<TrackingCubit, TrackingState>(
      'a second load while one is in flight is ignored',
      setUp: serve,
      build: build,
      act: (c) => Future.wait([c.load(), c.load()]),
      expect: () => const [TrackingLoading(), _loaded],
      verify: (_) => verify(() => getVehicles()).called(1),
    );
  });

  group('refresh', () {
    const narrowed = TrackingLoaded(
      vehicles: _vehicles,
      assets: _assets,
      filter: VehicleStatus.moving,
      query: 'tru',
    );

    blocTest<TrackingCubit, TrackingState>(
      'loaded → loading(previous) → loaded, keeping filter and search',
      setUp: serve,
      build: build,
      seed: () => narrowed,
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(previous: narrowed), narrowed],
    );

    blocTest<TrackingCubit, TrackingState>(
      'loaded → loading(previous) → failure(previous) keeps the last data',
      setUp: () => serve(vehicles: const Left(_failure)),
      build: build,
      seed: () => narrowed,
      act: (c) => c.load(),
      expect: () => const [
        TrackingLoading(previous: narrowed),
        TrackingFailure(_failure, previous: narrowed),
      ],
      verify: (c) => expect(c.state.visible, narrowed),
    );

    blocTest<TrackingCubit, TrackingState>(
      'retry from failure(previous) recovers, still carrying the data',
      setUp: serve,
      build: build,
      seed: () => const TrackingFailure(_failure, previous: narrowed),
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(previous: narrowed), narrowed],
    );

    blocTest<TrackingCubit, TrackingState>(
      'retry from a first-load failure has nothing to carry',
      setUp: serve,
      build: build,
      seed: () => const TrackingFailure(_failure),
      act: (c) => c.load(),
      expect: () => const [TrackingLoading(), _loaded],
    );

    blocTest<TrackingCubit, TrackingState>(
      'refreshing into an empty fleet drops the filter with it',
      setUp: () => serve(vehicles: const Right([]), assets: const Right([])),
      build: build,
      seed: () => narrowed,
      act: (c) => c.load(),
      expect: () => const [
        TrackingLoading(previous: narrowed),
        TrackingEmpty(),
      ],
    );
  });

  group('filter', () {
    blocTest<TrackingCubit, TrackingState>(
      'narrows the list to one status',
      build: build,
      seed: () => _loaded,
      act: (c) => c.setFilter(VehicleStatus.stopped),
      expect: () => [_loaded.withFilter(VehicleStatus.stopped)],
      verify: (c) => expect(c.state.visible!.visibleAssets, [_van]),
    );

    blocTest<TrackingCubit, TrackingState>(
      'null goes back to all',
      build: build,
      seed: () => _loaded.withFilter(VehicleStatus.stopped),
      act: (c) => c.setFilter(null),
      expect: () => const [_loaded],
    );

    blocTest<TrackingCubit, TrackingState>(
      'reselecting the current filter emits nothing',
      build: build,
      seed: () => _loaded.withFilter(VehicleStatus.moving),
      act: (c) => c.setFilter(VehicleStatus.moving),
      expect: () => const <TrackingState>[],
    );

    blocTest<TrackingCubit, TrackingState>(
      'is ignored before anything has loaded',
      build: build,
      act: (c) => c.setFilter(VehicleStatus.moving),
      expect: () => const <TrackingState>[],
    );
  });

  group('search', () {
    blocTest<TrackingCubit, TrackingState>(
      'commits once typing pauses, with the last text only',
      build: build,
      seed: () => _loaded,
      act: (c) {
        c
          ..onQueryChanged('v')
          ..onQueryChanged('va')
          ..onQueryChanged('van');
      },
      wait: TrackingCubit.searchDebounce + const Duration(milliseconds: 50),
      expect: () => [_loaded.withQuery('van')],
      verify: (c) => expect(c.state.visible!.visibleAssets, [_van]),
    );

    blocTest<TrackingCubit, TrackingState>(
      'emits nothing before the debounce elapses',
      build: build,
      seed: () => _loaded,
      act: (c) => c.onQueryChanged('van'),
      wait: const Duration(milliseconds: 100),
      expect: () => const <TrackingState>[],
    );

    blocTest<TrackingCubit, TrackingState>(
      'matches name, code and assigned person, case-insensitively',
      build: build,
      seed: () => _loaded,
      act: (c) => c.onQueryChanged('OMAR'),
      wait: TrackingCubit.searchDebounce + const Duration(milliseconds: 50),
      verify: (c) => expect(c.state.visible!.visibleAssets, [_van]),
    );

    // The close() override cancels the pending timer; without it this emits
    // after close and bloc throws.
    test('a pending search is cancelled when the cubit closes', () async {
      final cubit = build()..emit(_loaded);
      cubit.onQueryChanged('van');
      await cubit.close();
      await Future<void>.delayed(
        TrackingCubit.searchDebounce + const Duration(milliseconds: 50),
      );
      expect(cubit.state, _loaded);
    });
  });

  group('marker lookup', () {
    test('resolves a vehicle to its asset by id', () {
      final cubit = build()..emit(_loaded);
      expect(cubit.assetForVehicle(_vanGps), _van);
      expect(cubit.assetForVehicle(_truckGps), _truck);
    });

    test('still resolves while a filter hides the asset from the list', () {
      final cubit = build()..emit(_loaded.withFilter(VehicleStatus.moving));
      expect(cubit.assetForVehicle(_vanGps), _van);
    });

    test('is null for an asset not in the fleet, or before a load', () {
      const stray = TrackingVehicle(
        id: '9',
        assetId: 'AST-404',
        latitude: 0,
        longitude: 0,
        status: VehicleStatus.idle,
      );
      expect(build().assetForVehicle(_truckGps), isNull);
      expect((build()..emit(_loaded)).assetForVehicle(stray), isNull);
    });

    test('keeps working through a failed refresh', () {
      final cubit = build()
        ..emit(const TrackingFailure(_failure, previous: _loaded));
      expect(cubit.assetForVehicle(_vanGps), _van);
    });
  });
}
