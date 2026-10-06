import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A message from a running import.
sealed class ImportProgress {
  const new();
}

/// The import reached [stage].
final class ImportStageReached extends ImportProgress {
  /// Creates the message.
  const new(this.stage);

  /// The stage.
  final ImportStage stage;
}

/// The import finished.
final class ImportFinished extends ImportProgress {
  /// Creates the message.
  const new(this.result, this.text);

  /// The result.
  final ImportResult result;

  /// The decoded PGN text (stored as the repertoire's PGN), or null when the
  /// file was rejected before decoding (E-SIZE).
  final String? text;
}

/// Runs an import and streams its progress; cancelling the subscription
/// stops it.
typedef ImportRunner = Stream<ImportProgress> Function(
  Uint8List bytes,
  Side side,
);

/// Imports on a background isolate so the UI keeps its frames
/// (02-architecture §5 rule 3).
Stream<ImportProgress> isolateImportRunner(Uint8List bytes, Side side) {
  late StreamController<ImportProgress> controller;
  Isolate? isolate;
  final port = ReceivePort();
  controller = StreamController<ImportProgress>(
    onListen: () async {
      port.listen((message) {
        switch (message) {
          case final int stage:
            controller.add(ImportStageReached(ImportStage.values[stage]));
          case (final ImportResult result, final String? text):
            controller.add(ImportFinished(result, text));
            unawaited(controller.close());
            port.close();
          case [final Object error, final Object? stack]:
            controller.addError(
              error,
              StackTrace.fromString(stack?.toString() ?? ''),
            );
            unawaited(controller.close());
            port.close();
        }
      });
      isolate = await Isolate.spawn(_importWorker, (
        port.sendPort,
        bytes,
        side,
      ), onError: port.sendPort);
    },
    onCancel: () {
      isolate?.kill(priority: Isolate.immediate);
      port.close();
    },
  );
  return controller.stream;
}

void _importWorker((SendPort, Uint8List, Side) args) {
  final (port, bytes, side) = args;
  void stage(ImportStage s) => port.send(s.index);
  stage(ImportStage.reading);
  if (bytes.length > maxPgnBytes) {
    Isolate.exit(port, (importPgnBytes(bytes, side), null));
  }
  final text = decodePgnBytes(bytes);
  final result = importPgn(text, side, onStage: stage);
  Isolate.exit(port, (result, text));
}

/// Imports in the current isolate (widget tests).
Stream<ImportProgress> inProcessImportRunner(
  Uint8List bytes,
  Side side,
) async* {
  final stages = <ImportStage>[];
  if (bytes.length > maxPgnBytes) {
    yield ImportFinished(importPgnBytes(bytes, side), null);
    return;
  }
  final text = decodePgnBytes(bytes);
  final result = importPgn(text, side, onStage: stages.add);
  for (final s in stages) {
    yield ImportStageReached(s);
  }
  yield ImportFinished(result, text);
}

/// The runner used by the import screens; tests override it.
final importRunnerProvider = Provider<ImportRunner>(
  (ref) => isolateImportRunner,
);
