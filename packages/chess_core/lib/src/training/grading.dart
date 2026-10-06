import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:meta/meta.dart';

/// Result of the engine's comparable check for a wrong first attempt
/// (docs/plan/04-algorithms.md §7.1), as plain data.
@immutable
final class ComparableOutcome {
  /// Creates an outcome.
  const new({required this.comparable, required this.status, this.lossCp});

  /// No engine available: not comparable.
  const new unavailable()
    : comparable = false,
      status = CheckStatus.engineUnavailable,
      lossCp = null;

  /// The move loses at most the threshold against the best repertoire move.
  final bool comparable;

  /// Loss against the best repertoire move in centipawns, if known.
  final int? lossCp;

  /// Whether the engine answered.
  final CheckStatus status;
}

/// State machine grading one user ply (docs/plan/04-algorithms.md §1).
///
/// The first event decides: a hint before any attempt is `hint`; a first
/// attempt in [accepted] is `correct` (alternative repertoire moves too);
/// otherwise `wrong` with a comparable check pending. A later hint overrides
/// `wrong`/`comparable`; a comparable check upgrades `wrong` to `comparable`.
final class PlyGradeBuilder {
  /// Starts grading [ply] where [expected] is the move of the chosen line
  /// and [accepted] every repertoire move at the node.
  new({
    required this.ply,
    required this.expected,
    required List<String> accepted,
  }) : accepted = List.unmodifiable(accepted);

  /// The ply being graded.
  final int ply;

  /// UCI of the move on the chosen line.
  final String expected;

  /// UCIs of all repertoire moves at this node.
  final List<String> accepted;

  GradeResult? _result;
  String? _firstAttempt;
  int _attempts = 0;
  int _hintLevel = 0;
  bool _checkPending = false;
  int? _checkCp;
  CheckStatus? _checkStatus;
  bool _frozen = false;

  /// The current result, or null before the first event.
  GradeResult? get result => _result;

  /// True once the first attempt or hint happened.
  bool get hasFirstEvent => _result != null;

  /// True while a comparable check for the first attempt is outstanding.
  bool get checkPending => _checkPending;

  /// The first attempt's UCI when it needs a comparable check.
  String? get moveToCheck => _checkPending ? _firstAttempt : null;

  /// After a restart (Restart mode) a graded ply keeps its grade: attempts
  /// and hints no longer change it (D-08). Comparable checks still apply.
  void freeze() => _frozen = _result != null;

  /// Records an attempt; returns true if [uci] is a repertoire move.
  bool attempt(String uci) {
    final ok = accepted.contains(uci);
    if (_frozen) return ok;
    _attempts++;
    if (_result == null) {
      _firstAttempt = uci;
      if (ok) {
        _result = GradeResult.correct;
      } else {
        _result = GradeResult.wrong;
        _checkPending = true;
      }
    }
    return ok;
  }

  /// Records a hint of [level] (1 or 2).
  void hint(int level) {
    if (_frozen) return;
    if (level > _hintLevel) _hintLevel = level;
    if (_result != GradeResult.correct) _result = GradeResult.hint;
  }

  /// Applies the comparable check of the first attempt. Ignored when no
  /// check is pending (e.g. it already timed out).
  void applyCheck(ComparableOutcome outcome) {
    if (!_checkPending) return;
    _checkPending = false;
    _checkCp = outcome.lossCp;
    _checkStatus = outcome.status;
    if (_result == GradeResult.wrong && outcome.comparable) {
      _result = GradeResult.comparable;
    }
  }

  /// Gives up on a pending check: it is recorded as `timeout`.
  void timeOutCheck() {
    if (!_checkPending) return;
    _checkPending = false;
    _checkStatus = CheckStatus.timeout;
  }

  /// The grade so far. Throws [StateError] before the first event.
  MoveGrade build() {
    final result = _result;
    if (result == null) throw StateError('ply $ply has no attempt or hint');
    return MoveGrade(
      ply: ply,
      expected: expected,
      accepted: accepted.join(' '),
      firstAttempt: _firstAttempt,
      result: result,
      credit: switch (result) {
        GradeResult.correct => creditCorrect,
        GradeResult.comparable => creditComparable,
        GradeResult.wrong || GradeResult.hint => 0,
      },
      attempts: _attempts,
      hintLevel: _hintLevel,
      checkCp: _checkCp,
      checkStatus: _checkStatus,
    );
  }
}

/// Accumulates the grades of a run and produces the immutable [RunRecord]
/// (docs/plan/04-algorithms.md §1).
final class RunBuilder {
  /// Starts a run.
  new({
    required this.id,
    required this.repertoireId,
    required this._lineKey,
    required this._ucis,
    required this.mode,
    required this.startPly,
    required this.wrongMoveMode,
    required this.startedAt,
    required this.deviceId,
  });

  /// Run id.
  final String id;

  /// Repertoire id.
  final String repertoireId;

  /// Training mode.
  final RunMode mode;

  /// First ply played by the drill (0 or the branch ply).
  final int startPly;

  /// Retry or restart on wrong moves.
  final WrongMoveMode wrongMoveMode;

  /// Start time, UTC milliseconds.
  final int startedAt;

  /// Device that ran it.
  final String deviceId;

  String _lineKey;
  String _ucis;
  bool _deviated = false;
  DeviationEvent? _deviation;
  RunRecord? _finished;
  final Map<int, PlyGradeBuilder> _plies = {};

  /// The line currently being played (changes on a branch switch).
  String get lineKey => _lineKey;

  /// UCI sequence of the current line.
  String get ucis => _ucis;

  /// True once [finish] was called.
  bool get isFinished => _finished != null;

  /// The builder for [ply], created on first use. Plies at or before
  /// [startPly] are not graded and throw [ArgumentError].
  PlyGradeBuilder ply(
    int ply, {
    required String expected,
    required List<String> accepted,
  }) {
    if (ply <= startPly) {
      throw ArgumentError.value(ply, 'ply', 'not after start ply $startPly');
    }
    return _plies.putIfAbsent(
      ply,
      () => PlyGradeBuilder(ply: ply, expected: expected, accepted: accepted),
    );
  }

  /// The grading of [ply] so far, or null if nothing happened at it
  /// (read-only: unlike [ply] it never creates a builder).
  PlyGradeBuilder? gradeAt(int ply) => _plies[ply];

  /// Grades of the plies with an attempt or hint so far, by ply (pending
  /// checks count as wrong until they resolve).
  List<MoveGrade> get grades => [
    for (final p in _plies.values)
      if (p.hasFirstEvent) p.build(),
  ]..sort((a, b) => a.ply.compareTo(b.ply));

  /// The user switched to another repertoire line (alternative move).
  void switchLine({required String lineKey, required String ucis}) {
    _lineKey = lineKey;
    _ucis = ucis;
  }

  /// Restart mode: the line restarts; already graded plies keep their
  /// grades (D-08).
  void restart() {
    for (final p in _plies.values) {
      p.freeze();
    }
  }

  /// Applies a comparable check result to [ply]; returns false when it came
  /// too late (run finished) or the ply has no pending check.
  bool applyCheck(int ply, ComparableOutcome outcome) {
    if (_finished != null) return false;
    final p = _plies[ply];
    if (p == null || !p.checkPending) return false;
    p.applyCheck(outcome);
    return true;
  }

  /// Plies whose comparable check is still outstanding.
  List<int> get pendingChecks => [
    for (final p in _plies.values)
      if (p.checkPending) p.ply,
  ];

  /// Records an opponent deviation; [midLine] marks the run as deviated
  /// (the line was not played to its end).
  void recordDeviation(DeviationEvent event, {required bool midLine}) {
    _deviation = event;
    if (midLine) _deviated = true;
  }

  /// Finishes the run. Pending checks become `timeout` with no credit;
  /// checks arriving afterwards are ignored. [completed] is false for an
  /// abandoned run. Calling it twice returns the same record.
  RunRecord finish({
    required int finishedAt,
    required String localDay,
    required bool completed,
  }) {
    final done = _finished;
    if (done != null) return done;
    final grades = [
      for (final p in _plies.values)
        if (p.hasFirstEvent) (p..timeOutCheck()).build(),
    ]..sort((a, b) => a.ply.compareTo(b.ply));
    return _finished = RunRecord(
      id: id,
      repertoireId: repertoireId,
      lineKey: _lineKey,
      ucis: _ucis,
      mode: mode,
      startPly: startPly,
      wrongMoveMode: wrongMoveMode,
      startedAt: startedAt,
      finishedAt: finishedAt,
      localDay: localDay,
      completed: completed,
      deviated: _deviated,
      gradedCount: grades.length,
      creditSum: grades.fold(0, (s, g) => s + g.credit),
      hintCount: grades.where((g) => g.hintLevel > 0).length,
      deviceId: deviceId,
      grades: grades,
      deviation: _deviation,
    );
  }
}
