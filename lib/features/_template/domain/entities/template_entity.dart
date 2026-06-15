import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_entity.freezed.dart';

@freezed
abstract class TemplateEntity with _$TemplateEntity {
  const factory TemplateEntity({
    required String id,
    required String title,
    required String description,
  }) = _TemplateEntity;
}
