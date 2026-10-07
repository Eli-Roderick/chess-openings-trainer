import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:http/http.dart' as http;
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/games_repository.dart';
import 'package:repertoire_trainer/features/games/chess_com_client.dart';
import 'package:repertoire_trainer/features/games/chess_com_parser.dart';

/// chess.com usernames: 3 to 25 letters, digits, `_` or `-`.
final usernamePattern = RegExp(r'^[A-Za-z0-9_-]{3,25}$');

/// Key of the archive-list row in `game_archives`.
const archiveListKey = '';

/// Fetches chess.com games into the database: the newest months on
/// [refresh], one older month per [loadOlder]. Parsing runs in an isolate.
final class GamesService {
  /// Creates the service.
  new(this._client, this._repo, this._clock);

  final ChessComClient _client;
  final GamesRepository _repo;
  final Clock _clock;

  int get _now => _clock.now().millisecondsSinceEpoch;

  /// Refreshes the archive list and re-checks the two newest months
  /// (conditional requests: unchanged months cost a 304). Returns the
  /// number of new games.
  Future<int> refresh(String username) async {
    final user = username.toLowerCase();
    final listRow = await _repo.archive(user, archiveListKey);
    final list = await _client.get(
      ChessComClient.archivesUri(user),
      etag: listRow?.etag,
      lastModified: listRow?.lastModified,
    );
    if (list.body != null) {
      await _repo.addKnownMonths(user, parseArchiveList(list.body!));
    }
    await _repo.saveArchive(
      GameArchivesCompanion.insert(
        username: user,
        archive: archiveListKey,
        etag: Value(list.etag),
        lastModified: Value(list.lastModified),
        fetchedAt: _now,
      ),
    );
    final months = await _repo.months(user);
    var added = 0;
    for (final (month, _) in months.take(2)) {
      added += await _fetchMonth(user, month);
    }
    return added;
  }

  /// Fetches the newest month not fetched yet; returns the new games, or
  /// null when every month is fetched.
  Future<int?> loadOlder(String username) async {
    final user = username.toLowerCase();
    final next = (await _repo.months(user)).where((m) => !m.$2).firstOrNull?.$1;
    if (next == null) return null;
    return await _fetchMonth(user, next);
  }

  /// Whether an older month is still to fetch.
  Future<bool> hasOlder(String username) async =>
      (await _repo.months(username.toLowerCase())).any((m) => !m.$2);

  Future<int> _fetchMonth(String user, String month) async {
    final row = await _repo.archive(user, month);
    final fetched = row != null && row.fetchedAt > 0;
    final r = await _client.get(
      ChessComClient.monthUri(user, month),
      etag: fetched ? row.etag : null,
      lastModified: fetched ? row.lastModified : null,
    );
    var added = 0;
    if (r.body != null) {
      final input = (body: r.body!, username: user, fetchedAt: _now);
      final rows = await Isolate.run(() => parseMonth(input));
      added = await _repo.upsertGames(rows);
    }
    await _repo.saveArchive(
      GameArchivesCompanion.insert(
        username: user,
        archive: month,
        etag: Value(r.etag),
        lastModified: Value(r.lastModified),
        fetchedAt: _now,
      ),
    );
    return added;
  }
}

/// The HTTP client for chess.com (overridden in tests).
final chessComHttpProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// The games service.
final gamesServiceProvider = Provider<GamesService>(
  (ref) => GamesService(
    ChessComClient(ref.watch(chessComHttpProvider)),
    ref.watch(gamesRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

/// Whether api.chess.com resolves (a cheap reachability check before
/// offering a fetch; overridden in tests).
final FutureProvider<bool> chessComReachableProvider =
    FutureProvider.autoDispose<bool>((ref) async {
      try {
        final r = await InternetAddress.lookup('api.chess.com')
            .timeout(const Duration(seconds: 3));
        return r.isNotEmpty;
      } on Object {
        return false;
      }
    });

/// The stored games of a username, newest first.
final StreamProviderFamily<List<DbImportedGame>, String> gamesProvider =
    StreamProvider.autoDispose.family<List<DbImportedGame>, String>(
      (ref, username) =>
          ref.watch(gamesRepositoryProvider).watchGames(username.toLowerCase()),
    );
