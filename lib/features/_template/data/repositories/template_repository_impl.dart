import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
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
    } on AppException catch (e) {
      // Only a genuinely unreachable server justifies serving stale data. A
      // 401/403/422 must surface, or an error quietly looks like success.
      if (e is NetworkException || e is TimeoutException) {
        final cached = await _cachedEntity(id);
        if (cached != null) return Right(cached);
      }
      return Left(FailureMapper.fromException(e));
    } catch (e, stack) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: stack));
    }
  }

  Future<TemplateEntity?> _cachedEntity(String id) async {
    try {
      final cachedModel = await _localDataSource.getCachedTemplate(id);
      return cachedModel == null ? null : TemplateMapper.toEntity(cachedModel);
    } on Object {
      // A broken cache must not replace the request error the caller needs.
      return null;
    }
  }
}
