import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Settings → Training (01-product-spec §10), the drill parts; also shown
/// as a sheet from the drill.
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
        SwitchListTile(
          key: const Key('show-line-summary'),
          title: Text(l10n.showLineSummary),
          value: s.showLineSummary,
          onChanged: (v) => update((s) => s.copyWith(showLineSummary: v)),
        ),
        const Divider(),
        // Opponent deviations (01 §8.1).
        SwitchListTile(
          key: const Key('deviations-enabled'),
          title: Text(l10n.opponentDeviations),
          value: s.deviationsEnabled,
          onChanged: (v) => update((s) => s.copyWith(deviationsEnabled: v)),
        ),
        ListTile(
          enabled: s.deviationsEnabled,
          title: Text(l10n.deviationChance),
          trailing: Text(l10n.percentValue(s.deviationChancePercent)),
        ),
        Slider(
          key: const Key('deviation-chance'),
          value: s.deviationChancePercent.toDouble(),
          max: 100,
          divisions: 20,
          label: l10n.percentValue(s.deviationChancePercent),
          onChanged: s.deviationsEnabled
              ? (v) =>
                    update((s) => s.copyWith(deviationChancePercent: v.round()))
              : null,
        ),
        ListTile(
          enabled: s.deviationsEnabled,
          title: Text(l10n.deviationTiming),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<DeviationTiming>(
            key: const Key('deviation-timing'),
            segments: [
              ButtonSegment(
                value: DeviationTiming.endOfLine,
                label: Text(l10n.timingEndOfLine),
              ),
              ButtonSegment(
                value: DeviationTiming.anywhere,
                label: Text(l10n.timingAnywhere),
              ),
            ],
            selected: {s.deviationTiming},
            onSelectionChanged: s.deviationsEnabled
                ? (v) => update((s) => s.copyWith(deviationTiming: v.single))
                : null,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        ListTile(
          title: Text(l10n.weakEnterBelow),
          trailing: Text(l10n.percentValue(s.weakEnterBelowPercent)),
        ),
        Slider(
          key: const Key('weak-enter-below'),
          value: s.weakEnterBelowPercent.toDouble(),
          min: 50,
          max: 95,
          divisions: 9,
          label: '${s.weakEnterBelowPercent} %',
          onChanged: (v) =>
              update((s) => s.copyWith(weakEnterBelowPercent: v.round())),
        ),
        ListTile(
          title: Text(l10n.weakExitAfter),
          trailing: Text('${s.weakExitCleanRuns}'),
        ),
        Slider(
          key: const Key('weak-exit-after'),
          value: s.weakExitCleanRuns.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '${s.weakExitCleanRuns}',
          onChanged: (v) =>
              update((s) => s.copyWith(weakExitCleanRuns: v.round())),
        ),
        const Divider(),
        ListTile(
          title: Text(l10n.srsNewPerDay),
          trailing: Text('${s.srsNewPerDay}'),
        ),
        Slider(
          key: const Key('srs-new-per-day'),
          value: s.srsNewPerDay.toDouble(),
          max: 100,
          divisions: 100,
          label: '${s.srsNewPerDay}',
          onChanged: (v) => update((s) => s.copyWith(srsNewPerDay: v.round())),
        ),
        ListTile(
          title: Text(l10n.srsMaxReviews),
          trailing: DropdownButton<int?>(
            key: const Key('srs-max-reviews'),
            value: s.srsMaxReviewsPerDay,
            onChanged: (v) => update((s) => s.copyWith(srsMaxReviewsPerDay: v)),
            items: [
              DropdownMenuItem(child: Text(l10n.unlimited)),
              for (final n in const [10, 20, 30, 50, 100, 200, 300, 500])
                DropdownMenuItem(value: n, child: Text('$n')),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.dayStartsAt),
          trailing: DropdownButton<int>(
            key: const Key('day-start'),
            value: s.dayStartHour,
            onChanged: (v) {
              if (v != null) update((s) => s.copyWith(dayStartHour: v));
            },
            items: [
              for (var h = 0; h <= 6; h++)
                DropdownMenuItem(
                  value: h,
                  child: Text('${h.toString().padLeft(2, '0')}:00'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
