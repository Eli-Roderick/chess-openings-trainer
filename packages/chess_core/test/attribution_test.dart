import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  const a = LineRef(key: 'A', ucis: 'e2e4 e7e5 g1f3');
  const b = LineRef(key: 'B', ucis: 'e2e4 e7e5 f1c4', ordinal: 1);
  const c = LineRef(key: 'C', ucis: 'e2e4 c7c5', ordinal: 2);

  group('attribute (03-data-model §5)', () {
    final index = LineIndex([a, b, c]);
    Attribution att(String ucis, [String key = 'old']) =>
        index.attribute(ucis: ucis, lineKey: key);

    test('exact match is direct', () {
      expect(att('e2e4 c7c5', 'C'), const DirectAttribution('C'));
    });

    test('extension to one line inherits', () {
      expect(
        att('e2e4 c7c5'.split(' ').first),
        InheritedAttribution(const ['A', 'B', 'C']),
      );
      final one = LineIndex([a, c]);
      expect(
        one.attribute(ucis: 'e2e4 e7e5', lineKey: 'old'),
        InheritedAttribution(const ['A']),
      );
    });

    test('extension to three lines inherits all, in ordinal order', () {
      final index3 = LineIndex([
        const LineRef(key: 'Z', ucis: 'e2e4 e7e5 d2d4', ordinal: 2),
        a.copyWithOrdinal(0),
        b.copyWithOrdinal(1),
      ]);
      expect(
        index3.attribute(ucis: 'e2e4 e7e5', lineKey: 'old'),
        InheritedAttribution(const ['A', 'B', 'Z']),
      );
    });

    test('a shortened or changed line is archived under its key', () {
      expect(
        att('e2e4 e7e5 g1f3 b8c6', 'longer'),
        const ArchivedAttribution('longer'),
      );
      expect(att('d2d4', 'other'), const ArchivedAttribution('other'));
    });

    test('a line that comes back is direct again', () {
      final without = LineIndex([b, c]);
      expect(
        without.attribute(ucis: a.ucis, lineKey: 'A'),
        const ArchivedAttribution('A'),
      );
      expect(
        LineIndex([a, b, c]).attribute(ucis: a.ucis, lineKey: 'A'),
        const DirectAttribution('A'),
      );
    });

    test('an empty index archives everything', () {
      expect(
        LineIndex(const []).attribute(ucis: 'e2e4', lineKey: 'k'),
        const ArchivedAttribution('k'),
      );
    });

    test('value semantics', () {
      expect(
        InheritedAttribution(const ['A']),
        InheritedAttribution(const ['A']),
      );
      expect(
        InheritedAttribution(const ['A']).hashCode,
        InheritedAttribution(const ['A']).hashCode,
      );
      expect(
        InheritedAttribution(const ['A']),
        isNot(InheritedAttribution(const ['B'])),
      );
      expect(const DirectAttribution('A').hashCode, 'A'.hashCode);
      expect(const ArchivedAttribution('A').hashCode, 'A'.hashCode);
      expect(const DirectAttribution('A').toString(), 'Direct(A)');
      expect(InheritedAttribution(const ['A']).toString(), 'Inherited([A])');
      expect(const ArchivedAttribution('A').toString(), 'Archived(A)');
      expect(a, const LineRef(key: 'A', ucis: 'e2e4 e7e5 g1f3'));
      expect(
        a.hashCode,
        const LineRef(key: 'A', ucis: 'e2e4 e7e5 g1f3').hashCode,
      );
      expect(a.toString(), contains('A'));
      expect(
        const LineRef(key: 'x', ucis: '', userMoveCount: 0).isTrainable,
        isFalse,
      );
    });
  });

  test('linesThrough finds the lines through a node (branch switch §3.4)', () {
    final index = LineIndex([a, b, c]);
    expect(index.linesThrough('e2e4 e7e5'), ['A', 'B']);
    expect(index.linesThrough('e2e4 e7e5 f1c4'), ['B']);
    expect(index.linesThrough(''), ['A', 'B', 'C']);
    expect(index.linesThrough('d2d4'), isEmpty);
  });

  test('works on the re-import fixtures', () {
    LineRef ref(Line l) =>
        LineRef(key: l.key, ucis: l.ucis, ordinal: l.ordinal);
    final v1 = importFixture('reimport_v1.pgn').tree!.lines.map(ref).toList();
    final v2 = LineIndex(importFixture('reimport_v2.pgn').tree!.lines.map(ref));
    final results = [
      for (final l in v1) v2.attribute(ucis: l.ucis, lineKey: l.key),
    ];
    expect(results[0], isA<DirectAttribution>());
    expect(results[1], isA<InheritedAttribution>());
    expect(results[2], isA<ArchivedAttribution>());
  });
}

extension on LineRef {
  LineRef copyWithOrdinal(int ordinal) =>
      LineRef(key: key, ucis: ucis, ordinal: ordinal);
}
