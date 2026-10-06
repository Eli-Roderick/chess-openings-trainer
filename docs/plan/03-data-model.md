# 03. Data model

## 1. Principles

1. **Source data vs derived data.** Only three kinds of data are source data: **repertoires** (including their PGN text), **runs** (immutable history of training), and **settings** (device-local). Everything else (tree nodes, lines, line stats, weak pool membership, SRS schedule, streak) is derived and can be rebuilt at any time. This makes sync and backup simple and conflict-free for stats ([06-sync.md](06-sync.md)).
2. **Runs are immutable.** Once a run is finalized it is never edited. Corrections happen by deriving differently, never by rewriting history.
3. **Runs store their move sequence**, not just the line key, so stats survive re-imports, extensions and syncing to a device with a different PGN version.
4. Times are stored as UTC milliseconds since epoch (`int`). Day bucketing uses the **local day** computed with the "Day starts at" setting at the moment the run finished, stored on the run (`localDay`, `YYYY-MM-DD`), so derived streaks never shift when travelling or changing the setting later.

## 2. Tables (drift)

Types: `TEXT`, `INT`, `REAL`, `BOOL` (drift bool = INT 0/1). `PK` primary key.

### 2.1 `repertoires` (source, synced)
| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | UUID v4 |
| name | TEXT | 1-60 chars |
| color | TEXT | `'w'` or `'b'` |
| pgn | TEXT | exact imported text, line endings normalized to `\n` |
| pgnHash | TEXT | SHA-256 hex of `pgn`; used to skip rebuilds |
| description | TEXT NULL | from the pre-first-move comment of the first game, if any |
| createdAt | INT | |
| updatedAt | INT | bumped on rename, re-import, delete |
| updatedBy | TEXT | deviceId of last writer (LWW tie-break) |
| deleted | BOOL | tombstone |
| lastTrainedAt | INT NULL | **local only**, not synced (derived from runs after sync) |
| drillStartFrom | TEXT | `'move1'` / `'branch'`, **local only** |
| lastMode | TEXT NULL | **local only** |

### 2.2 `nodes` (derived from `pgn`)
| Column | Type | Notes |
|---|---|---|
| repertoireId | TEXT | FK, index |
| nodeId | INT | preorder index, root = 0 |
| parentId | INT NULL | root NULL |
| ply | INT | root 0, first move 1 |
| san | TEXT NULL | root NULL |
| uci | TEXT NULL | e.g. `e2e4`, `e7e8q`; castling as king two squares (`e1g1`) |
| fen | TEXT | position after the move (root: initial FEN) |
| isUserMove | BOOL | ply parity matches repertoire colour |
| childIndex | INT | order among siblings (PGN order: mainline first) |
| why | TEXT NULL | parsed comment fields ([07-comment-format.md](07-comment-format.md)) |
| plan | TEXT NULL | |
| watch | TEXT NULL | |
| alt | TEXT NULL | |
| shapes | TEXT NULL | JSON `[{"t":"arrow","from":"e2","to":"e4","c":"G"}, {"t":"circle","sq":"d5","c":"R"}]` |
| rawComment | TEXT NULL | original comment text (for opponent moves too; used by export and diff) |
| nags | TEXT NULL | e.g. `"1,14"`, preserved, not shown |
PK (repertoireId, nodeId).

### 2.3 `lines` (derived)
| Column | Type | Notes |
|---|---|---|
| repertoireId | TEXT | |
| lineKey | TEXT | see §3 |
| leafNodeId | INT | |
| ordinal | INT | preorder order of leaves (display order) |
| plies | INT | length |
| userMoveCount | INT | |
| branchPly | INT | start ply for "Branch point" mode ([04-algorithms.md §6](04-algorithms.md)) |
| label | TEXT | display label (§4) |
| ucis | TEXT | space-separated UCI sequence (needed to match runs) |
PK (repertoireId, lineKey). Index (repertoireId, ordinal).

### 2.4 `runs` (source, synced, immutable)
| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | UUID v4 |
| repertoireId | TEXT | index |
| lineKey | TEXT | key of the line *at the time of the run* (after any branch switch) |
| ucis | TEXT | the line's full UCI sequence at the time of the run |
| mode | TEXT | `random`, `weak`, `srs`, `single` |
| startPly | INT | 0 or the branch ply |
| wrongMoveMode | TEXT | `retry` / `restart` |
| startedAt | INT | |
| finishedAt | INT | |
| localDay | TEXT | `YYYY-MM-DD` per §1.4 |
| completed | BOOL | reached line end (or, for a mid-line deviation, the reply was judged) |
| deviated | BOOL | true only for a **mid-line** deviation (the line was not played to its end). An end-of-line challenge leaves this false and is recorded only in `deviation_events`. |
| gradedCount | INT | number of graded user moves |
| creditSum | REAL | |
| hintCount | INT | |
| deviceId | TEXT | creator |
| syncedAt | INT NULL | **local only**: when uploaded |
| schema | INT | run record schema version (1) |
Index (repertoireId, lineKey, finishedAt), (localDay), (syncedAt).

### 2.5 `move_grades` (source, synced as part of the run, immutable)
| Column | Type | Notes |
|---|---|---|
| runId | TEXT | |
| ply | INT | ply of the user move in the line |
| expected | TEXT | UCI of the move on the chosen line at that time |
| accepted | TEXT | space-separated UCIs of all repertoire moves at that node |
| firstAttempt | TEXT NULL | UCI of the first attempt (NULL if a hint was pressed before any attempt) |
| result | TEXT | `correct`, `comparable`, `wrong`, `hint` |
| credit | REAL | 1, 0.5, 0 |
| attempts | INT | number of attempts until correct |
| hintLevel | INT | 0, 1, 2 |
| checkCp | INT NULL | eval loss of first attempt vs best repertoire move (centipawns), when checked |
| checkStatus | TEXT NULL | `ok`, `timeout`, `engine_unavailable` |
PK (runId, ply).

### 2.6 `deviation_events` (source, synced with run)
| Column | Type |
|---|---|
| runId TEXT PK | |
| ply INT | ply of the deviation move; for an end-of-line challenge this is `plies + 1` (an opponent move after a user leaf) or `plies` with `deviationUci` NULL (line ended on an opponent move, user moves directly) |
| deviationUci TEXT NULL | |
| replyUci TEXT NULL (NULL if the user hinted or abandoned) | |
| bestUci TEXT | |
| lossCp INT NULL | |
| passed BOOL | |

### 2.7 `line_stats` (derived cache)
| Column | Type | Notes |
|---|---|---|
| repertoireId | TEXT | |
| lineKey | TEXT | includes archived keys |
| archived | BOOL | key not in current `lines` |
| runCount | INT | eligible runs (all time) |
| accuracy | REAL NULL | last-10 accuracy, NULL if no eligible runs |
| lastPlayedAt | INT NULL | |
| inWeakPool | BOOL | |
| weakCleanStreak | INT | |
| srsState | TEXT | `new`, `learning`, `review` |
| srsReps | INT | |
| srsEase | REAL | |
| srsIntervalDays | INT | |
| srsDueDay | TEXT NULL | `YYYY-MM-DD` |
| srsLapses | INT | |
| srsFirstSeenDay | TEXT NULL | day the line was first introduced in SRS (for new-per-day quota) |
PK (repertoireId, lineKey).

### 2.8 `settings` (local)
`key TEXT PK, value TEXT (JSON)`. Typed accessors in `core/settings`. Keys listed in [01-product-spec.md §10](01-product-spec.md).

### 2.9 `sync_state` (local)
`key TEXT PK, value TEXT`. Keys: `deviceId`, `deviceName`, `driveEnabled`, `lastSyncAt`, `lastSyncResult`, `remoteFile:<name>` → `{"id":..., "md5":..., "modifiedTime":...}`.

### 2.10 `app_meta` (local)
`schemaVersion` (drift handles), `installedAt`, `demoInstalled`.

## 3. Line key

```
lineKey = first 16 hex chars of SHA-256( utf8( ucis ) )
ucis    = UCI moves from the initial position joined by a single space, lower-case, promotion piece lower-case
```
Example: `e2e4 e7e5 g1f3 b8c6 f1b5` → key of that string. Castling is always king-two-squares (`e1g1`), never king-takes-rook; the importer normalizes. 64 bits is collision-safe for any realistic repertoire; on the astronomically unlikely collision inside one repertoire the importer fails with an error (detected because `ucis` differ for equal keys).

## 4. Line label

`label = [prefix + ": "] + tail`
- `prefix`: from the first game (in file order) that contains the line: header `ChapterName`, else `Opening`, else `Event` unless it is `?` or empty. Omitted if none.
- `tail`: SAN of the last 4 plies of the line with move numbers ("…4.Ba4 Nf6 5.O-O Be7"); full line if ≤ 4 plies.
Full SAN text of the line is always available on the line detail screen.

## 5. Re-import and line identity

Inputs: old lines (keys + ucis), new lines. Diff (implemented in `chess_core/training/reimport_diff.dart`, pure):
- **Unchanged:** key in both.
- **Extended:** an old line's `ucis` is a strict prefix of one or more new lines' `ucis`, and the old key is not a new key.
- **Removed:** old key neither unchanged nor extended.
- **New:** new key with no exact old match and no old prefix.

Nothing is rewritten in `runs`. Stats derivation ([04-algorithms.md §8](04-algorithms.md)) attributes runs to current lines by sequence:
- A run belongs to current line L if `run.ucis == L.ucis` (**direct**), or if `run.ucis` is a strict prefix of `L.ucis` **and** `run.ucis` is not itself a current line (**inherited**; the old line was extended). One run can be inherited by several lines (all extensions); this is intended.
- Inherited runs count for accuracy, weak pool and streak, but not for SRS: an extended line starts SRS as `new`, because its new moves have never been reviewed.
- Runs that match no current line are **archived**: shown read-only under the old key in stats. If the line returns in a later import, its runs become direct again automatically.
- Runs where the user switched to an alternative repertoire move are stored under the line actually completed, so attribution needs no special case.

## 6. Repertoire tree in memory (`chess_core`)

```dart
final class TreeNode {
  final int id;            // == nodes.nodeId
  final TreeNode? parent;
  final List<TreeNode> children; // PGN order
  final int ply;
  final String? san, uci;
  final String fen;
  final bool isUserMove;
  final MoveComment? comment;    // why/plan/watch/alt/shapes
}
final class RepertoireTree { final TreeNode root; final Side userSide; final List<Line> lines; TreeNode node(int id); }
final class Line { final String key; final List<TreeNode> path /* excluding root */; final int branchPly; final String label; }
```
`RepertoireTree.fromRows(rows)` builds in O(n); `RepertoireTree.fromPgn(text, side)` (import path) returns the tree plus an `ImportReport`.

## 7. Migrations

Drift `schemaVersion` starts at 1 (P03). Every change: bump, add `MigrationStrategy.onUpgrade` step, export schema (`dart run drift_dev make-migrations`), add a generated migration test. Derived tables may be dropped and rebuilt in a migration (call `StatsDeriver.rebuildAll()` after) instead of migrating data.

## 8. Storage estimate

1 run with 10 graded moves ≈ 1.5 KB in SQLite. 20 runs/day for 3 years ≈ 22k runs ≈ 33 MB. Acceptable; no pruning. Indexes keep per-line queries O(log n).
