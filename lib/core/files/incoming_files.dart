import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';

final _log = Logger('IncomingFiles');

/// PGN files opened or shared from other apps (Android intents, P13).
abstract interface class IncomingFiles {
  /// The file the app was started with, if any (once).
  Future<PickedFile?> initialFile();

  /// Files opened while the app runs.
  Stream<PickedFile> get opened;
}

/// [IncomingFiles] over the `rt/intent` channel (MainActivity.kt).
final class ChannelIncomingFiles implements IncomingFiles {
  /// Listens on the channel.
  new() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'fileOpened') {
        final file = _fileOf(call.arguments);
        if (file != null) _opened.add(file);
      }
    });
  }

  static const _channel = MethodChannel('rt/intent');
  final _opened = StreamController<PickedFile>.broadcast();

  static PickedFile? _fileOf(Object? args) {
    if (args is! Map) return null;
    final name = args['name'];
    final bytes = args['bytes'];
    if (name is! String || bytes is! Uint8List) return null;
    return PickedFile(name: name, bytes: bytes);
  }

  @override
  Future<PickedFile?> initialFile() async {
    try {
      return _fileOf(await _channel.invokeMethod<Object?>('initialFile'));
    } on PlatformException catch (e) {
      _log.warning('No initial file', e);
      return null;
    }
  }

  @override
  Stream<PickedFile> get opened => _opened.stream;
}

/// No incoming files (desktop, tests).
final class NoIncomingFiles implements IncomingFiles {
  /// Creates it.
  const new();

  @override
  Future<PickedFile?> initialFile() async => null;

  @override
  Stream<PickedFile> get opened => const Stream.empty();
}

/// The platform's incoming files.
final incomingFilesProvider = Provider<IncomingFiles>(
  (ref) =>
      Platform.isAndroid ? ChannelIncomingFiles() : const NoIncomingFiles(),
);
