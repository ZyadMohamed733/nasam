import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/models/poi_model.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/entities/point_of_interest.dart';
import 'package:nasam/features/poi/domain/repositories/poi_repository.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_cubit.dart';

import '../../helpers/fixture_bundle.dart';
import '../../helpers/poi_files.dart';

const points = [
  PointOfInterest(
    id: '1',
    name: 'إشارة المرور',
    latitude: 21.4,
    longitude: 39.1,
  ),
  PointOfInterest(id: '2', name: 'Warehouse', latitude: 21.5, longitude: 39.2),
];

class _Repository implements PoiRepository {
  @override
  Stream<void> get changes => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  final requests = <Completer<Either<Failure, List<PointOfInterest>>>>[];
  @override
  Future<Either<Failure, List<PointOfInterest>>> getPoints() {
    final request = Completer<Either<Failure, List<PointOfInterest>>>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  test(
    'search during load survives, Arabic folding works, selection is validated',
    () async {
      final repository = _Repository();
      final cubit = PoiCubit(
        GetPointsOfInterestUseCase(repository),
        FakePoiFiles(),
        DeletePointOfInterestUseCase(repository),
        WatchPoiChangesUseCase(repository),
      );
      final load = cubit.load();
      cubit.search('اشاره');
      repository.requests.single.complete(const Right(points));
      await load;
      expect(cubit.state.visiblePoints.single.id, '1');
      cubit.select('1');
      cubit.select('missing');
      expect(cubit.state.selectedId, '1');
      cubit.search('ware');
      expect(cubit.state.visiblePoints.single.id, '2');
      cubit.search('missing');
      expect(cubit.state.visiblePoints, isEmpty);
      await cubit.close();
    },
  );
  test(
    'refresh failure preserves points/query, duplicate load is ignored, retry succeeds',
    () async {
      final repository = _Repository();
      final cubit = PoiCubit(
        GetPointsOfInterestUseCase(repository),
        FakePoiFiles(),
        DeletePointOfInterestUseCase(repository),
        WatchPoiChangesUseCase(repository),
      );
      var load = cubit.load();
      await cubit.load();
      expect(repository.requests.length, 1);
      repository.requests.last.complete(const Right(points));
      await load;
      cubit.search('ware');
      cubit.select('2');
      load = cubit.load();
      repository.requests.last.complete(
        const Left(NetworkFailure(message: 'offline')),
      );
      await load;
      expect(cubit.state.status, PoiStatus.failure);
      expect(cubit.state.visiblePoints.single.id, '2');
      load = cubit.load();
      repository.requests.last.complete(const Right([]));
      await load;
      expect(cubit.state.status, PoiStatus.loaded);
      expect(cubit.state.selectedId, isNull);
      await cubit.close();
    },
  );
  test('closing while loading discards response', () async {
    final repository = _Repository();
    final cubit = PoiCubit(
      GetPointsOfInterestUseCase(repository),
      FakePoiFiles(),
      DeletePointOfInterestUseCase(repository),
      WatchPoiChangesUseCase(repository),
    );
    final load = cubit.load();
    await cubit.close();
    repository.requests.single.complete(const Right(points));
    await load;
  });
  test(
    'fixture traverses source/model/mapper/repository and rejects invalid coordinates',
    () async {
      final result = await PoiRepositoryImpl(
        PoiFixtureDataSource(bundle: DiskAssetBundle()),
      ).getPoints();
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).length, 4);
      expect(
        () => PoiModel.fromJson({
          'id': 'x',
          'name': 'x',
          'latitude': 91,
          'longitude': 39,
        }),
        throwsFormatException,
      );
      expect(
        () => PoiModel.fromJson({
          'id': 'x',
          'name': 'x',
          'latitude': 0,
          'longitude': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
}
