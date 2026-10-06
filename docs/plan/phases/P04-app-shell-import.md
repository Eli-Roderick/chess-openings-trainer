# P04. App shell, Home, create/import/re-import, repertoire management

**Depends on:** P03.
**Read first:** [01-product-spec.md §2-§6, §13, §14](../01-product-spec.md), [07-comment-format.md §6](../07-comment-format.md), [08-annotation-prompt.md](../08-annotation-prompt.md), [02-architecture.md §5](../02-architecture.md), [10-testing-and-quality.md §6](../10-testing-and-quality.md).

## Goal
A usable app without training: themes, navigation, Home, creating repertoires from a file or pasted text with the full import report, re-import with diff, rename, delete with undo, export PGN, the demo repertoire, and the first Diagnostics pieces.

## Tasks
1. Theme (`app/theme/`): Material 3 dark (default), light, system; colour tokens; Inter font bundled; typography with tabular figures for move text. Settings → Appearance (theme picker) implemented now.
2. Router with all routes of [01-product-spec.md §2](../01-product-spec.md) (screens not built yet show a placeholder).
3. Responsive scaffold helper: `AdaptiveLayout` deciding phone vs wide per [01-product-spec.md §3](../01-product-spec.md); used by all screens from now on.
4. Home per §4: empty state with Create and Try the demo, repertoire cards (accuracy/due/weak are shown when non-null; they will light up after P07/P08), context menu, FAB. Streak card and Continue button are placeholders hidden until P08/P10.
5. Create screen per §5: name, colour, file pick (`file_picker`, `.pgn`/`.txt`), paste field, Validate only, Validate and import, Copy annotation prompt (Prompt 1 text from [08-annotation-prompt.md](../08-annotation-prompt.md) stored as a Dart const with `<<WHITE or BLACK>>` filled).
6. Import controller: runs `importPgn` in `Isolate.run`, progress stages, cancel (ignore result when cancelled), then report screen.
7. Import report screen per §5: counts, grouped errors/warnings/info with SAN paths, mini board preview on tap (static board rendering via `chessground` in non-interactive mode; P05 refines theming), Copy report, Import/Cancel, "Processed in N ms" footer.
8. Repertoire detail per §6 (Train/Browse/Stats buttons navigate to placeholders).
9. Re-import flow per §13 with the diff block from `reimport_diff`.
10. Rename dialog, delete with SnackBar undo (6 s), Export PGN via save dialog.
11. Demo install: copies the bundled PGN through the normal import path, named "Demo: Italian (White)".
12. Diagnostics screen skeleton (About → 7 taps) with Startup timings and Frames sections per [10-testing-and-quality.md §6](../10-testing-and-quality.md); Android `rt/native` channel method `processStartElapsedMs`.
13. Settings screen shell with all section headers; only Appearance and About functional now.
14. Startup path per [02-architecture.md §5](../02-architecture.md) rule 1.

## Tests
- Widget tests: Home empty/data states; Create validation (empty name, no colour, no source); report screen renders each level and disables Import on errors; re-import diff numbers; rename; delete + undo; theme switch.
- Integration (Linux): demo install → detail screen shows 12 lines; import malformed fixture → warnings visible → import → appears on Home.
- Text scale 1.3 golden-free overflow test on Home, Create, Report (no `RenderFlex overflowed` errors).

## Acceptance criteria
- Every interaction in §4, §5, §6, §13, §14 of the product spec works except those marked for later phases.
- Cold start on Linux release build shows Home data < 1 s with 10 repertoires in the DB (integration test with timing log).
- No jank-inducing work on the UI isolate during import (import runs in isolate; verified by test that the UI pumps frames during a 5,000-line import).

## Device checklist (Eli)
- [ ] Create a repertoire from one of your real PGNs (uncommented): report shows W-NO-COMMENT for your moves, import succeeds.
- [ ] Copy annotation prompt works; paste it into your AI of choice with a PGN; import the result; note the warning count.
- [ ] Diagnostics shows startup time; note the number.
- [ ] Rename, delete + undo, export PGN to Downloads.
