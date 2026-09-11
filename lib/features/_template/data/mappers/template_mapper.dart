import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/template_entity.dart';
import '../models/template_model.dart';

/// Where the wire shape becomes the domain shape.
///
/// This is the layer engineers delete when the model and entity are identical,
/// so the reference slice has to show what it is for: nullable server fields
/// get defaults, an ISO string becomes a [DateTime], and fields the domain does
/// not care about are dropped here rather than travelling through the app.
class TemplateMapper {
  static const String _unassignedDriver = 'Unassigned';

  static TemplateEntity toEntity(TemplateModel model) {
    final createdAt = DateTime.tryParse(model.createdAt);
    if (createdAt == null) {
      // A date the domain cannot represent is a server contract violation, not
      // something to paper over with DateTime.now().
      throw ServerException(
        message: 'Unparseable created_at: "${model.createdAt}"',
      );
    }

    return TemplateEntity(
      id: model.id,
      title: model.title,
      description: model.description ?? '',
      driverName: model.driverName ?? _unassignedDriver,
      createdAt: createdAt.toUtc(),
      isActive: model.isActive ?? false,
      // model.rowVersion is deliberately not mapped.
    );
  }

  static TemplateModel fromEntity(TemplateEntity entity) {
    return TemplateModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      driverName: entity.driverName == _unassignedDriver
          ? null
          : entity.driverName,
      createdAt: entity.createdAt.toUtc().toIso8601String(),
      isActive: entity.isActive,
    );
  }
}
