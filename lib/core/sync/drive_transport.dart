import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// A file in the Drive app folder.
@immutable
final class DriveFile {
  /// Creates it.
  const new({
    required this.id,
    required this.name,
    required this.md5,
    this.size,
    this.modifiedTime,
  });

  /// Drive file id.
  final String id;

  /// File name.
  final String name;

  /// MD5 of the content (hex).
  final String md5;

  /// Bytes.
  final int? size;

  /// Last change.
  final DateTime? modifiedTime;
}

/// Why a Drive call failed (docs/plan/06-sync.md §7).
sealed class SyncFailure implements Exception {
  const new(this.message);

  /// Details for logs and Diagnostics.
  final String message;

  @override
  String toString() => 'SyncFailure($message)';
}

/// No network, or a timeout.
final class SyncOffline extends SyncFailure {
  /// Creates it.
  const new(super.message);
}

/// The token was refused (401).
final class SyncAuthExpired extends SyncFailure {
  /// Creates it.
  const new(super.message);
}

/// Quota or rate limit (403 / 429).
final class SyncRateLimited extends SyncFailure {
  /// Creates it.
  const new(super.message);
}

/// Any other Drive error.
final class SyncServerError extends SyncFailure {
  /// Creates it.
  const new(super.message);
}

/// The Drive operations sync needs (P12 task 1), all in the app folder.
abstract interface class DriveTransport {
  /// Every file.
  Future<List<DriveFile>> list();

  /// The content of [id].
  Future<Uint8List> download(String id);

  /// Creates [name] with [bytes].
  Future<DriveFile> create(String name, Uint8List bytes);

  /// Replaces the content of [id].
  Future<DriveFile> update(String id, Uint8List bytes);

  /// Deletes every file whose name starts with [prefix]; returns how many.
  Future<int> deleteAll(String prefix);

  /// The signed-in account's e-mail address, if Drive tells.
  Future<String?> accountEmail();
}

/// [DriveTransport] on Drive v3 (`spaces: appDataFolder`).
final class GoogleDriveTransport implements DriveTransport {
  /// Uses [client], an authorized HTTP client.
  new(http.Client client) : _api = drive.DriveApi(client);

  final drive.DriveApi _api;

  static const _fields = 'id,name,md5Checksum,modifiedTime,size';

  DriveFile _of(drive.File f) => DriveFile(
    id: f.id!,
    name: f.name ?? '',
    md5: f.md5Checksum ?? '',
    size: int.tryParse(f.size ?? ''),
    modifiedTime: f.modifiedTime,
  );

  Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 60));
    } on drive.DetailedApiRequestError catch (e) {
      throw switch (e.status) {
        401 => SyncAuthExpired('${e.message}'),
        403 || 429 => SyncRateLimited('${e.message}'),
        _ => SyncServerError('${e.status} ${e.message}'),
      };
    } on SocketException catch (e) {
      throw SyncOffline(e.message);
    } on TimeoutException {
      throw const SyncOffline('timeout');
    } on http.ClientException catch (e) {
      throw SyncOffline(e.message);
    }
  }

  @override
  Future<List<DriveFile>> list() => _call(() async {
    final out = <DriveFile>[];
    String? page;
    do {
      final r = await _api.files.list(
        spaces: 'appDataFolder',
        pageSize: 1000,
        pageToken: page,
        $fields: 'nextPageToken,files($_fields)',
      );
      out.addAll((r.files ?? const []).map(_of));
      page = r.nextPageToken;
    } while (page != null);
    return out;
  });

  @override
  Future<Uint8List> download(String id) => _call(() async {
    final media = await _api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final builder = BytesBuilder(copy: false);
    await media.stream.forEach(builder.add);
    return builder.takeBytes();
  });

  drive.Media _media(Uint8List bytes) => drive.Media(
    Stream.value(bytes),
    bytes.length,
    contentType: 'application/gzip',
  );

  @override
  Future<DriveFile> create(String name, Uint8List bytes) => _call(
    () async => _of(
      await _api.files.create(
        drive.File(name: name, parents: ['appDataFolder']),
        uploadMedia: _media(bytes),
        $fields: _fields,
      ),
    ),
  );

  @override
  Future<DriveFile> update(String id, Uint8List bytes) => _call(
    () async => _of(
      await _api.files.update(
        drive.File(),
        id,
        uploadMedia: _media(bytes),
        $fields: _fields,
      ),
    ),
  );

  @override
  Future<int> deleteAll(String prefix) async {
    final files = await list();
    var n = 0;
    for (final f in files.where((f) => f.name.startsWith(prefix))) {
      await _call(() => _api.files.delete(f.id));
      n++;
    }
    return n;
  }

  @override
  Future<String?> accountEmail() => _call(
    () async =>
        (await _api.about.get($fields: 'user(emailAddress)'))
            .user
            ?.emailAddress,
  );
}
