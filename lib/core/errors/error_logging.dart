import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final _log = Logger('uncaught');

/// Sends uncaught framework and zone errors to the log (P13 task 7), then to
/// the handlers installed before (the test framework's in tests).
void installErrorLogging() {
  final flutterPrevious = FlutterError.onError;
  FlutterError.onError = (details) {
    _log.severe(details.exceptionAsString(), details.exception, details.stack);
    (flutterPrevious ?? FlutterError.presentError)(details);
  };
  final dispatcher = PlatformDispatcher.instance;
  final platformPrevious = dispatcher.onError;
  dispatcher.onError = (error, stack) {
    _log.severe('Uncaught error', error, stack);
    return platformPrevious?.call(error, stack) ?? true;
  };
}

/// Logs every provider failure (a failed query, stream or future) with the
/// provider's name; the screens show a short description.
final class ErrorLoggingObserver extends ProviderObserver {
  /// Creates the observer.
  const new();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _log.severe(
      'Provider ${context.provider.name ?? context.provider.runtimeType} '
      'failed',
      error,
      stackTrace,
    );
  }
}
