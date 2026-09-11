import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_entity.freezed.dart';

/// The domain shape: fully typed and non-null, with no knowledge of what the
/// JSON looks like. Defaults for absent server fields are applied by the
/// mapper, not carried through the app as nulls.
@freezed
abstract class TemplateEntity with _$TemplateEntity {
  const factory TemplateEntity({
    required String id,
    required String title,
    required String description,
    required String driverName,
    required DateTime createdAt,
    required bool isActive,
  }) = _TemplateEntity;
}
