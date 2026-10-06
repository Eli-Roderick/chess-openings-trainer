import 'dart:async';

import 'package:chess_core/chess_core.dart' show formatSanMoves;
import 'package:chessground/chessground.dart' show PlayerSide;
import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// How a play-on game ended (01-product-spec §8.2).
enum PlayOnResult {
  /// The user mated the engine.
  userMates,

  /// The engine mated the user.
  engineMates,

  /// Stalemate.
  stalemate,

  /// The same position for the third time.
  threefold,

  /// 50 moves without a capture or pawn move.
  fiftyMoves,

  /// Neither side can mate.
  insufficientMaterial,
}

/// The repetition key of [fen]: placement, side to move, castling, en
/// passant.
String repetitionKey(String fen) => fen.split(' ').take(4).join(' ');

/// The game end in [position] (reached for the [repetitions]th time), or
/// null while the game goes on.
PlayOnResult? playOnResult(
  Position position, {
  required Side userSide,
  int repetitions = 1,
}) {
  if (position.isCheckmate) {
    return position.turn == userSide
        ? PlayOnResult.engineMates
        : PlayOnResult.userMates;
  }
  if (position.isStalemate) return PlayOnResult.stalemate;
  if (position.isInsufficientMaterial) {
    return PlayOnResult.insufficientMaterial;
  }
  if (repetitions >= 3) return PlayOnResult.threefold;
  if (position.halfmoves >= 100) return PlayOnResult.fiftyMoves;
  return null;
}

/// The engine's move for play-on: UCI or null (no move / engine failed).
typedef PlayOnEngine = Future<String?> Function(String fen);

/// Play-on moves from the app's engine at the "Play-on strength" setting
/// (05-engine §7); tests override it.
final playOnEngineProvider = Provider<PlayOnEngine>((ref) {
  final service = ref.watch(engineServiceProvider);
  return (fen) {
    final elo =
        (ref.read(settingsProvider).value ?? const AppSettings()).playOnElo;
    return service.playMove(fen, elo: elo == 0 ? null : elo);
  };
});

/// Play on vs engine (01-product-spec §8.2) from [args]. Nothing is
/// stored; leaving returns to the drill, which goes on with the next line.
class PlayOnScreen extends ConsumerStatefulWidget {
  /// Plays on from [args].
  const new({required this.args, super.key});

  /// Start position and sides.
  final PlayOnArgs args;

  @override
  ConsumerState<PlayOnScreen> createState() => _PlayOnState();
}

typedef _Ply = ({FreeMove move, bool user});

class _PlayOnState extends ConsumerState<PlayOnScreen> {
  final _plies = <_Ply>[];
  late Side _orientation = widget.args.orientation;
  bool _thinking = false;
  bool _engineFailed = false;
  PlayOnResult? _result;
  int _token = 0;

  /// Engine moves show no sooner than this after the user's move (05 §7).
  static const _minDelay = Duration(milliseconds: 300);

  Side get _user => widget.args.userSide;

  String get _fen => _plies.isEmpty ? widget.args.fen : _plies.last.move.fen;

  Position get _position => positionFromFen(_fen);

  int get _elo {
    final s = ref.read(settingsProvider).value ?? const AppSettings();
    return s.playOnElo;
  }

  @override
  void initState() {
    super.initState();
    _result = playOnResult(_position, userSide: _user);
    if (_result == null && _position.turn != _user) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_engineMove());
      });
    }
  }

  int _repetitions(String fen) {
    final key = repetitionKey(fen);
    final fens = [widget.args.fen, for (final p in _plies) p.move.fen];
    return fens.where((f) => repetitionKey(f) == key).length;
  }

  void _add(ResolvedMove m, {required bool user}) {
    _plies.add((
      move: FreeMove(uci: m.uci, san: m.san, fen: m.after.fen),
      user: user,
    ));
    ref.read(soundServiceProvider).play(SoundType.forSan(m.san));
    _result = playOnResult(
      m.after,
      userSide: _user,
      repetitions: _repetitions(m.after.fen),
    );
  }

  void _onUserMove(NormalMove move, ResolvedMove resolved) {
    if (_thinking || _result != null || _position.turn != _user) return;
    setState(() => _add(resolved, user: true));
    if (_result != null) {
      unawaited(_showResult());
    } else {
      unawaited(_engineMove());
    }
  }

  Future<String?> _ask(String fen) => ref.read(playOnEngineProvider)(fen);

  Future<void> _engineMove() async {
    final token = ++_token;
    final fen = _fen;
    final watch = Stopwatch()..start();
    setState(() {
      _thinking = true;
      _engineFailed = false;
    });
    String? uci;
    try {
      uci = await _ask(fen);
    } on Object {
      uci = null;
    }
    final left = _minDelay - watch.elapsed;
    if (left > Duration.zero) await Future<void>.delayed(left);
    if (!mounted || token != _token) return;
    final move = uci == null ? null : parseUci(uci);
    final resolved = move == null
        ? null
        : resolveMove(positionFromFen(fen), move);
    setState(() {
      _thinking = false;
      if (resolved == null) {
        _engineFailed = true;
      } else {
        _add(resolved, user: false);
      }
    });
    if (_result != null) unawaited(_showResult());
  }

  /// Ply number of the first move played here.
  int get _firstPly {
    final start = positionFromFen(widget.args.fen);
    return (start.fullmoves - 1) * 2 + (start.turn == Side.white ? 1 : 2);
  }

  bool get _canTakeBack => _plies.any((p) => p.user);

  /// Undoes the user's last move and the engine's reply (or the pending
  /// reply).
  void _takeBack() {
    if (!_canTakeBack) return;
    _token++;
    setState(() {
      _thinking = false;
      _engineFailed = false;
      if (!_plies.last.user) _plies.removeLast();
      _plies.removeLast();
      _result = null;
    });
  }

  Future<void> _showResult() async {
    final result = _result;
    if (result == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final back = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('play-on-result'),
        title: Text(_resultText(l10n, result)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.close),
          ),
          FilledButton(
            key: const Key('result-back'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.backToTraining),
          ),
        ],
      ),
    );
    if ((back ?? false) && mounted) context.pop();
  }

  String _resultText(AppLocalizations l10n, PlayOnResult r) => switch (r) {
    PlayOnResult.userMates => l10n.resultUserMates,
    PlayOnResult.engineMates => l10n.resultEngineMates,
    PlayOnResult.stalemate => l10n.resultStalemate,
    PlayOnResult.threefold => l10n.resultThreefold,
    PlayOnResult.fiftyMoves => l10n.resultFiftyMoves,
    PlayOnResult.insufficientMaterial => l10n.resultInsufficient,
  };

  String _strength(AppLocalizations l10n) => switch (_elo) {
    1500 => l10n.strengthClub,
    2000 => l10n.strengthStrong,
    0 => l10n.fullStrength,
    _ => l10n.strengthExpert,
  };

  void _analyse() {
    final args = widget.args;
    unawaited(
      context.push(
        Routes.browse(args.repertoireId, node: args.nodeId, analyse: true),
        extra: [...args.moves, for (final p in _plies) p.move],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final position = _position;
    final last = _plies.isNotEmpty
        ? _plies.last.move.uci
        : (widget.args.moves.isNotEmpty ? widget.args.moves.last.uci : null);
    final userTurn = position.turn == _user && _result == null && !_thinking;
    final status = switch (_result) {
      final r? => _resultText(l10n, r),
      null when _engineFailed => l10n.engineUnavailable,
      null when _thinking => l10n.engineThinking,
      null => position.turn == _user ? l10n.yourMove : l10n.engineThinking,
    };
    final board = RepertoireBoard(
      state: BoardViewState(
        fen: _fen,
        orientation: _orientation,
        movable: userTurn
            ? (_user == Side.white ? PlayerSide.white : PlayerSide.black)
            : PlayerSide.none,
        lastMove: last == null ? null : parseUci(last),
      ),
      onUserMove: (move, resolved, {required viaDrag}) =>
          _onUserMove(move, resolved),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: Text(l10n.playOnTitle(_strength(l10n))),
        actions: [
          IconButton(
            key: const Key('play-on-flip'),
            tooltip: l10n.flipBoard,
            icon: const Icon(Icons.swap_vert),
            onPressed: () =>
                setState(() => _orientation = _orientation.opposite),
          ),
          IconButton(
            key: const Key('play-on-analyse'),
            tooltip: l10n.analyse,
            icon: const Icon(Icons.insights),
            onPressed: _analyse,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > c.maxHeight;
            final side = wide ? c.maxHeight : c.maxWidth;
            final panel = Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    status,
                    key: const Key('play-on-status'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatSanMoves([
                      for (final p in _plies) p.move.san,
                    ], firstPly: _firstPly),
                    key: const Key('play-on-moves'),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('take-back'),
                        icon: const Icon(Icons.undo),
                        label: Text(l10n.takeBack),
                        onPressed: _canTakeBack ? _takeBack : null,
                      ),
                      FilledButton.icon(
                        key: const Key('back-to-training'),
                        icon: const Icon(Icons.flag_outlined),
                        label: Text(l10n.backToTraining),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ],
              ),
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox.square(dimension: side, child: board),
                      Expanded(child: panel),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox.square(dimension: side, child: board),
                      Expanded(child: panel),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
