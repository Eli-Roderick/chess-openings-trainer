import 'package:drift/drift.dart';

// Tables of docs/plan/03-data-model.md §2. No foreign keys (sync design).
// Data classes are prefixed `Db` to avoid clashing with chess_core models.

/// Repertoires (source, synced).
@DataClassName('DbRepertoire')
class Repertoires extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// `'w'` or `'b'`.
  TextColumn get color => text()();

  /// Exact imported text, line endings normalized to `\n`.
  TextColumn get pgn => text()();
  TextColumn get pgnHash => text()();
  TextColumn get description => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get updatedBy => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  /// Local only.
  IntColumn get lastTrainedAt => integer().nullable()();

  /// Local only: `'move1'` or `'branch'`.
  TextColumn get drillStartFrom =>
      text().withDefault(const Constant('move1'))();

  /// Local only.
  TextColumn get lastMode => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Tree nodes (derived from `pgn`).
@DataClassName('DbNode')
class Nodes extends Table {
  TextColumn get repertoireId => text()();
  IntColumn get nodeId => integer()();
  IntColumn get parentId => integer().nullable()();
  IntColumn get ply => integer()();
  TextColumn get san => text().nullable()();
  TextColumn get uci => text().nullable()();
  TextColumn get fen => text()();
  BoolColumn get isUserMove => boolean()();
  IntColumn get childIndex => integer()();
  TextColumn get why => text().nullable()();
  TextColumn get plan => text().nullable()();
  TextColumn get watch => text().nullable()();
  TextColumn get alt => text().nullable()();
  TextColumn get shapes => text().nullable()();
  TextColumn get rawComment => text().nullable()();
  TextColumn get nags => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {repertoireId, nodeId};
}

/// Lines (derived).
@DataClassName('DbLine')
@TableIndex(name: 'lines_by_ordinal', columns: {#repertoireId, #ordinal})
class Lines extends Table {
  TextColumn get repertoireId => text()();
  TextColumn get lineKey => text()();
  IntColumn get leafNodeId => integer()();
  IntColumn get ordinal => integer()();
  IntColumn get plies => integer()();
  IntColumn get userMoveCount => integer()();
  IntColumn get branchPly => integer()();
  TextColumn get label => text()();
  TextColumn get ucis => text()();

  @override
  Set<Column<Object>> get primaryKey => {repertoireId, lineKey};
}

/// Runs (source, synced, immutable).
@DataClassName('DbRun')
@TableIndex(
  name: 'runs_by_line',
  columns: {#repertoireId, #lineKey, #finishedAt},
)
@TableIndex(name: 'runs_by_day', columns: {#localDay})
@TableIndex(name: 'runs_by_synced', columns: {#syncedAt})
// Covering indexes for the stats screen (P10): daily aggregates and run
// counts, and line keys with their moves.
@TableIndex(
  name: 'runs_daily_stats',
  columns: {#repertoireId, #completed, #localDay, #gradedCount, #creditSum},
)
@TableIndex(name: 'runs_key_ucis', columns: {#repertoireId, #lineKey, #ucis})
class Runs extends Table {
  TextColumn get id => text()();
  TextColumn get repertoireId => text()();
  TextColumn get lineKey => text()();
  TextColumn get ucis => text()();
  TextColumn get mode => text()();
  IntColumn get startPly => integer()();
  TextColumn get wrongMoveMode => text()();
  IntColumn get startedAt => integer()();
  IntColumn get finishedAt => integer()();
  TextColumn get localDay => text()();
  BoolColumn get completed => boolean()();
  BoolColumn get deviated => boolean()();
  IntColumn get gradedCount => integer()();
  RealColumn get creditSum => real()();
  IntColumn get hintCount => integer()();
  TextColumn get deviceId => text()();

  /// Local only: when uploaded.
  IntColumn get syncedAt => integer().nullable()();
  IntColumn get schema => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Grades of a run's user moves (immutable).
@DataClassName('DbMoveGrade')
class MoveGrades extends Table {
  TextColumn get runId => text()();
  IntColumn get ply => integer()();
  TextColumn get expected => text()();
  TextColumn get accepted => text()();
  TextColumn get firstAttempt => text().nullable()();
  TextColumn get result => text()();
  RealColumn get credit => real()();
  IntColumn get attempts => integer()();
  IntColumn get hintLevel => integer()();
  IntColumn get checkCp => integer().nullable()();
  TextColumn get checkStatus => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {runId, ply};
}

/// Opponent deviation of a run (immutable).
@DataClassName('DbDeviationEvent')
class DeviationEvents extends Table {
  TextColumn get runId => text()();
  IntColumn get ply => integer()();
  TextColumn get deviationUci => text().nullable()();
  TextColumn get replyUci => text().nullable()();
  TextColumn get bestUci => text()();
  IntColumn get lossCp => integer().nullable()();
  BoolColumn get passed => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {runId};
}

/// Derived per-line statistics (cache).
@DataClassName('DbLineStats')
class LineStatsTable extends Table {
  @override
  String get tableName => 'line_stats';

  TextColumn get repertoireId => text()();
  TextColumn get lineKey => text()();
  BoolColumn get archived => boolean()();
  IntColumn get runCount => integer()();
  RealColumn get accuracy => real().nullable()();
  IntColumn get lastPlayedAt => integer().nullable()();
  BoolColumn get inWeakPool => boolean()();
  IntColumn get weakCleanStreak => integer()();
  TextColumn get srsState => text()();
  IntColumn get srsReps => integer()();
  RealColumn get srsEase => real()();
  IntColumn get srsIntervalDays => integer()();
  TextColumn get srsDueDay => text().nullable()();
  IntColumn get srsLapses => integer()();
  TextColumn get srsFirstSeenDay => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {repertoireId, lineKey};
}

/// Derived first-attempt results per move sequence and ply over completed
/// runs (cache, P10): the most-missed moves without scanning every grade.
@DataClassName('DbPlyStats')
class PlyStats extends Table {
  TextColumn get repertoireId => text()();
  TextColumn get ucis => text()();
  IntColumn get ply => integer()();
  IntColumn get attempts => integer()();
  IntColumn get misses => integer()();

  @override
  Set<Column<Object>> get primaryKey => {repertoireId, ucis, ply};
}

/// Device-local settings: key → JSON value.
@DataClassName('DbSetting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Device-local sync state: key → value.
@DataClassName('DbSyncState')
class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Device-local app metadata: key → value.
@DataClassName('DbAppMeta')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Games fetched from chess.com for Game Review (device-local, not synced:
/// they can be fetched again).
@DataClassName('DbImportedGame')
@TableIndex(name: 'games_by_user', columns: {#username, #endTime})
class ImportedGames extends Table {
  /// `chesscom:<game id>`.
  TextColumn get id => text()();

  /// The account the game was fetched for, lower case.
  TextColumn get username => text()();
  TextColumn get url => text()();

  /// Unix seconds.
  IntColumn get endTime => integer()();

  /// `bullet`, `blitz`, `rapid` or `daily`.
  TextColumn get timeClass => text()();

  /// chess.com's time control, e.g. `180+2` or `1/86400`.
  TextColumn get timeControl => text()();
  BoolColumn get rated => boolean()();

  /// Whether [username] had White.
  BoolColumn get userWhite => boolean()();

  /// From the user's side: `win`, `draw` or `loss`.
  TextColumn get result => text()();

  /// chess.com's result code for the losing (or drawing) side, e.g.
  /// `checkmated`, `timeout`, `agreed`.
  TextColumn get resultDetail => text()();
  TextColumn get whiteName => text()();
  TextColumn get blackName => text()();
  IntColumn get whiteRating => integer()();
  IntColumn get blackRating => integer()();
  TextColumn get eco => text().nullable()();
  TextColumn get opening => text().nullable()();

  /// Mainline moves in UCI, space-separated.
  TextColumn get ucis => text()();

  /// Mainline moves in SAN, space-separated.
  TextColumn get sans => text()();

  /// Remaining clock after each ply in tenths of a second, comma-separated,
  /// or null without `%clk`.
  TextColumn get clocks => text().nullable()();

  /// chess.com's own accuracy of White and Black, for games it analysed
  /// (calibration target); null otherwise.
  RealColumn get chessComWhiteAccuracy => real().nullable()();
  RealColumn get chessComBlackAccuracy => real().nullable()();
  TextColumn get pgn => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// chess.com archive fetch state per account: the archive list (archive
/// `''`) and each monthly archive (`YYYY/MM`) with its ETag.
@DataClassName('DbGameArchive')
class GameArchives extends Table {
  TextColumn get username => text()();
  TextColumn get archive => text()();
  TextColumn get etag => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {username, archive};
}

/// One analysed game per analysis profile (Quick, Standard, Deep): engine,
/// progress and the summary shown without reading every ply.
@DataClassName('DbGameReview')
class GameReviews extends Table {
  TextColumn get gameId => text()();

  /// 0 Quick, 1 Standard, 2 Deep.
  IntColumn get profile => integer()();

  /// Engine name and version; a different engine invalidates the rows.
  TextColumn get engine => text()();

  /// Positions analysed so far (resume point) and in total.
  IntColumn get analysed => integer()();
  IntColumn get total => integer()();
  BoolColumn get complete => boolean()();
  RealColumn get whiteAccuracy => real().nullable()();
  RealColumn get blackAccuracy => real().nullable()();
  IntColumn get whitePerformance => integer().nullable()();
  IntColumn get blackPerformance => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId, profile};
}

/// Per-position engine results of a [GameReviews] row: position [ply] is
/// the position after `ply` half-moves (0 = start). Scores are White's.
@DataClassName('DbGameAnalysis')
class GameAnalysis extends Table {
  TextColumn get gameId => text()();
  IntColumn get profile => integer()();
  IntColumn get ply => integer()();

  /// Best-line score: centipawns, or moves to mate when [mate] is set.
  IntColumn get cp => integer().nullable()();
  IntColumn get mate => integer().nullable()();

  /// Best move and its line (UCI, space-separated, at most 10 plies).
  TextColumn get pv => text().nullable()();
  IntColumn get depth => integer()();

  /// The per-position time cap stopped the search before [depth] was the
  /// profile's depth.
  BoolColumn get capped => boolean().withDefault(const Constant(false))();

  /// Second-best move's score (MultiPV pass, candidates only).
  IntColumn get secondCp => integer().nullable()();
  IntColumn get secondMate => integer().nullable()();

  /// Classification of the move that led here (null for ply 0 and until
  /// classified); index into chess_core's `MoveLabel`.
  IntColumn get label => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {gameId, profile, ply};
}
