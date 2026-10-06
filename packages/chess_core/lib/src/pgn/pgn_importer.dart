import 'package:chess_core/src/pgn/comment_parser.dart';
import 'package:chess_core/src/pgn/encoding.dart';
import 'package:chess_core/src/pgn/move_comment.dart';
import 'package:chess_core/src/pgn/pgn_reader.dart';
import 'package:chess_core/src/pgn/report.dart';
import 'package:chess_core/src/tree/branch_point.dart';
import 'package:chess_core/src/tree/line.dart';
import 'package:chess_core/src/tree/line_key.dart';
import 'package:chess_core/src/tree/repertoire_tree.dart';
import 'package:chess_core/src/tree/san_path.dart';
import 'package:chess_core/src/tree/tree_node.dart';
import 'package:dartchess/dartchess.dart';
import 'package:meta/meta.dart';

/// Result of [importPgn].
@immutable
final class ImportResult {
  /// Creates a result.
  const new({required this.tree, required this.report, required this.elapsed});

  /// The merged tree, or null when [report] has errors.
  final RepertoireTree? tree;

  /// Findings and counts.
  final ImportReport report;

  /// Time the import took.
  final Duration elapsed;
}

/// Stages of an import, reported to [importPgn]'s `onStage` callback (the
/// import screen shows them; docs/plan/01-product-spec.md §5).
enum ImportStage {
  /// Decoding the file.
  reading,

  /// Reading the PGN syntax.
  parsing,

  /// Merging games and building lines.
  buildingLines,

  /// Parsing comments and building the report.
  checkingComments,
}

/// More lines than this get W-LARGE.
const largeLineCount = 5000;

/// Imports PGN file bytes (see [decodePgnBytes] for encodings).
ImportResult importPgnBytes(
  List<int> bytes,
  Side userSide, {
  void Function(ImportStage stage)? onStage,
}) {
  onStage?.call(ImportStage.reading);
  if (bytes.length > maxPgnBytes) {
    return ImportResult(
      tree: null,
      report: ImportReport(items: [ReportItem(ReportCode.size)]),
      elapsed: Duration.zero,
    );
  }
  return importPgn(decodePgnBytes(bytes), userSide, onStage: onStage);
}

/// Imports a PGN text as a repertoire for [userSide]
/// (docs/plan/07-comment-format.md §5).
///
/// All games are merged into one tree. The tree is null when the report has
/// errors. [onStage] is called as the import moves through its stages.
ImportResult importPgn(
  String text,
  Side userSide, {
  void Function(ImportStage stage)? onStage,
}) {
  final sw = Stopwatch()..start();
  if (exceedsPgnSize(text)) {
    return ImportResult(
      tree: null,
      report: ImportReport(items: [ReportItem(ReportCode.size)]),
      elapsed: sw.elapsed,
    );
  }
  final (tree, report) = _Importer(
    userSide,
    onStage ?? (_) {},
  ).run(normalizePgnText(text));
  return ImportResult(tree: tree, report: report, elapsed: sw.elapsed);
}

final class _BNode {
  new(this.parent, this.position, {required this.ply, this.san, this.uci});

  final _BNode? parent;
  final Position position;
  final int ply;
  final String? san;
  final String? uci;
  final List<_BNode> children = [];
  final Map<String, _BNode> byUci = {};
  int firstGame = 0;
  String? raw;
  int? rawGame;
  String? before;
  final List<int> nags = [];

  List<String> get sanPath {
    final out = <String>[];
    for (_BNode? n = this; n != null && n.parent != null; n = n.parent) {
      out.add(n.san!);
    }
    return out.reversed.toList();
  }
}

final class _Importer {
  new(this.userSide, this.onStage);

  final Side userSide;
  final void Function(ImportStage) onStage;
  final List<ReportItem> items = [];
  final Set<(_BNode, int)> _conflictsSeen = {};

  bool _isUser(int ply) => ply > 0 && ply.isOdd == (userSide == Side.white);

  (RepertoireTree?, ImportReport) run(String text) {
    onStage(ImportStage.parsing);
    final read = readPgn(text);
    for (final e in read.errors) {
      items.add(
        ReportItem(
          ReportCode.parseError,
          params: {
            'g': e.gameIndex + 1,
            'path': e.sanPath.isEmpty ? 'the start' : formatSanMoves(e.sanPath),
            'detail': e.detail,
          },
          nodePath: e.sanPath,
          gameIndex: e.gameIndex,
        ),
      );
    }

    onStage(ImportStage.buildingLines);
    final root = _BNode(null, Chess.initial, ply: 0);
    final headersByGame = <int, Map<String, String>>{};
    var merged = 0;
    for (final game in read.games) {
      headersByGame[game.index] = game.headers;
      if (!_startsFromInitial(game.headers)) {
        items.add(
          ReportItem(
            ReportCode.startError,
            params: {'g': game.index + 1},
            gameIndex: game.index,
          ),
        );
        continue;
      }
      merged++;
      _visit(game.root, root, game.index);
    }

    final description = read.games.isNotEmpty && read.games.first.index == 0
        ? _nullIfEmpty(
            collapseWhitespace(read.games.first.preComments.join(' ')),
          )
        : null;

    if (root.children.isEmpty &&
        !items.any((i) => i.level == ReportLevel.error)) {
      items.add(ReportItem(ReportCode.empty));
    }

    onStage(ImportStage.checkingComments);
    final tree = _finish(root, headersByGame, description);
    if (merged > 1) {
      items.add(ReportItem(ReportCode.merged, params: {'n': merged}));
    }

    final nodes = tree.nodes.skip(1);
    final report = ImportReport(
      items: items,
      games: read.gameCount,
      lines: tree.lines.length,
      userMoves: nodes.where((n) => n.isUserMove).length,
      opponentMoves: nodes.where((n) => !n.isUserMove).length,
      commentedUserMoves: nodes
          .where((n) => n.isUserMove && n.comment?.why != null)
          .length,
      maxDepth: nodes.fold(0, (m, n) => n.ply > m ? n.ply : m),
    );
    return (report.hasErrors ? null : tree, report);
  }

  static String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  static bool _startsFromInitial(Map<String, String> headers) {
    final variant = headers['Variant']?.trim().toLowerCase();
    if (variant != null &&
        variant.isNotEmpty &&
        variant != 'standard' &&
        variant != 'chess') {
      return false;
    }
    final fen = headers['FEN']?.trim();
    if (fen == null || fen.isEmpty) return true;
    final initial = Chess.initial.fen.split(' ').take(4).join(' ');
    return fen.split(RegExp(r'\s+')).take(4).join(' ') == initial;
  }

  String _gamePath(int game, List<String> sans) =>
      'Game ${game + 1}: ${formatSanMoves(sans)}';

  void _visit(RawMove raw, _BNode node, int game) {
    final seen = <String>{};
    for (final child in raw.children) {
      if (child.san == '--') {
        items.add(
          ReportItem(
            ReportCode.nullMove,
            params: {
              'path': _gamePath(game, [...node.sanPath, '--']),
            },
            nodePath: node.sanPath,
            gameIndex: game,
          ),
        );
        continue;
      }
      final move = node.position.parseSan(child.san);
      if (move == null) {
        items.add(
          ReportItem(
            ReportCode.illegalMove,
            params: {
              'san': child.san,
              'path': _gamePath(game, [...node.sanPath, '${child.san}??']),
            },
            nodePath: node.sanPath,
            gameIndex: game,
          ),
        );
        continue;
      }
      final (after, san) = node.position.makeSan(move);
      final uci = normalizeUci(move.uci, isCastling: san.startsWith('O-O'));
      var next = node.byUci[uci];
      if (next == null) {
        next = _BNode(node, after, ply: node.ply + 1, san: san, uci: uci)
          ..firstGame = game;
        node.children.add(next);
        node.byUci[uci] = next;
      } else if (seen.contains(uci)) {
        items.add(
          ReportItem(
            ReportCode.duplicateVariation,
            params: {'move': formatSanMoves(next.sanPath)},
            nodePath: next.sanPath,
            gameIndex: game,
          ),
        );
      }
      seen.add(uci);
      _mergeComment(next, child, game);
      if (child.beforeComments.isNotEmpty && next.before == null) {
        next.before = collapseWhitespace(child.beforeComments.join(' '));
      }
      for (final n in child.nags) {
        if (!next.nags.contains(n)) next.nags.add(n);
      }
      _visit(child, next, game);
    }
  }

  /// Keeps the first non-empty comment of a move. A later game's comment
  /// that parses differently is a W-CONFLICT; differences only in ignored
  /// tags (`%clk`, `%eval`, `%emt`) or whitespace are not.
  void _mergeComment(_BNode node, RawMove raw, int game) {
    if (raw.comments.isEmpty) return;
    final text = collapseWhitespace(raw.comments.join(' '));
    final existing = node.raw;
    final newParsed = _content(text);
    if (existing == null || (_content(existing) == null && newParsed != null)) {
      node
        ..raw = text
        ..rawGame = game;
      return;
    }
    if (newParsed == null ||
        newParsed == _content(existing) ||
        node.rawGame == game) {
      return;
    }
    if (_conflictsSeen.add((node, game))) {
      items.add(
        ReportItem(
          ReportCode.conflict,
          params: {
            'move': formatSanMoves(node.sanPath),
            'a': node.rawGame! + 1,
            'b': game + 1,
          },
          nodePath: node.sanPath,
          gameIndex: game,
        ),
      );
    }
  }

  static MoveComment? _content(String raw) =>
      parseComment(raw, isUserMove: false).comment;

  RepertoireTree _finish(
    _BNode broot,
    Map<int, Map<String, String>> headersByGame,
    String? description,
  ) {
    final nodes = <TreeNode>[];
    final firstGame = <int>[];
    var opponentComments = 0;
    var anyNags = false;

    TreeNode build(_BNode b, TreeNode? parent) {
      final isUser = _isUser(b.ply);
      var raw = b.raw;
      final path = b.sanPath;
      if (b.before != null) {
        if (isUser && (raw == null || raw.isEmpty)) {
          raw = b.before;
          items.add(_moveItem(ReportCode.commentBefore, path));
        } else {
          items.add(_moveItem(ReportCode.commentBeforeIgnored, path));
        }
      }
      final parsed = b.parent == null
          ? const ParsedComment(null, [])
          : parseComment(raw, isUserMove: isUser);
      if (isUser) {
        for (final issue in parsed.issues) {
          items.add(_moveItem(issue.code, path, issue.params));
        }
      } else if (raw != null && raw.isNotEmpty) {
        opponentComments++;
      }
      if (b.nags.isNotEmpty) anyNags = true;
      final node = TreeNode(
        id: nodes.length,
        parent: parent,
        ply: b.ply,
        san: b.san,
        uci: b.uci,
        fen: b.position.fen,
        isUserMove: isUser,
        comment: parsed.comment,
        rawComment: raw,
        nags: b.nags,
      );
      nodes.add(node);
      firstGame.add(b.firstGame);
      parent?.addChild(node);
      for (final c in b.children) {
        build(c, node);
      }
      return node;
    }

    final root = build(broot, null);

    final lines = <Line>[];
    final keys = <String, String>{};
    final endsOpp = <String>[];
    for (final leaf in nodes.where((n) => n.isLeaf && !n.isRoot)) {
      final path = leaf.path;
      final ucis = path.map((n) => n.uci).join(' ');
      final key = lineKey(ucis);
      final clash = keys[key];
      if (clash != null && clash != ucis) {
        items.add(ReportItem(ReportCode.keyCollision));
      }
      keys[key] = ucis;
      final line = Line(
        key: key,
        ucis: ucis,
        path: path,
        branchPly: branchPly(path),
        label: lineLabel(
          path,
          prefix: labelPrefix(headersByGame[firstGame[leaf.id]] ?? const {}),
        ),
        ordinal: lines.length,
      );
      lines.add(line);
      final text = sanPath(path);
      if (line.userMoveCount == 0) {
        items.add(
          ReportItem(
            ReportCode.noUserMove,
            params: {'path': text},
            nodePath: [for (final n in path) n.san!],
          ),
        );
      } else if (!leaf.isUserMove) {
        endsOpp.add(text);
      }
    }

    if (opponentComments > 0) {
      items.add(
        ReportItem(
          ReportCode.opponentComments,
          params: {'n': opponentComments},
        ),
      );
    }
    if (endsOpp.isNotEmpty) {
      items.add(
        ReportItem(
          ReportCode.endsWithOpponent,
          params: {'n': endsOpp.length},
          details: endsOpp,
        ),
      );
    }
    if (anyNags) items.add(ReportItem(ReportCode.nags));
    if (lines.length > largeLineCount) {
      items.add(ReportItem(ReportCode.large, params: {'n': lines.length}));
    }

    return RepertoireTree(
      root: root,
      userSide: userSide,
      nodes: nodes,
      lines: lines,
      description: description,
    );
  }

  ReportItem _moveItem(
    ReportCode code,
    List<String> path, [
    Map<String, Object> params = const {},
  ]) => ReportItem(
    code,
    params: {...params, 'move': formatSanMoves(path)},
    nodePath: path,
  );
}
