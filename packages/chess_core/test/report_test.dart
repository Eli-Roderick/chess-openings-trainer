import 'dart:convert';

import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('every code has a unique id matching its level', () {
    final ids = {for (final c in ReportCode.values) c.id};
    expect(ids, hasLength(ReportCode.values.length));
    for (final c in ReportCode.values) {
      final prefix = switch (c.level) {
        ReportLevel.error => 'E-',
        ReportLevel.warning => 'W-',
        ReportLevel.info => 'I-',
      };
      expect(c.id, startsWith(prefix));
    }
  });

  test('templates are exactly the spec messages', () {
    String m(ReportCode c, Map<String, Object> p) => c.format(p);
    expect(m(ReportCode.empty, {}), 'No moves found');
    expect(m(ReportCode.size, {}), 'File is larger than 10 MB');
    expect(
      m(ReportCode.keyCollision, {}),
      'Internal line-key collision; please report',
    );
    expect(
      m(ReportCode.badShape, {'move': '1.e4', 'entry': 'Xz9'}),
      "1.e4: invalid arrow/square 'Xz9' ignored",
    );
    expect(
      m(ReportCode.large, {'n': 5001}),
      '5001 lines: import and browsing will be slower',
    );
    expect(m(ReportCode.nags, {}), r'NAGs (!, ?, $n) are ignored');
    expect(
      m(ReportCode.merged, {'n': 3}),
      '3 games merged into one repertoire',
    );
    // Unknown placeholders are left in place.
    expect(m(ReportCode.empty, {'x': 1}), 'No moves found');
    expect(ReportCode.noComment.format({}), '{move} has no comment');
  });

  group('ImportReport', () {
    late ImportReport report;
    setUpAll(() => report = importFixture('illegal_move.pgn').report);

    test('level views', () {
      expect(report.hasErrors, isTrue);
      expect(report.errors.single.code, ReportCode.illegalMove);
      expect(report.warnings, hasLength(2));
      expect(report.infos, hasLength(2));
    });

    test('toPlainText lists counts, then errors, warnings and infos', () {
      expect(
        report.toPlainText(),
        'Games: 2, lines: 1, your moves: 3 (1 commented), opponent moves: 3, '
        'max depth: 6 plies\n'
        'Errors (1)\n'
        '  E-ILLEGAL Illegal or ambiguous move Bxc7 at Game 2: 1.e4 e5 2.Nf3 '
        'Nc6 3.Bb5 a6 4.Bxc7??\n'
        'Warnings (2)\n'
        '  W-NO-COMMENT 1.e4 e5 2.Nf3 has no comment\n'
        '  W-NO-COMMENT 1.e4 e5 2.Nf3 Nc6 3.Bb5 has no comment\n'
        'Info (2)\n'
        '  I-ENDS-OPP 1 lines end with an opponent move\n'
        '    1.e4 e5 2.Nf3 Nc6 3.Bb5 a6\n'
        '  I-MERGED 2 games merged into one repertoire\n',
      );
    });

    test('toJson / toJsonString', () {
      final json = jsonDecode(report.toJsonString()) as Map<String, Object?>;
      expect(json['counts'], {
        'games': 2,
        'lines': 1,
        'userMoves': 3,
        'opponentMoves': 3,
        'commentedUserMoves': 1,
        'maxDepth': 6,
        'errors': 1,
        'warnings': 2,
        'infos': 2,
      });
      final items = (json['items']! as List).cast<Map<String, Object?>>();
      expect(items.first, {
        'code': 'E-ILLEGAL',
        'level': 'error',
        'message':
            'Illegal or ambiguous move Bxc7 at Game 2: 1.e4 e5 2.Nf3 Nc6 '
            '3.Bb5 a6 4.Bxc7??',
        'nodePath': ['e4', 'e5', 'Nf3', 'Nc6', 'Bb5', 'a6'],
        'gameIndex': 1,
      });
      expect(items[3]['details'], ['1.e4 e5 2.Nf3 Nc6 3.Bb5 a6']);
      expect(items[4].containsKey('gameIndex'), isFalse);
    });

    test('ReportItem.toString', () {
      expect(ReportItem(ReportCode.empty).toString(), 'E-EMPTY No moves found');
    });
  });
}
