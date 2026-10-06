# Changelog

Versions follow `pubspec.yaml`; a `v<version>` tag publishes the release (`.github/workflows/release.yml`), whose notes are this file's section for the version. Per-phase details are in [`docs/PROGRESS.md`](docs/PROGRESS.md) and [`docs/DECISIONS.md`](docs/DECISIONS.md).

## 0.1.0

First release: Android (arm64-v8a, armeabi-v7a) and Windows (x64).

- **Repertoires from PGN.** Create a repertoire from an annotated PGN file (or open a `.pgn` from the file manager or share sheet on Android); the import report lists errors, warnings and infos before anything is stored. Re-import keeps your training history and shows what changed; removed lines keep their stats as archived. Rename, delete with Undo, export the stored PGN, validate it again. A demo repertoire (Italian Game for White) is one tap away.
- **Browse.** The move tree with collapsible variations, the board with your comments (`why`, `plan`, `watch`, alternatives, arrows and highlights), keyboard navigation and Stockfish analysis with up to three lines.
- **Drill.** Random, weak-line pool, spaced repetition (SRS) and single-line modes; start from move 1 or from the branch; hints; grading of comparable moves by Stockfish; a session summary with the moves you missed and why.
- **Opponent deviations.** Optionally, the opponent leaves the book at the end of a line (or mid-line) and Stockfish judges your reply; play on against the engine from any position.
- **Stats and streak.** Accuracy over time, coverage, weak and due lines, worst lines, most-missed moves, deviation replies, a full line list and per-line history; a daily streak on Home.
- **Backup and sync.** Export and import a backup file (merge or replace); optional Google Drive sync between your devices through Drive's hidden app folder (your own Google Cloud project, see `docs/GOOGLE_SETUP.md`).
- **Polish.** Dark and light themes (WCAG AA text contrast), text scale up to 1.3 without overflow, keyboard shortcuts (`?` lists them, Ctrl+, opens Settings), Windows remembers its size and position (minimum 900 x 600), Android 12+ splash, app icon, and a hidden Diagnostics screen (About, tap the version 7 times) with timings, frames, engine, database, sync, an import benchmark and Export logs.
