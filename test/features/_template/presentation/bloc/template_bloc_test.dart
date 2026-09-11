import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';
import 'package:nasam/features/_template/domain/usecases/get_template_usecase.dart';
import 'package:nasam/features/_template/presentation/bloc/template_bloc.dart';
import 'package:nasam/features/_template/presentation/bloc/template_event.dart';
import 'package:nasam/features/_template/presentation/bloc/template_state.dart';

class _MockGetTemplateUseCase extends Mock implements GetTemplateUseCase {}

void main() {
  late TemplateBloc bloc;
  late _MockGetTemplateUseCase getTemplateUseCase;

  const templateId = 'template-1';
  const templateEntity = TemplateEntity(
    id: templateId,
    title: 'Fleet Unit',
    description: 'Tracked vehicle',
  );

  setUp(() {
    getTemplateUseCase = _MockGetTemplateUseCase();
    bloc = TemplateBloc(getTemplateUseCase);
  });

  tearDown(() => bloc.close());

  test('initial state is TemplateInitial', () {
    expect(bloc.state, const TemplateState.initial());
  });

  blocTest<TemplateBloc, TemplateState>(
    'emits [loading, success] when load succeeds',
    build: () {
      when(
        () => getTemplateUseCase(templateId),
      ).thenAnswer((_) async => const Right(templateEntity));
      return bloc;
    },
    act: (bloc) => bloc.add(const TemplateEvent.load(templateId)),
    expect: () => [
      const TemplateState.loading(),
      const TemplateState.success(templateEntity),
    ],
    verify: (_) {
      verify(() => getTemplateUseCase(templateId)).called(1);
    },
  );

  blocTest<TemplateBloc, TemplateState>(
    'emits [loading, failure] when load fails',
    build: () {
      const failure = NetworkFailure(message: 'No connection');
      when(
        () => getTemplateUseCase(templateId),
      ).thenAnswer((_) async => const Left(failure));
      return bloc;
    },
    act: (bloc) => bloc.add(const TemplateEvent.load(templateId)),
    expect: () => [
      const TemplateState.loading(),
      const TemplateState.failure(NetworkFailure(message: 'No connection')),
    ],
    verify: (_) {
      verify(() => getTemplateUseCase(templateId)).called(1);
    },
  );
}
