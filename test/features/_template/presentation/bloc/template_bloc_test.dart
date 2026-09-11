import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/presentation/bloc/template_bloc.dart';
import 'package:nasam/features/_template/presentation/bloc/template_event.dart';
import 'package:nasam/features/_template/presentation/bloc/template_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_helper.dart';

void main() {
  late TemplateBloc bloc;
  late MockGetTemplateUseCase getTemplateUseCase;

  const templateId = Fixtures.templateId;
  final templateEntity = Fixtures.templateEntity;

  setUp(() {
    getTemplateUseCase = MockGetTemplateUseCase();
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
      ).thenAnswer((_) async => Right(templateEntity));
      return bloc;
    },
    act: (bloc) => bloc.add(const TemplateEvent.load(templateId)),
    expect: () => [
      const TemplateState.loading(),
      TemplateState.success(templateEntity),
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
