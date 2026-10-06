# P12. Google Drive sync

**Depends on:** P11. Needs Eli to complete the Google Cloud setup in [06-sync.md §5.4](../06-sync.md) before the device checklist (the code and tests do not need it).
**Read first:** [06-sync.md](../06-sync.md) (all).

## Goal
Opt-in Drive sync between Eli's phone and PC using the appDataFolder, per-device files, LWW repertoires and run union.

## Tasks
1. `DriveTransport` interface: `list()`, `download(id)`, `create(name, bytes)`, `update(id, bytes)`, `deleteAll(prefix)`; `GoogleDriveTransport` (googleapis Drive v3, `spaces: 'appDataFolder'`, parents `['appDataFolder']`, fields `files(id,name,md5Checksum,modifiedTime,size)`, paging) and `FakeDriveTransport` (in-memory, computes md5).
2. Auth: `AndroidDriveAuth` (google_sign_in 7.x per [06-sync.md §5.1](../06-sync.md)) and `DesktopDriveAuth` (googleapis_auth loopback flow, credentials persisted in `flutter_secure_storage`, per §5.2), behind `DriveAuth` interface; config via `--dart-define-from-file` (§5.3) with the "not configured" state.
3. `SyncService` implementing the algorithm in [06-sync.md §4](../06-sync.md) using P11 codec/merge/applier: single-flight mutex, md5 cache in `sync_state`, meta hash, monthly run files, `syncedAt` marking, error mapping (§7), backoff.
4. Triggers per §6 (start, background/close, debounced local changes, manual), deferred while a drill line is in progress. When a merge changes a repertoire that is open (drill, browse, stats), `RepertoireCache` is invalidated and the screen reloads its tree; a drill reloads before its next pick, and if the repertoire was deleted it exits to Home with a SnackBar.
5. UI: Settings → Sync and backup (toggle, sign in/out, account, last sync, Sync now, Delete cloud data with confirmation), Home sync icon states, SnackBar "<name> was updated from another device", newer-schema warning.
6. `docs/GOOGLE_SETUP.md` from [06-sync.md §5.4](../06-sync.md); README section on building with `config/google_oauth.json`; release workflow reads secrets into the config file.
7. Diagnostics: Sync section (deviceId, last results, remote file list with sizes).

## Tests
- SyncService with two simulated devices (two in-memory DBs, two deviceIds) on one `FakeDriveTransport`: convergence after alternating syncs; rename conflict newest wins; delete propagates; runs never duplicated; second sync with no changes downloads nothing and uploads nothing; newer-schema file skipped with warning; network failure mid-sync then retry converges.
- Trigger tests with fake clock (debounce, deferral during a line).
- Auth classes tested with mocked plugins (no network).
- Integration flow 16.

## Acceptance criteria
- All tests green; sync never runs on the UI isolate for decode/merge; a failed sync never loses local data (test: transport throws at each step in turn; DB unchanged or consistently advanced).

## Device checklist (Eli)
- [ ] Complete Google Cloud setup (docs/GOOGLE_SETUP.md).
- [ ] Enable sync on the phone, train 3 lines; enable on Windows: repertoires and stats appear.
- [ ] Train on Windows; reopen phone: stats and streak include those runs.
- [ ] Rename a repertoire on one device; it updates on the other after sync.
- [ ] One week later, sync still works without signing in again (confirms the "In production" consent setting).
