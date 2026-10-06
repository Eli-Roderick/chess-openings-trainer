import 'dart:async';

import 'package:chess_core/chess_core.dart' show accuracyPercent;
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/features/board/repertoire_actions.dart';
import 'package:repertoire_trainer/features/home/demo_installer.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Home (docs/plan/01-product-spec.md §4). The streak card and Continue
/// button arrive with P08/P10.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates Home.
  const new({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  bool _installingDemo = false;
  late final CalibrationController _calibration = ref.read(
    calibrationProvider.notifier,
  );

  @override
  void initState() {
    super.initState();
    // Engine calibration once per install after 10 s idle on Home
    // (docs/plan/05-engine.md §9).
    unawaited(
      _calibration.scheduleAuto(
        isIdle: () => mounted && (ModalRoute.of(context)?.isCurrent ?? true),
      ),
    );
  }

  @override
  void dispose() {
    _calibration.cancelAuto();
    super.dispose();
  }

  Future<void> _tryDemo() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _installingDemo = true);
    try {
      final id = await installDemo(ref, name: l10n.demoName);
      if (mounted) unawaited(context.push(Routes.repertoire(id)));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
    } finally {
      if (mounted) setState(() => _installingDemo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(repertoireSummariesProvider);
    if (summaries.hasValue) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => StartupTimings.instance.markHomeData(),
      );
    }
    final list = summaries.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            key: const Key('open-settings'),
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      floatingActionButton: list != null && list.isNotEmpty
          ? FloatingActionButton.extended(
              key: const Key('new-repertoire'),
              onPressed: () => context.push(Routes.newRepertoire),
              icon: const Icon(Icons.add),
              label: Text(l10n.newRepertoire),
            )
          : null,
      body: switch (summaries) {
        AsyncValue(:final error?) => Center(
          child: Text(l10n.loadError('$error')),
        ),
        AsyncValue(value: final items?) when items.isEmpty => _EmptyHome(
          installing: _installingDemo,
          onCreate: () => context.push(Routes.newRepertoire),
          onDemo: _tryDemo,
        ),
        AsyncValue(value: final items?) => AdaptiveLayout(
          phone: ListView.builder(
            key: const Key('repertoire-list'),
            padding: const EdgeInsets.fromLTRB(
              AdaptiveLayout.gutter,
              8,
              AdaptiveLayout.gutter,
              88,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => RepertoireCard(summary: items[i]),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const new({
    required this.installing,
    required this.onCreate,
    required this.onDemo,
  });

  final bool installing;
  final VoidCallback onCreate;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.homeEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (installing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(l10n.demoInstalling),
            ] else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    key: const Key('create-repertoire'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createRepertoire),
                    onPressed: onCreate,
                  ),
                  OutlinedButton.icon(
                    key: const Key('try-demo'),
                    icon: const Icon(Icons.school_outlined),
                    label: Text(l10n.tryDemo),
                    onPressed: onDemo,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A Home card: name, colour, lines, accuracy, due and weak counts.
class RepertoireCard extends ConsumerWidget {
  /// Shows [summary].
  const new({required this.summary, super.key});

  /// The repertoire.
  final RepertoireSummary summary;

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final action = await showModalBottomSheet<_Action>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final a in _Action.values)
              ListTile(
                key: Key('action-${a.name}'),
                leading: Icon(a.icon),
                title: Text(a.label(l10n)),
                onTap: () => Navigator.of(context).pop(a),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    await _run(action, context, ref, messenger);
  }

  Future<void> _run(
    _Action action,
    BuildContext context,
    WidgetRef ref,
    ScaffoldMessengerState messenger,
  ) async {
    switch (action) {
      case _Action.rename:
        await renameRepertoire(
          context,
          ref,
          id: summary.id,
          currentName: summary.name,
        );
      case _Action.reimport:
        await context.push(Routes.reimport(summary.id));
      case _Action.export:
        await exportRepertoirePgn(context, ref, id: summary.id);
      case _Action.delete:
        await deleteRepertoire(
          context,
          ref,
          id: summary.id,
          name: summary.name,
          messenger: messenger,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wide = AdaptiveLayout.sizeOf(context) == LayoutSize.wide;
    final theme = Theme.of(context);
    final accuracy = summary.accuracy;
    return Card(
      key: Key('repertoire-${summary.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.repertoire(summary.id)),
        onLongPress: () => _showActions(context, ref),
        onSecondaryTap: () => _showActions(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              ColourDisc(side: summary.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(l10n.lineCount(summary.lineCount)),
                        Text(
                          accuracy == null
                              ? l10n.notTrained
                              : l10n.accuracyValue(accuracyPercent(accuracy)),
                        ),
                        if (summary.dueCount > 0)
                          Text(
                            l10n.dueCount(summary.dueCount),
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        if (summary.weakCount > 0)
                          Text(
                            l10n.weakCount(summary.weakCount),
                            style: const TextStyle(color: AppColors.warning),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (wide)
                PopupMenuButton<_Action>(
                  key: Key('menu-${summary.id}'),
                  tooltip: l10n.repertoireActions,
                  onSelected: (a) =>
                      _run(a, context, ref, ScaffoldMessenger.of(context)),
                  itemBuilder: (context) => [
                    for (final a in _Action.values)
                      PopupMenuItem(value: a, child: Text(a.label(l10n))),
                  ],
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Action {
  rename(Icons.edit_outlined),
  reimport(Icons.upload_file_outlined),
  export(Icons.download_outlined),
  delete(Icons.delete_outline);

  new(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    rename => l10n.rename,
    reimport => l10n.reimport,
    export => l10n.exportPgn,
    delete => l10n.delete,
  };
}

/// A white or black disc marking the repertoire's colour.
class ColourDisc extends StatelessWidget {
  /// Disc for [side].
  const new({required this.side, super.key});

  /// Colour.
  final Side side;

  @override
  Widget build(BuildContext context) {
    final white = side == Side.white;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: white ? l10n.colorWhite : l10n.colorBlack,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white ? AppColors.whiteSide : AppColors.blackSide,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
