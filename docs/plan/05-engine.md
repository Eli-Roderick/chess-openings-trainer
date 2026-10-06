# 05. Engine (Stockfish)

## 1. Choice

- **Stockfish, latest official stable release at bootstrap** (17.1 at the time of writing; P00 pinned sf_18, see corrections/P00.md), with its default embedded NNUE networks. Pinned by URL and SHA-256 in `engine/checksums.json`.
- Driven over **UCI through `dart:io` `Process`** on every platform. One implementation, testable on Linux in CI.
- Binaries are **not committed**. `tool/fetch_engines.dart --platform <android|windows|linux>` downloads the official release assets, verifies SHA-256, unpacks, and places them. CI caches them.

| Platform | Release asset | Installed as |
|---|---|---|
| Android arm64-v8a | `stockfish-android-armv8.tar` | `android/app/src/main/jniLibs/arm64-v8a/libstockfish.so` |
| Android armeabi-v7a | `stockfish-android-armv7-neon.tar` | `android/app/src/main/jniLibs/armeabi-v7a/libstockfish.so` |
| Windows x64 | `stockfish-windows-x86-64-avx2.zip` and `stockfish-windows-x86-64-sse41-popcnt.zip` | `<bundle>/engine/stockfish-avx2.exe`, `<bundle>/engine/stockfish-sse41.exe` |
| Linux x64 (dev/CI) | `stockfish-ubuntu-x86-64-avx2.tar` | `engine/linux/stockfish` |

`jniLibs/**/libstockfish.so` is gitignored. Exact asset names must be checked against the pinned release page by the P06 agent and written into `checksums.json`. If an official Android asset is missing for the pinned release, `tool/build_stockfish_android.sh` builds from the pinned source tag with the NDK: `make -j build ARCH=armv8 COMP=ndk` (and `ARCH=armv7-neon`), then `llvm-strip`.

Size: each binary is roughly 70-80 MB because the networks are embedded. `--split-per-abi` keeps each APK to one binary. Accepted: offline-first means the networks must ship, and Eli sideloads the APK.

Licence: Stockfish is GPL-3.0. The app is GPL-3.0-or-later, the About screen states it and links to Stockfish's source for the pinned tag, and `THIRD_PARTY.md` lists it.

## 2. Locating and launching the binary

`core/engine/binary_locator.dart`:
- **Android:** a `MethodChannel('rt/native')` method `nativeLibraryDir` implemented in `MainActivity.kt` returns `applicationInfo.nativeLibraryDir`. Path = `<dir>/libstockfish.so`. Required in `AndroidManifest.xml`: `android:extractNativeLibs="true"`; in `app/build.gradle(.kts)`: `packaging { jniLibs { useLegacyPackaging = true } }`. Executing from `nativeLibraryDir` is permitted on Android 10+ (W^X rules forbid executing from app data dirs, not from the native lib dir). The P06 agent verifies on an emulator image if available; Eli verifies on his phone in the P06 device checklist. **Fallback if this ever fails on a device:** switch Android to an FFI build (the `multistockfish` / `stockfish` pub packages' approach) behind the same `UciTransport` interface; the rest of the code is unaffected.
- **Windows:** `<dir of Platform.resolvedExecutable>/engine/`. Try `stockfish-avx2.exe`; if it exits or fails to answer `uciok` within 3 s, use `stockfish-sse41.exe`. Remember the working variant in settings.
- **Linux:** `engine/linux/stockfish` relative to the repo (dev) or `<exe dir>/engine/stockfish`.

## 3. Engine options

Set once after `uciok`:
| Option | Android | Windows/Linux |
|---|---|---|
| Threads | `clamp(cores - 1, 1, 4)` (cores from `Platform.numberOfProcessors`) | `clamp(cores ~/ 2, 1, 8)` |
| Hash (MB) | 64 | 256 |
| MultiPV | per job | per job |
| UCI_ShowWDL | false | false |
| UCI_LimitStrength / UCI_Elo | only for play-on jobs, reset to false after | same |
Settings can override Threads (1..cores) and Hash (16..1024).

## 4. `uci_engine` package design

```
abstract interface class UciTransport { Stream<String> get lines; void send(String cmd); Future<void> kill(); }
class ProcessTransport implements UciTransport   // Process.start, utf8 line splitting, stderr logged
class FakeTransport implements UciTransport      // scripted responses for unit tests

class UciEngine {
  Future<void> start();                // 'uci' → wait 'uciok' (timeout 5 s) → setoptions → 'isready' → 'readyok'
  Future<void> newGame();              // 'ucinewgame' + isready
  Stream<SearchInfo> go(SearchRequest r);  // position fen …; go …; emits parsed info; completes on bestmove
  Future<void> stop();                 // 'stop', waits for bestmove (timeout 1 s, else restart process)
  Future<void> dispose();              // 'quit', kill after 500 ms
}

class EngineService {                  // the only thing the app talks to
  Future<ComparableResult> checkComparable(fen, userUci, acceptedUcis);   // priority HIGH
  Future<List<DeviationCandidate>> deviationCandidates(fen, bookUcis);    // priority LOW, cancellable
  Future<ReplyJudgement> judgeReply(fen, replyUci);                       // priority HIGH
  Stream<AnalysisUpdate> analyse(fen, multiPv);                           // EXCLUSIVE, cancel by subscription cancel
  Future<String> playMove(fen, elo|null, movetime);                       // priority HIGH
  Future<CalibrationResult> calibrate();
  EngineStatus get status;  Stream<EngineStatus> statusChanges;
}
```
**Queue rules:** one search at a time. HIGH jobs preempt a running LOW job (send `stop`, discard its result, re-queue it if still wanted). Analysis is exclusive: starting a drill job while analysis runs is not possible because analysis only exists on Browse/Play-on screens; leaving those screens cancels analysis. Every job begins with `position fen <fen>` and an `isready` handshake so stale `info` lines from a stopped search are never attributed to the next job (discard lines until `readyok`). Parse scores as `cp` or `mate`, `depth`, `seldepth`, `nodes`, `nps`, `multipv`, `pv`.

**Lifecycle:** start lazily on first job; pre-warm when the Drill, Browse-with-analysis or Play-on screen opens (after first frame). Android: on `AppLifecycleState.paused`, stop searches; after 60 s paused, `quit` the process; restart on next job. Crash or broken pipe: mark status error, restart once automatically; a second crash within 60 s sets status `unavailable` until the user taps "Restart engine" in Engine settings.

**Engine unavailable:** comparable checks resolve as `engine_unavailable` (wrong moves keep credit 0, no banner), deviations are disabled (book moves only), Play on and Analysis buttons are disabled with a tooltip.

## 5. Comparable check job (decision: time budget)

```
position fen <P>
setoption name MultiPV value <|A ∪ {u}|>
go infinite searchmoves <a1> <a2> ... <u>
stop when (elapsed >= minTime and depth >= 12 for all returned PVs) or elapsed >= maxTime
read the last complete info per multipv; map pv[0] → score
```
- `minTime` = **1.0 s** [setting "Check search time"], `maxTime` = `max(2.5 s, 2.5 × minTime)`, minimum depth 12.
- One search with `searchmoves` gives all scores from the same tree, which is more consistent than two separate searches.

**Decision on slow phones (open question from requirements):** the budget does **not** scale down. It is a floor of 1 s *and* depth 12, up to 2.5 s. Reason: the check runs in the background and never blocks the board, so a slow phone only delays the banner by a second or so, while a shallower search on a slow phone would hand out wrong half-credits. Depth 12 with NNUE is enough to tell a 0.3-pawn difference in opening positions reliably; a modern mid-range phone reaches it well inside 1 s. Calibration (§9) reports when a device usually needs more than 2 s so Eli knows.

Queue pressure: if the user makes several wrong moves quickly, checks queue up in order; each is independent. If more than 3 checks are queued, the oldest unfinished ones beyond the latest 3 continue anyway (all must resolve for grading); the 3 s finalize wait in [04-algorithms.md §1](04-algorithms.md) bounds the delay.

## 6. Deviation candidates job (prefetch)

Must be ready before the opponent's turn so the move still comes within the opponent delay.
- **End of line (default):** when a run with a challenge reaches the user's last book move (the leaf is a user move), schedule a LOW job on the position after that expected move while the user is thinking. If the user plays an alternative repertoire move that switches lines, recompute for the new line's leaf. Lines ending with an opponent move need no candidates.
- **Anywhere in the line:** with deviation ply d chosen, schedule the job on the position at ply d-1 as soon as the drill reaches ply d-2 or earlier, or immediately if the run starts at d-1. On a line switch, re-roll the ply for the new line (still at most one deviation per run).
- `MultiPV 5`, `go movetime 800`. Filtering per [04-algorithms.md §7.2](04-algorithms.md).
- If candidates are not ready when needed: end of line → skip the challenge; mid-line → the opponent plays the book move.

## 7. Play-on job

`setoption UCI_LimitStrength true` + `UCI_Elo <elo>` for 1500/2000/2500 (Stockfish accepts roughly 1320-3190), `false` for Full strength. `go movetime 600`. Engine moves are shown no sooner than 300 ms after the user's move lands. Reset `UCI_LimitStrength false` when leaving play-on.

## 8. Analysis stream

`go infinite` with MultiPV 1-3. Emit `AnalysisUpdate {depth, lines: [{scoreWhitePov, pvUci}], nps}` throttled to 10 Hz (`uci_engine` stays chess-agnostic; the app converts PVs to SAN with dartchess). Convert side-to-move score to White's point of view for the eval bar. The app shows at most 12 plies of each PV. Eval bar mapping: `fraction = 0.5 + 0.5 * (2 / (1 + exp(-0.004 * cp)) - 1)`, mate = full bar. Animate bar changes over 250 ms.

## 9. Calibration

Runs automatically once after first engine start (in background, after 10 s idle on Home) and on demand from Engine settings: `position startpos`, `go movetime 2000`, read final `nps` and depth. Also measures depth reached at 1.0 s on a fixed set of 5 opening positions (FENs in `calibration.dart`). Stores `nps`, `medianDepthAt1s`. Engine status line shows nps. If `medianDepthAt1s < 12`, the Engine settings show: "This device usually needs more than 1 s per check; banners may appear a little later." Diagnostics shows all numbers.

## 10. Tests

- Unit (FakeTransport): handshake, option setting, info parsing (cp, mate, upperbound/lowerbound lines ignored for final score), searchmoves command building, stop/readyok discarding of stale lines, preemption, crash restart, unavailable state.
- Integration (tag `engine`, Linux binary in CI): start/quit; comparable check on known positions (e.g. after 1.e4 e5 2.Nf3 with book `b8c6`: `g8f6` comparable, `f7f6` not comparable at 30 cp; the agent confirms the chosen pairs against the pinned binary and picks pairs with a wide margin so the test is not flaky); deviation candidates exclude book moves; play-on returns legal moves; analysis emits increasing depth; 20 sequential checks without leaks.
