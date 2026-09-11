import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';
import 'package:nasam/features/_template/domain/usecases/get_template_usecase.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_helper.dart';

void main() {
  late GetTemplateUseCase useCase;
  late MockTemplateRepository repository;

  const templateId = Fixtures.templateId;
  final templateEntity = Fixtures.templateEntity;

  setUp(() {
    repository = MockTemplateRepository();
    useCase = GetTemplateUseCase(repository);
  });

  test('returns entity when repository succeeds', () async {
    when(
      () => repository.getTemplate(templateId),
    ).thenAnswer((_) async => Right<Failure, TemplateEntity>(templateEntity));

    final result = await useCase(templateId);

    expect(result, Right<Failure, TemplateEntity>(templateEntity));
    verify(() => repository.getTemplate(templateId)).called(1);
  });

  test('returns failure when repository fails', () async {
    const failure = NetworkFailure(message: 'No connection');
    when(
      () => repository.getTemplate(templateId),
    ).thenAnswer((_) async => const Left<Failure, TemplateEntity>(failure));

    final result = await useCase(templateId);

    expect(result, const Left<Failure, TemplateEntity>(failure));
    verify(() => repository.getTemplate(templateId)).called(1);
  });
}
