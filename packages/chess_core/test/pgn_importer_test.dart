import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Replays [line] with dartchess and checks every node's FEN and UCI.
void expectReplayMatches(Line line) {
  Position pos = Chess.initial;
  for (final node in line.path) {
    final move = pos.parseSan(node.san!)!;
    pos = pos.play(move);
    expect(node.fen, pos.fen, reason: 'FEN at ${node.san}');
  }
}

void main() {
  group('demo repertoire', () {
    late ImportResult r;
    setUpAll(() => r = importFixture('demo_italian_white.pgn'));

    test('imports with no errors and no warnings', () {
      expect(r.report.errors, isEmpty);
      expect(r.report.warnings, isEmpty);
      expect(r.tree, isNotNull);
    });

    test('counts', () {
      final rep = r.report;
      expect(rep.games, 1);
      expect(rep.lines, 12);
      expect(rep.userMoves, 44);
      expect(rep.commentedUserMoves, 44);
      expect(rep.opponentMoves, 43);
      expect(rep.maxDepth, 15);
    });

    test('line count equals leaf count and lines are leaves in preorder', () {
      final tree = r.tree!;
      final leaves = tree.nodes.where((n) => n.isLeaf && !n.isRoot).toList();
      expect(tree.lines, hasLength(leaves.length));
      expect([for (final l in tree.lines) l.leaf], leaves);
      expect([
        for (final l in tree.lines) l.ordinal,
      ], List.generate(12, (i) => i));
    });

    test('ids are preorder indices', () {
      final tree = r.tree!;
      final order = <TreeNode>[];
      void walk(TreeNode n) {
        order.add(n);
        n.children.forEach(walk);
      }

      walk(tree.root);
      expect([
        for (final n in order) n.id,
      ], List.generate(order.length, (i) => i));
      expect(tree.nodes, order);
      for (final n in tree.nodes) {
        expect(tree.node(n.id), same(n));
      }
    });

    test('FEN at every node matches a dartchess replay', () {
      r.tree!.lines.forEach(expectReplayMatches);
      expect(r.tree!.root.fen, Chess.initial.fen);
    });

    test('user moves are White moves, every one with a Why', () {
      for (final n in r.tree!.nodes.skip(1)) {
        expect(n.isUserMove, n.ply.isOdd);
        if (n.isUserMove) expect(n.comment?.why, isNotNull);
      }
    });

    test('description, labels and lookups', () {
      final tree = r.tree!;
      expect(tree.description, startsWith('A solid Italian Game repertoire'));
      expect(tree.lines.first.label, 'Italian Game: …6...O-O 7.Re1 a6 8.a4');
      expect(tree.lineByKey(tree.lines[3].key), same(tree.lines[3]));
      expect(tree.lineByKey('0000000000000000'), isNull);
      expect(tree.userSide, Side.white);
    });

    test('the asset copy is identical', () {
      expect(
        fixtureBytes('../../../../assets/demo/italian_white.pgn'),
        fixtureBytes('demo_italian_white.pgn'),
      );
    });
  });

  group('fixtures and their report codes', () {
    <String, List<String>>{
      'one_line.pgn': [],
      'multi_game_merge.pgn': ['I-MERGED'],
      'conflicting_comments.pgn': ['W-CONFLICT', 'I-MERGED'],
      'duplicate_variation.pgn': ['W-DUP-VARIATION'],
      'malformed_tags.pgn': [
        'W-MALFORMED',
        'W-MALFORMED',
        'W-DUP-TAG',
        'W-LOOSE-TEXT',
        'W-BAD-SHAPE',
        'W-BAD-SHAPE',
        'W-BAD-SHAPE',
        'W-UNKNOWN-TAG',
        'W-LONG',
      ],
      'plain_comments.pgn': ['I-PLAIN', 'I-PLAIN', 'I-ENDS-OPP'],
      'missing_comments.pgn': ['W-NO-COMMENT', 'W-NO-WHY', 'W-NO-WHY'],
      // Items follow node preorder: 2...d6 sits in the 2.Nf3 subtree.
      'comment_before_move.pgn': [
        'I-COMMENT-BEFORE-IGNORED',
        'W-COMMENT-BEFORE',
        'I-COMMENT-BEFORE-IGNORED',
      ],
      'lichess_study_export.pgn': ['I-OPP-COMMENT', 'I-NAG', 'I-MERGED'],
      'encoding_crlf_bom.pgn': [],
      'encoding_latin1.pgn': [],
      'fen_start.pgn': ['E-START'],
      'variant_chess960.pgn': ['E-START'],
      'illegal_move.pgn': [
        'E-ILLEGAL',
        'W-NO-COMMENT',
        'W-NO-COMMENT',
        'I-ENDS-OPP',
        'I-MERGED',
      ],
      'null_move.pgn': ['E-NULL', 'W-NO-COMMENT', 'I-ENDS-OPP'],
      'syntax_error.pgn': ['E-PARSE', 'I-ENDS-OPP', 'I-MERGED'],
      'empty.pgn': ['E-EMPTY'],
      'reimport_v1.pgn': [],
      'reimport_v2.pgn': [],
      'promotion_line.pgn': [],
      'castling_both.pgn': ['I-ENDS-OPP'],
    }.forEach((name, want) {
      test(name, () {
        final r = importFixture(name);
        expect(codes(r), want);
        expect(r.tree == null, r.report.hasErrors);
      });
    });

    test('black_caro.pgn as Black', () {
      final r = importFixture('black_caro.pgn', side: Side.black);
      expect(codes(r), isEmpty);
      expect(r.report.userMoves, 7);
      for (final n in r.tree!.nodes.skip(1)) {
        expect(n.isUserMove, n.ply.isEven);
      }
    });

    test('black_caro.pgn as White warns about every White move', () {
      final r = importFixture('black_caro.pgn');
      expect(codes(r).where((c) => c == 'W-NO-COMMENT'), hasLength(6));
    });
  });

  group('messages', () {
    String messageOf(String fixture, String code) =>
        importFixture(fixture).report.items
            .firstWhere((i) => i.code.id == code)
            .message;

    test('E-ILLEGAL names the move and the game path', () {
      expect(
        messageOf('illegal_move.pgn', 'E-ILLEGAL'),
        'Illegal or ambiguous move Bxc7 at '
        'Game 2: 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Bxc7??',
      );
    });

    test('E-NULL, E-PARSE, E-START', () {
      expect(
        messageOf('null_move.pgn', 'E-NULL'),
        'Null move at Game 1: 1.e4 e5 2.--',
      );
      expect(
        messageOf('syntax_error.pgn', 'E-PARSE'),
        "PGN syntax error in game 2 near 1.e4 e5 2.Nf3: unexpected '&'",
      );
      expect(
        messageOf('fen_start.pgn', 'E-START'),
        'Game 1 does not start from the initial position',
      );
    });

    test('W-CONFLICT keeps the first game', () {
      final r = importFixture('conflicting_comments.pgn');
      expect(
        r.report.warnings.single.message,
        '1.e4 e5 2.Nf3 has different comments in games 1 and 2; '
        "kept game 1's",
      );
      final nf3 = r.tree!.lines.first.path[2];
      expect(nf3.comment!.why, startsWith('First version'));
      expect(r.report.warnings.single.nodePath, ['e4', 'e5', 'Nf3']);
      expect(r.report.warnings.single.gameIndex, 1);
    });

    test('move warnings render the SAN path', () {
      expect(
        messageOf('missing_comments.pgn', 'W-NO-WHY'),
        '1.e4 e5 2.Nf3 has a comment but no [%why]',
      );
      expect(
        messageOf('malformed_tags.pgn', 'W-LONG'),
        '1.e4 e5 2.Nf3 Nc6 3.Bc4 Bc5 4.c3 Nf6 5.d3 d6 6.O-O O-O 7.Re1: '
        '[%why] is 422 characters (max 400 recommended)',
      );
    });
  });

  group('merging', () {
    test('multi-game merge keeps first-seen order and per-game labels', () {
      final r = importFixture('multi_game_merge.pgn');
      final tree = r.tree!;
      expect([for (final l in tree.lines) l.leaf.san], ['Bc4', 'Bb5', 'Nxe5']);
      expect(
        [for (final l in tree.lines) l.label],
        [
          'Italian: …1...e5 2.Nf3 Nc6 3.Bc4',
          'Spanish: …1...e5 2.Nf3 Nc6 3.Bb5',
          'Petrov Defence: …1...e5 2.Nf3 Nf6 3.Nxe5',
        ],
      );
      // Game 3 has no comment on 1.e4; game 1's is kept, no conflict.
      expect(tree.root.children.single.comment!.why, startsWith('Takes'));
      expect(r.report.games, 3);
    });

    test('same comment differing only in %clk is not a conflict', () {
      final r = importFixture('lichess_study_export.pgn');
      expect(codes(r), isNot(contains('W-CONFLICT')));
      final e4 = r.tree!.root.children.single;
      expect(e4.comment!.why, startsWith('Takes the centre'));
    });

    test('an empty comment is replaced by a later non-empty one', () {
      final r = importPgn(
        '1. e4 {} e5 *\n\n1. e4 {[%why Now with a reason.]} e5 *',
        Side.white,
      );
      expect(codes(r), ['I-ENDS-OPP', 'I-MERGED']);
      expect(r.tree!.root.children.single.comment!.why, 'Now with a reason.');
    });

    test('duplicate siblings are merged including their subtrees', () {
      final tree = importFixture('duplicate_variation.pgn').tree!;
      final nc6 = tree.lines.first.path[3];
      expect([for (final c in nc6.children) c.san], ['Bb5', 'Bc4']);
    });

    test('NAGs are stored and merged without duplicates', () {
      final r = importPgn(
        '1. e4! {[%why x]} e5 *\n\n1. e4 \$1 \$14 {[%why x]} e5 *',
        Side.white,
      );
      expect(r.tree!.root.children.single.nags, [1, 14]);
      expect(codes(r), contains('I-NAG'));
    });
  });

  group('variation-start comments', () {
    late RepertoireTree tree;
    setUpAll(() => tree = importFixture('comment_before_move.pgn').tree!);

    TreeNode child(TreeNode n, String san) =>
        n.children.firstWhere((c) => c.san == san);

    test('attached to a user move without its own comment', () {
      final e5 = child(child(tree.root, 'e4'), 'e5');
      expect(
        child(e5, 'Bc4').comment!.why,
        'The bishop goes first, keeping the f-pawn free.',
      );
    });

    test('ignored when the move has its own comment or is not a user move', () {
      final e5 = child(child(tree.root, 'e4'), 'e5');
      expect(child(e5, 'Nc3').comment!.why, 'Defends e4 and develops.');
      expect(child(child(e5, 'Nf3'), 'd6').comment, isNull);
    });
  });

  group('UCI normalization', () {
    test('castling is king two squares, both sides and directions', () {
      final tree = importFixture('castling_both.pgn').tree!;
      expect(tree.lines[0].ucis, endsWith('e1g1 e8g8'));
      expect(tree.lines[1].ucis, endsWith('e1c1 e8c8'));
      tree.lines.forEach(expectReplayMatches);
    });

    test('underpromotion is lower case', () {
      final tree = importFixture('promotion_line.pgn').tree!;
      expect(tree.lines.single.ucis, endsWith('b7a8n'));
      expect(tree.lines.single.leaf.san, 'bxa8=N');
      expectReplayMatches(tree.lines.single);
    });

    test('SAN is canonical (check marks added, glyphs removed)', () {
      final r = importPgn(
        '1. e4 {[%why a]} e5 2. Qh5!? {[%why b]} Nc6 3. Bc4 {[%why c]} Nf6 '
        '4. Qxf7 {[%why d]} *',
        Side.white,
      );
      expect(r.tree!.lines.single.leaf.san, 'Qxf7#');
    });
  });

  group('encodings', () {
    test('UTF-8 with BOM and CRLF equals Latin-1 with LF', () {
      final a = importFixture('encoding_crlf_bom.pgn').tree!;
      final b = importFixture('encoding_latin1.pgn').tree!;
      expect(a.toRows().nodes, b.toRows().nodes);
      expect(a.lines.single.label, 'Encoding: Réti: 1.e4 e5 2.Nf3');
      expect(
        a.root.children.single.comment!.why,
        'Réti would approve: the centre pawn frees the bishop.',
      );
    });

    test('decodePgnBytes and normalizePgnText', () {
      expect(decodePgnBytes([0xEF, 0xBB, 0xBF, 0x61, 0x0D, 0x0A]), 'a\n');
      expect(decodePgnBytes([0xE9]), 'é');
      expect(normalizePgnText('﻿a\r\nb\rc'), 'a\nb\nc');
    });
  });

  group('limits', () {
    test('E-SIZE above 10 MB, from text and from bytes', () {
      final big = 'x' * (maxPgnBytes + 1);
      expect(codes(importPgn(big, Side.white)), ['E-SIZE']);
      expect(
        codes(importPgnBytes(List.filled(maxPgnBytes + 1, 0x20), Side.white)),
        ['E-SIZE'],
      );
      // Multi-byte text near the limit is measured in UTF-8 bytes.
      expect(exceedsPgnSize('é' * (maxPgnBytes ~/ 2 + 1)), isTrue);
      expect(exceedsPgnSize('é' * (maxPgnBytes ~/ 2 - 1)), isFalse);
    });

    test('W-LARGE above 5,000 lines', () {
      final pgn = generateSyntheticPgn(lines: 5001, depth: 8, seed: 3);
      final r = importPgn(pgn, Side.white);
      expect(r.report.lines, 5001);
      expect(codes(r), contains('W-LARGE'));
    });

    test('W-NO-USER-MOVE for a Black line that is only 1.e4', () {
      final r = importPgn('1. e4 (1. d4 d5 {[%why Symmetry.]}) *', Side.black);
      expect(codes(r), ['W-NO-USER-MOVE']);
      expect(
        r.report.warnings.single.message,
        'Line 1.e4 contains none of your moves; it is skipped in training',
      );
    });
  });

  test('elapsed is measured', () {
    expect(importFixture('one_line.pgn').elapsed, greaterThan(Duration.zero));
  });
}
