// Cold start budget (docs/plan/phases/P04): Home shows data < 1 s after
// main() with 10 repertoires in the database, on a release build. Flutter
// Driver cannot run desktop release builds, so CI runs it AOT-compiled in
// profile mode (decision D-61) with
// `xvfb-run flutter drive --profile -d linux
//   --driver=test_driver/integration_test.dart
//   --target=integration_test/cold_start_test.dart`;
// under `flutter test` (debug, JIT) only a loose bound is checked.
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/sync_state_repository.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start with 10 repertoires shows Home data in < 1 s', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('rt_cold_');
    final dbFile = File(p.join(dir.path, 'repertoire.sqlite'));
    final seed = AppDatabase(NativeDatabase(dbFile));
    var next = 0;
    final repo = DriftRepertoireRepository(
      seed,
      clock: const SystemClock(),
      newId: () => 'id-${next++}',
      deviceId: DriftSyncStateRepository(seed, newId: () => 'dev').deviceId,
    );
    final pgn = generateSyntheticPgn(lines: 12, depth: 12, seed: 1);
    final result = importPgn(pgn, Side.white);
    for (var i = 0; i < 10; i++) {
      await repo.create(
        name: 'Repertoire $i',
        color: Side.white,
        pgn: pgn,
        result: result,
      );
    }
    await seed.close();

    await bootstrap(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.createInBackground(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    final card = find.text('Repertoire 9');
    final watch = Stopwatch()..start();
    while (card.evaluate().isEmpty && watch.elapsed.inSeconds < 30) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    final t = StartupTimings.instance;
    final total = t.mainToHomeData;
    // The timing log the acceptance criterion asks for.
    // ignore: avoid_print
    print(
      'Cold start (${kDebugMode ? 'debug' : 'AOT'}): '
      'main -> runApp ${t.mainToRunApp?.inMilliseconds} ms, '
      'first frame +${t.runAppToFirstFrame?.inMilliseconds} ms, '
      'Home data +${t.firstFrameToHomeData?.inMilliseconds} ms, '
      'total ${total?.inMilliseconds} ms',
    );
    expect(total, isNotNull);
    expect(
      total,
      lessThan(
        kDebugMode ? const Duration(seconds: 5) : const Duration(seconds: 1),
      ),
    );
  });
}
