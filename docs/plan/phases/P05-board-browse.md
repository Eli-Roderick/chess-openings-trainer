# P05. Board foundation, sounds, Browse mode

**Depends on:** P04.
**Read first:** [01-product-spec.md §3, §7.5, §7.6, §9, §10 (Board and sound), §15](../01-product-spec.md), [02-architecture.md §5](../02-architecture.md).

## Goal
The board that every screen uses, made to feel excellent, plus Browse mode (without engine analysis).

## Tasks
1. `features/board/repertoire_board.dart`: wrapper around `chessground`'s board widget. Inputs: FEN, orientation, side allowed to move (or none), last move, shapes (arrows/circles), square highlights (hint, error flash), animation duration, interactivity. Output: `onUserMove(NormalMove)`. Uses dartchess for legal moves (dests map). Wrapped in `RepaintBoundary`; rebuilt only when inputs change (`==` on an immutable `BoardViewState`).
   - Test hook: `RepertoireBoardController` exposed via provider with `debugPlayUserMove(String uci)` that calls the same handler as a real move (used by widget and integration tests).
   - Error flash: destination square red overlay 300 ms, then the caller decides (take back or restart).
   - Take-back animation: piece animates from the wrong square back to its origin (use chessground's animation by setting the previous FEN with the move as `lastMove` reversed, or the package's equivalent; agent verifies the smoothest approach against the pinned version and documents it in DECISIONS.md).
   - Promotion: chessground promotion selector.
   - Size: square, `min(width, available height)`; on phones edge-to-edge.
2. Board settings (Settings → Board and sound) per [01-product-spec.md §10](../01-product-spec.md) with a live preview board at the top. Piece-set and board-theme lists come from chessground's enums. Precache the active piece set's images after first frame and on change.
3. `core/audio/sound_service.dart` with `flutter_soloud`: preload all sounds after first frame; `play(SoundType)`, volume, mute. Sounds: move, capture, check, castle, error, line_complete, deviation, hint. Source: lichess `lila` "standard" sound set if its licence permits redistribution in a GPL app (check `lila/COPYING.md`), else Kenney (CC0) or other CC0 sounds; record source and licence in `THIRD_PARTY.md`. Convert to OGG (Android) and include WAV fallback if Windows needs it.
4. `core/haptics/`: light (move), medium (error) via `HapticFeedback`; no-op on Windows; setting toggle.
5. `features/board/comment_panel.dart` per [01-product-spec.md §7.6](../01-product-spec.md): Why / Plan / Watch out / Alternatives (collapsed), SAN heading, "No comment for this move", internal scrolling, fixed max height on phone (35 % of screen height), fade transition (150 ms) on change.
6. `features/board/move_tree_view.dart`: compact variation text for the whole tree, virtualized (flatten to rows of tokens; `ListView.builder`); collapse/expand per fork; highlight + auto-scroll to current node; tap to jump.
7. Browse screen per [01-product-spec.md §9](../01-product-spec.md) except the Analysis toggle (P06): navigation buttons, keyboard shortcuts, swipe area, fork chooser bottom sheet (children SAN + first 60 chars of Why), comment panel, shapes from comments, free exploration branch with "Back to repertoire" chip, flip, `?node=` deep link.
8. Keyboard shortcut layer (`Shortcuts`/`Actions`) for §15 keys that exist so far (F, arrows, Home/End, Esc).

## Tests
- Board widget: renders FEN, emits move on drag and on tap-tap (simulate gestures), refuses moves when not interactive, promotion flow, rebuild count does not increase when unrelated providers change (count builds with a test-only callback).
- Comment panel states.
- Move tree view: correct nesting text for `black_caro.pgn`; tapping navigates; 5,000-line synthetic tree scrolls without building all rows (check built row count).
- Browse: navigation through forks via chooser; keyboard; free exploration and return; deep link.
- Sound service: plays mapped sounds (fake backend).

## Acceptance criteria
- Browse fully usable on phone and wide layouts.
- In a profile build on Linux, dragging pieces shows no frames over budget in the Diagnostics frame stats during a 30 s interaction script (integration test reads the stats).

## Device checklist (Eli)
- [ ] Drag and tap moves feel smooth; animations look right at your phone's refresh rate.
- [ ] Try 3 board themes and 3 piece sets; preview updates instantly.
- [ ] Sounds are crisp with no delay; haptics feel right (or turn them off).
- [ ] Browse your imported repertoire: fork chooser, comments, arrows.
- [ ] Windows: keyboard navigation in Browse, window resize keeps the board square.
