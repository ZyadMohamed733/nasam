import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/data/datasources/local/template_local_datasource.dart';
import 'package:nasam/features/_template/data/datasources/remote/template_remote_datasource.dart';
import 'package:nasam/features/_template/data/models/template_model.dart';
import 'package:nasam/features/_template/data/repositories/template_repository_impl.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';

class _MockRemoteDataSource extends Mock implements TemplateRemoteDataSource {}

class _MockLocalDataSource extends Mock implements TemplateLocalDataSource {}

void main() {
  late TemplateRepositoryImpl repository;
  late _MockRemoteDataSource remoteDataSource;
  late _MockLocalDataSource localDataSource;

  const templateId = 'template-1';
  const templateModel = TemplateModel(
    id: templateId,
    title: 'Fleet Unit',
    description: 'Tracked vehicle',
  );
  const templateEntity = TemplateEntity(
    id: templateId,
    title: 'Fleet Unit',
    description: 'Tracked vehicle',
  );

  setUp(() {
    remoteDataSource = _MockRemoteDataSource();
    localDataSource = _MockLocalDataSource();
    repository = TemplateRepositoryImpl(remoteDataSource, localDataSource);
  });

  group('getTemplate', () {
    test('returns entity when remote fetch succeeds', () async {
      when(() => remoteDataSource.getTemplate(templateId))
          .thenAnswer((_) async => templateModel);
      when(() => localDataSource.cacheTemplate(templateModel))
          .thenAnswer((_) async {});

      final result = await repository.getTemplate(templateId);

      expect(result, const Right(templateEntity));
      verify(() => remoteDataSource.getTemplate(templateId)).called(1);
      verify(() => localDataSource.cacheTemplate(templateModel)).called(1);
      verifyNever(() => localDataSource.getCachedTemplate(any()));
    });

    test('returns cached entity when remote fails and cache exists', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/templates/$templateId'),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => remoteDataSource.getTemplate(templateId))
          .thenThrow(dioException);
      when(() => localDataSource.getCachedTemplate(templateId))
          .thenAnswer((_) async => templateModel);

      final result = await repository.getTemplate(templateId);

      expect(result, const Right(templateEntity));
      verify(() => localDataSource.getCachedTemplate(templateId)).called(1);
    });

    test('returns Failure when remote fails and cache is empty', () async {
      const failure = NetworkFailure(message: 'No connection');
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/templates/$templateId'),
        type: DioExceptionType.connectionTimeout,
        error: failure,
      );

      when(() => remoteDataSource.getTemplate(templateId))
          .thenThrow(dioException);
      when(() => localDataSource.getCachedTemplate(templateId))
          .thenAnswer((_) async => null);

      final result = await repository.getTemplate(templateId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (left) => expect(left, failure),
        (_) => fail('Expected Left'),
      );
    });
  });
}
