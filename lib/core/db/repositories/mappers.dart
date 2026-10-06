import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:drift/drift.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

// Conversions between chess_core models and drift rows.

/// `'w'` / `'b'`.
String sideToDb(Side side) => side == Side.white ? 'w' : 'b';

/// Parses `'w'` / `'b'`.
Side sideFromDb(String color) => switch (color) {
  'w' => Side.white,
  'b' => Side.black,
  _ => throw FormatException('bad colour $color'),
};

/// The lines of [tree] for training logic.
List<LineRef> lineRefsOf(RepertoireTree tree) => [
  for (final l in tree.lines)
    LineRef(
      key: l.key,
      ucis: l.ucis,
      ordinal: l.ordinal,
      userMoveCount: l.userMoveCount,
    ),
];

/// A `nodes` insert.
NodesCompanion nodeCompanion(String repertoireId, NodeRow n) =>
    NodesCompanion.insert(
      repertoireId: repertoireId,
      nodeId: n.nodeId,
      parentId: Value(n.parentId),
      ply: n.ply,
      san: Value(n.san),
      uci: Value(n.uci),
      fen: n.fen,
      isUserMove: n.isUserMove,
      childIndex: n.childIndex,
      why: Value(n.why),
      plan: Value(n.plan),
      watch: Value(n.watch),
      alt: Value(n.alt),
      shapes: Value(n.shapesJson),
      rawComment: Value(n.rawComment),
      nags: Value(n.nagsText),
    );

/// A `nodes` row as a chess_core [NodeRow].
NodeRow nodeRowOf(DbNode n) => NodeRow(
  nodeId: n.nodeId,
  parentId: n.parentId,
  ply: n.ply,
  san: n.san,
  uci: n.uci,
  fen: n.fen,
  isUserMove: n.isUserMove,
  childIndex: n.childIndex,
  why: n.why,
  plan: n.plan,
  watch: n.watch,
  alt: n.alt,
  shapes: NodeRow.shapesFromJson(n.shapes),
  rawComment: n.rawComment,
  nags: NodeRow.nagsFromText(n.nags),
);

/// A `lines` insert.
LinesCompanion lineCompanion(String repertoireId, LineRow l) =>
    LinesCompanion.insert(
      repertoireId: repertoireId,
      lineKey: l.lineKey,
      leafNodeId: l.leafNodeId,
      ordinal: l.ordinal,
      plies: l.plies,
      userMoveCount: l.userMoveCount,
      branchPly: l.branchPly,
      label: l.label,
      ucis: l.ucis,
    );

/// A `lines` row as a chess_core [LineRow].
LineRow lineRowOf(DbLine l) => LineRow(
  lineKey: l.lineKey,
  leafNodeId: l.leafNodeId,
  ordinal: l.ordinal,
  plies: l.plies,
  userMoveCount: l.userMoveCount,
  branchPly: l.branchPly,
  label: l.label,
  ucis: l.ucis,
);

/// A `line_stats` row for [s].
LineStatsTableCompanion lineStatsCompanion(String repertoireId, LineStats s) =>
    LineStatsTableCompanion.insert(
      repertoireId: repertoireId,
      lineKey: s.lineKey,
      archived: s.archived,
      runCount: s.runCount,
      accuracy: Value(s.accuracy),
      lastPlayedAt: Value(s.lastPlayedAt),
      inWeakPool: s.inWeakPool,
      weakCleanStreak: s.weakCleanStreak,
      srsState: s.srs.phase.dbValue,
      srsReps: s.srs.reps,
      srsEase: s.srs.ease,
      srsIntervalDays: s.srs.intervalDays,
      srsDueDay: Value(s.srs.dueDay),
      srsLapses: s.srs.lapses,
      srsFirstSeenDay: Value(s.srs.firstSeenDay),
    );

/// A `line_stats` row as [LineStats].
LineStats lineStatsOf(DbLineStats r) => LineStats(
  lineKey: r.lineKey,
  archived: r.archived,
  runCount: r.runCount,
  accuracy: r.accuracy,
  lastPlayedAt: r.lastPlayedAt,
  weak: WeakPoolState(inPool: r.inWeakPool, cleanStreak: r.weakCleanStreak),
  srs: SrsState(
    phase: SrsPhase.values.firstWhere((p) => p.dbValue == r.srsState),
    reps: r.srsReps,
    ease: r.srsEase,
    intervalDays: r.srsIntervalDays,
    dueDay: r.srsDueDay,
    lapses: r.srsLapses,
    firstSeenDay: r.srsFirstSeenDay,
  ),
);

/// A `runs` insert (without `syncedAt`).
RunsCompanion runCompanion(RunRecord r, {int? syncedAt}) =>
    RunsCompanion.insert(
      id: r.id,
      repertoireId: r.repertoireId,
      lineKey: r.lineKey,
      ucis: r.ucis,
      mode: r.mode.name,
      startPly: r.startPly,
      wrongMoveMode: r.wrongMoveMode.name,
      startedAt: r.startedAt,
      finishedAt: r.finishedAt,
      localDay: r.localDay,
      completed: r.completed,
      deviated: r.deviated,
      gradedCount: r.gradedCount,
      creditSum: r.creditSum,
      hintCount: r.hintCount,
      deviceId: r.deviceId,
      syncedAt: Value(syncedAt),
      schema: r.schema,
    );

/// A `move_grades` insert.
MoveGradesCompanion gradeCompanion(String runId, MoveGrade g) =>
    MoveGradesCompanion.insert(
      runId: runId,
      ply: g.ply,
      expected: g.expected,
      accepted: g.accepted,
      firstAttempt: Value(g.firstAttempt),
      result: g.result.name,
      credit: g.credit,
      attempts: g.attempts,
      hintLevel: g.hintLevel,
      checkCp: Value(g.checkCp),
      checkStatus: Value(g.checkStatus?.name),
    );

/// A `deviation_events` insert.
DeviationEventsCompanion deviationCompanion(String runId, DeviationEvent d) =>
    DeviationEventsCompanion.insert(
      runId: runId,
      ply: d.ply,
      deviationUci: Value(d.deviationUci),
      replyUci: Value(d.replyUci),
      bestUci: d.bestUci,
      lossCp: Value(d.lossCp),
      passed: d.passed,
    );

/// Rebuilds a [RunRecord] from its rows.
RunRecord runRecordOf(
  DbRun r,
  List<DbMoveGrade> grades,
  DbDeviationEvent? deviation,
) => RunRecord(
  id: r.id,
  repertoireId: r.repertoireId,
  lineKey: r.lineKey,
  ucis: r.ucis,
  mode: RunMode.values.byName(r.mode),
  startPly: r.startPly,
  wrongMoveMode: WrongMoveMode.values.byName(r.wrongMoveMode),
  startedAt: r.startedAt,
  finishedAt: r.finishedAt,
  localDay: r.localDay,
  completed: r.completed,
  deviated: r.deviated,
  gradedCount: r.gradedCount,
  creditSum: r.creditSum,
  hintCount: r.hintCount,
  deviceId: r.deviceId,
  schema: r.schema,
  grades: [
    for (final g in grades)
      MoveGrade(
        ply: g.ply,
        expected: g.expected,
        accepted: g.accepted,
        firstAttempt: g.firstAttempt,
        result: GradeResult.values.byName(g.result),
        credit: g.credit,
        attempts: g.attempts,
        hintLevel: g.hintLevel,
        checkCp: g.checkCp,
        checkStatus: g.checkStatus == null
            ? null
            : CheckStatus.values.byName(g.checkStatus!),
      ),
  ],
  deviation: deviation == null
      ? null
      : DeviationEvent(
          ply: deviation.ply,
          deviationUci: deviation.deviationUci,
          replyUci: deviation.replyUci,
          bestUci: deviation.bestUci,
          lossCp: deviation.lossCp,
          passed: deviation.passed,
        ),
);
