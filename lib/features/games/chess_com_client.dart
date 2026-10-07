import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/app/version.dart';

final _log = Logger('chesscom');

/// Why a chess.com request failed.
sealed class ChessComFailure implements Exception {
  const new();
}

/// No connection (DNS, socket or timeout).
final class ChessComOffline extends ChessComFailure {
  /// Creates the failure.
  const new();
}

/// The account does not exist (404).
final class ChessComNotFound extends ChessComFailure {
  /// Creates the failure.
  const new();
}

/// Still rate limited (429) after the retries.
final class ChessComRateLimited extends ChessComFailure {
  /// Creates the failure.
  const new();
}

/// Any other HTTP status.
final class ChessComHttpError extends ChessComFailure {
  /// Creates the failure for [status].
  const new(this.status);

  /// HTTP status.
  final int status;
}

/// A conditional GET's answer: [body] is null when not modified (304).
final class ChessComResponse {
  /// Creates the response.
  const new({this.body, this.etag, this.lastModified});

  /// Response text, or null on 304.
  final String? body;

  /// Validators for the next request.
  final String? etag;

  /// See [etag].
  final String? lastModified;

  /// The server said 304.
  bool get notModified => body == null;
}

/// The chess.com published-data API (the app's second network boundary
/// after sync, D-119): one request at a time (parallel requests get 429),
/// conditional requests with ETag / Last-Modified, a descriptive
/// User-Agent, and backoff on 429.
final class ChessComClient {
  /// Uses [_http]; the delay function waits between retries (tests).
  new(
    this._http, {
    this._delay = _wait,
    this.timeout = const Duration(seconds: 20),
  });

  final http.Client _http;
  final Future<void> Function(Duration) _delay;

  /// Per-request timeout.
  final Duration timeout;

  Future<void> _tail = Future.value();

  static Future<void> _wait(Duration d) => Future.delayed(d);

  /// API root.
  static const base = 'https://api.chess.com/pub/player';

  /// User-Agent with a contact point, as chess.com asks.
  static const userAgent =
      'RepertoireTrainer/$appVersion (+$sourceRepositoryUrl)';

  /// The archive list of [username].
  static Uri archivesUri(String username) =>
      Uri.parse('$base/${username.toLowerCase()}/games/archives');

  /// The games of [username] in [month] (`YYYY/MM`).
  static Uri monthUri(String username, String month) =>
      Uri.parse('$base/${username.toLowerCase()}/games/$month');

  /// GETs [uri], serialized behind every earlier request.
  Future<ChessComResponse> get(Uri uri, {String? etag, String? lastModified}) {
    final result = _tail.then(
      (_) => _get(uri, etag: etag, lastModified: lastModified),
    );
    _tail = result.then((_) {}, onError: (Object _) {});
    return result;
  }

  Future<ChessComResponse> _get(
    Uri uri, {
    String? etag,
    String? lastModified,
  }) async {
    final headers = {
      'User-Agent': userAgent,
      'Accept': 'application/json',
      'If-None-Match': ?etag,
      'If-Modified-Since': ?lastModified,
    };
    for (var attempt = 0; ; attempt++) {
      final http.Response r;
      try {
        r = await _http.get(uri, headers: headers).timeout(timeout);
      } on SocketException {
        throw const ChessComOffline();
      } on http.ClientException {
        throw const ChessComOffline();
      } on TimeoutException {
        throw const ChessComOffline();
      }
      switch (r.statusCode) {
        case 200:
          return ChessComResponse(
            body: r.body,
            etag: r.headers['etag'],
            lastModified: r.headers['last-modified'],
          );
        case 304:
          return ChessComResponse(etag: etag, lastModified: lastModified);
        case 404 || 410:
          throw const ChessComNotFound();
        case 429 when attempt < 3:
          final after = int.tryParse(r.headers['retry-after'] ?? '');
          final wait = Duration(seconds: after ?? 2 << attempt);
          _log.info('429 from chess.com, retrying in $wait');
          await _delay(wait);
        case 429:
          throw const ChessComRateLimited();
        default:
          throw ChessComHttpError(r.statusCode);
      }
    }
  }
}
