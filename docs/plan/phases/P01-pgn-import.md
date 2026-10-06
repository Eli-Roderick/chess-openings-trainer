# P01. chess_core: PGN import, comments, validation, lines

**Depends on:** P00.
**Read first:** [07-comment-format.md](../07-comment-format.md) (all), [03-data-model.md §3, §4, §6](../03-data-model.md), [04-algorithms.md §6](../04-algorithms.md), [10-testing-and-quality.md §2](../10-testing-and-quality.md).

## Goal
Pure-Dart importer that turns PGN text + colour into a validated `RepertoireTree` with lines, keys, labels, branch plies and an `ImportReport`, plus the CLI validator and an import benchmark.

## Tasks
1. `tree/`: `TreeNode`, `RepertoireTree`, `Line` per [03-data-model.md §6](../03-data-model.md). `RepertoireTree.fromRows` (used later by the app) and `toRows` (flat list for DB, preorder ids).
2. `tree/line_key.dart`: UCI normalisation (castling as king two squares, lower-case promotion), key = first 16 hex of SHA-256.
3. `tree/branch_point.dart` per [04-algorithms.md §6](../04-algorithms.md).
4. `tree/san_path.dart`: render a node path as "1.e4 e5 2.Nf3 Nc6" (with "3...Bc5" style when starting on Black), and line labels per [03-data-model.md §4](../03-data-model.md).
5. `pgn/comment_parser.dart` per [07-comment-format.md §4](../07-comment-format.md), including `%cal`/`%csl` shape parsing into `BoardShape` value objects.
6. `pgn/pgn_importer.dart` per [07-comment-format.md §5](../07-comment-format.md): decoding (UTF-8, BOM, Latin-1 fallback, CRLF), multi-game parse with dartchess, start-position checks, merge, comment attachment (incl. variation-start comments), NAGs kept, report building. Entry point:
   `ImportResult importPgn(String text, Side userSide)` → `{RepertoireTree? tree, ImportReport report, Duration elapsed}`; `tree` is null when the report has errors.
7. `pgn/report.dart`: `ImportReport` with `List<ReportItem>` (code, level, message, nodePath (List<String> SAN), gameIndex), aggregate counts (games, lines, user moves, opponent moves, commented user moves, max depth), `toPlainText()`, `toJson()`. Message templates exactly as in [07-comment-format.md §6](../07-comment-format.md).
8. `pgn/pgn_exporter.dart`: export a tree to PGN (single game, mainline + variations, comments re-serialized in canonical tag order `why plan watch alt cal csl`). Used for round-trip tests and possible future "normalize" export; the app's Export PGN uses the stored original text.
9. `tool/validate_pgn.dart` CLI per [07-comment-format.md §7](../07-comment-format.md).
10. `tool/gen_synthetic_pgn.dart` (lines, depth, seed; produces legal random-but-plausible trees using dartchess legal moves, every user move with a short tagged comment) and `tool/bench_import.dart`.
11. All fixtures from [10-testing-and-quality.md §2](../10-testing-and-quality.md); write `demo_italian_white.pgn` (≈12 lines, a real Italian Game repertoire for White, every White move commented following [07-comment-format.md](../07-comment-format.md) and the content rules in [08-annotation-prompt.md](../08-annotation-prompt.md); moves must be sound mainstream theory). Copy it to `assets/demo/italian_white.pgn`.

## Tests (minimum)
- Comment parser: every rule and warning code in §4/§6 of the spec, one test each; shapes valid/invalid; whitespace collapse; plain text; tags + loose text.
- Importer: every fixture with its expected report codes and counts; line count = leaf count; preorder ids; FEN at nodes matches dartchess replay; UCI normalisation for castling and promotion; multi-game merge order; conflict keeps first; variation-start comment attachment; E-START for FEN and Variant; encoding fixtures; 10 MB limit.
- Line keys stable for the same moves with different comments; differ for different moves.
- Branch point: cases listed in [04-algorithms.md §6](../04-algorithms.md).
- Exporter round trip: `importPgn(exportPgn(tree))` yields identical nodes, comments and keys for all valid fixtures.
- `fromRows(toRows(tree))` identical.
- Benchmark test: 1,000 lines depth 16 imports < 1.0 s on CI (skip with `@Tags(['bench'])` locally if needed, run in CI).
- CLI: exit codes 0/1/2; `--json` parses.

## Acceptance criteria
- All above tests green; `chess_core` coverage ≥ 90 % for `pgn/` and `tree/`.
- `dart run tool/validate_pgn.dart --colour white assets/demo/italian_white.pgn` prints 0 errors, 0 warnings.
- No Flutter imports in `chess_core`.

## Out of scope
Database, UI, training logic.
