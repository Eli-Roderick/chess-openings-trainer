import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/incoming_files.dart';

import '../app_harness.dart';

final class _Incoming implements IncomingFiles {
  PickedFile? initial;
  final controller = StreamController<PickedFile>.broadcast();

  @override
  Future<PickedFile?> initialFile() async => initial;

  @override
  Stream<PickedFile> get opened => controller.stream;
}

PickedFile _pgn(String name) => PickedFile(
  name: name,
  bytes: Uint8List.fromList(utf8.encode('1. e4 e5 2. Nf3 *')),
);

void main() {
  testWidgets('a file opened at start with no repertoire goes to Create, '
      'named after the file', (tester) async {
    final incoming = _Incoming()..initial = _pgn('Italian Game.pgn');
    final h = await AppHarness.pump(
      tester,
      overrides: [incomingFilesProvider.overrideWithValue(incoming)],
    );
    await h.settle();
    expect(find.text('Italian Game'), findsOneWidget);
    expect(find.text('Italian Game.pgn'), findsOneWidget);
  });

  testWidgets('with repertoires: new repertoire or re-import into one', (
    tester,
  ) async {
    final incoming = _Incoming();
    final h = await AppHarness.pump(
      tester,
      overrides: [incomingFilesProvider.overrideWithValue(incoming)],
    );
    final id = await h.create('Rep', '1. d4 d5 *');
    await h.settle();
    incoming.controller.add(_pgn('new.pgn'));
    await h.settle();
    expect(find.byKey(const Key('incoming-file')), findsOneWidget);
    expect(find.text('Re-import into Rep'), findsOneWidget);
    await tester.tap(find.byKey(Key('incoming-$id')));
    await h.settle();
    expect(find.text('new.pgn'), findsOneWidget);
    expect(find.byKey(const Key('incoming-file')), findsNothing);
  });
}
