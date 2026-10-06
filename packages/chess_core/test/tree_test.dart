import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:test/test.dart';

import 'helpers.dart';

Line lineEndingWith(RepertoireTree t, String ucisSuffix) =>
    t.lines.firstWhere((l) => l.ucis.endsWith(ucisSuffix));

void main() {
  group('line keys', () {
    test('key is the first 16 hex chars of SHA-256 of the UCI string', () {
      // Values computed independently with Python's hashlib.
      expect(lineKey('e2e4 e7e5 g1f3 b8c6 f1b5'), '09cd8a667eb787f7');
      expect(
        importFixture('one_line.pgn').tree!.lines.single.key,
        '09cd8a667eb787f7',
      );
    });

    test('stable for the same moves with different comments', () {
      final a = importPgn(
        '1. e4 {[%why A]} e5 2. Nf3 {[%why B]} *',
        Side.white,
      );
      final b = importPgn('1. e4 {Other} e5 2. Nf3 *', Side.white);
      expect(a.tree!.lines.single.key, b.tree!.lines.single.key);
    });

    test('different for different moves', () {
      final a = importPgn('1. e4 e5 2. Nf3 *', Side.white);
      final b = importPgn('1. e4 e5 2. Nc3 *', Side.white);
      expect(a.tree!.lines.single.key, isNot(b.tree!.lines.single.key));
    });

    test('normalizeUci', () {
      expect(normalizeUci('E1H1', isCastling: true), 'e1g1');
      expect(normalizeUci('e1a1', isCastling: true), 'e1c1');
      expect(normalizeUci('e8h8', isCastling: true), 'e8g8');
      expect(normalizeUci('e8a8', isCastling: true), 'e8c8');
      expect(normalizeUci('e1g1', isCastling: true), 'e1g1');
      expect(normalizeUci('e1h1', isCastling: false), 'e1h1');
      expect(normalizeUci('b7a8N', isCastling: false), 'b7a8n');
    });
  });

  group('branch point (04-algorithms §6)', () {
    test('no forks: 0', () {
      final t = importFixture('one_line.pgn').tree!;
      expect(t.lines.single.branchPly, 0);
      expect(branchPly(const []), 0);
    });

    test('root fork: 0', () {
      final t = importFixture('castling_both.pgn').tree!;
      expect([for (final l in t.lines) l.branchPly], [0, 0]);
    });

    test('deepest fork followed only by an opponent leaf falls back', () {
      final t = importPgn(
        '1. e4 e5 (1... c5 2. Nf3) 2. Nf3 Nc6 (2... d6) *',
        Side.white,
      ).tree!;
      // Fork after 2.Nf3 (ply 3) has only opponent moves after it.
      expect(lineEndingWith(t, 'b8c6').branchPly, 1);
      expect(lineEndingWith(t, 'd7d6').branchPly, 1);
      expect(lineEndingWith(t, 'c7c5 g1f3').branchPly, 1);
    });

    test('user-side fork (two accepted moves)', () {
      final t = importFixture('black_caro.pgn', side: Side.black).tree!;
      expect(lineEndingWith(t, 'c8f5 g1f3 e7e6').branchPly, 5);
      expect(lineEndingWith(t, 'c6c5').branchPly, 5);
      expect(lineEndingWith(t, 'c3e4 c8f5').branchPly, 4);
    });

    test('demo lines', () {
      final t = importFixture('demo_italian_white.pgn').tree!;
      expect(
        [for (final l in t.lines) l.branchPly],
        [
          9, 9, 9, 11, 11, 7, 7, 7, 7, 5, 5, 3, //
        ],
      );
    });
  });

  group('SAN paths and labels', () {
    test('formatSanMoves from White and from Black', () {
      expect(formatSanMoves(['e4', 'e5', 'Nf3', 'Nc6']), '1.e4 e5 2.Nf3 Nc6');
      expect(formatSanMoves(['Bc5', 'c3'], firstPly: 6), '3...Bc5 4.c3');
      expect(formatSanMoves([]), '');
    });

    test('sanPath of nodes', () {
      final t = importFixture('one_line.pgn').tree!;
      final path = t.lines.single.path;
      expect(sanPath(path), '1.e4 e5 2.Nf3 Nc6 3.Bb5');
      expect(sanPath(path.sublist(1, 3)), '1...e5 2.Nf3');
      expect(sanPath(const []), '');
    });

    test('labels: prefix choice and 4-ply tail', () {
      final path = importFixture('one_line.pgn').tree!.lines.single.path;
      expect(lineLabel(path), '…1...e5 2.Nf3 Nc6 3.Bb5');
      expect(
        lineLabel(path.sublist(0, 4), prefix: 'X'),
        'X: 1.e4 e5 2.Nf3 Nc6',
      );
      expect(lineLabel(path.sublist(0, 2), prefix: ''), '1.e4 e5');
      expect(
        labelPrefix({'ChapterName': 'C', 'Opening': 'O', 'Event': 'E'}),
        'C',
      );
      expect(labelPrefix({'Opening': 'O', 'Event': 'E'}), 'O');
      expect(labelPrefix({'Event': 'E'}), 'E');
      expect(labelPrefix({'Event': '?'}), isNull);
      expect(labelPrefix({'ChapterName': ' ', 'Event': ''}), isNull);
      expect(labelPrefix({}), isNull);
    });

    test('a game without a usable header has no prefix', () {
      final t = importPgn('[Event "?"]\n1. e4 e5 *', Side.white).tree!;
      expect(t.lines.single.label, '1.e4 e5');
    });
  });

  group('TreeNode and Line', () {
    test('accessors', () {
      final t = importFixture('one_line.pgn').tree!;
      final line = t.lines.single;
      expect(line.plies, 5);
      expect(line.userMoveCount, 3);
      expect(line.leaf.isLeaf, isTrue);
      expect(line.leaf.path, line.path);
      expect(t.root.isRoot, isTrue);
      expect(t.root.path, isEmpty);
      expect(t.root.childIndex, 0);
      expect(t.root.toString(), 'TreeNode(0, ply 0, root)');
      expect(line.leaf.toString(), 'TreeNode(5, ply 5, Bb5)');
      expect(line.toString(), contains(line.key));
      expect(() => t.root.children.add(t.root), throwsUnsupportedError);
    });
  });

  group('rows', () {
    final valid = [
      'demo_italian_white.pgn',
      'black_caro.pgn',
      'lichess_study_export.pgn',
      'malformed_tags.pgn',
      'castling_both.pgn',
      'promotion_line.pgn',
    ];
    for (final name in valid) {
      test('fromRows(toRows(tree)) is identical: $name', () {
        final side = name.startsWith('black') ? Side.black : Side.white;
        final tree = importFixture(name, side: side).tree!;
        final rows = tree.toRows();
        final back = RepertoireTree.fromRows(
          rows,
          userSide: side,
          description: tree.description,
        );
        expect(back.toRows().nodes, rows.nodes);
        expect(back.toRows().lines, rows.lines);
        expect(back.description, tree.description);
        expect(back.userSide, side);
        for (var i = 0; i < tree.nodes.length; i++) {
          expect(back.nodes[i].comment, tree.nodes[i].comment);
        }
      });
    }

    test('row columns: shapes JSON and NAG text', () {
      final rows = importFixture('lichess_study_export.pgn').tree!.toRows();
      final bc4 = rows.nodes.firstWhere((r) => r.san == 'Bc4');
      expect(
        bc4.shapesJson,
        '[{"t":"arrow","from":"c4","to":"f7","c":"G"},'
        '{"t":"circle","sq":"f7","c":"R"}]',
      );
      expect(NodeRow.shapesFromJson(bc4.shapesJson), bc4.shapes);
      expect(bc4.nagsText, '1');
      expect(NodeRow.nagsFromText(bc4.nagsText), [1]);
      expect(rows.nodes.first.shapesJson, isNull);
      expect(rows.nodes.first.nagsText, isNull);
      expect(NodeRow.shapesFromJson(null), isEmpty);
      expect(NodeRow.nagsFromText(''), isEmpty);
      expect(rows.nodes.first.parentId, isNull);
      expect(bc4.toString(), contains('Bc4'));
      expect(rows.lines.first.toString(), contains(rows.lines.first.lineKey));
      expect(
        bc4.hashCode,
        rows.nodes.firstWhere((r) => r.san == 'Bc4').hashCode,
      );
      expect(rows.lines.first.hashCode, rows.lines.first.hashCode);
    });

    test('fromRows rejects rows that are not a preorder tree', () {
      NodeRow row(int id, int? parent, {int childIndex = 0}) => NodeRow(
        nodeId: id,
        parentId: parent,
        ply: id,
        san: id == 0 ? null : 'e4',
        uci: id == 0 ? null : 'e2e4',
        fen: 'x',
        isUserMove: false,
        childIndex: childIndex,
      );
      RepertoireTree build(List<NodeRow> nodes) => RepertoireTree.fromRows(
        RepertoireRows(nodes: nodes, lines: const []),
        userSide: Side.white,
      );
      expect(() => build([]), throwsFormatException);
      expect(() => build([row(1, null)]), throwsFormatException);
      expect(() => build([row(0, null), row(1, null)]), throwsFormatException);
      expect(() => build([row(0, 0)]), throwsFormatException);
      expect(
        () => build([row(0, null), row(1, 0, childIndex: 1)]),
        throwsFormatException,
      );
      expect(build([row(0, null), row(1, 0)]).nodes, hasLength(2));
    });
  });
}
