import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/sync/drive_auth.dart';
import 'package:repertoire_trainer/core/sync/sync_controller.dart';

import '../app_harness.dart';
import '../core/sync/fake_drive.dart';

final class _Auth implements DriveAuth {
  bool signedIn = false;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> restore() async => signedIn;

  @override
  Future<void> signIn() async => signedIn = true;

  @override
  Future<http.Client> client() async => http.Client();

  @override
  Future<void> refresh() async {}

  @override
  Future<void> signOut() async => signedIn = false;
}

/// Pumps with real async work (isolates, database) until [finder] matches.
Future<void> _until(AppHarness h, Finder finder) async {
  for (var i = 0; i < 300; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await h.tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ].whereType<String>().join(' | ');
  throw TestFailure('Timed out waiting for $finder; screen: $texts');
}

void main() {
  testWidgets('not configured: says so', (tester) async {
    final h = await AppHarness.pump(tester);
    h.container.read(routerProvider).go(Routes.settingsSection('sync'));
    await _until(h, find.byKey(const Key('sync-unconfigured')));
    expect(find.text('Sync is not configured in this build.'), findsOneWidget);
  });

  testWidgets('turn on: signs in, syncs, shows the account and last sync; '
      'Home shows the icon; delete cloud data asks first; turn off', (
    tester,
  ) async {
    final drive = FakeDriveTransport();
    final auth = _Auth();
    final h = await AppHarness.pump(
      tester,
      size: const Size(400, 1000),
      overrides: [
        driveAuthProvider.overrideWithValue(auth),
        driveConnectorProvider.overrideWithValue(() async => drive),
      ],
    );
    await h.create('Rep', '1. e4 e5 2. Nf3 *');
    h.container.read(routerProvider).go(Routes.settingsSection('sync'));
    await _until(h, find.byKey(const Key('sync-toggle')));
    await tester.tap(find.byKey(const Key('sync-toggle')));
    await _until(h, find.textContaining('Last sync:'));
    expect(auth.signedIn, isTrue);
    expect(find.text('Signed in as eli@example.com'), findsOneWidget);
    expect(drive.files.values.map((f) => f.name), [startsWith('rt1-')]);
    expect(h.container.read(syncControllerProvider).enabled, isTrue);

    await tester.tap(find.byKey(const Key('delete-cloud')));
    await _until(h, find.byKey(const Key('confirm-delete-cloud')));
    await tester.tap(find.byKey(const Key('confirm-delete-cloud')));
    await _until(h, find.text('1 file deleted'));
    expect(drive.files, isEmpty);

    h.container.read(routerProvider).go(Routes.home);
    await _until(h, find.byKey(const Key('home-sync')));
    await tester.tap(find.byKey(const Key('home-sync')));
    await _until(h, find.byIcon(Icons.cloud_done));
    expect(drive.files, hasLength(1));

    h.container.read(routerProvider).go(Routes.settingsSection('sync'));
    await _until(h, find.byKey(const Key('sync-toggle')));
    await tester.tap(find.byKey(const Key('sync-toggle')));
    await _until(h, find.textContaining('Keeps repertoires'));
    expect(auth.signedIn, isFalse);
    expect(h.container.read(syncControllerProvider).enabled, isFalse);
  });
}
