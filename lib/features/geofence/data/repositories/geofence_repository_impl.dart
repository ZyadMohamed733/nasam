import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/geofence.dart';
import '../../domain/entities/geofence_draft.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../datasources/geofence_datasource.dart';
import '../mappers/geofence_mapper.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  GeofenceRepositoryImpl(this._source);
  final GeofenceDataSource _source;
  final _changes = StreamController<void>.broadcast();
  @override Stream<void> get changes => _changes.stream;
  @override Future<void> dispose() => _changes.close();
  Future<Either<Failure,T>> _guard<T>(Future<T> Function() run) async {
    try { return Right(await run()); }
    on AppException catch (e) { return Left(FailureMapper.fromException(e)); }
    catch (e, st) { return Left(UnknownFailure(message:e.toString(),stackTrace:st)); }
  }
  int _sequence=0;
  String _id()=> 'geofence-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
  @override Future<Either<Failure,List<Geofence>>> getGeofences()=>_guard(() async { final models=await _source.getGeofences(); if(models.map((e)=>e.id).toSet().length!=models.length) throw const FormatException('Duplicate geofence ids'); return List.unmodifiable(models.map(GeofenceMapper.fromModel)); });
  @override Future<Either<Failure,Geofence>> getGeofence(String id)=>_guard(() async=>GeofenceMapper.fromModel(await _source.getGeofence(id)));
  @override Future<Either<Failure,Geofence>> save(GeofenceDraft draft,{String? id}) {
    if(!draft.isValid) return Future.value(const Left(ValidationFailure(message:'Invalid geofence fields')));
    return _guard(() async { final saved=GeofenceMapper.fromModel(await _source.save(GeofenceMapper.toModel(draft,id??_id()),create:id==null)); _changes.add(null); return saved; });
  }
  @override Future<Either<Failure,Unit>> delete(String id)=>_guard(() async { await _source.delete(id); _changes.add(null); return unit; });
  @override Future<Either<Failure,List<GeofenceAssetOption>>> getAssetOptions()=>_guard(() async=>(await _source.getAssetOptions()).map(GeofenceMapper.asset).toList());
}
