import 'dart:convert';
import 'dart:typed_data';

import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/core/import/import_runner.dart';

/// Installs the bundled demo repertoire through the normal import path
/// (01-product-spec §4); returns its id.
Future<String> installDemo(WidgetRef ref, {required String name}) async {
  final text = await ref.read(demoPgnProvider.future);
  final progress = ref.read(importRunnerProvider)(
    Uint8List.fromList(utf8.encode(text)),
    Side.white,
  );
  final done = await progress.whereType<ImportFinished>().first;
  if (done.result.tree == null) {
    throw StateError(done.result.report.toPlainText());
  }
  return await ref
      .read(repertoireRepositoryProvider)
      .create(
        name: name,
        color: Side.white,
        pgn: done.text!,
        result: done.result,
      );
}

/// Narrows a stream to events of type `T`.
extension on Stream<ImportProgress> {
  Stream<T> whereType<T extends ImportProgress>() =>
      where((e) => e is T).cast<T>();
}
