import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_model.freezed.dart';
part 'template_model.g.dart';

@freezed
abstract class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String title,
    required String description,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}
