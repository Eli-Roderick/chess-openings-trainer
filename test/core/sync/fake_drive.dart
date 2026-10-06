import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';

/// An in-memory Drive app folder shared by simulated devices; computes
/// md5 like Drive. [onCall] may throw to simulate failures.
final class FakeDriveTransport implements DriveTransport {
  final files = <String, ({String name, Uint8List bytes})>{};
  final calls = <String>[];
  void Function(String op)? onCall;
  var _next = 0;

  void _call(String op) {
    calls.add(op);
    onCall?.call(op);
  }

  DriveFile _file(String id) {
    final f = files[id]!;
    return DriveFile(
      id: id,
      name: f.name,
      md5: md5.convert(f.bytes).toString(),
      size: f.bytes.length,
    );
  }

  @override
  Future<List<DriveFile>> list() async {
    _call('list');
    return [for (final id in files.keys) _file(id)];
  }

  @override
  Future<Uint8List> download(String id) async {
    _call('download');
    return files[id]!.bytes;
  }

  @override
  Future<DriveFile> create(String name, Uint8List bytes) async {
    _call('create');
    final id = 'f${++_next}';
    files[id] = (name: name, bytes: bytes);
    return _file(id);
  }

  @override
  Future<DriveFile> update(String id, Uint8List bytes) async {
    _call('update');
    files[id] = (name: files[id]!.name, bytes: bytes);
    return _file(id);
  }

  @override
  Future<int> deleteAll(String prefix) async {
    _call('deleteAll');
    final ids = [
      for (final e in files.entries)
        if (e.value.name.startsWith(prefix)) e.key,
    ];
    files.removeWhere((id, _) => ids.contains(id));
    return ids.length;
  }

  @override
  Future<String?> accountEmail() async => 'eli@example.com';

  /// Calls since the last [reset] that move data (downloads and uploads).
  int get transfers => calls
      .where((c) => c == 'download' || c == 'create' || c == 'update')
      .length;

  void reset() => calls.clear();
}
