import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/validate_pgn.dart' as cli;

const fixtures = 'packages/chess_core/test/fixtures';

Future<(int, String, String)> run(List<String> args) async {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = await cli.runValidatePgn(args, out: out, err: err);
  return (code, out.toString(), err.toString());
}

void main() {
  test('exit 0 and no warnings for the demo repertoire', () async {
    final (code, out, _) = await run([
      '--colour',
      'white',
      'assets/demo/italian_white.pgn',
    ]);
    expect(code, 0);
    expect(out, contains('Errors (0)'));
    expect(out, contains('Warnings (0)'));
    expect(out, startsWith('Games: 1, lines: 12'));
  });

  test('exit 1 when the report has errors', () async {
    final (code, out, _) = await run([
      '--colour=black',
      '$fixtures/illegal_move.pgn',
    ]);
    expect(code, 1);
    expect(out, contains('E-ILLEGAL'));
  });

  test('warnings alone still exit 0', () async {
    final (code, _, _) = await run([
      '--color',
      'w',
      '$fixtures/missing_comments.pgn',
    ]);
    expect(code, 0);
  });

  test('--json output parses', () async {
    final (code, out, _) = await run([
      '--json',
      '--colour',
      'b',
      '$fixtures/black_caro.pgn',
    ]);
    expect(code, 0);
    final json = jsonDecode(out) as Map<String, Object?>;
    expect((json['counts']! as Map)['lines'], 3);
  });

  test('exit 2 on usage errors', () async {
    for (final args in [
      <String>[],
      ['file.pgn'],
      ['--colour'],
      ['--colour', 'green', 'file.pgn'],
      ['--colour', 'white'],
      ['--colour', 'white', '--bogus', 'file.pgn'],
      ['--colour', 'white', 'a.pgn', 'b.pgn'],
    ]) {
      final (code, _, err) = await run(args);
      expect(code, 2, reason: '$args');
      expect(err, contains('Usage'));
    }
  });

  test('exit 2 when the file cannot be read', () async {
    final (code, _, err) = await run(['--colour', 'white', 'nope/missing.pgn']);
    expect(code, 2);
    expect(err, contains('Cannot read nope/missing.pgn'));
  });
}
