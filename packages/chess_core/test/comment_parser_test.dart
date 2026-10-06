import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Square;
import 'package:test/test.dart';

List<ReportCode> issueCodes(ParsedComment p) => [
  for (final i in p.issues) i.code,
];

ParsedComment user(String? raw) => parseComment(raw, isUserMove: true);

void main() {
  group('tags', () {
    test('all text tags and shapes', () {
      final p = user(
        '[%why W.] [%plan P.] [%watch X.] [%alt A.] '
        '[%cal Gc4f7,Rd8h4] [%csl Gd5,Rf7]',
      );
      expect(p.issues, isEmpty);
      expect(
        p.comment,
        MoveComment(
          why: 'W.',
          plan: 'P.',
          watch: 'X.',
          alt: 'A.',
          shapes: const [
            ArrowShape(ShapeColor.green, Square.c4, Square.f7),
            ArrowShape(ShapeColor.red, Square.d8, Square.h4),
            CircleShape(ShapeColor.green, Square.d5),
            CircleShape(ShapeColor.red, Square.f7),
          ],
        ),
      );
    });

    test('whitespace and newlines collapse to one space', () {
      final p = user('  [%why  Two\n  lines\tof   text ]  ');
      expect(p.comment!.why, 'Two lines of text');
      expect(p.issues, isEmpty);
    });

    test('tag names are case-insensitive', () {
      expect(user('[%Why Upper.]').comment!.why, 'Upper.');
    });

    test('arrows come before squares whatever the input order', () {
      final p = user('[%why x] [%csl Bd5] [%cal Ye2e4]');
      expect(p.comment!.shapes, [
        const ArrowShape(ShapeColor.yellow, Square.e2, Square.e4),
        const CircleShape(ShapeColor.blue, Square.d5),
      ]);
    });

    test('eval, clk and emt are ignored silently', () {
      final p = user('[%why x] [%eval 0.3,20] [%clk 0:05:00] [%emt 0:00:03]');
      expect(p.issues, isEmpty);
      expect(p.comment, MoveComment(why: 'x'));
    });
  });

  group('warnings', () {
    test('W-DUP-TAG joins the texts', () {
      final p = user('[%why one.] [%plan p] [%why two.]');
      expect(issueCodes(p), [ReportCode.duplicateTag]);
      expect(p.issues.single.params, {'tag': 'why'});
      expect(p.comment!.why, 'one. two.');
    });

    test('W-UNKNOWN-TAG', () {
      final p = user('[%why x] [%foo bar]');
      expect(issueCodes(p), [ReportCode.unknownTag]);
      expect(p.issues.single.params, {'tag': 'foo'});
      expect(p.comment, MoveComment(why: 'x'));
    });

    test('W-BAD-SHAPE per invalid entry, valid entries kept', () {
      final p = user('[%why x] [%cal Gc4f7,Xz9z9,Gc4,Ge4e4] [%csl Rz1,Gd5,Q]');
      expect(issueCodes(p), List.filled(5, ReportCode.badShape));
      expect(
        [for (final i in p.issues) i.params['entry']],
        ['Xz9z9', 'Gc4', 'Ge4e4', 'Rz1', 'Q'],
      );
      expect(p.comment!.shapes, [
        const ArrowShape(ShapeColor.green, Square.c4, Square.f7),
        const CircleShape(ShapeColor.green, Square.d5),
      ]);
    });

    test('W-LOOSE-TEXT appends to Why', () {
      final p = user('[%why Tagged.] and loose');
      expect(issueCodes(p), [ReportCode.looseText]);
      expect(p.comment!.why, 'Tagged. and loose');
    });

    test('loose text with brackets is sanitized', () {
      expect(user('[%why a] see [1]').comment!.why, 'a see (1)');
    });

    test('W-MALFORMED for an unclosed tag', () {
      final p = user('[%why unclosed tag text');
      expect(issueCodes(p), [ReportCode.malformed]);
      expect(p.comment!.why, 'unclosed tag text');
    });

    test('W-MALFORMED for brackets inside tag text', () {
      final p = user('[%why the [c-file] matters]');
      expect(issueCodes(p), [ReportCode.malformed]);
      expect(p.comment!.why, 'the c-file matters');
    });

    test('W-MALFORMED keeps well-formed tags and appends the rest', () {
      final p = user('[%why ok.] [%plan broken');
      expect(issueCodes(p), [ReportCode.malformed]);
      expect(p.comment!.why, 'ok. broken');
    });

    test('W-LONG over 400 characters, with tag and length', () {
      final p = user('[%why ok] [%alt ${'a' * 401}]');
      expect(issueCodes(p), [ReportCode.long]);
      expect(p.issues.single.params, {'tag': 'alt', 'n': 401});
      expect(user('[%why ${'a' * 400}]').issues, isEmpty);
    });

    test('W-NO-COMMENT for a user move without comment', () {
      final p = user(null);
      expect(issueCodes(p), [ReportCode.noComment]);
      expect(p.comment, isNull);
    });

    test('W-NO-WHY for an empty comment', () {
      expect(issueCodes(user('')), [ReportCode.noWhy]);
      expect(issueCodes(user('   ')), [ReportCode.noWhy]);
    });

    test('W-NO-WHY for tags without why', () {
      final p = user('[%plan p] [%cal Gc4f7]');
      expect(issueCodes(p), [ReportCode.noWhy]);
      expect(p.comment!.plan, 'p');
    });

    test('a comment holding only clk is not malformed (D-37)', () {
      final p = user('[%clk 0:05:00]');
      expect(issueCodes(p), [ReportCode.noWhy]);
      expect(p.comment, isNull);
    });

    test('opponent moves get no W-NO-* warnings', () {
      expect(parseComment(null, isUserMove: false).issues, isEmpty);
      expect(parseComment('[%plan p]', isUserMove: false).issues, isEmpty);
    });
  });

  group('plain text', () {
    test('I-PLAIN uses the whole text as Why', () {
      final p = user('Best by test.');
      expect(issueCodes(p), [ReportCode.plain]);
      expect(p.comment, MoveComment(why: 'Best by test.'));
    });

    test('plain text next to shapes is still plain', () {
      final p = user('[%cal Gc4f7] Strong bishop.');
      expect(issueCodes(p), [ReportCode.plain]);
      expect(p.comment!.why, 'Strong bishop.');
      expect(p.comment!.shapes, hasLength(1));
    });
  });

  group('formatComment', () {
    test('canonical order and bracket replacement', () {
      final c = MoveComment(
        alt: 'A [x]',
        why: 'W',
        watch: 'X',
        plan: 'P',
        shapes: const [
          CircleShape(ShapeColor.red, Square.f7),
          ArrowShape(ShapeColor.green, Square.c4, Square.f7),
        ],
      );
      expect(
        formatComment(c),
        '[%why W] [%plan P] [%watch X] [%alt A (x)] [%cal Gc4f7] [%csl Rf7]',
      );
      expect(user(formatComment(c)).comment!.alt, 'A (x)');
    });
  });

  group('value objects', () {
    test('MoveComment normalizes blanks and compares by value', () {
      expect(MoveComment(why: ' ', plan: '').isEmpty, isTrue);
      expect(MoveComment(why: 'a'), MoveComment(why: 'a'));
      expect(MoveComment(why: 'a').hashCode, MoveComment(why: 'a').hashCode);
      expect(MoveComment(why: 'a'), isNot(MoveComment(why: 'b')));
      expect(MoveComment(why: 'a').toString(), contains('why: a'));
    });

    test('BoardShape JSON round trip and equality', () {
      final shapes = <BoardShape>[
        const ArrowShape(ShapeColor.blue, Square.e2, Square.e4),
        const CircleShape(ShapeColor.yellow, Square.d5),
      ];
      for (final s in shapes) {
        expect(BoardShape.fromJson(s.toJson()), s);
        expect(BoardShape.fromJson(s.toJson()).hashCode, s.hashCode);
      }
      expect(shapes.first.toJson(), {
        't': 'arrow',
        'from': 'e2',
        'to': 'e4',
        'c': 'B',
      });
      expect(shapes.last.toJson(), {'t': 'circle', 'sq': 'd5', 'c': 'Y'});
      expect(shapes.first.toString(), 'ArrowShape(Be2e4)');
      expect(shapes.last.toString(), 'CircleShape(Yd5)');
      expect(
        () => BoardShape.fromJson(const {'t': 'blob', 'c': 'G'}),
        throwsFormatException,
      );
      expect(ShapeColor.fromCode('g'), ShapeColor.green);
      expect(ShapeColor.fromCode('x'), isNull);
    });

    test('CommentIssue equality', () {
      expect(
        const CommentIssue(ReportCode.long, {'tag': 'why', 'n': 401}),
        const CommentIssue(ReportCode.long, {'tag': 'why', 'n': 401}),
      );
      expect(
        const CommentIssue(ReportCode.long, {'tag': 'why'}).hashCode,
        const CommentIssue(ReportCode.long, {'tag': 'why'}).hashCode,
      );
      expect(
        const CommentIssue(ReportCode.long, {'tag': 'why'}),
        isNot(const CommentIssue(ReportCode.long, {'tag': 'alt'})),
      );
      expect(const CommentIssue(ReportCode.plain).toString(), contains('I-'));
    });
  });
}
