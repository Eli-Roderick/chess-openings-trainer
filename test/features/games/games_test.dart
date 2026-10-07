import 'dart:convert';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
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
import 'package:repertoire_trainer/features/games/chess_com_client.dart';
import 'package:repertoire_trainer/features/games/chess_com_parser.dart';
import 'package:repertoire_trainer/features/games/games_screen.dart';
import 'package:repertoire_trainer/features/games/games_service.dart';
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
    });
  });
}
