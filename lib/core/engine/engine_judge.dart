import 'package:chess_core/chess_core.dart';
import 'package:chess_core/chess_core.dart'
    as core
    show deviationCandidates, judgeReply;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:uci_engine/uci_engine.dart';

/// Engine judgements used by training (docs/plan/04-algorithms.md §7):
/// `uci_engine` searches, chess_core decides (D-78).
final class EngineJudge {
  /// Creates the judge.
  new(this._service, this._settings);

  final EngineService _service;
  final AppSettings Function() _settings;

  Duration get _minTime => Duration(milliseconds: _settings().checkSearchMs);

  /// Centipawns of an engine score (mate per 04 §7.1).
  static int cpOf(EngineScore s) => scoreToCp(cp: s.cp, mate: s.mate);

  /// Whether [userUci] is comparable to the best of [accepted] in [fen]
  /// (one `searchmoves` search). Engine unavailable or a move missing from
  /// the result: not comparable, status `engineUnavailable`.
  Future<ComparableOutcome> checkComparable({
    required String fen,
    required String userUci,
    required List<String> accepted,
  }) async {
    final moves = {...accepted, userUci}.toList();
    try {
      final r = await _service.scoreMoves(fen, moves, minTime: _minTime);
      if (!moves.every(r.scores.containsKey)) {
        return const ComparableOutcome.unavailable();
      }
      final j = judgeComparable(
        scores: {for (final e in r.scores.entries) e.key: cpOf(e.value)},
        accepted: accepted,
        userMove: userUci,
        thresholdCp: _settings().comparableThresholdCp,
      );
      return ComparableOutcome(
        comparable: j.comparable,
        lossCp: j.lossCp,
        status: CheckStatus.ok,
      );
    } on EngineUnavailable {
      return const ComparableOutcome.unavailable();
    }
  }

  /// Deviation candidates in [fen] (opponent to move), excluding [book]
  /// moves (04 §7.2). Empty when the engine is unavailable.
  Future<List<PvMove>> deviationCandidates({
    required String fen,
    Set<String> book = const {},
    EngineCancelToken? cancel,
  }) async {
    try {
      final lines = await _service.topLines(fen, cancel: cancel);
      return core.deviationCandidates([
        for (final l in lines) (uci: l.move, scoreCp: cpOf(l.score)),
      ], repertoireMoves: book);
    } on EngineUnavailable {
      return const [];
    }
  }

  /// Judges the user's reply [replyUci] after a deviation (04 §7.3), with
  /// the best move it was measured against; null when the engine is
  /// unavailable.
  Future<({ReplyJudgement judgement, String bestUci})?> judgeReply({
    required String fen,
    required String replyUci,
  }) async {
    try {
      final best = await _service.bestLine(fen, minTime: _minTime);
      if (best == null) return null;
      final bestCp = cpOf(best.score);
      if (best.move == replyUci) {
        return (
          judgement: core.judgeReply(
            bestUci: best.move,
            bestCp: bestCp,
            replyUci: replyUci,
          ),
          bestUci: best.move,
        );
      }
      final r = await _service.scoreMoves(fen, [replyUci], minTime: _minTime);
      final reply = r.scores[replyUci];
      if (reply == null) return null;
      return (
        judgement: core.judgeReply(
          bestUci: best.move,
          bestCp: bestCp,
          replyUci: replyUci,
          replyCp: cpOf(reply),
        ),
        bestUci: best.move,
      );
    } on EngineUnavailable {
      return null;
    }
  }

  /// The engine's best move in [fen]; null when unavailable.
  Future<String?> bestMove(String fen) async {
    try {
      return (await _service.bestLine(fen, minTime: _minTime))?.move;
    } on EngineUnavailable {
      return null;
    }
  }
}

/// The judge on the app's engine and settings.
final engineJudgeProvider = Provider<EngineJudge>(
  (ref) => EngineJudge(
    ref.watch(engineServiceProvider),
    () => ref.read(settingsProvider).value ?? const AppSettings(),
  ),
);
