import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/sync/drive_auth.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';
import 'package:repertoire_trainer/core/sync/sync_controller.dart';
import 'package:repertoire_trainer/core/sync/sync_service.dart';

/// Counts syncs; [next] decides how the next one ends.
final class _FakeSyncer implements Syncer {
  int syncs = 0;
  Exception? next;

  @override
  Future<SyncReport> sync() async {
    syncs++;
    final failure = next;
    next = null;
    if (failure != null) throw failure;
    return const SyncReport(
      downloaded: 0,
      uploaded: 0,
      merge: MergeReport(
        changedIds: {'r'},
        effects: MergeEffects(deleteRepertoires: {'gone'}),
        insertedRuns: 0,
      ),
      updatedFromOtherDevice: ['Italian'],
    );
  }

  @override
  Future<int> deleteCloudData() async => 0;
}

final class _FakeAuth implements DriveAuth {
  bool signedIn = true;
  int signIns = 0;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> restore() async => signedIn;

  @override
  Future<void> signIn() async {
    signIns++;
    signedIn = true;
  }

  @override
  Future<http.Client> client() async => http.Client();

  @override
  Future<void> refresh() async {}

  @override
  Future<void> signOut() async => signedIn = false;
}

final class _NoDrive implements DriveTransport {
  @override
  Future<String?> accountEmail() async => 'eli@example.com';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late _FakeSyncer syncer;
  late _FakeAuth auth;

  ProviderContainer container({bool enabled = true}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FakeClock(DateTime(2026, 10, 6, 12))),
        driveAuthProvider.overrideWithValue(auth),
        driveConnectorProvider.overrideWithValue(() async => _NoDrive()),
        syncServiceProvider.overrideWithValue(syncer),
      ],
    );
    addTearDown(c.dispose);
    if (enabled) {
      unawaited(
        c
            .read(syncStateRepositoryProvider)
            .set(SyncControllerKeys.enabled, '1'),
      );
    }
    return c;
  }

  setUp(() {
    db = AppDatabase.memory();
    syncer = _FakeSyncer();
    auth = _FakeAuth();
  });

  tearDown(() => db.close());

  test('start: one sync 3 s after the first frame when on', () {
    fakeAsync((async) {
      final c = container()..read(syncControllerProvider);
      async.flushMicrotasks();
      c.read(syncControllerProvider.notifier).onAppStarted();
      async.elapse(const Duration(milliseconds: 2900));
      expect(syncer.syncs, 0);
      async.elapse(const Duration(milliseconds: 200));
      expect(syncer.syncs, 1);
      async.flushMicrotasks();
      expect(c.read(syncControllerProvider).phase, SyncPhase.idle);
      expect(c.read(syncControllerProvider).account, 'eli@example.com');
    });
  });

  test('off: no sync at start, no Home icon state', () {
    fakeAsync((async) {
      final c = container(enabled: false)..read(syncControllerProvider);
      async.flushMicrotasks();
      c.read(syncControllerProvider.notifier).onAppStarted();
      async.elapse(const Duration(seconds: 10));
      expect(syncer.syncs, 0);
      expect(c.read(syncControllerProvider).enabled, isFalse);
    });
  });

  test('local changes: one sync 30 s after the last of them', () {
    fakeAsync((async) {
      final c = container()..read(syncControllerProvider);
      async.flushMicrotasks();
      final repo = c.read(repertoireRepositoryProvider);
      unawaited(
        repo.create(
          name: 'R',
          color: Side.white,
          pgn: '1. e4 *',
          result: importPgn('1. e4 *', Side.white),
        ),
      );
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 20));
      unawaited(c.read(runRepositoryProvider).markSynced(const [], 0));
      final ids = repo.allIds();
      async.flushMicrotasks();
      unawaited(ids.then((i) => repo.rename(i.single, 'Renamed')));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 29));
      expect(syncer.syncs, 0);
      async.elapse(const Duration(seconds: 2));
      expect(syncer.syncs, 1);
    });
  });

  test('a sync waits for the drill line to end', () {
    fakeAsync((async) {
      final c = container()..read(syncControllerProvider);
      async.flushMicrotasks();
      final gate = c.read(syncGateProvider)..busy = true;
      unawaited(c.read(syncControllerProvider.notifier).syncNow());
      async.flushMicrotasks();
      expect(syncer.syncs, 0);
      gate.busy = false;
      async.flushMicrotasks();
      expect(syncer.syncs, 1);
    });
  });

  test('errors map to states (06 §7); changes are announced', () {
    fakeAsync((async) {
      final c = container();
      final n = c.read(syncControllerProvider.notifier);
      async.flushMicrotasks();
      final changes = <SyncChange>[];
      n.changes.listen(changes.add);
      syncer.next = const SyncOffline('no network');
      unawaited(n.syncNow());
      async.flushMicrotasks();
      expect(c.read(syncControllerProvider).phase, SyncPhase.offline);
      syncer.next = const SyncAuthExpired('401');
      unawaited(n.syncNow());
      async.flushMicrotasks();
      expect(c.read(syncControllerProvider).phase, SyncPhase.signInNeeded);
      // Signed out: triggers do nothing until signing in again.
      unawaited(n.syncNow());
      async.flushMicrotasks();
      expect(syncer.syncs, 2);
      unawaited(n.signInAgain());
      async.flushMicrotasks();
      expect((auth.signIns, syncer.syncs), (1, 3));
      expect(c.read(syncControllerProvider).phase, SyncPhase.idle);
      expect(changes.single.updatedNames, ['Italian']);
      expect(changes.single.deletedIds, {'gone'});
    });
  });

  test('enable signs in when needed; sign out turns sync off', () {
    fakeAsync((async) {
      auth.signedIn = false;
      final c = container(enabled: false);
      final n = c.read(syncControllerProvider.notifier);
      async.flushMicrotasks();
      unawaited(n.enable());
      async.flushMicrotasks();
      expect((auth.signIns, syncer.syncs), (1, 1));
      expect(c.read(syncControllerProvider).enabled, isTrue);
      unawaited(n.signOut());
      async.flushMicrotasks();
      expect(c.read(syncControllerProvider).phase, SyncPhase.off);
      expect(auth.signedIn, isFalse);
    });
  });
}
