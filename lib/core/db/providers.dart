import 'package:chess_core/chess_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/settings_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/stats_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/sync_state_repository.dart';
import 'package:repertoire_trainer/core/db/stats_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:uuid/uuid.dart';

// Riverpod wiring for the persistence layer. Tests override
// [databaseProvider] with `AppDatabase.memory()` (and [clockProvider] /
// [idGeneratorProvider] for determinism).

/// The database, opened lazily on first use and closed with the scope.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Injected time source.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Injected randomness.
final rngProvider = Provider<Rng>((ref) => SystemRng());

/// Generates new ids (UUID v4).
final idGeneratorProvider = Provider<String Function()>(
  (ref) =>
      () => const Uuid().v4(),
);

/// Sync key/value state.
final syncStateRepositoryProvider = Provider<SyncStateRepository>(
  (ref) => DriftSyncStateRepository(
    ref.watch(databaseProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

/// This device's id (created on first launch).
final deviceIdProvider = FutureProvider<String>(
  (ref) => ref.watch(syncStateRepositoryProvider).deviceId(),
);

/// Settings store.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);

/// Current settings, updated live.
final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Repertoires, nodes and lines.
final repertoireRepositoryProvider = Provider<RepertoireRepository>((ref) {
  final sync = ref.watch(syncStateRepositoryProvider);
  return DriftRepertoireRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    deviceId: sync.deviceId,
  );
});

/// Runs.
final runRepositoryProvider = Provider<RunRepository>(
  (ref) => DriftRunRepository(ref.watch(databaseProvider)),
);

/// Derived stats.
final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => DriftStatsRepository(ref.watch(databaseProvider)),
);

/// Stats derivation wired to writes and to settings changes.
final statsServiceProvider = Provider<StatsService>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final service = StatsService(
    repertoires: ref.watch(repertoireRepositoryProvider),
    runs: ref.watch(runRepositoryProvider),
    stats: ref.watch(statsRepositoryProvider),
    settings: settings.load,
  )..listenToSettings(settings.watch());
  ref.onDispose(service.dispose);
  return service;
});
