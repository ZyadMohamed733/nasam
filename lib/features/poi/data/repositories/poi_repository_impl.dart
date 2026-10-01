import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/poi_draft.dart';
import '../../domain/entities/poi_limits.dart';
import '../../domain/entities/point_of_interest.dart';
import '../../domain/repositories/poi_repository.dart';
import '../datasources/poi_datasource.dart';
import '../mappers/poi_mapper.dart';
import '../models/poi_model.dart';

@LazySingleton(as: PoiRepository)
class PoiRepositoryImpl implements PoiRepository {
  PoiRepositoryImpl(this._source);
  final PoiDataSource _source;
  final _changes = StreamController<void>.broadcast();
  @override
  Stream<void> get changes => _changes.stream;
  @override
  @disposeMethod
  Future<void> dispose() => _changes.close();
  @override
  Future<Either<Failure, List<PointOfInterest>>> getPoints() async {
    try {
      final models = await _source.getPoints();
      if (models.map((m) => m.id).toSet().length != models.length) {
        throw const FormatException('Duplicate POI IDs');
      }
      return Right(List.unmodifiable(models.map(PoiMapper.point)));
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e, stack) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: stack));
    }
  }

  int _sequence = 0;
  String _newId() =>
      'poi-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
  PoiModel _model(PoiDraft d, String id) => PoiModel(
    id: id,
    name: d.name.trim(),
    latitude: d.latitude,
    longitude: d.longitude,
    icon: d.icon.name,
    notes: d.notes.trim(),
  );
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e, stack) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, PointOfInterest>> getPoint(String id) =>
      _guard(() async {
        for (final model in await _source.getPoints()) {
          if (model.id == id) return PoiMapper.point(model);
        }
        throw ServerException(message: 'POI not found', code: '404');
      });
  @override
  Future<Either<Failure, PointOfInterest>> save(PoiDraft draft, {String? id}) {
    if (!draft.isValid) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid POI fields')),
      );
    }
    return _guard(() async {
      final point = PoiMapper.point(
        await _source.save(_model(draft, id ?? _newId()), create: id == null),
      );
      _changes.add(null);
      return point;
    });
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) => _guard(() async {
    await _source.delete(id);
    _changes.add(null);
    return unit;
  });
  @override
  Future<Either<Failure, int>> importPoints(List<PoiDraft> drafts) {
    if (drafts.length > PoiLimits.maxRecords || drafts.any((d) => !d.isValid)) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid POI import')),
      );
    }
    return _guard(() async {
      final count = await _source.importPoints(
        drafts.map((d) => _model(d, _newId())).toList(),
      );
      if (count > 0) _changes.add(null);
      return count;
    });
  }
}
