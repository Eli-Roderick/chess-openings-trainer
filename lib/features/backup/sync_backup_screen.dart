import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/db/backup_queries.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/core/sync/sync_controller.dart';
import 'package:repertoire_trainer/features/backup/backup_service.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// How a backup is imported.
enum ImportMode {
  /// Same merge as sync (default).
  merge,

  /// Delete local repertoires and runs first.
  replace,
}

/// Settings → Sync and backup (06-sync §8; Drive sync arrives in P12).
class SyncBackupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<SyncBackupScreen> createState() => _SyncBackupState();
}

class _SyncBackupState extends ConsumerState<SyncBackupScreen> {
  String? _busy;

  /// Replaces the current SnackBar (results should not queue up).
  void _show(ScaffoldMessengerState messenger, SnackBar bar) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(bar);

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = l10n.backupExporting);
    try {
      final backup = await ref.read(backupServiceProvider).export();
      if (!mounted) return;
      setState(() => _busy = null);
      final where = await ref
          .read(fileServiceProvider)
          .saveBackup(fileName: backup.fileName, bytes: backup.bytes);
      if (where != null) {
        _show(messenger, SnackBar(content: Text(l10n.backupSaved(where))));
      }
    } on Object catch (e) {
      _show(messenger, SnackBar(content: Text(l10n.backupFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(backupServiceProvider);
    final picked = await ref.read(fileServiceProvider).pickBackup();
    if (picked == null || !mounted) return;
    setState(() => _busy = l10n.backupReading);
    final RawBackup backup;
    try {
      backup = await service.read(picked.bytes);
    } on CodecError catch (e) {
      if (mounted) setState(() => _busy = null);
      _show(
        messenger,
        SnackBar(
          content: Text(switch (e) {
            NewerSchema() => l10n.backupNewer,
            WrongFormat() || CorruptFile() => l10n.backupInvalid,
          }),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _busy = null);
    final choice = await showDialog<(ImportMode, bool)>(
      context: context,
      builder: (context) => _ImportDialog(backup: backup),
    );
    if (choice == null || !mounted) return;
    final (mode, restoreSettings) = choice;
    if (mode == ImportMode.replace) {
      final repertoires =
          (await ref.read(repertoireRepositoryProvider).records())
              .where((r) => !r.deleted)
              .length;
      final runs = await ref.read(runRepositoryProvider).count();
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.replaceAllTitle),
          content: Text(
            [
              l10n.replaceAllBody(repertoires, runs),
              // Other devices would bring the data back (06 §8).
              if (ref.read(syncControllerProvider).enabled)
                l10n.replaceSyncWarning,
            ].join('\n\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              key: const Key('confirm-replace'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.replaceAll),
            ),
          ],
        ),
      );
      if (!(ok ?? false) || !mounted) return;
    }
    setState(() => _busy = l10n.backupImporting);
    try {
      final report = await service.import(
        backup,
        replace: mode == ImportMode.replace,
        restoreSettings: restoreSettings,
      );
      _show(
        messenger,
        SnackBar(
          content: Text(
            l10n.backupImported(report.changedIds.length, report.insertedRuns),
          ),
        ),
      );
    } on Object catch (e) {
      _show(messenger, SnackBar(content: Text(l10n.backupFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = _busy;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSync)),
      body: AdaptiveLayout(
        phone: ListView(
          key: const Key('sync-backup'),
          children: [
            ListTile(title: Text(l10n.syncTitle)),
            const _SyncSection(),
            const Divider(height: 32),
            ListTile(title: Text(l10n.backupTitle)),
            if (busy != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdaptiveLayout.gutter,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LinearProgressIndicator(),
                    const SizedBox(height: 4),
                    Text(busy, key: const Key('backup-busy')),
                  ],
                ),
              ),
            ListTile(
              key: const Key('export-backup'),
              leading: const Icon(Icons.save_alt),
              title: Text(l10n.exportBackup),
              subtitle: Text(l10n.exportBackupHint),
              enabled: busy == null,
              onTap: () => unawaited(_export()),
            ),
            ListTile(
              key: const Key('import-backup'),
              leading: const Icon(Icons.restore),
              title: Text(l10n.importBackup),
              subtitle: Text(l10n.importBackupHint),
              enabled: busy == null,
              onTap: () => unawaited(_import()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Merge or Replace all, and "Also restore settings".
class _ImportDialog extends StatefulWidget {
  const new({required this.backup});

  final RawBackup backup;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  ImportMode _mode = ImportMode.merge;
  bool _settings = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final b = widget.backup.header;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(DateTime.fromMillisecondsSinceEpoch(b.exportedAt));
    return AlertDialog(
      key: const Key('import-dialog'),
      title: Text(l10n.importBackup),
      content: SingleChildScrollView(
        child: RadioGroup<ImportMode>(
          groupValue: _mode,
          onChanged: (m) => setState(() => _mode = m ?? _mode),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.backupContents(
                  b.repertoires.length,
                  widget.backup.runCount,
                  date,
                ),
                key: const Key('backup-contents'),
              ),
              const SizedBox(height: 8),
              RadioListTile<ImportMode>(
                key: const Key('mode-merge'),
                contentPadding: EdgeInsets.zero,
                value: ImportMode.merge,
                title: Text(l10n.importMerge),
                subtitle: Text(l10n.importMergeHint),
              ),
              RadioListTile<ImportMode>(
                key: const Key('mode-replace'),
                contentPadding: EdgeInsets.zero,
                value: ImportMode.replace,
                title: Text(l10n.replaceAll),
                subtitle: Text(l10n.importReplaceHint),
              ),
              CheckboxListTile(
                key: const Key('restore-settings'),
                contentPadding: EdgeInsets.zero,
                value: _settings,
                onChanged: (v) => setState(() => _settings = v ?? false),
                title: Text(l10n.restoreSettings),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('start-import'),
          onPressed: () => Navigator.of(context).pop((_mode, _settings)),
          child: Text(l10n.importAction),
        ),
      ],
    );
  }
}

/// Drive sync: toggle, account, last sync, Sync now, Sign out, Delete
/// cloud data (06 §6), errors (§7).
class _SyncSection extends ConsumerWidget {
  const new();

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on Object catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.syncFailed('$e'))));
    }
  }

  Future<void> _deleteCloud(BuildContext context, SyncController c) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCloudTitle),
        content: Text(l10n.deleteCloudBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-cloud'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    try {
      final n = await c.deleteCloudData();
      messenger.showSnackBar(SnackBar(content: Text(l10n.cloudDeleted(n))));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.syncFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);
    final c = ref.read(syncControllerProvider.notifier);
    const pad = EdgeInsets.symmetric(horizontal: AdaptiveLayout.gutter);
    if (status.phase == SyncPhase.notConfigured) {
      return Padding(
        padding: pad,
        child: Text(
          l10n.syncNotConfigured,
          key: const Key('sync-unconfigured'),
        ),
      );
    }
    final last = status.lastSyncAt;
    final lastText = last == null
        ? l10n.syncNever
        : DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
              .add_Hm()
              .format(DateTime.fromMillisecondsSinceEpoch(last));
    final line = switch (status.phase) {
      SyncPhase.syncing => l10n.syncRunning,
      SyncPhase.offline => l10n.syncOffline,
      SyncPhase.signInNeeded => l10n.syncSignInAgain,
      SyncPhase.error => l10n.syncError(status.message ?? ''),
      _ => l10n.syncLast(lastText),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          key: const Key('sync-toggle'),
          title: Text(l10n.syncToggle),
          subtitle: Text(
            status.enabled
                ? (status.account == null
                      ? l10n.syncSignedIn
                      : l10n.syncSignedInAs(status.account!))
                : l10n.syncOffHint,
          ),
          value: status.enabled,
          onChanged: status.phase == SyncPhase.syncing
              ? null
              : (on) => unawaited(_run(context, on ? c.enable : c.signOut)),
        ),
        if (status.enabled) ...[
          ListTile(
            key: const Key('sync-status'),
            title: Text(line),
            leading: status.phase == SyncPhase.syncing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          for (final w in status.warnings)
            ListTile(
              leading: const Icon(Icons.warning_amber),
              title: Text(
                w.newerSchema ? l10n.syncNewerDevice : l10n.syncCorruptFile,
              ),
            ),
          Padding(
            padding: pad,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status.phase == SyncPhase.signInNeeded)
                  FilledButton(
                    key: const Key('sync-sign-in'),
                    onPressed: () => unawaited(_run(context, c.signInAgain)),
                    child: Text(l10n.signInAgain),
                  )
                else
                  FilledButton.icon(
                    key: const Key('sync-now'),
                    icon: const Icon(Icons.sync),
                    onPressed: status.phase == SyncPhase.syncing
                        ? null
                        : () => unawaited(_run(context, c.syncNow)),
                    label: Text(l10n.syncNow),
                  ),
                OutlinedButton(
                  key: const Key('sync-sign-out'),
                  onPressed: () => unawaited(_run(context, c.signOut)),
                  child: Text(l10n.signOut),
                ),
                TextButton(
                  key: const Key('delete-cloud'),
                  onPressed: () => unawaited(_deleteCloud(context, c)),
                  child: Text(l10n.deleteCloudData),
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AdaptiveLayout.gutter,
            8,
            AdaptiveLayout.gutter,
            0,
          ),
          child: Text(
            l10n.syncHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
