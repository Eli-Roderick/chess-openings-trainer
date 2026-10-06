// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunRecord {

 String get id; String get repertoireId; String get lineKey; String get ucis; RunMode get mode; int get startPly; WrongMoveMode get wrongMoveMode; int get startedAt; int get finishedAt; String get localDay; bool get completed; bool get deviated; int get gradedCount; double get creditSum; int get hintCount; String get deviceId; int get schema; List<MoveGrade> get grades; DeviationEvent? get deviation;
/// Create a copy of RunRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunRecordCopyWith<RunRecord> get copyWith => _$RunRecordCopyWithImpl<RunRecord>(this as RunRecord, _$identity);

  /// Serializes this RunRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RunRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.repertoireId, _this.repertoireId) || other.repertoireId == _this.repertoireId)&&(identical(other.lineKey, _this.lineKey) || other.lineKey == _this.lineKey)&&(identical(other.ucis, _this.ucis) || other.ucis == _this.ucis)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.startPly, _this.startPly) || other.startPly == _this.startPly)&&(identical(other.wrongMoveMode, _this.wrongMoveMode) || other.wrongMoveMode == _this.wrongMoveMode)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.localDay, _this.localDay) || other.localDay == _this.localDay)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.deviated, _this.deviated) || other.deviated == _this.deviated)&&(identical(other.gradedCount, _this.gradedCount) || other.gradedCount == _this.gradedCount)&&(identical(other.creditSum, _this.creditSum) || other.creditSum == _this.creditSum)&&(identical(other.hintCount, _this.hintCount) || other.hintCount == _this.hintCount)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.schema, _this.schema) || other.schema == _this.schema)&&const DeepCollectionEquality().equals(other.grades, _this.grades)&&(identical(other.deviation, _this.deviation) || other.deviation == _this.deviation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RunRecord;
  return Object.hashAll([runtimeType,_this.id,_this.repertoireId,_this.lineKey,_this.ucis,_this.mode,_this.startPly,_this.wrongMoveMode,_this.startedAt,_this.finishedAt,_this.localDay,_this.completed,_this.deviated,_this.gradedCount,_this.creditSum,_this.hintCount,_this.deviceId,_this.schema,const DeepCollectionEquality().hash(_this.grades),_this.deviation]);
}

@override
String toString() {
  final _this = this as RunRecord;
  return 'RunRecord(id: ${_this.id}, repertoireId: ${_this.repertoireId}, lineKey: ${_this.lineKey}, ucis: ${_this.ucis}, mode: ${_this.mode}, startPly: ${_this.startPly}, wrongMoveMode: ${_this.wrongMoveMode}, startedAt: ${_this.startedAt}, finishedAt: ${_this.finishedAt}, localDay: ${_this.localDay}, completed: ${_this.completed}, deviated: ${_this.deviated}, gradedCount: ${_this.gradedCount}, creditSum: ${_this.creditSum}, hintCount: ${_this.hintCount}, deviceId: ${_this.deviceId}, schema: ${_this.schema}, grades: ${_this.grades}, deviation: ${_this.deviation})';
}


}

/// @nodoc
abstract mixin class $RunRecordCopyWith<$Res>  {
  factory $RunRecordCopyWith(RunRecord value, $Res Function(RunRecord) _then) = _$RunRecordCopyWithImpl;
@useResult
$Res call({
 String id, String repertoireId, String lineKey, String ucis, RunMode mode, int startPly, WrongMoveMode wrongMoveMode, int startedAt, int finishedAt, String localDay, bool completed, bool deviated, int gradedCount, double creditSum, int hintCount, String deviceId, int schema, List<MoveGrade> grades, DeviationEvent? deviation
});


$DeviationEventCopyWith<$Res>? get deviation;

}
/// @nodoc
class _$RunRecordCopyWithImpl<$Res>
    implements $RunRecordCopyWith<$Res> {
  _$RunRecordCopyWithImpl(this._self, this._then);

  final RunRecord _self;
  final $Res Function(RunRecord) _then;

/// Create a copy of RunRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? repertoireId = null,Object? lineKey = null,Object? ucis = null,Object? mode = null,Object? startPly = null,Object? wrongMoveMode = null,Object? startedAt = null,Object? finishedAt = null,Object? localDay = null,Object? completed = null,Object? deviated = null,Object? gradedCount = null,Object? creditSum = null,Object? hintCount = null,Object? deviceId = null,Object? schema = null,Object? grades = null,Object? deviation = freezed,}) {
  return _then(RunRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,repertoireId: null == repertoireId ? _self.repertoireId : repertoireId // ignore: cast_nullable_to_non_nullable
as String,lineKey: null == lineKey ? _self.lineKey : lineKey // ignore: cast_nullable_to_non_nullable
as String,ucis: null == ucis ? _self.ucis : ucis // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as RunMode,startPly: null == startPly ? _self.startPly : startPly // ignore: cast_nullable_to_non_nullable
as int,wrongMoveMode: null == wrongMoveMode ? _self.wrongMoveMode : wrongMoveMode // ignore: cast_nullable_to_non_nullable
as WrongMoveMode,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as int,localDay: null == localDay ? _self.localDay : localDay // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,deviated: null == deviated ? _self.deviated : deviated // ignore: cast_nullable_to_non_nullable
as bool,gradedCount: null == gradedCount ? _self.gradedCount : gradedCount // ignore: cast_nullable_to_non_nullable
as int,creditSum: null == creditSum ? _self.creditSum : creditSum // ignore: cast_nullable_to_non_nullable
as double,hintCount: null == hintCount ? _self.hintCount : hintCount // ignore: cast_nullable_to_non_nullable
as int,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,schema: null == schema ? _self.schema : schema // ignore: cast_nullable_to_non_nullable
as int,grades: null == grades ? _self.grades : grades // ignore: cast_nullable_to_non_nullable
as List<MoveGrade>,deviation: freezed == deviation ? _self.deviation : deviation // ignore: cast_nullable_to_non_nullable
as DeviationEvent?,
  ));
}
/// Create a copy of RunRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviationEventCopyWith<$Res>? get deviation {
    if (_self.deviation == null) {
    return null;
  }

  return $DeviationEventCopyWith<$Res>(_self.deviation!, (value) {
    return _then(_self.copyWith(deviation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RunRecord].
extension RunRecordPatterns on RunRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunRecord value)  $default,){
final _that = this;
switch (_that) {
case _RunRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunRecord value)?  $default,){
final _that = this;
switch (_that) {
case _RunRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String repertoireId,  String lineKey,  String ucis,  RunMode mode,  int startPly,  WrongMoveMode wrongMoveMode,  int startedAt,  int finishedAt,  String localDay,  bool completed,  bool deviated,  int gradedCount,  double creditSum,  int hintCount,  String deviceId,  int schema,  List<MoveGrade> grades,  DeviationEvent? deviation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunRecord() when $default != null:
return $default(_that.id,_that.repertoireId,_that.lineKey,_that.ucis,_that.mode,_that.startPly,_that.wrongMoveMode,_that.startedAt,_that.finishedAt,_that.localDay,_that.completed,_that.deviated,_that.gradedCount,_that.creditSum,_that.hintCount,_that.deviceId,_that.schema,_that.grades,_that.deviation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String repertoireId,  String lineKey,  String ucis,  RunMode mode,  int startPly,  WrongMoveMode wrongMoveMode,  int startedAt,  int finishedAt,  String localDay,  bool completed,  bool deviated,  int gradedCount,  double creditSum,  int hintCount,  String deviceId,  int schema,  List<MoveGrade> grades,  DeviationEvent? deviation)  $default,) {final _that = this;
switch (_that) {
case _RunRecord():
return $default(_that.id,_that.repertoireId,_that.lineKey,_that.ucis,_that.mode,_that.startPly,_that.wrongMoveMode,_that.startedAt,_that.finishedAt,_that.localDay,_that.completed,_that.deviated,_that.gradedCount,_that.creditSum,_that.hintCount,_that.deviceId,_that.schema,_that.grades,_that.deviation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String repertoireId,  String lineKey,  String ucis,  RunMode mode,  int startPly,  WrongMoveMode wrongMoveMode,  int startedAt,  int finishedAt,  String localDay,  bool completed,  bool deviated,  int gradedCount,  double creditSum,  int hintCount,  String deviceId,  int schema,  List<MoveGrade> grades,  DeviationEvent? deviation)?  $default,) {final _that = this;
switch (_that) {
case _RunRecord() when $default != null:
return $default(_that.id,_that.repertoireId,_that.lineKey,_that.ucis,_that.mode,_that.startPly,_that.wrongMoveMode,_that.startedAt,_that.finishedAt,_that.localDay,_that.completed,_that.deviated,_that.gradedCount,_that.creditSum,_that.hintCount,_that.deviceId,_that.schema,_that.grades,_that.deviation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunRecord extends RunRecord {
  const _RunRecord({required this.id, required this.repertoireId, required this.lineKey, required this.ucis, required this.mode, required this.startPly, required this.wrongMoveMode, required this.startedAt, required this.finishedAt, required this.localDay, required this.completed, required this.deviated, required this.gradedCount, required this.creditSum, required this.hintCount, required this.deviceId, this.schema = 1,  List<MoveGrade> grades = const <MoveGrade>[], this.deviation}): _grades = grades,super._();
  factory _RunRecord.fromJson(Map<String, dynamic> json) => _$RunRecordFromJson(json);

@override final  String id;
@override final  String repertoireId;
@override final  String lineKey;
@override final  String ucis;
@override final  RunMode mode;
@override final  int startPly;
@override final  WrongMoveMode wrongMoveMode;
@override final  int startedAt;
@override final  int finishedAt;
@override final  String localDay;
@override final  bool completed;
@override final  bool deviated;
@override final  int gradedCount;
@override final  double creditSum;
@override final  int hintCount;
@override final  String deviceId;
@override@JsonKey() final  int schema;
 final  List<MoveGrade> _grades;
@override@JsonKey() List<MoveGrade> get grades {
  if (_grades is EqualUnmodifiableListView) return _grades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_grades);
}

@override final  DeviationEvent? deviation;

/// Create a copy of RunRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunRecordCopyWith<_RunRecord> get copyWith => __$RunRecordCopyWithImpl<_RunRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.repertoireId, repertoireId) || other.repertoireId == repertoireId)&&(identical(other.lineKey, lineKey) || other.lineKey == lineKey)&&(identical(other.ucis, ucis) || other.ucis == ucis)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.startPly, startPly) || other.startPly == startPly)&&(identical(other.wrongMoveMode, wrongMoveMode) || other.wrongMoveMode == wrongMoveMode)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.localDay, localDay) || other.localDay == localDay)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.deviated, deviated) || other.deviated == deviated)&&(identical(other.gradedCount, gradedCount) || other.gradedCount == gradedCount)&&(identical(other.creditSum, creditSum) || other.creditSum == creditSum)&&(identical(other.hintCount, hintCount) || other.hintCount == hintCount)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.schema, schema) || other.schema == schema)&&const DeepCollectionEquality().equals(other.grades, _grades)&&(identical(other.deviation, deviation) || other.deviation == deviation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,repertoireId,lineKey,ucis,mode,startPly,wrongMoveMode,startedAt,finishedAt,localDay,completed,deviated,gradedCount,creditSum,hintCount,deviceId,schema,const DeepCollectionEquality().hash(_grades),deviation]);
}

@override
String toString() {
    return 'RunRecord(id: $id, repertoireId: $repertoireId, lineKey: $lineKey, ucis: $ucis, mode: $mode, startPly: $startPly, wrongMoveMode: $wrongMoveMode, startedAt: $startedAt, finishedAt: $finishedAt, localDay: $localDay, completed: $completed, deviated: $deviated, gradedCount: $gradedCount, creditSum: $creditSum, hintCount: $hintCount, deviceId: $deviceId, schema: $schema, grades: $grades, deviation: $deviation)';
}


}

/// @nodoc
abstract mixin class _$RunRecordCopyWith<$Res> implements $RunRecordCopyWith<$Res> {
  factory _$RunRecordCopyWith(_RunRecord value, $Res Function(_RunRecord) _then) = __$RunRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String repertoireId, String lineKey, String ucis, RunMode mode, int startPly, WrongMoveMode wrongMoveMode, int startedAt, int finishedAt, String localDay, bool completed, bool deviated, int gradedCount, double creditSum, int hintCount, String deviceId, int schema, List<MoveGrade> grades, DeviationEvent? deviation
});


@override $DeviationEventCopyWith<$Res>? get deviation;

}
/// @nodoc
class __$RunRecordCopyWithImpl<$Res>
    implements _$RunRecordCopyWith<$Res> {
  __$RunRecordCopyWithImpl(this._self, this._then);

  final _RunRecord _self;
  final $Res Function(_RunRecord) _then;

/// Create a copy of RunRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? repertoireId = null,Object? lineKey = null,Object? ucis = null,Object? mode = null,Object? startPly = null,Object? wrongMoveMode = null,Object? startedAt = null,Object? finishedAt = null,Object? localDay = null,Object? completed = null,Object? deviated = null,Object? gradedCount = null,Object? creditSum = null,Object? hintCount = null,Object? deviceId = null,Object? schema = null,Object? grades = null,Object? deviation = freezed,}) {
  return _then(_RunRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,repertoireId: null == repertoireId ? _self.repertoireId : repertoireId // ignore: cast_nullable_to_non_nullable
as String,lineKey: null == lineKey ? _self.lineKey : lineKey // ignore: cast_nullable_to_non_nullable
as String,ucis: null == ucis ? _self.ucis : ucis // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as RunMode,startPly: null == startPly ? _self.startPly : startPly // ignore: cast_nullable_to_non_nullable
as int,wrongMoveMode: null == wrongMoveMode ? _self.wrongMoveMode : wrongMoveMode // ignore: cast_nullable_to_non_nullable
as WrongMoveMode,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as int,localDay: null == localDay ? _self.localDay : localDay // ignore: cast_nullable_to_non_nullable
as String,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,deviated: null == deviated ? _self.deviated : deviated // ignore: cast_nullable_to_non_nullable
as bool,gradedCount: null == gradedCount ? _self.gradedCount : gradedCount // ignore: cast_nullable_to_non_nullable
as int,creditSum: null == creditSum ? _self.creditSum : creditSum // ignore: cast_nullable_to_non_nullable
as double,hintCount: null == hintCount ? _self.hintCount : hintCount // ignore: cast_nullable_to_non_nullable
as int,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,schema: null == schema ? _self.schema : schema // ignore: cast_nullable_to_non_nullable
as int,grades: null == grades ? _self._grades : grades // ignore: cast_nullable_to_non_nullable
as List<MoveGrade>,deviation: freezed == deviation ? _self.deviation : deviation // ignore: cast_nullable_to_non_nullable
as DeviationEvent?,
  ));
}

/// Create a copy of RunRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviationEventCopyWith<$Res>? get deviation {
    if (_self.deviation == null) {
    return null;
  }

  return $DeviationEventCopyWith<$Res>(_self.deviation!, (value) {
    return _then(_self.copyWith(deviation: value));
  });
}
}


/// @nodoc
mixin _$MoveGrade {

 int get ply; String get expected; String get accepted; String? get firstAttempt; GradeResult get result; double get credit; int get attempts; int get hintLevel; int? get checkCp; CheckStatus? get checkStatus;
/// Create a copy of MoveGrade
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveGradeCopyWith<MoveGrade> get copyWith => _$MoveGradeCopyWithImpl<MoveGrade>(this as MoveGrade, _$identity);

  /// Serializes this MoveGrade to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoveGrade;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveGrade&&(identical(other.ply, _this.ply) || other.ply == _this.ply)&&(identical(other.expected, _this.expected) || other.expected == _this.expected)&&(identical(other.accepted, _this.accepted) || other.accepted == _this.accepted)&&(identical(other.firstAttempt, _this.firstAttempt) || other.firstAttempt == _this.firstAttempt)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.credit, _this.credit) || other.credit == _this.credit)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.hintLevel, _this.hintLevel) || other.hintLevel == _this.hintLevel)&&(identical(other.checkCp, _this.checkCp) || other.checkCp == _this.checkCp)&&(identical(other.checkStatus, _this.checkStatus) || other.checkStatus == _this.checkStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoveGrade;
  return Object.hash(runtimeType,_this.ply,_this.expected,_this.accepted,_this.firstAttempt,_this.result,_this.credit,_this.attempts,_this.hintLevel,_this.checkCp,_this.checkStatus);
}

@override
String toString() {
  final _this = this as MoveGrade;
  return 'MoveGrade(ply: ${_this.ply}, expected: ${_this.expected}, accepted: ${_this.accepted}, firstAttempt: ${_this.firstAttempt}, result: ${_this.result}, credit: ${_this.credit}, attempts: ${_this.attempts}, hintLevel: ${_this.hintLevel}, checkCp: ${_this.checkCp}, checkStatus: ${_this.checkStatus})';
}


}

/// @nodoc
abstract mixin class $MoveGradeCopyWith<$Res>  {
  factory $MoveGradeCopyWith(MoveGrade value, $Res Function(MoveGrade) _then) = _$MoveGradeCopyWithImpl;
@useResult
$Res call({
 int ply, String expected, String accepted, String? firstAttempt, GradeResult result, double credit, int attempts, int hintLevel, int? checkCp, CheckStatus? checkStatus
});




}
/// @nodoc
class _$MoveGradeCopyWithImpl<$Res>
    implements $MoveGradeCopyWith<$Res> {
  _$MoveGradeCopyWithImpl(this._self, this._then);

  final MoveGrade _self;
  final $Res Function(MoveGrade) _then;

/// Create a copy of MoveGrade
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ply = null,Object? expected = null,Object? accepted = null,Object? firstAttempt = freezed,Object? result = null,Object? credit = null,Object? attempts = null,Object? hintLevel = null,Object? checkCp = freezed,Object? checkStatus = freezed,}) {
  return _then(MoveGrade(
ply: null == ply ? _self.ply : ply // ignore: cast_nullable_to_non_nullable
as int,expected: null == expected ? _self.expected : expected // ignore: cast_nullable_to_non_nullable
as String,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as String,firstAttempt: freezed == firstAttempt ? _self.firstAttempt : firstAttempt // ignore: cast_nullable_to_non_nullable
as String?,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GradeResult,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as double,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,hintLevel: null == hintLevel ? _self.hintLevel : hintLevel // ignore: cast_nullable_to_non_nullable
as int,checkCp: freezed == checkCp ? _self.checkCp : checkCp // ignore: cast_nullable_to_non_nullable
as int?,checkStatus: freezed == checkStatus ? _self.checkStatus : checkStatus // ignore: cast_nullable_to_non_nullable
as CheckStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveGrade].
extension MoveGradePatterns on MoveGrade {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveGrade value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveGrade() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveGrade value)  $default,){
final _that = this;
switch (_that) {
case _MoveGrade():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveGrade value)?  $default,){
final _that = this;
switch (_that) {
case _MoveGrade() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ply,  String expected,  String accepted,  String? firstAttempt,  GradeResult result,  double credit,  int attempts,  int hintLevel,  int? checkCp,  CheckStatus? checkStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveGrade() when $default != null:
return $default(_that.ply,_that.expected,_that.accepted,_that.firstAttempt,_that.result,_that.credit,_that.attempts,_that.hintLevel,_that.checkCp,_that.checkStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ply,  String expected,  String accepted,  String? firstAttempt,  GradeResult result,  double credit,  int attempts,  int hintLevel,  int? checkCp,  CheckStatus? checkStatus)  $default,) {final _that = this;
switch (_that) {
case _MoveGrade():
return $default(_that.ply,_that.expected,_that.accepted,_that.firstAttempt,_that.result,_that.credit,_that.attempts,_that.hintLevel,_that.checkCp,_that.checkStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ply,  String expected,  String accepted,  String? firstAttempt,  GradeResult result,  double credit,  int attempts,  int hintLevel,  int? checkCp,  CheckStatus? checkStatus)?  $default,) {final _that = this;
switch (_that) {
case _MoveGrade() when $default != null:
return $default(_that.ply,_that.expected,_that.accepted,_that.firstAttempt,_that.result,_that.credit,_that.attempts,_that.hintLevel,_that.checkCp,_that.checkStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveGrade implements MoveGrade {
  const _MoveGrade({required this.ply, required this.expected, required this.accepted, required this.firstAttempt, required this.result, required this.credit, required this.attempts, required this.hintLevel, this.checkCp, this.checkStatus});
  factory _MoveGrade.fromJson(Map<String, dynamic> json) => _$MoveGradeFromJson(json);

@override final  int ply;
@override final  String expected;
@override final  String accepted;
@override final  String? firstAttempt;
@override final  GradeResult result;
@override final  double credit;
@override final  int attempts;
@override final  int hintLevel;
@override final  int? checkCp;
@override final  CheckStatus? checkStatus;

/// Create a copy of MoveGrade
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveGradeCopyWith<_MoveGrade> get copyWith => __$MoveGradeCopyWithImpl<_MoveGrade>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveGradeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveGrade&&(identical(other.ply, ply) || other.ply == ply)&&(identical(other.expected, expected) || other.expected == expected)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.firstAttempt, firstAttempt) || other.firstAttempt == firstAttempt)&&(identical(other.result, result) || other.result == result)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.hintLevel, hintLevel) || other.hintLevel == hintLevel)&&(identical(other.checkCp, checkCp) || other.checkCp == checkCp)&&(identical(other.checkStatus, checkStatus) || other.checkStatus == checkStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ply,expected,accepted,firstAttempt,result,credit,attempts,hintLevel,checkCp,checkStatus);
}

@override
String toString() {
    return 'MoveGrade(ply: $ply, expected: $expected, accepted: $accepted, firstAttempt: $firstAttempt, result: $result, credit: $credit, attempts: $attempts, hintLevel: $hintLevel, checkCp: $checkCp, checkStatus: $checkStatus)';
}


}

/// @nodoc
abstract mixin class _$MoveGradeCopyWith<$Res> implements $MoveGradeCopyWith<$Res> {
  factory _$MoveGradeCopyWith(_MoveGrade value, $Res Function(_MoveGrade) _then) = __$MoveGradeCopyWithImpl;
@override @useResult
$Res call({
 int ply, String expected, String accepted, String? firstAttempt, GradeResult result, double credit, int attempts, int hintLevel, int? checkCp, CheckStatus? checkStatus
});




}
/// @nodoc
class __$MoveGradeCopyWithImpl<$Res>
    implements _$MoveGradeCopyWith<$Res> {
  __$MoveGradeCopyWithImpl(this._self, this._then);

  final _MoveGrade _self;
  final $Res Function(_MoveGrade) _then;

/// Create a copy of MoveGrade
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ply = null,Object? expected = null,Object? accepted = null,Object? firstAttempt = freezed,Object? result = null,Object? credit = null,Object? attempts = null,Object? hintLevel = null,Object? checkCp = freezed,Object? checkStatus = freezed,}) {
  return _then(_MoveGrade(
ply: null == ply ? _self.ply : ply // ignore: cast_nullable_to_non_nullable
as int,expected: null == expected ? _self.expected : expected // ignore: cast_nullable_to_non_nullable
as String,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as String,firstAttempt: freezed == firstAttempt ? _self.firstAttempt : firstAttempt // ignore: cast_nullable_to_non_nullable
as String?,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GradeResult,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as double,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,hintLevel: null == hintLevel ? _self.hintLevel : hintLevel // ignore: cast_nullable_to_non_nullable
as int,checkCp: freezed == checkCp ? _self.checkCp : checkCp // ignore: cast_nullable_to_non_nullable
as int?,checkStatus: freezed == checkStatus ? _self.checkStatus : checkStatus // ignore: cast_nullable_to_non_nullable
as CheckStatus?,
  ));
}


}


/// @nodoc
mixin _$DeviationEvent {

 int get ply; String get bestUci; bool get passed; String? get deviationUci; String? get replyUci; int? get lossCp;
/// Create a copy of DeviationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviationEventCopyWith<DeviationEvent> get copyWith => _$DeviationEventCopyWithImpl<DeviationEvent>(this as DeviationEvent, _$identity);

  /// Serializes this DeviationEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviationEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviationEvent&&(identical(other.ply, _this.ply) || other.ply == _this.ply)&&(identical(other.bestUci, _this.bestUci) || other.bestUci == _this.bestUci)&&(identical(other.passed, _this.passed) || other.passed == _this.passed)&&(identical(other.deviationUci, _this.deviationUci) || other.deviationUci == _this.deviationUci)&&(identical(other.replyUci, _this.replyUci) || other.replyUci == _this.replyUci)&&(identical(other.lossCp, _this.lossCp) || other.lossCp == _this.lossCp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviationEvent;
  return Object.hash(runtimeType,_this.ply,_this.bestUci,_this.passed,_this.deviationUci,_this.replyUci,_this.lossCp);
}

@override
String toString() {
  final _this = this as DeviationEvent;
  return 'DeviationEvent(ply: ${_this.ply}, bestUci: ${_this.bestUci}, passed: ${_this.passed}, deviationUci: ${_this.deviationUci}, replyUci: ${_this.replyUci}, lossCp: ${_this.lossCp})';
}


}

/// @nodoc
abstract mixin class $DeviationEventCopyWith<$Res>  {
  factory $DeviationEventCopyWith(DeviationEvent value, $Res Function(DeviationEvent) _then) = _$DeviationEventCopyWithImpl;
@useResult
$Res call({
 int ply, String bestUci, bool passed, String? deviationUci, String? replyUci, int? lossCp
});




}
/// @nodoc
class _$DeviationEventCopyWithImpl<$Res>
    implements $DeviationEventCopyWith<$Res> {
  _$DeviationEventCopyWithImpl(this._self, this._then);

  final DeviationEvent _self;
  final $Res Function(DeviationEvent) _then;

/// Create a copy of DeviationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ply = null,Object? bestUci = null,Object? passed = null,Object? deviationUci = freezed,Object? replyUci = freezed,Object? lossCp = freezed,}) {
  return _then(DeviationEvent(
ply: null == ply ? _self.ply : ply // ignore: cast_nullable_to_non_nullable
as int,bestUci: null == bestUci ? _self.bestUci : bestUci // ignore: cast_nullable_to_non_nullable
as String,passed: null == passed ? _self.passed : passed // ignore: cast_nullable_to_non_nullable
as bool,deviationUci: freezed == deviationUci ? _self.deviationUci : deviationUci // ignore: cast_nullable_to_non_nullable
as String?,replyUci: freezed == replyUci ? _self.replyUci : replyUci // ignore: cast_nullable_to_non_nullable
as String?,lossCp: freezed == lossCp ? _self.lossCp : lossCp // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviationEvent].
extension DeviationEventPatterns on DeviationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviationEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviationEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviationEvent value)  $default,){
final _that = this;
switch (_that) {
case _DeviationEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviationEvent value)?  $default,){
final _that = this;
switch (_that) {
case _DeviationEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ply,  String bestUci,  bool passed,  String? deviationUci,  String? replyUci,  int? lossCp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviationEvent() when $default != null:
return $default(_that.ply,_that.bestUci,_that.passed,_that.deviationUci,_that.replyUci,_that.lossCp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ply,  String bestUci,  bool passed,  String? deviationUci,  String? replyUci,  int? lossCp)  $default,) {final _that = this;
switch (_that) {
case _DeviationEvent():
return $default(_that.ply,_that.bestUci,_that.passed,_that.deviationUci,_that.replyUci,_that.lossCp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ply,  String bestUci,  bool passed,  String? deviationUci,  String? replyUci,  int? lossCp)?  $default,) {final _that = this;
switch (_that) {
case _DeviationEvent() when $default != null:
return $default(_that.ply,_that.bestUci,_that.passed,_that.deviationUci,_that.replyUci,_that.lossCp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviationEvent implements DeviationEvent {
  const _DeviationEvent({required this.ply, required this.bestUci, required this.passed, this.deviationUci, this.replyUci, this.lossCp});
  factory _DeviationEvent.fromJson(Map<String, dynamic> json) => _$DeviationEventFromJson(json);

@override final  int ply;
@override final  String bestUci;
@override final  bool passed;
@override final  String? deviationUci;
@override final  String? replyUci;
@override final  int? lossCp;

/// Create a copy of DeviationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviationEventCopyWith<_DeviationEvent> get copyWith => __$DeviationEventCopyWithImpl<_DeviationEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviationEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviationEvent&&(identical(other.ply, ply) || other.ply == ply)&&(identical(other.bestUci, bestUci) || other.bestUci == bestUci)&&(identical(other.passed, passed) || other.passed == passed)&&(identical(other.deviationUci, deviationUci) || other.deviationUci == deviationUci)&&(identical(other.replyUci, replyUci) || other.replyUci == replyUci)&&(identical(other.lossCp, lossCp) || other.lossCp == lossCp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ply,bestUci,passed,deviationUci,replyUci,lossCp);
}

@override
String toString() {
    return 'DeviationEvent(ply: $ply, bestUci: $bestUci, passed: $passed, deviationUci: $deviationUci, replyUci: $replyUci, lossCp: $lossCp)';
}


}

/// @nodoc
abstract mixin class _$DeviationEventCopyWith<$Res> implements $DeviationEventCopyWith<$Res> {
  factory _$DeviationEventCopyWith(_DeviationEvent value, $Res Function(_DeviationEvent) _then) = __$DeviationEventCopyWithImpl;
@override @useResult
$Res call({
 int ply, String bestUci, bool passed, String? deviationUci, String? replyUci, int? lossCp
});




}
/// @nodoc
class __$DeviationEventCopyWithImpl<$Res>
    implements _$DeviationEventCopyWith<$Res> {
  __$DeviationEventCopyWithImpl(this._self, this._then);

  final _DeviationEvent _self;
  final $Res Function(_DeviationEvent) _then;

/// Create a copy of DeviationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ply = null,Object? bestUci = null,Object? passed = null,Object? deviationUci = freezed,Object? replyUci = freezed,Object? lossCp = freezed,}) {
  return _then(_DeviationEvent(
ply: null == ply ? _self.ply : ply // ignore: cast_nullable_to_non_nullable
as int,bestUci: null == bestUci ? _self.bestUci : bestUci // ignore: cast_nullable_to_non_nullable
as String,passed: null == passed ? _self.passed : passed // ignore: cast_nullable_to_non_nullable
as bool,deviationUci: freezed == deviationUci ? _self.deviationUci : deviationUci // ignore: cast_nullable_to_non_nullable
as String?,replyUci: freezed == replyUci ? _self.replyUci : replyUci // ignore: cast_nullable_to_non_nullable
as String?,lossCp: freezed == lossCp ? _self.lossCp : lossCp // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
