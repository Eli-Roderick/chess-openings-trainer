# Repertoire Trainer: build plan

The complete specification for Eli's chess openings study app, written so AI build agents can implement it phase by phase. `requirements.md` (from the requirements interview) is the source of truth for what Eli decided; everything here elaborates it. Where this plan refines a default from requirements, [11-decisions.md](11-decisions.md) says so and why.

## Files

| File | What it is |
|---|---|
| [requirements.md](requirements.md) | Eli's decisions (owned by the interview thread) |
| [01-product-spec.md](01-product-spec.md) | Every screen, flow, behaviour and setting with defaults |
| [02-architecture.md](02-architecture.md) | Stack, packages, repository layout, layering, performance rules, platforms, CI, agent rules |
| [03-data-model.md](03-data-model.md) | Database tables, line identity, re-import rules, in-memory tree |
| [04-algorithms.md](04-algorithms.md) | Grading, accuracy, weighted randomizer, weak pool, SRS, branch point, engine judgements, stats derivation, streak |
| [05-engine.md](05-engine.md) | Stockfish packaging, UCI service, time budget, calibration |
| [06-sync.md](06-sync.md) | Google Drive sync design, auth, Google Cloud setup, backup file |
| [07-comment-format.md](07-comment-format.md) | Structured PGN comment spec, parser, validator codes, example |
| [08-annotation-prompt.md](08-annotation-prompt.md) | Ready-to-use prompts for an AI to annotate your PGNs, and to fix import warnings |
| [10-testing-and-quality.md](10-testing-and-quality.md) | Test layers, fixtures, end-to-end flows, performance verification, Diagnostics screen |
| [11-decisions.md](11-decisions.md) | Decisions made during planning, with reasons, and corrections to requirements defaults |
| [phases/](phases/) | One file per build phase: tasks, tests, acceptance criteria, device checklist |

## Answers to the open questions from requirements

- **SRS parameters:** SM-2 per line; pass ≥ 90 %; intervals 1 d → 4 d → × ease (2.5 start, 1.3-3.0); fail → relearn the same day; 10 new lines a day in PGN order; cap 180 d. ([04 §5](04-algorithms.md), D-01)
- **SRS vs weak pool:** independent; a failure in any mode pulls the line's SRS due date to today. (D-02)
- **Engine budget on slow phones:** no scaling down; at least 1 s and depth 12, at most 2.5 s, because the check is asynchronous and accuracy of half-credits matters more than banner speed. ([05 §5](05-engine.md), D-03)
- **Drive sync:** hidden appDataFolder, each device writes only its own files, newest-wins per repertoire, runs merged by union, all stats re-derived; syncs on start, on background, 30 s after changes, and on demand. ([06](06-sync.md), D-04)
- **Deviation details:** lines always play out exactly as written; by default deviations happen only after the last book move (mid-line is an optional setting). Per-line chance (default 25 %), engine picks a move within 1 pawn of best, the reply passes within 0.5 pawn of the engine's best, tracked separately. (C-1, D-07)

## Phases

| Phase | Name | Depends on | Can run in parallel with |
|---|---|---|---|
| [P00](phases/P00-bootstrap.md) | Repository bootstrap and CI | | |
| [P01](phases/P01-pgn-import.md) | PGN import, comments, validation, lines (pure Dart) | P00 | P06 tasks 1-4 |
| [P02](phases/P02-training-logic.md) | Training logic: grading, accuracy, randomizer, weak pool, SRS, streak (pure Dart) | P01 | P06 tasks 1-4 |
| [P03](phases/P03-persistence.md) | Database, repositories, settings, stats derivation | P02 | |
| [P04](phases/P04-app-shell-import.md) | App shell, Home, create/import/re-import, management | P03 | |
| [P05](phases/P05-board-browse.md) | Board, sounds, Browse | P04 | P11 |
| [P06](phases/P06-engine.md) | Stockfish service, analysis board, engine settings | P00 (tasks 1-4), P05 | P11 |
| [P07](phases/P07-drill-core.md) | Drill core in Random mode | P05, P06 | P11 |
| [P08](phases/P08-training-modes.md) | Weak pool, SRS, single line, summaries | P07 | P11 |
| [P09](phases/P09-deviations-play-on.md) | Opponent deviations, play on vs engine | P08 | P10, P12 |
| [P10](phases/P10-stats-streak.md) | Stats screens, streak | P08 | P09, P12 |
| [P11](phases/P11-backup-sync-core.md) | Backup and sync core (codec, merge) | P03, P04 | P05-P10 |
| [P12](phases/P12-drive-sync.md) | Google Drive sync | P11 | P09, P10 |
| [P13](phases/P13-performance-polish-release.md) | Performance pass, polish, release | all | |

```
P00 ─┬─ P01 ─ P02 ─ P03 ─ P04 ─┬─ P05 ─ P06 ─ P07 ─ P08 ─┬─ P09 ─┐
     └─ P06 (engine package) ──┘                          ├─ P10 ─┼─ P13
                               └─ P11 ─────────────────── P12 ────┘
```

The critical path is P00 → P08 (a usable trainer). After P08 Eli has a working app on his phone; P09-P12 add engine extras, stats, and sync; P13 makes it release-quality.

## How a build thread uses this plan

1. Read this README, `requirements.md`, its phase file, and the spec sections the phase file lists under "Read first". The phase file's tasks are the scope; the spec files are the detail.
2. Ambiguity: pick the reasonable default consistent with the spec, record it in the repo's `docs/DECISIONS.md`, continue. Ask Eli only when the answer changes what he gets.
3. Open one PR per phase (`P<nn>: <name>`), meet every acceptance criterion, keep CI green, and post the device checklist for Eli in the thread.
4. Update `docs/PROGRESS.md`. If the spec turned out wrong, fix it in `docs/plan/` in the same PR and say so in the PR description.

## Things Eli has to do himself

| When | What |
|---|---|
| Before P00 | Create an empty GitHub repository (or let a build thread create it) and connect it to the project. |
| P00 | Store the Android signing keystore and passwords safely offline (P00 explains); add the repository secrets if the agent cannot. |
| Any time | Annotate your PGNs with [Prompt 1](08-annotation-prompt.md); import; fix warnings with Prompt 2. |
| Each phase | Run the phase's device checklist on your phone (and Windows where listed). |
| Before P12 device checks | One-time Google Cloud setup ([06-sync.md §5.4](06-sync.md)), about 15 minutes. |
