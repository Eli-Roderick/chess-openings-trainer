import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/sync/drive_auth.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';
import 'package:repertoire_trainer/core/sync/sync_service.dart';

final _log = Logger('SyncController');

/// Where sync stands, for Settings and the Home icon (06 §6, §7).
enum SyncPhase {
  /// This build has no OAuth ids.
  notConfigured,

  /// Sync is off.
  off,

  /// Waiting for the next trigger.
  idle,

  /// Running.
  syncing,

  /// The last sync failed: no network ("Offline, will retry").
  offline,

  /// The token is gone: "Sign in again".
  signInNeeded,

  /// The last sync failed otherwise.
  error,
}

/// Sync status.
@immutable
final class SyncStatus {
  /// Creates it.
  const new({
    required this.phase,
    this.account,
    this.lastSyncAt,
    this.message,
    this.warnings = const [],
  });

  /// Phase.
  final SyncPhase phase;

  /// Signed-in account e-mail, if known.
  final String? account;

  /// Last successful sync (UTC ms).
  final int? lastSyncAt;

  /// Details of the last failure.
  final String? message;

  /// Files the last sync skipped.
  final List<SyncWarning> warnings;

  /// Sync is on.
  bool get enabled =>
      phase != SyncPhase.off && phase != SyncPhase.notConfigured;

  /// A copy with the given fields replaced.
  SyncStatus copyWith({
    SyncPhase? phase,
    String? account,
    int? lastSyncAt,
    String? message,
    bool clearMessage = false,
    List<SyncWarning>? warnings,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    account: account ?? this.account,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    message: clearMessage ? null : message ?? this.message,
    warnings: warnings ?? this.warnings,
  );
}

/// What a finished sync changed, for open screens (P12 task 4) and the
/// "updated from another device" SnackBar.
@immutable
final class SyncChange {
  /// Creates it.
  const new({
    required this.changedIds,
    required this.deletedIds,
    required this.updatedNames,
  });

  /// Repertoires whose record changed.
  final Set<String> changedIds;

  /// Repertoires deleted by another device.
  final Set<String> deletedIds;

  /// Names of repertoires another device changed.
  final List<String> updatedNames;
}

/// Holds sync back while a drill line is in progress (06 §6): DB writes
/// and re-derivation wait for the line to end.
final class SyncGate extends ValueNotifier<bool> {
  /// Open by default.
  new() : super(false);

  /// A line is in progress.
  bool get busy => value;

  set busy(bool b) => value = b;
}

/// The app's gate.
final syncGateProvider = Provider<SyncGate>((ref) {
  final gate = SyncGate();
  ref.onDispose(gate.dispose);
  return gate;
});

/// The OAuth ids of this build; tests override.
final oauthConfigProvider = Provider<OAuthConfig>(
  (ref) => OAuthConfig.fromEnvironment,
);

/// Sign-in for this platform.
final driveAuthProvider = Provider<DriveAuth>((ref) {
  final config = ref.watch(oauthConfigProvider);
  if (Platform.isAndroid && config.android) {
    return AndroidDriveAuth(config: config, backend: GoogleSignInBackend());
  }
  if ((Platform.isWindows || Platform.isLinux) && config.desktop) {
    return DesktopDriveAuth(config: config);
  }
  return const UnconfiguredDriveAuth();
});

/// Connects to Drive with the signed-in account; tests override.
final driveConnectorProvider = Provider<Future<DriveTransport> Function()>((
  ref,
) {
  final auth = ref.watch(driveAuthProvider);
  return () async => GoogleDriveTransport(await auth.client());
});

/// The sync algorithm on the app's database.
final syncServiceProvider = Provider<Syncer>((ref) {
  final state = ref.watch(syncStateRepositoryProvider);
  return SyncService(
    connect: ref.watch(driveConnectorProvider),
    refreshAuth: ref.watch(driveAuthProvider).refresh,
    applier: ref.watch(mergeApplierProvider),
    repertoires: ref.watch(repertoireRepositoryProvider),
    runs: ref.watch(runRepositoryProvider),
    state: state,
    deviceId: state.deviceId,
    clock: ref.watch(clockProvider),
    deviceName: Platform.isAndroid ? 'Android' : Platform.operatingSystem,
  );
});

/// `sync_state` keys of the controller.
abstract final class SyncControllerKeys {
  /// "1" when sync is on.
  static const enabled = 'sync.enabled';

  /// Last successful sync (UTC ms).
  static const lastSyncAt = 'sync.lastSyncAt';
}

/// Sync triggers and status (06 §6): 3 s after start, when the app goes
/// to the background or closes, 30 s after a local change, and on demand;
/// deferred while a drill line is in progress.
final class SyncController extends Notifier<SyncStatus> {
  /// Debounce after a local change.
  static const debounce = Duration(seconds: 30);

  /// Delay after the app starts.
  static const startDelay = Duration(seconds: 3);

  final _changes = StreamController<SyncChange>.broadcast();
  Timer? _debounce;
  Timer? _start;
  StreamSubscription<Object?>? _tableWatch;
  bool _pending = false;
  bool _started = false;

  /// What each finished sync changed.
  Stream<SyncChange> get changes => _changes.stream;

  DriveAuth get _auth => ref.read(driveAuthProvider);

  @override
  SyncStatus build() {
    final gate = ref.watch(syncGateProvider);
    void onGate() {
      if (!gate.busy && _pending) unawaited(syncNow());
    }

    gate.addListener(onGate);
    ref.onDispose(() {
      gate.removeListener(onGate);
      _debounce?.cancel();
      _start?.cancel();
      unawaited(_tableWatch?.cancel());
      unawaited(_changes.close());
    });
    if (!_auth.isConfigured) {
      return const SyncStatus(phase: SyncPhase.notConfigured);
    }
    unawaited(_load());
    return const SyncStatus(phase: SyncPhase.off);
  }

  Future<void> _load() async {
    final store = ref.read(syncStateRepositoryProvider);
    final enabled = await store.get(SyncControllerKeys.enabled) == '1';
    final last = int.tryParse(
      await store.get(SyncControllerKeys.lastSyncAt) ?? '',
    );
    if (!ref.mounted) return;
    if (!enabled) {
      state = SyncStatus(phase: SyncPhase.off, lastSyncAt: last);
      return;
    }
    final signedIn = await _auth.restore().catchError((Object _) => false);
    if (!ref.mounted) return;
    state = SyncStatus(
      phase: signedIn ? SyncPhase.idle : SyncPhase.signInNeeded,
      lastSyncAt: last,
    );
    _watchLocalChanges();
    if (signedIn) {
      unawaited(_fetchAccount());
      _scheduleStart();
    }
  }

  Future<void> _fetchAccount() async {
    try {
      final email = await (await ref.read(
        driveConnectorProvider,
      )()).accountEmail();
      if (ref.mounted && email != null) state = state.copyWith(account: email);
    } on Object catch (e) {
      _log.info('No account e-mail: $e');
    }
  }

  void _watchLocalChanges() {
    if (_tableWatch != null) return;
    final db = ref.read(databaseProvider);
    _tableWatch = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.runs, db.repertoires]))
        .listen((_) => onLocalChange());
  }

  /// The app's first frame was shown: sync 3 s later if on (or once the
  /// stored state says it is).
  void onAppStarted() {
    if (_started) return;
    _started = true;
    _scheduleStart();
  }

  void _scheduleStart() {
    if (!_started || _start != null || !state.enabled) return;
    _start = Timer(startDelay, () => unawaited(syncNow()));
  }

  /// The app went to the background (or is closing).
  Future<void> onBackground() async {
    if (state.enabled) await syncNow();
  }

  /// A run or repertoire changed locally: sync after [debounce].
  void onLocalChange() {
    // A sync's own writes are not local changes.
    if (!state.enabled || state.phase == SyncPhase.syncing) return;
    _debounce?.cancel();
    _debounce = Timer(debounce, () => unawaited(syncNow()));
  }

  /// Syncs now (or when the drill line ends).
  Future<void> syncNow() async {
    if (!state.enabled || state.phase == SyncPhase.signInNeeded) return;
    if (ref.read(syncGateProvider).busy) {
      _pending = true;
      return;
    }
    _pending = false;
    _debounce?.cancel();
    state = state.copyWith(phase: SyncPhase.syncing, clearMessage: true);
    try {
      final report = await ref.read(syncServiceProvider).sync();
      final now = ref.read(clockProvider).now().millisecondsSinceEpoch;
      await ref
          .read(syncStateRepositoryProvider)
          .set(SyncControllerKeys.lastSyncAt, '$now');
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: SyncPhase.idle,
        lastSyncAt: now,
        warnings: report.warnings,
      );
      _announce(report);
    } on SyncOffline catch (e) {
      if (ref.mounted) {
        state = state.copyWith(phase: SyncPhase.offline, message: e.message);
      }
    } on SyncAuthExpired catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          phase: SyncPhase.signInNeeded,
          message: e.message,
        );
      }
    } on Object catch (e) {
      _log.warning('Sync failed', e);
      if (ref.mounted) {
        state = state.copyWith(phase: SyncPhase.error, message: '$e');
      }
    }
  }

  /// Announces [change] as if a sync made it (tests).
  @visibleForTesting
  void debugAnnounce(SyncChange change) => _changes.add(change);

  void _announce(SyncReport report) {
    final changed = report.merge.changedIds;
    final deleted = report.merge.effects.deleteRepertoires;
    for (final id in changed) {
      ref
        ..invalidate(repertoireTreeProvider(id))
        ..invalidate(lineRefsProvider(id));
    }
    if (changed.isEmpty && report.updatedFromOtherDevice.isEmpty) return;
    _changes.add(
      SyncChange(
        changedIds: changed,
        deletedIds: deleted,
        updatedNames: report.updatedFromOtherDevice,
      ),
    );
  }

  /// Turns sync on: signs in when needed, then syncs.
  Future<void> enable() async {
    if (!_auth.isConfigured) return;
    if (!await _auth.restore()) await _auth.signIn();
    await ref
        .read(syncStateRepositoryProvider)
        .set(SyncControllerKeys.enabled, '1');
    state = state.copyWith(phase: SyncPhase.idle, clearMessage: true);
    _watchLocalChanges();
    unawaited(_fetchAccount());
    await syncNow();
  }

  /// Signs in again after "Sign in again".
  Future<void> signInAgain() async {
    await _auth.signIn();
    state = state.copyWith(phase: SyncPhase.idle, clearMessage: true);
    await syncNow();
  }

  /// Turns sync off and signs out; local data stays.
  Future<void> signOut() async {
    _debounce?.cancel();
    await _auth.signOut();
    await ref
        .read(syncStateRepositoryProvider)
        .remove(SyncControllerKeys.enabled);
    state = SyncStatus(phase: SyncPhase.off, lastSyncAt: state.lastSyncAt);
  }

  /// Deletes every device's sync files; local data stays.
  Future<int> deleteCloudData() =>
      ref.read(syncServiceProvider).deleteCloudData();
}

/// The app's sync controller.
final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);
