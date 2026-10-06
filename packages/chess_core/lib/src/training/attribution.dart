import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// A current line as far as training logic needs it.
@immutable
final class LineRef {
  /// Creates a reference.
  const new({
    required this.key,
    required this.ucis,
    this.ordinal = 0,
    this.userMoveCount = 1,
  });

  /// Line key.
  final String key;

  /// Space-separated UCI sequence.
  final String ucis;

  /// Display (PGN preorder) position.
  final int ordinal;

  /// Moves by the repertoire's side; 0 means never trainable.
  final int userMoveCount;

  /// True if the line can be trained (has at least one user move).
  bool get isTrainable => userMoveCount > 0;

  @override
  bool operator ==(Object other) =>
      other is LineRef &&
      other.key == key &&
      other.ucis == ucis &&
      other.ordinal == ordinal &&
      other.userMoveCount == userMoveCount;

  @override
  int get hashCode => Object.hash(key, ucis, ordinal, userMoveCount);

  @override
  String toString() => 'LineRef($key, $ucis)';
}

/// Which current line(s) a run belongs to
/// (docs/plan/03-data-model.md §5).
@immutable
sealed class Attribution {
  const new();
}

/// The run's moves are exactly a current line.
final class DirectAttribution extends Attribution {
  /// Creates a direct attribution.
  const new(this.key);

  /// The line's key.
  final String key;

  @override
  bool operator ==(Object other) =>
      other is DirectAttribution && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'Direct($key)';
}

/// The run's line was extended: its moves are a strict prefix of these
/// current lines (and not a current line themselves).
final class InheritedAttribution extends Attribution {
  /// Creates an inherited attribution.
  new(List<String> keys) : keys = List.unmodifiable(keys);

  /// Keys of every current line extending the run's moves, in ordinal order.
  final List<String> keys;

  @override
  bool operator ==(Object other) =>
      other is InheritedAttribution &&
      const ListEquality<String>().equals(other.keys, keys);

  @override
  int get hashCode => Object.hashAll(keys);

  @override
  String toString() => 'Inherited($keys)';
}

/// No current line matches: the run is archived under its own key.
final class ArchivedAttribution extends Attribution {
  /// Creates an archived attribution.
  const new(this.key);

  /// The run's line key at the time of the run.
  final String key;

  @override
  bool operator ==(Object other) =>
      other is ArchivedAttribution && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'Archived($key)';
}

final class _Trie {
  final Map<String, _Trie> children = {};
  String? key;
  List<String>? _below;

  /// Keys of all lines ending at or below this node, in ordinal order.
  List<String> below(Map<String, int> ordinals) => _below ??= () {
    final out = <String>[];
    void walk(_Trie t) {
      if (t.key != null) out.add(t.key!);
      t.children.values.forEach(walk);
    }

    walk(this);
    return out..sort((a, b) => ordinals[a]!.compareTo(ordinals[b]!));
  }();
}

/// Prefix trie over the current lines' UCI sequences, used to attribute
/// runs and to find the lines through a node.
final class LineIndex {
  /// Indexes [lines].
  new(Iterable<LineRef> lines) {
    for (final l in lines) {
      _ordinals[l.key] = l.ordinal;
      var t = _root;
      for (final uci in _tokens(l.ucis)) {
        t = t.children.putIfAbsent(uci, _Trie.new);
      }
      t.key = l.key;
    }
  }

  final _Trie _root = _Trie();
  final Map<String, int> _ordinals = {};

  static List<String> _tokens(String ucis) =>
      ucis.isEmpty ? const [] : ucis.split(' ');

  _Trie? _find(String ucis) {
    var t = _root;
    for (final uci in _tokens(ucis)) {
      final next = t.children[uci];
      if (next == null) return null;
      t = next;
    }
    return t;
  }

  /// Attributes a run with moves [ucis] that was recorded under [lineKey].
  Attribution attribute({required String ucis, required String lineKey}) {
    final t = _find(ucis);
    if (t == null) return ArchivedAttribution(lineKey);
    final direct = t.key;
    if (direct != null) return DirectAttribution(direct);
    final below = t.below(_ordinals);
    return below.isEmpty
        ? ArchivedAttribution(lineKey)
        : InheritedAttribution(below);
  }

  /// Keys of the current lines whose moves start with [prefixUcis]
  /// (the lines through the node reached by those moves), in ordinal order.
  List<String> linesThrough(String prefixUcis) =>
      _find(prefixUcis)?.below(_ordinals) ?? const [];
}
