# uci_engine

Pure Dart UCI client of Repertoire Trainer (docs/plan/05-engine.md §4). Chess-agnostic: moves are UCI strings and scores are raw engine scores; the app converts them (SAN with dartchess, judgements with chess_core).

- `UciTransport`: `ProcessTransport` (a Stockfish process) and `FakeTransport` (scripted, for tests).
- `UciEngine`: handshake, options, one search at a time, `stop`, `quit`.
- `EngineService`: the job queue the app uses (priorities, preemption, crash restart, background pause), see `docs/DECISIONS.md` D-78 to D-80.

Tests: `dart test --exclude-tags engine` (fake engine); `dart test --tags engine` runs against `engine/linux/stockfish` (fetch it with `dart run tool/fetch_engines.dart --platform linux` from the repository root).
