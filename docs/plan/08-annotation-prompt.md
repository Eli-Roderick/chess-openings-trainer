# 08. Annotation prompts (for Eli)

Two prompts: one to annotate an uncommented PGN, one to fix problems the app's import report finds. Copy everything inside the box, replace the `<<…>>` placeholders, and attach or paste the PGN. Use the strongest model you have access to; opening knowledge quality varies a lot between models, and you should spot-check the comments of a few lines you know well.

The same text ships inside the app (Import screen → "Copy annotation prompt", phase P04) with the colour filled in.

## Prompt 1: annotate a repertoire

````text
You are a chess coach annotating an opening repertoire for a student who will drill it in a training app. The app reads your comments with a strict parser, so the output format matters as much as the chess content.

REPERTOIRE
- The student plays: <<WHITE or BLACK>>
- Opening(s): <<e.g. "Italian Game as White" or "Caro-Kann as Black">>
- Student level: <<e.g. "club player around 1500 rapid">>
- The PGN is below (or attached). It contains moves and variations but no comments.

YOUR TASK
Return the same PGN with a comment after EVERY move played by <<WHITE or BLACK>> (the student's moves), in every variation. Do not comment the opponent's moves.

HARD RULES (the parser rejects or flags violations)
1. Keep every move and every variation exactly as given: same moves, same order, same nesting. Do not add, remove, reorder or "fix" moves, even ones you disagree with. Keep all headers.
2. Every comment goes in braces immediately AFTER the student's move it explains, for example:  5. O-O {[%why ...] [%plan ...]}
3. Inside the braces use only these tags, each written as [%tag text]:
   [%why text]   REQUIRED on every student move.
   [%plan text]  optional: what the move prepares / the plan that follows.
   [%watch text] optional: the opponent's main threat, trick or typical mistake to look out for next.
   [%alt text]   optional: other reasonable moves here and why the repertoire move is preferred.
   [%cal Gc4f7,Rd8h4]  optional arrows: colour letter (G green, R red, Y yellow, B blue) + from-square + to-square, comma-separated.
   [%csl Gd5,Rf7]      optional highlighted squares: colour letter + square, comma-separated.
4. The text inside a tag must NOT contain the characters [ ] { }. Use parentheses instead. Write each tag's text on one line.
5. Keep [%why] between 60 and 300 characters. Keep the other tags under 300 characters each.
6. No engine evaluations (no "+0.4"), no emojis, no markdown inside the PGN.
7. Do not put comments on the opponent's moves and do not put comments before a move.

CONTENT RULES (this is what makes the comments useful)
A. [%why] must explain why THIS move is played in THIS position. When the move is a response to the opponent's previous move, say so explicitly and name that move, e.g. "After ...a6 the bishop is attacked; Ba4 keeps the pin on the c6-knight" or "Black's ...Bc5 eyes f2, so c3 prepares d4 to hit the bishop with tempo".
B. Be concrete: name squares, pieces, pawn breaks, weaknesses and piece routes. Avoid generic filler like "develops a piece" unless you add what it does there.
C. If a move is played for a move-order or transposition reason, explain it.
D. [%watch] should name the specific danger (a tactic, a trap, a typical mistake) and what to do about it.
E. [%alt] should name the main alternatives in that position (moves the student might be tempted to play) and the short reason they are not chosen.
F. Use [%cal]/[%csl] sparingly, only when an arrow makes the idea instantly clear (a key diagonal, a pawn break, a target square).
G. A move that appears in several variations is the same position: its comment must be identical everywhere.
H. If you are not certain about a concrete claim (a trap, a historical fact, a statistic), keep the comment general rather than inventing specifics.

LONG REPERTOIRES
If the complete output would not fit in one reply, split it into several PGN games. Each game must start from move 1 and contain a subset of the variations, with the moves exactly as in the original. Every variation of the original must appear in at least one game. Moves shared between games must carry identical comments. Output the games one after another in the same code block (or across consecutive replies when I say "continue"). The app merges the games back into one tree.

BEFORE YOU ANSWER, CHECK
- Every student move in every variation has a [%why].
- No opponent move has a comment.
- No tag text contains [ ] { }.
- Moves and variations are unchanged.

OUTPUT
Only the annotated PGN inside one ```pgn code block. No text before or after it.

PGN:
<<PASTE PGN HERE>>
````

## Prompt 2: fix issues from the import report

Use after importing (or validating) in the app: tap **Copy report** on the import report and paste it below.

````text
You annotated the chess repertoire PGN below using the [%why]/[%plan]/[%watch]/[%alt]/[%cal]/[%csl] comment format. The training app's validator reported the problems listed under REPORT. Fix ONLY those problems:
- For "has no comment" or "no [%why]": add a [%why] (and optionally other tags) to that student move, following the same rules as before (explain why the move is played, and name the opponent's previous move when the move responds to it).
- For "malformed", "text outside tags", "appears twice", "invalid arrow/square": rewrite that comment in the correct format without changing its meaning.
- For "is N characters": shorten that tag to under 300 characters.
- For "different comments in games": make the comments on that move identical in all games (keep the better one).
Do not change any moves, variations, headers or other comments. Text inside tags must not contain [ ] { }.
Output only the complete corrected PGN in one ```pgn code block.

The student plays: <<WHITE or BLACK>>

REPORT:
<<PASTE REPORT>>

PGN:
<<PASTE THE PGN YOU IMPORTED>>
````

## Tips

- Validate before importing: the app's Create screen has "Validate only", and on a PC `dart run tool/validate_pgn.dart --colour white file.pgn` does the same.
- Re-importing a corrected file keeps all training stats (lines are matched by their moves, not their comments).
