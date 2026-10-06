import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';
import 'package:repertoire_trainer/features/board/position_preview.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// The import report (docs/plan/01-product-spec.md §5): counts, errors,
/// warnings grouped by code, collapsed infos, Copy report, timing footer,
/// and the Import / Cancel buttons.
class ImportReportView extends StatelessWidget {
  /// Creates the view. [onImport] null hides the Import button (validate
  /// only); it is disabled when the report has errors.
  const new({
    required this.result,
    required this.side,
    required this.onCancel,
    this.onImport,
    this.diff,
    super.key,
  });

  /// The import result.
  final ImportResult result;

  /// Board orientation for previews.
  final Side side;

  /// Import action, or null for "Validate only".
  final VoidCallback? onImport;

  /// Leaves the report.
  final VoidCallback onCancel;

  /// Re-import diff block.
  final Widget? diff;

  ImportReport get _report => result.report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = _report;
    final warningsByCode = <ReportCode, List<ReportItem>>{};
    for (final w in report.warnings) {
      (warningsByCode[w.code] ??= []).add(w);
    }
    final percent = report.userMoves == 0
        ? 0
        : (report.commentedUserMoves * 100 / report.userMoves).round();
    return Column(
      children: [
        Expanded(
          child: AdaptiveLayout(
            phone: ListView(
              key: const Key('report-list'),
              padding: const EdgeInsets.all(AdaptiveLayout.gutter),
              children: [
                _Counts(
                  rows: [
                    (l10n.reportGames, '${report.games}'),
                    (l10n.reportLines, '${report.lines}'),
                    (l10n.reportUserMoves, '${report.userMoves}'),
                    (l10n.reportOpponentMoves, '${report.opponentMoves}'),
                    (
                      l10n.reportCommented,
                      l10n.reportCommentedValue(
                        report.commentedUserMoves,
                        percent,
                      ),
                    ),
                    (l10n.reportDepth, l10n.reportDepthValue(report.maxDepth)),
                  ],
                ),
                if (diff != null) ...[const SizedBox(height: 16), diff!],
                const SizedBox(height: 16),
                if (report.errors.isNotEmpty) ...[
                  _SectionTitle(
                    l10n.reportErrors(report.errors.length),
                    AppColors.error,
                  ),
                  for (final e in report.errors) _ItemTile(e, side: side),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.importBlocked),
                  ),
                ],
                _SectionTitle(
                  l10n.reportWarnings(report.warnings.length),
                  AppColors.warning,
                ),
                for (final MapEntry(key: code, value: items)
                    in warningsByCode.entries)
                  ExpansionTile(
                    key: Key('group-${code.id}'),
                    title: Text('${code.id} (${items.length})'),
                    initiallyExpanded: warningsByCode.length == 1,
                    children: [for (final w in items) _ItemTile(w, side: side)],
                  ),
                if (report.infos.isNotEmpty)
                  ExpansionTile(
                    key: const Key('group-info'),
                    title: Text(
                      l10n.reportInfo(report.infos.length),
                      style: const TextStyle(color: AppColors.info),
                    ),
                    children: [
                      for (final i in report.infos) _ItemTile(i, side: side),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.processedIn(result.elapsed.inMilliseconds),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  key: const Key('copy-report'),
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.copyReport),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(
                      ClipboardData(text: report.toPlainText()),
                    );
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.reportCopied)),
                    );
                  },
                ),
                OutlinedButton(onPressed: onCancel, child: Text(l10n.cancel)),
                if (onImport != null)
                  FilledButton(
                    key: const Key('import-button'),
                    onPressed: report.hasErrors ? null : onImport,
                    child: Text(l10n.importAction),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Counts extends StatelessWidget {
  const new({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(label)),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const new(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
    ),
  );
}

class _ItemTile extends StatelessWidget {
  const new(this.item, {required this.side});

  final ReportItem item;
  final Side side;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPreview = item.nodePath.isNotEmpty;
    return ListTile(
      dense: true,
      title: Text(item.message),
      subtitle: item.details.isEmpty
          ? Text(item.code.id)
          : Text('${item.code.id}\n${item.details.join('\n')}'),
      trailing: canPreview ? const Icon(Icons.visibility_outlined) : null,
      onTap: canPreview
          ? () => showPositionPreview(
              context,
              sanPath: item.nodePath,
              title:
                  '${l10n.positionPreview}: ${formatSanMoves(item.nodePath)}',
              orientation: side,
            )
          : null,
    );
  }
}

/// The re-import diff block (01 §13).
class ReimportDiffView extends StatelessWidget {
  /// Shows [diff]; [labels] maps old line keys to their labels for the
  /// removed-lines list.
  const new({required this.diff, required this.labels, super.key});

  /// The diff.
  final ReimportDiff diff;

  /// Line labels by key.
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget row(String label, int n, {Key? key}) => ListTile(
      key: key,
      dense: true,
      title: Text(label),
      trailing: Text('$n', style: Theme.of(context).textTheme.titleMedium),
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              l10n.diffTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          row(
            l10n.diffUnchanged,
            diff.unchanged.length,
            key: const Key('diff-unchanged'),
          ),
          row(
            l10n.diffExtended,
            diff.extended.length,
            key: const Key('diff-extended'),
          ),
          row(l10n.diffNew, diff.added.length, key: const Key('diff-new')),
          ExpansionTile(
            key: const Key('diff-removed'),
            dense: true,
            title: Text(l10n.diffRemoved),
            trailing: Text(
              '${diff.removed.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              for (final key in diff.removed)
                ListTile(dense: true, title: Text(labels[key] ?? key)),
            ],
          ),
          row(
            l10n.diffCommentChanges,
            diff.commentChanges,
            key: const Key('diff-comments'),
          ),
        ],
      ),
    );
  }
}
