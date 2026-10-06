/// Pure Dart chess logic for Repertoire Trainer: PGN import and export,
/// repertoire trees and lines.
///
/// Imports nothing from Flutter or the app, and no `dart:io`.
library;

export 'src/pgn/board_shape.dart';
export 'src/pgn/comment_parser.dart'
    show
        CommentIssue,
        ParsedComment,
        collapseWhitespace,
        formatComment,
        maxFieldLength,
        parseComment,
        textTags;
export 'src/pgn/encoding.dart';
export 'src/pgn/move_comment.dart';
export 'src/pgn/pgn_exporter.dart';
export 'src/pgn/pgn_importer.dart';
export 'src/pgn/pgn_reader.dart';
export 'src/pgn/report.dart';
export 'src/pgn/synthetic_pgn.dart';
export 'src/tree/branch_point.dart';
export 'src/tree/line.dart';
export 'src/tree/line_key.dart';
export 'src/tree/repertoire_tree.dart';
export 'src/tree/rows.dart';
export 'src/tree/san_path.dart';
export 'src/tree/tree_node.dart';
