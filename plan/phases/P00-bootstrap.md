# P00. Repository bootstrap and CI

**Depends on:** nothing (repository must exist; Eli or the coordinator creates an empty GitHub repo `repertoire-trainer`).
**Read first:** [02-architecture.md](../02-architecture.md) (all), [10-testing-and-quality.md §4](../10-testing-and-quality.md), [11-decisions.md](../11-decisions.md).

## Goal
A buildable, empty-but-structured Flutter workspace with strict lints, CI on every push, and agent rules, so every later phase only adds features.

## Tasks
1. `flutter create --org dev.eliroderick --project-name repertoire_trainer --platforms android,windows,linux .` Set Android `applicationId dev.eliroderick.repertoiretrainer`, `minSdk 24`, app label "Repertoire Trainer".
2. Pin Flutter: `.flutter-version` with the exact stable version used; CI reads it.
3. Pub workspace: root `pubspec.yaml` with `workspace:` listing `packages/chess_core` and `packages/uci_engine`; create both packages (`dart create -t package`), each with `resolution: workspace`. `chess_core` depends on `dartchess`, `crypto`, `meta`, `collection`; `uci_engine` on `meta`, `collection`, `async`.
4. Add app dependencies from [02-architecture.md §1](../02-architecture.md) at latest stable versions; dev deps `build_runner`, `drift_dev`, `freezed`, `json_serializable`, `very_good_analysis`, `mocktail`, `fake_async`, `integration_test`. Write `docs/DEPENDENCIES.md` (package, version, purpose, licence).
5. `analysis_options.yaml` including `very_good_analysis`, excluding `**/*.g.dart`, `**/*.freezed.dart`; `public_member_api_docs: false` for the app (keep for packages).
6. Folder skeleton from [02-architecture.md §2](../02-architecture.md) with placeholder `README.md` per feature folder describing its responsibility (one paragraph each, copied from the spec).
7. `l10n.yaml` + `lib/l10n/app_en.arb` with the app title; `MaterialApp.router` with a placeholder Home route; dark theme default.
8. `lib/main.dart` minimal bootstrap: logging setup (console in debug, rotating file sink in `getApplicationSupportDirectory()/logs`), `ProviderScope`, `runApp`.
9. `tool/fetch_engines.dart` (full implementation per [05-engine.md §1](../05-engine.md)): reads `engine/checksums.json`, downloads with `HttpClient`, verifies SHA-256, extracts tar/zip (use `package:archive` as a dev dependency of the tool only, under `tool/pubspec.yaml` if needed, or the workspace dev deps), places files, idempotent (skips when hashes match). Fill `checksums.json` for the pinned Stockfish release after checking the actual asset names and hashes on the release page.
10. Android: `extractNativeLibs`, `useLegacyPackaging` settings; `key.properties.example`; release signing config reading `key.properties` when present, else debug signing.
    **One signing key from day one.** Android refuses to install an update signed with a different key, and every CI runner generates a fresh debug keystore, so CI-built test APKs would force Eli to uninstall (and lose his data) on every update. Therefore: generate one upload/release keystore now (`keytool -genkeypair -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias repertoire`), store it base64-encoded with its passwords in repository secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_PROPERTIES`), and have CI build the device-test APK as `flutter build apk --release --split-per-abi` signed with it. Eli keeps an offline copy of the keystore and passwords (if it is lost, the app can never be updated in place). The same key's SHA-1 is used for the Google OAuth Android client in P12. If secrets are unavailable to the agent, it writes the exact steps for Eli in the PR and CI falls back to debug signing until they are added.
11. Windows CMake: install rule copying `engine/windows/*.exe` to `${CMAKE_INSTALL_PREFIX}/engine/` (create the dir if no exe so builds without engines still work). Linux CMake: same for `engine/linux/stockfish`.
12. CI `ci.yml` and `release.yml` per [02-architecture.md §7](../02-architecture.md). Integration job may have zero tests yet but must run.
13. `AGENTS.md` with the contents in [02-architecture.md §8](../02-architecture.md); `CLAUDE.md` containing one line: "Read AGENTS.md."
14. Copy this plan folder into `docs/plan/`. Seed `docs/DECISIONS.md` from `11-decisions.md`, create `docs/PROGRESS.md` with the phase table (all "not started", P00 "done" on merge).
15. `LICENSE` (GPL-3.0-or-later full text), `THIRD_PARTY.md` (Stockfish, dartchess, chessground, Inter font (OFL), piece sets (added in P05), sounds (P05)).
16. Import-boundary test: `test/architecture_test.dart` greps `packages/*/lib/**/*.dart` for `package:flutter` or `package:repertoire_trainer` imports and features for cross-feature imports (allow `features/board/`).

## Acceptance criteria
- `flutter analyze --fatal-infos` clean; `dart format` clean; `flutter test` and `dart test` (both packages, with one trivial test each) green.
- CI green on the default branch: checks, engine-integration (fetch + empty tag run), build-android (APK artefact), build-windows (zip artefact).
- `dart run tool/fetch_engines.dart --platform linux` then `engine/linux/stockfish` answers `uci` with `uciok` (a test in `packages/uci_engine/test` tagged `engine` proves it).
- The debug APK installs and shows the placeholder Home in dark theme.

## Device checklist (Eli)
- [ ] Install the CI APK on the phone; it opens to a dark placeholder screen.
- [ ] Unzip the Windows artefact; the exe opens.

## Out of scope
Any feature code.
