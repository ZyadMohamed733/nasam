import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/data/models/template_model.dart';
import 'package:nasam/features/_template/data/repositories/template_repository_impl.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';

import '../../../../helpers/mock_helper.dart';

void main() {
  late TemplateRepositoryImpl repository;
  late MockTemplateRemoteDataSource remoteDataSource;
  late MockTemplateLocalDataSource localDataSource;

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

  setUpAll(() {
    registerFallbackValue(templateModel);
  });

  setUp(() {
    remoteDataSource = MockTemplateRemoteDataSource();
    localDataSource = MockTemplateLocalDataSource();
    repository = TemplateRepositoryImpl(remoteDataSource, localDataSource);
  });

  group('getTemplate', () {
    test('returns entity when remote fetch succeeds', () async {
      when(
        () => remoteDataSource.getTemplate(templateId),
      ).thenAnswer((_) async => templateModel);
      when(
        () => localDataSource.cacheTemplate(templateModel),
      ).thenAnswer((_) async {});

      final result = await repository.getTemplate(templateId);

      expect(result, const Right<Failure, TemplateEntity>(templateEntity));
      verify(() => remoteDataSource.getTemplate(templateId)).called(1);
      verify(() => localDataSource.cacheTemplate(templateModel)).called(1);
      verifyNever(() => localDataSource.getCachedTemplate(any()));
    });

    test('falls back to cache on NetworkException', () async {
      when(
        () => remoteDataSource.getTemplate(templateId),
      ).thenThrow(const NetworkException(message: 'No internet connection.'));
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenAnswer((_) async => templateModel);

      final result = await repository.getTemplate(templateId);

      expect(result, const Right<Failure, TemplateEntity>(templateEntity));
      verify(() => localDataSource.getCachedTemplate(templateId)).called(1);
    });

    test('falls back to cache on TimeoutException', () async {
      when(
        () => remoteDataSource.getTemplate(templateId),
      ).thenThrow(const TimeoutException(message: 'Request timed out.'));
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenAnswer((_) async => templateModel);

      final result = await repository.getTemplate(templateId);

      expect(result, const Right<Failure, TemplateEntity>(templateEntity));
    });

    test('returns NetworkFailure when offline and cache is empty', () async {
      when(
        () => remoteDataSource.getTemplate(templateId),
      ).thenThrow(const NetworkException(message: 'No internet connection.'));
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenAnswer((_) async => null);

      final result = await repository.getTemplate(templateId);

      expect(
        result,
        const Left<Failure, TemplateEntity>(
          NetworkFailure(message: 'No internet connection.'),
        ),
      );
    });

    test('surfaces the request error when the cache itself throws', () async {
      when(
        () => remoteDataSource.getTemplate(templateId),
      ).thenThrow(const NetworkException(message: 'No internet connection.'));
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenThrow(const CacheException(message: 'Corrupt cache entry.'));

      final result = await repository.getTemplate(templateId);

      expect(
        result,
        const Left<Failure, TemplateEntity>(
          NetworkFailure(message: 'No internet connection.'),
        ),
      );
    });

    // The bug this contract exists to prevent: a 401 served from cache looks
    // to the caller exactly like a healthy session.
    test('does NOT serve cache on AuthException', () async {
      when(() => remoteDataSource.getTemplate(templateId)).thenThrow(
        const AuthException(message: 'Session expired.', code: '401'),
      );
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenAnswer((_) async => templateModel);

      final result = await repository.getTemplate(templateId);

      expect(
        result,
        const Left<Failure, TemplateEntity>(
          AuthFailure(message: 'Session expired.', code: '401'),
        ),
      );
      verifyNever(() => localDataSource.getCachedTemplate(any()));
    });

    test('does NOT serve cache on PermissionException', () async {
      when(() => remoteDataSource.getTemplate(templateId)).thenThrow(
        const PermissionException(message: 'Forbidden.', code: '403'),
      );
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenAnswer((_) async => templateModel);

      final result = await repository.getTemplate(templateId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => localDataSource.getCachedTemplate(any()));
    });

    test('preserves fieldErrors through to ValidationFailure', () async {
      when(() => remoteDataSource.getTemplate(templateId)).thenThrow(
        const ValidationException(
          message: 'Validation failed.',
          fieldErrors: {
            'plate_number': ['Plate number is already registered.'],
          },
          code: '422',
        ),
      );
      when(
        () => localDataSource.getCachedTemplate(templateId),
      ).thenAnswer((_) async => templateModel);

      final result = await repository.getTemplate(templateId);

      final failure = result.fold((l) => l, (_) => null);
      expect(failure, isA<ValidationFailure>());
      expect(
        (failure! as ValidationFailure).fieldErrors,
        {
          'plate_number': ['Plate number is already registered.'],
        },
      );
      verifyNever(() => localDataSource.getCachedTemplate(any()));
    });
  });
}
