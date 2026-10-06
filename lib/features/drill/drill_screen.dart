import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/app/shortcuts.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/diagnostics/drill_latency.dart';
import 'package:repertoire_trainer/core/engine/engine_judge.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/comment_panel.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/board/training_settings_list.dart';
import 'package:repertoire_trainer/features/drill/drill_controller.dart';
import 'package:repertoire_trainer/features/drill/drill_state.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// The drill screen (01-product-spec §7.2) in Random mode.
class DrillScreen extends ConsumerStatefulWidget {
  /// Drills repertoire [id].
  const new({required this.id, super.key});

  /// Repertoire id.
  final String id;

  @override
  ConsumerState<DrillScreen> createState() => _DrillScreenState();
}

class _Effects implements DrillEffects {
  new(this.sounds, this.haptics, this.board);

  final SoundService sounds;
  final HapticsService haptics;
  final RepertoireBoardController board;

  @override
  Future<void> flash(Square square) => board.flashError(square);

  @override
  void haptic(HapticKind kind) => switch (kind) {
    HapticKind.light => haptics.light(),
    HapticKind.medium => haptics.medium(),
  };

  @override
  void sound(SoundType type) => sounds.play(type);
}

class _DrillScreenState extends ConsumerState<DrillScreen> {
  final _board = RepertoireBoardController();
  DrillController? _controller;
  String? _error;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      // The controller outlives this widget's `ref` (an abandoned run is
      // stored after dispose), so it reads from the container.
      final container = ProviderScope.containerOf(context, listen: false);
      final repo = container.read(repertoireRepositoryProvider);
      final tree = await repo.loadTree(widget.id);
      final deviceId = await container.read(deviceIdProvider.future);
      if (!mounted) return;
      final judge = container.read(engineJudgeProvider);
      final controller = DrillController(
        tree: tree,
        repertoireId: widget.id,
        deps: DrillDeps(
          clock: container.read(clockProvider),
          rng: container.read(rngProvider),
          newId: container.read(idGeneratorProvider),
          deviceId: deviceId,
          settings: () =>
              container.read(settingsProvider).value ?? const AppSettings(),
          lineStats: () =>
              container.read(statsRepositoryProvider).lineStats(widget.id),
          recentStarted: () => container
              .read(runRepositoryProvider)
              .recentStartedLineKeys(widget.id, 3),
          recordRun: container.read(statsServiceProvider).recordRun,
          check: judge.checkComparable,
          effects: _Effects(
            container.read(soundServiceProvider),
            container.read(hapticsServiceProvider),
            _board,
          ),
          latency: DrillLatency.instance,
        ),
      );
      setState(() => _controller = controller);
      // Pre-warm the engine for comparable checks (05 §4).
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(container.read(engineServiceProvider).warmUp()),
      );
      await controller.start();
    } on Object catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    // A run in progress is stored as abandoned (01 §7.10).
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;
    final session = _controller?.state.session;
    if (session != null && session.linesCompleted > 0 && mounted) {
      await showModalBottomSheet<void>(
        context: context,
        builder: (context) => _SessionSummary(session: session),
      );
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.repertoire(widget.id));
    }
  }

  void _openSettings() => unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.8,
        child: TrainingSettingsList(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final title =
        ref
            .watch(repertoireSummariesProvider)
            .value
            ?.where((s) => s.id == widget.id)
            .firstOrNull
            ?.name ??
        l10n.trainTitle;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Text(l10n.loadError(_error!)),
        ),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Shortcuts(
        shortcuts: drillShortcuts,
        child: Actions(
          actions: {
            FlipBoardIntent: CallbackAction<FlipBoardIntent>(
              onInvoke: (_) => controller.flip(),
            ),
            HintIntent: CallbackAction<HintIntent>(
              onInvoke: (_) => controller.hint(),
            ),
            NextLineIntent: CallbackAction<NextLineIntent>(
              onInvoke: (_) => controller.nextLine(),
            ),
            LeaveIntent: CallbackAction<LeaveIntent>(onInvoke: (_) => _leave()),
          },
          child: Focus(
            autofocus: true,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _DrillView(
                title: title,
                state: controller.state,
                controller: controller,
                board: _board,
                onSettings: _openSettings,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrillView extends StatelessWidget {
  const new({
    required this.title,
    required this.state,
    required this.controller,
    required this.board,
    required this.onSettings,
  });

  final String title;
  final DrillState state;
  final DrillController controller;
  final RepertoireBoardController board;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.phase == DrillPhase.empty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(l10n.noTrainableLines)),
      );
    }
    final boardWidget = Stack(
      children: [
        RepertoireBoard(
          controller: board,
          state: state.board,
          onUserMove: (move, resolved, {required viaDrag}) =>
              controller.onUserMove(
                uci: resolved.uci,
                san: resolved.san,
                fenAfter: resolved.after.fen,
                viaDrag: viaDrag,
              ),
        ),
        // Restart mode: a quick fade over the reset board (01 §7.7).
        if (state.restarts > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('restart-${state.restarts}'),
                tween: Tween(begin: 0.6, end: 0),
                duration: const Duration(milliseconds: 200),
                builder: (context, v, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surface
                      .withValues(alpha: v),
                ),
              ),
            ),
          ),
      ],
    );
    final info = _InfoPanel(state: state, controller: controller);
    final bottom = state.endBar != null
        ? _EndBar(bar: state.endBar!, controller: controller)
        : _BottomBar(state: state, controller: controller);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: Text('$title · ${l10n.modeRandom}'),
        actions: [
          IconButton(
            key: const Key('flip-board'),
            tooltip: l10n.flipBoard,
            icon: const Icon(Icons.swap_vert),
            onPressed: controller.flip,
          ),
          IconButton(
            key: const Key('drill-settings'),
            tooltip: l10n.trainingSettings,
            icon: const Icon(Icons.tune),
            onPressed: onSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: AdaptiveLayout(
          phone: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(aspectRatio: 1, child: boardWidget),
              Expanded(child: info),
              bottom,
            ],
          ),
          wide: LayoutBuilder(
            builder: (context, c) {
              final side = c.maxHeight < c.maxWidth * 0.62
                  ? c.maxHeight
                  : c.maxWidth * 0.62;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(dimension: side, child: boardWidget),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: info),
                        const Divider(height: 1),
                        Expanded(flex: 2, child: _MoveLog(log: state.log)),
                        bottom,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const new({required this.state, required this.controller});

  final DrillState state;
  final DrillController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeholder = switch (state.phase) {
      DrillPhase.userToMove => l10n.yourMove,
      DrillPhase.opponentToMove => l10n.opponentToMove,
      _ => '',
    };
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.skippedSans.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      key: const Key('skipped-chip'),
                      label: Text(l10n.skippedToMove(state.startPly ~/ 2 + 1)),
                      onPressed: () => unawaited(
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(
                              formatSanMoves(state.skippedSans),
                              key: const Key('skipped-moves'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: CommentPanel(
                  node: state.comment,
                  placeholder: placeholder,
                ),
              ),
            ],
          ),
        ),
        if (state.banner case final banner?)
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: _Banner(banner: banner, onDismiss: controller.dismissBanner),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const new({required this.banner, required this.onDismiss});

  final DrillBanner banner;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (banner.kind) {
      BannerKind.comparable => l10n.comparableBanner,
      BannerKind.notRepertoire => l10n.notRepertoireMove,
    };
    final prefix = banner.sanPrefix;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      key: Key('banner-${banner.kind.name}'),
      color: banner.kind == BannerKind.comparable
          ? scheme.secondaryContainer
          : scheme.surfaceContainerHighest,
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onDismiss,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            prefix == null ? text : l10n.bannerWithMove(prefix, text),
            key: const Key('banner-text'),
          ),
        ),
      ),
    );
  }
}

String _accuracyText(AppLocalizations l10n, int graded, double credit) {
  if (graded == 0) return '';
  final shown = credit == credit.roundToDouble()
      ? credit.toInt().toString()
      : credit.toStringAsFixed(1);
  return l10n.runAccuracy(shown, graded, (100 * credit / graded).round());
}

class _BottomBar extends StatelessWidget {
  const new({required this.state, required this.controller});

  final DrillState state;
  final DrillController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canHint = state.phase == DrillPhase.userToMove && state.hintLevel < 2;
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            TextButton.icon(
              key: const Key('hint'),
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(state.hintLevel == 0 ? l10n.hint : l10n.showMove),
              onPressed: canHint ? controller.hint : null,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.userMovesTotal == 0
                        ? ''
                        : l10n.moveProgress(
                            (state.userMovesDone + 1).clamp(
                              1,
                              state.userMovesTotal,
                            ),
                            state.userMovesTotal,
                          ),
                    key: const Key('progress'),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    _accuracyText(l10n, state.graded, state.creditSum),
                    key: const Key('run-accuracy'),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            TextButton(
              key: const Key('skip-line'),
              onPressed: state.phase == DrillPhase.loading
                  ? null
                  : () => unawaited(controller.skipLine()),
              child: Text(l10n.skipLine),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndBar extends StatelessWidget {
  const new({required this.bar, required this.controller});

  final EndBarState bar;
  final DrillController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      key: const Key('end-bar'),
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => controller.cancelAutoAdvance(),
      child: Material(
        elevation: 4,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _accuracyText(l10n, bar.graded, bar.creditSum),
                  key: const Key('end-accuracy'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                key: const Key('next-line'),
                onPressed: () => unawaited(controller.nextLine()),
                icon: bar.counting && bar.autoAdvance > Duration.zero
                    ? SizedBox.square(
                        dimension: 18,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: bar.autoAdvance,
                          builder: (context, v, _) => CircularProgressIndicator(
                            key: const Key('countdown'),
                            value: v,
                            strokeWidth: 2.5,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.skip_next),
                label: Text(l10n.nextLine),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveLog extends StatelessWidget {
  const new({required this.log});

  final List<MoveLogEntry> log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const Key('move-log'),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final (i, e) in log.indexed)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: i == 0 || e.ply.isOdd
                        ? formatSanMoves([e.san], firstPly: e.ply)
                        : e.san,
                  ),
                  if (e.result case final r?)
                    TextSpan(
                      text: switch (r) {
                        GradeResult.correct => ' ✓',
                        GradeResult.comparable => ' ½',
                        GradeResult.wrong => ' ✗',
                        GradeResult.hint => ' ?',
                      },
                      style: TextStyle(
                        color: switch (r) {
                          GradeResult.correct => AppColors.info,
                          GradeResult.comparable => AppColors.warning,
                          GradeResult.wrong ||
                          GradeResult.hint => AppColors.error,
                        },
                      ),
                    ),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  const new({required this.session});

  final SessionStats session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accuracy = session.accuracy;
    return SafeArea(
      child: Padding(
        key: const Key('session-summary'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sessionSummary,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(l10n.linesCompleted(session.linesCompleted)),
            if (accuracy != null)
              Text(l10n.sessionAccuracy((accuracy * 100).round())),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('session-done'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}
