import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/mappers.dart';
import 'package:repertoire_trainer/features/import/import_controller.dart';
import 'package:repertoire_trainer/features/import/report_view.dart';
import 'package:repertoire_trainer/features/import/source_picker.dart';
import 'package:repertoire_trainer/features/import/stage_names.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Re-import a repertoire (docs/plan/01-product-spec.md §13): same source
/// choices, colour fixed, report with the diff block, then rebuilds stats.
class ReimportScreen extends ConsumerStatefulWidget {
  /// Re-imports repertoire [id].
  const new({required this.id, super.key});

  /// Repertoire id.
  final String id;

  @override
  ConsumerState<ReimportScreen> createState() => _ReimportState();
}

class _ReimportState extends ConsumerState<ReimportScreen> {
  final _source = PgnSourceController();
  late final Future<DbRepertoire?> _repertoire = ref
      .read(repertoireRepositoryProvider)
      .get(widget.id);
  bool _submitted = false;
  bool _saving = false;
  ImportDone? _diffFor;
  Future<(ReimportDiff, Map<String, String>)>? _diff;

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<(ReimportDiff, Map<String, String>)> _computeDiff(
    ImportDone done,
  ) async {
    final repo = ref.read(repertoireRepositoryProvider);
    final oldTree = await repo.loadTree(widget.id);
    final newTree = done.result.tree;
    final diff = newTree == null
        ? diffReimport(oldLines: lineRefsOf(oldTree), newLines: const [])
        : diffReimport(
            oldLines: lineRefsOf(oldTree),
            newLines: lineRefsOf(newTree),
            commentChanges: countCommentChanges(oldTree, newTree),
          );
    return (diff, {for (final l in oldTree.lines) l.key: l.label});
  }

  Future<void> _import(ImportDone done, String name) async {
    if (_saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(repertoireRepositoryProvider)
          .reimport(widget.id, pgn: done.text!, result: done.result);
      await ref.read(statsServiceProvider).rebuildRepertoire(widget.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.reimported(name))));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<DbRepertoire?>(
      future: _repertoire,
      builder: (context, snapshot) {
        final rep = snapshot.data;
        if (rep == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: snapshot.connectionState == ConnectionState.done
                  ? Text(l10n.loadError('not found'))
                  : const CircularProgressIndicator(),
            ),
          );
        }
        final side = sideFromDb(rep.color);
        final state = ref.watch(importControllerProvider);
        final controller = ref.read(importControllerProvider.notifier);
        if (state is ImportDone && !identical(state, _diffFor)) {
          _diffFor = state;
          _diff = _computeDiff(state);
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.reimportTitle(rep.name))),
          body: switch (state) {
            ImportIdle() => AdaptiveLayout(
              phone: ListView(
                padding: const EdgeInsets.all(AdaptiveLayout.gutter),
                children: [
                  Text(
                    l10n.reimportColour(
                      rep.color == 'w' ? l10n.colorWhite : l10n.colorBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PgnSourcePicker(
                    controller: _source,
                    errorText: _submitted && _source.bytes == null
                        ? l10n.errorSourceRequired
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      key: const Key('validate-reimport'),
                      onPressed: () {
                        setState(() => _submitted = true);
                        final bytes = _source.bytes;
                        if (bytes != null) controller.run(bytes, side);
                      },
                      child: Text(l10n.validateAndImport),
                    ),
                  ),
                ],
              ),
            ),
            ImportRunning(:final stage) => ImportProgressView(
              stage: stageName(l10n, stage),
              onCancel: controller.reset,
            ),
            ImportDone() => FutureBuilder(
              future: _diff,
              builder: (context, diff) => ImportReportView(
                result: state.result,
                side: side,
                onCancel: controller.reset,
                diff: diff.data == null
                    ? null
                    : ReimportDiffView(
                        diff: diff.data!.$1,
                        labels: diff.data!.$2,
                      ),
                onImport: _saving || diff.data == null
                    ? null
                    : () => _import(state, rep.name),
              ),
            ),
            ImportFailed(:final message) => Center(
              child: Text(l10n.importFailed(message)),
            ),
          },
        );
      },
    );
  }
}
