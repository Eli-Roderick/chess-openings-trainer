import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/sync/sync_controller.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Wires sync to the app's life (06 §6): a sync 3 s after the first frame,
/// one when the app goes to the background, one (at most 5 s) before the
/// desktop app closes; shows "`<name>` was updated from another device".
class SyncLifecycle extends ConsumerStatefulWidget {
  /// Wraps [child]; SnackBars go to [messenger].
  const new({required this.child, required this.messenger, super.key});

  /// The app.
  final Widget child;

  /// The app's ScaffoldMessenger.
  final GlobalKey<ScaffoldMessengerState> messenger;

  @override
  ConsumerState<SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<SyncLifecycle> {
  late final AppLifecycleListener _listener;
  StreamSubscription<SyncChange>? _changes;

  SyncController get _controller => ref.read(syncControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onPause: () => unawaited(_controller.onBackground()),
      onExitRequested: () async {
        await _controller.onBackground().timeout(
          const Duration(seconds: 5),
          onTimeout: () {},
        );
        return AppExitResponse.exit;
      },
    );
    _changes = _controller.changes.listen(_show);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.onAppStarted();
    });
  }

  void _show(SyncChange change) {
    final messenger = widget.messenger.currentState;
    if (messenger == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    for (final name in change.updatedNames) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.updatedFromOtherDevice(name))),
      );
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    unawaited(_changes?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
