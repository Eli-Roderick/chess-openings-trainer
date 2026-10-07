# Third-party components

Repertoire Trainer is licensed under the GNU General Public License v3.0 or later (see `LICENSE`). It includes or links the following third-party components. Dart/Flutter package dependencies and their licences are listed in `docs/DEPENDENCIES.md`.

| Component | Where | Licence | Source |
|---|---|---|---|
| Stockfish sf_18 | Bundled engine binary (`libstockfish.so` on Android, `engine/stockfish-*.exe` on Windows) | GPL-3.0 | https://github.com/official-stockfish/Stockfish/tree/sf_18 |
| dartchess | Chess rules, SAN, PGN | GPL-3.0 | https://github.com/lichess-org/dartchess |
| chessground | Board widget, board themes and the piece sets it ships | GPL-3.0 (piece sets: see the chessground repository for each set's licence) | https://github.com/lichess-org/flutter-chessground |
| Inter font 4.1 | UI font, bundled in `assets/fonts/` (licence text `Inter-LICENSE.txt`) | SIL Open Font License 1.1 | https://github.com/rsms/inter |
| DejaVu Sans | The knight glyph (U+265E) in the app icon and Android splash (`assets/icon/*.png`, rendered images; the font itself is not bundled) | Bitstream Vera Fonts licence; DejaVu changes public domain | https://dejavu-fonts.github.io/License.html |
| lichess opening table | `assets/openings/openings.tsv` (names and moves of 3,865 openings, converted by `tool/gen_openings.dart`): book moves and opening names in Game Review | CC0-1.0 | https://github.com/lichess-org/chess-openings |
| Sounds | `assets/sounds/*.ogg`: lichess "standard" set (`Move`, `Capture`, `Error`, `Confirmation` as line complete, `GenericNotify` as deviation, `Select` as hint), unmodified | AGPL-3.0-or-later (lila's default licence; not among lila's exceptions). Combined with this GPL-3.0 app under GPL-3.0 §13 | https://github.com/lichess-org/lila/tree/master/public/sound/standard |
| Piece sets | Every set chessground ships is bundled (the package declares them as assets); licences as listed in lila's `COPYING.md` | See below | https://github.com/lichess-org/lila/blob/master/COPYING.md |

Piece set licences (from lila's `COPYING.md`, which chessground's sets come from):

| Licence | Sets |
|---|---|
| GPL-2.0-or-later | cburnett, merida |
| GPL-3.0-or-later | mpchess |
| Apache-2.0 | chessnut |
| MIT | fantasy, spatial, celtic |
| CC0-1.0 | rhosgfx |
| CC BY 4.0 | firi, kiwen-suwi |
| CC BY-SA 4.0 | shapes |
| CC BY-NC-SA 4.0 (non-commercial) | california, caliente, maestro, fresca, cardinal, icpieces, gioco, tatiana, staunty, dubrovny, anarcandy, disguised, cooke, monarchy, horsey |
| CC BY-NC-SA 2.5 (non-commercial) | xkcd |
| AGPL-3.0-or-later (lila default) | pirouetti, pixel, letter, and the sets lila does not list (alpha, chess7, companion, governor, kosal, leipzig, reillycraig, riohacha, symmetric, totoy) |

The non-commercial sets restrict commercial redistribution of the app as a whole; the app is free and non-commercial.

Stockfish's source for the exact pinned version is linked above and from every GitHub release of this app.
