// Downloads the pinned Stockfish release binaries listed in
// engine/checksums.json, verifies their SHA-256, extracts them and places them
// where the platform builds expect them (docs/plan/05-engine.md §1).
//
// Usage (from the repository root):
//   dart run tool/fetch_engines.dart --platform linux
//   dart run tool/fetch_engines.dart --platform android --platform windows
//   dart run tool/fetch_engines.dart --platform all [--force]
//
// Idempotent: a binary whose installed file already has the pinned hash is
// skipped. Downloaded archives are cached in engine/.cache/.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

const _platforms = {'android', 'windows', 'linux'};

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  if (options == null) {
    stderr.writeln(
      'Usage: dart run tool/fetch_engines.dart '
      '--platform <android|windows|linux|all> [--platform ...] [--force]',
    );
    exitCode = 64;
    return;
  }
  final root = _repoRoot();
  final manifest = jsonDecode(
    File(p.join(root, 'engine', 'checksums.json')).readAsStringSync(),
  ) as Map<String, dynamic>;
  final binaries = (manifest['binaries'] as List)
      .cast<Map<String, dynamic>>()
      .map(_Binary.fromJson)
      .where((b) => options.platforms.contains(b.platform))
      .toList();

  final client = HttpClient()
    ..findProxy = HttpClient.findProxyFromEnvironment
    ..connectionTimeout = const Duration(seconds: 30);
  try {
    for (final b in binaries) {
      await _install(b, root: root, client: client, force: options.force);
    }
  } on _FetchError catch (e) {
    stderr.writeln('fetch_engines: ${e.message}');
    exitCode = 1;
  } finally {
    client.close(force: true);
  }
}

class _Options {
  new(this.platforms, {required this.force});
  final Set<String> platforms;
  final bool force;
}

_Options? _parseArgs(List<String> args) {
  final platforms = <String>{};
  var force = false;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    String? value;
    if (a == '--platform' && i + 1 < args.length) {
      value = args[++i];
    } else if (a.startsWith('--platform=')) {
      value = a.substring('--platform='.length);
    } else if (a == '--force') {
      force = true;
      continue;
    } else {
      return null;
    }
    for (final v in value.split(',')) {
      if (v == 'all') {
        platforms.addAll(_platforms);
      } else if (_platforms.contains(v)) {
        platforms.add(v);
      } else {
        return null;
      }
    }
  }
  return platforms.isEmpty ? null : _Options(platforms, force: force);
}

class _Binary {
  new({
    required this.platform,
    required this.url,
    required this.sha256,
    required this.member,
    required this.binarySha256,
    required this.installPath,
  });

  factory fromJson(Map<String, dynamic> j) => _Binary(
    platform: j['platform'] as String,
    url: Uri.parse(j['url'] as String),
    sha256: j['sha256'] as String,
    member: j['member'] as String,
    binarySha256: j['binarySha256'] as String,
    installPath: j['installPath'] as String,
  );

  final String platform;
  final Uri url;
  final String sha256;
  final String member;
  final String binarySha256;
  final String installPath;

  String get archiveName => url.pathSegments.last;
}

class _FetchError implements Exception {
  new(this.message);
  final String message;
}

String _repoRoot() {
  var dir = File(Platform.script.toFilePath()).parent;
  while (!File(p.join(dir.path, 'engine', 'checksums.json')).existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      return Directory.current.path;
    }
    dir = parent;
  }
  return dir.path;
}

Future<String> _sha256Of(File f) async {
  final digest = await sha256.bind(f.openRead()).first;
  return digest.toString();
}

Future<void> _install(
  _Binary b, {
  required String root,
  required HttpClient client,
  required bool force,
}) async {
  final target = File(p.join(root, b.installPath));
  if (!force &&
      target.existsSync() &&
      await _sha256Of(target) == b.binarySha256) {
    print('ok       ${b.installPath} (hash matches, skipped)');
    return;
  }

  final cacheDir = Directory(p.join(root, 'engine', '.cache'))
    ..createSync(recursive: true);
  final archive = File(p.join(cacheDir.path, b.archiveName));
  if (force || !archive.existsSync() || await _sha256Of(archive) != b.sha256) {
    await _download(client, b.url, archive);
    final actual = await _sha256Of(archive);
    if (actual != b.sha256) {
      archive.deleteSync();
      throw _FetchError(
        'SHA-256 mismatch for ${b.archiveName}: '
        'expected ${b.sha256}, got $actual',
      );
    }
  }

  await _extractMember(archive, b.member, target);
  final binHash = await _sha256Of(target);
  if (binHash != b.binarySha256) {
    target.deleteSync();
    throw _FetchError(
      'SHA-256 mismatch for extracted ${b.member}: '
      'expected ${b.binarySha256}, got $binHash',
    );
  }
  if (!Platform.isWindows) {
    final r = await Process.run('chmod', ['755', target.path]);
    if (r.exitCode != 0) {
      throw _FetchError('chmod failed for ${target.path}: ${r.stderr}');
    }
  }
  print('install  ${b.installPath}');
}

Future<void> _download(HttpClient client, Uri url, File out) async {
  print('download $url');
  final partial = File('${out.path}.part');
  for (var attempt = 1; ; attempt++) {
    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('HTTP ${response.statusCode}', uri: url);
      }
      final sink = partial.openWrite();
      await response.pipe(sink);
      partial.renameSync(out.path);
      return;
    } on Exception catch (e) {
      if (partial.existsSync()) partial.deleteSync();
      if (attempt >= 4) throw _FetchError('download of $url failed: $e');
      final wait = Duration(seconds: 1 << attempt);
      stderr.writeln('retry    $url in ${wait.inSeconds}s ($e)');
      await Future<void>.delayed(wait);
    }
  }
}

Future<void> _extractMember(File archiveFile, String member, File out) async {
  final input = InputFileStream(archiveFile.path);
  try {
    final archive = archiveFile.path.endsWith('.zip')
        ? ZipDecoder().decodeStream(input)
        : TarDecoder().decodeStream(input);
    final entry = archive.files.where((f) => f.name == member).firstOrNull;
    if (entry == null) {
      throw _FetchError('${p.basename(archiveFile.path)} has no $member');
    }
    out.parent.createSync(recursive: true);
    final tmp = '${out.path}.tmp';
    final output = OutputFileStream(tmp);
    entry.writeContent(output);
    await output.close();
    if (out.existsSync()) out.deleteSync();
    File(tmp).renameSync(out.path);
  } finally {
    await input.close();
  }
}
