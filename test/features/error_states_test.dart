import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/errors/error_logging.dart';

import '../app_harness.dart';

Future<void> _until(AppHarness h, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await h.tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

/// P13 task 7: a failing query shows a readable message, not a spinner
/// that never ends.
void main() {
  final message = find.text('Something went wrong: disk I/O error');

  for (final (name, location) in [
    ('Stats', Routes.stats),
    ('Line list', Routes.lineList),
    ('Line detail', (String id) => Routes.lineStats(id, 'k')),
  ]) {
    testWidgets('$name: a failing stats query', (tester) async {
      final h = await AppHarness.pump(
        tester,
        overrides: [
          lineStatsProvider.overrideWith(
            (ref, id) => Stream.error(StateError('disk I/O error')),
          ),
        ],
      );
      final id = await h.create('Rep', '1. e4 e5 *');
      h.container.read(routerProvider).go(location(id));
      await _until(h, message);
    });
  }

  test('provider failures are logged with the provider name', () async {
    final records = <LogRecord>[];
    final sub = Logger.root.onRecord.listen(records.add);
    addTearDown(sub.cancel);
    final failing = FutureProvider<int>(
      (ref) => throw StateError('boom'),
      name: 'failing',
    );
    final container = ProviderContainer(
      observers: const [ErrorLoggingObserver()],
    );
    addTearDown(container.dispose);
    await expectLater(container.read(failing.future), throwsStateError);
    expect(records.map((r) => r.message), contains('Provider failing failed'));
  });
}
