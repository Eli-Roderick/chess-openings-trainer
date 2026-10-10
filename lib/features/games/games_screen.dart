import 'dart:async';

import 'package:chess_core/chess_core.dart' show minFitSamples;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/games/chess_com_client.dart';
import 'package:repertoire_trainer/features/games/game_analysis.dart';
import 'package:repertoire_trainer/features/games/games_service.dart';
import 'package:repertoire_trainer/features/games/scoring.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Game Review entry: a chess.com username, a fetch, the stored games.
/// Fetching needs internet; stored games are always listed.
class GamesScreen extends ConsumerStatefulWidget {
  /// Creates the screen; [onOpen] opens a game's review.
  const new({super.key, this.onOpen});

  /// Opens a game (null until review exists).
  final void Function(DbImportedGame game)? onOpen;

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  late final _field = TextEditingController(
    text: ref.read(settingsProvider).value?.chessComUsername ?? '',
  );
  late String? _username = ref.read(settingsProvider).value?.chessComUsername;
  bool _busy = false;
  bool _hasOlder = false;
  String? _message;
  final _selected = <String>{};

  @override
  void initState() {
    super.initState();
    final u = _username;
    if (u != null) unawaited(_checkOlder(u));
    unawaited(_rescoreIfStale());
  }

  Future<void> _rescoreIfStale() async {
    final current = await ref.read(scoringProvider.future);
    if (!mounted) return;
    final repo = ref.read(gamesRepositoryProvider);
    if (await rescoreIfStale(repo, current)) ref.invalidate(scoringProvider);
  }

  /// Refits the accuracy to chess.com's own and re-scores every game.
  Future<void> _calibrate() async {
    final l10n = AppLocalizations.of(context);
    final result = await rescoreGames(
      ref.read(gamesRepositoryProvider),
      await ref.read(scoringProvider.future),
      fit: true,
    );
    ref.invalidate(scoringProvider);
    final fit = result.fit;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calibrateTitle),
        content: Text(
          key: const Key('calibrate-result'),
          fit == null
              ? l10n.calibrateTooFew(minFitSamples)
              : l10n.calibrateDone(
                  fit.samples,
                  fit.decay.toStringAsFixed(4),
                  fit.meanError.toStringAsFixed(1),
                  fit.bias.toStringAsFixed(1),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _checkOlder(String u) async {
    final older = await ref.read(gamesServiceProvider).hasOlder(u);
    if (mounted) setState(() => _hasOlder = older);
  }

  String _describe(AppLocalizations l10n, Object e) => switch (e) {
    ChessComOffline() => l10n.needsInternet,
    ChessComNotFound() => l10n.userNotFound,
    ChessComRateLimited() => l10n.chessComBusy,
    ChessComHttpError(:final status) => l10n.chessComError(status),
    _ => '$e',
  };

  Future<void> _run(Future<int?> Function(GamesService s, String u) job) async {
    final l10n = AppLocalizations.of(context);
    final u = _field.text.trim();
    if (!usernamePattern.hasMatch(u)) {
      setState(() => _message = l10n.invalidUsername);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
      _username = u;
    });
    if (ref.read(settingsProvider).value?.chessComUsername != u) {
      unawaited(
        ref
            .read(settingsRepositoryProvider)
            .update((s) => s.copyWith(chessComUsername: u)),
      );
    }
    String? message;
    try {
      final added = await job(ref.read(gamesServiceProvider), u);
      message = added == null ? l10n.allGamesLoaded : l10n.newGames(added);
    } on ChessComFailure catch (e) {
      message = _describe(l10n, e);
      if (e is ChessComOffline) ref.invalidate(chessComReachableProvider);
    }
    await _checkOlder(u);
    if (mounted) {
      setState(() {
        _busy = false;
        _message = message;
      });
    }
  }

  void _toggle(String id) => setState(() {
    if (!_selected.remove(id)) _selected.add(id);
  });

  /// Reviews the selected games (newest first); [rerun] replaces results.
  void _reviewSelected(List<DbImportedGame> games, {required bool rerun}) {
    final picked = [
      for (final g in games)
        if (_selected.contains(g.id)) g,
    ];
    setState(_selected.clear);
    unawaited(ref.read(batchProvider.notifier).start(picked, rerun: rerun));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final online = ref.watch(chessComReachableProvider).value ?? true;
    final u = _username;
    final games = u == null
        ? const <DbImportedGame>[]
        : ref.watch(gamesProvider(u)).value ?? const <DbImportedGame>[];
    final canFetch = online && !_busy;
    final batch = ref.watch(batchProvider);
    final accuracy = ref.watch(gameAccuracyProvider).value ?? const {};
    final selecting = _selected.isNotEmpty;
    final idle = !batch.running;
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_selected.clear);
      },
      child: Scaffold(
        appBar: selecting
            ? AppBar(
                leading: IconButton(
                  key: const Key('selection-clear'),
                  tooltip: l10n.clearSelection,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(_selected.clear),
                ),
                title: Text(l10n.selectedCount(_selected.length)),
                actions: [
                  IconButton(
                    key: const Key('select-all'),
                    tooltip: l10n.selectAllGames,
                    icon: const Icon(Icons.select_all),
                    onPressed: () => setState(
                      () => _selected.addAll([for (final g in games) g.id]),
                    ),
                  ),
                  IconButton(
                    key: const Key('review-selected'),
                    tooltip: l10n.reviewSelected,
                    icon: const Icon(Icons.insights),
                    onPressed: idle
                        ? () => _reviewSelected(games, rerun: false)
                        : null,
                  ),
                  IconButton(
                    key: const Key('rerun-selected'),
                    tooltip: l10n.rerunSelected,
                    icon: const Icon(Icons.refresh),
                    onPressed: idle
                        ? () => _reviewSelected(games, rerun: true)
                        : null,
                  ),
                ],
              )
            : AppBar(
                title: Text(l10n.gameReview),
                actions: [
                  IconButton(
                    key: const Key('calibrate'),
                    tooltip: l10n.calibrateScores,
                    icon: const Icon(Icons.tune),
                    onPressed: games.isEmpty || batch.running
                        ? null
                        : () => unawaited(_calibrate()),
                  ),
                  IconButton(
                    key: const Key('analyse-recent'),
                    tooltip: l10n.analyseRecentGames,
                    icon: const Icon(Icons.insights),
                    onPressed: games.isEmpty || batch.running
                        ? null
                        : () => unawaited(
                            ref
                                .read(batchProvider.notifier)
                                .start(games.take(10).toList()),
                          ),
                  ),
                ],
              ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online)
              MaterialBanner(
                key: const Key('games-offline'),
                leading: const Icon(Icons.cloud_off),
                content: Text(l10n.gamesOffline),
                actions: [
                  TextButton(
                    onPressed: () => ref.invalidate(chessComReachableProvider),
                    child: Text(l10n.checkConnection),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('chesscom-username'),
                      controller: _field,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText: l10n.chessComUsername,
                        isDense: true,
                      ),
                      onSubmitted: canFetch
                          ? (_) => unawaited(_run((s, u) => s.refresh(u)))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: online ? '' : l10n.needsInternet,
                    child: FilledButton(
                      key: const Key('fetch-games'),
                      onPressed: canFetch
                          ? () => unawaited(_run((s, u) => s.refresh(u)))
                          : null,
                      child: Text(l10n.fetchGames),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                online
                    ? (_message ?? l10n.archiveDelayNote)
                    : l10n.needsInternet,
                key: const Key('games-message'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 4),
            if (_busy) const LinearProgressIndicator() else const Divider(),
            if (batch.running)
              _BatchBar(state: batch)
            else if (batch.stoppedForBattery)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.analysisStoppedBattery),
              ),
            Expanded(
              child: games.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noGamesYet,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      key: const Key('games-list'),
                      itemCount: games.length + (_hasOlder ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == games.length) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: OutlinedButton(
                                key: const Key('load-older'),
                                onPressed: canFetch
                                    ? () => unawaited(
                                        _run((s, u) => s.loadOlder(u)),
                                      )
                                    : null,
                                child: Text(l10n.loadOlderGames),
                              ),
                            ),
                          );
                        }
                        final g = games[i];
                        return GameTile(
                          game: g,
                          accuracy: accuracy[g.id],
                          selected: _selected.contains(g.id),
                          onLongPress: () => _toggle(g.id),
                          onTap: selecting
                              ? () => _toggle(g.id)
                              : widget.onOpen == null
                              ? null
                              : () => widget.onOpen!(g),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One stored game: result, opponent, time control, date, opening.
class GameTile extends StatelessWidget {
  /// Creates the tile.
  const new({
    required this.game,
    super.key,
    this.onTap,
    this.onLongPress,
    this.accuracy,
    this.selected = false,
  });

  /// The game.
  final DbImportedGame game;

  /// The user's accuracy once analysed.
  final double? accuracy;

  /// Opens it.
  final VoidCallback? onTap;

  /// Starts or extends a selection.
  final VoidCallback? onLongPress;

  /// Part of the current selection.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final g = game;
    final (label, color) = switch (g.result) {
      'win' => (l10n.resultWin, AppColors.success),
      'draw' => (l10n.resultDraw, AppColors.info),
      _ => (l10n.resultLoss, AppColors.error),
    };
    final opponent = g.userWhite ? g.blackName : g.whiteName;
    final rating = g.userWhite ? g.blackRating : g.whiteRating;
    final date = DateFormat.yMMMd().format(
      DateTime.fromMillisecondsSinceEpoch(g.endTime * 1000),
    );
    final tc = timeControlLabel(l10n, g.timeControl);
    final details = [
      '${timeClassLabel(l10n, g.timeClass)} $tc',
      date,
      ?g.opening,
    ].join(' · ');
    return ListTile(
      key: ValueKey('game-${g.id}'),
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      leading: selected
          ? const SizedBox.square(
              dimension: 32,
              child: Icon(Icons.check_circle, key: Key('game-selected')),
            )
          : Tooltip(
              message: label,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label.characters.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
      title: Text(l10n.gameOpponent(opponent, rating)),
      subtitle: Text(details, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accuracy case final a?)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Tooltip(
                message: l10n.gameAccuracy(a.toStringAsFixed(1)),
                child: Text(
                  a.toStringAsFixed(1),
                  key: ValueKey('accuracy-${g.id}'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          Tooltip(
            message: g.userWhite ? l10n.playedWhite : l10n.playedBlack,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: g.userWhite ? AppColors.whiteSide : AppColors.blackSide,
                border: Border.all(color: AppColors.info),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Batch progress with a Stop button.
class _BatchBar extends ConsumerWidget {
  const new({required this.state});

  final BatchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = state.progress;
    return Padding(
      key: const Key('batch-bar'),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.analysingGame(state.index + 1, state.total)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: p == null || p.total == 0 ? null : p.done / p.total,
                ),
              ],
            ),
          ),
          TextButton(
            key: const Key('stop-batch'),
            onPressed: () => unawaited(ref.read(batchProvider.notifier).stop()),
            child: Text(l10n.stopAnalysis),
          ),
        ],
      ),
    );
  }
}

/// "Blitz", "Rapid", ...
String timeClassLabel(AppLocalizations l10n, String timeClass) =>
    switch (timeClass) {
      'bullet' => l10n.timeClassBullet,
      'blitz' => l10n.timeClassBlitz,
      'rapid' => l10n.timeClassRapid,
      'daily' => l10n.timeClassDaily,
      _ => timeClass,
    };

/// chess.com's `180+2` as `3+2`, `600` as `10`, `1/86400` as "1 day per
/// move".
String timeControlLabel(AppLocalizations l10n, String tc) {
  final daily = RegExp(r'^1/(\d+)$').firstMatch(tc);
  if (daily != null) {
    return l10n.timeControlDays(int.parse(daily[1]!) ~/ 86400);
  }
  final m = RegExp(r'^(\d+)(?:\+(\d+))?$').firstMatch(tc);
  if (m == null) return tc;
  final base = int.parse(m[1]!);
  final minutes = base % 60 == 0
      ? '${base ~/ 60}'
      : (base / 60).toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return m[2] == null ? minutes : '$minutes+${m[2]}';
}
