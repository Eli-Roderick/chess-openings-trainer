import 'dart:convert';
import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/app.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/core/import/import_runner.dart';

/// Reads a chess_core fixture.
String fixture(String name) =>
    io.File('packages/chess_core/test/fixtures/$name').readAsStringSync();

/// A [FileService] that returns [picked] and records saves.
final class FakeFileService implements FileService {
  PickedFile? picked;
  final saved = <String, String>{};

  @override
  Future<PickedFile?> pickPgn() async => picked;

  @override
  Future<String?> saveText({
    required String fileName,
    required String text,
  }) async {
    saved[fileName] = text;
    return '/fake/$fileName';
  }
}

/// Records played sounds instead of playing them.
final class FakeSoundBackend implements SoundBackend {
  final played = <String>[];
  final loaded = <String>{};

  @override
  Future<void> load(Iterable<String> assets) async => loaded.addAll(assets);

  @override
  void play(String asset, double volume) => played.add(asset);
}

/// The real app on an in-memory database with deterministic time and ids,
/// in-process imports and fake file dialogs.
final class AppHarness {
  new _(
    this.tester,
    this.container,
    this.db,
    this.files,
    this.clipboard,
    this.sounds,
  );

  final WidgetTester tester;
  final ProviderContainer container;
  final AppDatabase db;
  final FakeFileService files;
  final List<String> clipboard;
  final FakeSoundBackend sounds;

  /// Pumps the app at [size] with [textScale].
  static Future<AppHarness> pump(
    WidgetTester tester, {
    Size size = const Size(400, 800),
    double textScale = 1,
    List<Override> overrides = const [],
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final clipboard = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    final db = AppDatabase.memory();
    final files = FakeFileService();
    final sounds = FakeSoundBackend();
    var id = 0;
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FakeClock(DateTime(2026, 10, 6, 12))),
        idGeneratorProvider.overrideWithValue(() => 'id-${++id}'),
        importRunnerProvider.overrideWithValue(inProcessImportRunner),
        fileServiceProvider.overrideWithValue(files),
        soundBackendProvider.overrideWithValue(sounds),
        demoPgnProvider.overrideWith(
          (ref) async => fixture('demo_italian_white.pgn'),
        ),
        ...overrides,
      ],
    );
    final h = AppHarness._(tester, container, db, files, clipboard, sounds);
    await container.read(soundServiceProvider).preload();
    addTearDown(h.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RepertoireTrainerApp(),
      ),
    );
    await h.settle();
    return h;
  }

  /// Lets database futures and streams complete, then settles animations.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// Creates a repertoire directly through the repository.
  Future<String> create(
    String name,
    String pgn, {
    Side side = Side.white,
  }) async {
    final id = await tester.runAsync(
      () => container
          .read(repertoireRepositoryProvider)
          .create(
            name: name,
            color: side,
            pgn: pgn,
            result: importPgn(pgn, side),
          ),
    );
    await settle();
    return id!;
  }

  /// A file the fake picker will return.
  void pickFile(String name, String text) => files.picked = PickedFile(
    name: name,
    bytes: Uint8List.fromList(utf8.encode(text)),
  );

  Future<void> dispose() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.runAsync(db.close);
  }
}
