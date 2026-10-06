// Checks line coverage from `dart test --coverage=<dir>` output against a
// minimum, per source directory (docs/plan/10-testing-and-quality.md §1).
//
//   (cd packages/chess_core && dart test --coverage=coverage)
//   dart run tool/check_coverage.dart --package packages/chess_core \
//       --min 90 lib/src/pgn lib/src/tree
//
// Reads the VM coverage JSON files directly (no extra dependency). A line
// counts as covered if any test run hit it; generated files are skipped.
// Exit code 1 when a directory is below the minimum, 2 on usage errors.
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

void main(List<String> args) {
  String? package;
  var min = 90.0;
  final dirs = <String>[];
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--package' when i + 1 < args.length:
        package = args[++i];
      case '--min' when i + 1 < args.length:
        min = double.tryParse(args[++i]) ?? -1;
      default:
        dirs.add(args[i]);
    }
  }
  if (package == null || dirs.isEmpty || min < 0) {
    stderr.writeln(
      'Usage: dart run tool/check_coverage.dart --package <dir> '
      '[--min 90] <lib/src/...> ...',
    );
    exitCode = 2;
    return;
  }

  final name = RegExp(r'^name:\s*(\S+)', multiLine: true)
      .firstMatch(File(p.join(package, 'pubspec.yaml')).readAsStringSync())!
      .group(1)!;
  // source (relative to the package) -> line -> hit count
  final hits = <String, Map<int, int>>{};
  final covDir = Directory(p.join(package, 'coverage'));
  for (final f in covDir.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.json')) continue;
    final json = jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
    for (final entry
        in (json['coverage']! as List).cast<Map<String, Object?>>()) {
      final source = _relativeSource(entry['source']! as String, name, package);
      // Generated code (freezed, json_serializable, drift) is not ours.
      if (source == null ||
          source.endsWith('.g.dart') ||
          source.endsWith('.freezed.dart')) {
        continue;
      }
      final lines = hits.putIfAbsent(source, () => {});
      final list = (entry['hits']! as List).cast<int>();
      for (var k = 0; k + 1 < list.length; k += 2) {
        lines[list[k]] = (lines[list[k]] ?? 0) + list[k + 1];
      }
    }
  }

  var failed = false;
  for (final dir in dirs) {
    var total = 0;
    var covered = 0;
    final files = hits.keys.where((s) => p.isWithin(dir, s)).toList()..sort();
    for (final file in files) {
      final lines = hits[file]!;
      final c = lines.values.where((n) => n > 0).length;
      total += lines.length;
      covered += c;
      stdout.writeln(
        '  ${_pct(c, lines.length).padLeft(6)}  $file '
        '($c/${lines.length})',
      );
    }
    final pct = total == 0 ? 0.0 : 100 * covered / total;
    final ok = total > 0 && pct >= min;
    failed |= !ok;
    stdout.writeln(
      '${ok ? 'OK  ' : 'FAIL'} $dir: ${_pct(covered, total)} '
      '($covered/$total lines, minimum $min %)',
    );
  }
  if (failed) exitCode = 1;
}

String? _relativeSource(String source, String package, String root) {
  final prefix = 'package:$package/';
  if (source.startsWith(prefix)) {
    return p.join('lib', source.substring(prefix.length));
  }
  final uri = Uri.tryParse(source);
  if (uri == null || uri.scheme != 'file') return null;
  final abs = p.normalize(uri.toFilePath());
  final rootAbs = p.normalize(p.absolute(root));
  return p.isWithin(rootAbs, abs) ? p.relative(abs, from: rootAbs) : null;
}

String _pct(int covered, int total) =>
    total == 0 ? '-' : '${(100 * covered / total).toStringAsFixed(1)} %';
