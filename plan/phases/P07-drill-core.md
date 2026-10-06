# P07. Drill core (Random mode)

**Depends on:** P05, P06.
**Read first:** [01-product-spec.md §7 (all)](../01-product-spec.md), [04-algorithms.md §1, §3, §6, §7.1](../04-algorithms.md), [05-engine.md §5](../05-engine.md), [11-decisions.md D-08, D-09, D-10, D-14](../11-decisions.md).

## Goal
Train a repertoire in Random mode end to end: line selection, opponent moves, user moves, both mistake modes, hints, comments, comparable checks with half credit and banner, branch-point start, alternative-move branch switching, run persistence and the end bar.

## Drill controller state machine (`features/drill/drill_controller.dart`)

State (freezed): `phase`, `line`, `nodeAtBoard`, `startPly`, `gradesByPly`, `attemptsAtPly`, `hintLevel`, `banner`, `lastComment`, `boardView`, `sessionStats`, `pendingChecks`.

```
phases: picking → (opponentToMove | userToMove) → … → lineComplete → picking …
picking:        line = picker.pick(); startPly = settings.start == branch ? line.branchPly : 0
                board = position at startPly (no animation); runBuilder = RunBuilder(...)
                → next phase by side to move at startPly
opponentToMove: wait opponentDelay (Timer, from end of previous animation); play line move at ply+1
                if that was the leaf → lineComplete else → userToMove
userToMove:     on move m:
                  if m == expected or m ∈ children(node) (user side) → correct path
                      (if m != expected: switch line per 04 §3.4)
                      grade if first event; sounds; comment; → opponentToMove or lineComplete (if leaf)
                  else → mistake path per 01 §7.7 (retry: take back; restart: reset to startPly)
                      queue EngineService.checkComparable(...) → on result: runBuilder.applyCheck(ply, outcome); maybe banner
                on hint → hintLevel++ (max 2); runBuilder.hint(ply); highlight/arrow
lineComplete:   runBuilder.finalize(waitForChecks: 3 s) in background → RunRepository.insertRun → StatsService
                show end bar (auto-advance countdown) → picking
abandon:        on dispose / Skip line / app detach: persist incomplete run (completed=false)
```
All timers are cancelled on dispose; every async callback checks it still belongs to the current run (run token) before mutating state.

## Tasks
1. Controller above, using P02 `RunBuilder`/`PlyGradeBuilder` and the Random picker with exclusion from `RunRepository.recentStartedLineKeys` + session history.
2. Drill screen per [01-product-spec.md §7.2](../01-product-spec.md): app bar, banner area, board, info/comment panel, bottom bar (Hint, progress, run accuracy, Skip line), wide-layout move list with result marks.
3. Mistake handling for both modes with animations and sounds; hint levels with highlight and arrow.
4. Comparable banner exact text "That is not the move in your repertoire, but it is a comparable move." (4 s, tap to dismiss; prefix with SAN if the user moved on). Engine-unavailable path.
5. Branch-point start with "Skipped to move N" chip and skipped-moves popover.
6. End bar per §7.9 (Next line with countdown ring, Play on (hidden until P09), Summary (hidden until P08)); auto-advance delay setting; tap cancels countdown.
7. Settings → Training: wrong-move mode, auto-advance delay, opponent delay, show comments, show comment arrows, start-from default (the mode sheet comes in P08; until then Train starts Random with the stored start-from setting).
8. Drill latency metric into Diagnostics (user drop → opponent animation start, p50/p95).
9. Session summary sheet on exit (§7.10).
10. Keyboard: H hint, Space/Enter next line, F flip, Esc back.

## Tests
- Controller unit tests (fake engine, fake clock, seeded rng, in-memory repos): full correct line; wrong move retry (grade 0, attempts counted); wrong then comparable result (0.5); comparable result arriving after the user already moved on (grade still updated, banner prefixed); comparable after hint stays 0; restart mode resets and does not regrade; hint levels; alternative user move switches line and run stored under the completed line; line ending with an opponent move; branch start; skip line → abandoned run; dispose mid-line → abandoned run; engine unavailable → no banner, 0 credit; check timeout at finalize → `timeout` status.
- Opponent delay respected exactly with fake clock; no opponent move after dispose.
- Widget tests: end bar countdown and cancel; banner shows/dismisses.
- Integration flows 1-7 from [10-testing-and-quality.md §3](../10-testing-and-quality.md).

## Acceptance criteria
- All tests green; drill usable start to finish on phone and wide layouts.
- p95 drill latency ≤ 300 ms with default settings in the Linux profile integration run.
- Board never waits on the engine (test: fake engine that delays checks 5 s; opponent still moves on time).

## Device checklist (Eli)
- [ ] Train your annotated repertoire for 10 lines in Retry mode, then 5 in Restart mode.
- [ ] Play a reasonable non-repertoire move: banner appears within about 1-2 s.
- [ ] Hint twice, check the move shows; stats later show that move as wrong.
- [ ] Try Branch point start.
- [ ] Diagnostics drill latency p95 ≤ 300 ms; frames over budget < 1 %.
