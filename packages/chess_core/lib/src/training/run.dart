import 'package:chess_core/src/training/constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run.freezed.dart';
part 'run.g.dart';

/// Training mode of a run.
enum RunMode {
  /// Weighted random line.
  random,

  /// Weak-pool lines only.
  weak,

  /// Spaced repetition.
  srs,

  /// One chosen line.
  single,
}

/// What happens after a wrong move.
enum WrongMoveMode {
  /// Try again at the same position.
  retry,

  /// Restart the line from the start ply.
  restart,
}

/// Outcome of one graded user move.
enum GradeResult {
  /// First attempt was a repertoire move.
  correct,

  /// First attempt was not in the repertoire but the engine judged it
  /// comparable (half credit).
  comparable,

  /// First attempt was wrong.
  wrong,

  /// A hint was used.
  hint,
}

/// Status of the engine check of a wrong first attempt.
@JsonEnum(fieldRename: FieldRename.snake)
enum CheckStatus {
  /// The engine answered.
  ok,

  /// The run finished before the engine answered.
  timeout,

  /// No engine was available.
  engineUnavailable,
}

/// One immutable training run (docs/plan/03-data-model.md §2.4,
/// docs/plan/06-sync.md §2).
@freezed
abstract class RunRecord with _$RunRecord {
  /// Creates a run.
  const factory({
    required String id,
    required String repertoireId,
    required String lineKey,
    required String ucis,
    required RunMode mode,
    required int startPly,
    required WrongMoveMode wrongMoveMode,
    required int startedAt,
    required int finishedAt,
    required String localDay,
    required bool completed,
    required bool deviated,
    required int gradedCount,
    required double creditSum,
    required int hintCount,
    required String deviceId,
    @Default(1) int schema,
    @Default(<MoveGrade>[]) List<MoveGrade> grades,
    DeviationEvent? deviation,
  }) = _RunRecord;

  /// Parses the sync JSON form.
  factory fromJson(Map<String, dynamic> json) => _$RunRecordFromJson(json);

  const new _();

  /// Run accuracy (credit per graded move), or null with no graded moves.
  double? get accuracy => gradedCount == 0 ? null : creditSum / gradedCount;

  /// Counts for accuracy, weak pool and streak (abandoned and empty runs do
  /// not; docs/plan/04-algorithms.md §2.1).
  bool get isEligible => completed && gradedCount > 0;

  /// Every graded move got full credit.
  bool get allPerfect =>
      grades.isNotEmpty && grades.every((g) => g.credit == creditCorrect);
}

/// The grade of one user move in a run (03 §2.5).
@freezed
abstract class MoveGrade with _$MoveGrade {
  /// Creates a grade.
  const factory({
    required int ply,
    required String expected,
    required String accepted,
    required String? firstAttempt,
    required GradeResult result,
    required double credit,
    required int attempts,
    required int hintLevel,
    int? checkCp,
    CheckStatus? checkStatus,
  }) = _MoveGrade;

  /// Parses the sync JSON form.
  factory fromJson(Map<String, dynamic> json) => _$MoveGradeFromJson(json);
}

/// An opponent deviation and the user's reply (03 §2.6).
@freezed
abstract class DeviationEvent with _$DeviationEvent {
  /// Creates an event.
  const factory({
    required int ply,
    required String bestUci,
    required bool passed,
    String? deviationUci,
    String? replyUci,
    int? lossCp,
  }) = _DeviationEvent;

  /// Parses the sync JSON form.
  factory fromJson(Map<String, dynamic> json) => _$DeviationEventFromJson(json);
}
