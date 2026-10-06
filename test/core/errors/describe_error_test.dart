import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/errors/describe_error.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';

void main() {
  test('database errors: code and message, no SQL', () {
    expect(
      describeError(
        SqliteException(
          extendedResultCode: 2067,
          message: 'UNIQUE constraint failed: x.id',
          causingStatement: 'INSERT INTO x VALUES (1)',
        ),
      ),
      'database error 2067: UNIQUE constraint failed: x.id',
    );
  });

  test('file, sync, platform, format and state errors', () {
    expect(
      describeError(
        const FileSystemException(
          'Cannot open file',
          '/a/b.pgn',
          OSError('No such file or directory', 2),
        ),
      ),
      'Cannot open file: /a/b.pgn: No such file or directory',
    );
    expect(describeError(const SyncOffline('no network')), 'no network');
    expect(
      describeError(PlatformException(code: 'denied', message: 'Denied')),
      'Denied',
    );
    expect(describeError(PlatformException(code: 'denied')), 'denied');
    expect(describeError(const FormatException('bad header')), 'bad header');
    expect(describeError(StateError('closed')), 'closed');
  });

  test('long descriptions are cut', () {
    final d = describeError(Exception('x' * 500));
    expect(d.length, maxErrorLength);
    expect(d, endsWith('…'));
  });
}
