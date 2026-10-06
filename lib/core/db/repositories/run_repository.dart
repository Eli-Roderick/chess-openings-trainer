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

  /// Every run with grades, oldest first (backup).
  Future<List<RunRecord>> allRuns();

  /// Runs of [repertoireId] without grades or deviation, oldest first:
  /// enough for stats derivation (`RunRecord.allPerfect` uses the totals)
  /// and much faster to load.
  Future<List<RunRecord>> runsForDerivation(String repertoireId);

  /// Every run as a JSON array in the sync form (`RunRecord.toJson`),
  /// built by SQLite (large backups).
  Future<String> exportRunsJson();

  /// Inserts the runs at `$.runs` of backup document [docId] (the
  /// `backup_doc` temporary table, see `BackupQueries`) that are not stored
  /// yet and whose repertoire is not deleted, in SQLite. Returns the number
  /// of inserted runs per repertoire.
  Future<Map<String, int>> importBackupRuns(int docId, {int? syncedAt});

  /// Number of stored runs.
  Future<int> count();

  /// UTC months (`YYYY-MM`) of [deviceId]'s runs not uploaded yet.
  Future<List<String>> unsyncedMonths(String deviceId);

  /// [deviceId]'s runs that finished in UTC [month] (`YYYY-MM`), with
  /// grades, oldest first (a monthly run log, 06 §3).
  Future<List<RunRecord>> deviceRunsInMonth(String deviceId, String month);

  /// Line keys of the [n] most recently started runs of [repertoireId],
  /// newest first (input for the recent-line exclusion).
  Future<List<String>> recentStartedLineKeys(String repertoireId, int n);

  /// SRS reviews (04 §5.2: SRS mode, completed, not deviated, graded) on
  /// [day], all repertoires: the SRS daily review cap counts these.
  Future<int> srsReviewsOn(String day);

  /// Runs not uploaded yet.
  Future<List<RunRecord>> unsyncedRuns();

  /// Marks [ids] uploaded at [at].
  Future<void> markSynced(List<String> ids, int at);

  /// Distinct days with at least one completed run, any repertoire (streak).
  Future<Set<String>> trainingDays();

  /// [trainingDays], updated live.
  Stream<Set<String>> watchTrainingDays();

  /// Runs of [repertoireId] whose moves are [ucis] or a strict prefix of
  /// it (direct and inherited candidates for a line's history), with
  /// grades, oldest first.
  Future<List<RunRecord>> runsAlong(String repertoireId, String ucis);

  /// Runs of [repertoireId] stored under [lineKey], with grades, oldest
  /// first (an archived line's history).
  Future<List<RunRecord>> runsForKey(String repertoireId, String lineKey);
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
    final inserted = [
      for (final r in runs)
        if (known.add(r.id)) r,
    ];
    // One batch per 500 runs: a round trip per run made a 20k-run import
    // take over a minute.
    for (var i = 0; i < inserted.length; i += 500) {
      final chunk = inserted.sublist(
        i,
        i + 500 > inserted.length ? inserted.length : i + 500,
      );
      await _db.batch((b) {
        b
          ..insertAll(_db.runs, [
            for (final r in chunk) runCompanion(r, syncedAt: syncedAt),
          ])
          ..insertAll(_db.moveGrades, [
            for (final r in chunk)
              for (final g in r.grades) gradeCompanion(r.id, g),
          ])
          ..insertAll(_db.deviationEvents, [
            for (final r in chunk)
              if (r.deviation case final d?) deviationCompanion(r.id, d),
          ]);
      });
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
    return await _withChildrenOf(runs, 'r.repertoire_id = ?1', [
      Variable.withString(repertoireId),
    ]);
  }

  @override
  Future<List<RunRecord>> allRuns() async {
    final runs =
        await (_db.select(_db.runs)..orderBy([
              (r) => OrderingTerm.asc(r.finishedAt),
              (r) => OrderingTerm.asc(r.id),
            ]))
            .get();
    return await _withChildrenOf(runs, '1', const []);
  }

  /// [_withChildren] for many runs selected by [runFilter] (SQL over `r`, a
  /// `runs` alias): two queries in all instead of two per 500 runs.
  Future<List<RunRecord>> _withChildrenOf(
    List<DbRun> runs,
    String runFilter,
    List<Variable> variables,
  ) async {
    if (runs.isEmpty) return const [];
    final grades = <String, List<DbMoveGrade>>{};
    for (final row
        in await _db
            .customSelect(
              'SELECT g.* FROM move_grades g JOIN runs r ON r.id = g.run_id '
              'WHERE $runFilter ORDER BY g.run_id, g.ply',
              variables: variables,
              readsFrom: {_db.runs, _db.moveGrades},
            )
            .get()) {
      final g = _db.moveGrades.map(row.data);
      (grades[g.runId] ??= []).add(g);
    }
    final deviations = {
      for (final row
          in await _db
              .customSelect(
                'SELECT d.* FROM deviation_events d CROSS JOIN runs r '
                'ON r.id = d.run_id WHERE $runFilter',
                variables: variables,
                readsFrom: {_db.runs, _db.deviationEvents},
              )
              .get())
        row.read<String>('run_id'): _db.deviationEvents.map(row.data),
    };
    return [
      for (final r in runs)
        runRecordOf(r, grades[r.id] ?? const [], deviations[r.id]),
    ];
  }

  @override
  Future<List<RunRecord>> runsForDerivation(String repertoireId) async => [
    for (final r
        in await (_db.select(_db.runs)
              ..where((r) => r.repertoireId.equals(repertoireId))
              ..orderBy([
                (r) => OrderingTerm.asc(r.finishedAt),
                (r) => OrderingTerm.asc(r.id),
              ]))
            .get())
      runRecordOf(r, const [], null),
  ];

  static String _bool(String column) =>
      "json(CASE WHEN $column THEN 'true' ELSE 'false' END)";

  @override
  Future<String> exportRunsJson() async {
    // Subqueries lose the JSON subtype, hence the json(...) wrappers.
    final row = await _db
        .customSelect(
          'SELECT json_group_array(json(j)) AS runs FROM (SELECT json_object( '
          "'id', r.id, 'repertoireId', r.repertoire_id, "
          "'lineKey', r.line_key, 'ucis', r.ucis, 'mode', r.mode, "
          "'startPly', r.start_ply, 'wrongMoveMode', r.wrong_move_mode, "
          "'startedAt', r.started_at, 'finishedAt', r.finished_at, "
          "'localDay', r.local_day, 'completed', ${_bool('r.completed')}, "
          "'deviated', ${_bool('r.deviated')}, "
          "'gradedCount', r.graded_count, 'creditSum', r.credit_sum, "
          "'hintCount', r.hint_count, 'deviceId', r.device_id, "
          "'schema', r.schema, "
          "'grades', json((SELECT json_group_array(json_object( "
          "'ply', g.ply, 'expected', g.expected, 'accepted', g.accepted, "
          "'firstAttempt', g.first_attempt, 'result', g.result, "
          "'credit', g.credit, 'attempts', g.attempts, "
          "'hintLevel', g.hint_level, 'checkCp', g.check_cp, "
          "'checkStatus', CASE g.check_status WHEN 'engineUnavailable' "
          "THEN 'engine_unavailable' ELSE g.check_status END)) "
          'FROM (SELECT * FROM move_grades WHERE run_id = r.id '
          'ORDER BY ply) g)), '
          "'deviation', json((SELECT json_object('ply', d.ply, "
          "'bestUci', d.best_uci, 'passed', ${_bool('d.passed')}, "
          "'deviationUci', d.deviation_uci, 'replyUci', d.reply_uci, "
          "'lossCp', d.loss_cp) FROM deviation_events d "
          'WHERE d.run_id = r.id))) AS j '
          'FROM runs r ORDER BY r.finished_at, r.id)',
          readsFrom: {_db.runs, _db.moveGrades, _db.deviationEvents},
        )
        .getSingle();
    return row.read<String>('runs');
  }

  @override
  Future<Map<String, int>> importBackupRuns(int docId, {int? syncedAt}) =>
      _db.transaction(() async {
        String v(String path) => "json_extract(i.v, '\$.$path')";
        await _db.customStatement(
          'CREATE TEMP TABLE IF NOT EXISTS import_runs (v BLOB NOT NULL)',
        );
        await _db.customStatement('DELETE FROM import_runs');
        await _db.customStatement(
          'INSERT INTO import_runs (v) SELECT j.value FROM jsonb_each( '
          r"(SELECT v FROM backup_doc WHERE id = ?1), '$.runs') j "
          'WHERE NOT EXISTS (SELECT 1 FROM runs '
          r"WHERE id = json_extract(j.value, '$.id')) "
          'AND NOT EXISTS (SELECT 1 FROM repertoires p '
          r"WHERE p.id = json_extract(j.value, '$.repertoireId') "
          'AND p.deleted)',
          [docId],
        );
        await _db.customUpdate(
          'INSERT OR IGNORE INTO runs (id, repertoire_id, line_key, ucis, '
          'mode, start_ply, wrong_move_mode, started_at, finished_at, '
          'local_day, completed, deviated, graded_count, credit_sum, '
          'hint_count, device_id, synced_at, schema) SELECT '
          "${v('id')}, ${v('repertoireId')}, ${v('lineKey')}, ${v('ucis')}, "
          "${v('mode')}, ${v('startPly')}, ${v('wrongMoveMode')}, "
          "${v('startedAt')}, ${v('finishedAt')}, ${v('localDay')}, "
          "${v('completed')}, ${v('deviated')}, ${v('gradedCount')}, "
          "${v('creditSum')}, ${v('hintCount')}, ${v('deviceId')}, ?1, "
          "COALESCE(${v('schema')}, 1) FROM import_runs i",
          variables: [Variable<int>(syncedAt)],
          updates: {_db.runs},
        );
        String g(String path) => "json_extract(g.value, '\$.$path')";
        await _db.customUpdate(
          'INSERT OR IGNORE INTO move_grades (run_id, ply, expected, '
          'accepted, first_attempt, result, credit, attempts, hint_level, '
          'check_cp, check_status) SELECT '
          "${v('id')}, ${g('ply')}, ${g('expected')}, ${g('accepted')}, "
          "${g('firstAttempt')}, ${g('result')}, ${g('credit')}, "
          "${g('attempts')}, ${g('hintLevel')}, ${g('checkCp')}, "
          "CASE ${g('checkStatus')} WHEN 'engine_unavailable' "
          "THEN 'engineUnavailable' ELSE ${g('checkStatus')} END "
          r"FROM import_runs i, jsonb_each(i.v, '$.grades') g",
          updates: {_db.moveGrades},
        );
        await _db.customUpdate(
          'INSERT OR IGNORE INTO deviation_events (run_id, ply, '
          'deviation_uci, reply_uci, best_uci, loss_cp, passed) SELECT '
          "${v('id')}, ${v('deviation.ply')}, ${v('deviation.deviationUci')}, "
          "${v('deviation.replyUci')}, ${v('deviation.bestUci')}, "
          "${v('deviation.lossCp')}, ${v('deviation.passed')} "
          r"FROM import_runs i WHERE json_type(i.v, '$.deviation') = 'object'",
          updates: {_db.deviationEvents},
        );
        final rows = await _db
            .customSelect(
              "SELECT ${v('repertoireId')} AS rep, COUNT(*) AS n "
              'FROM import_runs i GROUP BY 1',
            )
            .get();
        await _db.customStatement('DELETE FROM import_runs');
        return {for (final r in rows) r.read<String>('rep'): r.read<int>('n')};
      });

  static const _month = "strftime('%Y-%m', r.finished_at / 1000, 'unixepoch')";

  @override
  Future<List<String>> unsyncedMonths(String deviceId) async => [
    for (final row
        in await _db
            .customSelect(
              'SELECT DISTINCT $_month AS m FROM runs r '
              'WHERE r.device_id = ?1 AND r.synced_at IS NULL ORDER BY m',
              variables: [Variable.withString(deviceId)],
              readsFrom: {_db.runs},
            )
            .get())
      row.read<String>('m'),
  ];

  @override
  Future<List<RunRecord>> deviceRunsInMonth(
    String deviceId,
    String month,
  ) async {
    const filter = 'r.device_id = ?1 AND $_month = ?2';
    final variables = [
      Variable.withString(deviceId),
      Variable.withString(month),
    ];
    final rows = await _db
        .customSelect(
          'SELECT r.* FROM runs r WHERE $filter '
          'ORDER BY r.finished_at, r.id',
          variables: variables,
          readsFrom: {_db.runs},
        )
        .get();
    return await _withChildrenOf(
      [for (final row in rows) _db.runs.map(row.data)],
      filter,
      variables,
    );
  }

  @override
  Future<int> count() async {
    final runs = _db.runs.id.count();
    final row = await (_db.selectOnly(
      _db.runs,
    )..addColumns([runs])).getSingle();
    final n = row.read(runs);
    return n ?? 0;
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
  Future<int> srsReviewsOn(String day) async {
    final count = _db.runs.id.count();
    final query = _db.selectOnly(_db.runs)
      ..addColumns([count])
      ..where(
        _db.runs.mode.equals(RunMode.srs.name) &
            _db.runs.completed.equals(true) &
            _db.runs.deviated.equals(false) &
            _db.runs.gradedCount.isBiggerThanValue(0) &
            _db.runs.localDay.equals(day),
      );
    final row = await query.getSingle();
    final n = row.read(count);
    return n ?? 0;
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

  JoinedSelectStatement<$RunsTable, DbRun> _days() =>
      _db.selectOnly(_db.runs, distinct: true)
        ..addColumns([_db.runs.localDay])
        ..where(_db.runs.completed.equals(true));

  @override
  Future<Set<String>> trainingDays() async => {
    for (final r in await _days().get()) r.read(_db.runs.localDay)!,
  };

  @override
  Stream<Set<String>> watchTrainingDays() => _days().watch().map(
    (rows) => {for (final r in rows) r.read(_db.runs.localDay)!},
  );

  @override
  Future<List<RunRecord>> runsAlong(String repertoireId, String ucis) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM runs WHERE repertoire_id = ?1 AND (ucis = ?2 OR '
          "substr(?2, 1, length(ucis) + 1) = ucis || ' ') "
          'ORDER BY finished_at, id',
          variables: [
            Variable.withString(repertoireId),
            Variable.withString(ucis),
          ],
          readsFrom: {_db.runs},
        )
        .get();
    return await _withChildren([for (final r in rows) _db.runs.map(r.data)]);
  }

  @override
  Future<List<RunRecord>> runsForKey(
    String repertoireId,
    String lineKey,
  ) async {
    final runs =
        await (_db.select(_db.runs)
              ..where(
                (r) =>
                    r.repertoireId.equals(repertoireId) &
                    r.lineKey.equals(lineKey),
              )
              ..orderBy([
                (r) => OrderingTerm.asc(r.finishedAt),
                (r) => OrderingTerm.asc(r.id),
              ]))
            .get();
    return await _withChildren(runs);
  }
}
