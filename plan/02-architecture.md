# 02. Architecture, stack and repository layout

## 1. Stack

| Concern | Choice | Reason |
|---|---|---|
| Framework | Flutter stable (latest at bootstrap, pinned in `.flutter-version` and CI) | Decided by Eli. |
| Language | Dart 3 (version bundled with the pinned Flutter) | |
| Targets | Android (shipped), Windows (shipped), Linux desktop (**dev and CI only**, never shipped) | Linux lets build agents run integration tests with a real engine under `xvfb` without a phone or Windows machine. |
| Chess rules, SAN, PGN | `dartchess` (lichess-org, GPL-3.0) | Battle-tested in lichess mobile; pure Dart, so usable in isolates and CLI tools. |
| Board widget | `chessground` (lichess-org, GPL-3.0) | The board lichess mobile uses: drag/tap, animations, arrows, highlights, promotion UI, themes and piece sets. Building our own board would be the riskiest part of the project for no gain. |
| State management | `flutter_riverpod` (Notifier / AsyncNotifier, no riverpod codegen) | Fine-grained rebuilds (`select`) keep the board from repainting on unrelated state changes. |
| Routing | `go_router` | |
| Database | `drift` + `drift_flutter` (SQLite, WAL, background isolate) | Typed queries, migrations, streams, fast. |
| Models | `freezed` + `json_serializable` | Immutable models and JSON for sync/backup; `build_runner` is already needed by drift. |
| Hashing / ids | `crypto` (SHA-256), `uuid` (v4) | |
| Files | `file_picker` (open + save on Android SAF and Windows), `path_provider` | No storage permission needed. |
| Audio | `flutter_soloud` | Low-latency short sounds on Android and Windows. |
| Charts | `fl_chart` | |
| Drive sync | `googleapis` (Drive v3), `googleapis_auth`, `google_sign_in` (Android only), `flutter_secure_storage`, `url_launcher` | See [06-sync.md](06-sync.md). |
| Engine | Stockfish official release binaries, driven over UCI via `dart:io` `Process` | One code path on all platforms. See [05-engine.md](05-engine.md). |
| Logging | `logging` + a rotating file sink (1 MB x 3) in app support dir | Exportable from Diagnostics. |
| Localization | `flutter_localizations` + `gen-l10n`, English only (`lib/l10n/app_en.arb`) | All UI strings in one file; adding languages later is free. |
| Lints | `very_good_analysis` | Strict lints catch AI-written mistakes early. |
| Tests | `test`, `flutter_test`, `integration_test`, `mocktail`, `fake_async` | |

Package versions: the P00 agent adds each package at its latest stable version (`flutter pub add`), commits `pubspec.lock`, and records versions in `docs/DEPENDENCIES.md`. Later phases must not add packages beyond this table without adding a row and reason to `docs/DECISIONS.md` in the repo. Note for agents: `google_sign_in` 7.x changed its API completely (`GoogleSignIn.instance.initialize`, `authenticate`, `authorizationClient`); most examples online are for 6.x. Read the pinned version's README and example.

## 2. Repository layout

Pub workspace (Dart ≥ 3.6 workspaces). Root is the Flutter app; pure-Dart packages under `packages/`.

```
repertoire-trainer/
├─ .github/workflows/ci.yml           # analyze, format, test (all packages), build android/windows/linux
├─ .github/workflows/release.yml      # tagged builds → GitHub release assets (APK, Windows zip)
├─ .flutter-version
├─ AGENTS.md                          # rules for AI build agents (contents in §8); CLAUDE.md symlinks/points to it
├─ README.md                          # what it is, how to build, how to run tests
├─ LICENSE                            # GPL-3.0-or-later
├─ THIRD_PARTY.md                     # Stockfish, dartchess, chessground, piece sets, sounds, fonts, with licences
├─ pubspec.yaml                       # app; `workspace: [packages/chess_core, packages/uci_engine]`
├─ analysis_options.yaml              # include: package:very_good_analysis; excludes generated files
├─ l10n.yaml
├─ config/
│  ├─ google_oauth.example.json       # template for --dart-define-from-file
│  └─ .gitignore                      # ignores google_oauth.json
├─ docs/
│  ├─ DECISIONS.md                    # running decision log (seeded from plan/11-decisions.md)
│  ├─ DEPENDENCIES.md
│  ├─ PROGRESS.md                     # which phases are done, by which PR
│  └─ plan/                           # copy of this plan folder, the spec agents build from
├─ assets/
│  ├─ demo/italian_white.pgn
│  ├─ sounds/{move,capture,check,castle,error,line_complete,deviation,hint}.ogg
│  ├─ fonts/Inter-*.ttf
│  └─ test_pgns/                      # (not bundled; under test/fixtures instead, see packages)
├─ engine/                            # gitignored binaries, populated by tool/fetch_engines.dart
│  ├─ checksums.json                  # committed: url + sha256 per binary
├─ tool/
│  ├─ fetch_engines.dart              # downloads pinned Stockfish binaries, verifies sha256, places them
│  ├─ validate_pgn.dart               # CLI: dart run tool/validate_pgn.dart --colour white file.pgn
│  ├─ gen_synthetic_pgn.dart          # generates N-line PGNs for benchmarks
│  └─ bench_import.dart               # import benchmark, prints ms
├─ packages/
│  ├─ chess_core/                     # PURE DART. No Flutter, no dart:io except in bin/.
│  │  ├─ lib/chess_core.dart          # barrel
│  │  ├─ lib/src/pgn/                 # pgn_importer.dart, comment_parser.dart, validator.dart, report.dart, pgn_exporter.dart
│  │  ├─ lib/src/tree/                # repertoire_tree.dart, tree_node.dart, line.dart, line_key.dart, branch_point.dart, san_path.dart
│  │  ├─ lib/src/training/            # grading.dart, run.dart, accuracy.dart, randomizer.dart, weak_pool.dart, srs.dart, streak.dart, line_stats_deriver.dart, reimport_diff.dart, day_clock.dart
│  │  ├─ lib/src/sync/                # records.dart, merge.dart, codec.dart (json+gzip), backup.dart
│  │  ├─ lib/src/util/                # rng.dart (seedable), clock.dart (injectable)
│  │  └─ test/ (+ test/fixtures/*.pgn)
│  └─ uci_engine/                     # PURE DART (dart:io allowed). UCI protocol client.
│     ├─ lib/src/uci_process.dart     # spawn, stdin/stdout lines, isready sync, quit/kill
│     ├─ lib/src/uci_parser.dart      # info/bestmove/option parsing
│     ├─ lib/src/engine_service.dart  # job queue, priorities, cancellation
│     ├─ lib/src/jobs/                # comparable_check.dart, deviation_candidates.dart, reply_judge.dart, analysis_stream.dart, play_move.dart, calibration.dart
│     └─ test/ (unit with fake process; integration tagged `engine` using engine/linux binary)
├─ lib/
│  ├─ main.dart                       # bootstrap: bindings, logging, DB open, ProviderScope, runApp
│  ├─ app/                            # app.dart (MaterialApp.router), router.dart, theme/ (app_theme.dart, colors.dart)
│  ├─ core/
│  │  ├─ db/                          # drift database, tables, daos, migrations
│  │  ├─ engine/                      # binary_locator.dart (per platform), engine_providers.dart, android_native_dir channel
│  │  ├─ audio/                       # sound_service.dart
│  │  ├─ haptics/
│  │  ├─ settings/                    # settings model, repository, providers
│  │  ├─ files/                       # pick/save abstractions
│  │  └─ diagnostics/                 # timings, frame stats, log export
│  ├─ features/
│  │  ├─ home/
│  │  ├─ repertoire/                  # create, detail, rename, delete, export
│  │  ├─ import/                      # import controller (isolate), report screen, diff
│  │  ├─ board/                       # RepertoireBoard wrapper around chessground, comment panel, eval bar, move list widgets
│  │  ├─ browse/
│  │  ├─ analysis/
│  │  ├─ drill/                       # drill_controller.dart (state machine), drill_screen.dart, end_bar.dart, line_summary_screen.dart, mode_sheet.dart, pickers/
│  │  ├─ play_engine/
│  │  ├─ stats/
│  │  ├─ streak/
│  │  ├─ settings/
│  │  ├─ sync/                        # drive_transport.dart, auth_android.dart, auth_desktop.dart, sync_service.dart, sync_ui
│  │  └─ backup/
│  └─ l10n/app_en.arb
├─ android/                           # jniLibs populated at build from engine/ (see 05-engine.md §2)
├─ windows/                           # CMake installs engine exe into bundle
├─ linux/                             # dev only
├─ test/                              # widget + unit tests for app code
└─ integration_test/                  # end-to-end on Linux desktop (and on device manually)
```

Dependency rule (enforced by review and an import-lint test that greps imports): `packages/chess_core` imports nothing from the app or Flutter; `packages/uci_engine` imports nothing from the app or Flutter; features may import `core/` and `packages/*`, never other features' internals except `features/board/` widgets (shared). Shared widgets used by 2+ features live in `features/board/`.

## 3. Layering inside the app

```
UI (widgets)  →  Controllers (Riverpod Notifiers)  →  Repositories (core/db DAOs, settings, sync)  →  chess_core / uci_engine
```

- Widgets never touch drift or the engine directly.
- Controllers own screen state as immutable freezed classes.
- All chess logic, scoring and scheduling is in `chess_core`, unit-tested without Flutter. The app only orchestrates.
- Time and randomness are injected (`Clock`, `Rng` providers) so drills and schedulers are deterministic in tests.

## 4. Key runtime components

| Component | Lifetime | Notes |
|---|---|---|
| `AppDatabase` | app | Opened via `driftDatabase(name: 'repertoire', native: DriftNativeOptions(shareAcrossIsolates: true))` on a background isolate. WAL. |
| `RepertoireCache` | app, per repertoire, LRU 3 | In-memory `RepertoireTree` + lines, loaded from DB node rows (not re-parsed from PGN). Invalidated on re-import/sync change. |
| `EngineService` | lazy; started on first need; stopped after 60 s in background | Single Stockfish process, job queue. |
| `SoundService` | app; initialized after first frame | Preloads all sounds. |
| `SyncService` | app; idle unless enabled | Mutex; triggers per [06-sync.md §6](06-sync.md). |
| `StatsDeriver` | on demand | Recomputes `line_stats` for a repertoire (or specific lines) from runs. Runs in an isolate when > 2,000 runs. |

## 5. Performance architecture

These are design rules, not optimisations to do later.
1. **First frame fast:** `main()` does only: `WidgetsFlutterBinding.ensureInitialized()`, start DB open (don't await before `runApp` beyond what Home needs), `runApp`. Home's data is one query on a small summary query (repertoire rows joined with aggregated `line_stats`). Sounds, engine, fonts precache, sync: after first frame (`SchedulerBinding.addPostFrameCallback` + `Future.delayed(Duration.zero)`).
2. **Board isolation:** the board widget is wrapped in `RepaintBoundary` and rebuilt only when its own inputs change (position, orientation, shapes, highlights, theme). Comment panel, banners and timers live in sibling widgets watching separate providers (`ref.watch(provider.select(...))`).
3. **No work on the UI isolate > 8 ms:** PGN parsing, tree building, validation, stats derivation for large histories, backup encode/decode and sync merges run in `Isolate.run`. Engine I/O is async stream parsing on the main isolate (cheap), throttled to ≤ 10 UI updates/s for analysis.
4. **Trees loaded from rows:** opening a repertoire reads pre-built `nodes` rows (one query, indexed) and builds the in-memory tree in O(n). The FEN for every node is stored, so no move replay is needed on open.
5. **Precache piece images** for the active piece set after first frame.
6. **Impeller** (Android default) avoids shader-compilation jank. On Windows use the default renderer.
7. **Release builds only** are judged for performance (`--release` or `--profile`). Debug-mode jank is not a bug.
8. Lists use `ListView.builder`; the Browse move list for big trees is virtualized (flattened rows).

## 6. Platform specifics

**Android:** minSdk 24, target latest. Permissions: `INTERNET` only. `android:extractNativeLibs="true"` and Gradle `packaging { jniLibs { useLegacyPackaging = true } }` so the engine binary is extracted to `nativeLibraryDir` ([05-engine.md §2](05-engine.md)). Release builds: `flutter build apk --release --split-per-abi` (arm64 APK is the one Eli installs). Signing via `android/key.properties` (gitignored), template in `android/key.properties.example`. App icon via `flutter_launcher_icons` (dev dependency) in P13. Intent filter for opening `.pgn` files from file managers (P13).

**Windows:** CMake install step copies `engine/windows/*.exe` into `<bundle>/engine/`. Release artefact: zip of `build/windows/x64/runner/Release/`. Window min size 900x600, remembers size/position (simple JSON in app support dir; P13).

**Linux (dev only):** same as Windows with `engine/linux/stockfish`. Used for `integration_test` in CI under `xvfb-run`.

## 7. CI (GitHub Actions)

`ci.yml` on push and PR:
1. **checks** (ubuntu): `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, verify no diff in generated files (they are committed), `dart format --set-exit-if-changed .`, `flutter analyze --fatal-infos`, `dart test` in each package, `flutter test` (app), import-boundary test.
2. **engine-integration** (ubuntu): `dart run tool/fetch_engines.dart --platform linux`, `dart test --tags engine` in `packages/uci_engine`, then `xvfb-run flutter test integration_test -d linux`.
3. **build-android** (ubuntu): fetch engines (android), `flutter build apk --release --split-per-abi` signed with the project's single release key from secrets (see P00 task 10; never a per-runner debug key, or updates would not install over each other); upload arm64 APK as artefact.
4. **build-windows** (windows-latest): fetch engines (windows), `flutter build windows --release`; upload zip artefact.
Caches: pub cache, Gradle, `engine/` keyed by `engine/checksums.json` hash.

`release.yml` on tag `v*`: release builds, signed APK (keystore from repository secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_PROPERTIES`), Windows zip, attaches to a GitHub release along with Stockfish source link (GPL).

## 8. AGENTS.md contents (create in P00, keep current)

- Read `docs/plan/README.md` and your phase file before writing code. The plan is the spec; if the plan is ambiguous, pick the reasonable default, write it in `docs/DECISIONS.md`, and continue.
- Commands: `flutter pub get`; `dart run build_runner build -d`; `dart format .`; `flutter analyze`; `dart test` (inside packages); `flutter test`; `xvfb-run flutter test integration_test -d linux`; `dart run tool/fetch_engines.dart --platform <linux|android|windows>`.
- Definition of done for any PR: analyzer clean (no infos), formatted, all tests green, new logic has tests, `docs/PROGRESS.md` updated, generated files committed, no TODOs without an issue reference.
- Never: put chess/scoring/scheduling logic in widgets; use `print` (use `logging`); add a package not in `docs/DEPENDENCIES.md` without a DECISIONS entry; make network calls outside `features/sync`; block the UI isolate with parsing or DB work; use real time or unseeded randomness in logic (inject `Clock`/`Rng`); edit generated files by hand.
- Database changes: bump `schemaVersion`, write a migration, add a migration test (drift `SchemaVerifier`, schemas exported to `drift_schemas/`).
- UI strings go in `app_en.arb`.
- Keep PRs to one phase (or one sub-phase); title `P<nn>: <name>`.
