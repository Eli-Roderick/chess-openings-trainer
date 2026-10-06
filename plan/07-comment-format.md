# 07. Structured comment format (spec)

This is the contract between the annotating AI ([08-annotation-prompt.md](08-annotation-prompt.md)), the importer and the validator. The importer and the CLI validator (`tool/validate_pgn.dart`) implement exactly this file.

## 1. Container

A standard PGN file (UTF-8; Latin-1 accepted as a fallback when the file is not valid UTF-8; BOM stripped; CRLF or LF). One or more games. Every game must start from the standard initial position. Variations use standard PGN parentheses (RAV). Comments use standard PGN braces `{ }`.

**All games in a file are merged into one tree** by move sequence. This lets an AI split a large repertoire across several games (chapters), and it accepts lichess study exports directly.

## 2. Where comments go

- A comment explains the move **immediately before it** (standard PGN placement): `5. O-O {comment about O-O}`.
- Only moves by the repertoire's colour (the "user moves") need comments. Comments on opponent moves are kept in the file but never shown.
- A comment before the first move of the first game (`{...} 1. e4`) becomes the repertoire description.
- A comment at the start of a variation, before its first move (`( {text} 3... Nf6 ...)`), is attached to that first move if it is a user move with no comment of its own (warning `W-COMMENT-BEFORE`); otherwise ignored (info).

## 3. Comment body

Inside the braces, a sequence of **tags** separated by spaces:

```
{[%why <text>] [%plan <text>] [%watch <text>] [%alt <text>] [%cal <arrows>] [%csl <squares>]}
```

| Tag | Required | Meaning | Shown as |
|---|---|---|---|
| `%why` | yes, for user moves | Why this move is played here. If the move responds to the opponent's previous move, it must say so explicitly ("After ...a6, …", "Black's ...Bc5 eyes f2, so …"). | "Why" |
| `%plan` | optional | What this move prepares or the plan that follows. | "Plan" |
| `%watch` | optional | The opponent's main threat, trick or typical mistake to watch for in the coming moves. | "Watch out" |
| `%alt` | optional | Other moves in this position and why the repertoire move is preferred. | "Alternatives" (collapsed) |
| `%cal` | optional | Arrows, lichess syntax: comma-separated `<colour><from><to>`, colour `G` green, `R` red, `Y` yellow, `B` blue. E.g. `[%cal Gc4f7,Rd8h4]` | arrows on board |
| `%csl` | optional | Highlighted squares: comma-separated `<colour><square>`. E.g. `[%csl Gd5,Rf7]` | square highlights |

**Text rules** for `%why`, `%plan`, `%watch`, `%alt`:
- Plain text on one logical line. Newlines inside are collapsed to a single space.
- Must not contain `[`, `]`, `{`, `}` (PGN cannot contain `}` inside a comment, and `]` ends the tag). Use parentheses instead.
- Moves inside text are written in SAN with dots as usual: "after 6...Bg4, h3 asks the question". Move numbers are optional.
- Recommended length: `%why` 60-300 characters; others up to 300. Over 400 characters in one field: warning `W-LONG`.
- No engine numbers ("+0.3") and no emojis.

Other `[%...]` commands (`%eval`, `%clk`, `%emt`) are ignored silently. Any other unknown `[%name …]` tag: warning `W-UNKNOWN-TAG`, ignored.

**Plain comments:** a comment with no recognized tags is accepted and used entirely as `%why` (info `I-PLAIN`). This keeps hand-written PGNs usable.

## 4. Parsing algorithm (comment_parser.dart)

```
input: raw comment text (all comments after a move concatenated with a space, in order)
1. collapse whitespace runs to one space; trim
2. scan for tags with the regex  \[%([A-Za-z]+)\s+([^\[\]]*?)\s*\]
   - known text tags (why, plan, watch, alt): append text to that field (second occurrence → joined with " ", W-DUP-TAG)
   - cal / csl: parse shapes; invalid entries → W-BAD-SHAPE, entry skipped
   - eval, clk, emt: ignore
   - other: W-UNKNOWN-TAG
3. leftover text = input with all matched tags removed, trimmed
4. if no known text tags matched:
       if input contains "[%" → W-MALFORMED; why = input with "[%why"/"[%plan"/… markers stripped, brackets removed
       else why = leftover (I-PLAIN)
   elif leftover non-empty → W-LOOSE-TEXT; why = (why + " " + leftover).trim()
5. if user move and why empty → W-NO-WHY (if comment exists) or W-NO-COMMENT (if no comment)
```
Output: `MoveComment {why, plan, watch, alt, shapes}`; all fields nullable; empty strings normalized to null.

## 5. Tree building rules (pgn_importer.dart)

1. Parse all games with dartchess (`PgnGame.parseMultiGamePgn`). Syntax errors → `E-PARSE` with game index and the nearest move path.
2. Reject games whose `FEN`/`SetUp` headers specify a non-initial position, or whose `Variant` is not `Standard`/absent → `E-START`.
3. Walk each game's mainline and variations, playing SAN with dartchess. Illegal or ambiguous SAN → `E-ILLEGAL` with path ("Game 2: 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Bxc7??"). Null moves → `E-NULL`.
4. Insert into the merged tree keyed by UCI from each parent. Same move already present:
   - from another game: merge; if both have different non-empty comments → keep the first, `W-CONFLICT`.
   - twice among siblings in the same game: merge, `W-DUP-VARIATION`.
5. Children keep first-seen order (mainline first).
6. NAGs are stored, not shown (`I-NAG`, one aggregated info).
7. Compute `isUserMove`, FEN per node, lines (leaves in preorder), line keys ([03-data-model.md §3](03-data-model.md)), branch plies ([04-algorithms.md §6](04-algorithms.md)), labels.
8. Lines ending with an opponent move: `I-ENDS-OPP` (the final opponent move is played but nothing is graded after it). Lines containing no user move at all (e.g. a Black repertoire line that is only `1.e4`): `W-NO-USER-MOVE`; such lines are kept in the tree but never picked for training.
9. Empty tree → `E-EMPTY`. File > 10 MB → `E-SIZE`. > 5,000 lines → `W-LARGE`.

## 6. Report codes

| Code | Level | Message template |
|---|---|---|
| E-PARSE | error | "PGN syntax error in game {g} near {path}: {detail}" |
| E-START | error | "Game {g} does not start from the initial position" |
| E-ILLEGAL | error | "Illegal or ambiguous move {san} at {path}" |
| E-NULL | error | "Null move at {path}" |
| E-EMPTY | error | "No moves found" |
| E-SIZE | error | "File is larger than 10 MB" |
| E-KEY-COLLISION | error | "Internal line-key collision; please report" |
| W-NO-COMMENT | warning | "{move} has no comment" (user moves only) |
| W-NO-WHY | warning | "{move} has a comment but no [%why]" |
| W-MALFORMED | warning | "{move}: comment tags are malformed; shown as plain text" |
| W-DUP-TAG | warning | "{move}: [%{tag}] appears twice; texts joined" |
| W-LOOSE-TEXT | warning | "{move}: text outside tags added to Why" |
| W-LONG | warning | "{move}: [%{tag}] is {n} characters (max 400 recommended)" |
| W-UNKNOWN-TAG | warning | "{move}: unknown tag [%{tag}] ignored" |
| W-BAD-SHAPE | warning | "{move}: invalid arrow/square '{entry}' ignored" |
| W-CONFLICT | warning | "{move} has different comments in games {a} and {b}; kept game {a}'s" |
| W-DUP-VARIATION | warning | "{move} appears twice as a variation; merged" |
| W-COMMENT-BEFORE | warning | "{move}: comment placed before the move; attached to it" |
| W-NO-USER-MOVE | warning | "Line {path} contains none of your moves; it is skipped in training" |
| W-LARGE | warning | "{n} lines: import and browsing will be slower" |
| I-PLAIN | info | "{move}: plain comment used as Why" |
| I-OPP-COMMENT | info | "{n} comments on opponent moves are kept but not shown" (aggregated) |
| I-ENDS-OPP | info | "{n} lines end with an opponent move" (aggregated, expandable) |
| I-NAG | info | "NAGs (!, ?, $n) are ignored" (aggregated) |
| I-MERGED | info | "{n} games merged into one repertoire" |

`{move}` renders as the SAN path to the move ("1.e4 e5 2.Nf3 Nc6 3.Bb5"). The report has `toPlainText()` (used by "Copy report" and the CLI) and is JSON-serializable (CLI `--json`).

## 7. CLI validator

```
dart run tool/validate_pgn.dart --colour white|black [--json] file.pgn
exit code 0 = no errors (warnings allowed), 1 = errors, 2 = usage/file error
```
Prints counts, then errors, warnings and infos in the same format as the app. Lets Eli (or the annotating AI, if it can run code) check output before importing.

## 8. Example (White repertoire)

```pgn
[Event "Italian Game repertoire"]
[ChapterName "Italian: Giuoco Piano"]

{A quiet Italian setup with c3 and d3/d4. Aim: easy development and a slow kingside attack.}
1. e4 {[%why Takes the centre with a pawn and frees the f1-bishop and the queen.] [%plan Follow up with Nf3 and Bc4, then castle quickly.]}
1... e5
2. Nf3 {[%why Black's ...e5 claimed the centre; Nf3 develops while attacking that pawn, so Black must spend a move defending it.] [%watch Once e5 is defended by ...Nc6 or ...d6, Nxe5 is no longer free.]}
2... Nc6
3. Bc4 {[%why With ...Nc6 Black defended e5, so White develops the bishop to its best diagonal, aiming at f7, the square only Black's king protects.] [%plan Castle, then prepare d4 with c3.] [%cal Gc4f7]}
3... Bc5
(3... Nf6 4. d3 {[%why Black's ...Nf6 attacks e4; d3 calmly defends it and opens the c1-bishop, avoiding the sharp lines after 4.Ng5.] [%plan Castle, then c3 and Re1 to prepare d4 later.]})
4. c3 {[%why Black's ...Bc5 points at f2; c3 prepares d4, which would hit the bishop and gain central space with tempo.] [%plan Play d4 or d3 next, castle, and build with Re1 and Nbd2.] [%alt 4.O-O is also normal; 4.b4, the Evans Gambit, is sharper but not part of this repertoire.] [%csl Gd4]}
*
```
This tree has 2 lines; every White move has `%why`; Black moves have no comments. The demo repertoire in `assets/demo/` follows this format and is the reference fixture for tests.
