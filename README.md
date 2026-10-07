# Repertoire Trainer

An offline-first chess openings trainer. Import your repertoire as annotated PGN, then drill it line by line with spaced repetition, a weak-line pool, Stockfish judging non-repertoire moves, and optional Google Drive sync between devices. Android (phone) is the primary target; Windows is also shipped. Linux desktop is used for development and CI only.

The full specification is in [`docs/plan/`](docs/plan/README.md); progress per phase is in [`docs/PROGRESS.md`](docs/PROGRESS.md), changes per version in [`CHANGELOG.md`](CHANGELOG.md). Rules for AI build agents are in [`AGENTS.md`](AGENTS.md).

## Install

Download the files from the latest [GitHub release](https://github.com/Eli-Roderick/chess-openings-trainer/releases).

### Android (7.0 or newer)

1. On the phone, download `repertoire-trainer-<version>-android-arm64-v8a.apk` (use `armeabi-v7a` only on an old 32-bit phone).
2. Open the file. Android asks to allow installs from your browser or file manager ("Install unknown apps"): allow it, go back, tap **Install**.
3. Updates: install the newer APK the same way; your data stays (every release is signed with the same key). Do not uninstall first, that deletes the data.

Play Protect may warn about an app from an unknown developer; choose **Install anyway**.

### Windows 10 (1809) or newer, x64

1. Download `repertoire-trainer-<version>-windows-x64.zip` and unzip it anywhere (for example `Documents\Repertoire Trainer`).
2. Run `repertoire_trainer.exe`. SmartScreen may say "Windows protected your PC": **More info → Run anyway**.
3. Updates: replace the folder's contents with the new zip's. Your data lives in `%APPDATA%\dev.eliroderick\repertoire_trainer` (the app support folder), not in the app folder.

The `engine` folder next to the exe holds Stockfish; keep it with the app.

## Using it

1. **Write or get an annotated repertoire.** Repertoires are PGN files whose moves by your colour carry structured comments (`[%why …] [%plan …] [%watch …] [%alt …] [%cal …] [%csl …]`, see [`docs/plan/07-comment-format.md`](docs/plan/07-comment-format.md)). The annotation workflow: export your repertoire as PGN (from Lichess, ChessBase, …), paste it into an AI chat with the prompt in [`docs/plan/08-annotation-prompt.md`](docs/plan/08-annotation-prompt.md) (the app's Create screen copies the same prompt with **Copy annotation prompt**), save the answer as a `.pgn` file.
2. **Import it.** Home → **New repertoire** → name, colour, choose the file (on Android you can also open a `.pgn` from the file manager or share it to the app). The report lists errors (fix them and choose the file again), warnings and infos.
3. **Train.** Open the repertoire → **Train** → mode (Random, Weak lines, Due (SRS), one line) → play your moves; **Browse** shows the tree with your comments and engine analysis; **Stats** shows accuracy, weak lines and the moves you miss most.
4. **Keep it safe.** Settings → Sync and backup: **Export backup** any time; turn on Google Drive sync to use the phone and the PC together (needs the one-time setup below).

Keyboard (Windows, or any hardware keyboard): `?` lists the shortcuts; `Ctrl+,` opens Settings.

## Building from source

### Requirements

- Flutter, exactly the version in [`.flutter-version`](.flutter-version) (currently 3.47.6, Dart 3.13.5).
- Android: Android SDK and JDK 17.
- Windows: Visual Studio with the "Desktop development with C++" workload.
- Linux (dev): `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev libsecret-1-dev`, plus `xvfb` for headless integration tests.

### Setup

```sh
flutter pub get
dart run tool/fetch_engines.dart --platform linux    # or android, windows, all
```

`tool/fetch_engines.dart` downloads the pinned Stockfish release binaries listed in `engine/checksums.json`, verifies their SHA-256, and installs them (`engine/linux/stockfish`, `engine/windows/*.exe`, `android/app/src/main/jniLibs/*/libstockfish.so`). The binaries are not committed. Re-running it is a no-op when the installed files match; `--force` re-downloads.

### Build

```sh
flutter build apk --release --split-per-abi   # build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
flutter build windows --release               # build/windows/x64/runner/Release/
flutter build linux --release                 # build/linux/x64/release/bundle/
```

Android release builds are signed with the key in `android/key.properties` (gitignored; template in `android/key.properties.example`) and fall back to debug signing when it is absent. Desktop builds copy the fetched engine into `<bundle>/engine/`.

### Google Drive sync

Sync needs OAuth client ids from your own Google Cloud project: follow [docs/GOOGLE_SETUP.md](docs/GOOGLE_SETUP.md) once (about 15 minutes). Copy `config/google_oauth.example.json` to `config/google_oauth.json` (gitignored), fill in the three values and pass the file to every build or run:

```sh
flutter run --dart-define-from-file=config/google_oauth.json
flutter build apk --release --split-per-abi --dart-define-from-file=config/google_oauth.json
flutter build windows --release --dart-define-from-file=config/google_oauth.json
```

Without the file the app works normally and Settings → Sync and backup says "Sync is not configured in this build". The release workflow writes the file from the repository secrets `GOOGLE_ANDROID_SERVER_CLIENT_ID`, `GOOGLE_DESKTOP_CLIENT_ID` and `GOOGLE_DESKTOP_CLIENT_SECRET`.

### Test

```sh
dart run build_runner build -d                 # generated code (committed)
dart format .
flutter analyze --fatal-infos
(cd packages/chess_core && dart test --coverage=coverage)
dart run tool/check_coverage.dart --package packages/chess_core --min 90 lib
(cd packages/uci_engine && dart test --exclude-tags engine)
(cd packages/uci_engine && dart test --tags engine)   # needs engine/linux/stockfish
flutter test
xvfb-run -a flutter test integration_test/app_test.dart -d linux
xvfb-run -a flutter test integration_test/drill_test.dart -d linux
xvfb-run -a flutter drive --profile -d linux \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/profile_test.dart   # cold start budget
```

### PGN tools

Check a file before importing, or make synthetic ones for benchmarks:

```sh
dart run tool/validate_pgn.dart --colour white [--json] my_repertoire.pgn   # exit 0 ok, 1 errors, 2 usage
dart run tool/gen_synthetic_pgn.dart --lines 1000 --depth 16 --seed 1 --out big.pgn
dart run tool/bench_import.dart --lines 1000 --depth 16
```

`assets/demo/italian_white.pgn` is a fully commented example (12 lines, Italian Game for White).

### CI and releases

CI (`.github/workflows/ci.yml`) runs all of the above plus Android and Windows release builds on every push and pull request. To release: set `version:` in `pubspec.yaml`, add a `## <version>` section to `CHANGELOG.md`, merge, then push the tag `v<version>`. `.github/workflows/release.yml` checks that the tag, pubspec and changelog agree, builds the APKs (signed with the release key from the repository secrets `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEY_PROPERTIES`; a release without them fails) and the Windows zip, and publishes them as a GitHub release whose notes are the changelog section plus the Stockfish source link. It checks that each APK contains Stockfish and is release-signed, and that the release ends up with both APKs and the zip. Creating the release in the GitHub UI instead of pushing the tag also works: the workflow fills in the existing release. To re-publish a tag (after a failed run, say), run Actions → Release → Run workflow with the tag, e.g. `v0.1.0`.

## Licence

GPL-3.0-or-later; see [`LICENSE`](LICENSE). The app bundles Stockfish (GPL-3.0; the source of the exact version is linked from every release and from About → Licences), dartchess and chessground (GPL-3.0). All third-party components and their licences are listed in [`THIRD_PARTY.md`](THIRD_PARTY.md); Dart packages in [`docs/DEPENDENCIES.md`](docs/DEPENDENCIES.md).
