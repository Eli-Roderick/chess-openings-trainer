# 01. Product specification

Every user-visible behaviour of the app. Algorithms are in [04-algorithms.md](04-algorithms.md), the engine in [05-engine.md](05-engine.md), sync in [06-sync.md](06-sync.md). Where this file and `requirements.md` disagree, [11-decisions.md](11-decisions.md) explains why.

Working name: **Repertoire Trainer** (package `repertoire_trainer`, Android applicationId `dev.eliroderick.repertoiretrainer`). Renaming later is a find-and-replace task in phase P13.

## 1. Glossary

| Term | Meaning |
|---|---|
| Repertoire | A named, user-created collection: one PGN tree + one colour (White or Black) the user plays. |
| User colour | The colour fixed on the repertoire. "User moves" are moves by that colour; "opponent moves" are the other colour's. |
| Node | One move in the repertoire tree (position after the move). The root is the initial position (no move). |
| Line | One root-to-leaf path in the tree. Number of lines = number of leaves. |
| Line key | Stable id of a line: hash of its UCI move sequence ([03-data-model.md §3](03-data-model.md)). |
| Fork | A node with 2+ children. |
| Branch point | The deepest fork on a line ([04-algorithms.md §6](04-algorithms.md)). |
| Run | One attempt at one line in a drill, from its start ply to its end (or abandonment). |
| Graded move | A user move inside a run that receives a credit (1, 0.5 or 0). |
| Credit | 1 = first try correct, no hint. 0.5 = first try was a comparable non-repertoire move. 0 = first try was a non-comparable wrong move, or any hint was used. |
| Line accuracy | Credits / graded moves over the line's last 10 eligible runs ([04-algorithms.md §2](04-algorithms.md)). |
| Clean run | A completed run where every graded move earned credit 1. |
| Weak pool | Set of lines flagged weak ([04-algorithms.md §4](04-algorithms.md)). |
| Comparable move | Non-repertoire move whose engine eval is within 0.30 pawns of the best repertoire move ([05-engine.md §5](05-engine.md)). |
| Deviation | The opponent plays a non-repertoire (engine-chosen) move. By default only after the line's last book move, so the line itself always plays out exactly as written ([§8.1](#81-opponent-deviations-off-by-default)). |

## 2. Navigation map

```
Home
 ├─ Create repertoire  → Import flow → Import report → Repertoire detail
 ├─ Repertoire detail
 │   ├─ Train (mode sheet) → Drill screen → (Line summary) → Drill screen …
 │   │                                     └─ Play on vs engine
 │   ├─ Browse → Analysis (toggle inside Browse)
 │   ├─ Stats → Line detail → Drill this line / Browse this line
 │   ├─ Re-import PGN → Import report (with diff) → back
 │   ├─ Rename / Export PGN / Delete
 ├─ Settings
 │   ├─ Training, Board & sound, Engine, Appearance, Sync & backup, About (+ hidden Diagnostics)
```

Router: `go_router`. Routes: `/`, `/repertoire/new`, `/repertoire/:id`, `/repertoire/:id/train?mode=`, `/repertoire/:id/browse?node=`, `/repertoire/:id/stats`, `/repertoire/:id/stats/line/:lineKey`, `/repertoire/:id/reimport`, `/settings`, `/settings/:section`, `/play-engine` (state passed via extra), `/diagnostics`.

Android back button and Windows Esc both pop; on the drill screen, popping asks nothing (runs in progress are abandoned, see §7.10).

## 3. Layout rules

- **Phone (width < 600 dp), portrait:** board full width at top under a slim app bar (48 dp). Below it: the info panel (comment / status) and a bottom action bar. Board never scrolls off screen. Landscape phone uses the wide layout.
- **Wide (width ≥ 600 dp, or landscape):** board on the left at `min(height - chrome, width * 0.62)` square; right panel holds comment panel, move list and actions.
- Board edge-to-edge on phones (no horizontal padding). All other content uses 16 dp gutters.
- Minimum touch target 48 dp. Text scales with system font scale up to 1.3x without overflow (tested).
- Material 3. Themes: Dark (default), Light, System. Dark is a true dark grey (#121212 surface) to keep the board the brightest element.
- Fonts bundled (Inter for UI, JetBrains Mono for move lists is NOT used; SAN uses Inter with tabular figures). No runtime font downloads.

## 4. First run and Home

**First run:** generate `deviceId` (UUID v4), store it. Home shows an empty state: title "No repertoires yet", buttons **Create repertoire** and **Try the demo** (installs the bundled demo repertoire, `assets/demo/italian_white.pgn`, a fully commented White repertoire of ~12 lines written in phase P4, used also by tests).

**Home screen content (top to bottom):**
1. App bar: title, Settings icon, Sync status icon (only when sync enabled: idle / syncing spinner / error badge; tap = sync now).
2. Streak card: flame icon (Material icon, not emoji), "N-day streak", "Best: M", and today's state: "Done today" (check) or "Train one line to keep your streak". Hidden until the user has completed at least one line ever.
3. "Continue" button: resumes the last trained repertoire in its last used mode (hidden if none).
4. Repertoire list, sorted by last trained (never trained last, by creation date). Each card: name, colour chip (white/black disc), line count, accuracy (or "Not trained"), due count (SRS, only if > 0), weak count (only if > 0). Tap opens Repertoire detail. Long-press (or right-click / kebab on wide) opens: Rename, Re-import, Export PGN, Delete.
5. FAB / primary button: "New repertoire".

Delete: confirmation dialog naming the repertoire and stating that stats are deleted too. Deletion is a soft delete (tombstone, needed for sync); a SnackBar offers Undo for 6 s.

## 5. Create and import a repertoire

**Create screen** fields: Name (required, 1-60 chars, trimmed, duplicates allowed but warned), Colour (segmented: White / Black; required), PGN source: **Choose file** (`file_picker`, extensions `.pgn`, `.txt`) or **Paste text** (multiline field, for phones where the PGN is in a chat). Buttons: **Validate and import** (primary), **Validate only** (shows the report, imports nothing), and a text button **Copy annotation prompt** that copies Prompt 1 from [08-annotation-prompt.md](08-annotation-prompt.md) with the selected colour filled in.

Import runs in a background isolate. While it runs: progress indicator with the stage name (Reading file, Parsing, Building lines, Checking comments). Cancel button.

**Import report screen** (also used by re-import and by the dry-run "Validate only"):
- Header counts: games merged, lines, user moves, opponent moves, user moves with comments (count and %), deepest line (plies).
- Errors (red): import blocked; list each with location.
- Warnings (amber), grouped by code ([07-comment-format.md §6](07-comment-format.md)), each group collapsible, each item shows a SAN path ("1.e4 e5 2.Nf3 Nc6 3.Bb5") and the message. Tapping an item opens a mini board preview of that position.
- Info (grey), collapsed by default.
- Buttons: **Import** (disabled if errors), **Cancel**. For re-import: also the diff block (§13).
- "Copy report" button copies the whole report as plain text (so Eli can paste it to the annotating AI for fixes).

Limits: file ≤ 10 MB (error above). More than 5,000 lines: warning ("training and stats work but import and browse will be slower").

## 6. Repertoire detail

Shows name, colour, line count, accuracy, coverage ("37 of 52 lines trained"), weak count, due today, new available today. Actions:
- **Train** (primary): opens the mode sheet (§7.1).
- **Browse** (§9).
- **Stats** (§11).
- Overflow: Rename, Re-import PGN, Export PGN, Delete, Validate stored PGN (shows report of current file).

## 7. Drill (training)

### 7.1 Mode sheet
Bottom sheet with:
- Mode (radio): **Random** (weighted, all lines), **Weak lines** (shows pool size; disabled with explanation when 0), **Spaced repetition** (shows "N due, M new available").
- Start from (segmented): **Move 1** / **Branch point**. Default Move 1. Remembered per repertoire.
- Opponent deviations: switch, mirrors the global setting, changeable per session (not persisted per repertoire).
- **Start** button.

### 7.2 Drill screen layout
- App bar: repertoire name, mode label ("Random", "Weak 6", "SRS 12 left"), flip-board icon, settings icon (opens Training settings as a sheet without leaving the drill).
- Banner area (overlays the top of the info panel, never the board): comparable banner, deviation banner, errors.
- Board, oriented to user colour (flip toggles for this session).
- Info panel: the **comment panel** for the user's last correct move (§7.6), or a prompt ("Your move", or the deviation prompts in §8.1).
- Bottom bar: **Hint** button (shows level: "Hint", "Show move"), progress text ("Move 5 of 9"), line accuracy so far this run, **Skip line** (abandon run, no stats recorded except as abandoned).
- Wide layout: right panel also shows the move list of the line so far (SAN, with per-move result marks).

### 7.3 Starting a line
1. Pick a line using the mode's picker ([04-algorithms.md §3, §4, §5](04-algorithms.md)).
2. Compute the start ply: 0 for "Move 1", the branch point for "Branch point" ([04-algorithms.md §6](04-algorithms.md)).
3. Set the board to the position at the start ply instantly (no animation of skipped moves). If moves were skipped, show a chip "Skipped to move N" in the info panel; tapping it shows the skipped moves as SAN text.
4. If the side to move is the opponent: play the opponent move after the opponent delay. If the user: prompt "Your move".

### 7.4 Opponent moves
- Opponent plays the next move of the chosen line after **opponent delay** (setting, default 250 ms, range 0-1500 ms), counted from the end of the user's move animation. Animated with the board's standard animation.
- If the line's leaf is an opponent move, it is played and then the line completes.
- With deviation timing "Anywhere in the line", at the deviation ply (§8.1) the opponent plays the deviation instead. With the default "End of line", the opponent never leaves the book before the line ends.

### 7.5 User moves
User moves by drag or tap-tap (both always enabled). Legal-move dots shown when a piece is selected (setting, default on). Premoves disabled. Promotion shows chessground's promotion selector.

Classification of a legal user move at node N (on the chosen line L):
- **Expected:** the child of N on L → correct.
- **Alternative repertoire move:** another child of N (N has several user-move children) → correct; the chosen line switches to a line through that child, picked by the active mode's weighting restricted to lines through that child ([04-algorithms.md §3.4](04-algorithms.md)). Grades already given stay.
- **Wrong:** not a child of N → mistake (§7.7).

On correct: move sound + light haptic, last-move highlight, the comment panel updates to this move's comment, the ply's grade is finalized if this is the first attempt.

### 7.6 Comment panel
Shows the structured comment of the user's most recent correct move (comments exist only on user moves):
- Heading: the move in SAN with move number ("12...Nd7").
- **Why** (always first; bold label "Why").
- **Plan** (if present).
- **Watch out** (if present; amber accent).
- **Alternatives** (if present; collapsed by default, "Show alternatives").
- If the comment has `%cal`/`%csl` shapes, they are drawn on the board while that comment is shown and cleared when the user makes the next move (setting "Show comment arrows", default on).
- No comment on that move: panel shows "No comment for this move" in muted text (never empty space).
- Panel scrolls internally if long; it never pushes the board.
- Setting "Show comments during drills" (default on). When off, comments still appear in summaries and Browse.

### 7.7 Mistakes
On a wrong move:
1. The piece lands on the target square, the destination square flashes red for 300 ms with the error sound and a medium haptic.
2. **Retry mode (default):** the piece animates back to its origin; the same position is retried; unlimited attempts.
   **Restart mode:** after the flash, the board resets to the run's start position (animated as a quick fade, 200 ms) and the opponent replays from there; moves already graded keep their first grade and are not graded again in this run.
3. The ply's grade is provisionally 0 and a **comparable check** is queued on the engine for (position, user move, repertoire moves) ([05-engine.md §5](05-engine.md)). It never blocks the board.
4. When the check returns comparable: the ply's first-attempt grade becomes 0.5 (only if the wrong move was the *first* attempt at that ply and no hint was used), and the banner "That is not the move in your repertoire, but it is a comparable move." shows for 4 s (tap to dismiss). If the user has already moved on, the banner still shows, prefixed with the move: "Bb5: that is not the move …".
5. Non-comparable: no banner beyond the red flash. Optional text "Not your repertoire move" in the info panel for 2 s.

Only the first attempt at a ply decides its grade; later wrong attempts never change it (except a hint, which forces 0).

### 7.8 Hints
- Press 1: highlight the from-square of the expected move (a soft blue square, plus the piece pulses once). Grade of this ply forced to 0.
- Press 2: draw an arrow for the full expected move. User must still play it.
- With alternative repertoire moves, the hint shows the move on the chosen line.
- During a deviation reply, the hint shows the engine's best move (and fails the deviation reply).

### 7.9 Line end
When the last move of the line has been played:
1. Line-complete sound. Run is finalized ([04-algorithms.md §1](04-algorithms.md)); persistence happens in the background and waits up to 3 s for pending comparable checks (unresolved checks count as 0 and are flagged).
2. **If "Show line summary" is off (default):** an end bar slides up over the bottom action bar: run accuracy ("8/9 · 89%"), **Next line** (with a countdown ring, auto-advance after the auto-advance delay, default 1.5 s, range 0-5 s; 0 = immediate), **Play on**, **Summary**. Any tap on the bar cancels auto-advance. The board keeps the final position until the next line starts.
3. **If "Show line summary" is on:** the Line summary screen opens: line label, run accuracy, line accuracy (last 10) before → after, weak-pool change ("Entered weak pool" / "Left weak pool"), SRS next due (in SRS mode), a list of the user's graded moves with marks (correct, half, wrong, hint) and, for each non-correct move, the expected move with its comment and the user's first attempt. Buttons: **Next line**, **Play on vs engine**, **Retry this line**, **Browse this line**.

### 7.10 Abandoning
Leaving the drill screen, pressing Skip line, or the app being killed mid-run records the run as `completed = false`. Abandoned runs are stored but excluded from all stats ([04-algorithms.md §2](04-algorithms.md)) so quitting a bad run does not help or hurt. On exit with at least one completed line this session, a small sheet shows the session summary (lines completed, session accuracy, streak status) with Done.

### 7.11 Session rules
- Lines continue indefinitely in Random and Weak modes.
- SRS mode ends when no due and no new-allowed lines remain: "All caught up. Next review: <date> (N lines)" with buttons **Train weak lines**, **Random**, **Done**.
- Weak mode with empty pool: "No weak lines. Nice." with **Random** and **Done**.

### 7.12 Drill this line
From the Line detail screen: drill a single line repeatedly ("single" mode). Runs count normally for accuracy and weak pool, not for SRS ([04-algorithms.md §5.6](04-algorithms.md)).

## 8. Engine extras in drills

### 8.1 Opponent deviations (off by default)
Settings: **Opponent deviations** on/off, **Deviation chance per line** (0-100 %, default 25 %), **Deviation timing**: **End of line** (default) or **Anywhere in the line**. Why per line and why end of line by default: [11-decisions.md C-1, D-07](11-decisions.md).

**End of line (default).** The line is always played exactly as written and graded normally. Deviations only happen once the book runs out:
- At line start, roll once with the chance. On a hit, the run gets an **off-book challenge** after the line's last move.
- If the line ends with a user move: after it, the opponent plays an engine-chosen move (a plausible move, not necessarily the best; [04-algorithms.md §7.2](04-algorithms.md)) with the deviation sound and the banner "Your repertoire ends here. The opponent plays on: find a good reply." The user plays any legal move (no take-backs), and the engine judges it.
- If the line ends with an opponent move: no extra opponent move is needed. Banner "Your repertoire ends here. Find a good move." The user's move is judged the same way.
- Result display: **Good reply** (green) or **Inaccurate** with the engine's best move as an arrow and "Best was Nf3". Then the end bar / summary, with **Play on** to continue from that position.
- The engine prepares the opponent's move while the user thinks about the last book move ([05-engine.md §6](05-engine.md)). If it is not ready when needed, the challenge is skipped for this run.
- The line's own graded moves count exactly as in a run without a challenge (accuracy, weak pool, SRS, streak). The challenge result counts only in deviation stats.

**Anywhere in the line (optional).** The old mid-line behaviour: on a hit, a deviation ply is chosen uniformly among the line's opponent plies after the start ply; the opponent plays an engine-chosen non-book move there instead of the book move; banner "Opponent left your repertoire. Find a good reply."; the reply is judged and the line ends. Graded moves before the deviation count in accuracy; the run is marked `deviated` and is not a clean run or an SRS review, because the rest of the line was never played ([04-algorithms.md §4, §5.2](04-algorithms.md)).

### 8.2 Play on vs engine
From the end bar or summary. Opens the Play-on screen at the current position, user keeps their colour and orientation.
- Engine strength: setting "Play-on strength", values "Club 1500", "Strong 2000", "Expert 2500", "Full strength" (default Expert 2500), via UCI_LimitStrength/UCI_Elo ([05-engine.md §7](05-engine.md)).
- Engine replies after its search (movetime 600 ms, minimum shown delay 300 ms).
- Controls: Take back (undo user move + engine reply), Flip, Analyse (opens Analysis at the current position), Resign/Back to training.
- Game end: checkmate, stalemate, threefold, 50-move, insufficient material: dialog with result. Nothing is stored.

## 9. Browse

- Board at a tree node. Starts at root (or `?node=` param, e.g. from "Browse this line").
- Navigation: buttons First / Back / Forward / Last; swipe left/right on the board area below (not on the board itself, to keep dragging pieces possible); keyboard ← → Home End; at a fork, Forward opens a chooser listing the children (SAN plus the first words of the comment for user moves); ↑/↓ cycles siblings on wide.
- Move list panel: the whole tree as a compact variation text (main line first, variations indented, collapsible per fork). Current node highlighted and auto-scrolled. Tap any move to jump.
- Comment panel as in §7.6 for user moves. Opponent moves show no comment.
- Moving pieces on the board in Browse: if the move matches a child, navigate there; otherwise enter **free exploration** (a temporary branch shown in italics, with a "Back to repertoire" chip). Free exploration is never saved.
- **Analysis toggle** (icon button): turns on the engine ([05-engine.md §8](05-engine.md)): eval bar at the board's left edge (wide: right of board), top line(s) shown under the board in SAN ("+0.35 d22 Nf3 Nc6 Bb5 …"), number of lines setting 1-3 (default 1). Tapping a PV move plays it into free exploration. Analysis stops when toggled off, when the screen is left, and when the app goes to background.

## 10. Settings (all with defaults)

**Training**
| Setting | Default | Range |
|---|---|---|
| Wrong move behaviour | Retry | Retry / Restart line |
| Show line summary | Off | On/Off |
| Auto-advance delay | 1.5 s | 0-5 s, step 0.5 |
| Opponent move delay | 250 ms | 0-1500 ms, step 50 |
| Show comments during drills | On | |
| Show comment arrows | On | |
| Opponent deviations | Off | |
| Deviation chance per line | 25 % | 0-100 %, step 5 |
| Deviation timing | End of line | End of line / Anywhere in the line |
| Weak pool: enter below accuracy | 80 % | 50-95 %, step 5 |
| Weak pool: leave after clean runs | 3 | 1-10 |
| SRS: new lines per day | 10 | 0-100 |
| SRS: max reviews per day | Unlimited | Unlimited or 10-500 |
| Day starts at | 04:00 | 00:00-06:00 hourly |

**Board and sound**
| Setting | Default |
|---|---|
| Board theme | Brown (chessground themes: brown, blue, green, grey, purple, wood + others the package ships) |
| Piece set | cburnett (any set chessground ships) |
| Coordinates | On (inside board) |
| Legal move dots | On |
| Highlight last move | On |
| Animation speed | Normal (200 ms); Fast 120 ms; Slow 300 ms; Off |
| Sounds | On; volume 0-100 % default 80 % |
| Haptics (Android) | On |
| Board preview (live preview of theme + pieces) | shown at top of this section |

**Engine**
| Setting | Default |
|---|---|
| Comparable threshold | 0.30 pawns (range 0.10-1.00) |
| Check search time | 1.0 s minimum (range 0.5-3 s) |
| Threads | Auto ([05-engine.md §3](05-engine.md)) |
| Hash | Auto |
| Play-on strength | Expert 2500 |
| Engine status line | "Stockfish 17.1 ready · 4 threads · 1.2 Mnps" or the error |
| Run calibration | button |

**Appearance:** Theme (Dark / Light / System, default Dark).

**Sync and backup:** Google Drive sync on/off, signed-in account, last sync time and result, **Sync now**, **Sign out**; **Export backup**, **Import backup** (merge or replace). See [06-sync.md](06-sync.md).

**About:** version, build, licenses (Flutter `showLicensePage` plus Stockfish GPL notice and source link), link to the source repository. Tapping the version 7 times opens **Diagnostics** ([10-testing-and-quality.md §6](10-testing-and-quality.md)).

All settings apply immediately. Settings are device-local (not synced), see [06-sync.md §2](06-sync.md).

## 11. Stats

**Repertoire stats screen:**
1. Summary tiles: overall accuracy, coverage (trained lines / total), weak pool size, SRS due today, total runs, current streak.
2. Accuracy over time chart (`fl_chart` line chart): daily accuracy (sum credits / sum graded moves of completed runs that day) with a 7-day moving average line; range chips 30 d / 90 d / All. Bars underneath for runs per day.
3. **Worst lines**: 10 lowest-accuracy lines with at least 1 eligible run; "Show all" opens a full sortable list (sort by accuracy, last played, runs, line order; filter: weak only, untrained, archived).
4. **Most missed moves**: top 10 plies (node + user move) by error rate, min 3 attempts: "12...Nd7 (missed 4 of 6)". Tap opens Browse at that node.
5. **Deviation replies** (only if any): count, good-reply rate, last 10 with result.

**Line detail screen:** line label and full SAN, accuracy, runs, weak pool state (and clean streak "2 of 3"), SRS state (due date, interval, ease), run history list (date, mode, accuracy, marks per move), per-move error table for this line, buttons **Drill this line**, **Browse this line**. Archived lines (removed by re-import) are viewable read-only, labelled "Not in current PGN".

Overall accuracy = mean of line accuracies over lines with at least one eligible run (each line weighs the same; see [04-algorithms.md §2.3](04-algorithms.md)).

## 12. Daily streak

A day (bounded by "Day starts at") counts when at least one run was completed that day, any repertoire, any mode, including single-line drills and runs ended by a mid-line deviation. Current streak = consecutive counted days ending today, or ending yesterday if today is not yet counted (the card then says "Train one line to keep your streak"). Best streak shown. Derived from runs, so it syncs naturally. No notifications.

## 13. Re-import

From Repertoire detail overflow. Same file/paste source. Colour cannot change (the importer uses the repertoire's colour). The report screen adds a **diff block**:
- Unchanged lines (stats kept): N
- Extended lines (old line is now a prefix of new lines; history carried over): N
- New lines: N
- Removed lines (stats archived, restored if the line comes back): N, expandable list
- Comment changes: N user moves with changed comments (informational)
Import replaces the stored PGN and rebuilds nodes and lines. Rules in [03-data-model.md §5](03-data-model.md).

## 14. Export

- **Export PGN:** writes the stored PGN (the exact text imported last, normalized line endings) via a save dialog, default name `<repertoire name>.pgn`.
- **Export backup / Import backup:** [06-sync.md §8](06-sync.md).

## 15. Keyboard shortcuts (Windows, also any hardware keyboard)

| Key | Action |
|---|---|
| F | Flip board |
| H | Hint |
| Space / Enter | Next line (end bar), Forward (Browse) |
| ← → Home End ↑ ↓ | Browse navigation |
| A | Toggle analysis (Browse) |
| Esc | Back |
| Ctrl+, | Settings |

## 16. Non-functional requirements

- Fully offline. The only network use is Google Drive sync, and only when enabled. No analytics, no crash reporting service.
- Android 7.0+ (minSdk 24), arm64-v8a and armeabi-v7a. Windows 10 1809+ x64.
- Performance targets ([10-testing-and-quality.md §5](10-testing-and-quality.md)): cold start < 1.5 s to usable Home on a mid-range phone; no dropped frames during board interaction; opponent reply starts ≤ 300 ms after the user's move lands (default delay 250 ms); 1,000-line PGN import < 2 s on phone.
- Data safety: SQLite with WAL; every run is written in a transaction; backup export always available.
- Licence: the app is GPL-3.0-or-later because it bundles Stockfish, dartchess and chessground (all GPL-3.0). Source must be published with any distributed binary.
