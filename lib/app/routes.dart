/// Route paths (docs/plan/01-product-spec.md §2). Features navigate with
/// these helpers; `router.dart` maps them to screens.
abstract final class Routes {
  /// Home.
  static const home = '/';

  /// Create a repertoire (import flow).
  static const newRepertoire = '/repertoire/new';

  /// Repertoire detail.
  static String repertoire(String id) => '/repertoire/$id';

  /// Drill; [mode] is random, weak, srs or single ([line] for single);
  /// [fromBranch] overrides the repertoire's start-from choice and
  /// [deviations] the opponent-deviations setting for this session.
  static String train(
    String id, {
    String? mode,
    String? line,
    bool? fromBranch,
    bool? deviations,
  }) {
    final query = {
      'mode': ?mode,
      'line': ?line,
      if (fromBranch != null) 'from': fromBranch ? 'branch' : 'move1',
      if (deviations != null) 'dev': deviations ? 'on' : 'off',
    };
    return Uri(
      path: '/repertoire/$id/train',
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  /// Browse, optionally at [node], with the analysis on when [analyse]
  /// (free-exploration moves go in the route's `extra`).
  static String browse(String id, {int? node, bool analyse = false}) {
    final query = {
      if (node != null) 'node': '$node',
      if (analyse) 'analyse': '1',
    };
    return Uri(
      path: '/repertoire/$id/browse',
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  /// Stats.
  static String stats(String id) => '/repertoire/$id/stats';

  /// Line detail.
  static String lineStats(String id, String lineKey) =>
      '/repertoire/$id/stats/line/$lineKey';

  /// Re-import flow.
  static String reimport(String id) => '/repertoire/$id/reimport';

  /// Report of the stored PGN ("Validate stored PGN").
  static String validate(String id) => '/repertoire/$id/validate';

  /// Settings.
  static const settings = '/settings';

  /// One settings section.
  static String settingsSection(String section) => '/settings/$section';

  /// Play on vs engine.
  static const playEngine = '/play-engine';

  /// Hidden diagnostics.
  static const diagnostics = '/diagnostics';
}
