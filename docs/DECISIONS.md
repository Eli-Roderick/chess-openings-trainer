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
