import 'dart:convert';
import 'dart:math' as math;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Chess, NormalMove, Position;
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/analysis/analysis_host.dart';
import 'package:repertoire_trainer/core/analysis/analysis_providers.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/games_repository.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/games/chess_com_client.dart';
import 'package:repertoire_trainer/features/games/chess_com_parser.dart';
import 'package:repertoire_trainer/features/games/games_screen.dart';
import 'package:repertoire_trainer/features/games/games_service.dart';
import 'package:repertoire_trainer/features/games/move_marks.dart';
import 'package:repertoire_trainer/features/games/review_model.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations_en.dart';

import '../../app_harness.dart';
import '../../core/engine/fake_engine.dart';

const _pgn =
    '[Event "Live Chess"]\n[ECO "C25"]\n'
    '[ECOUrl "https://www.chess.com/openings/Vienna-Game-2...Nf6"]\n\n'
    '1. e4 {[%clk 0:03:00]} 1... e5 {[%clk 0:02:59]} 2. Nc3 {[%clk 0:02:58]} '
    '2... Nf6 {[%clk 0:02:57]} 3. Qh5 {[%clk 0:02:56]} '
    '3... Nxh5 {[%clk 0:02:55]} 1-0';

final class _FakeHost implements AnalysisHost {
  final shown = <String>[];
  int stopped = 0;
  bool low = false;

  @override
  Future<void> show(String text) async => shown.add(text);

  @override
  Future<void> stop() async => stopped++;

  @override
  Future<bool> batteryLow() async => low;
}

Map<String, Object?> _game(
  String id, {
  int end = 1790000000,
  String white = 'Eli',
  String black = 'opp',
  String whiteResult = 'win',
  String blackResult = 'resigned',
  String rules = 'chess',
}) => {
  'url': 'https://www.chess.com/game/live/$id',
  'uuid': id,
  'pgn': _pgn,
  'time_control': '180+2',
  'end_time': end,
  'rated': true,
  'time_class': 'blitz',
  'rules': rules,
  'white': {'username': white, 'rating': 1500, 'result': whiteResult},
  'black': {'username': black, 'rating': 1480, 'result': blackResult},
};

String _month(List<Map<String, Object?>> games) => jsonEncode({'games': games});

const _base = 'https://api.chess.com/pub/player/eli/games';

/// A scripted chess.com: archives 2026/09 and 2026/10, ETags per URL.
final class _FakeChessCom {
  final requests = <http.Request>[];
  final bodies = <String, String>{
    '$_base/archives': jsonEncode({
      'archives': ['$_base/2026/09', '$_base/2026/10'],
    }),
    '$_base/2026/10': _month([
      _game('a'),
      _game(
        'b',
        end: 1790000100,
        white: 'opp',
        black: 'eli',
        whiteResult: 'agreed',
        blackResult: 'agreed',
      ),
      _game('variant', rules: 'chess960'),
      _game('other', white: 'x', black: 'y'),
    ]),
    '$_base/2026/09': _month([
      _game(
        'c',
        end: 1780000000,
        whiteResult: 'checkmated',
        blackResult: 'win',
      ),
    ]),
  };

  late final client = MockClient((r) async {
    requests.add(r);
    final body = bodies['${r.url}'];
    if (body == null) return http.Response('', 404);
    final etag = '"${body.hashCode}"';
    if (r.headers['If-None-Match'] == etag) return http.Response('', 304);
    return http.Response(body, 200, headers: {'etag': etag});
  });
}

void main() {
  group('ChessComClient', () {
    test('headers, 304, 404 and offline', () async {
      final seen = <http.BaseRequest>[];
      final client = ChessComClient(
        MockClient((r) async {
          seen.add(r);
          return switch (r.url.path) {
            '/ok' => http.Response('{}', 200, headers: {'etag': 'e1'}),
            '/same' => http.Response('', 304),
            '/gone' => http.Response('', 404),
            _ => throw http.ClientException('no network'),
          };
        }),
      );
      final ok = await client.get(Uri.parse('https://h/ok'));
      expect(ok.body, '{}');
      expect(ok.etag, 'e1');
      expect(seen.single.headers['User-Agent'], ChessComClient.userAgent);
      final same = await client.get(Uri.parse('https://h/same'), etag: 'e1');
      expect(same.notModified, isTrue);
      expect(same.etag, 'e1');
      expect(seen.last.headers['If-None-Match'], 'e1');
      await expectLater(
        client.get(Uri.parse('https://h/gone')),
        throwsA(isA<ChessComNotFound>()),
      );
      await expectLater(
        client.get(Uri.parse('https://h/down')),
        throwsA(isA<ChessComOffline>()),
      );
    });

    test('429 backs off (Retry-After, then doubling) and gives up', () async {
      final waits = <Duration>[];
      var calls = 0;
      final client = ChessComClient(
        MockClient((r) async {
          calls++;
          if (r.url.path == '/once' && calls == 2) {
            return http.Response('{}', 200);
          }
          return http.Response('', 429, headers: {'retry-after': '1'});
        }),
        delay: (d) async => waits.add(d),
      );
      expect((await client.get(Uri.parse('https://h/once'))).body, '{}');
      expect(waits, [const Duration(seconds: 1)]);
      calls = 10;
      await expectLater(
        client.get(Uri.parse('https://h/always')),
        throwsA(isA<ChessComRateLimited>()),
      );
      expect(waits, hasLength(4));
      final status = ChessComClient(
        MockClient((_) async => http.Response('', 500)),
      );
      await expectLater(
        status.get(Uri.parse('https://h/x')),
        throwsA(isA<ChessComHttpError>().having((e) => e.status, 's', 500)),
      );
    });

    test('requests run one at a time', () async {
      var active = 0;
      var maxActive = 0;
      final client = ChessComClient(
        MockClient((r) async {
          maxActive = ++active > maxActive ? active : maxActive;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          active--;
          return http.Response(r.url.path, 200);
        }),
      );
      final results = await Future.wait([
        for (var i = 0; i < 4; i++) client.get(Uri.parse('https://h/$i')),
      ]);
      expect(maxActive, 1);
      expect([for (final r in results) r.body], ['/0', '/1', '/2', '/3']);
    });
  });

  test("parseMonth keeps chess.com's own accuracies when present", () {
    final withAcc = {
      ..._game('acc'),
      'accuracies': {'white': 62.6, 'black': 51},
    };
    final rows = parseMonth((
      body: _month([withAcc, _game('none')]),
      username: 'eli',
      fetchedAt: 1,
    ));
    expect(rows[0].chessComWhiteAccuracy.value, 62.6);
    expect(rows[0].chessComBlackAccuracy.value, 51);
    expect(rows[1].chessComWhiteAccuracy.value, isNull);
  });

  test('parseArchiveList and parseMonth', () {
    expect(
      parseArchiveList(
        jsonEncode({
          'archives': ['$_base/2025/12', '$_base/2026/01', 'nonsense'],
        }),
      ),
      ['2026/01', '2025/12'],
    );
    final rows = parseMonth((
      body: _FakeChessCom().bodies['$_base/2026/10']!,
      username: 'ELI',
      fetchedAt: 5,
    ));
    expect([for (final r in rows) r.id.value], ['chesscom:a', 'chesscom:b']);
    final a = rows.first;
    expect(a.userWhite.value, isTrue);
    expect(a.result.value, 'win');
    expect(a.resultDetail.value, 'resigned');
    expect(a.ucis.value, 'e2e4 e7e5 b1c3 g8f6 d1h5 f6h5');
    expect(a.clocks.value, '1800,1790,1780,1770,1760,1750');
    expect(a.opening.value, 'Vienna Game');
    expect(rows[1].result.value, 'draw');
    expect(rows[1].userWhite.value, isFalse);
  });

  test('timeControlLabel', () {
    final l10n = AppLocalizationsEn();
    expect(timeControlLabel(l10n, '180+2'), '3+2');
    expect(timeControlLabel(l10n, '600'), '10');
    expect(timeControlLabel(l10n, '90+1'), '1.5+1');
    expect(timeControlLabel(l10n, '1/86400'), '1 day per move');
    expect(timeControlLabel(l10n, 'odd'), 'odd');
  });

  test(
    'GamesService: newest months, ETag on refresh, older on demand',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final fake = _FakeChessCom();
      final repo = GamesRepository(db);
      final service = GamesService(
        ChessComClient(fake.client),
        repo,
        FakeClock(DateTime(2026, 10, 7)),
      );
      // Only two months exist, so refresh covers both.
      expect(await service.refresh('Eli'), 3);
      expect(await service.hasOlder('eli'), isFalse);
      expect(await service.loadOlder('eli'), isNull);
      final games = await repo.watchGames('eli').first;
      expect(
        [for (final g in games) g.id],
        ['chesscom:b', 'chesscom:a', 'chesscom:c'],
      );
      expect(games.last.result, 'loss');
      fake.requests.clear();
      expect(await service.refresh('eli'), 0);
      expect(fake.requests, hasLength(3));
      expect(
        fake.requests.every((r) => r.headers['If-None-Match'] != null),
        isTrue,
      );
      // A third, older month appears.
      fake.bodies['$_base/archives'] = jsonEncode({
        'archives': ['$_base/2026/08', '$_base/2026/09', '$_base/2026/10'],
      });
      fake.bodies['$_base/2026/08'] = _month([_game('d', end: 1770000000)]);
      expect(await service.refresh('eli'), 0);
      expect(await service.hasOlder('eli'), isTrue);
      expect(await service.loadOlder('eli'), 1);
      expect(await service.hasOlder('eli'), isFalse);
    },
  );

  group('GamesScreen', () {
    Future<AppHarness> open(
      WidgetTester tester, {
      required bool online,
      _FakeChessCom? fake,
    }) async {
      final h = await AppHarness.pump(
        tester,
        overrides: [
          chessComReachableProvider.overrideWith((ref) async => online),
          chessComHttpProvider.overrideWithValue(
            (fake ?? _FakeChessCom()).client,
          ),
        ],
      );
      h.container.read(routerProvider).go(Routes.games);
      await h.settle();
      return h;
    }

    testWidgets('offline: banner, fetch disabled with the reason', (
      tester,
    ) async {
      await open(tester, online: false);
      expect(find.byKey(const Key('games-offline')), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('fetch-games')),
      );
      expect(button.onPressed, isNull);
      expect(find.text('Needs an internet connection'), findsWidgets);
    });

    testWidgets('online: a fetch lists the games and stores the name', (
      tester,
    ) async {
      final h = await open(tester, online: true);
      expect(find.byKey(const Key('games-offline')), findsNothing);
      await tester.enterText(find.byKey(const Key('chesscom-username')), 'x');
      await tester.tap(find.byKey(const Key('fetch-games')));
      await tester.pump();
      expect(find.textContaining('3 to 25'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('chesscom-username')), 'Eli');
      await tester.tap(find.byKey(const Key('fetch-games')));
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      expect(find.text('3 new games'), findsOneWidget);
      expect(find.byType(GameTile), findsNWidgets(3));
      expect(find.text('vs opp (1480)'), findsNWidgets(2));
      expect(find.textContaining('Blitz 3+2'), findsNWidgets(3));
      expect(h.container.read(settingsProvider).value!.chessComUsername, 'Eli');
    });

    testWidgets('Analyse recent games: notification, accuracy on the tile, '
        'low battery stops', (tester) async {
      final host = _FakeHost();
      final engine = FakeEngine(step: const Duration(milliseconds: 1));
      final h = await AppHarness.pump(
        tester,
        engine: engine,
        overrides: [
          chessComReachableProvider.overrideWith((ref) async => true),
          chessComHttpProvider.overrideWithValue(_FakeChessCom().client),
          analysisHostProvider.overrideWithValue(host),
          gameAnalyzerProvider.overrideWith(
            (ref) => GameAnalyzer(
              launch: () =>
                  FakeEngine(step: const Duration(milliseconds: 1))
                      .launch('sf'),
              store: ref.watch(gamesRepositoryProvider),
              workers: 1,
              clock: FakeClock(DateTime(2026, 10, 7)),
            ),
          ),
        ],
      );
      h.container.read(routerProvider).go(Routes.games);
      await h.settle();
      await tester.enterText(find.byKey(const Key('chesscom-username')), 'eli');
      await tester.tap(find.byKey(const Key('fetch-games')));
      Future<void> spin(int n) async {
        for (var i = 0; i < n; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 20));
        }
      }

      await spin(10);
      expect(find.byType(GameTile), findsNWidgets(3));
      host.low = true;
      await tester.tap(find.byKey(const Key('analyse-recent')));
      await spin(5);
      expect(find.text('Analysis stopped: battery low.'), findsOneWidget);
      expect(host.shown, isEmpty);
      host.low = false;
      await tester.tap(find.byKey(const Key('analyse-recent')));
      await spin(3);
      expect(find.byKey(const Key('batch-bar')), findsOneWidget);
      for (var i = 0; i < 300 && host.stopped < 2; i++) {
        await spin(1);
      }
      await spin(5);
      expect(host.shown, ['1 / 3', '2 / 3', '3 / 3']);
      expect(find.byKey(const Key('batch-bar')), findsNothing);
      expect(find.byKey(const ValueKey('accuracy-chesscom:a')), findsOneWidget);

      // Long-press selects, taps extend, Re-run replaces the results.
      await tester.longPress(find.byType(GameTile).first);
      await tester.pump();
      expect(find.text('1 selected'), findsOneWidget);
      await tester.tap(find.byType(GameTile).at(1));
      await tester.pump();
      expect(find.text('2 selected'), findsOneWidget);
      host.shown.clear();
      await tester.tap(find.byKey(const Key('rerun-selected')));
      await spin(3);
      expect(find.text('2 selected'), findsNothing);
      expect(find.byKey(const Key('batch-bar')), findsOneWidget);
      for (var i = 0; i < 300; i++) {
        if (find.byKey(const Key('batch-bar')).evaluate().isEmpty) break;
        await spin(1);
      }
      expect(host.shown, ['1 / 2', '2 / 2']);
      expect(find.byKey(const ValueKey('accuracy-chesscom:a')), findsOneWidget);

      // Review selected skips games that are already reviewed.
      await tester.longPress(find.byType(GameTile).first);
      await tester.pump();
      host.shown.clear();
      await tester.tap(find.byKey(const Key('review-selected')));
      await spin(5);
      expect(host.shown, isEmpty);
    });
  });

  group('review model', () {
    test('time spent from clocks and increment', () {
      final clocks = parseClocks('1800,1795,1790,1700');
      expect(secondsSpent(clocks, '180+2', 1), 2.0);
      expect(secondsSpent(clocks, '180+2', 3), 3.0);
      expect(secondsSpent(clocks, '180+2', 4), 11.5);
      expect(secondsSpent(clocks, '1/86400', 1), isNull);
      expect(secondsSpent(null, '180', 1), isNull);
      expect(secondsSpent(clocks, '180', 5), isNull);
      expect(parseClocks(''), isNull);
    });

    test('key moves, move numbers, counts', () {
      const labels = [
        MoveLabel.book,
        MoveLabel.best,
        MoveLabel.blunder,
        null,
        MoveLabel.great,
      ];
      final keys = keyPlies(labels);
      expect(keys, [3, 5]);
      expect(nextKey(keys, 0), 3);
      expect(nextKey(keys, 5), isNull);
      expect(previousKey(keys, 5), 3);
      expect(previousKey(keys, 3), isNull);
      expect(moveNumber(1), '1.');
      expect(moveNumber(4), '2...');
      expect(labelCounts(labels, white: true), {
        MoveLabel.book: 1,
        MoveLabel.blunder: 1,
        MoveLabel.great: 1,
      });
    });
  });

  group('GameReviewScreen', () {
    Future<String> location(AppHarness h) async =>
        h.container.read(routerProvider).state.uri.path;

    Future<void> spin(WidgetTester tester, int n) async {
      for (var i = 0; i < n; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 20));
      }
    }

    Future<AppHarness> open(
      WidgetTester tester, {
      bool analysed = true,
      bool board = false,
      String? repertoire,
    }) async {
      final h = await AppHarness.pump(
        tester,
        overrides: [
          gameAnalyzerProvider.overrideWith(
            (ref) => GameAnalyzer(
              launch: () =>
                  FakeEngine(step: const Duration(milliseconds: 1))
                      .launch('sf'),
              store: ref.watch(gamesRepositoryProvider),
              workers: 1,
              clock: FakeClock(DateTime(2026, 10, 7)),
            ),
          ),
        ],
      );
      if (repertoire != null) await h.create('Rep', repertoire);
      final repo = h.container.read(gamesRepositoryProvider);
      await repo.upsertGames(
        parseMonth((body: _month([_game('a')]), username: 'eli', fetchedAt: 1)),
      );
      if (!analysed) {
        h.container.read(routerProvider).go(Routes.gameReview('chesscom:a'));
        await spin(tester, 80);
        return h;
      }
      const standard = AnalysisProfile.standard;
      for (final (ply, cp, pv) in [
        (0, 20, 'e2e4'),
        (1, 20, 'g1f3'),
        (2, 20, 'b1c3'),
        (3, 20, 'g8f6'),
        (4, 30, 'g1f3 b8c6'),
        (5, -900, 'f6h5'),
        (6, -900, 'g2g3'),
      ]) {
        await repo.savePosition(
          GameAnalysisCompanion.insert(
            gameId: 'chesscom:a',
            profile: standard.index,
            ply: ply,
            cp: Value(cp),
            pv: Value(pv),
            depth: 18,
          ),
        );
      }
      final book = MoveLabel.book.index;
      await repo.completeReview(
        GameReviewsCompanion.insert(
          gameId: 'chesscom:a',
          profile: standard.index,
          engine: 'sf',
          analysed: 7,
          total: 7,
          complete: true,
          updatedAt: 1,
        ),
        [book, book, book, book, null, null],
      );
      final target = board
          ? Routes.gameBoard('chesscom:a')
          : Routes.gameReview('chesscom:a');
      h.container.read(routerProvider).go(target);
      await spin(tester, 80);
      return h;
    }

    testWidgets('summary page: graph, accuracy, label counts, rating, '
        'Continue review opens the board', (tester) async {
      final h = await open(tester);
      expect(find.byKey(const Key('summary-intro')), findsOneWidget);
      expect(find.byKey(const Key('review-progress')), findsNothing);
      expect(find.byKey(const Key('eval-graph')), findsOneWidget);
      expect(find.byKey(const Key('summary-accuracy')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('summary-rating')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('summary-rating')), findsOneWidget);
      // Eli (White): one Blunder; Black: Nf6 is the engine's move, Nxh5 too.
      String count(String label, String side) =>
          tester.widget<Text>(find.byKey(Key('summary-$label-$side'))).data!;
      expect(count('blunder', 'w'), '1');
      expect(count('blunder', 'b'), '0');
      expect(count('book', 'w'), '2');
      expect(count('book', 'b'), '2');
      expect(find.text('Brilliant'), findsOneWidget);
      await tester.tap(find.byKey(const Key('continue-review')));
      await spin(tester, 10);
      expect(await location(h), endsWith('/board'));
      expect(find.byKey(const Key('coach-card')), findsOneWidget);
    });

    testWidgets('board page: key moments, retry with hint, strip', (
      tester,
    ) async {
      final h = await open(tester, board: true);
      expect(find.text('Start position'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-next')));
      await tester.pump();
      expect(find.text('Qh5 is a blunder'), findsOneWidget);
      expect(find.text('Best was Nf3'), findsOneWidget);
      expect(find.byKey(const Key('review-eval')), findsOneWidget);
      expect(find.text('4.0 s'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-show')));
      await tester.pump();
      expect(find.textContaining('Engine line: Nf3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-best')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('nav-forward')));
      await tester.pump();
      expect(find.text('Nxh5 is the best move'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nav-back')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('retry-move')));
      await tester.pump();
      expect(find.text('Find a better move than Qh5.'), findsOneWidget);
      final board = h.container.read(activeBoardProvider)!;
      expect(board.debugPlayUserMove('a2a3'), isTrue);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Not the best move. Try again.'), findsOneWidget);
      expect(board.debugPlayUserMove('g1f3'), isTrue);
      await tester.pump();
      expect(find.text('Correct: Nf3 was best.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('retry-exit')));
      await tester.pump();
      expect(find.text('Qh5 is a blunder'), findsOneWidget);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('nav-back')));
        await tester.pump();
      }
      expect(find.text('e4 is a book move'), findsOneWidget);
      expect(find.text('Opening: Vienna Game'), findsOneWidget);
      // No key moment left after the blunder: Next goes back to the summary.
      await tester.tap(find.byKey(const Key('review-next')));
      await tester.pump();
      expect(find.text('Qh5 is a blunder'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-flip')));
      await tester.pump();
    });

    testWidgets('phone: arrows walk the whole game and back without errors', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390 * 3, 780 * 3)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await open(tester, board: true);
      final boardAt = tester.getTopLeft(find.byType(RepertoireBoard));
      final boardSize = tester.getSize(find.byType(RepertoireBoard));
      for (var i = 0; i < 8; i++) {
        for (final k in ['review-best', 'review-show']) {
          final f = find.byKey(Key(k));
          if (f.evaluate().isNotEmpty) {
            await tester.tap(f, warnIfMissed: false);
            await tester.pump();
          }
        }
        await tester.tap(find.byKey(const Key('nav-forward')));
        await tester.pump();
      }
      for (var i = 0; i < 8; i++) {
        await tester.tap(find.byKey(const Key('nav-back')));
        await tester.pump();
      }
      // The board never moves or resizes as the coach text changes.
      expect(tester.getTopLeft(find.byType(RepertoireBoard)), boardAt);
      expect(tester.getSize(find.byType(RepertoireBoard)), boardSize);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // The stepped-to move carries its label mark on the coach card, the
      // board square and its chip in the strip.
      expect(find.byType(MoveMark), findsAtLeastNWidgets(3));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone: a long game steps forward and back without errors', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390 * 3, 780 * 3)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final h = await AppHarness.pump(tester);
      final rng = math.Random(3);
      Position pos = Chess.initial;
      final ucis = <String>[];
      final sans = <String>[];
      while (ucis.length < 60) {
        final moves = [
          for (final MapEntry(key: from, value: tos) in pos.legalMoves.entries)
            for (final to in tos.squares) NormalMove(from: from, to: to),
        ];
        if (moves.isEmpty) break;
        final m = moves[rng.nextInt(moves.length)];
        final (after, san) = pos.makeSan(m);
        ucis.add(m.uci);
        sans.add(san);
        pos = after;
      }
      final repo = h.container.read(gamesRepositoryProvider);
      await repo.upsertGames([
        ImportedGamesCompanion.insert(
          id: 'g',
          username: 'eli',
          url: '',
          endTime: 0,
          timeClass: 'blitz',
          timeControl: '180+2',
          rated: true,
          userWhite: true,
          result: 'win',
          resultDetail: 'resigned',
          whiteName: 'Eli',
          blackName: 'opp',
          whiteRating: 1500,
          blackRating: 1500,
          ucis: ucis.join(' '),
          sans: sans.join(' '),
          pgn: '',
          fetchedAt: 0,
        ),
      ]);
      for (var ply = 0; ply <= ucis.length; ply++) {
        await repo.savePosition(
          GameAnalysisCompanion.insert(
            gameId: 'g',
            profile: AnalysisProfile.standard.index,
            ply: ply,
            cp: Value(rng.nextInt(600) - 300),
            pv: Value(ply < ucis.length ? ucis[ply] : ''),
            depth: 18,
          ),
        );
      }
      await repo.completeReview(
        GameReviewsCompanion.insert(
          gameId: 'g',
          profile: AnalysisProfile.standard.index,
          engine: 'sf',
          analysed: ucis.length + 1,
          total: ucis.length + 1,
          complete: true,
          updatedAt: 0,
        ),
        List<int?>.filled(ucis.length, null),
      );
      h.container.read(routerProvider).go(Routes.gameBoard('g'));
      await spin(tester, 20);
      for (var i = 0; i < ucis.length; i++) {
        await tester.tap(find.byKey(const Key('nav-forward')));
        await tester.pump();
      }
      for (var i = 0; i < ucis.length; i++) {
        await tester.tap(find.byKey(const Key('nav-back')));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrows while the analysis is still running do not throw', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390 * 3, 780 * 3)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await open(tester, analysed: false);
      await tester.tap(find.byKey(const Key('continue-review')));
      await spin(tester, 2);
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(const Key('nav-forward')));
        await spin(tester, 2);
      }
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(const Key('nav-back')));
        await spin(tester, 2);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('re-run replaces the stored review; stale scores refresh', (
      tester,
    ) async {
      final h = await open(tester);
      final repo = h.container.read(gamesRepositoryProvider);
      const standard = 1;
      // The seeded summary has no stored accuracy; opening it stores the
      // current one.
      DbGameReview? row;
      for (var i = 0; i < 100 && row?.whiteAccuracy == null; i++) {
        row = await tester.runAsync<DbGameReview?>(
          () => repo.review('chesscom:a', standard),
        );
        await spin(tester, 1);
      }
      expect(row?.whiteAccuracy, isNotNull);
      expect(find.byKey(const Key('review-progress')), findsNothing);

      await tester.tap(find.byKey(const Key('rerun-review')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('rerun-confirm')));
      await spin(tester, 2);
      // The seeded summary was written at 1; the re-run writes a new one.
      DbGameReview? again;
      for (var i = 0; i < 300; i++) {
        again = await tester.runAsync<DbGameReview?>(
          () => repo.review('chesscom:a', standard),
        );
        if ((again?.complete ?? false) && again!.updatedAt != 1) break;
        await spin(tester, 1);
      }
      expect(again?.updatedAt, isNot(1));
      await spin(tester, 3);
      expect(find.byKey(const Key('review-progress')), findsNothing);
    });

    testWidgets('opening an unanalysed game analyses it and fills in', (
      tester,
    ) async {
      final h = await open(tester, analysed: false);
      expect(find.byKey(const Key('summary-intro')), findsOneWidget);
      final repo = h.container.read(gamesRepositoryProvider);
      for (var i = 0; i < 300; i++) {
        final r = await tester.runAsync(
          () => repo.review('chesscom:a', AnalysisProfile.standard.index),
        );
        if (r?.complete ?? false) break;
        await spin(tester, 1);
      }
      await spin(tester, 3);
      expect(find.byKey(const Key('review-progress')), findsNothing);
      expect(find.textContaining('Accuracy -'), findsNothing);
    });

    testWidgets('repertoire link: you left, record, drill this line', (
      tester,
    ) async {
      final h = await open(tester, repertoire: '1. e4 e5 2. Nc3 Nf6 3. Bc4 *');
      await tester.tap(find.byKey(const Key('open-repertoire-link')));
      await spin(tester, 20);
      expect(
        find.text(
          'You left the repertoire at 3. Qh5. The repertoire plays Bc4.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Your games reaching this position: 1 W, 0 D, 0 L'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('link-add')), findsNothing);
      await tester.tap(find.byKey(const Key('link-drill')));
      await spin(tester, 10);
      expect(await location(h), endsWith('/train'));
    });

    testWidgets('repertoire link: uncovered opponent reply opens Browse', (
      tester,
    ) async {
      final h = await open(tester, repertoire: '1. e4 c5 2. Nf3 *');
      await tester.tap(find.byKey(const Key('open-repertoire-link')));
      await spin(tester, 20);
      expect(
        find.text(
          'Your opponent left the repertoire at 1... e5. Not covered yet.',
        ),
        findsOneWidget,
      );
      expect(find.text('1... e5 after 1.e4: 1 game'), findsOneWidget);
      await tester.tap(find.byKey(const Key('link-add')));
      await spin(tester, 10);
      expect(await location(h), endsWith('/browse'));
    });

    testWidgets('repertoire link without a repertoire', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const Key('open-repertoire-link')));
      await spin(tester, 10);
      expect(find.byKey(const Key('link-none')), findsOneWidget);
    });
  });
}
