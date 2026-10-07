import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/recovery_service.dart';
import 'package:repertoire_trainer/core/db/repositories/snapshot_repository.dart';
import 'package:repertoire_trainer/core/errors/describe_error.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Saved versions, newest first.
final StreamProvider<List<Snapshot>> snapshotsProvider =
    StreamProvider.autoDispose<List<Snapshot>>(
      (ref) => ref.watch(snapshotRepositoryProvider).watchAll(),
    );

/// Deleted repertoires that can be restored.
final StreamProvider<List<TrashEntry>> trashProvider =
    StreamProvider.autoDispose<List<TrashEntry>>(
      (ref) => ref.watch(snapshotRepositoryProvider).watchTrash(),
    );

/// Version history and trash (audit R4): every saved version, deleted
/// repertoires, and incoming versions that did not import. With
/// [repertoireId], only that repertoire's versions.
class RecoveryScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key, this.repertoireId});

  /// Shows only this repertoire's versions.
  final String? repertoireId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final only = repertoireId;
    final snapshots = [
      for (final s in ref.watch(snapshotsProvider).value ?? const <Snapshot>[])
        if (only == null || s.repertoireId == only) s,
    ];
    final trash = only != null
        ? const <TrashEntry>[]
        : ref.watch(trashProvider).value ?? const <TrashEntry>[];
    final versions = [
      for (final s in snapshots)
        if (s.reason != SnapshotReason.rejected) s,
    ];
    final rejected = [
      for (final s in snapshots)
        if (s.reason == SnapshotReason.rejected) s,
    ];
    final theme = Theme.of(context);
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AdaptiveLayout.gutter,
        16,
        AdaptiveLayout.gutter,
        4,
      ),
      child: Text(text, style: theme.textTheme.titleSmall),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(only == null ? l10n.recoveryTitle : l10n.versionHistory),
      ),
      body: AdaptiveLayout(
        phone: ListView(
          key: const Key('recovery'),
          children: [
            if (trash.isNotEmpty) ...[
              header(l10n.recoveryTrash),
              for (final e in trash) _TrashTile(entry: e),
            ],
            if (versions.isNotEmpty) ...[
              header(l10n.recoveryVersions),
              for (final s in versions) _SnapshotTile(snapshot: s),
            ],
            if (rejected.isNotEmpty) ...[
              header(l10n.recoveryRejected),
              for (final s in rejected) _SnapshotTile(snapshot: s),
            ],
            if (trash.isEmpty && snapshots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AdaptiveLayout.gutter),
                child: Text(
                  l10n.recoveryEmpty,
                  key: const Key('recovery-empty'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AdaptiveLayout.gutter),
              child: Text(
                l10n.recoveryInfo(maxSnapshotsPerRepertoire),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _date(BuildContext context, int ms) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
        .add_Hm()
        .format(DateTime.fromMillisecondsSinceEpoch(ms));

String _reason(AppLocalizations l10n, SnapshotReason r) => switch (r) {
  SnapshotReason.reimport => l10n.snapshotReasonReimport,
  SnapshotReason.restore => l10n.snapshotReasonRestore,
  SnapshotReason.replaced => l10n.snapshotReasonReplaced,
  SnapshotReason.deleted => l10n.snapshotReasonDeleted,
  SnapshotReason.rejected => l10n.snapshotReasonRejected,
};

void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// Runs [action]; shows [done] or a readable error.
Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  String what,
  Future<void> Function() action, {
  String? done,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  void show(String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  try {
    await action();
    if (done != null) show(done);
  } on VersionNotRestorable catch (e, st) {
    reportError(what, e, st);
    show(l10n.versionNotRestorable);
  } on Object catch (e, st) {
    show(l10n.recoveryFailed(reportError(what, e, st)));
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  required Key key,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: key,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _TrashTile extends ConsumerWidget {
  const new({required this.entry});

  final TrashEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final date = _date(context, entry.deletedAt);
    final recovery = ref.read(recoveryServiceProvider);
    return ListTile(
      key: Key('trash-${entry.repertoireId}'),
      leading: const Icon(Icons.delete_outline),
      title: Text(entry.name),
      subtitle: Text(
        entry.hasData ? l10n.trashWithHistory(date) : l10n.trashMovesOnly(date),
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          TextButton(
            key: Key('restore-${entry.repertoireId}'),
            onPressed: () => unawaited(
              _run(
                context,
                ref,
                'Restore from trash failed',
                () => recovery.restoreDeleted(entry.repertoireId),
                done: l10n.versionRestored(entry.name),
              ),
            ),
            child: Text(l10n.restore),
          ),
          IconButton(
            key: Key('delete-forever-${entry.repertoireId}'),
            tooltip: l10n.deleteForever,
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: () async {
              final ok = await _confirm(
                context,
                title: l10n.deleteForeverTitle(entry.name),
                body: l10n.deleteForeverBody,
                action: l10n.deleteForever,
                key: const Key('confirm-delete-forever'),
              );
              if (!ok || !context.mounted) return;
              await _run(
                context,
                ref,
                'Delete forever failed',
                () => recovery.deleteForever(entry.repertoireId),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _VersionAction { restore, export, delete }

class _SnapshotTile extends ConsumerWidget {
  const new({required this.snapshot});

  final Snapshot snapshot;

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _VersionAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final s = snapshot;
    switch (action) {
      case _VersionAction.restore:
        final ok = await _confirm(
          context,
          title: l10n.restoreVersionTitle(s.record.name),
          body: l10n.restoreVersionBody,
          action: l10n.restore,
          key: const Key('confirm-restore-version'),
        );
        if (!ok || !context.mounted) return;
        await _run(context, ref, 'Version restore failed', () async {
          await ref.read(recoveryServiceProvider).restoreVersion(s.id);
          ref
            ..invalidate(repertoireTreeProvider(s.repertoireId))
            ..invalidate(lineRefsProvider(s.repertoireId));
        }, done: l10n.versionRestored(s.record.name));
      case _VersionAction.export:
        try {
          final where = await ref
              .read(fileServiceProvider)
              .saveText(
                fileName: pgnFileName(s.record.name),
                text: s.record.pgn,
              );
          if (where != null && context.mounted) {
            _snack(context, l10n.exportedSnack(where));
          }
        } on Object catch (e, st) {
          if (context.mounted) {
            _snack(
              context,
              l10n.exportFailed(reportError('Version export failed', e, st)),
            );
          }
        }
      case _VersionAction.delete:
        await _run(
          context,
          ref,
          'Version delete failed',
          () => ref.read(snapshotRepositoryProvider).delete(s.id),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = snapshot;
    final rejected = s.reason == SnapshotReason.rejected;
    return ListTile(
      key: Key('snapshot-${s.id}'),
      leading: Icon(rejected ? Icons.report_outlined : Icons.history),
      title: Text(s.record.name),
      subtitle: Text(
        l10n.snapshotSubtitle(
          _reason(l10n, s.reason),
          _date(context, s.savedAt),
        ),
      ),
      trailing: PopupMenuButton<_VersionAction>(
        key: Key('snapshot-menu-${s.id}'),
        onSelected: (a) => unawaited(_onAction(context, ref, a)),
        itemBuilder: (context) => [
          if (!rejected)
            PopupMenuItem(
              key: const Key('version-restore'),
              value: _VersionAction.restore,
              child: Text(l10n.restoreVersion),
            ),
          PopupMenuItem(
            key: const Key('version-export'),
            value: _VersionAction.export,
            child: Text(l10n.exportPgn),
          ),
          PopupMenuItem(
            key: const Key('version-delete'),
            value: _VersionAction.delete,
            child: Text(l10n.deleteVersion),
          ),
        ],
      ),
    );
  }
}
