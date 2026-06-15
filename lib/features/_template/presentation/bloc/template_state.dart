import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/template_entity.dart';

part 'template_state.freezed.dart';

@freezed
abstract class TemplateState with _$TemplateState {
  const factory TemplateState.initial() = TemplateInitial;
  const factory TemplateState.loading() = TemplateLoading;
  const factory TemplateState.success(TemplateEntity entity) = TemplateSuccess;
  const factory TemplateState.failure(Failure failure) = TemplateFailure;
}
