import 'dart:async';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/errors/describe_error.dart';
import 'package:repertoire_trainer/core/import/import_runner.dart';

/// State of an import screen.
sealed class ImportState {
  const new();
}

/// Nothing running: the form is shown.
final class ImportIdle extends ImportState {
  /// Creates the state.
  const new();
}

/// Import in progress.
final class ImportRunning extends ImportState {
  /// Creates the state.
  const new(this.stage);

  /// Current stage.
  final ImportStage stage;
}

/// Import finished; the report is shown.
final class ImportDone extends ImportState {
  /// Creates the state.
  const new({required this.result, required this.text, required this.side});

  /// Result (tree null on errors).
  final ImportResult result;

  /// Decoded PGN text (null if rejected before decoding).
  final String? text;

  /// Colour the PGN was imported for.
  final Side side;
}

/// The import crashed (a bug, not a report error).
final class ImportFailed extends ImportState {
  /// Creates the state.
  const new(this.message);

  /// What happened.
  final String message;
}

/// Runs imports for the Create, Re-import and Validate screens
/// (01-product-spec §5): progress stages, cancel, report.
class ImportController extends Notifier<ImportState> {
  StreamSubscription<ImportProgress>? _sub;

  @override
  ImportState build() {
    ref.onDispose(() => _sub?.cancel());
    return const ImportIdle();
  }

  /// Imports [bytes] for [side]; a running import is cancelled first.
  void run(Uint8List bytes, Side side) {
    unawaited(_sub?.cancel());
    state = const ImportRunning(ImportStage.reading);
    _sub = ref
        .read(importRunnerProvider)(bytes, side)
        .listen(
          (p) => state = switch (p) {
            ImportStageReached(:final stage) => ImportRunning(stage),
            ImportFinished(:final result, :final text) => ImportDone(
              result: result,
              text: text,
              side: side,
            ),
          },
          onError: (Object e, StackTrace st) =>
              state = ImportFailed(reportError('Import failed', e, st)),
        );
  }

  /// Stops a running import (its result is ignored) or leaves the report.
  void reset() {
    unawaited(_sub?.cancel());
    _sub = null;
    state = const ImportIdle();
  }
}

/// One controller per open import screen.
final NotifierProvider<ImportController, ImportState> importControllerProvider =
    NotifierProvider.autoDispose<ImportController, ImportState>(
      ImportController.new,
    );
