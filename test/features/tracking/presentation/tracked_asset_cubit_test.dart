import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_asset_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracked_asset_cubit.dart';

class _MockGetAsset extends Mock implements GetTrackedAssetUseCase {}

const _asset = TrackedAsset(
  id: 'AST-1',
  name: 'Truck',
  code: 'AST-1',
  status: VehicleStatus.moving,
  assignedPerson: 'Aya',
  routeProgress: .5,
);

void main() {
  late _MockGetAsset getAsset;
  setUp(() => getAsset = _MockGetAsset());

  TrackedAssetCubit build() => TrackedAssetCubit(getAsset);

  blocTest<TrackedAssetCubit, TrackedAssetState>(
    'loading → loaded',
    setUp: () => when(
      () => getAsset('AST-1'),
    ).thenAnswer((_) async => const Right(_asset)),
    build: build,
    act: (c) => c.load('AST-1'),
    expect: () => const [TrackedAssetLoading(), TrackedAssetLoaded(_asset)],
  );

  blocTest<TrackedAssetCubit, TrackedAssetState>(
    'a 404 is not-found, which retrying cannot fix',
    setUp: () => when(() => getAsset('AST-404')).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'nope', code: '404')),
    ),
    build: build,
    act: (c) => c.load('AST-404'),
    expect: () => const [TrackedAssetLoading(), TrackedAssetNotFound()],
  );

  blocTest<TrackedAssetCubit, TrackedAssetState>(
    'any other failure is a failure, which retrying might fix',
    setUp: () => when(
      () => getAsset('AST-1'),
    ).thenAnswer((_) async => const Left(NetworkFailure(message: 'offline'))),
    build: build,
    act: (c) => c.load('AST-1'),
    expect: () => const [
      TrackedAssetLoading(),
      TrackedAssetFailure(NetworkFailure(message: 'offline')),
    ],
  );

  blocTest<TrackedAssetCubit, TrackedAssetState>(
    'a blank id is not-found without asking the server',
    build: build,
    act: (c) => c.load('   '),
    expect: () => const [TrackedAssetNotFound()],
    verify: (_) => verifyNever(() => getAsset(any())),
  );
}
