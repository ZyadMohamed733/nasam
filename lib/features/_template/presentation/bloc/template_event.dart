import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_event.freezed.dart';

@freezed
abstract class TemplateEvent with _$TemplateEvent {
  const factory TemplateEvent.load(String id) = LoadTemplate;
}
