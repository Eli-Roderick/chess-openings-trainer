/// Pure Dart UCI engine client for Repertoire Trainer
/// (docs/plan/05-engine.md §4). Chess-agnostic: moves are UCI strings and
/// scores are raw engine scores; the app converts them.
library;

export 'src/engine.dart';
export 'src/parser.dart';
export 'src/service.dart';
export 'src/transport.dart';
