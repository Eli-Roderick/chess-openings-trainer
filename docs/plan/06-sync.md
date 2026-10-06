# 06. Google Drive sync and backup

## 1. Decisions (answers the open question in requirements)

| Question | Decision | Reason |
|---|---|---|
| Where on Drive | **`appDataFolder`** (hidden app-private folder), scope `https://www.googleapis.com/auth/drive.appdata` only | Narrowest scope; the app cannot see or touch any other Drive file, and the user cannot accidentally edit sync files. Human-readable copies are covered by Export backup. |
| File layout | **Each device writes only its own files**: one meta file plus monthly run logs | No two devices ever write the same file, so there are no write races and no locking. |
| What syncs | Repertoires (incl. PGN, tombstones) and runs (with grades and deviation events) | Everything else is derived ([03-data-model.md §1](03-data-model.md)). |
| What does not sync | Settings, tree/line caches, line stats, local UI state | Settings are per-device on purpose (phone vs desktop board size, threads, sounds). Derived data is recomputed after merge. |
| Conflict rule | Repertoires: per record, newest `updatedAt` wins, tie → larger `updatedBy` deviceId. Runs: immutable, union by id. | Matches "per record, newest change wins" from requirements. Runs never conflict. |
| Triggers | App start, app going to background, 30 s after a local change (debounced), manual Sync now | Covers phone→PC hand-off without background services. |
| Offline queue | Implicit: unsynced runs have `syncedAt == null`; repertoire changes compare against last uploaded meta hash | No separate queue table to get out of step. |

## 2. Records

`RepertoireRecord` JSON:
```json
{"id":"uuid","name":"Italian","color":"w","pgn":"...","pgnHash":"sha256","description":null,
 "createdAt":1759700000000,"updatedAt":1759700000000,"updatedBy":"device-uuid","deleted":false}
```
`RunRecord` JSON (one per line in run logs):
```json
{"id":"uuid","repertoireId":"uuid","lineKey":"16hex","ucis":"e2e4 e7e5 ...","mode":"random","startPly":0,
 "wrongMoveMode":"retry","startedAt":0,"finishedAt":0,"localDay":"2026-10-06","completed":true,"deviated":false,
 "gradedCount":5,"creditSum":4.5,"hintCount":0,"deviceId":"uuid","schema":1,
 "grades":[{"ply":1,"expected":"e2e4","accepted":"e2e4","firstAttempt":"e2e4","result":"correct","credit":1,"attempts":1,"hintLevel":0,"checkCp":null,"checkStatus":null}],
 "deviation":null}
```
Serialization lives in `chess_core/sync/codec.dart` (pure), shared with backup.

## 3. Drive files (all in `appDataFolder`)

| Name | Content | Written by |
|---|---|---|
| `rt1-<deviceId>-meta.json.gz` | `{"format":"rt-sync-meta","schema":1,"deviceId","deviceName","appVersion","writtenAt","repertoires":[RepertoireRecord…]}`. All repertoires this device knows, tombstones included. | that device |
| `rt1-<deviceId>-runs-<YYYY-MM>.jsonl.gz` | RunRecords created by that device, finishedAt in that UTC month (abandoned runs included, since they feed the exclusion rule and keep history honest) | that device |

`rt1` is the format generation. A device that finds a file with `schema` higher than it supports skips it and shows "Another device uses a newer app version. Update this device." (sync otherwise continues).

## 4. Sync algorithm (`features/sync/sync_service.dart`, merge logic in `chess_core/sync/merge.dart`)

```
sync():
  guard: enabled && signed in; single-flight mutex; status = syncing
  files = drive.list(spaces=appDataFolder, fields=id,name,md5Checksum,modifiedTime,size)
  # 1. pull
  for f in files where f.name starts with 'rt1-' and deviceIdOf(f) != myDeviceId and f.md5 != cached md5(f.name):
      bytes = drive.download(f.id); records = decode(bytes)            # in isolate
      if meta: mergeRepertoires(records.repertoires)                   # LWW
      if runs: insertRunsIfAbsent(records.runs)                         # skips runs of tombstoned repertoires;
                                                                        # runs of not-yet-known repertoires are kept (meta files are processed first)
      cache md5(f.name) after the DB transaction commits
  # 2. apply effects
  for repertoires whose winning record changed locally:
      if deleted: delete local nodes, lines, line_stats and runs of that repertoire
      elif pgnHash changed: rebuild nodes/lines from pgn (isolate)
  rederive line_stats for every repertoire that got new runs or a new pgn
  # 3. push
  meta = encode(all local repertoire records)
  if hash(meta) != sync_state.lastMetaHash: upload or create rt1-<me>-meta.json.gz; store hash
  for month in months of local runs with deviceId == me and syncedAt == null:
      content = all my runs of that month (from DB, not incremental append)
      upload/create rt1-<me>-runs-<month>.jsonl.gz; set syncedAt for those runs
  status = ok(lastSyncAt = now)
on error: status = error(kind); keep partial progress (each step is idempotent); retry on next trigger
```
Merge properties (unit-tested, property-based with random record sets): commutative, associative, idempotent, and the result is independent of file processing order.

Run cost: rewriting a month file is fine (a heavy month is a few hundred KB gzipped). First sync on a new device downloads everything once; afterwards only changed files (md5 differs).

Clock skew: LWW uses wall-clock `updatedAt`. A device with a wrong clock can win or lose renames/re-imports incorrectly; runs are unaffected. Accepted for a single-user app; documented in the Sync settings help text.

Concurrent re-import of the same repertoire on two devices: the later `updatedAt` wins; runs from both devices are kept and attributed to lines by move sequence, so nothing is lost except the losing PGN text. The losing device shows a SnackBar after sync: "<name> was updated from another device."

## 5. Authentication

### 5.1 Android
`google_sign_in` 7.x: `GoogleSignIn.instance.initialize(serverClientId: <web client id>)` at sync enable, `authenticate()` on "Sign in", then `authorizationClient.authorizeScopes([driveAppdataScope])` for an access token (interactive the first time, silent afterwards via `authorizationForScopes`). Build an authenticated `http.Client` for `googleapis` from the access token (`googleapis_auth` `authenticatedClient` with `AccessCredentials`); refresh by asking `authorizationClient` again when a call returns 401. Store nothing sensitive ourselves.

### 5.2 Windows (and Linux dev)
`google_sign_in` does not support Windows. Use `googleapis_auth` installed-app flow: `clientViaUserConsent(ClientId(desktopClientId, desktopClientSecret), [scope], (url) => launchUrl(url))`; it runs a loopback server on 127.0.0.1 and uses the system browser. Persist the resulting `AccessCredentials` (incl. refresh token) as JSON in `flutter_secure_storage`; rebuild with `autoRefreshingClient` on start. Save refreshed credentials via the client's `credentialUpdates` stream.

### 5.3 Config
OAuth client ids come from `config/google_oauth.json` (gitignored) via `--dart-define-from-file`:
```json
{"GOOGLE_ANDROID_SERVER_CLIENT_ID":"...apps.googleusercontent.com",
 "GOOGLE_DESKTOP_CLIENT_ID":"...apps.googleusercontent.com",
 "GOOGLE_DESKTOP_CLIENT_SECRET":"..."}
```
If ids are missing at build time, the Sync section shows "Sync is not configured in this build" and everything else works. Google treats the desktop client secret as non-confidential; it is still kept out of the repo. CI release builds get it from repository secrets.

### 5.4 One-time Google Cloud setup (Eli does this; P12 agent writes it as `docs/GOOGLE_SETUP.md` with screenshots-free steps)
1. console.cloud.google.com → new project "Repertoire Trainer".
2. APIs & Services → Library → enable **Google Drive API**.
3. OAuth consent screen (Google Auth Platform): External, app name, support email, add scope `.../auth/drive.appdata`, add your own Google account as a test user, then **Publish app** (set status to "In production"). In "Testing" status Google expires refresh tokens after 7 days, which would force a re-login every week. An unverified production app still works for its owner after the "Google hasn't verified this app" click-through.
4. Credentials → Create OAuth client → **Android**: package `dev.eliroderick.repertoiretrainer`, SHA-1 of the signing key (`keytool -list -v -keystore <release keystore>`; also add the debug keystore SHA-1 for debug builds).
5. Credentials → Create OAuth client → **Web application** (only its client id is used, as `serverClientId`).
6. Credentials → Create OAuth client → **Desktop app** (client id + secret for Windows).
7. Put the three values into `config/google_oauth.json` and the repository secrets.

## 6. Triggers and UI

- Start: 3 s after first frame if enabled.
- Background: on `AppLifecycleState.paused` (Android) / window minimize or close (Windows: on close, sync with a 5 s cap before exit, best effort).
- Local change: run persisted, repertoire created/renamed/re-imported/deleted → debounce 30 s.
- Manual: Sync now (settings, and tapping the Home sync icon).
- Never during an active drill line (deferred until the line ends) to keep the UI isolate free; network and decode happen off the UI isolate anyway, but DB writes and re-derivation are deferred.
- Settings section shows: toggle, account email, last sync time and result, Sync now, Sign out (stops syncing, keeps local data), **Delete cloud data** (confirm; deletes all `rt1-*` files in appDataFolder for all devices; local data kept).

## 7. Errors

| Error | Behaviour |
|---|---|
| No network / timeout | status "Offline, will retry"; retry on next trigger |
| 401 after refresh attempt | status "Sign in again" with button |
| 403 quota / rate limit | exponential backoff 2, 4, 8 s within the sync, then give up until next trigger |
| Corrupt remote file | skip file, log, status warning naming the device |
| Newer schema | skip file, warning as §3 |

## 8. Backup file (manual export/import)

- File: `repertoire-trainer-backup-YYYYMMDD-HHMM.rtbackup` = gzip of JSON:
  `{"format":"rt-backup","schema":1,"exportedAt","appVersion","deviceId","repertoires":[…non-deleted…],"runs":[…all…],"settings":{…}}`
- Export: Settings → Sync and backup → Export backup → save dialog (Android SAF / Windows dialog). Encode in isolate.
- Import: pick file → validate format/schema → dialog: **Merge** (default; same merge as sync; settings untouched unless "Also restore settings" is ticked) or **Replace all** (deletes local repertoires and runs first; confirm with the counts). If Drive sync is on, Replace warns that the next sync brings back data from other devices unless "Delete cloud data" is also used.
- Round-trip test: export → wipe → import → identical DB content (excluding local-only columns).
