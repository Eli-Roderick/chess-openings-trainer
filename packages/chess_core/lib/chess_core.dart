/// Pure Dart chess logic for Repertoire Trainer: PGN import and export,
/// repertoire trees and lines, and the training rules (grading, accuracy,
/// pickers, weak pool, SRS, streak, stats derivation, re-import diff) and
/// the sync / backup records, codec and merge.
///
/// Imports nothing from Flutter or the app, and no `dart:io` (the app
/// supplies gzip to the codec).
library;

export 'src/games/played_game.dart';
export 'src/games/repertoire_link.dart';
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
export 'src/review/accuracy_fit.dart';
export 'src/review/book.dart';
export 'src/review/move_facts.dart'
    show MoveFacts, bestCapture, material, pvSacrifice, see;
export 'src/review/review.dart';
export 'src/review/win_chance.dart';
export 'src/sync/codec.dart';
export 'src/sync/merge.dart';
export 'src/sync/records.dart';
export 'src/training/accuracy.dart';
export 'src/training/attribution.dart';
export 'src/training/constants.dart';
export 'src/training/day_clock.dart';
export 'src/training/engine_judgement.dart';
export 'src/training/grading.dart';
export 'src/training/line_stats_deriver.dart';
export 'src/training/randomizer.dart';
export 'src/training/reimport_diff.dart';
export 'src/training/run.dart';
export 'src/training/srs.dart';
export 'src/training/streak.dart';
export 'src/training/weak_pool.dart';
export 'src/tree/branch_point.dart';
export 'src/tree/line.dart';
export 'src/tree/line_key.dart';
export 'src/tree/repertoire_tree.dart';
export 'src/tree/rows.dart';
export 'src/tree/san_path.dart';
export 'src/tree/tree_node.dart';
export 'src/util/clock.dart';
export 'src/util/rng.dart';
