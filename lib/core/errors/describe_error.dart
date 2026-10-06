import 'dart:io';

import 'package:drift/native.dart';
// Isolate-backed databases wrap their errors in DriftRemoteException.
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';

/// Longest description shown to the user; the full error is in the logs.
const maxErrorLength = 200;

/// A short, readable description of [error] for a message on screen
/// (P13 task 7): the cause without type names, stack traces or SQL.
String describeError(Object error) {
  final text = switch (error) {
    DriftRemoteException(:final remoteCause) => describeError(remoteCause),
    SqliteException(:final message, :final extendedResultCode) =>
      'database error $extendedResultCode: $message',
    FileSystemException(:final message, :final path, :final osError) => [
      message,
      ?path,
      ?osError?.message,
    ].where((s) => s.isNotEmpty).join(': '),
    SyncFailure(:final message) => message,
    PlatformException(:final message, :final code) => message ?? code,
    FormatException(:final message) => message,
    StateError(:final message) => message,
    _ => '$error',
  };
  final clean = text.trim();
  return clean.length <= maxErrorLength
      ? clean
      : '${clean.substring(0, maxErrorLength - 1)}…';
}

final _log = Logger('error');

/// Logs [error] as a failure of [what] and returns its description for the
/// screen.
String reportError(String what, Object error, [StackTrace? stack]) {
  _log.severe(what, error, stack);
  return describeError(error);
}
