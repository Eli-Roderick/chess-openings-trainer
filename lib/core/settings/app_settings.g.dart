// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  wrongMoveMode:
      $enumDecodeNullable(_$WrongMoveModeEnumMap, json['wrongMoveMode']) ??
      WrongMoveMode.retry,
  showLineSummary: json['showLineSummary'] as bool? ?? false,
  autoAdvanceDelayMs: (json['autoAdvanceDelayMs'] as num?)?.toInt() ?? 1500,
  opponentMoveDelayMs: (json['opponentMoveDelayMs'] as num?)?.toInt() ?? 250,
  showComments: json['showComments'] as bool? ?? true,
  showCommentArrows: json['showCommentArrows'] as bool? ?? true,
  deviationsEnabled: json['deviationsEnabled'] as bool? ?? false,
  deviationChancePercent:
      (json['deviationChancePercent'] as num?)?.toInt() ?? 25,
  deviationTiming:
      $enumDecodeNullable(_$DeviationTimingEnumMap, json['deviationTiming']) ??
      DeviationTiming.endOfLine,
  weakEnterBelowPercent: (json['weakEnterBelowPercent'] as num?)?.toInt() ?? 80,
  weakExitCleanRuns:
      (json['weakExitCleanRuns'] as num?)?.toInt() ?? defaultWeakExitCleanRuns,
  srsNewPerDay: (json['srsNewPerDay'] as num?)?.toInt() ?? defaultSrsNewPerDay,
  srsMaxReviewsPerDay: (json['srsMaxReviewsPerDay'] as num?)?.toInt(),
  dayStartHour: (json['dayStartHour'] as num?)?.toInt() ?? defaultDayStartHour,
  startFromBranchPoint: json['startFromBranchPoint'] as bool? ?? false,
  drillEvalBar: json['drillEvalBar'] as bool? ?? false,
  boardTheme: json['boardTheme'] as String? ?? 'brown',
  pieceSet: json['pieceSet'] as String? ?? 'cburnett',
  showCoordinates: json['showCoordinates'] as bool? ?? true,
  showLegalMoves: json['showLegalMoves'] as bool? ?? true,
  highlightLastMove: json['highlightLastMove'] as bool? ?? true,
  animationSpeed:
      $enumDecodeNullable(_$AnimationSpeedEnumMap, json['animationSpeed']) ??
      AnimationSpeed.normal,
  soundsEnabled: json['soundsEnabled'] as bool? ?? true,
  soundVolumePercent: (json['soundVolumePercent'] as num?)?.toInt() ?? 80,
  hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
  comparableThresholdCp:
      (json['comparableThresholdCp'] as num?)?.toInt() ??
      defaultComparableThresholdCp,
  checkSearchMs: (json['checkSearchMs'] as num?)?.toInt() ?? 1000,
  engineThreads: (json['engineThreads'] as num?)?.toInt(),
  engineHashMb: (json['engineHashMb'] as num?)?.toInt(),
  playOnElo: (json['playOnElo'] as num?)?.toInt() ?? 2500,
  engineVariant: json['engineVariant'] as String?,
  analysisLines: (json['analysisLines'] as num?)?.toInt() ?? 1,
  themeMode:
      $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
      AppThemeMode.dark,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'wrongMoveMode': _$WrongMoveModeEnumMap[instance.wrongMoveMode]!,
      'showLineSummary': instance.showLineSummary,
      'autoAdvanceDelayMs': instance.autoAdvanceDelayMs,
      'opponentMoveDelayMs': instance.opponentMoveDelayMs,
      'showComments': instance.showComments,
      'showCommentArrows': instance.showCommentArrows,
      'deviationsEnabled': instance.deviationsEnabled,
      'deviationChancePercent': instance.deviationChancePercent,
      'deviationTiming': _$DeviationTimingEnumMap[instance.deviationTiming]!,
      'weakEnterBelowPercent': instance.weakEnterBelowPercent,
      'weakExitCleanRuns': instance.weakExitCleanRuns,
      'srsNewPerDay': instance.srsNewPerDay,
      'srsMaxReviewsPerDay': instance.srsMaxReviewsPerDay,
      'dayStartHour': instance.dayStartHour,
      'startFromBranchPoint': instance.startFromBranchPoint,
      'drillEvalBar': instance.drillEvalBar,
      'boardTheme': instance.boardTheme,
      'pieceSet': instance.pieceSet,
      'showCoordinates': instance.showCoordinates,
      'showLegalMoves': instance.showLegalMoves,
      'highlightLastMove': instance.highlightLastMove,
      'animationSpeed': _$AnimationSpeedEnumMap[instance.animationSpeed]!,
      'soundsEnabled': instance.soundsEnabled,
      'soundVolumePercent': instance.soundVolumePercent,
      'hapticsEnabled': instance.hapticsEnabled,
      'comparableThresholdCp': instance.comparableThresholdCp,
      'checkSearchMs': instance.checkSearchMs,
      'engineThreads': instance.engineThreads,
      'engineHashMb': instance.engineHashMb,
      'playOnElo': instance.playOnElo,
      'engineVariant': instance.engineVariant,
      'analysisLines': instance.analysisLines,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
    };

const _$WrongMoveModeEnumMap = {
  WrongMoveMode.retry: 'retry',
  WrongMoveMode.restart: 'restart',
};

const _$DeviationTimingEnumMap = {
  DeviationTiming.endOfLine: 'endOfLine',
  DeviationTiming.anywhere: 'anywhere',
};

const _$AnimationSpeedEnumMap = {
  AnimationSpeed.slow: 'slow',
  AnimationSpeed.normal: 'normal',
  AnimationSpeed.fast: 'fast',
  AnimationSpeed.off: 'off',
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.dark: 'dark',
  AppThemeMode.light: 'light',
  AppThemeMode.system: 'system',
};
