import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// A Stockfish executable and, on Windows, its CPU variant.
@immutable
final class EngineBinary {
  /// Creates it.
  const new(this.path, {this.variant});

  /// Absolute path.
  final String path;

  /// `avx2` or `sse41` on Windows; null elsewhere.
  final String? variant;

  @override
  bool operator ==(Object other) =>
      other is EngineBinary && other.path == path && other.variant == variant;

  @override
  int get hashCode => Object.hash(path, variant);

  @override
  String toString() => 'EngineBinary($path, $variant)';
}

/// Finds the Stockfish binary (docs/plan/05-engine.md §2).
final class BinaryLocator {
  /// Creates a locator; the defaults use the running process.
  new({
    TargetPlatform? platform,
    String? resolvedExecutable,
    String? currentDirectory,
    Future<String?> Function()? nativeLibraryDir,
    bool Function(String path)? exists,
  }) : _platform = platform ?? defaultTargetPlatform,
       _executable = resolvedExecutable ?? Platform.resolvedExecutable,
       _cwd = currentDirectory ?? Directory.current.path,
       _nativeLibraryDir = nativeLibraryDir ?? _channelNativeLibraryDir,
       _exists = exists ?? ((path) => File(path).existsSync());

  final TargetPlatform _platform;
  final String _executable;
  final String _cwd;
  final Future<String?> Function() _nativeLibraryDir;
  final bool Function(String) _exists;

  static Future<String?> _channelNativeLibraryDir() =>
      const MethodChannel('rt/native').invokeMethod<String>('nativeLibraryDir');

  /// Existing candidates in the order to try them: Android
  /// `<nativeLibraryDir>/libstockfish.so`; Windows `<exe dir>/engine/`
  /// avx2 then sse41; Linux `<exe dir>/engine/stockfish`, then
  /// `engine/linux/stockfish` in the working directory or a parent (dev).
  Future<List<EngineBinary>> candidates() async {
    final exeDir = p.dirname(_executable);
    final all = switch (_platform) {
      TargetPlatform.android => [
        if (await _nativeLibraryDir() case final dir?)
          EngineBinary(p.join(dir, 'libstockfish.so')),
      ],
      TargetPlatform.windows => [
        EngineBinary(
          p.join(exeDir, 'engine', 'stockfish-avx2.exe'),
          variant: 'avx2',
        ),
        EngineBinary(
          p.join(exeDir, 'engine', 'stockfish-sse41.exe'),
          variant: 'sse41',
        ),
      ],
      TargetPlatform.linux => [
        EngineBinary(p.join(exeDir, 'engine', 'stockfish')),
        for (final dir in _ancestors(_cwd))
          EngineBinary(p.join(dir, 'engine', 'linux', 'stockfish')),
      ],
      _ => const <EngineBinary>[],
    };
    return [
      for (final b in all)
        if (_exists(b.path)) b,
    ];
  }

  static Iterable<String> _ancestors(String dir) sync* {
    var d = p.normalize(p.absolute(dir));
    while (true) {
      yield d;
      final parent = p.dirname(d);
      if (parent == d) return;
      d = parent;
    }
  }
}
