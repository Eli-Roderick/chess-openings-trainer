import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

/// Why a repertoire version was saved (audit R2, R4).
enum SnapshotReason {
  /// The version a re-import or a version restore replaced.
  reimport,

  /// A local repertoire before a backup "Replace all".
  restore,

  /// A local version a newer synced or backed-up one replaced.
  replaced,

  /// A local repertoire another device deleted.
  deleted,

  /// An incoming (sync or backup) version whose PGN did not import; the
  /// local version was kept.
  rejected,
}

/// A saved repertoire version.
@immutable
final class Snapshot {
  /// Creates it.
  const new({
    required this.id,
    required this.record,
    required this.reason,
    required this.savedAt,
  });

  /// Row id.
  final int id;

  /// The saved source (name, colour, PGN, timestamps).
  final RepertoireRecord record;

  /// Why it was saved.
  final SnapshotReason reason;

  /// When it was saved (UTC ms).
  final int savedAt;

  /// The repertoire it belongs to.
  String get repertoireId => record.id;
}

/// The sync / backup record of repertoire row [r].
RepertoireRecord repertoireRecordOf(DbRepertoire r) => RepertoireRecord(
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
);

/// Saved versions kept per repertoire (oldest dropped first).
const maxSnapshotsPerRepertoire = 10;

/// Saves [record] as a [reason] version at [now] in [db]. A version with
/// the same PGN and reason is only refreshed (its time and name), so
/// repeated syncs or re-imports of one file keep one copy. Safe inside a
/// transaction.
Future<void> saveSnapshot(
  AppDatabase db,
  RepertoireRecord record,
  SnapshotReason reason, {
  required int now,
}) async {
  final same =
      await (db.select(db.snapshots)..where(
            (s) =>
                s.repertoireId.equals(record.id) &
                s.pgnHash.equals(record.pgnHash) &
                s.reason.equals(reason.name),
          ))
          .get();
  if (same.isNotEmpty) {
    await (db.update(
      db.snapshots,
    )..where((s) => s.id.equals(same.first.id))).write(
      SnapshotsCompanion(name: Value(record.name), createdAt: Value(now)),
    );
  } else {
    await db
        .into(db.snapshots)
        .insert(
          SnapshotsCompanion.insert(
            repertoireId: record.id,
            name: record.name,
            color: record.color,
            pgn: record.pgn,
            pgnHash: record.pgnHash,
            description: Value(record.description),
            recordCreatedAt: record.createdAt,
            recordUpdatedAt: record.updatedAt,
            recordUpdatedBy: record.updatedBy,
            reason: reason.name,
            createdAt: now,
          ),
        );
  }
  final keep = db.selectOnly(db.snapshots)
    ..addColumns([db.snapshots.id])
    ..where(db.snapshots.repertoireId.equals(record.id))
    ..orderBy([
      OrderingTerm.desc(db.snapshots.createdAt),
      OrderingTerm.desc(db.snapshots.id),
    ])
    ..limit(maxSnapshotsPerRepertoire);
  await (db.delete(db.snapshots)..where(
        (s) => s.repertoireId.equals(record.id) & s.id.isNotInQuery(keep),
      ))
      .go();
}

/// A deleted repertoire that can still be restored.
@immutable
final class TrashEntry {
  /// Creates it.
  const new({
    required this.repertoireId,
    required this.name,
    required this.deletedAt,
    required this.hasData,
  });

  /// Repertoire id.
  final String repertoireId;

  /// Its name.
  final String name;

  /// When it was deleted, or when its last version was saved (UTC ms).
  final int deletedAt;

  /// Its tree, runs and stats are still on this device (a local delete);
  /// otherwise only a saved version is left.
  final bool hasData;

  @override
  bool operator ==(Object other) =>
      other is TrashEntry &&
      other.repertoireId == repertoireId &&
      other.name == name &&
      other.deletedAt == deletedAt &&
      other.hasData == hasData;

  @override
  int get hashCode => Object.hash(repertoireId, name, deletedAt, hasData);
}

/// Saved versions (audit R4): version history, trash and rejected
/// incoming versions.
final class SnapshotRepository {
  /// Creates the repository.
  new(this._db);

  final AppDatabase _db;

  /// Every saved version, newest first.
  Stream<List<Snapshot>> watchAll() =>
      (_db.select(_db.snapshots)..orderBy([
            (s) => OrderingTerm.desc(s.createdAt),
            (s) => OrderingTerm.desc(s.id),
          ]))
          .watch()
          .map((rows) => [for (final r in rows) _snapshotOf(r)]);

  /// Deleted repertoires that can be restored, newest first: deleted rows
  /// whose data or a saved version is left, and saved versions of
  /// repertoires that no longer exist (removed by "Replace all").
  Stream<List<TrashEntry>> watchTrash() {
    const restorable = "s.reason != 'rejected'";
    return _db
        .customSelect(
          '''
SELECT r.id AS id, r.name AS name, r.updated_at AS at,
  EXISTS (SELECT 1 FROM nodes n WHERE n.repertoire_id = r.id) AS has_data
FROM repertoires r
WHERE r.deleted = 1 AND (
  EXISTS (SELECT 1 FROM nodes n WHERE n.repertoire_id = r.id)
  OR EXISTS (SELECT 1 FROM snapshots s
             WHERE s.repertoire_id = r.id AND $restorable))
UNION ALL
SELECT s.repertoire_id AS id, s.name AS name, MAX(s.created_at) AS at,
  0 AS has_data
FROM snapshots s
WHERE $restorable AND NOT EXISTS (
  SELECT 1 FROM repertoires r WHERE r.id = s.repertoire_id)
GROUP BY s.repertoire_id
ORDER BY at DESC
''',
          readsFrom: {_db.repertoires, _db.nodes, _db.snapshots},
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              TrashEntry(
                repertoireId: r.read<String>('id'),
                name: r.read<String>('name'),
                deletedAt: r.read<int>('at'),
                hasData: r.read<int>('has_data') != 0,
              ),
          ],
        );
  }

  /// The saved version [id], or null.
  Future<Snapshot?> get(int id) async {
    final row = await (_db.select(
      _db.snapshots,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    return row == null ? null : _snapshotOf(row);
  }

  /// The newest version of [repertoireId] that can be restored (not a
  /// rejected one), or null.
  Future<Snapshot?> latestRestorable(String repertoireId) async {
    final row =
        await (_db.select(_db.snapshots)
              ..where(
                (s) =>
                    s.repertoireId.equals(repertoireId) &
                    s.reason.equals(SnapshotReason.rejected.name).not(),
              )
              ..orderBy([
                (s) => OrderingTerm.desc(s.createdAt),
                (s) => OrderingTerm.desc(s.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _snapshotOf(row);
  }

  /// Deletes version [id].
  Future<void> delete(int id) =>
      (_db.delete(_db.snapshots)..where((s) => s.id.equals(id))).go();

  /// Deletes every version of [repertoireId].
  Future<void> deleteForRepertoire(String repertoireId) => (_db.delete(
    _db.snapshots,
  )..where((s) => s.repertoireId.equals(repertoireId))).go();

  static Snapshot _snapshotOf(DbSnapshot r) => Snapshot(
    id: r.id,
    record: RepertoireRecord(
      id: r.repertoireId,
      name: r.name,
      color: r.color,
      pgn: r.pgn,
      pgnHash: r.pgnHash,
      description: r.description,
      createdAt: r.recordCreatedAt,
      updatedAt: r.recordUpdatedAt,
      updatedBy: r.recordUpdatedBy,
    ),
    reason: SnapshotReason.values.firstWhere(
      (v) => v.name == r.reason,
      orElse: () => SnapshotReason.replaced,
    ),
    savedAt: r.createdAt,
  );
}
