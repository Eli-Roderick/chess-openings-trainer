import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/app/app.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/diagnostics/log_setup.dart';

final _log = Logger('main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Console logging is ready synchronously; the file sink attaches in the
  // background so it never delays the first frame.
  unawaited(setupLogging());
  final container = ProviderContainer();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RepertoireTrainerApp(),
    ),
  );
  // After the first frame (docs/plan/02-architecture.md §5): open the
  // database, create the device id on first launch and start re-deriving
  // stats when thresholds change.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    unawaited(
      container.read(deviceIdProvider.future).then(
        (id) {
          _log.info('Device $id');
          container.read(statsServiceProvider);
        },
        onError: (Object e, StackTrace st) =>
            _log.severe('Database start-up failed', e, st),
      ),
    );
  });
}
