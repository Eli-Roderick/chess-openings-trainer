# P11. Backup export/import and sync core

**Depends on:** P03 and P04 (can run in parallel with P05-P10).
**Read first:** [06-sync.md §1-§4, §8](../06-sync.md), [03-data-model.md §1](../03-data-model.md), [11-decisions.md D-04, D-05, D-06](../11-decisions.md).

## Goal
The record codec and merge logic shared by sync and backup, and the working manual backup feature.

## Tasks
1. `chess_core/sync/records.dart`: `RepertoireRecord` (RunRecord exists from P02), JSON per [06-sync.md §2](../06-sync.md).
2. `chess_core/sync/codec.dart`: encode/decode meta files, run-log files (JSONL), backup files; gzip via `dart:io` `gzip` (codec functions take/return bytes; keep `dart:io` usage behind a small adapter so the rest stays platform-neutral); schema checks returning typed errors.
3. `chess_core/sync/merge.dart`: `mergeRepertoires(local, remote) → (winners, changedIds)` with LWW + tie-break; run union; tombstone effects described as data (`MergeEffects {rebuildTrees, deleteRepertoires, rederive}`).
4. App `features/backup/`: Export backup (isolate encode, save dialog, default filename), Import backup (pick, validate, Merge / Replace all dialog with counts and the sync warning, "Also restore settings"), progress and result SnackBars.
5. `MergeApplier` in `core/db`: applies merge results in one transaction, rebuilds trees for changed PGNs (isolate import of stored PGN), deletes tombstoned data, triggers re-derivation. Shared with P12.
6. Settings → Sync and backup: backup buttons (sync part stays "Coming soon" until P12).

## Tests
- Codec round trips for all record types; corrupt gzip / wrong format / newer schema → typed errors.
- Merge property tests (random record sets, 500 iterations, seeded): commutative, associative, idempotent, order-independent.
- Tombstone cases: delete wins when newer; rename after delete on another device (older) loses; runs of tombstoned repertoires skipped.
- MergeApplier: PGN change rebuilds tree and re-derives; stats identical to a fresh derivation.
- Integration flow 15 (backup round trip).

## Acceptance criteria
- Export → wipe → import (merge) reproduces identical repertoires, runs and derived stats.
- Backup of 20k runs exports < 3 s and imports < 5 s on Linux CI.

## Device checklist (Eli)
- [ ] Export a backup on the phone, import it on Windows (merge): same repertoires and stats.
