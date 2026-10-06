import 'dart:convert';

import 'package:chess_core/chess_core.dart';
import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/mappers.dart';

/// One Home card (docs/plan/01-product-spec.md §4).
@immutable
final class RepertoireSummary {
  /// Creates a summary.
  const new({
    required this.id,
    required this.name,
    required this.color,
    required this.lineCount,
    required this.accuracy,
    required this.dueCount,
    required this.weakCount,
    required this.lastTrainedAt,
    required this.createdAt,
    this.lastMode,
    this.startFromBranch = false,
  });

  /// Repertoire id.
  final String id;

  /// Name.
  final String name;

  /// Colour.
  final Side color;

  /// Number of lines.
  final int lineCount;

  /// Overall accuracy (mean of line accuracies), or null if not trained.
  final double? accuracy;

  /// Lines due in SRS today.
  final int dueCount;

  /// Lines in the weak pool.
  final int weakCount;

  /// Last training time (UTC ms), or null.
  final int? lastTrainedAt;

  /// Creation time (UTC ms).
  final int createdAt;

  /// Last training mode (`RunMode` name), local only.
  final String? lastMode;

  /// Drills start at the branch point (mode sheet choice), local only.
  final bool startFromBranch;

  @override
  bool operator ==(Object other) =>
      other is RepertoireSummary &&
      other.id == id &&
      other.name == name &&
      other.color == color &&
      other.lineCount == lineCount &&
      other.accuracy == accuracy &&
      other.dueCount == dueCount &&
      other.weakCount == weakCount &&
      other.lastTrainedAt == lastTrainedAt &&
      other.createdAt == createdAt &&
      other.lastMode == lastMode &&
      other.startFromBranch == startFromBranch;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    color,
    lineCount,
    accuracy,
    dueCount,
    weakCount,
    lastTrainedAt,
    createdAt,
    lastMode,
    startFromBranch,
  );

  @override
  String toString() =>
      'RepertoireSummary($name, lines $lineCount, '
      'acc $accuracy, due $dueCount, weak $weakCount)';
}

/// Repertoires, their nodes and lines (docs/plan/phases/P03 task 2).
abstract interface class RepertoireRepository {
  /// Home cards of non-deleted repertoires, sorted by last trained (never
  /// trained last, newest first). [today] decides the due counts.
  Stream<List<RepertoireSummary>> watchSummaries({required String today});

  /// Stores a new repertoire from a successful import; returns its id.
  Future<String> create({
    required String name,
    required Side color,
    required String pgn,
    required ImportResult result,
  });

  /// Replaces the PGN, nodes and lines of [id]; runs are untouched. Returns
  /// the diff against the previous version. Call
  /// `StatsService.rebuildRepertoire` afterwards.
  Future<ReimportDiff> reimport(
    String id, {
    required String pgn,
    required ImportResult result,
  });

  /// Renames [id].
  Future<void> rename(String id, String name);

  /// Marks [id] deleted (tombstone for sync).
  Future<void> softDelete(String id);

  /// Undoes [softDelete].
  Future<void> undoDelete(String id);

  /// Stores the drill choices of [id] (local only, not synced): the last
  /// mode and whether drills start at the branch point.
  Future<void> setTrainingPrefs(
    String id, {
    String? lastMode,
    bool? startFromBranch,
  });

  /// The repertoire row, or null if unknown.
  Future<DbRepertoire?> get(String id);

  /// The current lines of [id] for training logic, in ordinal order.
  Future<List<LineRef>> lineRefs(String id);

  /// Ids of all repertoires, deleted ones included.
  Future<List<String>> allIds();

  /// Every repertoire as a sync / backup record, deleted ones included.
  Future<List<RepertoireRecord>> records();

  /// Stores [record] as it is (a merge winner): inserts it or updates its
  /// source columns, keeping local ones. With [tree], replaces its nodes
  /// and lines (a new or changed PGN). Safe inside a transaction.
  Future<void> putRecord(RepertoireRecord record, {RepertoireTree? tree});

  /// Deletes everything of [id] but its row (a merged tombstone): nodes,
  /// lines, derived stats and runs.
  Future<void> purge(String id);

  /// Deletes every repertoire, run and derived row (backup "Replace all").
  Future<void> deleteAll();

  /// The in-memory tree of [id] (cached, LRU of 3).
  Future<RepertoireTree> loadTree(String id);
}

/// Keeps the 3 most recently used trees, keyed by repertoire id and PGN
/// hash (a re-import changes the hash and so misses the cache).
final class RepertoireCache {
  /// Creates a cache holding at most [capacity] trees.
  new({this.capacity = 3});

  /// Maximum number of trees.
  final int capacity;

  final _entries = <String, (String, RepertoireTree)>{};

  /// The cached tree of [id] if its hash is [pgnHash].
  RepertoireTree? get(String id, String pgnHash) {
    final e = _entries.remove(id);
    if (e == null) return null;
    if (e.$1 != pgnHash) return null;
    _entries[id] = e; // most recently used last
    return e.$2;
  }

  /// Stores [tree].
  void put(String id, String pgnHash, RepertoireTree tree) {
    _entries
      ..remove(id)
      ..[id] = (pgnHash, tree);
    while (_entries.length > capacity) {
      _entries.remove(_entries.keys.first);
    }
  }

  /// Drops [id].
  void invalidate(String id) => _entries.remove(id);

  /// Ids of the cached trees.
  Iterable<String> get ids => _entries.keys;

  /// Number of cached trees.
  int get length => _entries.length;
}

/// SHA-256 hex of [pgn].
String pgnHashOf(String pgn) => sha256.convert(utf8.encode(pgn)).toString();

/// drift implementation of [RepertoireRepository].
final class DriftRepertoireRepository implements RepertoireRepository {
  /// Creates the repository.
  new(
    this._db, {
    required this._clock,
    required this._newId,
    required this._deviceId,
    RepertoireCache? cache,
    @visibleForTesting void Function(String stage)? debugHook,
  }) : _cache = cache ?? RepertoireCache(),
       _hook = debugHook;

  final AppDatabase _db;
  final Clock _clock;
  final String Function() _newId;
  final Future<String> Function() _deviceId;
  final RepertoireCache _cache;
  final void Function(String stage)? _hook;

  int get _now => _clock.now().millisecondsSinceEpoch;

  @override
  Stream<List<RepertoireSummary>> watchSummaries({required String today}) {
    final query = _db.customSelect(
      '''
SELECT r.id, r.name, r.color, r.last_trained_at, r.created_at,
  r.last_mode, r.drill_start_from,
  (SELECT COUNT(*) FROM lines l WHERE l.repertoire_id = r.id) AS line_count,
  s.accuracy, COALESCE(s.weak_count, 0) AS weak_count,
  COALESCE(s.due_count, 0) AS due_count
FROM repertoires r
LEFT JOIN (
  SELECT repertoire_id,
    AVG(accuracy) AS accuracy,
    SUM(in_weak_pool) AS weak_count,
    SUM(CASE WHEN srs_state IN ('learning', 'review')
             AND srs_due_day <= ?1 THEN 1 ELSE 0 END) AS due_count
  FROM line_stats WHERE archived = 0
  GROUP BY repertoire_id
) s ON s.repertoire_id = r.id
WHERE r.deleted = 0
ORDER BY r.last_trained_at IS NULL, r.last_trained_at DESC, r.created_at DESC
''',
      variables: [Variable.withString(today)],
      readsFrom: {_db.repertoires, _db.lines, _db.lineStatsTable},
    );
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          RepertoireSummary(
            id: r.read<String>('id'),
            name: r.read<String>('name'),
            color: sideFromDb(r.read<String>('color')),
            lineCount: r.read<int>('line_count'),
            accuracy: r.readNullable<double>('accuracy'),
            dueCount: r.read<int>('due_count'),
            weakCount: r.read<int>('weak_count'),
            lastTrainedAt: r.readNullable<int>('last_trained_at'),
            createdAt: r.read<int>('created_at'),
            lastMode: r.readNullable<String>('last_mode'),
            startFromBranch: r.read<String>('drill_start_from') == 'branch',
          ),
      ],
    );
  }

  @override
  Future<String> create({
    required String name,
    required Side color,
    required String pgn,
    required ImportResult result,
  }) async {
    final tree = _requireTree(result);
    final id = _newId();
    final device = await _deviceId();
    final text = normalizePgnText(pgn);
    final now = _now;
    await _db.transaction(() async {
      await _db
          .into(_db.repertoires)
          .insert(
            RepertoiresCompanion.insert(
              id: id,
              name: name.trim(),
              color: sideToDb(color),
              pgn: text,
              pgnHash: pgnHashOf(text),
              description: Value(tree.description),
              createdAt: now,
              updatedAt: now,
              updatedBy: device,
            ),
          );
      _hook?.call('create:repertoire');
      await _insertTree(id, tree);
      _hook?.call('create:tree');
      final empty = deriveRepertoire(lines: lineRefsOf(tree), runs: const []);
      await _db.batch((b) {
        b.insertAll(_db.lineStatsTable, [
          for (final s in empty) lineStatsCompanion(id, s),
        ]);
      });
    });
    return id;
  }

  Future<void> _insertTree(String id, RepertoireTree tree) async {
    final rows = tree.toRows();
    // Multi-row INSERTs: several times faster than one statement per row
    // for the thousands of nodes of a big repertoire (P03 target < 300 ms).
    await _insertRows('nodes', _nodeColumns, [
      for (final n in rows.nodes)
        [
          id,
          n.nodeId,
          n.parentId,
          n.ply,
          n.san,
          n.uci,
          n.fen,
          n.isUserMove,
          n.childIndex,
          n.why,
          n.plan,
          n.watch,
          n.alt,
          n.shapesJson,
          n.rawComment,
          n.nagsText,
        ],
    ], _db.nodes);
    await _insertRows('lines', _lineColumns, [
      for (final l in rows.lines)
        [
          id,
          l.lineKey,
          l.leafNodeId,
          l.ordinal,
          l.plies,
          l.userMoveCount,
          l.branchPly,
          l.label,
          l.ucis,
        ],
    ], _db.lines);
  }

  static const _nodeColumns = [
    'repertoire_id', 'node_id', 'parent_id', 'ply', 'san', 'uci', 'fen', //
    'is_user_move', 'child_index', 'why', 'plan', 'watch', 'alt', 'shapes',
    'raw_comment', 'nags',
  ];

  static const _lineColumns = [
    'repertoire_id', 'line_key', 'leaf_node_id', 'ordinal', 'plies', //
    'user_move_count', 'branch_ply', 'label', 'ucis',
  ];

  /// Rows per INSERT statement (stays far below SQLite's variable limit).
  static const _rowsPerStatement = 50;

  Future<void> _insertRows(
    String table,
    List<String> columns,
    List<List<Object?>> rows,
    TableInfo<Table, Object?> info,
  ) async {
    final tuple = '(${List.filled(columns.length, '?').join(', ')})';
    for (var i = 0; i < rows.length; i += _rowsPerStatement) {
      final end = i + _rowsPerStatement > rows.length
          ? rows.length
          : i + _rowsPerStatement;
      final chunk = rows.sublist(i, end);
      await _db.customInsert(
        'INSERT INTO $table (${columns.join(', ')}) VALUES '
        '${List.filled(chunk.length, tuple).join(', ')}',
        variables: [
          for (final row in chunk)
            for (final value in row) Variable<Object>(value),
        ],
        updates: {info},
      );
    }
  }

  @override
  Future<ReimportDiff> reimport(
    String id, {
    required String pgn,
    required ImportResult result,
  }) async {
    final tree = _requireTree(result);
    final oldTree = await loadTree(id);
    final device = await _deviceId();
    final text = normalizePgnText(pgn);
    final diff = diffReimport(
      oldLines: lineRefsOf(oldTree),
      newLines: lineRefsOf(tree),
      commentChanges: countCommentChanges(oldTree, tree),
    );
    await _db.transaction(() async {
      await (_db.delete(
        _db.nodes,
      )..where((n) => n.repertoireId.equals(id))).go();
      await (_db.delete(
        _db.lines,
      )..where((l) => l.repertoireId.equals(id))).go();
      _hook?.call('reimport:deleted');
      await _insertTree(id, tree);
      await (_db.update(_db.repertoires)..where((r) => r.id.equals(id))).write(
        RepertoiresCompanion(
          pgn: Value(text),
          pgnHash: Value(pgnHashOf(text)),
          description: Value(tree.description),
          updatedAt: Value(_now),
          updatedBy: Value(device),
        ),
      );
    });
    _cache.invalidate(id);
    return diff;
  }

  @override
  Future<void> rename(String id, String name) =>
      _touch(id, RepertoiresCompanion(name: Value(name.trim())));

  @override
  Future<void> softDelete(String id) =>
      _touch(id, const RepertoiresCompanion(deleted: Value(true)));

  @override
  Future<void> setTrainingPrefs(
    String id, {
    String? lastMode,
    bool? startFromBranch,
  }) => (_db.update(_db.repertoires)..where((r) => r.id.equals(id))).write(
    RepertoiresCompanion(
      lastMode: lastMode == null ? const Value.absent() : Value(lastMode),
      drillStartFrom: startFromBranch == null
          ? const Value.absent()
          : Value(startFromBranch ? 'branch' : 'move1'),
    ),
  );

  @override
  Future<void> undoDelete(String id) =>
      _touch(id, const RepertoiresCompanion(deleted: Value(false)));

  Future<void> _touch(String id, RepertoiresCompanion change) async {
    final device = await _deviceId();
    await (_db.update(_db.repertoires)..where((r) => r.id.equals(id))).write(
      change.copyWith(updatedAt: Value(_now), updatedBy: Value(device)),
    );
  }

  @override
  Future<DbRepertoire?> get(String id) => (_db.select(
    _db.repertoires,
  )..where((r) => r.id.equals(id))).getSingleOrNull();

  @override
  Future<List<LineRef>> lineRefs(String id) async {
    final rows =
        await (_db.select(_db.lines)
              ..where((l) => l.repertoireId.equals(id))
              ..orderBy([(l) => OrderingTerm.asc(l.ordinal)]))
            .get();
    return [
      for (final l in rows)
        LineRef(
          key: l.lineKey,
          ucis: l.ucis,
          ordinal: l.ordinal,
          userMoveCount: l.userMoveCount,
        ),
    ];
  }

  @override
  Future<List<RepertoireRecord>> records() async => [
    for (final r in await (_db.select(
      _db.repertoires,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get())
      RepertoireRecord(
        id: r.id,
        name: r.name,
        color: r.color,
        pgn: r.pgn,
        pgnHash: r.pgnHash,
        description: r.description,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        updatedBy: r.updatedBy,
        deleted: r.deleted,
      ),
  ];

  @override
  Future<void> putRecord(RepertoireRecord record, {RepertoireTree? tree}) =>
      _db.transaction(() async {
        final source = RepertoiresCompanion(
          name: Value(record.name),
          color: Value(record.color),
          pgn: Value(record.pgn),
          pgnHash: Value(record.pgnHash),
          description: Value(record.description),
          createdAt: Value(record.createdAt),
          updatedAt: Value(record.updatedAt),
          updatedBy: Value(record.updatedBy),
          deleted: Value(record.deleted),
        );
        final updated = await (_db.update(
          _db.repertoires,
        )..where((r) => r.id.equals(record.id))).write(source);
        if (updated == 0) {
          await _db
              .into(_db.repertoires)
              .insert(source.copyWith(id: Value(record.id)));
        }
        if (tree != null) {
          await _deleteTree(record.id);
          await _insertTree(record.id, tree);
        }
        _cache.invalidate(record.id);
      });

  Future<void> _deleteTree(String id) async {
    await (_db.delete(_db.nodes)..where((n) => n.repertoireId.equals(id))).go();
    await (_db.delete(_db.lines)..where((l) => l.repertoireId.equals(id))).go();
  }

  @override
  Future<void> purge(String id) => _db.transaction(() async {
    await _deleteTree(id);
    final runIds = _db.selectOnly(_db.runs)
      ..addColumns([_db.runs.id])
      ..where(_db.runs.repertoireId.equals(id));
    await (_db.delete(
      _db.moveGrades,
    )..where((g) => g.runId.isInQuery(runIds))).go();
    await (_db.delete(
      _db.deviationEvents,
    )..where((d) => d.runId.isInQuery(runIds))).go();
    await (_db.delete(_db.runs)..where((r) => r.repertoireId.equals(id))).go();
    await (_db.delete(
      _db.lineStatsTable,
    )..where((s) => s.repertoireId.equals(id))).go();
    await (_db.delete(
      _db.plyStats,
    )..where((s) => s.repertoireId.equals(id))).go();
    _cache.invalidate(id);
  });

  @override
  Future<void> deleteAll() => _db.transaction(() async {
    final tables = <TableInfo<Table, Object?>>[
      _db.moveGrades,
      _db.deviationEvents,
      _db.runs,
      _db.lineStatsTable,
      _db.plyStats,
      _db.nodes,
      _db.lines,
      _db.repertoires,
    ];
    for (final t in tables) {
      await _db.delete(t).go();
    }
    [..._cache.ids].forEach(_cache.invalidate);
  });

  @override
  Future<List<String>> allIds() async => [
    for (final r in await _db.select(_db.repertoires).get()) r.id,
  ];

  @override
  Future<RepertoireTree> loadTree(String id) async {
    final rep = await get(id);
    if (rep == null) throw StateError('unknown repertoire $id');
    final cached = _cache.get(id, rep.pgnHash);
    if (cached != null) return cached;
    final nodes =
        await (_db.select(_db.nodes)
              ..where((n) => n.repertoireId.equals(id))
              ..orderBy([(n) => OrderingTerm.asc(n.nodeId)]))
            .get();
    final lines =
        await (_db.select(_db.lines)
              ..where((l) => l.repertoireId.equals(id))
              ..orderBy([(l) => OrderingTerm.asc(l.ordinal)]))
            .get();
    final tree = RepertoireTree.fromRows(
      RepertoireRows(
        nodes: [for (final n in nodes) nodeRowOf(n)],
        lines: [for (final l in lines) lineRowOf(l)],
      ),
      userSide: sideFromDb(rep.color),
      description: rep.description,
    );
    _cache.put(id, rep.pgnHash, tree);
    return tree;
  }

  /// Drops [id] from the tree cache (tests measure cold loads).
  @visibleForTesting
  void invalidateForTest(String id) => _cache.invalidate(id);

  static RepertoireTree _requireTree(ImportResult result) {
    final tree = result.tree;
    if (tree == null) {
      throw ArgumentError.value(result, 'result', 'import has errors');
    }
    return tree;
  }
}
