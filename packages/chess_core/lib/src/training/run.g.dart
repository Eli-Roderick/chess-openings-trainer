// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunRecord _$RunRecordFromJson(Map<String, dynamic> json) => _RunRecord(
  id: json['id'] as String,
  repertoireId: json['repertoireId'] as String,
  lineKey: json['lineKey'] as String,
  ucis: json['ucis'] as String,
  mode: $enumDecode(_$RunModeEnumMap, json['mode']),
  startPly: (json['startPly'] as num).toInt(),
  wrongMoveMode: $enumDecode(_$WrongMoveModeEnumMap, json['wrongMoveMode']),
  startedAt: (json['startedAt'] as num).toInt(),
  finishedAt: (json['finishedAt'] as num).toInt(),
  localDay: json['localDay'] as String,
  completed: json['completed'] as bool,
  deviated: json['deviated'] as bool,
  gradedCount: (json['gradedCount'] as num).toInt(),
  creditSum: (json['creditSum'] as num).toDouble(),
  hintCount: (json['hintCount'] as num).toInt(),
  deviceId: json['deviceId'] as String,
  schema: (json['schema'] as num?)?.toInt() ?? 1,
  grades:
      (json['grades'] as List<dynamic>?)
          ?.map((e) => MoveGrade.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MoveGrade>[],
  deviation: json['deviation'] == null
      ? null
      : DeviationEvent.fromJson(json['deviation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RunRecordToJson(_RunRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'repertoireId': instance.repertoireId,
      'lineKey': instance.lineKey,
      'ucis': instance.ucis,
      'mode': _$RunModeEnumMap[instance.mode]!,
      'startPly': instance.startPly,
      'wrongMoveMode': _$WrongMoveModeEnumMap[instance.wrongMoveMode]!,
      'startedAt': instance.startedAt,
      'finishedAt': instance.finishedAt,
      'localDay': instance.localDay,
      'completed': instance.completed,
      'deviated': instance.deviated,
      'gradedCount': instance.gradedCount,
      'creditSum': instance.creditSum,
      'hintCount': instance.hintCount,
      'deviceId': instance.deviceId,
      'schema': instance.schema,
      'grades': instance.grades,
      'deviation': instance.deviation,
    };

const _$RunModeEnumMap = {
  RunMode.random: 'random',
  RunMode.weak: 'weak',
  RunMode.srs: 'srs',
  RunMode.single: 'single',
};

const _$WrongMoveModeEnumMap = {
  WrongMoveMode.retry: 'retry',
  WrongMoveMode.restart: 'restart',
};

_MoveGrade _$MoveGradeFromJson(Map<String, dynamic> json) => _MoveGrade(
  ply: (json['ply'] as num).toInt(),
  expected: json['expected'] as String,
  accepted: json['accepted'] as String,
  firstAttempt: json['firstAttempt'] as String?,
  result: $enumDecode(_$GradeResultEnumMap, json['result']),
  credit: (json['credit'] as num).toDouble(),
  attempts: (json['attempts'] as num).toInt(),
  hintLevel: (json['hintLevel'] as num).toInt(),
  checkCp: (json['checkCp'] as num?)?.toInt(),
  checkStatus: $enumDecodeNullable(_$CheckStatusEnumMap, json['checkStatus']),
);

Map<String, dynamic> _$MoveGradeToJson(_MoveGrade instance) =>
    <String, dynamic>{
      'ply': instance.ply,
      'expected': instance.expected,
      'accepted': instance.accepted,
      'firstAttempt': instance.firstAttempt,
      'result': _$GradeResultEnumMap[instance.result]!,
      'credit': instance.credit,
      'attempts': instance.attempts,
      'hintLevel': instance.hintLevel,
      'checkCp': instance.checkCp,
      'checkStatus': _$CheckStatusEnumMap[instance.checkStatus],
    };

const _$GradeResultEnumMap = {
  GradeResult.correct: 'correct',
  GradeResult.comparable: 'comparable',
  GradeResult.wrong: 'wrong',
  GradeResult.hint: 'hint',
};

const _$CheckStatusEnumMap = {
  CheckStatus.ok: 'ok',
  CheckStatus.timeout: 'timeout',
  CheckStatus.engineUnavailable: 'engine_unavailable',
};

_DeviationEvent _$DeviationEventFromJson(Map<String, dynamic> json) =>
    _DeviationEvent(
      ply: (json['ply'] as num).toInt(),
      bestUci: json['bestUci'] as String,
      passed: json['passed'] as bool,
      deviationUci: json['deviationUci'] as String?,
      replyUci: json['replyUci'] as String?,
      lossCp: (json['lossCp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DeviationEventToJson(_DeviationEvent instance) =>
    <String, dynamic>{
      'ply': instance.ply,
      'bestUci': instance.bestUci,
      'passed': instance.passed,
      'deviationUci': instance.deviationUci,
      'replyUci': instance.replyUci,
      'lossCp': instance.lossCp,
    };
