import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/features/board/move_tree_view.dart';

String rowText(MoveRow r) => [
  '  ' * r.depth,
  [
    for (final i in r.items)
      switch (i) {
        MoveItem() => i.text,
        ForkToggle() => i.collapsed ? '[+${i.variations}]' : '[-]',
      },
  ].join(' '),
].join();

void main() {
  final caro = importPgn(
    File('packages/chess_core/test/fixtures/black_caro.pgn').readAsStringSync(),
    Side.black,
  ).tree!;

  test('nesting text for black_caro.pgn', () {
    expect(
      [for (final r in MoveRows.build(caro.root).rows) rowText(r)],
      [
        '1.e4 c6 2.d4 d5 3.e5 [-]',
        '  3.Nc3 dxe4 4.Nxe4 Bf5',
        '3...Bf5 [-]',
        '  3...c5',
        '4.Nf3 e6',
      ],
    );
  });

  test('collapsed forks hide their variations', () {
    final d5 = caro
        .root
        .children
        .single
        .children
        .single
        .children
        .single
        .children
        .single;
    final rows = MoveRows.build(caro.root, collapsed: {d5.id});
    expect(
      [for (final r in rows.rows) rowText(r)],
      ['1.e4 c6 2.d4 d5 3.e5 [+1] 3...Bf5 [-]', '  3...c5', '4.Nf3 e6'],
    );
    final nc3 = d5.children[1];
    expect(rows.rowOf(nc3.id), isNull);
    expect(rows.rowOf(d5.children.first.id), 0);
  });

  Future<List<TreeNode>> pumpView(
    WidgetTester tester,
    TreeNode root,
    int current,
  ) async {
    final tapped = <TreeNode>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoveTreeView(
            root: root,
            current: current,
            onSelect: tapped.add,
          ),
        ),
      ),
    );
    await tester.pump();
    return tapped;
  }

  testWidgets('tapping a move selects it; forks toggle', (tester) async {
    final tapped = await pumpView(tester, caro.root, 0);
    await tester.tap(find.text('3.Nc3'));
    expect(tapped.single.san, 'Nc3');
    final d5 = tapped.single.parent!;
    await tester.tap(find.byKey(ValueKey('fork-${d5.id}')));
    await tester.pump();
    expect(find.text('3.Nc3'), findsNothing);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('5,000-line tree: only visible rows are built; current is '
      'scrolled into view', (tester) async {
    final big = importPgn(
      generateSyntheticPgn(lines: 5000, depth: 16, seed: 3),
      Side.white,
    ).tree!;
    final rows = MoveRows.build(big.root);
    expect(rows.rows.length, greaterThan(4000));
    final built = <int>{};
    MoveTreeView.debugOnRowBuild = built.add;
    addTearDown(() => MoveTreeView.debugOnRowBuild = null);
    final deep = big.lines[4000].path.last;
    await pumpView(tester, big.root, deep.id);
    await tester.pumpAndSettle();
    expect(built.length, lessThan(200));
    expect(find.byKey(ValueKey('move-${deep.id}')), findsOneWidget);
    final view = tester.getRect(find.byType(MoveTreeView));
    final chip = tester.getRect(find.byKey(ValueKey('move-${deep.id}')));
    expect(view.contains(chip.center), isTrue);
  });
}
