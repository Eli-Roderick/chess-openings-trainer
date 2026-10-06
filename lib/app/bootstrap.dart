import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/app/app.dart';
import 'package:repertoire_trainer/app/version.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';
import 'package:repertoire_trainer/core/diagnostics/log_setup.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';

final _log = Logger('main');

/// Starts the app (docs/plan/02-architecture.md §5 rule 1): bindings,
/// `runApp`, and everything else after the first frame. Integration tests
/// pass [overrides] (temporary database, fake clock).
Future<void> bootstrap({List<Override> overrides = const []}) async {
  final timings = StartupTimings.instance..markMainStart();
  WidgetsFlutterBinding.ensureInitialized();
  // Console logging is ready synchronously; the file sink attaches in the
  // background so it never delays the first frame.
  unawaited(setupLogging());
  _registerLicenses();
  final container = ProviderContainer(overrides: overrides);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RepertoireTrainerApp(),
    ),
  );
  timings.markRunApp();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    timings.markFirstFrame();
    FrameStats.instance.start();
    unawaited(timings.loadProcessStart());
    // The database opens lazily when Home watches it; the device id is
    // created on first launch and the stats service starts listening.
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

void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Stockfish'],
      '''
Stockfish $stockfishTag is free software licensed under the GNU General Public
License version 3. Source code: $stockfishSourceUrl''',
    );
  });
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Inter font'],
      '''
Inter is licensed under the SIL Open Font License, Version 1.1
(assets/fonts/Inter-LICENSE.txt, https://github.com/rsms/inter).''',
    );
  });
}
