import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;

/// Reads `test/fixtures/<name>` (tests run from the package root).
List<int> fixtureBytes(String name) =>
    io.File('test/fixtures/$name').readAsBytesSync();

/// Imports a fixture.
ImportResult importFixture(String name, {Side side = Side.white}) =>
    importPgnBytes(fixtureBytes(name), side);

/// Report codes of [r], in order.
List<String> codes(ImportResult r) => [
  for (final i in r.report.items) i.code.id,
];
