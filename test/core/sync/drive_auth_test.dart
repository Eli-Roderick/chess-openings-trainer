import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:repertoire_trainer/core/sync/drive_auth.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';

const _config = OAuthConfig(
  androidServerClientId: 'web.apps.googleusercontent.com',
  desktopClientId: 'desktop.apps.googleusercontent.com',
  desktopClientSecret: 'secret',
);

final class _Backend implements SignInBackend {
  final calls = <String>[];
  bool account = false;
  String? silentToken = 'silent';
  int tokens = 0;

  @override
  Future<void> initialize(String serverClientId) async =>
      calls.add('init $serverClientId');

  @override
  Future<bool> lightweight() async {
    calls.add('lightweight');
    return account;
  }

  @override
  Future<void> authenticate() async {
    calls.add('authenticate');
    account = true;
  }

  @override
  Future<String?> token(List<String> scopes, {required bool prompt}) async {
    calls.add('token ${prompt ? 'prompt' : 'silent'} ${scopes.single}');
    tokens++;
    return prompt ? 'granted' : silentToken;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    account = false;
  }
}

final class _Store implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

final class _Client extends http.BaseClient
    implements auth.AutoRefreshingAuthClient {
  new(this.credentials);

  @override
  final auth.AccessCredentials credentials;

  final updates = StreamController<auth.AccessCredentials>.broadcast();
  bool closed = false;

  @override
  Stream<auth.AccessCredentials> get credentialUpdates => updates.stream;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();

  @override
  void close() => closed = true;
}

auth.AccessCredentials _credentials(String token) => auth.AccessCredentials(
  auth.AccessToken('Bearer', token, DateTime.utc(2026, 10, 6, 13)),
  'refresh',
  const [driveScope],
);

void main() {
  test('config: placeholders and empty ids are not configured', () {
    expect((_config.android, _config.desktop), (true, true));
    const empty = OAuthConfig(
      androidServerClientId: '',
      desktopClientId: 'REPLACE_ME.apps.googleusercontent.com',
      desktopClientSecret: 'x',
    );
    expect((empty.android, empty.desktop), (false, false));
    expect(const UnconfiguredDriveAuth().isConfigured, isFalse);
    expect(
      const UnconfiguredDriveAuth().client(),
      throwsA(isA<SyncAuthExpired>()),
    );
  });

  group('Android', () {
    test('restore is silent; sign-in asks once for the Drive scope; the '
        'token is renewed silently after 50 min', () async {
      final backend = _Backend();
      var now = DateTime(2026, 10, 6, 12);
      final a = AndroidDriveAuth(
        config: _config,
        backend: backend,
        now: () => now,
      );
      expect(await a.restore(), isFalse);
      expect(backend.calls, [
        'init web.apps.googleusercontent.com',
        'lightweight',
      ]);
      await a.signIn();
      expect(backend.calls.sublist(2), [
        'authenticate',
        'token prompt $driveScope',
      ]);
      (await a.client()).close();
      expect(backend.tokens, 1);
      now = now.add(const Duration(minutes: 51));
      (await a.client()).close();
      expect(backend.calls.last, 'token silent $driveScope');
    });

    test('refresh without a silent token means signing in again', () async {
      final backend = _Backend()
        ..account = true
        ..silentToken = null;
      final a = AndroidDriveAuth(config: _config, backend: backend);
      expect(await a.restore(), isTrue);
      await expectLater(a.refresh(), throwsA(isA<SyncAuthExpired>()));
      await a.signOut();
      await expectLater(a.client(), throwsA(isA<SyncAuthExpired>()));
      expect(backend.calls.last, 'signOut');
    });
  });

  group('Desktop', () {
    test('sign-in stores the credentials; refreshed ones are saved; '
        'restore rebuilds the client; sign out forgets', () async {
      final store = _Store();
      final clients = <_Client>[];
      DesktopDriveAuth make() => DesktopDriveAuth(
        config: _config,
        store: store,
        consent: (id) async {
          expect(
            (id.identifier, id.secret),
            ('desktop.apps.googleusercontent.com', 'secret'),
          );
          return _credentials('first');
        },
        clients: (id, c) {
          final client = _Client(c);
          clients.add(client);
          return client;
        },
      );
      final d = make();
      expect(await d.restore(), isFalse);
      await expectLater(d.client(), throwsA(isA<SyncAuthExpired>()));
      await d.signIn();
      final stored = jsonDecode(
        store.values[DesktopDriveAuth.credentialsKey]!,
      ) as Map<String, dynamic>;
      expect(auth.AccessCredentials.fromJson(stored).accessToken.data, 'first');
      clients.last.updates.add(_credentials('refreshed'));
      await pumpEventQueue();
      expect(
        store.values[DesktopDriveAuth.credentialsKey],
        contains('refreshed'),
      );

      final again = make();
      expect(await again.restore(), isTrue);
      expect(
        (await again.client() as _Client).credentials.accessToken.data,
        'refreshed',
      );
      await expectLater(again.refresh(), throwsA(isA<SyncAuthExpired>()));
      await again.signOut();
      expect(clients.last.closed, isTrue);
      expect(store.values, isEmpty);
    });

    test('unreadable stored credentials are dropped', () async {
      final store = _Store()
        ..values[DesktopDriveAuth.credentialsKey] = '{broken';
      final d = DesktopDriveAuth(config: _config, store: store);
      expect(await d.restore(), isFalse);
      expect(store.values, isEmpty);
    });
  });
}
