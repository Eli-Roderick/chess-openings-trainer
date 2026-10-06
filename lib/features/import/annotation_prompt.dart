/// Prompt 1 of docs/plan/08-annotation-prompt.md ("annotate a
/// repertoire"), copied by the Create screen with the colour filled in.
/// Keep in sync with the plan (a test compares them).
library;

/// The prompt with the `<<WHITE or BLACK>>` placeholders.
const annotationPromptTemplate = '''
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
<<PASTE PGN HERE>>''';

/// The prompt for [colour] (`WHITE` or `BLACK`); the other `<<…>>`
/// placeholders are left for the user.
String annotationPrompt(String colour) =>
    annotationPromptTemplate.replaceAll('<<WHITE or BLACK>>', colour);
