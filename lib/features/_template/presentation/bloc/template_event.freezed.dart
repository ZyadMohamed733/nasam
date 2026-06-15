// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateEvent {

 String get id;
/// Create a copy of TemplateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateEventCopyWith<TemplateEvent> get copyWith => _$TemplateEventCopyWithImpl<TemplateEvent>(this as TemplateEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateEvent&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'TemplateEvent(id: $id)';
}


}

/// @nodoc
abstract mixin class $TemplateEventCopyWith<$Res>  {
  factory $TemplateEventCopyWith(TemplateEvent value, $Res Function(TemplateEvent) _then) = _$TemplateEventCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$TemplateEventCopyWithImpl<$Res>
    implements $TemplateEventCopyWith<$Res> {
  _$TemplateEventCopyWithImpl(this._self, this._then);

  final TemplateEvent _self;
  final $Res Function(TemplateEvent) _then;

/// Create a copy of TemplateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateEvent].
extension TemplateEventPatterns on TemplateEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadTemplate value)?  load,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadTemplate() when load != null:
return load(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadTemplate value)  load,}){
final _that = this;
switch (_that) {
case LoadTemplate():
return load(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadTemplate value)?  load,}){
final _that = this;
switch (_that) {
case LoadTemplate() when load != null:
return load(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id)?  load,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadTemplate() when load != null:
return load(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id)  load,}) {final _that = this;
switch (_that) {
case LoadTemplate():
return load(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id)?  load,}) {final _that = this;
switch (_that) {
case LoadTemplate() when load != null:
return load(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class LoadTemplate implements TemplateEvent {
  const LoadTemplate(this.id);
  

@override final  String id;

/// Create a copy of TemplateEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadTemplateCopyWith<LoadTemplate> get copyWith => _$LoadTemplateCopyWithImpl<LoadTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadTemplate&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'TemplateEvent.load(id: $id)';
}


}

/// @nodoc
abstract mixin class $LoadTemplateCopyWith<$Res> implements $TemplateEventCopyWith<$Res> {
  factory $LoadTemplateCopyWith(LoadTemplate value, $Res Function(LoadTemplate) _then) = _$LoadTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class _$LoadTemplateCopyWithImpl<$Res>
    implements $LoadTemplateCopyWith<$Res> {
  _$LoadTemplateCopyWithImpl(this._self, this._then);

  final LoadTemplate _self;
  final $Res Function(LoadTemplate) _then;

/// Create a copy of TemplateEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(LoadTemplate(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
