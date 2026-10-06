import 'package:chess_core/chess_core.dart';

/// A finished run whose grades have the given [credits] (1, 0.5 or 0).
RunRecord makeRun({
  String id = 'r',
  String lineKey = 'L',
  String ucis = 'e2e4',
  RunMode mode = RunMode.random,
  int finishedAt = 0,
  String day = '2026-01-01',
  bool completed = true,
  bool deviated = false,
  List<double> credits = const [1],
}) {
  final grades = [
    for (var i = 0; i < credits.length; i++)
      MoveGrade(
        ply: 2 * i + 1,
        expected: 'e2e4',
        accepted: 'e2e4',
        firstAttempt: credits[i] == 1 ? 'e2e4' : 'd2d4',
        result: switch (credits[i]) {
          1.0 => GradeResult.correct,
          0.5 => GradeResult.comparable,
          _ => GradeResult.wrong,
        },
        credit: credits[i],
        attempts: 1,
        hintLevel: 0,
      ),
  ];
  return RunRecord(
    id: id,
    repertoireId: 'rep',
    lineKey: lineKey,
    ucis: ucis,
    mode: mode,
    startPly: 0,
    wrongMoveMode: WrongMoveMode.retry,
    startedAt: finishedAt - 1000,
    finishedAt: finishedAt,
    localDay: day,
    completed: completed,
    deviated: deviated,
    gradedCount: grades.length,
    creditSum: credits.fold(0, (s, c) => s + c),
    hintCount: 0,
    deviceId: 'dev',
    grades: grades,
  );
}

/// A run with [graded] moves and a total [creditSum] (for accuracy maths).
RunRecord scoredRun({
  required double creditSum,
  int graded = 10,
  String id = 'r',
  String lineKey = 'L',
  String ucis = 'e2e4',
  RunMode mode = RunMode.random,
  int finishedAt = 0,
  String day = '2026-01-01',
  bool completed = true,
  bool deviated = false,
}) {
  final full = creditSum.floor();
  final half = creditSum - full >= 0.5;
  final credits = <double>[
    for (var i = 0; i < graded; i++)
      if (i < full) 1 else if (i == full && half) 0.5 else 0,
  ];
  return makeRun(
    id: id,
    lineKey: lineKey,
    ucis: ucis,
    mode: mode,
    finishedAt: finishedAt,
    day: day,
    completed: completed,
    deviated: deviated,
    credits: credits,
  );
}
