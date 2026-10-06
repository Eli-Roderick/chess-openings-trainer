// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'records.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepertoireRecord {

 String get id; String get name;/// `w` or `b`.
 String get color; String get pgn; String get pgnHash; int get createdAt; int get updatedAt; String get updatedBy; String? get description; bool get deleted;
/// Create a copy of RepertoireRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepertoireRecordCopyWith<RepertoireRecord> get copyWith => _$RepertoireRecordCopyWithImpl<RepertoireRecord>(this as RepertoireRecord, _$identity);

  /// Serializes this RepertoireRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RepertoireRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepertoireRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.pgn, _this.pgn) || other.pgn == _this.pgn)&&(identical(other.pgnHash, _this.pgnHash) || other.pgnHash == _this.pgnHash)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.updatedBy, _this.updatedBy) || other.updatedBy == _this.updatedBy)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RepertoireRecord;
  return Object.hash(runtimeType,_this.id,_this.name,_this.color,_this.pgn,_this.pgnHash,_this.createdAt,_this.updatedAt,_this.updatedBy,_this.description,_this.deleted);
}

@override
String toString() {
  final _this = this as RepertoireRecord;
  return 'RepertoireRecord(id: ${_this.id}, name: ${_this.name}, color: ${_this.color}, pgn: ${_this.pgn}, pgnHash: ${_this.pgnHash}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, updatedBy: ${_this.updatedBy}, description: ${_this.description}, deleted: ${_this.deleted})';
}


}

/// @nodoc
abstract mixin class $RepertoireRecordCopyWith<$Res>  {
  factory $RepertoireRecordCopyWith(RepertoireRecord value, $Res Function(RepertoireRecord) _then) = _$RepertoireRecordCopyWithImpl;
@useResult
$Res call({
 String id, String name, String color, String pgn, String pgnHash, int createdAt, int updatedAt, String updatedBy, String? description, bool deleted
});




}
/// @nodoc
class _$RepertoireRecordCopyWithImpl<$Res>
    implements $RepertoireRecordCopyWith<$Res> {
  _$RepertoireRecordCopyWithImpl(this._self, this._then);

  final RepertoireRecord _self;
  final $Res Function(RepertoireRecord) _then;

/// Create a copy of RepertoireRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? pgn = null,Object? pgnHash = null,Object? createdAt = null,Object? updatedAt = null,Object? updatedBy = null,Object? description = freezed,Object? deleted = null,}) {
  return _then(RepertoireRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,pgn: null == pgn ? _self.pgn : pgn // ignore: cast_nullable_to_non_nullable
as String,pgnHash: null == pgnHash ? _self.pgnHash : pgnHash // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,updatedBy: null == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RepertoireRecord].
extension RepertoireRecordPatterns on RepertoireRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepertoireRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepertoireRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepertoireRecord value)  $default,){
final _that = this;
switch (_that) {
case _RepertoireRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepertoireRecord value)?  $default,){
final _that = this;
switch (_that) {
case _RepertoireRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String color,  String pgn,  String pgnHash,  int createdAt,  int updatedAt,  String updatedBy,  String? description,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepertoireRecord() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.pgn,_that.pgnHash,_that.createdAt,_that.updatedAt,_that.updatedBy,_that.description,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String color,  String pgn,  String pgnHash,  int createdAt,  int updatedAt,  String updatedBy,  String? description,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _RepertoireRecord():
return $default(_that.id,_that.name,_that.color,_that.pgn,_that.pgnHash,_that.createdAt,_that.updatedAt,_that.updatedBy,_that.description,_that.deleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String color,  String pgn,  String pgnHash,  int createdAt,  int updatedAt,  String updatedBy,  String? description,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _RepertoireRecord() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.pgn,_that.pgnHash,_that.createdAt,_that.updatedAt,_that.updatedBy,_that.description,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepertoireRecord implements RepertoireRecord {
  const _RepertoireRecord({required this.id, required this.name, required this.color, required this.pgn, required this.pgnHash, required this.createdAt, required this.updatedAt, required this.updatedBy, this.description, this.deleted = false});
  factory _RepertoireRecord.fromJson(Map<String, dynamic> json) => _$RepertoireRecordFromJson(json);

@override final  String id;
@override final  String name;
/// `w` or `b`.
@override final  String color;
@override final  String pgn;
@override final  String pgnHash;
@override final  int createdAt;
@override final  int updatedAt;
@override final  String updatedBy;
@override final  String? description;
@override@JsonKey() final  bool deleted;

/// Create a copy of RepertoireRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepertoireRecordCopyWith<_RepertoireRecord> get copyWith => __$RepertoireRecordCopyWithImpl<_RepertoireRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepertoireRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepertoireRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.pgn, pgn) || other.pgn == pgn)&&(identical(other.pgnHash, pgnHash) || other.pgnHash == pgnHash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.description, description) || other.description == description)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,color,pgn,pgnHash,createdAt,updatedAt,updatedBy,description,deleted);
}

@override
String toString() {
    return 'RepertoireRecord(id: $id, name: $name, color: $color, pgn: $pgn, pgnHash: $pgnHash, createdAt: $createdAt, updatedAt: $updatedAt, updatedBy: $updatedBy, description: $description, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$RepertoireRecordCopyWith<$Res> implements $RepertoireRecordCopyWith<$Res> {
  factory _$RepertoireRecordCopyWith(_RepertoireRecord value, $Res Function(_RepertoireRecord) _then) = __$RepertoireRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String color, String pgn, String pgnHash, int createdAt, int updatedAt, String updatedBy, String? description, bool deleted
});




}
/// @nodoc
class __$RepertoireRecordCopyWithImpl<$Res>
    implements _$RepertoireRecordCopyWith<$Res> {
  __$RepertoireRecordCopyWithImpl(this._self, this._then);

  final _RepertoireRecord _self;
  final $Res Function(_RepertoireRecord) _then;

/// Create a copy of RepertoireRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? pgn = null,Object? pgnHash = null,Object? createdAt = null,Object? updatedAt = null,Object? updatedBy = null,Object? description = freezed,Object? deleted = null,}) {
  return _then(_RepertoireRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,pgn: null == pgn ? _self.pgn : pgn // ignore: cast_nullable_to_non_nullable
as String,pgnHash: null == pgnHash ? _self.pgnHash : pgnHash // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,updatedBy: null == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
