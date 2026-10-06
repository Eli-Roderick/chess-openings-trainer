import 'package:freezed_annotation/freezed_annotation.dart';

part 'records.freezed.dart';
part 'records.g.dart';

/// A repertoire as it syncs and backs up (docs/plan/06-sync.md §2): the
/// source data only, no local columns.
@freezed
abstract class RepertoireRecord with _$RepertoireRecord {
  /// Creates a record.
  const factory({
    required String id,
    required String name,

    /// `w` or `b`.
    required String color,
    required String pgn,
    required String pgnHash,
    required int createdAt,
    required int updatedAt,
    required String updatedBy,
    String? description,
    @Default(false) bool deleted,
  }) = _RepertoireRecord;

  /// Parses the JSON form.
  factory fromJson(Map<String, dynamic> json) =>
      _$RepertoireRecordFromJson(json);
}
