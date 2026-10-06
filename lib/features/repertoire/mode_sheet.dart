import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Opens the mode sheet (01-product-spec §7.1) for [summary].
Future<void> showModeSheet(
  BuildContext context, {
  required RepertoireSummary summary,
  required int newAvailable,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => ModeSheet(summary: summary, newAvailable: newAvailable),
);

/// Mode, start-from and deviations, then Start.
class ModeSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const new({required this.summary, required this.newAvailable, super.key});

  /// The repertoire.
  final RepertoireSummary summary;

  /// SRS new lines still allowed today.
  final int newAvailable;

  @override
  ConsumerState<ModeSheet> createState() => _ModeSheetState();
}

class _ModeSheetState extends ConsumerState<ModeSheet> {
  late RunMode _mode = _initialMode();
  // The repertoire's own choice once trained, else the Training default.
  late bool _fromBranch = widget.summary.lastMode == null
      ? (ref.read(settingsProvider).value ?? const AppSettings())
            .startFromBranchPoint
      : widget.summary.startFromBranch;

  RunMode _initialMode() {
    final last = RunMode.values
        .where((m) => m.name == widget.summary.lastMode)
        .firstOrNull;
    if (last == null || last == RunMode.single) return RunMode.random;
    if (last == RunMode.weak && widget.summary.weakCount == 0) {
      return RunMode.random;
    }
    return last;
  }

  void _start() {
    final repo = ref.read(repertoireRepositoryProvider);
    final id = widget.summary.id;
    unawaited(repo.setTrainingPrefs(id, startFromBranch: _fromBranch));
    Navigator.of(context).pop();
    unawaited(
      context.push(Routes.train(id, mode: _mode.name, fromBranch: _fromBranch)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = widget.summary;
    final weakAvailable = s.weakCount > 0;
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('mode-sheet'),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: RadioGroup<RunMode>(
          groupValue: _mode,
          onChanged: (m) {
            if (m != null) setState(() => _mode = m);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.trainTitle)),
              RadioListTile<RunMode>(
                key: const Key('mode-random'),
                value: RunMode.random,
                title: Text(l10n.modeRandom),
                subtitle: Text(l10n.modeRandomHint),
              ),
              RadioListTile<RunMode>(
                key: const Key('mode-weak'),
                value: RunMode.weak,
                enabled: weakAvailable,
                title: Text(l10n.modeWeak),
                subtitle: Text(
                  weakAvailable
                      ? l10n.weakPoolSize(s.weakCount)
                      : l10n.weakPoolEmptyHint,
                ),
              ),
              RadioListTile<RunMode>(
                key: const Key('mode-srs'),
                value: RunMode.srs,
                title: Text(l10n.modeSrs),
                subtitle: Text(l10n.srsCounts(s.dueCount, widget.newAvailable)),
              ),
              const SizedBox(height: 8),
              ListTile(title: Text(l10n.startFrom)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<bool>(
                  key: const Key('sheet-start-from'),
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(l10n.startFromMove1),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(l10n.startFromBranch),
                    ),
                  ],
                  selected: {_fromBranch},
                  onSelectionChanged: (v) =>
                      setState(() => _fromBranch = v.single),
                ),
              ),
              // Opponent deviations arrive in P09.
              SwitchListTile(
                key: const Key('sheet-deviations'),
                value: false,
                onChanged: null,
                title: Text(l10n.opponentDeviations),
                subtitle: Text(l10n.arrivesLater),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton(
                  key: const Key('sheet-start'),
                  onPressed: _start,
                  child: Text(l10n.start),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
