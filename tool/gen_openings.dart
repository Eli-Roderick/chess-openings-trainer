// Builds assets/openings/openings.tsv from lichess-org/chess-openings
// (CC0): `dart run tool/gen_openings.dart <dir with a.tsv..e.tsv>`.
// Output lines: ECO, name, UCI moves (space-separated).
import 'dart:io';

import 'package:chess_core/chess_core.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tool/gen_openings.dart <dir>');
    exit(64);
  }
  final out = StringBuffer();
  var count = 0;
  for (final f in ['a', 'b', 'c', 'd', 'e']) {
    final lines = File('${args.first}/$f.tsv').readAsLinesSync().skip(1);
    for (final line in lines) {
      final cols = line.split('\t');
      if (cols.length < 3) continue;
      final game = parsePlayedGame(cols[2]);
      if (game == null || game.ucis.isEmpty) {
        stderr.writeln('skipped: $line');
        continue;
      }
      out.writeln('${cols[0]}\t${cols[1]}\t${game.ucis.join(' ')}');
      count++;
    }
  }
  File('assets/openings/openings.tsv')
    ..createSync(recursive: true)
    ..writeAsStringSync(out.toString());
  stdout.writeln('$count openings');
}
