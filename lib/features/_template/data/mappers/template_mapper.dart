import '../../domain/entities/template_entity.dart';
import '../models/template_model.dart';

class TemplateMapper {
  static TemplateEntity toEntity(TemplateModel model) {
    return TemplateEntity(
      id: model.id,
      title: model.title,
      description: model.description,
    );
  }

  static TemplateModel fromEntity(TemplateEntity entity) {
    return TemplateModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
    );
  }
}
