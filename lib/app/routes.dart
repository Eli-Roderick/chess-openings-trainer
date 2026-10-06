/// Route paths (docs/plan/01-product-spec.md §2). Features navigate with
/// these helpers; `router.dart` maps them to screens.
abstract final class Routes {
  /// Home.
  static const home = '/';

  /// Create a repertoire (import flow).
  static const newRepertoire = '/repertoire/new';

  /// Repertoire detail.
  static String repertoire(String id) => '/repertoire/$id';

  /// Drill; [mode] is random, weak, srs or single.
  static String train(String id, {String? mode}) =>
      '/repertoire/$id/train${mode == null ? '' : '?mode=$mode'}';

  /// Browse, optionally at [node].
  static String browse(String id, {int? node}) =>
      '/repertoire/$id/browse${node == null ? '' : '?node=$node'}';

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
