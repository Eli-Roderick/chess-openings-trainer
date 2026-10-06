import 'package:chess_core/chess_core.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/settings_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/stats_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/sync_state_repository.dart';
import 'package:repertoire_trainer/core/db/stats_service.dart';

/// Everything wired to one in-memory database, deterministic ids and time.
final class TestDb {
  new({void Function(String)? debugHook, int isolateThreshold = 2000})
    : db = AppDatabase.memory(),
      clock = FakeClock(DateTime.utc(2026, 10, 6, 12)) {
    sync = DriftSyncStateRepository(db, newId: nextId);
    settings = DriftSettingsRepository(db);
    repertoires = DriftRepertoireRepository(
      db,
      clock: clock,
      newId: nextId,
      deviceId: sync.deviceId,
      debugHook: debugHook,
    );
    runs = DriftRunRepository(db);
    stats = DriftStatsRepository(db);
    service = StatsService(
      repertoires: repertoires,
      runs: runs,
      stats: stats,
      settings: settings.load,
      isolateThreshold: isolateThreshold,
    );
  }

  final AppDatabase db;
  final FakeClock clock;
  late final DriftSyncStateRepository sync;
  late final DriftSettingsRepository settings;
  late final DriftRepertoireRepository repertoires;
  late final DriftRunRepository runs;
  late final DriftStatsRepository stats;
  late final StatsService service;
  var _id = 0;

  /// Sequential ids: id-1, id-2, ...
  String nextId() => 'id-${++_id}';

  Future<void> close() async {
    await service.dispose();
    await db.close();
  }
}
