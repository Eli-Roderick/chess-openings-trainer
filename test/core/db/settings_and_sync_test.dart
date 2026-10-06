import 'package:chess_core/chess_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/settings_repository.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

import 'db_test_helpers.dart';

void main() {
  late TestDb t;
  setUp(() => t = TestDb());
  tearDown(() => t.close());

  group('settings', () {
    test('defaults (01-product-spec §10)', () async {
      final s = await t.settings.load();
      expect(s, const AppSettings());
      expect(s.wrongMoveMode, WrongMoveMode.retry);
      expect(s.autoAdvanceDelayMs, 1500);
      expect(s.opponentMoveDelayMs, 250);
      expect(s.deviationsEnabled, isFalse);
      expect(s.deviationChancePercent, 25);
      expect(s.deviationTiming, DeviationTiming.endOfLine);
      expect(s.weakEnterBelow, 0.8);
      expect(s.weakExitCleanRuns, 3);
      expect(s.srsNewPerDay, 10);
      expect(s.srsMaxReviewsPerDay, isNull);
      expect(s.dayStartHour, 4);
      expect(s.boardTheme, 'brown');
      expect(s.pieceSet, 'cburnett');
      expect(s.animationSpeed.ms, 200);
      expect(s.soundVolumePercent, 80);
      expect(s.comparableThresholdCp, 30);
      expect(s.checkSearchMs, 1000);
      expect(s.playOnElo, 2500);
      expect(s.themeMode, AppThemeMode.dark);
      expect(s.deriveSettings.weakEnterBelow, 0.8);
    });

    test('updates persist only changed keys and survive reopening', () async {
      await t.settings.update(
        (s) =>
            s.copyWith(dayStartHour: 2, srsMaxReviewsPerDay: 50, playOnElo: 0),
      );
      final rows = await t.db.select(t.db.settings).get();
      expect(
        {for (final r in rows) r.key},
        {'dayStartHour', 'srsMaxReviewsPerDay', 'playOnElo'},
      );
      final again = DriftSettingsRepository(t.db);
      final s = await again.load();
      expect(s.dayStartHour, 2);
      expect(s.srsMaxReviewsPerDay, 50);
      expect(s.playOnElo, 0);
      await t.settings.update((s) => s.copyWith(srsMaxReviewsPerDay: null));
      expect((await again.load()).srsMaxReviewsPerDay, isNull);
    });

    test('values are clamped to their ranges and steps', () async {
      final s = await t.settings.update(
        (s) => s.copyWith(
          autoAdvanceDelayMs: 1700,
          opponentMoveDelayMs: 9999,
          weakEnterBelowPercent: 12,
          weakExitCleanRuns: 0,
          srsNewPerDay: 500,
          srsMaxReviewsPerDay: 3,
          dayStartHour: 9,
          deviationChancePercent: 33,
          soundVolumePercent: -5,
          comparableThresholdCp: 5,
          checkSearchMs: 10000,
        ),
      );
      expect(s.autoAdvanceDelayMs, 1500);
      expect(s.opponentMoveDelayMs, 1500);
      expect(s.weakEnterBelowPercent, 50);
      expect(s.weakExitCleanRuns, 1);
      expect(s.srsNewPerDay, 100);
      expect(s.srsMaxReviewsPerDay, 10);
      expect(s.dayStartHour, 6);
      expect(s.deviationChancePercent, 35);
      expect(s.soundVolumePercent, 0);
      expect(s.comparableThresholdCp, 10);
      expect(s.checkSearchMs, 3000);
    });

    test('unparseable stored values fall back to defaults', () {
      final s = DriftSettingsRepository.fromRows(const [
        DbSetting(key: 'themeMode', value: '"neon"'),
        DbSetting(key: 'dayStartHour', value: 'not json'),
        DbSetting(key: 'srsNewPerDay', value: '"many"'),
        DbSetting(key: 'removedSetting', value: '1'),
        DbSetting(key: 'pieceSet', value: '"alpha"'),
      ]);
      expect(s.themeMode, AppThemeMode.dark);
      expect(s.dayStartHour, 4);
      expect(s.srsNewPerDay, 10);
      expect(s.pieceSet, 'alpha');
    });

    test('watch emits on change', () async {
      final values = <int>[];
      final sub = t.settings.watch().listen((s) => values.add(s.dayStartHour));
      await pumpEventQueue();
      await t.settings.update((s) => s.copyWith(dayStartHour: 0));
      await pumpEventQueue();
      await sub.cancel();
      expect(values, [4, 0]);
    });
  });

  group('sync state and device id', () {
    test('device id is created once and kept', () async {
      final id = await t.sync.deviceId();
      expect(id, startsWith('id-'));
      expect(await t.sync.deviceId(), id);
      expect(await t.sync.get('deviceId'), id);
    });

    test('get, set, remove, watch', () async {
      expect(await t.sync.get('k'), isNull);
      final seen = <String?>[];
      final sub = t.sync.watch('k').listen(seen.add);
      await pumpEventQueue();
      await t.sync.set('k', 'v1');
      await pumpEventQueue();
      await t.sync.set('k', 'v2');
      await pumpEventQueue();
      await t.sync.remove('k');
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [null, 'v1', 'v2', null]);
    });
  });
}
