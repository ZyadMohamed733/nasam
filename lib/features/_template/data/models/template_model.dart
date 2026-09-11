import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_model.freezed.dart';
part 'template_model.g.dart';

/// The wire shape, deliberately as messy as a real API response: snake_case
/// keys, a nullable field, a date as an ISO string, and a field the domain does
/// not care about. Copy this slice and the mapper has visible work to do.
@freezed
abstract class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String title,

    /// The server omits this for records created before descriptions existed.
    String? description,

    /// Unassigned units come back with a null driver.
    @JsonKey(name: 'driver_name') String? driverName,

    /// ISO 8601 string on the wire, a DateTime in the domain.
    @JsonKey(name: 'created_at') required String createdAt,

    @JsonKey(name: 'is_active') bool? isActive,

    /// Server bookkeeping the domain has no use for; the mapper drops it.
    @JsonKey(name: 'row_version') int? rowVersion,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}
