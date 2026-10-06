# P03. Persistence: database, repositories, settings

**Depends on:** P02.
**Read first:** [03-data-model.md](../03-data-model.md) (all), [02-architecture.md §3-§5](../02-architecture.md), [01-product-spec.md §10](../01-product-spec.md).

## Goal
The drift database with every table, typed repositories the controllers will use, the settings store, and stats derivation wired to writes.

## Tasks
1. `core/db/app_database.dart`: all tables of [03-data-model.md §2](../03-data-model.md) with indexes; `schemaVersion = 1`; opened via `drift_flutter` `driftDatabase(...)` in a background isolate; WAL; `PRAGMA foreign_keys` not used (no FKs, by design for sync). Export schema to `drift_schemas/` and add the drift migration test scaffold.
2. Repositories (`core/db/repositories/`), each with an abstract interface for fakes:
   - `RepertoireRepository`: `watchSummaries()` (Home: name, colour, line count, accuracy, due count, weak count, lastTrainedAt) as a single SQL query joined with aggregated `line_stats`; `create(name, color, ImportResult)` (one transaction: repertoire row + nodes + lines + empty derived stats); `reimport(id, ImportResult)`; `rename`; `softDelete` / `undoDelete`; `get(id)`; `loadTree(id)` → `RepertoireTree.fromRows` (cached in `RepertoireCache`, LRU 3).
   - `RunRepository`: `insertRun(RunRecord)` transaction (run + grades + deviation), `runsForRepertoire(id)`, `recentStartedLineKeys(id, n)`, `unsyncedRuns()`, `markSynced(ids, at)`, `insertIfAbsent(List<RunRecord>)`.
   - `StatsRepository`: `watchLineStats(repertoireId)`, `replaceDerived(repertoireId, List<LineStats>)`, `upsertDerived(...)`.
   - `SettingsRepository`: typed getters/setters + `watch` streams for every setting in [01-product-spec.md §10](../01-product-spec.md) with defaults; `AppSettings` freezed snapshot.
   - `SyncStateRepository`: key/value.
3. `StatsService`: after `insertRun`, derive affected lines incrementally (P02 `deriveLines`) and upsert; after create/reimport, full derive; on threshold or day-start setting change, full derive for all repertoires. Large derivations in `Isolate.run`.
4. Device identity: `deviceId` created on first launch in `sync_state`.
5. Riverpod providers for all of the above in `core/db/providers.dart`; overridable for tests.
6. In-memory DB factory for tests (`NativeDatabase.memory()`).

## Tests
- Each repository method against an in-memory DB, including transaction rollback on failure (inject an exception mid-transaction).
- `create` then `loadTree` equals the imported tree (nodes, comments, shapes, lines).
- `watchSummaries` emits updated values after a run insert.
- Stats after a sequence of runs equal pure-derivation results from P02.
- Re-import: runs untouched; stats re-attributed (extended/archived) correctly.
- Soft delete hides from summaries; undo restores.
- Settings defaults and persistence; changing weak thresholds triggers re-derivation.
- Migration test scaffold passes for v1.
- Performance: inserting the nodes of a 1,000-line repertoire < 300 ms on CI (batch insert).

## Acceptance criteria
- All tests green; no DB call on the UI isolate except through drift's isolate.
- `RepertoireRepository.loadTree` for the 1,000-line synthetic repertoire < 150 ms on CI.

## Out of scope
UI.
