import 'package:nasam/features/_template/data/models/template_model.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';

/// Shared fixtures so a change to the template shape lands in one place rather
/// than in every test that happens to build one.
abstract final class Fixtures {
  static const templateId = 'template-1';

  /// A fully populated server response.
  static const templateModel = TemplateModel(
    id: templateId,
    title: 'Fleet Unit',
    description: 'Tracked vehicle',
    driverName: 'Yousef',
    createdAt: '2026-03-05T09:30:00Z',
    isActive: true,
    rowVersion: 7,
  );

  /// What [templateModel] maps to: row_version dropped, date parsed.
  static final templateEntity = TemplateEntity(
    id: templateId,
    title: 'Fleet Unit',
    description: 'Tracked vehicle',
    driverName: 'Yousef',
    createdAt: DateTime.utc(2026, 3, 5, 9, 30),
    isActive: true,
  );

  /// The sparse response a real API returns for an older or unassigned record.
  static const sparseTemplateModel = TemplateModel(
    id: templateId,
    title: 'Fleet Unit',
    createdAt: '2026-03-05T09:30:00Z',
  );
}
