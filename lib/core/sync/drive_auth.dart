import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:repertoire_trainer/core/sync/drive_transport.dart';
import 'package:url_launcher/url_launcher.dart';

/// The only scope (docs/plan/06-sync.md §1).
const driveScope = 'https://www.googleapis.com/auth/drive.appdata';

/// OAuth client ids from `--dart-define-from-file=config/google_oauth.json`
/// (06 §5.3).
@immutable
final class OAuthConfig {
  /// Creates a config.
  const new({
    required this.androidServerClientId,
    required this.desktopClientId,
    required this.desktopClientSecret,
  });

  /// The build's config.
  static const fromEnvironment = OAuthConfig(
    androidServerClientId: String.fromEnvironment(
      'GOOGLE_ANDROID_SERVER_CLIENT_ID',
    ),
    desktopClientId: String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_ID'),
    desktopClientSecret: String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_SECRET'),
  );

  /// Web client id used as `serverClientId` on Android.
  final String androidServerClientId;

  /// Desktop (installed app) client id.
  final String desktopClientId;

  /// Desktop client secret (not confidential for installed apps).
  final String desktopClientSecret;

  bool _set(String v) => v.isNotEmpty && !v.startsWith('REPLACE_ME');

  /// Android can sign in.
  bool get android => _set(androidServerClientId);

  /// Windows / Linux can sign in.
  bool get desktop => _set(desktopClientId) && _set(desktopClientSecret);
}

/// Sign-in for Drive (06 §5).
abstract interface class DriveAuth {
  /// False when this build has no OAuth ids ("Sync is not configured").
  bool get isConfigured;

  /// Restores a session without user interaction; true if signed in.
  Future<bool> restore();

  /// Interactive sign-in (browser or account picker).
  Future<void> signIn();

  /// An authorized HTTP client; throws [SyncAuthExpired] when signed out.
  Future<http.Client> client();

  /// After a 401: get a fresh token silently; throws [SyncAuthExpired] if
  /// the user must sign in again.
  Future<void> refresh();

  /// Forgets the session.
  Future<void> signOut();
}

/// No OAuth ids in this build.
final class UnconfiguredDriveAuth implements DriveAuth {
  /// Creates it.
  const new();

  @override
  bool get isConfigured => false;

  @override
  Future<bool> restore() async => false;

  @override
  Future<void> signIn() async =>
      throw const SyncAuthExpired('sync is not configured');

  @override
  Future<http.Client> client() async =>
      throw const SyncAuthExpired('sync is not configured');

  @override
  Future<void> refresh() async =>
      throw const SyncAuthExpired('sync is not configured');

  @override
  Future<void> signOut() async {}
}

/// An access token with its expiry.
typedef DriveToken = ({String token, DateTime expiry});

/// What [AndroidDriveAuth] needs from `google_sign_in` (a fake in tests).
abstract interface class SignInBackend {
  /// `GoogleSignIn.instance.initialize`.
  Future<void> initialize(String serverClientId);

  /// Silent sign-in; true if an account is available.
  Future<bool> lightweight();

  /// Interactive sign-in.
  Future<void> authenticate();

  /// A token for [scopes]; with [prompt] the user may be asked.
  Future<String?> token(List<String> scopes, {required bool prompt});

  /// Signs out.
  Future<void> signOut();
}

/// `google_sign_in` 7.x (06 §5.1).
final class GoogleSignInBackend implements SignInBackend {
  /// Creates it.
  new();

  GoogleSignInAccount? _account;

  GoogleSignIn get _g => GoogleSignIn.instance;

  @override
  Future<void> initialize(String serverClientId) =>
      _g.initialize(serverClientId: serverClientId);

  @override
  Future<bool> lightweight() async {
    _account = await _g.attemptLightweightAuthentication();
    return _account != null;
  }

  @override
  Future<void> authenticate() async {
    _account = await _g.authenticate(scopeHint: const [driveScope]);
  }

  @override
  Future<String?> token(List<String> scopes, {required bool prompt}) async {
    final client = _account?.authorizationClient ?? _g.authorizationClient;
    final authz = prompt
        ? await client.authorizeScopes(scopes)
        : await client.authorizationForScopes(scopes);
    return authz?.accessToken;
  }

  @override
  Future<void> signOut() async {
    _account = null;
    await _g.signOut();
  }
}

/// Builds an HTTP client sending [token].
http.Client bearerClient(String token, DateTime expiry) =>
    auth.authenticatedClient(
      http.Client(),
      auth.AccessCredentials(
        auth.AccessToken('Bearer', token, expiry.toUtc()),
        null,
        const [driveScope],
      ),
      closeUnderlyingClient: true,
    );

/// Android: `google_sign_in` account, Drive token from its authorization
/// client (06 §5.1). Tokens are kept in memory only.
final class AndroidDriveAuth implements DriveAuth {
  /// Creates it.
  new({required this.config, required this.backend, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Client ids.
  final OAuthConfig config;

  /// The plugin.
  final SignInBackend backend;

  final DateTime Function() _now;
  bool _initialized = false;
  bool _signedIn = false;
  DriveToken? _token;

  /// Google access tokens live an hour; renew a little earlier.
  static const _life = Duration(minutes: 50);

  @override
  bool get isConfigured => config.android;

  Future<void> _init() async {
    if (_initialized) return;
    await backend.initialize(config.androidServerClientId);
    _initialized = true;
  }

  @override
  Future<bool> restore() async {
    if (!isConfigured) return false;
    await _init();
    return _signedIn = await backend.lightweight();
  }

  @override
  Future<void> signIn() async {
    await _init();
    await backend.authenticate();
    _signedIn = true;
    final t = await backend.token(const [driveScope], prompt: true);
    if (t == null) throw const SyncAuthExpired('Drive access refused');
    _token = (token: t, expiry: _now().add(_life));
  }

  @override
  Future<http.Client> client() async {
    final t = _token;
    if (t == null || !t.expiry.isAfter(_now())) await refresh();
    final fresh = _token!;
    return bearerClient(fresh.token, fresh.expiry);
  }

  @override
  Future<void> refresh() async {
    if (!_signedIn) throw const SyncAuthExpired('signed out');
    await _init();
    final t = await backend.token(const [driveScope], prompt: false);
    if (t == null) throw const SyncAuthExpired('sign in again');
    _token = (token: t, expiry: _now().add(_life));
  }

  @override
  Future<void> signOut() async {
    _token = null;
    _signedIn = false;
    await backend.signOut();
  }
}

/// Where desktop credentials are kept (a fake in tests).
abstract interface class SecretStore {
  /// The value of [key].
  Future<String?> read(String key);

  /// Stores [value].
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);
}

/// [SecretStore] on `flutter_secure_storage`.
final class SecureSecretStore implements SecretStore {
  /// Creates it.
  const new();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// The installed-app consent flow (a fake in tests): returns credentials.
typedef ConsentFlow = Future<auth.AccessCredentials> Function(
  auth.ClientId clientId,
);

/// googleapis_auth loopback flow in the system browser (06 §5.2).
Future<auth.AccessCredentials> browserConsent(auth.ClientId clientId) async {
  final client = await auth.clientViaUserConsent(clientId, const [
    driveScope,
  ], (url) => unawaited(launchUrl(Uri.parse(url))));
  final credentials = client.credentials;
  client.close();
  return credentials;
}

/// Builds the refreshing client (a fake in tests).
typedef RefreshingClientFactory = auth.AutoRefreshingAuthClient Function(
  auth.ClientId clientId,
  auth.AccessCredentials credentials,
);

/// Windows / Linux: credentials (with the refresh token) in secure storage,
/// an auto-refreshing client that saves refreshed credentials (06 §5.2).
final class DesktopDriveAuth implements DriveAuth {
  /// Creates it.
  new({
    required this.config,
    this.store = const SecureSecretStore(),
    this.consent = browserConsent,
    RefreshingClientFactory? clients,
  }) : _clients =
           clients ??
           ((id, c) => auth.autoRefreshingClient(id, c, http.Client()));

  /// Client ids.
  final OAuthConfig config;

  /// Credential storage.
  final SecretStore store;

  /// Sign-in flow.
  final ConsentFlow consent;

  final RefreshingClientFactory _clients;

  /// Storage key of the credentials JSON.
  static const credentialsKey = 'drive.credentials';

  auth.AutoRefreshingAuthClient? _client;
  StreamSubscription<auth.AccessCredentials>? _updates;

  auth.ClientId get _id =>
      auth.ClientId(config.desktopClientId, config.desktopClientSecret);

  @override
  bool get isConfigured => config.desktop;

  Future<void> _use(auth.AccessCredentials credentials) async {
    await _updates?.cancel();
    _client?.close();
    final client = _client = _clients(_id, credentials);
    _updates = client.credentialUpdates.listen(
      (c) => unawaited(store.write(credentialsKey, jsonEncode(c.toJson()))),
    );
  }

  @override
  Future<bool> restore() async {
    if (!isConfigured) return false;
    if (_client != null) return true;
    final text = await store.read(credentialsKey);
    if (text == null) return false;
    try {
      await _use(
        auth.AccessCredentials.fromJson(
          jsonDecode(text) as Map<String, dynamic>,
        ),
      );
      return true;
    } on Object {
      await store.delete(credentialsKey);
      return false;
    }
  }

  @override
  Future<void> signIn() async {
    final credentials = await consent(_id);
    await store.write(credentialsKey, jsonEncode(credentials.toJson()));
    await _use(credentials);
  }

  @override
  Future<http.Client> client() async {
    if (_client == null && !await restore()) {
      throw const SyncAuthExpired('signed out');
    }
    return _client!;
  }

  /// The client refreshes by itself; a 401 means the refresh token is gone.
  @override
  Future<void> refresh() async => throw const SyncAuthExpired('sign in again');

  @override
  Future<void> signOut() async {
    await _updates?.cancel();
    _updates = null;
    _client?.close();
    _client = null;
    await store.delete(credentialsKey);
  }
}
