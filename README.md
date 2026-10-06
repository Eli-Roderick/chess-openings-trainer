# Repertoire Trainer

An offline-first chess openings trainer. Import your repertoire as annotated PGN, then drill it line by line with spaced repetition, a weak-line pool, Stockfish judging non-repertoire moves, and optional Google Drive sync between devices. Android (phone) is the primary target; Windows is also shipped. Linux desktop is used for development and CI only.

The full specification is in [`docs/plan/`](docs/plan/README.md); progress per phase is in [`docs/PROGRESS.md`](docs/PROGRESS.md). Rules for AI build agents are in [`AGENTS.md`](AGENTS.md).

## Requirements

- Flutter, exactly the version in [`.flutter-version`](.flutter-version) (currently 3.47.6, Dart 3.13.5).
- Android: Android SDK and JDK 17.
- Windows: Visual Studio with the "Desktop development with C++" workload.
- Linux (dev): `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev libsecret-1-dev`, plus `xvfb` for headless integration tests.

## Setup

```sh
flutter pub get
dart run tool/fetch_engines.dart --platform linux    # or android, windows, all
```

`tool/fetch_engines.dart` downloads the pinned Stockfish release binaries listed in `engine/checksums.json`, verifies their SHA-256, and installs them (`engine/linux/stockfish`, `engine/windows/*.exe`, `android/app/src/main/jniLibs/*/libstockfish.so`). The binaries are not committed. Re-running it is a no-op when the installed files match; `--force` re-downloads.

## Build

```sh
flutter build apk --release --split-per-abi   # build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
flutter build windows --release               # build/windows/x64/runner/Release/
flutter build linux --release                 # build/linux/x64/release/bundle/
```

Android release builds are signed with the key in `android/key.properties` (gitignored; template in `android/key.properties.example`) and fall back to debug signing when it is absent. Desktop builds copy the fetched engine into `<bundle>/engine/`.

## Test

```sh
dart run build_runner build -d                 # generated code (committed)
dart format .
flutter analyze --fatal-infos
(cd packages/chess_core && dart test)
(cd packages/uci_engine && dart test --exclude-tags engine)
(cd packages/uci_engine && dart test --tags engine)   # needs engine/linux/stockfish
flutter test
xvfb-run -a flutter test integration_test -d linux
```

CI (`.github/workflows/ci.yml`) runs all of the above plus Android and Windows release builds on every push and pull request. Pushing a `v*` tag runs `.github/workflows/release.yml`, which publishes the signed APKs and a Windows zip as a GitHub release.

## Licence

GPL-3.0-or-later; see [`LICENSE`](LICENSE). Third-party components, including Stockfish (GPL-3.0), are listed in [`THIRD_PARTY.md`](THIRD_PARTY.md).
