import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:test/test.dart';

import 'helpers.dart';

/// Node rows without the raw comment (export re-serializes comments).
List<NodeRow> comparable(RepertoireTree t) => [
  for (final r in t.toRows().nodes)
    NodeRow(
      nodeId: r.nodeId,
      parentId: r.parentId,
      ply: r.ply,
      san: r.san,
      uci: r.uci,
      fen: r.fen,
      isUserMove: r.isUserMove,
      childIndex: r.childIndex,
      why: r.why,
      plan: r.plan,
      watch: r.watch,
      alt: r.alt,
      shapes: r.shapes,
      nags: r.nags,
    ),
];

void main() {
  const validFixtures = {
    'demo_italian_white.pgn': Side.white,
    'one_line.pgn': Side.white,
    'black_caro.pgn': Side.black,
    'multi_game_merge.pgn': Side.white,
    'conflicting_comments.pgn': Side.white,
    'duplicate_variation.pgn': Side.white,
    'malformed_tags.pgn': Side.white,
    'plain_comments.pgn': Side.white,
    'missing_comments.pgn': Side.white,
    'comment_before_move.pgn': Side.white,
    'lichess_study_export.pgn': Side.white,
    'encoding_crlf_bom.pgn': Side.white,
    'encoding_latin1.pgn': Side.white,
    'reimport_v1.pgn': Side.white,
    'reimport_v2.pgn': Side.white,
    'promotion_line.pgn': Side.white,
    'castling_both.pgn': Side.white,
  };

  group('round trip importPgn(exportPgn(tree))', () {
    validFixtures.forEach((name, side) {
      test(name, () {
        final tree = importFixture(name, side: side).tree!;
        final exported = exportPgn(tree, headers: {'Event': 'Round trip'});
        final again = importPgn(exported, side);
        expect(again.report.errors, isEmpty, reason: exported);
        final back = again.tree!;
        expect(comparable(back), comparable(tree));
        expect(
          [for (final l in back.lines) l.key],
          [for (final l in tree.lines) l.key],
        );
        expect(
          [for (final l in back.lines) l.branchPly],
          [for (final l in tree.lines) l.branchPly],
        );
        expect(back.description, tree.description);
      });
    });
  });

  test('export format', () {
    final tree = importPgn(
      r'{Intro} 1. e4 {[%csl Rf7] [%why A] [%cal Gc4f7]} $1 e5 '
      '(1... c5 2. Nf3 {[%why B]}) 2. Nf3 {[%why C]} *',
      Side.white,
    ).tree!;
    expect(
      exportPgn(tree, headers: {'Event': r'Say "hi" \ bye'}),
      '[Event "Say \\"hi\\" \\\\ bye"]\n'
      '\n'
      r'{Intro} 1. e4 $1 {[%why A] [%cal Gc4f7] [%csl Rf7]} 1... e5 '
      '(1... c5 2. Nf3\n'
      '{[%why B]}) 2. Nf3 {[%why C]} *\n',
    );
  });

  test('without headers or description', () {
    final tree = importPgn('1. e4 e5 *', Side.white).tree!;
    expect(exportPgn(tree), '1. e4 e5 *\n');
  });

  test('long movetext wraps between tokens', () {
    final text = exportPgn(importFixture('demo_italian_white.pgn').tree!);
    for (final line in text.split('\n')) {
      if (!line.contains('{')) expect(line.length, lessThanOrEqualTo(79));
    }
  });
}
