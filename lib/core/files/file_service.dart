import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// A file chosen by the user.
@immutable
final class PickedFile {
  /// Creates a picked file.
  const new({required this.name, required this.bytes});

  /// File name (no directory).
  final String name;

  /// Contents.
  final Uint8List bytes;
}

/// Open/save dialogs (Android SAF and Windows; no storage permission).
abstract interface class FileService {
  /// Lets the user choose a `.pgn` or `.txt` file; null if cancelled.
  Future<PickedFile?> pickPgn();

  /// Saves [text] (UTF-8) through a save dialog proposing [fileName];
  /// returns where it was saved, or null if cancelled. [extension] is `pgn`
  /// or `txt`.
  Future<String?> saveText({
    required String fileName,
    required String text,
    String extension = 'pgn',
  });

  /// Lets the user choose a backup file; null if cancelled.
  Future<PickedFile?> pickBackup();

  /// Saves backup [bytes] through a save dialog proposing [fileName];
  /// returns where it was saved, or null if cancelled.
  Future<String?> saveBackup({
    required String fileName,
    required Uint8List bytes,
  });
}

/// Backup file extension (docs/plan/06-sync.md §8).
const backupExtension = 'rtbackup';

/// [FileService] backed by `file_picker`.
final class PlatformFileService implements FileService {
  /// Creates the service.
  const new();

  @override
  Future<PickedFile?> pickPgn() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pgn', 'txt'],
    );
    if (file == null) return null;
    return PickedFile(name: file.name, bytes: await file.xFile.readAsBytes());
  }

  @override
  Future<String?> saveText({
    required String fileName,
    required String text,
    String extension = 'pgn',
  }) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(text)),
      mimeType: extension == 'pgn' ? 'application/x-chess-pgn' : 'text/plain',
      type: FileType.custom,
      allowedExtensions: [extension],
    );
    if (uri == null) return null;
    return uri.scheme == 'file' ? uri.toFilePath() : uri.pathSegments.last;
  }

  @override
  Future<PickedFile?> pickBackup() async {
    // Android's picker does not know the extension's MIME type: any file.
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    return PickedFile(name: file.name, bytes: await file.xFile.readAsBytes());
  }

  @override
  Future<String?> saveBackup({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/gzip',
      type: FileType.custom,
      allowedExtensions: const [backupExtension],
    );
    if (uri == null) return null;
    return uri.scheme == 'file' ? uri.toFilePath() : uri.pathSegments.last;
  }
}

/// A file name safe on Android and Windows: `<name>.pgn` without
/// characters those systems reject.
String pgnFileName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  return '${cleaned.isEmpty ? 'repertoire' : cleaned}.pgn';
}
