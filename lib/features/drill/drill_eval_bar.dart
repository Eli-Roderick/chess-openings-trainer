import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/features/board/eval_bar.dart';
import 'package:uci_engine/uci_engine.dart';

/// Search time per drill position. Short and low priority: comparable
/// checks preempt it and an infinite search would starve deviation picks.
const drillEvalMovetime = Duration(milliseconds: 500);

/// Eval bar for the drill: one short low-priority search per position
/// ([EngineService.topLines], MultiPV 1), cancelled when the position
/// changes, cached per FEN so stepping back costs nothing. The bar keeps
/// the previous score while the next one is searched.
class DrillEvalBar extends ConsumerStatefulWidget {
  /// Creates the bar for [fen].
  const new({required this.fen, required this.whiteAtBottom, super.key});

  /// Position to evaluate.
  final String fen;

  /// Board orientation.
  final bool whiteAtBottom;

  @override
  ConsumerState<DrillEvalBar> createState() => _DrillEvalBarState();
}

class _DrillEvalBarState extends ConsumerState<DrillEvalBar> {
  static const _cacheSize = 128;

  /// Scores from White's point of view, oldest first.
  final _cache = <String, EngineScore>{};
  EngineCancelToken? _token;
  EngineScore? _score;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  @override
  void didUpdateWidget(DrillEvalBar old) {
    super.didUpdateWidget(old);
    if (old.fen != widget.fen) _evaluate();
  }

  @override
  void dispose() {
    _token?.cancel();
    super.dispose();
  }

  void _evaluate() {
    _token?.cancel();
    _token = null;
    final fen = widget.fen;
    final cached = _cache[fen];
    if (cached != null) {
      if (_score != cached) setState(() => _score = cached);
      return;
    }
    final token = _token = EngineCancelToken();
    unawaited(_search(fen, token));
  }

  Future<void> _search(String fen, EngineCancelToken token) async {
    try {
      final lines = await ref
          .read(engineServiceProvider)
          .topLines(
            fen,
            multiPv: 1,
            movetime: drillEvalMovetime,
            cancel: token,
          );
      final best = lines.firstOrNull;
      if (best == null) return;
      final score = whiteToMove(fen) ? best.score : best.score.negated;
      _cache[fen] = score;
      if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
      if (mounted && widget.fen == fen) setState(() => _score = score);
    } on EngineJobCancelled {
      // Position changed or the bar was hidden.
    } on EngineUnavailable {
      // The bar stays even; the screen hides it when the engine is gone.
    }
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: EvalBar(score: _score, whiteAtBottom: widget.whiteAtBottom),
  );
}
