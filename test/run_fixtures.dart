import 'package:chess_core/chess_core.dart';

/// A run on [ucis] (key [key]) with one grade per credit at plies 1, 3, ….
RunRecord fixtureRun(
  String rep, {
  required String id,
  required String key,
  required String ucis,
  required String day,
  required List<double> credits,
  bool completed = true,
  DeviationEvent? deviation,
  int at = 0,
}) => RunRecord(
  id: id,
  repertoireId: rep,
  lineKey: key,
  ucis: ucis,
  mode: RunMode.random,
  startPly: 0,
  wrongMoveMode: WrongMoveMode.retry,
  startedAt: at,
  finishedAt: at + 1,
  localDay: day,
  completed: completed,
  deviated: false,
  gradedCount: credits.length,
  creditSum: credits.fold(0, (a, b) => a + b),
  hintCount: 0,
  deviceId: 'dev',
  grades: [
    for (final (i, c) in credits.indexed)
      MoveGrade(
        ply: 2 * i + 1,
        expected: ucis.split(' ')[2 * i],
        accepted: ucis.split(' ')[2 * i],
        firstAttempt: c == 1 ? ucis.split(' ')[2 * i] : 'a2a3',
        result: c == 1 ? GradeResult.correct : GradeResult.wrong,
        credit: c,
        attempts: c == 1 ? 1 : 2,
        hintLevel: 0,
      ),
  ],
  deviation: deviation,
);
