// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateModel _$TemplateModelFromJson(Map<String, dynamic> json) =>
    _TemplateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      driverName: json['driver_name'] as String?,
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool?,
      rowVersion: (json['row_version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TemplateModelToJson(_TemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'driver_name': instance.driverName,
      'created_at': instance.createdAt,
      'is_active': instance.isActive,
      'row_version': instance.rowVersion,
    };
