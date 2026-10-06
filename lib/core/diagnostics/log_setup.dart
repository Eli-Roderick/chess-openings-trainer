import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:repertoire_trainer/core/diagnostics/rotating_file_sink.dart';

final Logger _log = Logger('app');

/// Configures logging: console in debug builds, rotating file sink in the app
/// support directory (`logs/`) in all builds.
Future<void> setupLogging() async {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  if (kDebugMode) {
    Logger.root.onRecord.listen((r) {
      developer.log(
        r.message,
        time: r.time,
        level: r.level.value,
        name: r.loggerName,
        error: r.error,
        stackTrace: r.stackTrace,
      );
    });
  }
  try {
    final support = await getApplicationSupportDirectory();
    final sink = RotatingFileSink(Directory(p.join(support.path, 'logs')));
    Logger.root.onRecord.listen(sink.write);
    _log.info('Logging to ${sink.directory.path}');
  } on Object catch (e, st) {
    _log.warning('File logging unavailable', e, st);
  }
}
