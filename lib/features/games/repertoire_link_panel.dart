import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/games/review_model.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// An opponent reply the repertoire does not cover, seen in stored games.
typedef Uncovered = ({TreeNode node, FreeMove move, int count});

/// Where one game meets the user's repertoire, with the record of every
/// stored game through the same position and the uncovered replies.
final class LinkData {
  /// Creates the data.
  const new({
    required this.repertoireId,
    required this.tree,
    required this.link,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.uncovered,
  });

  /// The repertoire the game follows longest.
  final String repertoireId;

  /// Its tree.
  final RepertoireTree tree;

  /// Where the game leaves it.
  final RepertoireLink link;

  /// Results of the user's stored games (same colour) that reached
  /// [link]'s position.
  final int wins;

  /// See [wins].
  final int draws;

  /// See [wins].
  final int losses;

  /// Opponent replies the repertoire misses, most frequent first (at most
  /// five).
  final List<Uncovered> uncovered;

  /// The first line through the link's position (null at the start).
  Line? get line {
    if (link.node.isRoot) return null;
    for (final l in tree.lines) {
      if (l.path.contains(link.node)) return l;
    }
    return null;
  }
}

List<String> _ucis(DbImportedGame g) =>
    g.ucis.isEmpty ? const [] : g.ucis.split(' ');

bool _reaches(TreeNode from, TreeNode target) {
  for (TreeNode? n = from; n != null; n = n.parent) {
    if (identical(n, target)) return true;
    if (n.ply < target.ply) return false;
  }
  return false;
}

FreeMove? _free(TreeNode node, String uci) {
  final move = parseUci(uci);
  if (move == null) return null;
  final r = resolveMove(positionFromFen(node.fen), move);
  return r == null ? null : FreeMove(uci: r.uci, san: r.san, fen: r.after.fen);
}

/// The repertoire link of a stored game (null without a repertoire of the
/// user's colour).
final FutureProviderFamily<LinkData?, String> repertoireLinkProvider =
    FutureProvider.autoDispose.family<LinkData?, String>((ref, id) async {
      final repo = ref.watch(gamesRepositoryProvider);
      final game = await repo.game(id);
      if (game == null) return null;
      final side = game.userWhite ? Side.white : Side.black;
      final summaries = await ref.watch(repertoireSummariesProvider.future);
      final trees = <String, RepertoireTree>{
        for (final s in summaries.where((s) => s.color == side))
          s.id: await ref.watch(repertoireTreeProvider(s.id).future),
      };
      final best = bestLink(trees.values, _ucis(game));
      if (best == null) return null;
      final (tree, link) = best;
      final games = (await repo.watchGames(game.username).first).where(
        (g) => g.userWhite == game.userWhite,
      );
      var wins = 0;
      var draws = 0;
      var losses = 0;
      final counts = <(int, String), int>{};
      for (final g in games) {
        final l = linkGame(tree, _ucis(g));
        if (_reaches(l.node, link.node)) {
          switch (g.result) {
            case 'win':
              wins++;
            case 'draw':
              draws++;
            default:
              losses++;
          }
        }
        if (l.leftBy == LeftBy.opponent) {
          final key = (l.node.id, l.played!);
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
      final ranked = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final uncovered = <Uncovered>[
        for (final e in ranked.take(5))
          if (_free(tree.node(e.key.$1), e.key.$2) case final FreeMove m)
            (node: tree.node(e.key.$1), move: m, count: e.value),
      ];
      return LinkData(
        repertoireId: trees.entries.firstWhere((e) => e.value == tree).key,
        tree: tree,
        link: link,
        wins: wins,
        draws: draws,
        losses: losses,
        uncovered: uncovered,
      );
    });

/// Bottom-sheet content: where the game left the repertoire, the record
/// through that position, drill and add actions, uncovered replies.
class RepertoireLinkPanel extends ConsumerWidget {
  /// Creates the panel for [gameId].
  const new({required this.gameId, super.key});

  /// Stored game id.
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(repertoireLinkProvider(gameId));
    if (!async.hasValue) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final data = async.value;
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.linkNoRepertoire, key: const Key('link-none')),
      );
    }
    final link = data.link;
    final node = link.node;
    final played = link.played == null ? null : _free(node, link.played!);
    final move = moveNumber(node.ply + 1);
    final status = switch (link.leftBy) {
      LeftBy.user => l10n.linkUserLeft(
        move,
        played?.san ?? '',
        link.expected.map((n) => n.san).join(', '),
      ),
      LeftBy.opponent => l10n.linkOpponentLeft(move, played?.san ?? ''),
      LeftBy.repertoireEnd => l10n.linkRepertoireEnd(move, played?.san ?? ''),
      LeftBy.gameEnd => l10n.linkGameEnd,
    };
    final line = data.line;

    final router = GoRouter.of(context);
    void addReply(TreeNode at, FreeMove reply) {
      Navigator.of(context).pop();
      unawaited(
        router.push(
          Routes.browse(data.repertoireId, node: at.id),
          extra: [reply],
        ),
      );
    }

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.repertoireLink, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(status, key: const Key('link-status')),
          const SizedBox(height: 4),
          Text(
            l10n.linkRecord(data.wins, data.draws, data.losses),
            key: const Key('link-record'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (line != null)
                FilledButton.tonal(
                  key: const Key('link-drill'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    unawaited(
                      router.push(
                        Routes.train(
                          data.repertoireId,
                          mode: RunMode.single.name,
                          line: line.key,
                        ),
                      ),
                    );
                  },
                  child: Text(l10n.drillThisLine),
                ),
              if (link.leftBy == LeftBy.opponent && played != null)
                OutlinedButton(
                  key: const Key('link-add'),
                  onPressed: () => addReply(node, played),
                  child: Text(l10n.addToRepertoire),
                ),
            ],
          ),
          if (data.uncovered.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.uncoveredReplies, style: theme.textTheme.titleSmall),
            for (final u in data.uncovered)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.uncoveredReply(
                    moveNumber(u.node.ply + 1),
                    u.move.san,
                    u.node.isRoot ? '-' : sanPath(u.node.path),
                    u.count,
                  ),
                ),
                trailing: const Icon(Icons.add),
                onTap: () => addReply(u.node, u.move),
              ),
          ],
        ],
      ),
    );
  }
}
