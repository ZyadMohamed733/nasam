import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/template_entity.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/local/template_local_datasource.dart';
import '../datasources/remote/template_remote_datasource.dart';
import '../mappers/template_mapper.dart';

@LazySingleton(as: TemplateRepository)
class TemplateRepositoryImpl implements TemplateRepository {
  const TemplateRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final TemplateRemoteDataSource _remoteDataSource;
  final TemplateLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, TemplateEntity>> getTemplate(String id) async {
    try {
      final remoteModel = await _remoteDataSource.getTemplate(id);
      await _localDataSource.cacheTemplate(remoteModel);
      return Right(TemplateMapper.toEntity(remoteModel));
    } on DioException catch (e) {
      // Fallback to local cache on request error
      try {
        final cachedModel = await _localDataSource.getCachedTemplate(id);
        if (cachedModel != null) {
          return Right(TemplateMapper.toEntity(cachedModel));
        }
      } catch (_) {
        // Ignore cache fetch failures, bubble up request error instead
      }

      if (e.error is Failure) {
        return Left(e.error as Failure);
      }
      return Left(UnknownFailure(message: e.message ?? 'A network communication error occurred.', stackTrace: e.stackTrace));
    } catch (e, stack) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: stack));
    }
  }
}
