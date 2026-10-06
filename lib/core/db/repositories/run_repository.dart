import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/mappers.dart';

/// Immutable training runs with their grades and deviations.
abstract interface class RunRepository {
  /// Stores [run], its grades and deviation in one transaction and bumps the
  /// repertoire's `lastTrainedAt`.
  Future<void> insertRun(RunRecord run);

  /// Inserts the runs whose id is unknown (sync / backup merge); returns the
  /// inserted ones. Inserted runs count as synced at [syncedAt] if given.
  Future<List<RunRecord>> insertIfAbsent(List<RunRecord> runs, {int? syncedAt});

  /// All runs of [repertoireId] with grades, oldest first.
  Future<List<RunRecord>> runsForRepertoire(String repertoireId);

  /// Line keys of the [n] most recently started runs of [repertoireId],
  /// newest first (input for the recent-line exclusion).
  Future<List<String>> recentStartedLineKeys(String repertoireId, int n);

  /// Runs not uploaded yet.
  Future<List<RunRecord>> unsyncedRuns();

  /// Marks [ids] uploaded at [at].
  Future<void> markSynced(List<String> ids, int at);

  /// Distinct days with at least one completed run, any repertoire (streak).
  Future<Set<String>> trainingDays();
}

/// drift implementation of [RunRepository].
final class DriftRunRepository implements RunRepository {
  /// Creates the repository.
  new(this._db);

  final AppDatabase _db;

  @override
  Future<void> insertRun(RunRecord run) => _db.transaction(() async {
    await _insert(run);
    await _db.customUpdate(
      'UPDATE repertoires SET last_trained_at = '
      'MAX(COALESCE(last_trained_at, 0), ?1) WHERE id = ?2',
      variables: [
        Variable.withInt(run.finishedAt),
        Variable.withString(run.repertoireId),
      ],
      updates: {_db.repertoires},
    );
  });

  Future<void> _insert(RunRecord run, {int? syncedAt}) async {
    await _db.into(_db.runs).insert(runCompanion(run, syncedAt: syncedAt));
    await _db.batch((b) {
      b.insertAll(_db.moveGrades, [
        for (final g in run.grades) gradeCompanion(run.id, g),
      ]);
      final d = run.deviation;
      if (d != null) {
        b.insert(_db.deviationEvents, deviationCompanion(run.id, d));
      }
    });
  }

  @override
  Future<List<RunRecord>> insertIfAbsent(
    List<RunRecord> runs, {
    int? syncedAt,
  }) => _db.transaction(() async {
    final ids = [for (final r in runs) r.id];
    final known = <String>{};
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      final rows =
          await (_db.selectOnly(_db.runs)
                ..addColumns([_db.runs.id])
                ..where(_db.runs.id.isIn(chunk)))
              .get();
      known.addAll(rows.map((r) => r.read(_db.runs.id)!));
    }
    final inserted = <RunRecord>[];
    for (final r in runs) {
      if (known.add(r.id)) {
        await _insert(r, syncedAt: syncedAt);
        inserted.add(r);
      }
    }
    return inserted;
  });

  @override
  Future<List<RunRecord>> runsForRepertoire(String repertoireId) async {
    final runs =
        await (_db.select(_db.runs)
              ..where((r) => r.repertoireId.equals(repertoireId))
              ..orderBy([
                (r) => OrderingTerm.asc(r.finishedAt),
                (r) => OrderingTerm.asc(r.id),
              ]))
            .get();
    return await _withChildren(runs);
  }

  Future<List<RunRecord>> _withChildren(List<DbRun> runs) async {
    if (runs.isEmpty) return const [];
    final grades = <String, List<DbMoveGrade>>{};
    final deviations = <String, DbDeviationEvent>{};
    final ids = [for (final r in runs) r.id];
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      for (final g
          in await (_db.select(_db.moveGrades)
                ..where((g) => g.runId.isIn(chunk))
                ..orderBy([(g) => OrderingTerm.asc(g.ply)]))
              .get()) {
        (grades[g.runId] ??= []).add(g);
      }
      for (final d in await (_db.select(
        _db.deviationEvents,
      )..where((d) => d.runId.isIn(chunk))).get()) {
        deviations[d.runId] = d;
      }
    }
    return [
      for (final r in runs)
        runRecordOf(r, grades[r.id] ?? const [], deviations[r.id]),
    ];
  }

  @override
  Future<List<String>> recentStartedLineKeys(String repertoireId, int n) async {
    final rows =
        await (_db.select(_db.runs)
              ..where((r) => r.repertoireId.equals(repertoireId))
              ..orderBy([
                (r) => OrderingTerm.desc(r.startedAt),
                (r) => OrderingTerm.desc(r.id),
              ])
              ..limit(n))
            .get();
    return [for (final r in rows) r.lineKey];
  }

  @override
  Future<List<RunRecord>> unsyncedRuns() async => await _withChildren(
    await (_db.select(_db.runs)
          ..where((r) => r.syncedAt.isNull())
          ..orderBy([(r) => OrderingTerm.asc(r.finishedAt)]))
        .get(),
  );

  @override
  Future<void> markSynced(List<String> ids, int at) async {
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      await (_db.update(_db.runs)..where((r) => r.id.isIn(chunk))).write(
        RunsCompanion(syncedAt: Value(at)),
      );
    }
  }

  @override
  Future<Set<String>> trainingDays() async {
    final rows =
        await (_db.selectOnly(_db.runs, distinct: true)
              ..addColumns([_db.runs.localDay])
              ..where(_db.runs.completed.equals(true)))
            .get();
    return {for (final r in rows) r.read(_db.runs.localDay)!};
  }
}
