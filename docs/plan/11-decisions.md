# 11. Decisions made by the planning thread

Decisions Eli made are in `requirements.md` and are not repeated here. These are the planning thread's calls, each with its reason. Seed `docs/DECISIONS.md` in the repo with this list; build agents append to it.

## Corrections and refinements to requirements.md

`requirements.md` belongs to the interview thread and was not edited. Where this plan departs from a *default* recorded there (never from one of Eli's own decisions), it is listed here.

| # | requirements.md says | Plan does | Why |
|---|---|---|---|
| C-1 | Opponent deviations: "configurable chance per opponent move (default 10%)" Chance **per line**, default 25 %, at most one per run, and **by default only after the line's last book move** (Eli, 2026-10-06: "a line should never deviate until the end of the line"). Mid-line deviations are an optional setting. (D-07) | 10 % per move means a typical line with 8 opponent moves deviates 57 % of the time. Eli wants every line to always play out the same. |
| C-2 | Performance: "opponent reply shown within 300 ms" | Opponent delay default **250 ms** (adjustable 0-1500) | A longer default delay would break the target by design. |
| C-3 | Re-import: stats kept for lines matched by move sequence; removed lines archived | Adds **extended lines**: if an old line is now a prefix of new lines, its history carries over to them (accuracy, weak pool), SRS restarts for them (D-11) | Extending a line is the most common edit; dropping its history would punish adding depth. |
| C-4 | Go straight to the next line by default | An end bar shows for 1.5 s (auto-advance, any tap cancels) with Play on and Summary buttons; set the delay to 0 for an immediate jump (D-14) | Play on vs engine ("I really like c") needs a place to be offered without forcing the summary screen. |

## Decisions

**D-01 SRS parameters.** SM-2 per line: pass = run accuracy ≥ 90 % (from requirements); intervals 1 d, 4 d, then × ease; ease starts 2.5, +0.10 on a perfect run, unchanged at 90-99 %, -0.20 on a fail, clamped 1.3-3.0; fail → relearn the same day; ±10 % deterministic fuzz from 4 days; cap 180 days; 10 new lines/day in PGN order; no review cap by default. Why: 4 d instead of SM-2's 6 d because opening lines interfere with each other (similar move orders), so early spacing should be tighter; deterministic fuzz keeps devices in agreement after sync; file order introduces related lines together.

**D-02 SRS and weak pool interaction.** They are independent derived views over the same runs. A failure in Random/Weak/Single mode pulls a line's SRS due date to today but does not change ease or count a lapse. Why: forgetting found anywhere should surface in SRS; extra practice elsewhere must not push the schedule out.

**D-03 Engine time budget.** Comparable checks search at least 1.0 s and depth 12, at most 2.5 s; no scaling down on slow phones. Why: the check is asynchronous, so slowness costs banner latency only, while shallow searches would give wrong half-credits. Calibration warns if a device is slow.

**D-04 Drive sync design.** `drive.appdata` scope, per-device files (meta + monthly run logs), LWW for repertoires, union for runs. Why: narrowest permission, no concurrent writes to one file, and no stats conflicts at all.

**D-05 Settings are device-local.** Why: phone and desktop want different board, engine and sound settings; nothing in requirements asks for settings sync.

**D-06 Stats are derived from immutable runs.** Accuracy, weak pool, SRS and streak are recomputed from run history. Why: makes sync, backup merge, threshold changes and re-imports correct by construction.

**D-07 Deviation mechanics.** See C-1. Default timing is end of line: the line is played and graded in full, then (on a hit) the opponent plays an engine move off the end of the book, or the user must find a move if the line ended on an opponent move. Optional timing "Anywhere in the line" keeps mid-line deviations. Candidates: engine MultiPV 5, moves within 1.00 pawn of the best, weighted towards the best. A reply passes if it loses ≤ 0.50 pawn vs the engine's best. Challenge results count only in deviation stats. End-of-line runs are ordinary runs for accuracy, weak pool and SRS; a mid-line deviated run never counts as an SRS review or a clean run, because the rest of the line was not played.

**D-08 Restart mode keeps first grades.** After a restart, already graded plies are not re-graded within the run. Why: the grade measures first-try knowledge; regrading would let a restart erase a mistake.

**D-09 Restart mode restarts on any non-repertoire move, comparable or not.** Why: waiting for the engine before deciding would block the board; the half credit is still applied when the check returns.

**D-10 Abandoned runs are stored but excluded from stats.** They still count for the "last 3 lines" exclusion. Why: quitting a bad run should neither help nor hurt.

**D-11 Extended lines inherit history.** See C-3.

**D-12 Multi-game PGNs are merged into one tree.** Why: lets an AI split long repertoires across games and accepts lichess study exports unchanged.

**D-13 Accuracy is move-weighted across the last 10 runs; overall repertoire accuracy is the mean of line accuracies.** Why: short branch-point runs shouldn't count as much as full runs; at repertoire level each line should matter equally.

**D-14 End bar.** See C-4.

**D-15 Branch point = deepest fork on the line that still has a user move after it.** Why: everything before it is shared with other lines and is trained through them.

**D-16 Clean run = every graded move credit 1.** Half credit is not clean. Why: leaving the weak pool should require the repertoire move itself.

**D-17 Weak pool entry only after a non-clean run.** Why: hysteresis; without it a line leaving after 3 clean runs re-enters at once because older failures are still in its 10-run window.

**D-18 Board and rules from lichess (`chessground`, `dartchess`), therefore GPL-3.0.** Stockfish already forces GPL. Why: the board is the centrepiece; these packages are the most polished available.

**D-19 Stockfish via `Process` on all platforms, Android binary from `nativeLibraryDir`.** FFI is the fallback. Why: one code path, testable on Linux CI.

**D-20 Linux desktop as a dev/CI target.** Not shipped. Why: build agents need to run the real app and engine end to end without a phone.

**D-21 Day starts at 04:00 (setting).** Applies to streak and SRS days. Why: late-night sessions belong to the evening they started in.

**D-22 Working name "Repertoire Trainer", id `dev.eliroderick.repertoiretrainer`.** Rename is cheap until release (P13).

**D-23 Line identity = SHA-256 of the UCI sequence (16 hex chars); runs store the full sequence.** Why: stable across comment edits, and lets stats follow line extensions and survive any PGN version on any device.

**D-24 No notifications, no analytics, no crash service.** Logs are local and exportable.

**D-25 Dark theme by default.** Requirements ask for dark mode; Eli emphasised the board, which reads best on a dark surround. Light and System are available.
