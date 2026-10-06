# P09. Opponent deviations and play on vs engine

**Depends on:** P08.
**Read first:** [01-product-spec.md §8](../01-product-spec.md), [04-algorithms.md §7.2, §7.3](../04-algorithms.md), [05-engine.md §6, §7](../05-engine.md), [11-decisions.md C-1, D-07](../11-decisions.md).

## Goal
Engine features (b) and (c) from the requirements: the opponent sometimes leaves the book and the user must find a good reply; after any line the user can play on against the engine.

## Tasks
1. Deviation planning in the drill controller: roll at line start with `Rng`. Default timing **end of line**: the line plays and grades in full, then the off-book challenge per [01-product-spec.md §8.1](../01-product-spec.md) (opponent engine move after a user leaf; direct user move after an opponent leaf); prefetch while the user thinks about the last book move; skip the challenge if not ready. Optional timing **anywhere in the line**: choose the ply, prefetch, re-roll on branch switch, fall back to the book move when not ready ([05-engine.md §6](../05-engine.md)).
2. Deviation execution: play the move (if any), deviation sound, the banner text for the timing in use, user reply (no take-back), judgement via `judgeReply`, result display (green "Good reply" or "Inaccurate" with best-move arrow), hints show engine best and fail the reply, then line end with Play on prominent.
3. Persist `DeviationEvent` with the run; `deviated = true` only for mid-line deviations; grading rules per [11-decisions.md D-07](../11-decisions.md).
4. Settings → Training: deviations on/off, chance per line, timing (End of line default / Anywhere in the line); mode sheet switch now active (session override).
5. Play-on screen per [01-product-spec.md §8.2](../01-product-spec.md): starts from the current drill position, engine strength from settings, take back, flip, analyse (opens Browse-style analysis at that position in free exploration), game end detection via dartchess, back to training resumes the drill with the next line.
6. End bar and summary: Play on button visible.
7. Diagnostics: deviation job timings.

## Tests
- Controller (fake engine): end-of-line default never changes a book move (property test over all lines of the demo repertoire at 100 % chance); end-of-line run grades and counts as a normal run (clean/SRS); challenge after user leaf and after opponent leaf; challenge skipped when not ready; mid-line timing: deviation at chosen ply; candidates not ready → book move; reply pass/fail thresholds; hint during reply fails it; deviated run grading and persistence; re-roll on branch switch; 0 % never deviates, 100 % always deviates when an eligible ply exists.
- Play-on: engine reply legal; take back restores two plies; game-end dialogs (fixtures: mate in 1, stalemate position, threefold via scripted moves).
- Integration flow 14 (real engine).

## Acceptance criteria
- The line's book moves are never altered with the default timing (test above).
- With deviations on, the opponent's deviation move appears within the normal opponent delay (no visible wait) in ≥ 95 % of cases on Linux CI; otherwise the book move is played.
- Deviation stats are not mixed into line accuracy (test).

## Device checklist (Eli)
- [ ] Turn deviations on at 100 % for a few lines: every line plays exactly as written, then the opponent goes off-book without hesitation and the judgements look sensible.
- [ ] Try "Anywhere in the line" once to confirm it works, then switch back.
- [ ] Play on at each strength for a few moves; take back works; the phone stays responsive.
