// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TemplateState()';
}


}

/// @nodoc
class $TemplateStateCopyWith<$Res>  {
$TemplateStateCopyWith(TemplateState _, $Res Function(TemplateState) __);
}


/// Adds pattern-matching-related methods to [TemplateState].
extension TemplateStatePatterns on TemplateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TemplateInitial value)?  initial,TResult Function( TemplateLoading value)?  loading,TResult Function( TemplateSuccess value)?  success,TResult Function( TemplateFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TemplateInitial() when initial != null:
return initial(_that);case TemplateLoading() when loading != null:
return loading(_that);case TemplateSuccess() when success != null:
return success(_that);case TemplateFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TemplateInitial value)  initial,required TResult Function( TemplateLoading value)  loading,required TResult Function( TemplateSuccess value)  success,required TResult Function( TemplateFailure value)  failure,}){
final _that = this;
switch (_that) {
case TemplateInitial():
return initial(_that);case TemplateLoading():
return loading(_that);case TemplateSuccess():
return success(_that);case TemplateFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TemplateInitial value)?  initial,TResult? Function( TemplateLoading value)?  loading,TResult? Function( TemplateSuccess value)?  success,TResult? Function( TemplateFailure value)?  failure,}){
final _that = this;
switch (_that) {
case TemplateInitial() when initial != null:
return initial(_that);case TemplateLoading() when loading != null:
return loading(_that);case TemplateSuccess() when success != null:
return success(_that);case TemplateFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( TemplateEntity entity)?  success,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TemplateInitial() when initial != null:
return initial();case TemplateLoading() when loading != null:
return loading();case TemplateSuccess() when success != null:
return success(_that.entity);case TemplateFailure() when failure != null:
return failure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( TemplateEntity entity)  success,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case TemplateInitial():
return initial();case TemplateLoading():
return loading();case TemplateSuccess():
return success(_that.entity);case TemplateFailure():
return failure(_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( TemplateEntity entity)?  success,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case TemplateInitial() when initial != null:
return initial();case TemplateLoading() when loading != null:
return loading();case TemplateSuccess() when success != null:
return success(_that.entity);case TemplateFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class TemplateInitial implements TemplateState {
  const TemplateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TemplateState.initial()';
}


}




/// @nodoc


class TemplateLoading implements TemplateState {
  const TemplateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TemplateState.loading()';
}


}




/// @nodoc


class TemplateSuccess implements TemplateState {
  const TemplateSuccess(this.entity);
  

 final  TemplateEntity entity;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSuccessCopyWith<TemplateSuccess> get copyWith => _$TemplateSuccessCopyWithImpl<TemplateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSuccess&&(identical(other.entity, entity) || other.entity == entity));
}


@override
int get hashCode => Object.hash(runtimeType,entity);

@override
String toString() {
  return 'TemplateState.success(entity: $entity)';
}


}

/// @nodoc
abstract mixin class $TemplateSuccessCopyWith<$Res> implements $TemplateStateCopyWith<$Res> {
  factory $TemplateSuccessCopyWith(TemplateSuccess value, $Res Function(TemplateSuccess) _then) = _$TemplateSuccessCopyWithImpl;
@useResult
$Res call({
 TemplateEntity entity
});


$TemplateEntityCopyWith<$Res> get entity;

}
/// @nodoc
class _$TemplateSuccessCopyWithImpl<$Res>
    implements $TemplateSuccessCopyWith<$Res> {
  _$TemplateSuccessCopyWithImpl(this._self, this._then);

  final TemplateSuccess _self;
  final $Res Function(TemplateSuccess) _then;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entity = null,}) {
  return _then(TemplateSuccess(
null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as TemplateEntity,
  ));
}

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TemplateEntityCopyWith<$Res> get entity {
  
  return $TemplateEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}
}

/// @nodoc


class TemplateFailure implements TemplateState {
  const TemplateFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateFailureCopyWith<TemplateFailure> get copyWith => _$TemplateFailureCopyWithImpl<TemplateFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'TemplateState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $TemplateFailureCopyWith<$Res> implements $TemplateStateCopyWith<$Res> {
  factory $TemplateFailureCopyWith(TemplateFailure value, $Res Function(TemplateFailure) _then) = _$TemplateFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$TemplateFailureCopyWithImpl<$Res>
    implements $TemplateFailureCopyWith<$Res> {
  _$TemplateFailureCopyWithImpl(this._self, this._then);

  final TemplateFailure _self;
  final $Res Function(TemplateFailure) _then;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(TemplateFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
