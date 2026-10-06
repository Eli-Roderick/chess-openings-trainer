// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'records.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepertoireRecord _$RepertoireRecordFromJson(Map<String, dynamic> json) =>
    _RepertoireRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      pgn: json['pgn'] as String,
      pgnHash: json['pgnHash'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      updatedAt: (json['updatedAt'] as num).toInt(),
      updatedBy: json['updatedBy'] as String,
      description: json['description'] as String?,
      deleted: json['deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$RepertoireRecordToJson(_RepertoireRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'pgn': instance.pgn,
      'pgnHash': instance.pgnHash,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
      'description': instance.description,
      'deleted': instance.deleted,
    };
