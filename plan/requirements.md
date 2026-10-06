# Chess Openings Study App: Requirements

Running record of decisions from the requirements interview with Eli (started 2026-10-06).
Each entry notes whether Eli decided it or a default was chosen because Eli deferred.

## Project goal (from project settings)
- In-depth chess openings study app, runs locally, offline first.
- Import a PGN-like repertoire where every move carries a comment on why it is played and what it accomplishes.
- Randomizer picks lines from the imported repertoire and plays them against the user. Not purely random (no repeats back to back), not strict round-robin exhaustion either.
- Track accuracy per line; option to train only a pool of the user's weakest lines, randomly.
- Built almost entirely by AI, so the plan must be exhaustive.

## Decisions

### Platform and devices (Eli, 2026-10-06)
- Built in **Flutter**. Primary target **Android**; **Windows** also maintained as a second target.
- Studied mainly on phone, sometimes Windows. Layouts must be phone-first (portrait), with a usable desktop/wide layout.
- **Sync: optional, via Google Drive.** App is fully functional offline with no account; Drive sync is opt-in.

### Repertoires (Eli, 2026-10-06)
- Eli already has PGNs for their openings, **without comments**. Comments will be added by an external AI, not by the app.
  - Implication: the plan must include a written comment-format spec plus a ready-to-use prompt Eli can give an AI to annotate a PGN in that format. The importer must validate it.
- Single PGN file with comments inline (two-file approach rejected: a separate comments file keyed to moves breaks whenever the PGN is edited).
- Repertoires are user-created entities: create, **name it**, **import a PGN**, **choose the colour** the user plays. Any number of repertoires per colour.

### Training core (Eli, 2026-10-06)
- Main function: app picks a line from the PGN (a full path through the variation tree) and plays the opponent's moves from that line while the user plays their side.
- Engine use is core (see Engine section).

### Lines and drills (Eli, 2026-10-06)
- **Line = one root-to-leaf path** in the PGN variation tree. Number of lines = number of leaf nodes. All lines start from the initial position.
- **Drill start:** user can choose to start from move 1 or skip ahead to where the line branches off from already-known shared moves (option in drill setup).
- **Multiple user moves in a position** (user's side has 2+ repertoire moves): any repertoire move is correct; the drill continues down a line consistent with what the user played.
- **Wrong move handling: user-selectable mode in settings.**
  - Mode A "Restart on mistake": a wrong move restarts the entire line.
  - Mode B "Retry": the wrong move is taken back (piece animates back) and the user retries the same position **unlimited times** until they play the repertoire move.
- **Engine feedback on wrong moves:** if the wrong move is engine-comparable to the repertoire move, show a banner at the top: "That is not the move in your repertoire, but it is a comparable move." The piece is still moved back and the user must play the repertoire move.
- **Hint button, two levels:** 1st press highlights the piece to move; 2nd press shows the full move. **Any hint use marks that move incorrect.**

### Accuracy, randomizer, weak pool (Eli, 2026-10-06)
- **Accuracy per line** = % of the user's moves correct on the first try, over the **last 10 runs** of that line.
- **Randomizer:** weighted random. Each line's weight grows with time since it was last played and with lower accuracy. The last 3 lines played are blocked from being picked. No exhaustion cycle.
- **Weak-line pool:** lines under 80% accuracy enter automatically; a line leaves after 3 consecutive clean runs. Thresholds editable in settings. (Eli picked option a only, so no manual flagging unless added later.)

### Comments (Eli, 2026-10-06)
- **Comments appear only on the user's own moves**, shown after each of the user's moves (not on opponent moves).
- When the user's move responds to the opponent's preceding move, the comment must say so: why this move is played given what the opponent just did.
- Comment format: Eli deferred ("whatever you think best"). See defaults.

### Spaced repetition (Eli, 2026-10-06)
- **SRS mode as a separate training mode**, alongside weighted random and weak-pool modes. Lines become "due" after intervals in days.

### Engine (Eli, 2026-10-06)
- On-device **Stockfish** (Android + Windows) is a core dependency.
- **Comparable move** = engine eval within **0.3 pawns** of the repertoire move's eval, about **1 second** of engine time.
- **A comparable-but-wrong move scores half credit** (0.5) in first-try accuracy. Non-comparable wrong move or any hint = 0.
- Engine features wanted:
  - a) **Analysis board with eval bar** in browse mode.
  - b) **Opponent deviations:** the opponent sometimes plays a move that is not in the file, and the user must find a good reply (judged by engine).
  - c) **Play on against the engine after a line ends.** Eli said "I really like c": treat as high priority.

### Drill flow (Eli, 2026-10-06)
- At line end: **go straight to the next line by default**; a setting toggles a post-line summary screen (accuracy, mistakes, comments on missed moves).
- **Re-importing a PGN** into an existing repertoire keeps stats for lines that still exist, matched by move sequence. Removed lines' stats are dropped (or archived); new lines start fresh.
- **Transpositions:** lines are always treated separately, even if they reach the same position.
- **Scope:** the user opens a repertoire and trains it; every line in that repertoire is eligible. No branch-subset picking and no cross-repertoire mixing required.
- **Browse mode:** step through the repertoire tree and read comments without being tested. Includes the analysis board (engine feature a).
- **Stats screen, per repertoire:** accuracy per line, overall repertoire accuracy, history over time, worst lines.

### Sync and backup (Eli, 2026-10-06)
- **Google Drive sync** of repertoires and stats; conflicts resolved per record, newest change wins.
- **Manual export/import of a backup file** as well.

### Feel and performance (Eli, 2026-10-06)
- **The board is the centrepiece.** It must feel very smooth and pleasant: fluid drag and tap moves, polished animations, responsive feedback, move sounds, flip board, board and piece themes.
- **Performance is a top priority.** The app must be highly optimised and fast everywhere (startup, import, drills, stats).
- **Dark mode.**
- **Daily streak.**

## Defaults chosen where Eli deferred
- **Structured comments** inside standard PGN `{}` comments, e.g. `{[%why ...] [%plan ...] [%watch ...]}`. Plain-text comments still accepted (treated as `why`). Only moves of the repertoire's chosen colour need comments. The spec and an AI annotation prompt will enforce "reference the opponent's previous move when relevant".

- **Performance targets** (proposed, the plan should verify on a mid-range Android phone): cold start under 1.5 s to a usable home screen; board animations at the display refresh rate (60/90/120 Hz) with no dropped frames; opponent reply shown within 300 ms of the user's move (the engine check for comparable moves runs asynchronously and must never block the board); a 1,000-line PGN imports in under 2 s.
- **SRS algorithm:** SM-2-style scheduling per line. A run scoring 90% or more counts as a pass. Exact parameters are left to the planning thread.
- **Opponent deviations (engine b):** off by default, and when on, a configurable chance per opponent move (default 10%). The deviation is a plausible non-book move (within about 1 pawn of the engine's best). The user's reply is judged by the engine. It is tracked as its own stat, not mixed into repertoire accuracy.
- **Play on vs engine (engine c):** an optional button at line end. Engine strength is adjustable. Results are not counted in repertoire accuracy.
- **Daily streak:** a day counts if the user completes at least one line. Streak shown on the home screen.
- **Notifications:** none by default (not requested).
- **Re-import of a different colour:** not allowed; colour is fixed per repertoire.
- **Removed lines on re-import:** their stats are archived, not deleted, so re-adding the line restores them.
- **Comment validation on import:** moves of the user's colour without a comment are allowed, but are flagged in the import report. Malformed tags fall back to plain text.

## Open questions (none blocking; the planning thread can settle these)
- Exact SRS parameters and how SRS interacts with the weak pool when both apply.
- How much engine time is budgeted on low-end phones (whether 1 s for the comparable check should scale down).
- Drive sync mechanics (appDataFolder vs a visible folder, sync triggers, offline queue).
- Opponent-deviation selection details and how deviation replies are scored.
