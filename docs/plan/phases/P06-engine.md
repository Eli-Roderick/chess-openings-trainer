# P06. Stockfish integration and analysis board

**Depends on:** P00 for tasks 1-4 (can run in parallel with P01-P05), P05 for tasks 5-9.
**Read first:** [05-engine.md](../05-engine.md) (all), [01-product-spec.md §9 (Analysis), §10 (Engine)](../01-product-spec.md), [04-algorithms.md §7](../04-algorithms.md).

## Goal
A reliable engine on Android, Windows and Linux behind `EngineService`, with the analysis board in Browse, engine settings and calibration.

## Tasks
1. `packages/uci_engine`: `UciTransport`, `ProcessTransport`, `FakeTransport`, `UciParser`, `UciEngine`, `EngineService` with the job queue and all job types in [05-engine.md §4-§9](../05-engine.md) (comparable check, deviation candidates, reply judge, analysis stream, play move, calibration). Score conversion and mate handling per [04-algorithms.md §7](../04-algorithms.md). PV → SAN conversion via dartchess (add dartchess dependency to `uci_engine`, or do SAN conversion in the app layer; prefer the app layer to keep `uci_engine` chess-agnostic: `uci_engine` returns UCI PVs).
2. Unit tests with `FakeTransport` and integration tests with the Linux binary, per [05-engine.md §10](../05-engine.md).
3. Finalise `tool/fetch_engines.dart` for all platforms; Android placement into `jniLibs`; `tool/build_stockfish_android.sh` fallback script (documented, run manually only if needed).
4. CI: engine-integration job runs the `engine` tag tests.
5. App `core/engine/`: `binary_locator.dart` (Android via `rt/native` `nativeLibraryDir`, Windows avx2→sse41 fallback, Linux), `engine_providers.dart` exposing `EngineService` (lazy start, lifecycle handling: stop searches on pause, quit after 60 s in background, restart on demand), engine status provider.
6. Kotlin `MainActivity` method channel `rt/native`: `nativeLibraryDir`, `processStartElapsedMs` (already added in P04, extend).
7. Browse analysis per [01-product-spec.md §9](../01-product-spec.md): toggle, eval bar widget (`features/board/eval_bar.dart`, animated 250 ms, White POV, mate shown as "M3"), PV lines (1-3) under the board in SAN, tap PV move to explore, stops on toggle off / leave / background.
8. Settings → Engine per [01-product-spec.md §10](../01-product-spec.md): threshold, check time, threads, hash, play-on strength (stored now, used in P09), status line, Run calibration, Restart engine. Auto calibration once per install after 10 s idle on Home.
9. Diagnostics: Engine section per [10-testing-and-quality.md §6](../10-testing-and-quality.md).

## Tests
- All `uci_engine` tests above.
- App: binary locator per platform (with fakes for channel and file system); lifecycle (paused → stop; 60 s → quit; resume + job → restart) with fake clock; unavailable state disables Analysis button with tooltip.
- Integration (Linux, real engine): analysis toggle shows changing depth and eval; leaving Browse stops the engine (no info lines received afterwards within 1 s).

## Acceptance criteria
- `EngineService.checkComparable` on Linux CI returns within 2.5 s for the test positions with correct classification.
- Engine never blocks UI: integration test drags pieces while analysis runs with no frames over budget in profile mode on Linux.
- Android: engine starts on Eli's phone (device checklist) — this is the riskiest item in the plan; if it fails, the agent implements the FFI fallback described in [05-engine.md §2](../05-engine.md) in the same phase.

## Device checklist (Eli)
- [ ] Settings → Engine shows "Stockfish … ready" and an nps figure; run calibration; note nps and depth at 1 s.
- [ ] Browse → Analysis: eval bar moves smoothly, lines update, phone does not get hot after 1 minute (then toggle off).
- [ ] Windows: same; status line names the avx2 or sse41 variant.
