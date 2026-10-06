import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/app.dart';
import 'package:repertoire_trainer/core/diagnostics/log_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Console logging is ready synchronously; the file sink attaches in the
  // background so it never delays the first frame.
  unawaited(setupLogging());
  runApp(const ProviderScope(child: RepertoireTrainerApp()));
}
