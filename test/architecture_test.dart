// Import-boundary and hygiene checks (docs/plan/02-architecture.md §2,
// docs/plan/10-testing-and-quality.md §4). Runs from the repository root.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final _importRe = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

Iterable<File> _dartFiles(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
}

Iterable<(File, int, String)> _imports(File f) sync* {
  final lines = f.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final m = _importRe.firstMatch(lines[i]);
    if (m != null) yield (f, i + 1, m.group(1)!);
  }
}

String _where(File f, int line) => '${p.relative(f.path)}:$line';

void main() {
  test('pure packages import no Flutter and no app code', () {
    final violations = <String>[];
    for (final pkg in Directory('packages').listSync().whereType<Directory>()) {
      for (final f in _dartFiles(p.join(pkg.path, 'lib'))) {
        for (final (file, line, uri) in _imports(f)) {
          if (uri.startsWith('package:flutter') ||
              uri.startsWith('dart:ui') ||
              uri.startsWith('package:repertoire_trainer')) {
            violations.add('${_where(file, line)} imports $uri');
          }
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('chess_core lib does not use dart:io', () {
    final violations = [
      for (final f in _dartFiles('packages/chess_core/lib'))
        for (final (file, line, uri) in _imports(f))
          if (uri == 'dart:io') '${_where(file, line)} imports dart:io',
    ];
    expect(violations, isEmpty);
  });

  test('package logic uses no real time or unseeded randomness outside '
      'util/ (inject Clock / Rng)', () {
    final banned = RegExp(r'DateTime\.now\(|\bRandom\(');
    final violations = <String>[];
    for (final pkg in Directory('packages').listSync().whereType<Directory>()) {
      for (final f in _dartFiles(p.join(pkg.path, 'lib'))) {
        if (p.split(f.path).contains('util')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final code = lines[i].split('//').first;
          if (banned.hasMatch(code)) violations.add(_where(f, i + 1));
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('features do not import other features (except features/board)', () {
    const prefix = 'package:repertoire_trainer/features/';
    final violations = <String>[];
    for (final f in _dartFiles('lib/features')) {
      final own = p.split(p.relative(f.path, from: 'lib/features')).first;
      for (final (file, line, uri) in _imports(f)) {
        String? target;
        if (uri.startsWith(prefix)) {
          target = uri.substring(prefix.length).split('/').first;
        } else if (!uri.contains(':')) {
          final resolved = p.normalize(p.join(p.dirname(f.path), uri));
          final rel = p.split(p.relative(resolved, from: 'lib/features'));
          if (rel.first != '..') target = rel.first;
        }
        if (target != null && target != own && target != 'board') {
          violations.add('${_where(file, line)} imports feature $target');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('no print( in lib or packages', () {
    final printRe = RegExp(r'(^|[^\w.])print\(');
    final violations = <String>[];
    for (final root in ['lib', 'packages']) {
      for (final f in _dartFiles(root)) {
        if (!f.path.contains('${p.separator}lib${p.separator}') &&
            root == 'packages') {
          continue;
        }
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (printRe.hasMatch(lines[i])) violations.add(_where(f, i + 1));
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('every TODO references an issue (#123)', () {
    final todoRe = RegExp(r'\bTODO\b');
    final issueRe = RegExp('#[0-9]+');
    final violations = <String>[];
    for (final root in [
      'lib',
      'packages',
      'test',
      'tool',
      'integration_test',
    ]) {
      for (final f in _dartFiles(root)) {
        if (f.path.endsWith('architecture_test.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (todoRe.hasMatch(lines[i]) && !issueRe.hasMatch(lines[i])) {
            violations.add(_where(f, i + 1));
          }
        }
      }
    }
    expect(violations, isEmpty);
  });
}
