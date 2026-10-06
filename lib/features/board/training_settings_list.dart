import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Settings → Training (01-product-spec §10), the drill parts; also shown
/// as a sheet from the drill. Deviation, weak-pool, SRS and day-start
/// settings arrive with their phases.
class TrainingSettingsList extends ConsumerWidget {
  /// Creates the list.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider).value ?? const AppSettings();
    void update(AppSettings Function(AppSettings) change) =>
        unawaited(ref.read(settingsRepositoryProvider).update(change));
    String seconds(int ms) => l10n.secondsValue((ms / 1000).toStringAsFixed(1));
    return ListView(
      key: const Key('training-settings'),
      children: [
        ListTile(title: Text(l10n.wrongMoveBehaviour)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<WrongMoveMode>(
            key: const Key('wrong-move-mode'),
            segments: [
              ButtonSegment(
                value: WrongMoveMode.retry,
                label: Text(l10n.wrongMoveRetry),
              ),
              ButtonSegment(
                value: WrongMoveMode.restart,
                label: Text(l10n.wrongMoveRestart),
              ),
            ],
            selected: {s.wrongMoveMode},
            onSelectionChanged: (v) =>
                update((s) => s.copyWith(wrongMoveMode: v.single)),
          ),
        ),
        ListTile(title: Text(l10n.startFrom)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<bool>(
            key: const Key('start-from'),
            segments: [
              ButtonSegment(value: false, label: Text(l10n.startFromMove1)),
              ButtonSegment(value: true, label: Text(l10n.startFromBranch)),
            ],
            selected: {s.startFromBranchPoint},
            onSelectionChanged: (v) =>
                update((s) => s.copyWith(startFromBranchPoint: v.single)),
          ),
        ),
        ListTile(
          title: Text(l10n.autoAdvanceDelay),
          trailing: Text(seconds(s.autoAdvanceDelayMs)),
        ),
        Slider(
          key: const Key('auto-advance-delay'),
          value: s.autoAdvanceDelayMs.toDouble(),
          max: 5000,
          divisions: 10,
          label: seconds(s.autoAdvanceDelayMs),
          onChanged: (v) =>
              update((s) => s.copyWith(autoAdvanceDelayMs: v.round())),
        ),
        ListTile(
          title: Text(l10n.opponentDelay),
          trailing: Text(l10n.msValue('${s.opponentMoveDelayMs}')),
        ),
        Slider(
          key: const Key('opponent-delay'),
          value: s.opponentMoveDelayMs.toDouble(),
          max: 1500,
          divisions: 30,
          label: '${s.opponentMoveDelayMs}',
          onChanged: (v) =>
              update((s) => s.copyWith(opponentMoveDelayMs: v.round())),
        ),
        SwitchListTile(
          key: const Key('show-comments'),
          title: Text(l10n.showCommentsInDrills),
          value: s.showComments,
          onChanged: (v) => update((s) => s.copyWith(showComments: v)),
        ),
        SwitchListTile(
          key: const Key('show-comment-arrows'),
          title: Text(l10n.showCommentArrows),
          value: s.showCommentArrows,
          onChanged: (v) => update((s) => s.copyWith(showCommentArrows: v)),
        ),
      ],
    );
  }
}
