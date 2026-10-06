import 'dart:async';

import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/play/play_on_screen.dart';
import 'package:repertoire_trainer/features/settings/settings_screen.dart';

import '../app_harness.dart';
import '../run_fixtures.dart';

/// P13 task 6: every screen at text scale 1.3 on a 360x640 phone, with
/// data, renders without an overflow or other exception.
const _pgn = '''
[Event "A repertoire with a long event name to wrap on small phones"]
1. e4 {The most popular first move.} e5 2. Nf3 Nc6 (2... d6 3. d4) 3. Bb5 a6
(3... Nf6 4. O-O) 4. Ba4 *''';

const _start = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

Future<void> _pumpData(AppHarness h, [int rounds = 15]) async {
  for (var i = 0; i < rounds; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await h.tester.pump(const Duration(milliseconds: 50));
  }
}

Future<AppHarness> _phone(WidgetTester tester) => AppHarness.pump(
  tester,
  size: const Size(360, 640),
  textScale: 1.3,
  overrides: [playOnEngineProvider.overrideWithValue((_) async => null)],
);

/// A repertoire with one recorded run; returns its id and a line key.
Future<(String, String)> _data(AppHarness h) async {
  final id = await h.create(
    'A rather long repertoire name for a small phone screen',
    _pgn,
  );
  final refs = (await h.tester.runAsync(
    () => h.container.read(repertoireRepositoryProvider).lineRefs(id),
  ))!;
  final line = refs.first;
  var done = false;
  unawaited(
    h.container
        .read(statsServiceProvider)
        .recordRun(
          fixtureRun(
            id,
            id: 'r1',
            key: line.key,
            ucis: line.ucis,
            day: '2026-10-05',
            credits: [1, 0, 1],
            at: 1,
          ),
        )
        .whenComplete(() => done = true),
  );
  for (var i = 0; i < 200 && !done; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
    await h.tester.pump();
  }
  return (id, line.key);
}

Future<void> _expectClean(
  WidgetTester tester,
  AppHarness h,
  String location, {
  Object? extra,
}) async {
  final router = h.container.read(routerProvider);
  if (extra == null) {
    router.go(location);
  } else {
    router.go(Routes.home);
    await _pumpData(h, 3);
    unawaited(router.push(location, extra: extra));
  }
  await _pumpData(h);
  expect(tester.takeException(), isNull, reason: location);
}

void main() {
  final screens = <String, String Function(String id, String line)>{
    'Repertoire detail': (id, _) => Routes.repertoire(id),
    'Browse': (id, _) => Routes.browse(id),
    'Browse with analysis': (id, _) => Routes.browse(id, analyse: true),
    'Drill': (id, _) => Routes.train(id, mode: 'random'),
    'Stats': (id, _) => Routes.stats(id),
    'Line list': (id, _) => Routes.lineList(id),
    'Line detail': Routes.lineStats,
    'Re-import': (id, _) => Routes.reimport(id),
    'Validate': (id, _) => Routes.validate(id),
    'Settings': (_, _) => Routes.settings,
    for (final s in SettingsSection.values)
      'Settings ${s.name}': (_, _) => Routes.settingsSection(s.name),
    'Diagnostics': (_, _) => Routes.diagnostics,
  };
  for (final MapEntry(key: name, value: location) in screens.entries) {
    testWidgets(name, (tester) async {
      final h = await _phone(tester);
      final (id, line) = await _data(h);
      await _expectClean(tester, h, location(id, line));
    });
  }

  testWidgets('Play on', (tester) async {
    final h = await _phone(tester);
    final (id, _) = await _data(h);
    await _expectClean(
      tester,
      h,
      Routes.playEngine,
      extra: PlayOnArgs(
        repertoireId: id,
        nodeId: 0,
        nodeFen: _start,
        userSide: Side.white,
        orientation: Side.white,
      ),
    );
  });
}
