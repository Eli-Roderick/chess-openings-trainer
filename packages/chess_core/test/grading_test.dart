import 'dart:convert';

import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

PlyGradeBuilder ply() =>
    PlyGradeBuilder(ply: 5, expected: 'f1c4', accepted: ['f1c4', 'f1b5']);

const ok = ComparableOutcome(
  comparable: true,
  lossCp: 12,
  status: CheckStatus.ok,
);
const bad = ComparableOutcome(
  comparable: false,
  lossCp: 80,
  status: CheckStatus.ok,
);

RunBuilder builder({
  WrongMoveMode wrongMoveMode = WrongMoveMode.retry,
  int startPly = 0,
}) => RunBuilder(
  id: 'run1',
  repertoireId: 'rep1',
  lineKey: 'k1',
  ucis: 'e2e4 e7e5 g1f3',
  mode: RunMode.random,
  startPly: startPly,
  wrongMoveMode: wrongMoveMode,
  startedAt: 1000,
  deviceId: 'dev1',
);

void main() {
  group('PlyGradeBuilder transitions (§1)', () {
    test('correct first attempt', () {
      final p = ply();
      expect(p.hasFirstEvent, isFalse);
      expect(p.attempt('f1c4'), isTrue);
      final g = p.build();
      expect(g.result, GradeResult.correct);
      expect(g.credit, 1);
      expect(g.firstAttempt, 'f1c4');
      expect(g.attempts, 1);
      expect(g.accepted, 'f1c4 f1b5');
      expect(p.checkPending, isFalse);
    });

    test('an alternative repertoire move is correct', () {
      final p = ply()..attempt('f1b5');
      expect(p.build().result, GradeResult.correct);
      expect(p.build().expected, 'f1c4');
    });

    test('wrong, then comparable check upgrades to half credit', () {
      final p = ply();
      expect(p.attempt('d2d4'), isFalse);
      expect(p.result, GradeResult.wrong);
      expect(p.moveToCheck, 'd2d4');
      p
        ..attempt('f1c4')
        ..applyCheck(ok);
      final g = p.build();
      expect(g.result, GradeResult.comparable);
      expect(g.credit, 0.5);
      expect(g.attempts, 2);
      expect(g.checkCp, 12);
      expect(g.checkStatus, CheckStatus.ok);
      expect(p.moveToCheck, isNull);
    });

    test('wrong and not comparable stays wrong', () {
      final p = ply()
        ..attempt('d2d4')
        ..applyCheck(bad);
      expect(p.build().result, GradeResult.wrong);
      expect(p.build().credit, 0);
      expect(p.build().checkCp, 80);
    });

    test('hint before any attempt', () {
      final p = ply()..hint(1);
      final g = p.build();
      expect(g.result, GradeResult.hint);
      expect(g.firstAttempt, isNull);
      expect(g.hintLevel, 1);
      expect(g.attempts, 0);
      expect(p.checkPending, isFalse);
    });

    test('hint after wrong overrides, and a later comparable check does not '
        'restore credit', () {
      final p = ply()
        ..attempt('d2d4')
        ..hint(2)
        ..applyCheck(ok);
      final g = p.build();
      expect(g.result, GradeResult.hint);
      expect(g.credit, 0);
      expect(g.hintLevel, 2);
      expect(g.checkStatus, CheckStatus.ok);
    });

    test('hint after comparable overrides', () {
      final p = ply()
        ..attempt('d2d4')
        ..applyCheck(ok)
        ..hint(1);
      expect(p.build().result, GradeResult.hint);
    });

    test('hint level only goes up; a correct move is never overridden', () {
      final p = ply()
        ..hint(2)
        ..hint(1);
      expect(p.build().hintLevel, 2);
      final c = ply()
        ..attempt('f1c4')
        ..hint(1);
      expect(c.build().result, GradeResult.correct);
    });

    test('a timed-out check gets status timeout and later results are '
        'ignored', () {
      final p = ply()
        ..attempt('d2d4')
        ..timeOutCheck()
        ..applyCheck(ok);
      expect(p.build().result, GradeResult.wrong);
      expect(p.build().checkStatus, CheckStatus.timeout);
      expect(p.build().checkCp, isNull);
    });

    test('engine unavailable', () {
      final p = ply()
        ..attempt('d2d4')
        ..applyCheck(const ComparableOutcome.unavailable());
      expect(p.build().result, GradeResult.wrong);
      expect(p.build().checkStatus, CheckStatus.engineUnavailable);
    });

    test('build before any event throws', () {
      expect(() => ply().build(), throwsStateError);
    });
  });

  group('RunBuilder', () {
    test('finish computes counts, sorts grades and is idempotent', () {
      final b = builder();
      b.ply(3, expected: 'g1f3', accepted: ['g1f3']).attempt('g1f3');
      b.ply(1, expected: 'e2e4', accepted: ['e2e4']).attempt('d2d4');
      b.ply(5, expected: 'f1c4', accepted: ['f1c4']).hint(1);
      expect(b.pendingChecks, [1]);
      expect(b.applyCheck(1, ok), isTrue);
      final run = b.finish(
        finishedAt: 5000,
        localDay: '2026-10-06',
        completed: true,
      );
      expect([for (final g in run.grades) g.ply], [1, 3, 5]);
      expect(run.gradedCount, 3);
      expect(run.creditSum, 1.5);
      expect(run.hintCount, 1);
      expect(run.accuracy, 0.5);
      expect(run.isEligible, isTrue);
      expect(run.allPerfect, isFalse);
      expect(b.isFinished, isTrue);
      expect(
        b.finish(finishedAt: 9, localDay: 'x', completed: false),
        same(run),
      );
    });

    test('a check arriving after finish is ignored (timeout)', () {
      final b = builder();
      b.ply(1, expected: 'e2e4', accepted: ['e2e4']).attempt('d2d4');
      final run = b.finish(finishedAt: 2, localDay: 'd', completed: true);
      expect(b.applyCheck(1, ok), isFalse);
      expect(run.grades.single.checkStatus, CheckStatus.timeout);
      expect(run.creditSum, 0);
    });

    test('applyCheck for an unknown or settled ply returns false', () {
      final b = builder();
      expect(b.applyCheck(7, ok), isFalse);
      b.ply(1, expected: 'e2e4', accepted: ['e2e4']).attempt('e2e4');
      expect(b.applyCheck(1, ok), isFalse);
    });

    test('restart mode keeps first grades (D-08)', () {
      final b = builder(wrongMoveMode: WrongMoveMode.restart);
      b.ply(1, expected: 'e2e4', accepted: ['e2e4']).attempt('d2d4');
      b.restart();
      final again = b.ply(1, expected: 'e2e4', accepted: ['e2e4']);
      expect(again.attempt('e2e4'), isTrue);
      again.hint(2);
      b.ply(3, expected: 'g1f3', accepted: ['g1f3']).attempt('g1f3');
      // The half credit still applies when the check returns (D-09).
      expect(b.applyCheck(1, ok), isTrue);
      final run = b.finish(finishedAt: 2, localDay: 'd', completed: true);
      final g1 = run.grades.first;
      expect(g1.result, GradeResult.comparable);
      expect(g1.attempts, 1);
      expect(g1.hintLevel, 0);
      expect(run.creditSum, 1.5);
    });

    test('plies at or before the start ply are not graded', () {
      final b = builder(startPly: 4);
      expect(
        () => b.ply(3, expected: 'x', accepted: ['x']),
        throwsArgumentError,
      );
      expect(b.ply(5, expected: 'x', accepted: ['x']).ply, 5);
    });

    test('branch switch, deviation and abandoned run', () {
      final b = builder()..switchLine(lineKey: 'k2', ucis: 'e2e4 c7c5');
      expect(b.lineKey, 'k2');
      expect(b.ucis, 'e2e4 c7c5');
      const event = DeviationEvent(
        ply: 4,
        deviationUci: 'd7d6',
        replyUci: 'd2d4',
        bestUci: 'd2d4',
        lossCp: 0,
        passed: true,
      );
      b.recordDeviation(event, midLine: true);
      final run = b.finish(finishedAt: 2, localDay: 'd', completed: false);
      expect(run.lineKey, 'k2');
      expect(run.deviated, isTrue);
      expect(run.deviation, event);
      expect(run.gradedCount, 0);
      expect(run.accuracy, isNull);
      expect(run.isEligible, isFalse);
      expect(run.allPerfect, isFalse);

      final endOfLine = builder()..recordDeviation(event, midLine: false);
      expect(
        endOfLine
            .finish(finishedAt: 2, localDay: 'd', completed: true)
            .deviated,
        isFalse,
      );
    });
  });

  test('RunRecord JSON matches docs/plan/06-sync.md §2', () {
    final b = builder();
    b.ply(1, expected: 'e2e4', accepted: ['e2e4']).attempt('e2e4');
    b.ply(3, expected: 'g1f3', accepted: ['g1f3']).attempt('b1c3');
    final run = b.finish(
      finishedAt: 7,
      localDay: '2026-10-06',
      completed: true,
    );
    final json = jsonDecode(jsonEncode(run.toJson())) as Map<String, dynamic>;
    expect(json.keys.toSet(), {
      'id', 'repertoireId', 'lineKey', 'ucis', 'mode', 'startPly', //
      'wrongMoveMode', 'startedAt', 'finishedAt', 'localDay', 'completed',
      'deviated', 'gradedCount', 'creditSum', 'hintCount', 'deviceId',
      'schema', 'grades', 'deviation',
    });
    expect(json['mode'], 'random');
    expect(json['wrongMoveMode'], 'retry');
    expect(json['schema'], 1);
    expect(json['deviation'], isNull);
    final grade = (json['grades'] as List).last as Map<String, dynamic>;
    expect(grade, {
      'ply': 3,
      'expected': 'g1f3',
      'accepted': 'g1f3',
      'firstAttempt': 'b1c3',
      'result': 'wrong',
      'credit': 0.0,
      'attempts': 1,
      'hintLevel': 0,
      'checkCp': null,
      'checkStatus': 'timeout',
    });
    expect(RunRecord.fromJson(json), run);
    expect(
      CheckStatus.values.map(
        (s) => MoveGrade.fromJson({
          ...grade,
          'checkStatus': switch (s) {
            CheckStatus.ok => 'ok',
            CheckStatus.timeout => 'timeout',
            CheckStatus.engineUnavailable => 'engine_unavailable',
          },
        }).checkStatus,
      ),
      CheckStatus.values,
    );
    const dev = DeviationEvent(ply: 9, bestUci: 'a2a3', passed: false);
    expect(DeviationEvent.fromJson(dev.toJson()), dev);
  });

  test('read-only grade access never creates a ply', () {
    final r = builder();
    expect(r.gradeAt(1), isNull);
    expect(r.grades, isEmpty);
    r.ply(1, expected: 'e2e4', accepted: ['e2e4']).attempt('d2d4');
    r.ply(3, expected: 'g1f3', accepted: ['g1f3']);
    expect(r.gradeAt(1)!.result, GradeResult.wrong);
    expect(r.gradeAt(2), isNull);
    // Ply 3 exists but has no event yet: not in the grades.
    expect([for (final g in r.grades) g.ply], [1]);
    r.gradeAt(3)!.attempt('g1f3');
    expect(
      [for (final g in r.grades) (g.ply, g.result)],
      [(1, GradeResult.wrong), (3, GradeResult.correct)],
    );
  });
}
