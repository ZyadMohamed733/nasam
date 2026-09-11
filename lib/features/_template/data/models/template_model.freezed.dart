// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateModel {

 String get id; String get title;/// The server omits this for records created before descriptions existed.
 String? get description;/// Unassigned units come back with a null driver.
@JsonKey(name: 'driver_name') String? get driverName;/// ISO 8601 string on the wire, a DateTime in the domain.
@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'is_active') bool? get isActive;/// Server bookkeeping the domain has no use for; the mapper drops it.
@JsonKey(name: 'row_version') int? get rowVersion;
/// Create a copy of TemplateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateModelCopyWith<TemplateModel> get copyWith => _$TemplateModelCopyWithImpl<TemplateModel>(this as TemplateModel, _$identity);

  /// Serializes this TemplateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,driverName,createdAt,isActive,rowVersion);

@override
String toString() {
  return 'TemplateModel(id: $id, title: $title, description: $description, driverName: $driverName, createdAt: $createdAt, isActive: $isActive, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class $TemplateModelCopyWith<$Res>  {
  factory $TemplateModelCopyWith(TemplateModel value, $Res Function(TemplateModel) _then) = _$TemplateModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description,@JsonKey(name: 'driver_name') String? driverName,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'row_version') int? rowVersion
});




}
/// @nodoc
class _$TemplateModelCopyWithImpl<$Res>
    implements $TemplateModelCopyWith<$Res> {
  _$TemplateModelCopyWithImpl(this._self, this._then);

  final TemplateModel _self;
  final $Res Function(TemplateModel) _then;

/// Create a copy of TemplateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? driverName = freezed,Object? createdAt = null,Object? isActive = freezed,Object? rowVersion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,rowVersion: freezed == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateModel].
extension TemplateModelPatterns on TemplateModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateModel value)  $default,){
final _that = this;
switch (_that) {
case _TemplateModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateModel value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @JsonKey(name: 'driver_name')  String? driverName, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'row_version')  int? rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.driverName,_that.createdAt,_that.isActive,_that.rowVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @JsonKey(name: 'driver_name')  String? driverName, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'row_version')  int? rowVersion)  $default,) {final _that = this;
switch (_that) {
case _TemplateModel():
return $default(_that.id,_that.title,_that.description,_that.driverName,_that.createdAt,_that.isActive,_that.rowVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description, @JsonKey(name: 'driver_name')  String? driverName, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'row_version')  int? rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _TemplateModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.driverName,_that.createdAt,_that.isActive,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateModel implements TemplateModel {
  const _TemplateModel({required this.id, required this.title, this.description, @JsonKey(name: 'driver_name') this.driverName, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'is_active') this.isActive, @JsonKey(name: 'row_version') this.rowVersion});
  factory _TemplateModel.fromJson(Map<String, dynamic> json) => _$TemplateModelFromJson(json);

@override final  String id;
@override final  String title;
/// The server omits this for records created before descriptions existed.
@override final  String? description;
/// Unassigned units come back with a null driver.
@override@JsonKey(name: 'driver_name') final  String? driverName;
/// ISO 8601 string on the wire, a DateTime in the domain.
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'is_active') final  bool? isActive;
/// Server bookkeeping the domain has no use for; the mapper drops it.
@override@JsonKey(name: 'row_version') final  int? rowVersion;

/// Create a copy of TemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateModelCopyWith<_TemplateModel> get copyWith => __$TemplateModelCopyWithImpl<_TemplateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,driverName,createdAt,isActive,rowVersion);

@override
String toString() {
  return 'TemplateModel(id: $id, title: $title, description: $description, driverName: $driverName, createdAt: $createdAt, isActive: $isActive, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$TemplateModelCopyWith<$Res> implements $TemplateModelCopyWith<$Res> {
  factory _$TemplateModelCopyWith(_TemplateModel value, $Res Function(_TemplateModel) _then) = __$TemplateModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description,@JsonKey(name: 'driver_name') String? driverName,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'row_version') int? rowVersion
});




}
/// @nodoc
class __$TemplateModelCopyWithImpl<$Res>
    implements _$TemplateModelCopyWith<$Res> {
  __$TemplateModelCopyWithImpl(this._self, this._then);

  final _TemplateModel _self;
  final $Res Function(_TemplateModel) _then;

/// Create a copy of TemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? driverName = freezed,Object? createdAt = null,Object? isActive = freezed,Object? rowVersion = freezed,}) {
  return _then(_TemplateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,rowVersion: freezed == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
