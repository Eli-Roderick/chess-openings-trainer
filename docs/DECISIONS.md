# Decision log

Running log of decisions. Seeded in P00 from `docs/plan/11-decisions.md` (the planning thread); build agents append below, newest phase last. Decisions Eli made are in `docs/plan/requirements.md` and are not repeated.

## Corrections and refinements to requirements.md

`requirements.md` belongs to the interview thread and was not edited. Where this plan departs from a *default* recorded there (never from one of Eli's own decisions), it is listed here.

| # | requirements.md says | Plan does | Why |
|---|---|---|---|
| C-1 | Opponent deviations: "configurable chance per opponent move (default 10%)" Chance **per line**, default 25 %, at most one per run, and **by default only after the line's last book move** (Eli, 2026-10-06: "a line should never deviate until the end of the line"). Mid-line deviations are an optional setting. (D-07) | 10 % per move means a typical line with 8 opponent moves deviates 57 % of the time. Eli wants every line to always play out the same. |
| C-2 | Performance: "opponent reply shown within 300 ms" | Opponent delay default **250 ms** (adjustable 0-1500) | A longer default delay would break the target by design. |
| C-3 | Re-import: stats kept for lines matched by move sequence; removed lines archived | Adds **extended lines**: if an old line is now a prefix of new lines, its history carries over to them (accuracy, weak pool), SRS restarts for them (D-11) | Extending a line is the most common edit; dropping its history would punish adding depth. |
| C-4 | Go straight to the next line by default | An end bar shows for 1.5 s (auto-advance, any tap cancels) with Play on and Summary buttons; set the delay to 0 for an immediate jump (D-14) | Play on vs engine ("I really like c") needs a place to be offered without forcing the summary screen. |

## Decisions

**D-01 SRS parameters.** SM-2 per line: pass = run accuracy ≥ 90 % (from requirements); intervals 1 d, 4 d, then × ease; ease starts 2.5, +0.10 on a perfect run, unchanged at 90-99 %, -0.20 on a fail, clamped 1.3-3.0; fail → relearn the same day; ±10 % deterministic fuzz from 4 days; cap 180 days; 10 new lines/day in PGN order; no review cap by default. Why: 4 d instead of SM-2's 6 d because opening lines interfere with each other (similar move orders), so early spacing should be tighter; deterministic fuzz keeps devices in agreement after sync; file order introduces related lines together.

**D-02 SRS and weak pool interaction.** They are independent derived views over the same runs. A failure in Random/Weak/Single mode pulls a line's SRS due date to today but does not change ease or count a lapse. Why: forgetting found anywhere should surface in SRS; extra practice elsewhere must not push the schedule out.

**D-03 Engine time budget.** Comparable checks search at least 1.0 s and depth 12, at most 2.5 s; no scaling down on slow phones. Why: the check is asynchronous, so slowness costs banner latency only, while shallow searches would give wrong half-credits. Calibration warns if a device is slow.

**D-04 Drive sync design.** `drive.appdata` scope, per-device files (meta + monthly run logs), LWW for repertoires, union for runs. Why: narrowest permission, no concurrent writes to one file, and no stats conflicts at all.

**D-05 Settings are device-local.** Why: phone and desktop want different board, engine and sound settings; nothing in requirements asks for settings sync.

**D-06 Stats are derived from immutable runs.** Accuracy, weak pool, SRS and streak are recomputed from run history. Why: makes sync, backup merge, threshold changes and re-imports correct by construction.

**D-07 Deviation mechanics.** See C-1. Default timing is end of line: the line is played and graded in full, then (on a hit) the opponent plays an engine move off the end of the book, or the user must find a move if the line ended on an opponent move. Optional timing "Anywhere in the line" keeps mid-line deviations. Candidates: engine MultiPV 5, moves within 1.00 pawn of the best, weighted towards the best. A reply passes if it loses ≤ 0.50 pawn vs the engine's best. Challenge results count only in deviation stats. End-of-line runs are ordinary runs for accuracy, weak pool and SRS; a mid-line deviated run never counts as an SRS review or a clean run, because the rest of the line was not played.

**D-08 Restart mode keeps first grades.** After a restart, already graded plies are not re-graded within the run. Why: the grade measures first-try knowledge; regrading would let a restart erase a mistake.

**D-09 Restart mode restarts on any non-repertoire move, comparable or not.** Why: waiting for the engine before deciding would block the board; the half credit is still applied when the check returns.

**D-10 Abandoned runs are stored but excluded from stats.** They still count for the "last 3 lines" exclusion. Why: quitting a bad run should neither help nor hurt.

**D-11 Extended lines inherit history.** See C-3.

**D-12 Multi-game PGNs are merged into one tree.** Why: lets an AI split long repertoires across games and accepts lichess study exports unchanged.

**D-13 Accuracy is move-weighted across the last 10 runs; overall repertoire accuracy is the mean of line accuracies.** Why: short branch-point runs shouldn't count as much as full runs; at repertoire level each line should matter equally.

**D-14 End bar.** See C-4.

**D-15 Branch point = deepest fork on the line that still has a user move after it.** Why: everything before it is shared with other lines and is trained through them.

**D-16 Clean run = every graded move credit 1.** Half credit is not clean. Why: leaving the weak pool should require the repertoire move itself.

**D-17 Weak pool entry only after a non-clean run.** Why: hysteresis; without it a line leaving after 3 clean runs re-enters at once because older failures are still in its 10-run window.

**D-18 Board and rules from lichess (`chessground`, `dartchess`), therefore GPL-3.0.** Stockfish already forces GPL. Why: the board is the centrepiece; these packages are the most polished available.

**D-19 Stockfish via `Process` on all platforms, Android binary from `nativeLibraryDir`.** FFI is the fallback. Why: one code path, testable on Linux CI.

**D-20 Linux desktop as a dev/CI target.** Not shipped. Why: build agents need to run the real app and engine end to end without a phone.

**D-21 Day starts at 04:00 (setting).** Applies to streak and SRS days. Why: late-night sessions belong to the evening they started in.

**D-22 Working name "Repertoire Trainer", id `dev.eliroderick.repertoiretrainer`.** Rename is cheap until release (P13).

**D-23 Line identity = SHA-256 of the UCI sequence (16 hex chars); runs store the full sequence.** Why: stable across comment edits, and lets stats follow line extensions and survive any PGN version on any device.

**D-24 No notifications, no analytics, no crash service.** Logs are local and exportable.

**D-25 Dark theme by default.** Requirements ask for dark mode; Eli emphasised the board, which reads best on a dark surround. Light and System are available.

## P00 (repository bootstrap)

Details of the plan corrections are in `docs/plan/corrections/P00.md`.

**D-26 Stockfish pinned to sf_18.** The plan named 17.1 as "latest at the time of writing". The newest tag, `sf_19`, has no release assets under the names in 05-engine.md §1; `sf_18` has all five. URLs, archive and binary SHA-256 are in `engine/checksums.json`.

**D-27 Package versions.** Every package was added at its latest stable version at bootstrap (`chessground` 10.3.0, `dartchess` 0.14.0, `very_good_analysis` 11.0.0; full list in `docs/DEPENDENCIES.md`). `archive` is a root dev dependency used only by `tool/fetch_engines.dart` (allowed by P00 task 9).

**D-28 Constructor syntax.** Flutter 3.47.6 / Dart 3.13.5 with very_good_analysis 11 enables `unnecessary_type_name_in_constructor`, so constructors are written `const new({super.key});`, `new named()` and `factory fromJson(...)`. CI runs `--fatal-infos`, so the old `ClassName(...)` form fails the build. Later phases: if a code generator (freezed, drift) cannot handle the new form in hand-written source, disable the rule for that file with an `// ignore_for_file:` comment and record it here.

**D-29 Generated l10n lives in `lib/l10n/gen`.** `synthetic-package` no longer exists; `l10n.yaml` sets `output-dir: lib/l10n/gen`, the files are committed (CI checks they are current) and excluded from analysis. `pubspec.yaml` has `flutter: generate: true`.

**D-30 Workspace root has no `resolution: workspace`.** Only `packages/chess_core` and `packages/uci_engine` declare it; the root declares `workspace:`.

**D-31 Engine-tagged tests are opt-in.** Tests that need the real Stockfish binary carry the `engine` tag (declared in `packages/uci_engine/dart_test.yaml`). The checks job runs `dart test --exclude-tags engine`; the engine-integration job fetches the binary and runs `dart test --tags engine`.

**D-32 Desktop CMake installs the engine at install time.** `windows/CMakeLists.txt` and `linux/CMakeLists.txt` create `engine/<platform>/` at configure time and use `install(DIRECTORY ... FILES_MATCHING ...)`, so `<bundle>/engine/` always exists, builds without fetched engines succeed, and engines fetched after the first configure are still bundled (a configure-time `file(GLOB)` would miss them). Linux installs `stockfish` with execute permissions.

**D-33 Android release key is generated by Eli, not the agent.** The agent cannot set repository secrets, and a private signing key should not pass through an ephemeral cloud container or a chat. Eli generates `release.jks` locally with the exact `keytool` command from P00 task 10 and adds `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEY_PROPERTIES` (steps in the P00 PR). Until then CI builds debug-signed APKs and warns. CI always writes the keystore to `android/release.jks` and overrides `storeFile=release.jks`, so the secret's `storeFile` value does not matter. `release.yml` fails without the secrets. The CI log prints the signing certificate's SHA-1 for the P12 OAuth client.

**D-34 Android application id has no underscore.** `applicationId` and `namespace` are `dev.eliroderick.repertoiretrainer` (D-22); `MainActivity.kt` moved to that package. The Linux GTK application id was changed to match. Dart package name stays `repertoire_trainer`.

**D-35 CI shape.** A composite action (`.github/actions/setup-flutter`) reads `.flutter-version`, installs that Flutter with `subosito/flutter-action` (SDK and pub cache cached) and runs `flutter pub get`; every job uses it. Gradle is cached by `actions/setup-java`, `engine/.cache` per platform keyed on `engine/checksums.json`. The integration job has one smoke test (`integration_test/app_test.dart`, app boots to Home) so it runs real code from day one. Releases attach both ABI APKs (arm64-v8a for Eli's phone, armeabi-v7a for old 32-bit phones) and the Windows zip.

## P01 (PGN import, comments, validation, lines)

Details of the plan corrections are in `docs/plan/corrections/P01.md`.

**D-36 Own strict PGN reader.** `chess_core/lib/src/pgn/pgn_reader.dart` tokenizes PGN itself (tag pairs with escapes, `{}` and `;` comments, `%` escape lines, RAV, move numbers incl. `1...`/`1…`, NAGs and `!?` glyphs, zero castling, `--`/`Z0` null moves, results) and reports unknown tokens, unterminated comments and unbalanced parentheses as E-PARSE with the game index and the path to the last move, then resumes at the next game. Why: dartchess's parser skips invalid input silently and its game-splitting regex breaks games at indented `[%` comment lines. dartchess is still used for SAN legality (ambiguous SAN is rejected), canonical SAN (check marks added, glyphs dropped) and FEN.

**D-37 Malformed comment rule.** A comment is W-MALFORMED when `[%` remains after removing every well-formed tag; its text is stripped of tag markers and brackets and appended to Why. Plain and loose text used as Why has `[`/`]` replaced by parentheses, so exported comments re-import identically. A comment holding only `[%clk]`, `[%eval]`, `[%cal]` or `[%csl]` is not malformed (W-NO-WHY on a user move).

**D-38 I-COMMENT-BEFORE-IGNORED.** New info code for a variation-start comment that cannot be attached (the move is an opponent move or has its own comment).

**D-39 Merging comments.** The first non-empty comment of a move wins. A later game's comment that parses to a different `MoveComment` is W-CONFLICT (once per move and game); differences only in ignored tags or whitespace are not. An empty first comment (`{}` or only `[%clk]`) is replaced by a later non-empty one. Duplicate siblings in one game keep the first comment without a conflict warning. NAGs are merged without duplicates.

**D-40 Opponent comments and aggregated items.** Opponent moves' comments are parsed and stored like user moves' (the UI shows only user moves'); per-comment warnings are reported for user moves only, opponent comments count towards I-OPP-COMMENT. Lines without any user move get W-NO-USER-MOVE and are not also counted in I-ENDS-OPP. E-EMPTY is reported only when there is no other error (an unreadable or rejected game already explains the empty tree). Report items are in node preorder within each group of checks.

**D-41 Import API.** `importPgn(String, Side)` and `importPgnBytes(List<int>, Side)` return `ImportResult {tree, report, elapsed}`; the tree is null when the report has errors. Bytes: UTF-8 (BOM stripped) with Latin-1 fallback; line endings normalized to `\n`; E-SIZE above 10 MiB (10 × 1024 × 1024 bytes). Accepted starts: no `FEN` header or one whose first four fields equal the initial position; `Variant` absent, `Standard` or `chess` (case-insensitive). The repertoire description is the whitespace-collapsed comment before the first move of game 1.

**D-42 Tree immutability.** `TreeNode` is built parent-first through an `@internal` constructor and `addChild`; `children` is an unmodifiable view, so app code cannot change a tree. `RepertoireTree.fromRows` validates that rows are a preorder tree (ids, parents, child indices) and throws `FormatException` otherwise. `NodeRow`/`LineRow` mirror the `nodes`/`lines` tables (03 §2) including the `shapes` JSON and `nags` text columns.

**D-43 Synthetic PGNs and coverage gate.** `generateSyntheticPgn` lives in `chess_core` (used by the package's benchmark test and by `tool/gen_synthetic_pgn.dart` / `tool/bench_import.dart`); it is seeded and biased towards central and developing moves. The 1,000 × 16 benchmark test measures a cold (first) import and asserts < 1.0 s. CI runs `chess_core` tests with `--coverage` and `tool/check_coverage.dart` (reads VM coverage JSON, no new dependency) requires ≥ 90 % for `lib`, `lib/src/pgn` and `lib/src/tree`.

## P02 (training logic)

Details of the plan corrections are in `docs/plan/corrections/P02.md`. SRS expectations in `srs_scenarios_test.dart` were generated by an independent Python implementation of 04 §5.2-5.3 (15 scenarios), not by the Dart code under test.

**D-44 Weak-mode exclusion counts pool lines only.** The recent-start list is filtered to weak-pool lines before taking the `min(3, poolSize - 1)` most recent.

**D-45 SRS ease is kept to two decimals.** After every ease change the value is rounded to 0.01 (steps are 0.10/0.20, so this is exact) and `ceil(interval × ease)` subtracts 1e-9 first, so float noise never adds a day to an interval.

**D-46 freezed syntax under the constructor lint.** `const factory({...}) = _Name;`, `factory fromJson(...)`, `const new _();`. `RunRecord`, `MoveGrade` and `DeviationEvent` use freezed + json_serializable in `chess_core` (generated `run.freezed.dart`/`run.g.dart` committed; CI regenerates them in `packages/chess_core` and fails on a diff). Other value types (`SrsState`, `WeakPoolState`, `LineStats`, `Streak`, picks) are small hand-written immutable classes.

**D-47 Derivation API.** `deriveRepertoire({lines, runs, settings})` and `deriveLines({keys, lines, runs, settings})` take runs in any order and sort by (`finishedAt`, `id`). `LineStats` holds a `WeakPoolState` and an `SrsState` plus run count, accuracy and last played time, and exposes the `line_stats` column values. Archived keys appear for any run that matches no current line (accuracy and run count over its eligible runs; no weak pool or SRS).

**D-48 Engine judgement maths is pure and lives in `chess_core`.** `scoreToCp`, `judgeComparable`, `deviationCandidates`, `pickDeviation` and `judgeReply` implement 04 §7 over plain numbers; `ComparableOutcome` is what the engine layer hands to grading.

**D-49 Grading details.** A hint after a correct first attempt is ignored (the ply is done). A comparable result arriving after a hint records `checkCp`/`checkStatus` but does not restore credit. In Restart mode `RunBuilder.restart()` freezes graded plies: later attempts and hints do not change them, a pending comparable check still applies (D-09). `finish()` turns pending checks into `timeout` and ignores later results. `hintCount` counts graded plies with a hint.

**D-50 SRS picker semantics.** `pickSrs` is called once per pick with the session pick index (every 4th pick prefers a new line). The daily review limit is checked first. Excluded (recent) lines are skipped when any other due or new line exists. `SrsCaughtUp` carries the earliest future due day and how many lines fall on it. Lines without user moves are never picked.

**D-51 Runs and time in `chess_core`.** `Clock` (`SystemClock`, `FakeClock`) and `Rng` (`SeededRng`, `SystemRng`) are in `util/`; an architecture test fails on `DateTime.now(` or `Random(` in any package `lib/` file outside `util/`. The synthetic PGN generator now uses `SeededRng`. `localDay` subtracts the day-start hour with calendar arithmetic (not a `Duration`), so DST changes cannot shift the date.

## P03 (persistence)

Details of the plan corrections are in `docs/plan/corrections/P03.md`.

**D-52 Table naming.** drift's default snake_case SQL names (`repertoire_id`, `line_stats`, ...) stand for the camelCase column names in 03 §2; data classes are prefixed `Db` (`DbRun`, `DbLine`, ...) so they never clash with chess_core's `Line`, `MoveGrade` or `DeviationEvent`. No foreign keys.

**D-53 Database file.** `repertoire.sqlite` in the app support directory, opened by `drift_flutter` on a background isolate shared across isolates, `journal_mode=WAL`. The database opens lazily; `main()` reads the device id after the first frame, which creates it on first launch, then starts the stats service.

**D-54 Bulk inserts.** Nodes and lines are written with multi-row `INSERT` statements (50 rows each) inside the create/re-import transaction. 1,000 × 16 synthetic repertoire: create about 85-150 ms, `loadTree` well under 150 ms (tests assert < 300 ms and < 150 ms after one warm-up import).

**D-55 Home order.** Last trained first; never-trained repertoires after them, newest created first. Summaries come from one watched SQL query (subquery per repertoire for the line count, `line_stats` aggregated for accuracy, weak and due counts; archived keys excluded). Due counts take the caller's `today`.

**D-56 Write paths.** Runs: `StatsService.recordRun` (insert in one transaction with grades, deviation and `lastTrainedAt`, then incremental derivation of the attributed lines). Create: repertoire, nodes, lines and empty `line_stats` in one transaction. Re-import: delete/insert nodes and lines and update the repertoire in one transaction, returns `ReimportDiff`; the caller then calls `StatsService.rebuildRepertoire`. Derivations over more than 2,000 runs run in `Isolate.run`. Weak-threshold or day-start changes rebuild every repertoire.

**D-57 Settings storage.** One `settings` row per `AppSettings` field with a JSON value; only changed fields are written. Missing keys take defaults; a stored value that no longer parses (renamed enum, wrong type) is ignored instead of breaking start-up. Every numeric setting is clamped to its 01 §10 range and step. Play-on strength is `playOnElo` with 0 = full strength (a nullable field with a default could not store "full strength").

**D-58 `lastTrainedAt`.** Updated by every stored run (completed or abandoned) as the maximum `finishedAt`; it is device-local and will be recomputed from runs after a sync (P12).

**D-59 Repository interfaces.** Each repository is an `abstract interface class` with a drift implementation; Riverpod providers in `core/db/providers.dart` wire them to one `AppDatabase`. Tests use `AppDatabase.memory()` (`NativeDatabase.memory()`), a `FakeClock` and sequential ids. Transaction rollback is tested with a `@visibleForTesting` hook that throws mid-transaction.

**D-60 Schema evolution.** `build.yaml` configures `drift_dev` (schema dir `drift_schemas/`, test dir `test/drift/`). Every schema change: bump `schemaVersion`, add the `onUpgrade` step, run `dart run drift_dev make-migrations` and `dart run drift_dev schema generate drift_schemas/app_database/ test/drift/app_database/generated/`, add an upgrade test.

## P04 (app shell, Home, import)

Details of the plan corrections are in `docs/plan/corrections/P04.md`.

**D-61 Cold start is measured AOT in profile mode.** `integration_test/profile_test.dart` seeds 10 repertoires into a database file, boots the app through `bootstrap(overrides: ...)` and checks main → Home data < 1 s. CI runs it with `flutter drive --profile -d linux` because Flutter Driver cannot run desktop release builds; under `flutter test` (debug) it checks < 5 s. The timing log line is `Cold start (AOT): main -> runApp …, first frame +…, Home data +…, total … ms`.

**D-62 One app launch per integration test file.** On Linux desktop a second file in one `flutter test integration_test` invocation fails to attach, so CI names each file. New integration files need their own CI step (or their tests go into `app_test.dart`).

**D-63 Import runner.** `ImportRunner` (`lib/core/import/import_runner.dart`) streams `ImportStageReached` and one `ImportFinished(result, text)`. The app uses an `Isolate.spawn` worker (stages over a port, result via `Isolate.exit`, `kill` on cancel); widget tests use the in-process runner. File bytes go to the isolate and are decoded there; the decoded text comes back so the repository stores exactly what was validated.

**D-64 Startup path.** `main()` is `bootstrap()`: bindings, console logging (the file sink attaches in the background), licence entries, one `ProviderContainer`, `runApp`. After the first frame: frame statistics start, Android's process start time is read over `rt/native.processStartElapsedMs`, the device id is read (opening the database) and the stats service starts. `StartupTimings.markMainStart` clears earlier milestones. Home data is marked when the summaries stream first delivers.

**D-65 Repertoire names.** Trimmed, 1-60 characters. A name already used (case-insensitive) shows a warning under the field but is allowed (01 §5 does not forbid duplicates). Rename uses the same limits.

**D-66 Detail counts.** "Trained" counts current lines with at least one eligible run. "New available today" is `min(srsNewPerDay - lines first seen today, fresh trainable lines)` for this repertoire, never below 0; lines without user moves are not counted.

**D-67 Re-import shows the diff before writing.** The new PGN is imported in the worker, the diff is computed from the stored line refs and the new tree (including comment changes), and only Import writes (`RepertoireRepository.reimport` then `StatsService.rebuildRepertoire`). Colour is fixed on re-import.

**D-68 Delete and undo.** Delete asks for confirmation, soft-deletes, returns to Home and shows a 6 s SnackBar with Undo (`undoDelete`). Purging soft-deleted rows is left to the sync phases.

**D-69 Inter.** Inter 4.1 static TTFs (Regular, Medium, SemiBold, Bold) are bundled in `assets/fonts/` with the OFL text; move text uses tabular figures (`FontFeature.tabularFigures()`). The licence page lists Stockfish (GPL-3.0, source link) and Inter.

**D-70 Layout breakpoint.** `AdaptiveLayout` treats width >= 600 dp or landscape as wide; content is capped at 840 dp and centred, with 16 dp gutters. On wide layouts repertoire cards show a menu button instead of relying on long press.

## P05 (board, sounds, Browse)

Details of the plan corrections are in `docs/plan/corrections/P05.md`.

**D-71 Frame budgets on CI.** `integration_test/profile_test.dart` drags e2-e4 in Browse (20 one-frame steps, drop, Back) for 30 s in profile mode after one warm-up Forward/Back, and asserts at most one frame whose UI-thread build exceeds 16.667 ms. CI sets `LP_NUM_THREADS=1` for llvmpipe. Raster time is printed, not asserted (software rasterization on the runner). Slow builds are printed with the script step they followed.

**D-72 Board wrapper.** `RepertoireBoard` takes an immutable `BoardViewState` (FEN, orientation, movable side, last move, shapes, square highlights, animate) with value equality and drives a chessground `ChessboardController`; it is sized to the largest square that fits and wrapped in a `RepaintBoundary`. Legal moves come from dartchess `makeLegalMoves`. Premoves and user-drawn shapes are off; drag and tap-tap are both on. Each mounted board registers its `RepertoireBoardController` in `activeBoardProvider`; `debugPlayUserMove(uci)` goes through the same handler as a real move (legality and side checks included). Square overlays (hint square, the 300 ms error flash) are drawn by the wrapper, because chessground has no API for arbitrary square highlights.

**D-73 Take-back.** A wrong move is shown by setting the position after it (chessground records the drop, so the dragged piece is not animated again), then the previous FEN with `animate: true`: chessground diffs the two piece maps and translates the piece from the wrong square back to its origin (a captured piece reappears). Verified by a widget test; no custom animation is needed. Changing Animation speed applies to a board on screen (chessground updates the controller's duration in `didUpdateWidget`).

**D-74 Sounds and haptics.** `SoundService` preloads every sound after the first frame through a `SoundBackend` (flutter_soloud; a fake in tests). If audio cannot start (no device, CI), it logs once and stays silent. Volume and mute come from settings on each play. `SoundType.forSan` picks castle, check, capture or move. `HapticsService`: light after a move, medium after a mistake; nothing on Windows or when the setting is off.

**D-75 Move list.** `MoveRows.build` flattens the tree: the main line first; at a fork the first child continues the row, followed by a collapse toggle, each other child starts a variation row one level deeper, and the main line resumes on a new row with its move number. Collapsed forks show "+N". Rows are split into fixed-height lines for the width (see corrections 4). Navigating to a node inside a collapsed fork expands it; the current move is scrolled into view (30 % from the top) only when it is off screen.

**D-76 Browse details.** The start is the root or `?node=<id>` (an unknown id falls back to the root). Board orientation is the repertoire colour; F flips it for the session. Forward at a fork opens the chooser (SAN plus the first 60 characters of Why for user moves); Last follows first children to the end; ↑/↓ cycle siblings in every layout; Space and Enter also go forward; Esc leaves. Swipes (velocity > 200 px/s) on the panel below the board go forward or back. Opponent moves show "<move> · Opponent move" in the comment panel. Any move off the repertoire starts free exploration (italic SAN, "Back to repertoire" chip); Back removes the last exploration move. Comment arrows show for the current user move when "Show comment arrows" is on.

**D-77 Board settings page.** Theme and piece set are drop-downs listing every chessground colour scheme (by name) and piece set (by label). Settings are stored by name; unknown names fall back to brown and cburnett. The preview is a non-interactive `RepertoireBoard` (Italian after 3.Bc4) with the edited settings. Changing the volume plays the move sound; the haptics switch is shown on Android only.

## P06 (engine)

Details of the plan corrections are in `docs/plan/corrections/P06.md`.

**D-78 `uci_engine` API.** `UciTransport` (`ProcessTransport`, `FakeTransport`), parser (`parseInfo`, `parseBestMove`, `EngineScore`), `UciEngine` (handshake with a 5 s timeout, `setoption`, searches that set MultiPV and the position and wait for `readyok` before `go` so stale output is dropped, `stop` with a 1 s timeout after which the process is killed, `quit` then kill after 500 ms) and `EngineService` (queue). The app's `EngineJudge` applies chess_core's 04 §7 functions; engine unavailable means `ComparableOutcome.unavailable()`, no deviation candidates and no reply judgement.

**D-79 Queue and results.** One search at a time. High priority: `scoreMoves` (comparable checks), `bestLine` (reply judgement), `playMove`. Low priority: `topLines` (deviation candidates, cancellable with `EngineCancelToken`), `analyse`, `calibrate`. A high job preempts a running low job (`stop`), which is re-queued at the front of the low queue and runs again from the start. `scoreMoves` stops after `minTime` once every move has an exact line at depth 12, or at `maxTime = max(2.5 s, 2.5 × minTime)`; moves are scored by their deepest exact line. `topLines` uses the last complete iteration. The last 20 jobs (kind, run time, ok) are kept for Diagnostics.

**D-80 Crashes and lifecycle.** A crash is reported once per process (the process exit and the failing job both report it). The first crash sets `error` and the job is retried once on a fresh process; a second crash within 60 s sets `unavailable` (all queued jobs fail) until `restart()`. `pause()` (app paused or hidden) stops the running search, which is re-queued, holds the queue and quits the process after 60 s; `resume()` releases the queue and the process restarts on demand. A change of Threads or Hash restarts a running engine.

**D-81 Binary and options.** `BinaryLocator`: Android `<nativeLibraryDir>/libstockfish.so` (`rt/native.nativeLibraryDir`), Windows `<exe dir>/engine/stockfish-avx2.exe` then `-sse41.exe`, Linux `<exe dir>/engine/stockfish` then `engine/linux/stockfish` in the working directory or a parent. With several candidates each is probed (`uciok` within 3 s); the first that answers wins, and its variant is stored in `engineVariant` and tried first next time. Options per 05 §3; Threads is capped at the core count.

**D-82 Calibration.** 2 s on the start position (nps, depth), then 1 s on each of 5 opening positions (median depth). Stored under `engine.calibration` in `sync_state`; run from Engine settings or automatically once per install after 10 s with Home on top. Median depth below 12 shows the slow-device note.

**D-83 Browse analysis UI.** The toggle sits in the app bar (disabled with "Engine unavailable" as tooltip when the engine is unavailable). With analysis on, the eval bar (14 dp) sits at the board's left edge on phones and right of the board on wide layouts. The lines panel shows depth, a 1/2/3 control and per line the score (White's point of view) and up to 12 SAN moves; tapping a move plays the line up to it into free exploration. Every position change restarts the analysis on the new position; leaving the screen or toggling off cancels it; in the background the engine pauses (D-80) and the analysis continues when the app returns. PV SAN is cached per (position, line).

**D-84 Engine settings.** Status line `Stockfish 18 ready · N threads · X Mnps · variant`, or the error. Comparable threshold 0.10-1.00 pawns (step 0.05), check search time 0.5-3.0 s (step 0.1), Threads Auto or 1..cores, Hash Auto or 16-1024 MB, play-on strength 1500/2000/2500/Full, Run calibration, Restart engine.

**D-85 Profile budget with the engine.** `integration_test/profile_test.dart` runs the 30 s drag script with Browse analysis on (real Stockfish on CI). The P05 tolerance (at most one slow build) still applies.

## P07 (drill)

Details of the plan corrections are in `docs/plan/corrections/P07.md`.

**D-86 Drill controller.** `DrillController` (plain Dart `ChangeNotifier`, `lib/features/drill/`) runs the P07 state machine: loading → opponentToMove / userToMove → mistake → … → lineComplete. Every timer and async callback is tied to a run token and does nothing after the line changed or the drill closed. Dependencies come in as functions (`DrillDeps`: clock, rng, ids, settings, line stats, recent starts, `recordRun`, comparable check, effects) so the unit tests run in fake time with fakes. The screen builds the dependencies from the provider container, not the widget's `ref`, because an abandoned run is stored after the screen is disposed.

**D-87 Mistakes.** A wrong move shows the piece on the target square (board not interactive), plays the error sound and a medium haptic, flashes the square for 300 ms and queues the comparable check (first attempt only). Retry: the previous FEN is set and the piece animates home. Restart: `RunBuilder.restart()`, the board jumps to the start position under a 200 ms fade, and the opponent replays from there. A check result applies to its own run while that run is unfinished; the comparable banner shows for 4 s, prefixed with the move when the user has moved on.

**D-88 Line end.** On the last move: line-complete sound, end bar with the run's accuracy and Next line (a countdown ring; any tap on the bar stops the countdown; delay 0 goes straight on). The run is finalized in the background: up to 3 s for pending checks, then `StatsService.recordRun`; `finishedAt` is the moment the line ended. Skip line and leaving mid-line store the run with `completed = false`. Leaving after at least one completed line shows the session summary (lines, accuracy).

**D-89 Drill screen.** App bar: name · Random, flip, training settings (a sheet with the same list as Settings → Training). Info panel: "Skipped to move N" chip (tap: the skipped moves), comment panel of the last correct user move ("Your move" / "Opponent to move" otherwise), banner on top. Bottom bar: Hint / Show move, "Move N of M", run accuracy "credit/graded · %", Skip line. Wide: the right panel adds the line's moves with result marks (✓ ½ ✗ ?). Keys: H, F, Space/Enter (next line), Esc.

**D-90 Drill latency metric.** `DrillLatency` (`lib/core/diagnostics/`) keeps the last 200 user-move → opponent-move times; Diagnostics shows p50, p95 and the sample count. The profile integration run asserts p95 ≤ 300 ms with the default 250 ms delay.

## P08 (training modes)

Details of the plan corrections are in `docs/plan/corrections/P08.md`.

**D-91 Start-from rule.** Start from the branch point when the route says `from=branch`, from move 1 when it says `from=move1`; otherwise a repertoire never trained uses Settings → Training → "Start from branch point", and a trained one its own `drill_start_from`. The mode sheet stores the choice and the mode (`last_mode`) when a drill starts; single-line drills do not change `last_mode`.

**D-92 Pickers.** `LinePicker` (`lib/features/drill/line_picker.dart`): `RandomPicker`, `WeakPicker`, `SrsPicker`, `SingleLinePicker`, each with `pick`, `branchSwitch` (04 §3.4) and the app-bar count (Weak: pool size; SRS: due plus new still allowed today). A pick reads a fresh `PickContext` (live line stats, recent starts from the database plus this session, today from the clock and the day-start hour, SRS reviews today) after the previous run has been stored. Outcomes: a line (SRS marks new lines), no trainable line, empty weak pool, or SRS "All caught up" (next due day and its line count, or the daily review limit).

**D-93 SRS limits.** New lines per day count lines whose `firstSeenDay` is today; the review cap counts SRS reviews on the training day across all repertoires. A failed line lapses to learning, due today (04 §5.2), and comes back in the same session once the recent-line exclusion lets it.

**D-94 Line summary.** With "Show line summary" on, the line ends on the summary instead of the end-bar countdown; with it off, the end bar has a Summary button. The summary lists each graded user move (result mark, the first attempt if wrong, the move's comment), run accuracy, line accuracy before → after, weak-pool change ("Entered" / "Left" the weak pool) and the SRS next due day. Buttons: Next line, Retry this line (single-line drill), Browse at this line.

**D-95 Empty screens and Continue.** Weak with an empty pool: "No weak lines. Nice." with Random. SRS caught up: next review date and line count, or the daily limit message, with Weak lines and Random. Home's Continue button (above the cards) opens the most recently trained repertoire in its last mode (single maps to Random).

**D-96 Drill route.** `/repertoire/<id>/train?mode=&line=&from=`; the screen is keyed by the full URI so another mode or line is a new drill. `todayProvider` recomputes at the next day start.

## P09 (deviations, play on)

Details of the plan corrections are in `docs/plan/corrections/P09.md`.

**D-97 Deviation plan.** At line start, with deviations on (the mode sheet's session switch overrides the setting) and the engine not known to be unavailable, one roll per run (`rng.nextDouble() * 100 < chance`). End of line: candidates for the position after a user leaf are requested at once; a line ending on an opponent move needs none. Anywhere: a ply is drawn uniformly among the opponent plies after the start ply and the candidates for the position before it are requested at once. An alternative repertoire move recomputes (end of line: new leaf; anywhere: a new ply after the current one). When the opponent's move is due and no candidate has been picked, end of line skips the challenge, anywhere plays the book move; either way there is no further deviation in that run.

**D-98 Challenge flow.** The deviation move plays after the normal opponent delay with the deviation sound. The banner shows the prompt for the timing ("Your repertoire ends here. The opponent plays on: find a good reply." / "… Find a good move." / "Opponent left your repertoire. Find a good reply."). Any legal move is accepted, no take-back. The hint draws the engine's best move and fails the reply. The result banner is green "Good reply" or amber "Inaccurate. Best was X" with the board back at the position before the reply, the best move as a green arrow and the reply as a red one. The event: ply = deviation ply (`plies + 1` after a user leaf, `plies` with no deviation move after an opponent leaf), the reply, best move, loss and result. Only a mid-line run is `deviated`.

**D-99 Play on.** `/play-engine` with `PlayOnArgs` (last repertoire node, off-book moves, sides) as route extra; opened from the end bar (tonal button after a challenge, text button otherwise) and the summary. The engine moves first when it is its turn; replies use `EngineService.playMove` at the Play-on strength, shown no sooner than 300 ms after the user's move. Take back removes the user's last move and the engine's reply (or the pending reply). Game end: checkmate, stalemate, insufficient material, threefold (placement, side, castling, en passant), 50 moves; a dialog with Close / Back to training. Back to training pops and the drill goes on with the next line. Nothing is stored.

**D-100 Deviation diagnostics.** `DeviationTimings` (`lib/core/diagnostics/`): duration of candidates jobs (p50, p95, count) and the share of challenges whose move was ready when needed, over the last 200 of each; shown in Diagnostics.

## P10 (stats, streak)

Details of the plan corrections are in `docs/plan/corrections/P10.md`.

**D-101 Stats data.** `StatsQueries` (`lib/core/db/`): daily aggregates (completed runs per local day; credit and graded moves over runs with graded moves), the `ply_stats` cache, deviation replies (count, good, last 10), completed run count, and each line key's moves. Line histories: `RunRepository.runsAlong` (runs whose moves are the line's or a strict prefix of them) or `runsForKey` (archived key), filtered by chess_core's `LineIndex` attribution. Everything else comes from `line_stats`. The screen data reloads when the repertoire's line stats change.

**D-102 Stats screen.** Tiles: accuracy (mean of line accuracies), coverage (trained / trainable lines), weak, due today, completed runs, current streak. Chart: daily accuracy dots with gaps, a thick 7-day moving average line, runs-per-day bars; ranges 30 d / 90 d / All (default 30 d). Worst lines: 10 lowest accuracies; Show all opens the line list (sort: accuracy, last played, runs, line order; filters: all, weak, untrained, archived). Most missed: top 10 user moves by miss rate (ties: more misses, then tree order) with at least 3 attempts, mapped to tree nodes (an e4 shared by several lines adds up); tap opens Browse there. Deviation replies only when there are any.

**D-103 Line detail.** Full SAN, accuracy, runs, weak pool state ("clean runs 2 of 3"), SRS (due, interval, ease, or New), Drill this line, Browse this line, errors per move, run history newest first (date, mode, abandoned, marks ✓ ½ ✗ ?, accuracy). Archived lines: "Not in current PGN", no Drill or Browse.

**D-104 Streak.** `streakProvider` watches the distinct local days of completed runs (all repertoires) and today (which recomputes at the day start), and applies chess_core's `computeStreak`. The Home card (above Continue) shows from the first completed run: flame, "N-day streak", today done or "Train one line to keep your streak", best. The session summary adds "Streak: N days, today done".

## P11 (backup, sync core)

Details of the plan corrections are in `docs/plan/corrections/P11.md`.

**D-105 Records, codec, merge.** chess_core `sync/`: `RepertoireRecord` (06 §2), `SyncCodec` on an injected `GzipCodec` (meta files, JSONL run logs, backups; typed errors `CorruptFile`, `WrongFormat`, `NewerSchema`), `mergeRepertoires` (newest `updatedAt`, then larger `updatedBy`, then the larger JSON so equal versions are ordered the same everywhere), `mergeEffects` (rebuild trees for new, changed-PGN or undeleted repertoires; purge newly deleted ones; re-derive those plus repertoires with new runs) and `runsToInsert` (union by id, runs of deleted repertoires skipped, runs of unknown repertoires kept). Property tests: commutative, associative, idempotent, order-independent over 500 seeded random sets.

**D-106 Applying merges.** `MergeApplier` (`lib/core/db/`): builds trees for the planned rebuilds first (isolate import of the stored PGN; a PGN that no longer imports keeps the old tree, and a new repertoire with such a PGN is not added), then in one transaction stores the changed records (local-only columns kept), purges newly deleted repertoires (nodes, lines, stats, ply stats, runs) and inserts runs (objects batched, or a backup document in SQL), then re-derives. Backups: export = records (not deleted) + all runs (SQLite JSON) + settings, gzip on an isolate, file `repertoire-trainer-backup-YYYYMMDD-HHMM.rtbackup`; import = unpack on an isolate, check in SQLite, dialog with counts (Merge default / Replace all with a confirmation naming the local counts / Also restore settings), merge, SnackBar with the changed repertoires and added runs.

## P12 (Drive sync)

Details of the plan corrections are in `docs/plan/corrections/P12.md`.

**D-107 Sync components.** `DriveTransport` (`GoogleDriveTransport` on Drive v3 in `appDataFolder`, errors mapped to `SyncOffline`, `SyncAuthExpired`, `SyncRateLimited`, `SyncServerError`), `DriveAuth` (`AndroidDriveAuth` on `google_sign_in` 7 through a `SignInBackend`, `DesktopDriveAuth` on the `googleapis_auth` loopback flow with credentials in `flutter_secure_storage`, `UnconfiguredDriveAuth` when the build has no OAuth ids), `SyncService` (06 §4; single flight; md5 cache and meta hash in `sync_state`; quota retries after 2, 4 and 8 s; one silent re-auth on 401), `SyncController` (status and triggers) and `SyncLifecycle` (app start, background, desktop close with a 5 s cap, the "updated from another device" SnackBar).

**D-108 Triggers and open screens.** Sync runs 3 s after the first frame when on, when the app is paused, before a desktop app exits (at most 5 s), 30 s after the last local change, and on Sync now (Settings, Home icon). While a drill line is in progress (`SyncGate`, set from the drill's phase) a trigger waits and runs when the line ends. After a sync, changed repertoires' tree and line providers are invalidated (Browse starts a fresh view on the new tree, stats reload); a drill takes the new tree at its next pick, and a repertoire deleted on another device sends the drill back to Home with a SnackBar.

**D-109 Sync settings and status.** Settings → Sync and backup: "Sync is not configured in this build" without OAuth ids; otherwise the switch (on signs in if needed and syncs, off signs out and keeps local data), account, last sync or the current state ("Syncing…", "Offline, will retry", "Sign in again" with its button, the error), warnings for skipped files, Sync now, Sign out, Delete cloud data (confirmation; deletes every device's `rt1-*` files). The Home app bar shows a sync icon only when sync is on: a spinner while syncing, a badge on problems, a tap syncs (or opens the settings when signing in again is needed). Backup "Replace all" warns that sync brings the data back. Diagnostics shows the device id, sync state and, on demand, the Drive files with sizes.
