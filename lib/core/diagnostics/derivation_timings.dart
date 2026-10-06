import 'package:flutter/foundation.dart';

/// The last stats derivation (Diagnostics "Database", 10-testing §6).
final class DerivationTimings extends ChangeNotifier {
  new _();

  /// The app-wide instance.
  static final DerivationTimings instance = DerivationTimings._();

  /// Duration of the last derivation (one run, or a whole repertoire).
  Duration? last;

  /// What was derived last: `run` or `repertoire`.
  String? lastKind;

  /// Records a derivation of [kind] that took [elapsed].
  void record(String kind, Duration elapsed) {
    last = elapsed;
    lastKind = kind;
    notifyListeners();
  }
}
