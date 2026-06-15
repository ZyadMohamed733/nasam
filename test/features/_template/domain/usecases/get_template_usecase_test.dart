import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';
import 'package:nasam/features/_template/domain/repositories/template_repository.dart';
import 'package:nasam/features/_template/domain/usecases/get_template_usecase.dart';

class _MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  late GetTemplateUseCase useCase;
  late _MockTemplateRepository repository;

  const templateId = 'template-1';
  const templateEntity = TemplateEntity(
    id: templateId,
    title: 'Fleet Unit',
    description: 'Tracked vehicle',
  );

  setUp(() {
    repository = _MockTemplateRepository();
    useCase = GetTemplateUseCase(repository);
  });

  test('returns entity when repository succeeds', () async {
    when(() => repository.getTemplate(templateId))
        .thenAnswer((_) async => const Right(templateEntity));

    final result = await useCase(templateId);

    expect(result, const Right(templateEntity));
    verify(() => repository.getTemplate(templateId)).called(1);
  });

  test('returns failure when repository fails', () async {
    const failure = NetworkFailure(message: 'No connection');
    when(() => repository.getTemplate(templateId))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(templateId);

    expect(result, const Left(failure));
    verify(() => repository.getTemplate(templateId)).called(1);
  });
}
