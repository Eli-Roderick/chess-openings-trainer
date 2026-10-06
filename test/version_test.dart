import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/version.dart';

void main() {
  test('appVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1)!;
    expect(version, '$appVersion+$appBuildNumber');
  });

  test('Stockfish tag matches engine/checksums.json', () {
    final checksums = File('engine/checksums.json').readAsStringSync();
    expect(checksums, contains('"tag": "$stockfishTag"'));
    expect(stockfishSourceUrl, endsWith(stockfishTag));
  });
}
