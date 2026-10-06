# Dependencies

Versions are the ones resolved in `pubspec.lock` at P00 (Flutter 3.47.6, Dart 3.13.5). Adding a package not listed here needs a row here and a reason in `docs/DECISIONS.md` (see `AGENTS.md`).

## App (`pubspec.yaml`, dependencies)

| Package | Version | Purpose | Licence |
|---|---|---|---|
| chess_core | workspace | Pure-Dart chess logic: PGN import, tree, training, sync (`packages/chess_core`) | GPL-3.0-or-later (this repo) |
| uci_engine | workspace | Pure-Dart UCI engine client (`packages/uci_engine`) | GPL-3.0-or-later (this repo) |
| chessground | 10.3.0 | Board widget (drag/tap, arrows, highlights, promotion, themes, piece sets) | GPL-3.0 |
| dartchess | 0.14.0 | Chess rules, SAN, FEN, PGN | GPL-3.0 |
| flutter_riverpod | 3.4.3 | State management (Notifier / AsyncNotifier, no codegen) | MIT |
| go_router | 18.0.2 | Routing | BSD-3-Clause |
| drift | 2.35.1 | SQLite database (typed queries, migrations, streams) | MIT |
| drift_flutter | 0.3.1 | Opens the drift database on a background isolate | MIT |
| freezed_annotation | 3.1.0 | Annotations for immutable models | MIT |
| json_annotation | 4.12.0 | Annotations for JSON serialization (sync/backup) | BSD-3-Clause |
| crypto | 3.0.7 | SHA-256 (line identity, file hashes) | BSD-3-Clause |
| uuid | 4.6.0 | v4 ids | MIT |
| file_picker | 13.1.0 | Open/save files (Android SAF, Windows) | MIT |
| path_provider | 2.1.6 | App support/documents directories | BSD-3-Clause |
| path | 1.9.1 | Path manipulation | BSD-3-Clause |
| flutter_soloud | 5.1.6 | Low-latency sound effects | MIT |
| fl_chart | 1.2.0 | Stats charts | MIT |
| googleapis | 17.0.0 | Google Drive v3 API (sync) | BSD-3-Clause |
| googleapis_auth | 2.3.4 | OAuth (desktop installed-app flow, authenticated clients) | BSD-3-Clause |
| google_sign_in | 7.2.0 | Google sign-in on Android (7.x API) | BSD-3-Clause |
| flutter_secure_storage | 11.2.0 | Stores desktop OAuth credentials | BSD-3-Clause |
| url_launcher | 6.3.3 | Opens the system browser (OAuth, links) | BSD-3-Clause |
| logging | 1.3.0 | Logging (console + rotating file sink) | BSD-3-Clause |
| intl | 0.20.3 | Localization runtime for gen-l10n | BSD-3-Clause |
| flutter_localizations | SDK | Material/Cupertino localizations | BSD-3-Clause |
| collection | 1.19.1 | Collection utilities | BSD-3-Clause |
| meta | 1.19.0 | Annotations (`@immutable`, `@visibleForTesting`) | BSD-3-Clause |

## App (`pubspec.yaml`, dev_dependencies)

| Package | Version | Purpose | Licence |
|---|---|---|---|
| build_runner | 2.16.1 | Runs code generators | BSD-3-Clause |
| drift_dev | 2.35.1 | drift code generator, schema export/verification | MIT |
| freezed | 4.0.1 | Immutable model code generator | MIT |
| json_serializable | 6.14.1 | JSON code generator | BSD-3-Clause |
| very_good_analysis | 11.0.0 | Strict lint rules | MIT |
| mocktail | 1.0.5 | Mocks for tests | MIT |
| fake_async | 1.3.3 | Deterministic timers in tests | Apache-2.0 |
| flutter_test | SDK | Widget tests | BSD-3-Clause |
| integration_test | SDK | End-to-end tests (Linux desktop in CI, devices manually) | BSD-3-Clause |
| archive | 4.3.0 | tar/zip extraction in `tool/fetch_engines.dart` only | MIT |
| flutter_driver | SDK | Host side of `flutter drive` for the profile-mode performance tests | BSD-3-Clause |
| flutter_launcher_icons | 0.14.4 | Generates the Android (adaptive) and Windows app icons (P13; 02-architecture §6) | MIT |

## Packages

| Package | Dependency | Version | Purpose | Licence |
|---|---|---|---|---|
| chess_core | dartchess | 0.14.0 | Chess rules, SAN, PGN | GPL-3.0 |
| chess_core | crypto | 3.0.7 | SHA-256 line keys | BSD-3-Clause |
| chess_core | meta | 1.19.0 | Annotations | BSD-3-Clause |
| chess_core | collection | 1.19.1 | Collection utilities | BSD-3-Clause |
| chess_core | freezed_annotation | 3.1.0 | Annotations for the run models (P02) | MIT |
| chess_core | json_annotation | 4.12.0 | JSON annotations for the run models (P02) | BSD-3-Clause |
| chess_core (dev) | build_runner | 2.16.1 | Runs freezed/json_serializable in the package (P02) | BSD-3-Clause |
| chess_core (dev) | freezed | 4.0.1 | Generates the run models (P02) | MIT |
| chess_core (dev) | json_serializable | 6.14.1 | Generates run JSON (P02) | BSD-3-Clause |
| uci_engine | async | 2.13.1 | Stream utilities for the UCI process | BSD-3-Clause |
| uci_engine | meta | 1.19.0 | Annotations | BSD-3-Clause |
| uci_engine | collection | 1.19.1 | Collection utilities | BSD-3-Clause |
| uci_engine | clock | 1.1.3 | Injectable clock for search timing, fake time in tests (P06) | Apache-2.0 |
| uci_engine (dev) | fake_async | 1.3.3 | Deterministic timers for the job-queue tests (P06) | Apache-2.0 |
| both (dev) | test | 1.31.1 | Unit tests | BSD-3-Clause |
| both (dev) | very_good_analysis | 11.0.0 | Strict lint rules | MIT |

## Non-pub components

| Component | Version | Purpose | Licence |
|---|---|---|---|
| Stockfish | sf_18 (pinned in `engine/checksums.json`) | Chess engine, fetched by `tool/fetch_engines.dart` | GPL-3.0 |
