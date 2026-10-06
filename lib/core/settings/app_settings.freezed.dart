// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 WrongMoveMode get wrongMoveMode; bool get showLineSummary; int get autoAdvanceDelayMs; int get opponentMoveDelayMs; bool get showComments; bool get showCommentArrows; bool get deviationsEnabled; int get deviationChancePercent; DeviationTiming get deviationTiming; int get weakEnterBelowPercent; int get weakExitCleanRuns; int get srsNewPerDay;/// Null = unlimited.
 int? get srsMaxReviewsPerDay; int get dayStartHour;/// Drills start at the line's branch point instead of move 1 (the
/// default for the mode sheet, 01-product-spec §7.1).
 bool get startFromBranchPoint; String get boardTheme; String get pieceSet; bool get showCoordinates; bool get showLegalMoves; bool get highlightLastMove; AnimationSpeed get animationSpeed; bool get soundsEnabled; int get soundVolumePercent; bool get hapticsEnabled; int get comparableThresholdCp; int get checkSearchMs;/// Null = auto (docs/plan/05-engine.md §3).
 int? get engineThreads;/// Null = auto.
 int? get engineHashMb;/// UCI_Elo for play-on (1500, 2000, 2500); 0 = full strength.
 int get playOnElo;/// Windows: the engine variant that answered (avx2 / sse41), if known.
 String? get engineVariant;/// Number of lines in Browse analysis (01-product-spec §9).
 int get analysisLines; AppThemeMode get themeMode;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.wrongMoveMode, _this.wrongMoveMode) || other.wrongMoveMode == _this.wrongMoveMode)&&(identical(other.showLineSummary, _this.showLineSummary) || other.showLineSummary == _this.showLineSummary)&&(identical(other.autoAdvanceDelayMs, _this.autoAdvanceDelayMs) || other.autoAdvanceDelayMs == _this.autoAdvanceDelayMs)&&(identical(other.opponentMoveDelayMs, _this.opponentMoveDelayMs) || other.opponentMoveDelayMs == _this.opponentMoveDelayMs)&&(identical(other.showComments, _this.showComments) || other.showComments == _this.showComments)&&(identical(other.showCommentArrows, _this.showCommentArrows) || other.showCommentArrows == _this.showCommentArrows)&&(identical(other.deviationsEnabled, _this.deviationsEnabled) || other.deviationsEnabled == _this.deviationsEnabled)&&(identical(other.deviationChancePercent, _this.deviationChancePercent) || other.deviationChancePercent == _this.deviationChancePercent)&&(identical(other.deviationTiming, _this.deviationTiming) || other.deviationTiming == _this.deviationTiming)&&(identical(other.weakEnterBelowPercent, _this.weakEnterBelowPercent) || other.weakEnterBelowPercent == _this.weakEnterBelowPercent)&&(identical(other.weakExitCleanRuns, _this.weakExitCleanRuns) || other.weakExitCleanRuns == _this.weakExitCleanRuns)&&(identical(other.srsNewPerDay, _this.srsNewPerDay) || other.srsNewPerDay == _this.srsNewPerDay)&&(identical(other.srsMaxReviewsPerDay, _this.srsMaxReviewsPerDay) || other.srsMaxReviewsPerDay == _this.srsMaxReviewsPerDay)&&(identical(other.dayStartHour, _this.dayStartHour) || other.dayStartHour == _this.dayStartHour)&&(identical(other.startFromBranchPoint, _this.startFromBranchPoint) || other.startFromBranchPoint == _this.startFromBranchPoint)&&(identical(other.boardTheme, _this.boardTheme) || other.boardTheme == _this.boardTheme)&&(identical(other.pieceSet, _this.pieceSet) || other.pieceSet == _this.pieceSet)&&(identical(other.showCoordinates, _this.showCoordinates) || other.showCoordinates == _this.showCoordinates)&&(identical(other.showLegalMoves, _this.showLegalMoves) || other.showLegalMoves == _this.showLegalMoves)&&(identical(other.highlightLastMove, _this.highlightLastMove) || other.highlightLastMove == _this.highlightLastMove)&&(identical(other.animationSpeed, _this.animationSpeed) || other.animationSpeed == _this.animationSpeed)&&(identical(other.soundsEnabled, _this.soundsEnabled) || other.soundsEnabled == _this.soundsEnabled)&&(identical(other.soundVolumePercent, _this.soundVolumePercent) || other.soundVolumePercent == _this.soundVolumePercent)&&(identical(other.hapticsEnabled, _this.hapticsEnabled) || other.hapticsEnabled == _this.hapticsEnabled)&&(identical(other.comparableThresholdCp, _this.comparableThresholdCp) || other.comparableThresholdCp == _this.comparableThresholdCp)&&(identical(other.checkSearchMs, _this.checkSearchMs) || other.checkSearchMs == _this.checkSearchMs)&&(identical(other.engineThreads, _this.engineThreads) || other.engineThreads == _this.engineThreads)&&(identical(other.engineHashMb, _this.engineHashMb) || other.engineHashMb == _this.engineHashMb)&&(identical(other.playOnElo, _this.playOnElo) || other.playOnElo == _this.playOnElo)&&(identical(other.engineVariant, _this.engineVariant) || other.engineVariant == _this.engineVariant)&&(identical(other.analysisLines, _this.analysisLines) || other.analysisLines == _this.analysisLines)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hashAll([runtimeType,_this.wrongMoveMode,_this.showLineSummary,_this.autoAdvanceDelayMs,_this.opponentMoveDelayMs,_this.showComments,_this.showCommentArrows,_this.deviationsEnabled,_this.deviationChancePercent,_this.deviationTiming,_this.weakEnterBelowPercent,_this.weakExitCleanRuns,_this.srsNewPerDay,_this.srsMaxReviewsPerDay,_this.dayStartHour,_this.startFromBranchPoint,_this.boardTheme,_this.pieceSet,_this.showCoordinates,_this.showLegalMoves,_this.highlightLastMove,_this.animationSpeed,_this.soundsEnabled,_this.soundVolumePercent,_this.hapticsEnabled,_this.comparableThresholdCp,_this.checkSearchMs,_this.engineThreads,_this.engineHashMb,_this.playOnElo,_this.engineVariant,_this.analysisLines,_this.themeMode]);
}

@override
String toString() {
  final _this = this as AppSettings;
  return 'AppSettings(wrongMoveMode: ${_this.wrongMoveMode}, showLineSummary: ${_this.showLineSummary}, autoAdvanceDelayMs: ${_this.autoAdvanceDelayMs}, opponentMoveDelayMs: ${_this.opponentMoveDelayMs}, showComments: ${_this.showComments}, showCommentArrows: ${_this.showCommentArrows}, deviationsEnabled: ${_this.deviationsEnabled}, deviationChancePercent: ${_this.deviationChancePercent}, deviationTiming: ${_this.deviationTiming}, weakEnterBelowPercent: ${_this.weakEnterBelowPercent}, weakExitCleanRuns: ${_this.weakExitCleanRuns}, srsNewPerDay: ${_this.srsNewPerDay}, srsMaxReviewsPerDay: ${_this.srsMaxReviewsPerDay}, dayStartHour: ${_this.dayStartHour}, startFromBranchPoint: ${_this.startFromBranchPoint}, boardTheme: ${_this.boardTheme}, pieceSet: ${_this.pieceSet}, showCoordinates: ${_this.showCoordinates}, showLegalMoves: ${_this.showLegalMoves}, highlightLastMove: ${_this.highlightLastMove}, animationSpeed: ${_this.animationSpeed}, soundsEnabled: ${_this.soundsEnabled}, soundVolumePercent: ${_this.soundVolumePercent}, hapticsEnabled: ${_this.hapticsEnabled}, comparableThresholdCp: ${_this.comparableThresholdCp}, checkSearchMs: ${_this.checkSearchMs}, engineThreads: ${_this.engineThreads}, engineHashMb: ${_this.engineHashMb}, playOnElo: ${_this.playOnElo}, engineVariant: ${_this.engineVariant}, analysisLines: ${_this.analysisLines}, themeMode: ${_this.themeMode})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 WrongMoveMode wrongMoveMode, bool showLineSummary, int autoAdvanceDelayMs, int opponentMoveDelayMs, bool showComments, bool showCommentArrows, bool deviationsEnabled, int deviationChancePercent, DeviationTiming deviationTiming, int weakEnterBelowPercent, int weakExitCleanRuns, int srsNewPerDay, int? srsMaxReviewsPerDay, int dayStartHour, bool startFromBranchPoint, String boardTheme, String pieceSet, bool showCoordinates, bool showLegalMoves, bool highlightLastMove, AnimationSpeed animationSpeed, bool soundsEnabled, int soundVolumePercent, bool hapticsEnabled, int comparableThresholdCp, int checkSearchMs, int? engineThreads, int? engineHashMb, int playOnElo, String? engineVariant, int analysisLines, AppThemeMode themeMode
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wrongMoveMode = null,Object? showLineSummary = null,Object? autoAdvanceDelayMs = null,Object? opponentMoveDelayMs = null,Object? showComments = null,Object? showCommentArrows = null,Object? deviationsEnabled = null,Object? deviationChancePercent = null,Object? deviationTiming = null,Object? weakEnterBelowPercent = null,Object? weakExitCleanRuns = null,Object? srsNewPerDay = null,Object? srsMaxReviewsPerDay = freezed,Object? dayStartHour = null,Object? startFromBranchPoint = null,Object? boardTheme = null,Object? pieceSet = null,Object? showCoordinates = null,Object? showLegalMoves = null,Object? highlightLastMove = null,Object? animationSpeed = null,Object? soundsEnabled = null,Object? soundVolumePercent = null,Object? hapticsEnabled = null,Object? comparableThresholdCp = null,Object? checkSearchMs = null,Object? engineThreads = freezed,Object? engineHashMb = freezed,Object? playOnElo = null,Object? engineVariant = freezed,Object? analysisLines = null,Object? themeMode = null,}) {
  return _then(AppSettings(
wrongMoveMode: null == wrongMoveMode ? _self.wrongMoveMode : wrongMoveMode // ignore: cast_nullable_to_non_nullable
as WrongMoveMode,showLineSummary: null == showLineSummary ? _self.showLineSummary : showLineSummary // ignore: cast_nullable_to_non_nullable
as bool,autoAdvanceDelayMs: null == autoAdvanceDelayMs ? _self.autoAdvanceDelayMs : autoAdvanceDelayMs // ignore: cast_nullable_to_non_nullable
as int,opponentMoveDelayMs: null == opponentMoveDelayMs ? _self.opponentMoveDelayMs : opponentMoveDelayMs // ignore: cast_nullable_to_non_nullable
as int,showComments: null == showComments ? _self.showComments : showComments // ignore: cast_nullable_to_non_nullable
as bool,showCommentArrows: null == showCommentArrows ? _self.showCommentArrows : showCommentArrows // ignore: cast_nullable_to_non_nullable
as bool,deviationsEnabled: null == deviationsEnabled ? _self.deviationsEnabled : deviationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,deviationChancePercent: null == deviationChancePercent ? _self.deviationChancePercent : deviationChancePercent // ignore: cast_nullable_to_non_nullable
as int,deviationTiming: null == deviationTiming ? _self.deviationTiming : deviationTiming // ignore: cast_nullable_to_non_nullable
as DeviationTiming,weakEnterBelowPercent: null == weakEnterBelowPercent ? _self.weakEnterBelowPercent : weakEnterBelowPercent // ignore: cast_nullable_to_non_nullable
as int,weakExitCleanRuns: null == weakExitCleanRuns ? _self.weakExitCleanRuns : weakExitCleanRuns // ignore: cast_nullable_to_non_nullable
as int,srsNewPerDay: null == srsNewPerDay ? _self.srsNewPerDay : srsNewPerDay // ignore: cast_nullable_to_non_nullable
as int,srsMaxReviewsPerDay: freezed == srsMaxReviewsPerDay ? _self.srsMaxReviewsPerDay : srsMaxReviewsPerDay // ignore: cast_nullable_to_non_nullable
as int?,dayStartHour: null == dayStartHour ? _self.dayStartHour : dayStartHour // ignore: cast_nullable_to_non_nullable
as int,startFromBranchPoint: null == startFromBranchPoint ? _self.startFromBranchPoint : startFromBranchPoint // ignore: cast_nullable_to_non_nullable
as bool,boardTheme: null == boardTheme ? _self.boardTheme : boardTheme // ignore: cast_nullable_to_non_nullable
as String,pieceSet: null == pieceSet ? _self.pieceSet : pieceSet // ignore: cast_nullable_to_non_nullable
as String,showCoordinates: null == showCoordinates ? _self.showCoordinates : showCoordinates // ignore: cast_nullable_to_non_nullable
as bool,showLegalMoves: null == showLegalMoves ? _self.showLegalMoves : showLegalMoves // ignore: cast_nullable_to_non_nullable
as bool,highlightLastMove: null == highlightLastMove ? _self.highlightLastMove : highlightLastMove // ignore: cast_nullable_to_non_nullable
as bool,animationSpeed: null == animationSpeed ? _self.animationSpeed : animationSpeed // ignore: cast_nullable_to_non_nullable
as AnimationSpeed,soundsEnabled: null == soundsEnabled ? _self.soundsEnabled : soundsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundVolumePercent: null == soundVolumePercent ? _self.soundVolumePercent : soundVolumePercent // ignore: cast_nullable_to_non_nullable
as int,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,comparableThresholdCp: null == comparableThresholdCp ? _self.comparableThresholdCp : comparableThresholdCp // ignore: cast_nullable_to_non_nullable
as int,checkSearchMs: null == checkSearchMs ? _self.checkSearchMs : checkSearchMs // ignore: cast_nullable_to_non_nullable
as int,engineThreads: freezed == engineThreads ? _self.engineThreads : engineThreads // ignore: cast_nullable_to_non_nullable
as int?,engineHashMb: freezed == engineHashMb ? _self.engineHashMb : engineHashMb // ignore: cast_nullable_to_non_nullable
as int?,playOnElo: null == playOnElo ? _self.playOnElo : playOnElo // ignore: cast_nullable_to_non_nullable
as int,engineVariant: freezed == engineVariant ? _self.engineVariant : engineVariant // ignore: cast_nullable_to_non_nullable
as String?,analysisLines: null == analysisLines ? _self.analysisLines : analysisLines // ignore: cast_nullable_to_non_nullable
as int,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WrongMoveMode wrongMoveMode,  bool showLineSummary,  int autoAdvanceDelayMs,  int opponentMoveDelayMs,  bool showComments,  bool showCommentArrows,  bool deviationsEnabled,  int deviationChancePercent,  DeviationTiming deviationTiming,  int weakEnterBelowPercent,  int weakExitCleanRuns,  int srsNewPerDay,  int? srsMaxReviewsPerDay,  int dayStartHour,  bool startFromBranchPoint,  String boardTheme,  String pieceSet,  bool showCoordinates,  bool showLegalMoves,  bool highlightLastMove,  AnimationSpeed animationSpeed,  bool soundsEnabled,  int soundVolumePercent,  bool hapticsEnabled,  int comparableThresholdCp,  int checkSearchMs,  int? engineThreads,  int? engineHashMb,  int playOnElo,  String? engineVariant,  int analysisLines,  AppThemeMode themeMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.wrongMoveMode,_that.showLineSummary,_that.autoAdvanceDelayMs,_that.opponentMoveDelayMs,_that.showComments,_that.showCommentArrows,_that.deviationsEnabled,_that.deviationChancePercent,_that.deviationTiming,_that.weakEnterBelowPercent,_that.weakExitCleanRuns,_that.srsNewPerDay,_that.srsMaxReviewsPerDay,_that.dayStartHour,_that.startFromBranchPoint,_that.boardTheme,_that.pieceSet,_that.showCoordinates,_that.showLegalMoves,_that.highlightLastMove,_that.animationSpeed,_that.soundsEnabled,_that.soundVolumePercent,_that.hapticsEnabled,_that.comparableThresholdCp,_that.checkSearchMs,_that.engineThreads,_that.engineHashMb,_that.playOnElo,_that.engineVariant,_that.analysisLines,_that.themeMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WrongMoveMode wrongMoveMode,  bool showLineSummary,  int autoAdvanceDelayMs,  int opponentMoveDelayMs,  bool showComments,  bool showCommentArrows,  bool deviationsEnabled,  int deviationChancePercent,  DeviationTiming deviationTiming,  int weakEnterBelowPercent,  int weakExitCleanRuns,  int srsNewPerDay,  int? srsMaxReviewsPerDay,  int dayStartHour,  bool startFromBranchPoint,  String boardTheme,  String pieceSet,  bool showCoordinates,  bool showLegalMoves,  bool highlightLastMove,  AnimationSpeed animationSpeed,  bool soundsEnabled,  int soundVolumePercent,  bool hapticsEnabled,  int comparableThresholdCp,  int checkSearchMs,  int? engineThreads,  int? engineHashMb,  int playOnElo,  String? engineVariant,  int analysisLines,  AppThemeMode themeMode)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.wrongMoveMode,_that.showLineSummary,_that.autoAdvanceDelayMs,_that.opponentMoveDelayMs,_that.showComments,_that.showCommentArrows,_that.deviationsEnabled,_that.deviationChancePercent,_that.deviationTiming,_that.weakEnterBelowPercent,_that.weakExitCleanRuns,_that.srsNewPerDay,_that.srsMaxReviewsPerDay,_that.dayStartHour,_that.startFromBranchPoint,_that.boardTheme,_that.pieceSet,_that.showCoordinates,_that.showLegalMoves,_that.highlightLastMove,_that.animationSpeed,_that.soundsEnabled,_that.soundVolumePercent,_that.hapticsEnabled,_that.comparableThresholdCp,_that.checkSearchMs,_that.engineThreads,_that.engineHashMb,_that.playOnElo,_that.engineVariant,_that.analysisLines,_that.themeMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WrongMoveMode wrongMoveMode,  bool showLineSummary,  int autoAdvanceDelayMs,  int opponentMoveDelayMs,  bool showComments,  bool showCommentArrows,  bool deviationsEnabled,  int deviationChancePercent,  DeviationTiming deviationTiming,  int weakEnterBelowPercent,  int weakExitCleanRuns,  int srsNewPerDay,  int? srsMaxReviewsPerDay,  int dayStartHour,  bool startFromBranchPoint,  String boardTheme,  String pieceSet,  bool showCoordinates,  bool showLegalMoves,  bool highlightLastMove,  AnimationSpeed animationSpeed,  bool soundsEnabled,  int soundVolumePercent,  bool hapticsEnabled,  int comparableThresholdCp,  int checkSearchMs,  int? engineThreads,  int? engineHashMb,  int playOnElo,  String? engineVariant,  int analysisLines,  AppThemeMode themeMode)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.wrongMoveMode,_that.showLineSummary,_that.autoAdvanceDelayMs,_that.opponentMoveDelayMs,_that.showComments,_that.showCommentArrows,_that.deviationsEnabled,_that.deviationChancePercent,_that.deviationTiming,_that.weakEnterBelowPercent,_that.weakExitCleanRuns,_that.srsNewPerDay,_that.srsMaxReviewsPerDay,_that.dayStartHour,_that.startFromBranchPoint,_that.boardTheme,_that.pieceSet,_that.showCoordinates,_that.showLegalMoves,_that.highlightLastMove,_that.animationSpeed,_that.soundsEnabled,_that.soundVolumePercent,_that.hapticsEnabled,_that.comparableThresholdCp,_that.checkSearchMs,_that.engineThreads,_that.engineHashMb,_that.playOnElo,_that.engineVariant,_that.analysisLines,_that.themeMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings extends AppSettings {
  const _AppSettings({this.wrongMoveMode = WrongMoveMode.retry, this.showLineSummary = false, this.autoAdvanceDelayMs = 1500, this.opponentMoveDelayMs = 250, this.showComments = true, this.showCommentArrows = true, this.deviationsEnabled = false, this.deviationChancePercent = 25, this.deviationTiming = DeviationTiming.endOfLine, this.weakEnterBelowPercent = 80, this.weakExitCleanRuns = defaultWeakExitCleanRuns, this.srsNewPerDay = defaultSrsNewPerDay, this.srsMaxReviewsPerDay, this.dayStartHour = defaultDayStartHour, this.startFromBranchPoint = false, this.boardTheme = 'brown', this.pieceSet = 'cburnett', this.showCoordinates = true, this.showLegalMoves = true, this.highlightLastMove = true, this.animationSpeed = AnimationSpeed.normal, this.soundsEnabled = true, this.soundVolumePercent = 80, this.hapticsEnabled = true, this.comparableThresholdCp = defaultComparableThresholdCp, this.checkSearchMs = 1000, this.engineThreads, this.engineHashMb, this.playOnElo = 2500, this.engineVariant, this.analysisLines = 1, this.themeMode = AppThemeMode.dark}): super._();
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  WrongMoveMode wrongMoveMode;
@override@JsonKey() final  bool showLineSummary;
@override@JsonKey() final  int autoAdvanceDelayMs;
@override@JsonKey() final  int opponentMoveDelayMs;
@override@JsonKey() final  bool showComments;
@override@JsonKey() final  bool showCommentArrows;
@override@JsonKey() final  bool deviationsEnabled;
@override@JsonKey() final  int deviationChancePercent;
@override@JsonKey() final  DeviationTiming deviationTiming;
@override@JsonKey() final  int weakEnterBelowPercent;
@override@JsonKey() final  int weakExitCleanRuns;
@override@JsonKey() final  int srsNewPerDay;
/// Null = unlimited.
@override final  int? srsMaxReviewsPerDay;
@override@JsonKey() final  int dayStartHour;
/// Drills start at the line's branch point instead of move 1 (the
/// default for the mode sheet, 01-product-spec §7.1).
@override@JsonKey() final  bool startFromBranchPoint;
@override@JsonKey() final  String boardTheme;
@override@JsonKey() final  String pieceSet;
@override@JsonKey() final  bool showCoordinates;
@override@JsonKey() final  bool showLegalMoves;
@override@JsonKey() final  bool highlightLastMove;
@override@JsonKey() final  AnimationSpeed animationSpeed;
@override@JsonKey() final  bool soundsEnabled;
@override@JsonKey() final  int soundVolumePercent;
@override@JsonKey() final  bool hapticsEnabled;
@override@JsonKey() final  int comparableThresholdCp;
@override@JsonKey() final  int checkSearchMs;
/// Null = auto (docs/plan/05-engine.md §3).
@override final  int? engineThreads;
/// Null = auto.
@override final  int? engineHashMb;
/// UCI_Elo for play-on (1500, 2000, 2500); 0 = full strength.
@override@JsonKey() final  int playOnElo;
/// Windows: the engine variant that answered (avx2 / sse41), if known.
@override final  String? engineVariant;
/// Number of lines in Browse analysis (01-product-spec §9).
@override@JsonKey() final  int analysisLines;
@override@JsonKey() final  AppThemeMode themeMode;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.wrongMoveMode, wrongMoveMode) || other.wrongMoveMode == wrongMoveMode)&&(identical(other.showLineSummary, showLineSummary) || other.showLineSummary == showLineSummary)&&(identical(other.autoAdvanceDelayMs, autoAdvanceDelayMs) || other.autoAdvanceDelayMs == autoAdvanceDelayMs)&&(identical(other.opponentMoveDelayMs, opponentMoveDelayMs) || other.opponentMoveDelayMs == opponentMoveDelayMs)&&(identical(other.showComments, showComments) || other.showComments == showComments)&&(identical(other.showCommentArrows, showCommentArrows) || other.showCommentArrows == showCommentArrows)&&(identical(other.deviationsEnabled, deviationsEnabled) || other.deviationsEnabled == deviationsEnabled)&&(identical(other.deviationChancePercent, deviationChancePercent) || other.deviationChancePercent == deviationChancePercent)&&(identical(other.deviationTiming, deviationTiming) || other.deviationTiming == deviationTiming)&&(identical(other.weakEnterBelowPercent, weakEnterBelowPercent) || other.weakEnterBelowPercent == weakEnterBelowPercent)&&(identical(other.weakExitCleanRuns, weakExitCleanRuns) || other.weakExitCleanRuns == weakExitCleanRuns)&&(identical(other.srsNewPerDay, srsNewPerDay) || other.srsNewPerDay == srsNewPerDay)&&(identical(other.srsMaxReviewsPerDay, srsMaxReviewsPerDay) || other.srsMaxReviewsPerDay == srsMaxReviewsPerDay)&&(identical(other.dayStartHour, dayStartHour) || other.dayStartHour == dayStartHour)&&(identical(other.startFromBranchPoint, startFromBranchPoint) || other.startFromBranchPoint == startFromBranchPoint)&&(identical(other.boardTheme, boardTheme) || other.boardTheme == boardTheme)&&(identical(other.pieceSet, pieceSet) || other.pieceSet == pieceSet)&&(identical(other.showCoordinates, showCoordinates) || other.showCoordinates == showCoordinates)&&(identical(other.showLegalMoves, showLegalMoves) || other.showLegalMoves == showLegalMoves)&&(identical(other.highlightLastMove, highlightLastMove) || other.highlightLastMove == highlightLastMove)&&(identical(other.animationSpeed, animationSpeed) || other.animationSpeed == animationSpeed)&&(identical(other.soundsEnabled, soundsEnabled) || other.soundsEnabled == soundsEnabled)&&(identical(other.soundVolumePercent, soundVolumePercent) || other.soundVolumePercent == soundVolumePercent)&&(identical(other.hapticsEnabled, hapticsEnabled) || other.hapticsEnabled == hapticsEnabled)&&(identical(other.comparableThresholdCp, comparableThresholdCp) || other.comparableThresholdCp == comparableThresholdCp)&&(identical(other.checkSearchMs, checkSearchMs) || other.checkSearchMs == checkSearchMs)&&(identical(other.engineThreads, engineThreads) || other.engineThreads == engineThreads)&&(identical(other.engineHashMb, engineHashMb) || other.engineHashMb == engineHashMb)&&(identical(other.playOnElo, playOnElo) || other.playOnElo == playOnElo)&&(identical(other.engineVariant, engineVariant) || other.engineVariant == engineVariant)&&(identical(other.analysisLines, analysisLines) || other.analysisLines == analysisLines)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,wrongMoveMode,showLineSummary,autoAdvanceDelayMs,opponentMoveDelayMs,showComments,showCommentArrows,deviationsEnabled,deviationChancePercent,deviationTiming,weakEnterBelowPercent,weakExitCleanRuns,srsNewPerDay,srsMaxReviewsPerDay,dayStartHour,startFromBranchPoint,boardTheme,pieceSet,showCoordinates,showLegalMoves,highlightLastMove,animationSpeed,soundsEnabled,soundVolumePercent,hapticsEnabled,comparableThresholdCp,checkSearchMs,engineThreads,engineHashMb,playOnElo,engineVariant,analysisLines,themeMode]);
}

@override
String toString() {
    return 'AppSettings(wrongMoveMode: $wrongMoveMode, showLineSummary: $showLineSummary, autoAdvanceDelayMs: $autoAdvanceDelayMs, opponentMoveDelayMs: $opponentMoveDelayMs, showComments: $showComments, showCommentArrows: $showCommentArrows, deviationsEnabled: $deviationsEnabled, deviationChancePercent: $deviationChancePercent, deviationTiming: $deviationTiming, weakEnterBelowPercent: $weakEnterBelowPercent, weakExitCleanRuns: $weakExitCleanRuns, srsNewPerDay: $srsNewPerDay, srsMaxReviewsPerDay: $srsMaxReviewsPerDay, dayStartHour: $dayStartHour, startFromBranchPoint: $startFromBranchPoint, boardTheme: $boardTheme, pieceSet: $pieceSet, showCoordinates: $showCoordinates, showLegalMoves: $showLegalMoves, highlightLastMove: $highlightLastMove, animationSpeed: $animationSpeed, soundsEnabled: $soundsEnabled, soundVolumePercent: $soundVolumePercent, hapticsEnabled: $hapticsEnabled, comparableThresholdCp: $comparableThresholdCp, checkSearchMs: $checkSearchMs, engineThreads: $engineThreads, engineHashMb: $engineHashMb, playOnElo: $playOnElo, engineVariant: $engineVariant, analysisLines: $analysisLines, themeMode: $themeMode)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 WrongMoveMode wrongMoveMode, bool showLineSummary, int autoAdvanceDelayMs, int opponentMoveDelayMs, bool showComments, bool showCommentArrows, bool deviationsEnabled, int deviationChancePercent, DeviationTiming deviationTiming, int weakEnterBelowPercent, int weakExitCleanRuns, int srsNewPerDay, int? srsMaxReviewsPerDay, int dayStartHour, bool startFromBranchPoint, String boardTheme, String pieceSet, bool showCoordinates, bool showLegalMoves, bool highlightLastMove, AnimationSpeed animationSpeed, bool soundsEnabled, int soundVolumePercent, bool hapticsEnabled, int comparableThresholdCp, int checkSearchMs, int? engineThreads, int? engineHashMb, int playOnElo, String? engineVariant, int analysisLines, AppThemeMode themeMode
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wrongMoveMode = null,Object? showLineSummary = null,Object? autoAdvanceDelayMs = null,Object? opponentMoveDelayMs = null,Object? showComments = null,Object? showCommentArrows = null,Object? deviationsEnabled = null,Object? deviationChancePercent = null,Object? deviationTiming = null,Object? weakEnterBelowPercent = null,Object? weakExitCleanRuns = null,Object? srsNewPerDay = null,Object? srsMaxReviewsPerDay = freezed,Object? dayStartHour = null,Object? startFromBranchPoint = null,Object? boardTheme = null,Object? pieceSet = null,Object? showCoordinates = null,Object? showLegalMoves = null,Object? highlightLastMove = null,Object? animationSpeed = null,Object? soundsEnabled = null,Object? soundVolumePercent = null,Object? hapticsEnabled = null,Object? comparableThresholdCp = null,Object? checkSearchMs = null,Object? engineThreads = freezed,Object? engineHashMb = freezed,Object? playOnElo = null,Object? engineVariant = freezed,Object? analysisLines = null,Object? themeMode = null,}) {
  return _then(_AppSettings(
wrongMoveMode: null == wrongMoveMode ? _self.wrongMoveMode : wrongMoveMode // ignore: cast_nullable_to_non_nullable
as WrongMoveMode,showLineSummary: null == showLineSummary ? _self.showLineSummary : showLineSummary // ignore: cast_nullable_to_non_nullable
as bool,autoAdvanceDelayMs: null == autoAdvanceDelayMs ? _self.autoAdvanceDelayMs : autoAdvanceDelayMs // ignore: cast_nullable_to_non_nullable
as int,opponentMoveDelayMs: null == opponentMoveDelayMs ? _self.opponentMoveDelayMs : opponentMoveDelayMs // ignore: cast_nullable_to_non_nullable
as int,showComments: null == showComments ? _self.showComments : showComments // ignore: cast_nullable_to_non_nullable
as bool,showCommentArrows: null == showCommentArrows ? _self.showCommentArrows : showCommentArrows // ignore: cast_nullable_to_non_nullable
as bool,deviationsEnabled: null == deviationsEnabled ? _self.deviationsEnabled : deviationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,deviationChancePercent: null == deviationChancePercent ? _self.deviationChancePercent : deviationChancePercent // ignore: cast_nullable_to_non_nullable
as int,deviationTiming: null == deviationTiming ? _self.deviationTiming : deviationTiming // ignore: cast_nullable_to_non_nullable
as DeviationTiming,weakEnterBelowPercent: null == weakEnterBelowPercent ? _self.weakEnterBelowPercent : weakEnterBelowPercent // ignore: cast_nullable_to_non_nullable
as int,weakExitCleanRuns: null == weakExitCleanRuns ? _self.weakExitCleanRuns : weakExitCleanRuns // ignore: cast_nullable_to_non_nullable
as int,srsNewPerDay: null == srsNewPerDay ? _self.srsNewPerDay : srsNewPerDay // ignore: cast_nullable_to_non_nullable
as int,srsMaxReviewsPerDay: freezed == srsMaxReviewsPerDay ? _self.srsMaxReviewsPerDay : srsMaxReviewsPerDay // ignore: cast_nullable_to_non_nullable
as int?,dayStartHour: null == dayStartHour ? _self.dayStartHour : dayStartHour // ignore: cast_nullable_to_non_nullable
as int,startFromBranchPoint: null == startFromBranchPoint ? _self.startFromBranchPoint : startFromBranchPoint // ignore: cast_nullable_to_non_nullable
as bool,boardTheme: null == boardTheme ? _self.boardTheme : boardTheme // ignore: cast_nullable_to_non_nullable
as String,pieceSet: null == pieceSet ? _self.pieceSet : pieceSet // ignore: cast_nullable_to_non_nullable
as String,showCoordinates: null == showCoordinates ? _self.showCoordinates : showCoordinates // ignore: cast_nullable_to_non_nullable
as bool,showLegalMoves: null == showLegalMoves ? _self.showLegalMoves : showLegalMoves // ignore: cast_nullable_to_non_nullable
as bool,highlightLastMove: null == highlightLastMove ? _self.highlightLastMove : highlightLastMove // ignore: cast_nullable_to_non_nullable
as bool,animationSpeed: null == animationSpeed ? _self.animationSpeed : animationSpeed // ignore: cast_nullable_to_non_nullable
as AnimationSpeed,soundsEnabled: null == soundsEnabled ? _self.soundsEnabled : soundsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundVolumePercent: null == soundVolumePercent ? _self.soundVolumePercent : soundVolumePercent // ignore: cast_nullable_to_non_nullable
as int,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,comparableThresholdCp: null == comparableThresholdCp ? _self.comparableThresholdCp : comparableThresholdCp // ignore: cast_nullable_to_non_nullable
as int,checkSearchMs: null == checkSearchMs ? _self.checkSearchMs : checkSearchMs // ignore: cast_nullable_to_non_nullable
as int,engineThreads: freezed == engineThreads ? _self.engineThreads : engineThreads // ignore: cast_nullable_to_non_nullable
as int?,engineHashMb: freezed == engineHashMb ? _self.engineHashMb : engineHashMb // ignore: cast_nullable_to_non_nullable
as int?,playOnElo: null == playOnElo ? _self.playOnElo : playOnElo // ignore: cast_nullable_to_non_nullable
as int,engineVariant: freezed == engineVariant ? _self.engineVariant : engineVariant // ignore: cast_nullable_to_non_nullable
as String?,analysisLines: null == analysisLines ? _self.analysisLines : analysisLines // ignore: cast_nullable_to_non_nullable
as int,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,
  ));
}


}

// dart format on
