import 'package:meta/meta.dart';

/// A move as written in a PGN game, before any legality check.
///
/// The game root is a sentinel with an empty [san] and no parent.
final class RawMove {
  /// Creates a move under [parent].
  new(this.san, this.parent);

  /// The SAN token as written, without annotation glyphs (`!`, `?`).
  /// `--` for a null move.
  final String san;

  /// The previous move, or null for the game root.
  final RawMove? parent;

  /// Comments after this move, in order.
  final List<String> comments = [];

  /// Comments at the start of a variation, before this (its first) move.
  final List<String> beforeComments = [];

  /// NAGs, including those written as `!`, `?`, `!!`, `??`, `!?`, `?!`.
  final List<int> nags = [];

  /// Following moves: the continuation first, then variations.
  final List<RawMove> children = [];

  /// Ply of this move (root 0).
  int get ply {
    var n = 0;
    for (var m = parent; m != null; m = m.parent) {
      n++;
    }
    return n;
  }

  /// SAN moves from the start to this move (empty for the root).
  List<String> get sanPath {
    final out = <String>[];
    for (RawMove? m = this; m != null && m.parent != null; m = m.parent) {
      out.add(m.san);
    }
    return out.reversed.toList();
  }
}

/// One game of a PGN file, syntactically valid.
final class RawGame {
  /// Creates an empty game.
  new(this.index);

  /// Zero-based position of the game in the file.
  final int index;

  /// Tag pairs.
  final Map<String, String> headers = {};

  /// Comments before the first move.
  final List<String> preComments = [];

  /// Sentinel root; its children are the first moves.
  final RawMove root = RawMove('', null);
}

/// A syntax error that made one game unreadable.
@immutable
final class PgnSyntaxError {
  /// Creates an error.
  const new(this.gameIndex, this.sanPath, this.detail);

  /// Zero-based game index.
  final int gameIndex;

  /// SAN path to the last move read before the error.
  final List<String> sanPath;

  /// What was wrong.
  final String detail;

  @override
  String toString() => 'PgnSyntaxError(game $gameIndex at $sanPath: $detail)';
}

/// Result of [readPgn].
@immutable
final class PgnReadResult {
  /// Creates a result.
  const new(this.games, this.errors);

  /// Games read without syntax errors, in file order.
  final List<RawGame> games;

  /// One entry per game that could not be read.
  final List<PgnSyntaxError> errors;

  /// Total number of games seen (readable or not).
  int get gameCount => games.length + errors.length;
}

/// Reads every game of a PGN text strictly.
///
/// Unlike dartchess's lenient parser, unknown tokens, unterminated comments
/// and unbalanced parentheses are reported (E-PARSE) instead of being skipped
/// (docs/DECISIONS.md D-36). Moves are not checked for legality here.
/// Expects `\n` line endings and no BOM (see `normalizePgnText`).
PgnReadResult readPgn(String text) => _Reader(text).read();

final class _Abort implements Exception {
  const new(this.detail);
  final String detail;
}

final class _Frame {
  new(this.cursor);
  RawMove cursor;
  RawMove? last;
  final List<String> pendingBefore = [];
}

final _sanRe = RegExp(
  '(?:O-O-O|O-O|0-0-0|0-0|[NBRQK][a-h]?[1-8]?x?[a-h][1-8]'
  '|[a-h]x?[a-h]?[1-8](?:=?[NBRQnbrq])?)[+#]?',
);
final _headerRe = RegExp(
  r'\[\s*([A-Za-z0-9_][A-Za-z0-9_+#=:-]*)\s+"((?:[^"\\]|\\.)*)"\s*\]',
);
final _moveNumberRe = RegExp(r'[0-9]+\s*(?:\.+|…)?');
final _nagDigitsRe = RegExp('[0-9]{1,3}');
final _escapeRe = RegExp(r'\\(.)');
final _tokenCharRe = RegExp('[A-Za-z0-9=_]');
final _tokenRe = RegExp(r'[^\s{}()\[\]]+');
const _glyphNags = {'!': 1, '?': 2, '!!': 3, '??': 4, '!?': 5, '?!': 6};
const _results = ['1/2-1/2', '1-0', '0-1', '*'];

final class _Reader {
  new(this.s);

  final String s;
  int i = 0;

  bool get _eof => i >= s.length;

  bool get _atLineStart => i == 0 || s.codeUnitAt(i - 1) == 0x0A;

  PgnReadResult read() {
    final games = <RawGame>[];
    final errors = <PgnSyntaxError>[];
    var index = 0;
    for (;;) {
      _skipSpace();
      if (_eof) break;
      final game = RawGame(index);
      final frames = [_Frame(game.root)];
      try {
        _readGame(game, frames);
        games.add(game);
      } on _Abort catch (e) {
        final last = frames.last.last ?? frames.first.last;
        errors.add(PgnSyntaxError(index, last?.sanPath ?? const [], e.detail));
        _skipToNextGame();
      }
      index++;
    }
    return PgnReadResult(games, errors);
  }

  /// Skips whitespace and `%` escape lines.
  void _skipSpace() {
    while (!_eof) {
      final c = s.codeUnitAt(i);
      if (c == 0x25 && _atLineStart) {
        final nl = s.indexOf('\n', i);
        i = nl == -1 ? s.length : nl + 1;
      } else if (c == 0x20 || c == 0x0A || c == 0x09 || c == 0x0D) {
        i++;
      } else {
        return;
      }
    }
  }

  void _skipToNextGame() {
    while (!_eof) {
      final nl = s.indexOf('\n[', i);
      if (nl == -1) {
        i = s.length;
        return;
      }
      i = nl + 1;
      if (i + 1 < s.length && _isLetter(s.codeUnitAt(i + 1))) return;
    }
  }

  static bool _isLetter(int c) =>
      (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);

  void _readGame(RawGame game, List<_Frame> frames) {
    // Tag pairs.
    for (;;) {
      _skipSpace();
      if (_eof || s[i] != '[') break;
      final m = _headerRe.matchAsPrefix(s, i);
      if (m == null) throw const _Abort('malformed tag pair');
      game.headers[m[1]!] = m[2]!.replaceAllMapped(_escapeRe, (e) => e[1]!);
      i = m.end;
    }
    // Movetext.
    for (;;) {
      _skipSpace();
      if (_eof) break;
      final frame = frames.last;
      final c = s[i];
      if (c == '[') {
        if (frames.length > 1) throw const _Abort('unclosed variation');
        if (_atLineStart) return; // next game without a result token
        throw const _Abort("unexpected '['");
      }
      final result = (c == '1' || c == '0' || c == '*')
          ? _results.where((r) => s.startsWith(r, i)).firstOrNull
          : null;
      if (result != null && !s.startsWith('0-0', i)) {
        i += result.length;
        if (frames.length > 1) throw const _Abort('result inside variation');
        return;
      }
      switch (c) {
        case '{':
          final end = s.indexOf('}', i + 1);
          if (end == -1) throw const _Abort('unterminated comment');
          _comment(game, frames, s.substring(i + 1, end));
          i = end + 1;
        case ';':
          final nl = s.indexOf('\n', i);
          final end = nl == -1 ? s.length : nl;
          _comment(game, frames, s.substring(i + 1, end));
          i = end;
        case '(':
          final last = frame.last;
          if (last == null) throw const _Abort('variation before any move');
          frames.add(_Frame(last.parent!));
          i++;
        case ')':
          if (frames.length == 1) throw const _Abort("unmatched ')'");
          frames.removeLast();
          i++;
        case r'$':
          final m = _nagDigitsRe.matchAsPrefix(s, i + 1);
          if (m == null) throw const _Abort(r'malformed NAG after $');
          frame.last?.nags.add(int.parse(m[0]!));
          i = m.end;
        case '!' || '?':
          i = _glyphs(frame);
        case '-':
          if (!s.startsWith('--', i)) throw _unexpected();
          _move(frame, '--');
          i += 2;
        default:
          final san = _sanRe.matchAsPrefix(s, i);
          if (san != null && _tokenEndsAt(san.end)) {
            _move(frame, san[0]!.replaceAll('0', 'O'));
            i = _glyphs(frame, from: san.end);
          } else if (s.startsWith('Z0', i)) {
            _move(frame, '--');
            i += 2;
          } else {
            final num = _moveNumberRe.matchAsPrefix(s, i);
            if (num == null) throw _unexpected();
            i = num.end;
          }
      }
    }
    if (frames.length > 1) throw const _Abort('unclosed variation');
  }

  /// True if a token ending at [end] is followed by a delimiter.
  bool _tokenEndsAt(int end) {
    if (end >= s.length) return true;
    return !_tokenCharRe.hasMatch(s[end]);
  }

  _Abort _unexpected() {
    final m = _tokenRe.matchAsPrefix(s, i);
    return _Abort("unexpected '${m?[0] ?? s[i]}'");
  }

  /// Reads `!`/`?` glyphs at [from] (default [i]) into NAGs of the last move.
  int _glyphs(_Frame frame, {int? from}) {
    var j = from ?? i;
    final start = j;
    while (j < s.length && (s[j] == '!' || s[j] == '?')) {
      j++;
    }
    if (j > start) {
      final nag = _glyphNags[s.substring(start, j)];
      if (nag == null) {
        throw _Abort("unknown annotation '${s.substring(start, j)}'");
      }
      frame.last?.nags.add(nag);
    }
    return j;
  }

  void _move(_Frame frame, String san) {
    final move = RawMove(san, frame.cursor);
    frame.cursor.children.add(move);
    move.beforeComments.addAll(frame.pendingBefore);
    frame
      ..pendingBefore.clear()
      ..cursor = move
      ..last = move;
  }

  void _comment(RawGame game, List<_Frame> frames, String text) {
    final frame = frames.last;
    final last = frame.last;
    if (last != null) {
      last.comments.add(text);
    } else if (frames.length == 1) {
      game.preComments.add(text);
    } else {
      frame.pendingBefore.add(text);
    }
  }
}
