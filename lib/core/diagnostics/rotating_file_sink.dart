import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

/// Appends log records to `app.log`, rotating to `app.1.log` .. `app.N.log`
/// when the current file exceeds [maxBytes]. Keeps [maxFiles] files in total.
class RotatingFileSink {
  new(this.directory, {this.maxBytes = 1024 * 1024, this.maxFiles = 3}) {
    directory.createSync(recursive: true);
    _size = _current.existsSync() ? _current.lengthSync() : 0;
  }

  final Directory directory;
  final int maxBytes;
  final int maxFiles;
  late int _size;

  File get _current => File(p.join(directory.path, 'app.log'));

  File _rotated(int i) => File(p.join(directory.path, 'app.$i.log'));

  /// All log files, newest first.
  List<File> get files => [
    _current,
    for (var i = 1; i < maxFiles; i++) _rotated(i),
  ].where((f) => f.existsSync()).toList();

  void write(LogRecord r) {
    final buffer = StringBuffer()
      ..write(r.time.toIso8601String())
      ..write(' ')
      ..write(r.level.name)
      ..write(' ')
      ..write(r.loggerName)
      ..write(': ')
      ..writeln(r.message);
    if (r.error != null) buffer.writeln(r.error);
    if (r.stackTrace != null) buffer.writeln(r.stackTrace);
    final line = buffer.toString();
    if (_size + line.length > maxBytes && _size > 0) _rotate();
    _current.writeAsStringSync(line, mode: FileMode.append);
    _size += line.length;
  }

  void _rotate() {
    final oldest = _rotated(maxFiles - 1);
    if (oldest.existsSync()) oldest.deleteSync();
    for (var i = maxFiles - 2; i >= 1; i--) {
      final f = _rotated(i);
      if (f.existsSync()) f.renameSync(_rotated(i + 1).path);
    }
    if (_current.existsSync()) _current.renameSync(_rotated(1).path);
    _size = 0;
  }
}
