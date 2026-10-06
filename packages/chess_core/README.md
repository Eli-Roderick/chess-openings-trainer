# chess_core

Pure Dart package of Repertoire Trainer: no Flutter, no `dart:io`. See `docs/plan/02-architecture.md`.

## PGN import (P01)

```dart
import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;

final result = importPgnBytes(bytes, Side.white); // or importPgn(text, side)
print(result.report.toPlainText());               // counts, errors, warnings, infos
final tree = result.tree;                         // null when the report has errors
for (final line in tree!.lines) {
  print('${line.label}  key=${line.key}  branchPly=${line.branchPly}');
}
final rows = tree.toRows();                       // nodes/lines table rows
final again = RepertoireTree.fromRows(rows, userSide: Side.white);
```

- `pgn/`: strict PGN reader, structured comment parser (`docs/plan/07-comment-format.md`), importer and report, exporter, encodings, synthetic PGN generator.
- `tree/`: `TreeNode`, `RepertoireTree`, `Line`, line keys, branch points, SAN paths and labels, database rows.

## Training logic (P02)

- `util/`: `Clock` and `Rng` (inject them; no `DateTime.now()`/`Random()` elsewhere).
- `training/`: run models (`RunRecord`, `MoveGrade`, `DeviationEvent`; freezed + JSON in the sync shape), grading (`PlyGradeBuilder`, `RunBuilder`), attribution (`LineIndex`), accuracy, weak pool, SRS (replay and session picker), Random/Weak/branch-switch pickers, streak, `deriveRepertoire`/`deriveLines`, re-import diff, engine-judgement maths, constants.

Code generation: `dart run build_runner build -d` in this package (generated files are committed).

Tests: `dart test` (fixtures in `test/fixtures/`). Coverage: `dart test --coverage=coverage`, then from the repo root `dart run tool/check_coverage.dart --package packages/chess_core --min 90 lib`.
