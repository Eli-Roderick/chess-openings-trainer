// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RepertoiresTable extends Repertoires
    with TableInfo<$RepertoiresTable, DbRepertoire> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepertoiresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pgnMeta = const VerificationMeta('pgn');
  @override
  late final GeneratedColumn<String> pgn = GeneratedColumn<String>(
    'pgn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pgnHashMeta = const VerificationMeta(
    'pgnHash',
  );
  @override
  late final GeneratedColumn<String> pgnHash = GeneratedColumn<String>(
    'pgn_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastTrainedAtMeta = const VerificationMeta(
    'lastTrainedAt',
  );
  @override
  late final GeneratedColumn<int> lastTrainedAt = GeneratedColumn<int>(
    'last_trained_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drillStartFromMeta = const VerificationMeta(
    'drillStartFrom',
  );
  @override
  late final GeneratedColumn<String> drillStartFrom = GeneratedColumn<String>(
    'drill_start_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('move1'),
  );
  static const VerificationMeta _lastModeMeta = const VerificationMeta(
    'lastMode',
  );
  @override
  late final GeneratedColumn<String> lastMode = GeneratedColumn<String>(
    'last_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    pgn,
    pgnHash,
    description,
    createdAt,
    updatedAt,
    updatedBy,
    deleted,
    lastTrainedAt,
    drillStartFrom,
    lastMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repertoires';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRepertoire> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('pgn')) {
      context.handle(
        _pgnMeta,
        pgn.isAcceptableOrUnknown(data['pgn']!, _pgnMeta),
      );
    } else if (isInserting) {
      context.missing(_pgnMeta);
    }
    if (data.containsKey('pgn_hash')) {
      context.handle(
        _pgnHashMeta,
        pgnHash.isAcceptableOrUnknown(data['pgn_hash']!, _pgnHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pgnHashMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('last_trained_at')) {
      context.handle(
        _lastTrainedAtMeta,
        lastTrainedAt.isAcceptableOrUnknown(
          data['last_trained_at']!,
          _lastTrainedAtMeta,
        ),
      );
    }
    if (data.containsKey('drill_start_from')) {
      context.handle(
        _drillStartFromMeta,
        drillStartFrom.isAcceptableOrUnknown(
          data['drill_start_from']!,
          _drillStartFromMeta,
        ),
      );
    }
    if (data.containsKey('last_mode')) {
      context.handle(
        _lastModeMeta,
        lastMode.isAcceptableOrUnknown(data['last_mode']!, _lastModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRepertoire map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRepertoire(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      pgn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pgn'],
      )!,
      pgnHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pgn_hash'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      lastTrainedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_trained_at'],
      ),
      drillStartFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drill_start_from'],
      )!,
      lastMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_mode'],
      ),
    );
  }

  @override
  $RepertoiresTable createAlias(String alias) {
    return $RepertoiresTable(attachedDatabase, alias);
  }
}

class DbRepertoire extends DataClass implements Insertable<DbRepertoire> {
  final String id;
  final String name;

  /// `'w'` or `'b'`.
  final String color;

  /// Exact imported text, line endings normalized to `\n`.
  final String pgn;
  final String pgnHash;
  final String? description;
  final int createdAt;
  final int updatedAt;
  final String updatedBy;
  final bool deleted;

  /// Local only.
  final int? lastTrainedAt;

  /// Local only: `'move1'` or `'branch'`.
  final String drillStartFrom;

  /// Local only.
  final String? lastMode;
  const DbRepertoire({
    required this.id,
    required this.name,
    required this.color,
    required this.pgn,
    required this.pgnHash,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
    required this.deleted,
    this.lastTrainedAt,
    required this.drillStartFrom,
    this.lastMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['pgn'] = Variable<String>(pgn);
    map['pgn_hash'] = Variable<String>(pgnHash);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || lastTrainedAt != null) {
      map['last_trained_at'] = Variable<int>(lastTrainedAt);
    }
    map['drill_start_from'] = Variable<String>(drillStartFrom);
    if (!nullToAbsent || lastMode != null) {
      map['last_mode'] = Variable<String>(lastMode);
    }
    return map;
  }

  RepertoiresCompanion toCompanion(bool nullToAbsent) {
    return RepertoiresCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      pgn: Value(pgn),
      pgnHash: Value(pgnHash),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deleted: Value(deleted),
      lastTrainedAt: lastTrainedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTrainedAt),
      drillStartFrom: Value(drillStartFrom),
      lastMode: lastMode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMode),
    );
  }

  factory DbRepertoire.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRepertoire(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      pgn: serializer.fromJson<String>(json['pgn']),
      pgnHash: serializer.fromJson<String>(json['pgnHash']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      lastTrainedAt: serializer.fromJson<int?>(json['lastTrainedAt']),
      drillStartFrom: serializer.fromJson<String>(json['drillStartFrom']),
      lastMode: serializer.fromJson<String?>(json['lastMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'pgn': serializer.toJson<String>(pgn),
      'pgnHash': serializer.toJson<String>(pgnHash),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deleted': serializer.toJson<bool>(deleted),
      'lastTrainedAt': serializer.toJson<int?>(lastTrainedAt),
      'drillStartFrom': serializer.toJson<String>(drillStartFrom),
      'lastMode': serializer.toJson<String?>(lastMode),
    };
  }

  DbRepertoire copyWith({
    String? id,
    String? name,
    String? color,
    String? pgn,
    String? pgnHash,
    Value<String?> description = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? updatedBy,
    bool? deleted,
    Value<int?> lastTrainedAt = const Value.absent(),
    String? drillStartFrom,
    Value<String?> lastMode = const Value.absent(),
  }) => DbRepertoire(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    pgn: pgn ?? this.pgn,
    pgnHash: pgnHash ?? this.pgnHash,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deleted: deleted ?? this.deleted,
    lastTrainedAt: lastTrainedAt.present
        ? lastTrainedAt.value
        : this.lastTrainedAt,
    drillStartFrom: drillStartFrom ?? this.drillStartFrom,
    lastMode: lastMode.present ? lastMode.value : this.lastMode,
  );
  DbRepertoire copyWithCompanion(RepertoiresCompanion data) {
    return DbRepertoire(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      pgn: data.pgn.present ? data.pgn.value : this.pgn,
      pgnHash: data.pgnHash.present ? data.pgnHash.value : this.pgnHash,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      lastTrainedAt: data.lastTrainedAt.present
          ? data.lastTrainedAt.value
          : this.lastTrainedAt,
      drillStartFrom: data.drillStartFrom.present
          ? data.drillStartFrom.value
          : this.drillStartFrom,
      lastMode: data.lastMode.present ? data.lastMode.value : this.lastMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRepertoire(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('pgn: $pgn, ')
          ..write('pgnHash: $pgnHash, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deleted: $deleted, ')
          ..write('lastTrainedAt: $lastTrainedAt, ')
          ..write('drillStartFrom: $drillStartFrom, ')
          ..write('lastMode: $lastMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    color,
    pgn,
    pgnHash,
    description,
    createdAt,
    updatedAt,
    updatedBy,
    deleted,
    lastTrainedAt,
    drillStartFrom,
    lastMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRepertoire &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.pgn == this.pgn &&
          other.pgnHash == this.pgnHash &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deleted == this.deleted &&
          other.lastTrainedAt == this.lastTrainedAt &&
          other.drillStartFrom == this.drillStartFrom &&
          other.lastMode == this.lastMode);
}

class RepertoiresCompanion extends UpdateCompanion<DbRepertoire> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String> pgn;
  final Value<String> pgnHash;
  final Value<String?> description;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<bool> deleted;
  final Value<int?> lastTrainedAt;
  final Value<String> drillStartFrom;
  final Value<String?> lastMode;
  final Value<int> rowid;
  const RepertoiresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.pgn = const Value.absent(),
    this.pgnHash = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deleted = const Value.absent(),
    this.lastTrainedAt = const Value.absent(),
    this.drillStartFrom = const Value.absent(),
    this.lastMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepertoiresCompanion.insert({
    required String id,
    required String name,
    required String color,
    required String pgn,
    required String pgnHash,
    this.description = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String updatedBy,
    this.deleted = const Value.absent(),
    this.lastTrainedAt = const Value.absent(),
    this.drillStartFrom = const Value.absent(),
    this.lastMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color),
       pgn = Value(pgn),
       pgnHash = Value(pgnHash),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy);
  static Insertable<DbRepertoire> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? pgn,
    Expression<String>? pgnHash,
    Expression<String>? description,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<bool>? deleted,
    Expression<int>? lastTrainedAt,
    Expression<String>? drillStartFrom,
    Expression<String>? lastMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (pgn != null) 'pgn': pgn,
      if (pgnHash != null) 'pgn_hash': pgnHash,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deleted != null) 'deleted': deleted,
      if (lastTrainedAt != null) 'last_trained_at': lastTrainedAt,
      if (drillStartFrom != null) 'drill_start_from': drillStartFrom,
      if (lastMode != null) 'last_mode': lastMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepertoiresCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<String>? pgn,
    Value<String>? pgnHash,
    Value<String?>? description,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<bool>? deleted,
    Value<int?>? lastTrainedAt,
    Value<String>? drillStartFrom,
    Value<String?>? lastMode,
    Value<int>? rowid,
  }) {
    return RepertoiresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      pgn: pgn ?? this.pgn,
      pgnHash: pgnHash ?? this.pgnHash,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deleted: deleted ?? this.deleted,
      lastTrainedAt: lastTrainedAt ?? this.lastTrainedAt,
      drillStartFrom: drillStartFrom ?? this.drillStartFrom,
      lastMode: lastMode ?? this.lastMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (pgn.present) {
      map['pgn'] = Variable<String>(pgn.value);
    }
    if (pgnHash.present) {
      map['pgn_hash'] = Variable<String>(pgnHash.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (lastTrainedAt.present) {
      map['last_trained_at'] = Variable<int>(lastTrainedAt.value);
    }
    if (drillStartFrom.present) {
      map['drill_start_from'] = Variable<String>(drillStartFrom.value);
    }
    if (lastMode.present) {
      map['last_mode'] = Variable<String>(lastMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepertoiresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('pgn: $pgn, ')
          ..write('pgnHash: $pgnHash, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deleted: $deleted, ')
          ..write('lastTrainedAt: $lastTrainedAt, ')
          ..write('drillStartFrom: $drillStartFrom, ')
          ..write('lastMode: $lastMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NodesTable extends Nodes with TableInfo<$NodesTable, DbNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _repertoireIdMeta = const VerificationMeta(
    'repertoireId',
  );
  @override
  late final GeneratedColumn<String> repertoireId = GeneratedColumn<String>(
    'repertoire_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<int> nodeId = GeneratedColumn<int>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanMeta = const VerificationMeta('san');
  @override
  late final GeneratedColumn<String> san = GeneratedColumn<String>(
    'san',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uciMeta = const VerificationMeta('uci');
  @override
  late final GeneratedColumn<String> uci = GeneratedColumn<String>(
    'uci',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fenMeta = const VerificationMeta('fen');
  @override
  late final GeneratedColumn<String> fen = GeneratedColumn<String>(
    'fen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUserMoveMeta = const VerificationMeta(
    'isUserMove',
  );
  @override
  late final GeneratedColumn<bool> isUserMove = GeneratedColumn<bool>(
    'is_user_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user_move" IN (0, 1))',
    ),
  );
  static const VerificationMeta _childIndexMeta = const VerificationMeta(
    'childIndex',
  );
  @override
  late final GeneratedColumn<int> childIndex = GeneratedColumn<int>(
    'child_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whyMeta = const VerificationMeta('why');
  @override
  late final GeneratedColumn<String> why = GeneratedColumn<String>(
    'why',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watchMeta = const VerificationMeta('watch');
  @override
  late final GeneratedColumn<String> watch = GeneratedColumn<String>(
    'watch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altMeta = const VerificationMeta('alt');
  @override
  late final GeneratedColumn<String> alt = GeneratedColumn<String>(
    'alt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shapesMeta = const VerificationMeta('shapes');
  @override
  late final GeneratedColumn<String> shapes = GeneratedColumn<String>(
    'shapes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawCommentMeta = const VerificationMeta(
    'rawComment',
  );
  @override
  late final GeneratedColumn<String> rawComment = GeneratedColumn<String>(
    'raw_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nagsMeta = const VerificationMeta('nags');
  @override
  late final GeneratedColumn<String> nags = GeneratedColumn<String>(
    'nags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    repertoireId,
    nodeId,
    parentId,
    ply,
    san,
    uci,
    fen,
    isUserMove,
    childIndex,
    why,
    plan,
    watch,
    alt,
    shapes,
    rawComment,
    nags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbNode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('repertoire_id')) {
      context.handle(
        _repertoireIdMeta,
        repertoireId.isAcceptableOrUnknown(
          data['repertoire_id']!,
          _repertoireIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repertoireIdMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('san')) {
      context.handle(
        _sanMeta,
        san.isAcceptableOrUnknown(data['san']!, _sanMeta),
      );
    }
    if (data.containsKey('uci')) {
      context.handle(
        _uciMeta,
        uci.isAcceptableOrUnknown(data['uci']!, _uciMeta),
      );
    }
    if (data.containsKey('fen')) {
      context.handle(
        _fenMeta,
        fen.isAcceptableOrUnknown(data['fen']!, _fenMeta),
      );
    } else if (isInserting) {
      context.missing(_fenMeta);
    }
    if (data.containsKey('is_user_move')) {
      context.handle(
        _isUserMoveMeta,
        isUserMove.isAcceptableOrUnknown(
          data['is_user_move']!,
          _isUserMoveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isUserMoveMeta);
    }
    if (data.containsKey('child_index')) {
      context.handle(
        _childIndexMeta,
        childIndex.isAcceptableOrUnknown(data['child_index']!, _childIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_childIndexMeta);
    }
    if (data.containsKey('why')) {
      context.handle(
        _whyMeta,
        why.isAcceptableOrUnknown(data['why']!, _whyMeta),
      );
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    }
    if (data.containsKey('watch')) {
      context.handle(
        _watchMeta,
        watch.isAcceptableOrUnknown(data['watch']!, _watchMeta),
      );
    }
    if (data.containsKey('alt')) {
      context.handle(
        _altMeta,
        alt.isAcceptableOrUnknown(data['alt']!, _altMeta),
      );
    }
    if (data.containsKey('shapes')) {
      context.handle(
        _shapesMeta,
        shapes.isAcceptableOrUnknown(data['shapes']!, _shapesMeta),
      );
    }
    if (data.containsKey('raw_comment')) {
      context.handle(
        _rawCommentMeta,
        rawComment.isAcceptableOrUnknown(data['raw_comment']!, _rawCommentMeta),
      );
    }
    if (data.containsKey('nags')) {
      context.handle(
        _nagsMeta,
        nags.isAcceptableOrUnknown(data['nags']!, _nagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {repertoireId, nodeId};
  @override
  DbNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbNode(
      repertoireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repertoire_id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      san: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}san'],
      ),
      uci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uci'],
      ),
      fen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fen'],
      )!,
      isUserMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user_move'],
      )!,
      childIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_index'],
      )!,
      why: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}why'],
      ),
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      ),
      watch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watch'],
      ),
      alt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt'],
      ),
      shapes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shapes'],
      ),
      rawComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_comment'],
      ),
      nags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nags'],
      ),
    );
  }

  @override
  $NodesTable createAlias(String alias) {
    return $NodesTable(attachedDatabase, alias);
  }
}

class DbNode extends DataClass implements Insertable<DbNode> {
  final String repertoireId;
  final int nodeId;
  final int? parentId;
  final int ply;
  final String? san;
  final String? uci;
  final String fen;
  final bool isUserMove;
  final int childIndex;
  final String? why;
  final String? plan;
  final String? watch;
  final String? alt;
  final String? shapes;
  final String? rawComment;
  final String? nags;
  const DbNode({
    required this.repertoireId,
    required this.nodeId,
    this.parentId,
    required this.ply,
    this.san,
    this.uci,
    required this.fen,
    required this.isUserMove,
    required this.childIndex,
    this.why,
    this.plan,
    this.watch,
    this.alt,
    this.shapes,
    this.rawComment,
    this.nags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['repertoire_id'] = Variable<String>(repertoireId);
    map['node_id'] = Variable<int>(nodeId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['ply'] = Variable<int>(ply);
    if (!nullToAbsent || san != null) {
      map['san'] = Variable<String>(san);
    }
    if (!nullToAbsent || uci != null) {
      map['uci'] = Variable<String>(uci);
    }
    map['fen'] = Variable<String>(fen);
    map['is_user_move'] = Variable<bool>(isUserMove);
    map['child_index'] = Variable<int>(childIndex);
    if (!nullToAbsent || why != null) {
      map['why'] = Variable<String>(why);
    }
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    if (!nullToAbsent || watch != null) {
      map['watch'] = Variable<String>(watch);
    }
    if (!nullToAbsent || alt != null) {
      map['alt'] = Variable<String>(alt);
    }
    if (!nullToAbsent || shapes != null) {
      map['shapes'] = Variable<String>(shapes);
    }
    if (!nullToAbsent || rawComment != null) {
      map['raw_comment'] = Variable<String>(rawComment);
    }
    if (!nullToAbsent || nags != null) {
      map['nags'] = Variable<String>(nags);
    }
    return map;
  }

  NodesCompanion toCompanion(bool nullToAbsent) {
    return NodesCompanion(
      repertoireId: Value(repertoireId),
      nodeId: Value(nodeId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      ply: Value(ply),
      san: san == null && nullToAbsent ? const Value.absent() : Value(san),
      uci: uci == null && nullToAbsent ? const Value.absent() : Value(uci),
      fen: Value(fen),
      isUserMove: Value(isUserMove),
      childIndex: Value(childIndex),
      why: why == null && nullToAbsent ? const Value.absent() : Value(why),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      watch: watch == null && nullToAbsent
          ? const Value.absent()
          : Value(watch),
      alt: alt == null && nullToAbsent ? const Value.absent() : Value(alt),
      shapes: shapes == null && nullToAbsent
          ? const Value.absent()
          : Value(shapes),
      rawComment: rawComment == null && nullToAbsent
          ? const Value.absent()
          : Value(rawComment),
      nags: nags == null && nullToAbsent ? const Value.absent() : Value(nags),
    );
  }

  factory DbNode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbNode(
      repertoireId: serializer.fromJson<String>(json['repertoireId']),
      nodeId: serializer.fromJson<int>(json['nodeId']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      ply: serializer.fromJson<int>(json['ply']),
      san: serializer.fromJson<String?>(json['san']),
      uci: serializer.fromJson<String?>(json['uci']),
      fen: serializer.fromJson<String>(json['fen']),
      isUserMove: serializer.fromJson<bool>(json['isUserMove']),
      childIndex: serializer.fromJson<int>(json['childIndex']),
      why: serializer.fromJson<String?>(json['why']),
      plan: serializer.fromJson<String?>(json['plan']),
      watch: serializer.fromJson<String?>(json['watch']),
      alt: serializer.fromJson<String?>(json['alt']),
      shapes: serializer.fromJson<String?>(json['shapes']),
      rawComment: serializer.fromJson<String?>(json['rawComment']),
      nags: serializer.fromJson<String?>(json['nags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'repertoireId': serializer.toJson<String>(repertoireId),
      'nodeId': serializer.toJson<int>(nodeId),
      'parentId': serializer.toJson<int?>(parentId),
      'ply': serializer.toJson<int>(ply),
      'san': serializer.toJson<String?>(san),
      'uci': serializer.toJson<String?>(uci),
      'fen': serializer.toJson<String>(fen),
      'isUserMove': serializer.toJson<bool>(isUserMove),
      'childIndex': serializer.toJson<int>(childIndex),
      'why': serializer.toJson<String?>(why),
      'plan': serializer.toJson<String?>(plan),
      'watch': serializer.toJson<String?>(watch),
      'alt': serializer.toJson<String?>(alt),
      'shapes': serializer.toJson<String?>(shapes),
      'rawComment': serializer.toJson<String?>(rawComment),
      'nags': serializer.toJson<String?>(nags),
    };
  }

  DbNode copyWith({
    String? repertoireId,
    int? nodeId,
    Value<int?> parentId = const Value.absent(),
    int? ply,
    Value<String?> san = const Value.absent(),
    Value<String?> uci = const Value.absent(),
    String? fen,
    bool? isUserMove,
    int? childIndex,
    Value<String?> why = const Value.absent(),
    Value<String?> plan = const Value.absent(),
    Value<String?> watch = const Value.absent(),
    Value<String?> alt = const Value.absent(),
    Value<String?> shapes = const Value.absent(),
    Value<String?> rawComment = const Value.absent(),
    Value<String?> nags = const Value.absent(),
  }) => DbNode(
    repertoireId: repertoireId ?? this.repertoireId,
    nodeId: nodeId ?? this.nodeId,
    parentId: parentId.present ? parentId.value : this.parentId,
    ply: ply ?? this.ply,
    san: san.present ? san.value : this.san,
    uci: uci.present ? uci.value : this.uci,
    fen: fen ?? this.fen,
    isUserMove: isUserMove ?? this.isUserMove,
    childIndex: childIndex ?? this.childIndex,
    why: why.present ? why.value : this.why,
    plan: plan.present ? plan.value : this.plan,
    watch: watch.present ? watch.value : this.watch,
    alt: alt.present ? alt.value : this.alt,
    shapes: shapes.present ? shapes.value : this.shapes,
    rawComment: rawComment.present ? rawComment.value : this.rawComment,
    nags: nags.present ? nags.value : this.nags,
  );
  DbNode copyWithCompanion(NodesCompanion data) {
    return DbNode(
      repertoireId: data.repertoireId.present
          ? data.repertoireId.value
          : this.repertoireId,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      ply: data.ply.present ? data.ply.value : this.ply,
      san: data.san.present ? data.san.value : this.san,
      uci: data.uci.present ? data.uci.value : this.uci,
      fen: data.fen.present ? data.fen.value : this.fen,
      isUserMove: data.isUserMove.present
          ? data.isUserMove.value
          : this.isUserMove,
      childIndex: data.childIndex.present
          ? data.childIndex.value
          : this.childIndex,
      why: data.why.present ? data.why.value : this.why,
      plan: data.plan.present ? data.plan.value : this.plan,
      watch: data.watch.present ? data.watch.value : this.watch,
      alt: data.alt.present ? data.alt.value : this.alt,
      shapes: data.shapes.present ? data.shapes.value : this.shapes,
      rawComment: data.rawComment.present
          ? data.rawComment.value
          : this.rawComment,
      nags: data.nags.present ? data.nags.value : this.nags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbNode(')
          ..write('repertoireId: $repertoireId, ')
          ..write('nodeId: $nodeId, ')
          ..write('parentId: $parentId, ')
          ..write('ply: $ply, ')
          ..write('san: $san, ')
          ..write('uci: $uci, ')
          ..write('fen: $fen, ')
          ..write('isUserMove: $isUserMove, ')
          ..write('childIndex: $childIndex, ')
          ..write('why: $why, ')
          ..write('plan: $plan, ')
          ..write('watch: $watch, ')
          ..write('alt: $alt, ')
          ..write('shapes: $shapes, ')
          ..write('rawComment: $rawComment, ')
          ..write('nags: $nags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    repertoireId,
    nodeId,
    parentId,
    ply,
    san,
    uci,
    fen,
    isUserMove,
    childIndex,
    why,
    plan,
    watch,
    alt,
    shapes,
    rawComment,
    nags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbNode &&
          other.repertoireId == this.repertoireId &&
          other.nodeId == this.nodeId &&
          other.parentId == this.parentId &&
          other.ply == this.ply &&
          other.san == this.san &&
          other.uci == this.uci &&
          other.fen == this.fen &&
          other.isUserMove == this.isUserMove &&
          other.childIndex == this.childIndex &&
          other.why == this.why &&
          other.plan == this.plan &&
          other.watch == this.watch &&
          other.alt == this.alt &&
          other.shapes == this.shapes &&
          other.rawComment == this.rawComment &&
          other.nags == this.nags);
}

class NodesCompanion extends UpdateCompanion<DbNode> {
  final Value<String> repertoireId;
  final Value<int> nodeId;
  final Value<int?> parentId;
  final Value<int> ply;
  final Value<String?> san;
  final Value<String?> uci;
  final Value<String> fen;
  final Value<bool> isUserMove;
  final Value<int> childIndex;
  final Value<String?> why;
  final Value<String?> plan;
  final Value<String?> watch;
  final Value<String?> alt;
  final Value<String?> shapes;
  final Value<String?> rawComment;
  final Value<String?> nags;
  final Value<int> rowid;
  const NodesCompanion({
    this.repertoireId = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.ply = const Value.absent(),
    this.san = const Value.absent(),
    this.uci = const Value.absent(),
    this.fen = const Value.absent(),
    this.isUserMove = const Value.absent(),
    this.childIndex = const Value.absent(),
    this.why = const Value.absent(),
    this.plan = const Value.absent(),
    this.watch = const Value.absent(),
    this.alt = const Value.absent(),
    this.shapes = const Value.absent(),
    this.rawComment = const Value.absent(),
    this.nags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NodesCompanion.insert({
    required String repertoireId,
    required int nodeId,
    this.parentId = const Value.absent(),
    required int ply,
    this.san = const Value.absent(),
    this.uci = const Value.absent(),
    required String fen,
    required bool isUserMove,
    required int childIndex,
    this.why = const Value.absent(),
    this.plan = const Value.absent(),
    this.watch = const Value.absent(),
    this.alt = const Value.absent(),
    this.shapes = const Value.absent(),
    this.rawComment = const Value.absent(),
    this.nags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : repertoireId = Value(repertoireId),
       nodeId = Value(nodeId),
       ply = Value(ply),
       fen = Value(fen),
       isUserMove = Value(isUserMove),
       childIndex = Value(childIndex);
  static Insertable<DbNode> custom({
    Expression<String>? repertoireId,
    Expression<int>? nodeId,
    Expression<int>? parentId,
    Expression<int>? ply,
    Expression<String>? san,
    Expression<String>? uci,
    Expression<String>? fen,
    Expression<bool>? isUserMove,
    Expression<int>? childIndex,
    Expression<String>? why,
    Expression<String>? plan,
    Expression<String>? watch,
    Expression<String>? alt,
    Expression<String>? shapes,
    Expression<String>? rawComment,
    Expression<String>? nags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (repertoireId != null) 'repertoire_id': repertoireId,
      if (nodeId != null) 'node_id': nodeId,
      if (parentId != null) 'parent_id': parentId,
      if (ply != null) 'ply': ply,
      if (san != null) 'san': san,
      if (uci != null) 'uci': uci,
      if (fen != null) 'fen': fen,
      if (isUserMove != null) 'is_user_move': isUserMove,
      if (childIndex != null) 'child_index': childIndex,
      if (why != null) 'why': why,
      if (plan != null) 'plan': plan,
      if (watch != null) 'watch': watch,
      if (alt != null) 'alt': alt,
      if (shapes != null) 'shapes': shapes,
      if (rawComment != null) 'raw_comment': rawComment,
      if (nags != null) 'nags': nags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NodesCompanion copyWith({
    Value<String>? repertoireId,
    Value<int>? nodeId,
    Value<int?>? parentId,
    Value<int>? ply,
    Value<String?>? san,
    Value<String?>? uci,
    Value<String>? fen,
    Value<bool>? isUserMove,
    Value<int>? childIndex,
    Value<String?>? why,
    Value<String?>? plan,
    Value<String?>? watch,
    Value<String?>? alt,
    Value<String?>? shapes,
    Value<String?>? rawComment,
    Value<String?>? nags,
    Value<int>? rowid,
  }) {
    return NodesCompanion(
      repertoireId: repertoireId ?? this.repertoireId,
      nodeId: nodeId ?? this.nodeId,
      parentId: parentId ?? this.parentId,
      ply: ply ?? this.ply,
      san: san ?? this.san,
      uci: uci ?? this.uci,
      fen: fen ?? this.fen,
      isUserMove: isUserMove ?? this.isUserMove,
      childIndex: childIndex ?? this.childIndex,
      why: why ?? this.why,
      plan: plan ?? this.plan,
      watch: watch ?? this.watch,
      alt: alt ?? this.alt,
      shapes: shapes ?? this.shapes,
      rawComment: rawComment ?? this.rawComment,
      nags: nags ?? this.nags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (repertoireId.present) {
      map['repertoire_id'] = Variable<String>(repertoireId.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<int>(nodeId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (san.present) {
      map['san'] = Variable<String>(san.value);
    }
    if (uci.present) {
      map['uci'] = Variable<String>(uci.value);
    }
    if (fen.present) {
      map['fen'] = Variable<String>(fen.value);
    }
    if (isUserMove.present) {
      map['is_user_move'] = Variable<bool>(isUserMove.value);
    }
    if (childIndex.present) {
      map['child_index'] = Variable<int>(childIndex.value);
    }
    if (why.present) {
      map['why'] = Variable<String>(why.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (watch.present) {
      map['watch'] = Variable<String>(watch.value);
    }
    if (alt.present) {
      map['alt'] = Variable<String>(alt.value);
    }
    if (shapes.present) {
      map['shapes'] = Variable<String>(shapes.value);
    }
    if (rawComment.present) {
      map['raw_comment'] = Variable<String>(rawComment.value);
    }
    if (nags.present) {
      map['nags'] = Variable<String>(nags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NodesCompanion(')
          ..write('repertoireId: $repertoireId, ')
          ..write('nodeId: $nodeId, ')
          ..write('parentId: $parentId, ')
          ..write('ply: $ply, ')
          ..write('san: $san, ')
          ..write('uci: $uci, ')
          ..write('fen: $fen, ')
          ..write('isUserMove: $isUserMove, ')
          ..write('childIndex: $childIndex, ')
          ..write('why: $why, ')
          ..write('plan: $plan, ')
          ..write('watch: $watch, ')
          ..write('alt: $alt, ')
          ..write('shapes: $shapes, ')
          ..write('rawComment: $rawComment, ')
          ..write('nags: $nags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinesTable extends Lines with TableInfo<$LinesTable, DbLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _repertoireIdMeta = const VerificationMeta(
    'repertoireId',
  );
  @override
  late final GeneratedColumn<String> repertoireId = GeneratedColumn<String>(
    'repertoire_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineKeyMeta = const VerificationMeta(
    'lineKey',
  );
  @override
  late final GeneratedColumn<String> lineKey = GeneratedColumn<String>(
    'line_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leafNodeIdMeta = const VerificationMeta(
    'leafNodeId',
  );
  @override
  late final GeneratedColumn<int> leafNodeId = GeneratedColumn<int>(
    'leaf_node_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pliesMeta = const VerificationMeta('plies');
  @override
  late final GeneratedColumn<int> plies = GeneratedColumn<int>(
    'plies',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userMoveCountMeta = const VerificationMeta(
    'userMoveCount',
  );
  @override
  late final GeneratedColumn<int> userMoveCount = GeneratedColumn<int>(
    'user_move_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchPlyMeta = const VerificationMeta(
    'branchPly',
  );
  @override
  late final GeneratedColumn<int> branchPly = GeneratedColumn<int>(
    'branch_ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ucisMeta = const VerificationMeta('ucis');
  @override
  late final GeneratedColumn<String> ucis = GeneratedColumn<String>(
    'ucis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    repertoireId,
    lineKey,
    leafNodeId,
    ordinal,
    plies,
    userMoveCount,
    branchPly,
    label,
    ucis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('repertoire_id')) {
      context.handle(
        _repertoireIdMeta,
        repertoireId.isAcceptableOrUnknown(
          data['repertoire_id']!,
          _repertoireIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repertoireIdMeta);
    }
    if (data.containsKey('line_key')) {
      context.handle(
        _lineKeyMeta,
        lineKey.isAcceptableOrUnknown(data['line_key']!, _lineKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_lineKeyMeta);
    }
    if (data.containsKey('leaf_node_id')) {
      context.handle(
        _leafNodeIdMeta,
        leafNodeId.isAcceptableOrUnknown(
          data['leaf_node_id']!,
          _leafNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_leafNodeIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('plies')) {
      context.handle(
        _pliesMeta,
        plies.isAcceptableOrUnknown(data['plies']!, _pliesMeta),
      );
    } else if (isInserting) {
      context.missing(_pliesMeta);
    }
    if (data.containsKey('user_move_count')) {
      context.handle(
        _userMoveCountMeta,
        userMoveCount.isAcceptableOrUnknown(
          data['user_move_count']!,
          _userMoveCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userMoveCountMeta);
    }
    if (data.containsKey('branch_ply')) {
      context.handle(
        _branchPlyMeta,
        branchPly.isAcceptableOrUnknown(data['branch_ply']!, _branchPlyMeta),
      );
    } else if (isInserting) {
      context.missing(_branchPlyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('ucis')) {
      context.handle(
        _ucisMeta,
        ucis.isAcceptableOrUnknown(data['ucis']!, _ucisMeta),
      );
    } else if (isInserting) {
      context.missing(_ucisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {repertoireId, lineKey};
  @override
  DbLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbLine(
      repertoireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repertoire_id'],
      )!,
      lineKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_key'],
      )!,
      leafNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leaf_node_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      plies: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plies'],
      )!,
      userMoveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_move_count'],
      )!,
      branchPly: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}branch_ply'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      ucis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ucis'],
      )!,
    );
  }

  @override
  $LinesTable createAlias(String alias) {
    return $LinesTable(attachedDatabase, alias);
  }
}

class DbLine extends DataClass implements Insertable<DbLine> {
  final String repertoireId;
  final String lineKey;
  final int leafNodeId;
  final int ordinal;
  final int plies;
  final int userMoveCount;
  final int branchPly;
  final String label;
  final String ucis;
  const DbLine({
    required this.repertoireId,
    required this.lineKey,
    required this.leafNodeId,
    required this.ordinal,
    required this.plies,
    required this.userMoveCount,
    required this.branchPly,
    required this.label,
    required this.ucis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['repertoire_id'] = Variable<String>(repertoireId);
    map['line_key'] = Variable<String>(lineKey);
    map['leaf_node_id'] = Variable<int>(leafNodeId);
    map['ordinal'] = Variable<int>(ordinal);
    map['plies'] = Variable<int>(plies);
    map['user_move_count'] = Variable<int>(userMoveCount);
    map['branch_ply'] = Variable<int>(branchPly);
    map['label'] = Variable<String>(label);
    map['ucis'] = Variable<String>(ucis);
    return map;
  }

  LinesCompanion toCompanion(bool nullToAbsent) {
    return LinesCompanion(
      repertoireId: Value(repertoireId),
      lineKey: Value(lineKey),
      leafNodeId: Value(leafNodeId),
      ordinal: Value(ordinal),
      plies: Value(plies),
      userMoveCount: Value(userMoveCount),
      branchPly: Value(branchPly),
      label: Value(label),
      ucis: Value(ucis),
    );
  }

  factory DbLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbLine(
      repertoireId: serializer.fromJson<String>(json['repertoireId']),
      lineKey: serializer.fromJson<String>(json['lineKey']),
      leafNodeId: serializer.fromJson<int>(json['leafNodeId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      plies: serializer.fromJson<int>(json['plies']),
      userMoveCount: serializer.fromJson<int>(json['userMoveCount']),
      branchPly: serializer.fromJson<int>(json['branchPly']),
      label: serializer.fromJson<String>(json['label']),
      ucis: serializer.fromJson<String>(json['ucis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'repertoireId': serializer.toJson<String>(repertoireId),
      'lineKey': serializer.toJson<String>(lineKey),
      'leafNodeId': serializer.toJson<int>(leafNodeId),
      'ordinal': serializer.toJson<int>(ordinal),
      'plies': serializer.toJson<int>(plies),
      'userMoveCount': serializer.toJson<int>(userMoveCount),
      'branchPly': serializer.toJson<int>(branchPly),
      'label': serializer.toJson<String>(label),
      'ucis': serializer.toJson<String>(ucis),
    };
  }

  DbLine copyWith({
    String? repertoireId,
    String? lineKey,
    int? leafNodeId,
    int? ordinal,
    int? plies,
    int? userMoveCount,
    int? branchPly,
    String? label,
    String? ucis,
  }) => DbLine(
    repertoireId: repertoireId ?? this.repertoireId,
    lineKey: lineKey ?? this.lineKey,
    leafNodeId: leafNodeId ?? this.leafNodeId,
    ordinal: ordinal ?? this.ordinal,
    plies: plies ?? this.plies,
    userMoveCount: userMoveCount ?? this.userMoveCount,
    branchPly: branchPly ?? this.branchPly,
    label: label ?? this.label,
    ucis: ucis ?? this.ucis,
  );
  DbLine copyWithCompanion(LinesCompanion data) {
    return DbLine(
      repertoireId: data.repertoireId.present
          ? data.repertoireId.value
          : this.repertoireId,
      lineKey: data.lineKey.present ? data.lineKey.value : this.lineKey,
      leafNodeId: data.leafNodeId.present
          ? data.leafNodeId.value
          : this.leafNodeId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      plies: data.plies.present ? data.plies.value : this.plies,
      userMoveCount: data.userMoveCount.present
          ? data.userMoveCount.value
          : this.userMoveCount,
      branchPly: data.branchPly.present ? data.branchPly.value : this.branchPly,
      label: data.label.present ? data.label.value : this.label,
      ucis: data.ucis.present ? data.ucis.value : this.ucis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbLine(')
          ..write('repertoireId: $repertoireId, ')
          ..write('lineKey: $lineKey, ')
          ..write('leafNodeId: $leafNodeId, ')
          ..write('ordinal: $ordinal, ')
          ..write('plies: $plies, ')
          ..write('userMoveCount: $userMoveCount, ')
          ..write('branchPly: $branchPly, ')
          ..write('label: $label, ')
          ..write('ucis: $ucis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    repertoireId,
    lineKey,
    leafNodeId,
    ordinal,
    plies,
    userMoveCount,
    branchPly,
    label,
    ucis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbLine &&
          other.repertoireId == this.repertoireId &&
          other.lineKey == this.lineKey &&
          other.leafNodeId == this.leafNodeId &&
          other.ordinal == this.ordinal &&
          other.plies == this.plies &&
          other.userMoveCount == this.userMoveCount &&
          other.branchPly == this.branchPly &&
          other.label == this.label &&
          other.ucis == this.ucis);
}

class LinesCompanion extends UpdateCompanion<DbLine> {
  final Value<String> repertoireId;
  final Value<String> lineKey;
  final Value<int> leafNodeId;
  final Value<int> ordinal;
  final Value<int> plies;
  final Value<int> userMoveCount;
  final Value<int> branchPly;
  final Value<String> label;
  final Value<String> ucis;
  final Value<int> rowid;
  const LinesCompanion({
    this.repertoireId = const Value.absent(),
    this.lineKey = const Value.absent(),
    this.leafNodeId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.plies = const Value.absent(),
    this.userMoveCount = const Value.absent(),
    this.branchPly = const Value.absent(),
    this.label = const Value.absent(),
    this.ucis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinesCompanion.insert({
    required String repertoireId,
    required String lineKey,
    required int leafNodeId,
    required int ordinal,
    required int plies,
    required int userMoveCount,
    required int branchPly,
    required String label,
    required String ucis,
    this.rowid = const Value.absent(),
  }) : repertoireId = Value(repertoireId),
       lineKey = Value(lineKey),
       leafNodeId = Value(leafNodeId),
       ordinal = Value(ordinal),
       plies = Value(plies),
       userMoveCount = Value(userMoveCount),
       branchPly = Value(branchPly),
       label = Value(label),
       ucis = Value(ucis);
  static Insertable<DbLine> custom({
    Expression<String>? repertoireId,
    Expression<String>? lineKey,
    Expression<int>? leafNodeId,
    Expression<int>? ordinal,
    Expression<int>? plies,
    Expression<int>? userMoveCount,
    Expression<int>? branchPly,
    Expression<String>? label,
    Expression<String>? ucis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (repertoireId != null) 'repertoire_id': repertoireId,
      if (lineKey != null) 'line_key': lineKey,
      if (leafNodeId != null) 'leaf_node_id': leafNodeId,
      if (ordinal != null) 'ordinal': ordinal,
      if (plies != null) 'plies': plies,
      if (userMoveCount != null) 'user_move_count': userMoveCount,
      if (branchPly != null) 'branch_ply': branchPly,
      if (label != null) 'label': label,
      if (ucis != null) 'ucis': ucis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinesCompanion copyWith({
    Value<String>? repertoireId,
    Value<String>? lineKey,
    Value<int>? leafNodeId,
    Value<int>? ordinal,
    Value<int>? plies,
    Value<int>? userMoveCount,
    Value<int>? branchPly,
    Value<String>? label,
    Value<String>? ucis,
    Value<int>? rowid,
  }) {
    return LinesCompanion(
      repertoireId: repertoireId ?? this.repertoireId,
      lineKey: lineKey ?? this.lineKey,
      leafNodeId: leafNodeId ?? this.leafNodeId,
      ordinal: ordinal ?? this.ordinal,
      plies: plies ?? this.plies,
      userMoveCount: userMoveCount ?? this.userMoveCount,
      branchPly: branchPly ?? this.branchPly,
      label: label ?? this.label,
      ucis: ucis ?? this.ucis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (repertoireId.present) {
      map['repertoire_id'] = Variable<String>(repertoireId.value);
    }
    if (lineKey.present) {
      map['line_key'] = Variable<String>(lineKey.value);
    }
    if (leafNodeId.present) {
      map['leaf_node_id'] = Variable<int>(leafNodeId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (plies.present) {
      map['plies'] = Variable<int>(plies.value);
    }
    if (userMoveCount.present) {
      map['user_move_count'] = Variable<int>(userMoveCount.value);
    }
    if (branchPly.present) {
      map['branch_ply'] = Variable<int>(branchPly.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (ucis.present) {
      map['ucis'] = Variable<String>(ucis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinesCompanion(')
          ..write('repertoireId: $repertoireId, ')
          ..write('lineKey: $lineKey, ')
          ..write('leafNodeId: $leafNodeId, ')
          ..write('ordinal: $ordinal, ')
          ..write('plies: $plies, ')
          ..write('userMoveCount: $userMoveCount, ')
          ..write('branchPly: $branchPly, ')
          ..write('label: $label, ')
          ..write('ucis: $ucis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunsTable extends Runs with TableInfo<$RunsTable, DbRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repertoireIdMeta = const VerificationMeta(
    'repertoireId',
  );
  @override
  late final GeneratedColumn<String> repertoireId = GeneratedColumn<String>(
    'repertoire_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineKeyMeta = const VerificationMeta(
    'lineKey',
  );
  @override
  late final GeneratedColumn<String> lineKey = GeneratedColumn<String>(
    'line_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ucisMeta = const VerificationMeta('ucis');
  @override
  late final GeneratedColumn<String> ucis = GeneratedColumn<String>(
    'ucis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPlyMeta = const VerificationMeta(
    'startPly',
  );
  @override
  late final GeneratedColumn<int> startPly = GeneratedColumn<int>(
    'start_ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrongMoveModeMeta = const VerificationMeta(
    'wrongMoveMode',
  );
  @override
  late final GeneratedColumn<String> wrongMoveMode = GeneratedColumn<String>(
    'wrong_move_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDayMeta = const VerificationMeta(
    'localDay',
  );
  @override
  late final GeneratedColumn<String> localDay = GeneratedColumn<String>(
    'local_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _deviatedMeta = const VerificationMeta(
    'deviated',
  );
  @override
  late final GeneratedColumn<bool> deviated = GeneratedColumn<bool>(
    'deviated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deviated" IN (0, 1))',
    ),
  );
  static const VerificationMeta _gradedCountMeta = const VerificationMeta(
    'gradedCount',
  );
  @override
  late final GeneratedColumn<int> gradedCount = GeneratedColumn<int>(
    'graded_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditSumMeta = const VerificationMeta(
    'creditSum',
  );
  @override
  late final GeneratedColumn<double> creditSum = GeneratedColumn<double>(
    'credit_sum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintCountMeta = const VerificationMeta(
    'hintCount',
  );
  @override
  late final GeneratedColumn<int> hintCount = GeneratedColumn<int>(
    'hint_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaMeta = const VerificationMeta('schema');
  @override
  late final GeneratedColumn<int> schema = GeneratedColumn<int>(
    'schema',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    repertoireId,
    lineKey,
    ucis,
    mode,
    startPly,
    wrongMoveMode,
    startedAt,
    finishedAt,
    localDay,
    completed,
    deviated,
    gradedCount,
    creditSum,
    hintCount,
    deviceId,
    syncedAt,
    schema,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('repertoire_id')) {
      context.handle(
        _repertoireIdMeta,
        repertoireId.isAcceptableOrUnknown(
          data['repertoire_id']!,
          _repertoireIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repertoireIdMeta);
    }
    if (data.containsKey('line_key')) {
      context.handle(
        _lineKeyMeta,
        lineKey.isAcceptableOrUnknown(data['line_key']!, _lineKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_lineKeyMeta);
    }
    if (data.containsKey('ucis')) {
      context.handle(
        _ucisMeta,
        ucis.isAcceptableOrUnknown(data['ucis']!, _ucisMeta),
      );
    } else if (isInserting) {
      context.missing(_ucisMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('start_ply')) {
      context.handle(
        _startPlyMeta,
        startPly.isAcceptableOrUnknown(data['start_ply']!, _startPlyMeta),
      );
    } else if (isInserting) {
      context.missing(_startPlyMeta);
    }
    if (data.containsKey('wrong_move_mode')) {
      context.handle(
        _wrongMoveModeMeta,
        wrongMoveMode.isAcceptableOrUnknown(
          data['wrong_move_mode']!,
          _wrongMoveModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wrongMoveModeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('local_day')) {
      context.handle(
        _localDayMeta,
        localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta),
      );
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('deviated')) {
      context.handle(
        _deviatedMeta,
        deviated.isAcceptableOrUnknown(data['deviated']!, _deviatedMeta),
      );
    } else if (isInserting) {
      context.missing(_deviatedMeta);
    }
    if (data.containsKey('graded_count')) {
      context.handle(
        _gradedCountMeta,
        gradedCount.isAcceptableOrUnknown(
          data['graded_count']!,
          _gradedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gradedCountMeta);
    }
    if (data.containsKey('credit_sum')) {
      context.handle(
        _creditSumMeta,
        creditSum.isAcceptableOrUnknown(data['credit_sum']!, _creditSumMeta),
      );
    } else if (isInserting) {
      context.missing(_creditSumMeta);
    }
    if (data.containsKey('hint_count')) {
      context.handle(
        _hintCountMeta,
        hintCount.isAcceptableOrUnknown(data['hint_count']!, _hintCountMeta),
      );
    } else if (isInserting) {
      context.missing(_hintCountMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('schema')) {
      context.handle(
        _schemaMeta,
        schema.isAcceptableOrUnknown(data['schema']!, _schemaMeta),
      );
    } else if (isInserting) {
      context.missing(_schemaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      repertoireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repertoire_id'],
      )!,
      lineKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_key'],
      )!,
      ucis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ucis'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      startPly: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ply'],
      )!,
      wrongMoveMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wrong_move_mode'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      )!,
      localDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_day'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      deviated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deviated'],
      )!,
      gradedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}graded_count'],
      )!,
      creditSum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_sum'],
      )!,
      hintCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hint_count'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      schema: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema'],
      )!,
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class DbRun extends DataClass implements Insertable<DbRun> {
  final String id;
  final String repertoireId;
  final String lineKey;
  final String ucis;
  final String mode;
  final int startPly;
  final String wrongMoveMode;
  final int startedAt;
  final int finishedAt;
  final String localDay;
  final bool completed;
  final bool deviated;
  final int gradedCount;
  final double creditSum;
  final int hintCount;
  final String deviceId;

  /// Local only: when uploaded.
  final int? syncedAt;
  final int schema;
  const DbRun({
    required this.id,
    required this.repertoireId,
    required this.lineKey,
    required this.ucis,
    required this.mode,
    required this.startPly,
    required this.wrongMoveMode,
    required this.startedAt,
    required this.finishedAt,
    required this.localDay,
    required this.completed,
    required this.deviated,
    required this.gradedCount,
    required this.creditSum,
    required this.hintCount,
    required this.deviceId,
    this.syncedAt,
    required this.schema,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['repertoire_id'] = Variable<String>(repertoireId);
    map['line_key'] = Variable<String>(lineKey);
    map['ucis'] = Variable<String>(ucis);
    map['mode'] = Variable<String>(mode);
    map['start_ply'] = Variable<int>(startPly);
    map['wrong_move_mode'] = Variable<String>(wrongMoveMode);
    map['started_at'] = Variable<int>(startedAt);
    map['finished_at'] = Variable<int>(finishedAt);
    map['local_day'] = Variable<String>(localDay);
    map['completed'] = Variable<bool>(completed);
    map['deviated'] = Variable<bool>(deviated);
    map['graded_count'] = Variable<int>(gradedCount);
    map['credit_sum'] = Variable<double>(creditSum);
    map['hint_count'] = Variable<int>(hintCount);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    map['schema'] = Variable<int>(schema);
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      repertoireId: Value(repertoireId),
      lineKey: Value(lineKey),
      ucis: Value(ucis),
      mode: Value(mode),
      startPly: Value(startPly),
      wrongMoveMode: Value(wrongMoveMode),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      localDay: Value(localDay),
      completed: Value(completed),
      deviated: Value(deviated),
      gradedCount: Value(gradedCount),
      creditSum: Value(creditSum),
      hintCount: Value(hintCount),
      deviceId: Value(deviceId),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      schema: Value(schema),
    );
  }

  factory DbRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRun(
      id: serializer.fromJson<String>(json['id']),
      repertoireId: serializer.fromJson<String>(json['repertoireId']),
      lineKey: serializer.fromJson<String>(json['lineKey']),
      ucis: serializer.fromJson<String>(json['ucis']),
      mode: serializer.fromJson<String>(json['mode']),
      startPly: serializer.fromJson<int>(json['startPly']),
      wrongMoveMode: serializer.fromJson<String>(json['wrongMoveMode']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      finishedAt: serializer.fromJson<int>(json['finishedAt']),
      localDay: serializer.fromJson<String>(json['localDay']),
      completed: serializer.fromJson<bool>(json['completed']),
      deviated: serializer.fromJson<bool>(json['deviated']),
      gradedCount: serializer.fromJson<int>(json['gradedCount']),
      creditSum: serializer.fromJson<double>(json['creditSum']),
      hintCount: serializer.fromJson<int>(json['hintCount']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      schema: serializer.fromJson<int>(json['schema']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'repertoireId': serializer.toJson<String>(repertoireId),
      'lineKey': serializer.toJson<String>(lineKey),
      'ucis': serializer.toJson<String>(ucis),
      'mode': serializer.toJson<String>(mode),
      'startPly': serializer.toJson<int>(startPly),
      'wrongMoveMode': serializer.toJson<String>(wrongMoveMode),
      'startedAt': serializer.toJson<int>(startedAt),
      'finishedAt': serializer.toJson<int>(finishedAt),
      'localDay': serializer.toJson<String>(localDay),
      'completed': serializer.toJson<bool>(completed),
      'deviated': serializer.toJson<bool>(deviated),
      'gradedCount': serializer.toJson<int>(gradedCount),
      'creditSum': serializer.toJson<double>(creditSum),
      'hintCount': serializer.toJson<int>(hintCount),
      'deviceId': serializer.toJson<String>(deviceId),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'schema': serializer.toJson<int>(schema),
    };
  }

  DbRun copyWith({
    String? id,
    String? repertoireId,
    String? lineKey,
    String? ucis,
    String? mode,
    int? startPly,
    String? wrongMoveMode,
    int? startedAt,
    int? finishedAt,
    String? localDay,
    bool? completed,
    bool? deviated,
    int? gradedCount,
    double? creditSum,
    int? hintCount,
    String? deviceId,
    Value<int?> syncedAt = const Value.absent(),
    int? schema,
  }) => DbRun(
    id: id ?? this.id,
    repertoireId: repertoireId ?? this.repertoireId,
    lineKey: lineKey ?? this.lineKey,
    ucis: ucis ?? this.ucis,
    mode: mode ?? this.mode,
    startPly: startPly ?? this.startPly,
    wrongMoveMode: wrongMoveMode ?? this.wrongMoveMode,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    localDay: localDay ?? this.localDay,
    completed: completed ?? this.completed,
    deviated: deviated ?? this.deviated,
    gradedCount: gradedCount ?? this.gradedCount,
    creditSum: creditSum ?? this.creditSum,
    hintCount: hintCount ?? this.hintCount,
    deviceId: deviceId ?? this.deviceId,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    schema: schema ?? this.schema,
  );
  DbRun copyWithCompanion(RunsCompanion data) {
    return DbRun(
      id: data.id.present ? data.id.value : this.id,
      repertoireId: data.repertoireId.present
          ? data.repertoireId.value
          : this.repertoireId,
      lineKey: data.lineKey.present ? data.lineKey.value : this.lineKey,
      ucis: data.ucis.present ? data.ucis.value : this.ucis,
      mode: data.mode.present ? data.mode.value : this.mode,
      startPly: data.startPly.present ? data.startPly.value : this.startPly,
      wrongMoveMode: data.wrongMoveMode.present
          ? data.wrongMoveMode.value
          : this.wrongMoveMode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      completed: data.completed.present ? data.completed.value : this.completed,
      deviated: data.deviated.present ? data.deviated.value : this.deviated,
      gradedCount: data.gradedCount.present
          ? data.gradedCount.value
          : this.gradedCount,
      creditSum: data.creditSum.present ? data.creditSum.value : this.creditSum,
      hintCount: data.hintCount.present ? data.hintCount.value : this.hintCount,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      schema: data.schema.present ? data.schema.value : this.schema,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRun(')
          ..write('id: $id, ')
          ..write('repertoireId: $repertoireId, ')
          ..write('lineKey: $lineKey, ')
          ..write('ucis: $ucis, ')
          ..write('mode: $mode, ')
          ..write('startPly: $startPly, ')
          ..write('wrongMoveMode: $wrongMoveMode, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('localDay: $localDay, ')
          ..write('completed: $completed, ')
          ..write('deviated: $deviated, ')
          ..write('gradedCount: $gradedCount, ')
          ..write('creditSum: $creditSum, ')
          ..write('hintCount: $hintCount, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('schema: $schema')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    repertoireId,
    lineKey,
    ucis,
    mode,
    startPly,
    wrongMoveMode,
    startedAt,
    finishedAt,
    localDay,
    completed,
    deviated,
    gradedCount,
    creditSum,
    hintCount,
    deviceId,
    syncedAt,
    schema,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRun &&
          other.id == this.id &&
          other.repertoireId == this.repertoireId &&
          other.lineKey == this.lineKey &&
          other.ucis == this.ucis &&
          other.mode == this.mode &&
          other.startPly == this.startPly &&
          other.wrongMoveMode == this.wrongMoveMode &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.localDay == this.localDay &&
          other.completed == this.completed &&
          other.deviated == this.deviated &&
          other.gradedCount == this.gradedCount &&
          other.creditSum == this.creditSum &&
          other.hintCount == this.hintCount &&
          other.deviceId == this.deviceId &&
          other.syncedAt == this.syncedAt &&
          other.schema == this.schema);
}

class RunsCompanion extends UpdateCompanion<DbRun> {
  final Value<String> id;
  final Value<String> repertoireId;
  final Value<String> lineKey;
  final Value<String> ucis;
  final Value<String> mode;
  final Value<int> startPly;
  final Value<String> wrongMoveMode;
  final Value<int> startedAt;
  final Value<int> finishedAt;
  final Value<String> localDay;
  final Value<bool> completed;
  final Value<bool> deviated;
  final Value<int> gradedCount;
  final Value<double> creditSum;
  final Value<int> hintCount;
  final Value<String> deviceId;
  final Value<int?> syncedAt;
  final Value<int> schema;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.repertoireId = const Value.absent(),
    this.lineKey = const Value.absent(),
    this.ucis = const Value.absent(),
    this.mode = const Value.absent(),
    this.startPly = const Value.absent(),
    this.wrongMoveMode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.localDay = const Value.absent(),
    this.completed = const Value.absent(),
    this.deviated = const Value.absent(),
    this.gradedCount = const Value.absent(),
    this.creditSum = const Value.absent(),
    this.hintCount = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.schema = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required String repertoireId,
    required String lineKey,
    required String ucis,
    required String mode,
    required int startPly,
    required String wrongMoveMode,
    required int startedAt,
    required int finishedAt,
    required String localDay,
    required bool completed,
    required bool deviated,
    required int gradedCount,
    required double creditSum,
    required int hintCount,
    required String deviceId,
    this.syncedAt = const Value.absent(),
    required int schema,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       repertoireId = Value(repertoireId),
       lineKey = Value(lineKey),
       ucis = Value(ucis),
       mode = Value(mode),
       startPly = Value(startPly),
       wrongMoveMode = Value(wrongMoveMode),
       startedAt = Value(startedAt),
       finishedAt = Value(finishedAt),
       localDay = Value(localDay),
       completed = Value(completed),
       deviated = Value(deviated),
       gradedCount = Value(gradedCount),
       creditSum = Value(creditSum),
       hintCount = Value(hintCount),
       deviceId = Value(deviceId),
       schema = Value(schema);
  static Insertable<DbRun> custom({
    Expression<String>? id,
    Expression<String>? repertoireId,
    Expression<String>? lineKey,
    Expression<String>? ucis,
    Expression<String>? mode,
    Expression<int>? startPly,
    Expression<String>? wrongMoveMode,
    Expression<int>? startedAt,
    Expression<int>? finishedAt,
    Expression<String>? localDay,
    Expression<bool>? completed,
    Expression<bool>? deviated,
    Expression<int>? gradedCount,
    Expression<double>? creditSum,
    Expression<int>? hintCount,
    Expression<String>? deviceId,
    Expression<int>? syncedAt,
    Expression<int>? schema,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repertoireId != null) 'repertoire_id': repertoireId,
      if (lineKey != null) 'line_key': lineKey,
      if (ucis != null) 'ucis': ucis,
      if (mode != null) 'mode': mode,
      if (startPly != null) 'start_ply': startPly,
      if (wrongMoveMode != null) 'wrong_move_mode': wrongMoveMode,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (localDay != null) 'local_day': localDay,
      if (completed != null) 'completed': completed,
      if (deviated != null) 'deviated': deviated,
      if (gradedCount != null) 'graded_count': gradedCount,
      if (creditSum != null) 'credit_sum': creditSum,
      if (hintCount != null) 'hint_count': hintCount,
      if (deviceId != null) 'device_id': deviceId,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (schema != null) 'schema': schema,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<String>? repertoireId,
    Value<String>? lineKey,
    Value<String>? ucis,
    Value<String>? mode,
    Value<int>? startPly,
    Value<String>? wrongMoveMode,
    Value<int>? startedAt,
    Value<int>? finishedAt,
    Value<String>? localDay,
    Value<bool>? completed,
    Value<bool>? deviated,
    Value<int>? gradedCount,
    Value<double>? creditSum,
    Value<int>? hintCount,
    Value<String>? deviceId,
    Value<int?>? syncedAt,
    Value<int>? schema,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      repertoireId: repertoireId ?? this.repertoireId,
      lineKey: lineKey ?? this.lineKey,
      ucis: ucis ?? this.ucis,
      mode: mode ?? this.mode,
      startPly: startPly ?? this.startPly,
      wrongMoveMode: wrongMoveMode ?? this.wrongMoveMode,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      localDay: localDay ?? this.localDay,
      completed: completed ?? this.completed,
      deviated: deviated ?? this.deviated,
      gradedCount: gradedCount ?? this.gradedCount,
      creditSum: creditSum ?? this.creditSum,
      hintCount: hintCount ?? this.hintCount,
      deviceId: deviceId ?? this.deviceId,
      syncedAt: syncedAt ?? this.syncedAt,
      schema: schema ?? this.schema,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (repertoireId.present) {
      map['repertoire_id'] = Variable<String>(repertoireId.value);
    }
    if (lineKey.present) {
      map['line_key'] = Variable<String>(lineKey.value);
    }
    if (ucis.present) {
      map['ucis'] = Variable<String>(ucis.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (startPly.present) {
      map['start_ply'] = Variable<int>(startPly.value);
    }
    if (wrongMoveMode.present) {
      map['wrong_move_mode'] = Variable<String>(wrongMoveMode.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (localDay.present) {
      map['local_day'] = Variable<String>(localDay.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (deviated.present) {
      map['deviated'] = Variable<bool>(deviated.value);
    }
    if (gradedCount.present) {
      map['graded_count'] = Variable<int>(gradedCount.value);
    }
    if (creditSum.present) {
      map['credit_sum'] = Variable<double>(creditSum.value);
    }
    if (hintCount.present) {
      map['hint_count'] = Variable<int>(hintCount.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (schema.present) {
      map['schema'] = Variable<int>(schema.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('repertoireId: $repertoireId, ')
          ..write('lineKey: $lineKey, ')
          ..write('ucis: $ucis, ')
          ..write('mode: $mode, ')
          ..write('startPly: $startPly, ')
          ..write('wrongMoveMode: $wrongMoveMode, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('localDay: $localDay, ')
          ..write('completed: $completed, ')
          ..write('deviated: $deviated, ')
          ..write('gradedCount: $gradedCount, ')
          ..write('creditSum: $creditSum, ')
          ..write('hintCount: $hintCount, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('schema: $schema, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoveGradesTable extends MoveGrades
    with TableInfo<$MoveGradesTable, DbMoveGrade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoveGradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedMeta = const VerificationMeta(
    'expected',
  );
  @override
  late final GeneratedColumn<String> expected = GeneratedColumn<String>(
    'expected',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedMeta = const VerificationMeta(
    'accepted',
  );
  @override
  late final GeneratedColumn<String> accepted = GeneratedColumn<String>(
    'accepted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstAttemptMeta = const VerificationMeta(
    'firstAttempt',
  );
  @override
  late final GeneratedColumn<String> firstAttempt = GeneratedColumn<String>(
    'first_attempt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<double> credit = GeneratedColumn<double>(
    'credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintLevelMeta = const VerificationMeta(
    'hintLevel',
  );
  @override
  late final GeneratedColumn<int> hintLevel = GeneratedColumn<int>(
    'hint_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkCpMeta = const VerificationMeta(
    'checkCp',
  );
  @override
  late final GeneratedColumn<int> checkCp = GeneratedColumn<int>(
    'check_cp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkStatusMeta = const VerificationMeta(
    'checkStatus',
  );
  @override
  late final GeneratedColumn<String> checkStatus = GeneratedColumn<String>(
    'check_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    ply,
    expected,
    accepted,
    firstAttempt,
    result,
    credit,
    attempts,
    hintLevel,
    checkCp,
    checkStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'move_grades';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbMoveGrade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('expected')) {
      context.handle(
        _expectedMeta,
        expected.isAcceptableOrUnknown(data['expected']!, _expectedMeta),
      );
    } else if (isInserting) {
      context.missing(_expectedMeta);
    }
    if (data.containsKey('accepted')) {
      context.handle(
        _acceptedMeta,
        accepted.isAcceptableOrUnknown(data['accepted']!, _acceptedMeta),
      );
    } else if (isInserting) {
      context.missing(_acceptedMeta);
    }
    if (data.containsKey('first_attempt')) {
      context.handle(
        _firstAttemptMeta,
        firstAttempt.isAcceptableOrUnknown(
          data['first_attempt']!,
          _firstAttemptMeta,
        ),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('credit')) {
      context.handle(
        _creditMeta,
        credit.isAcceptableOrUnknown(data['credit']!, _creditMeta),
      );
    } else if (isInserting) {
      context.missing(_creditMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('hint_level')) {
      context.handle(
        _hintLevelMeta,
        hintLevel.isAcceptableOrUnknown(data['hint_level']!, _hintLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_hintLevelMeta);
    }
    if (data.containsKey('check_cp')) {
      context.handle(
        _checkCpMeta,
        checkCp.isAcceptableOrUnknown(data['check_cp']!, _checkCpMeta),
      );
    }
    if (data.containsKey('check_status')) {
      context.handle(
        _checkStatusMeta,
        checkStatus.isAcceptableOrUnknown(
          data['check_status']!,
          _checkStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId, ply};
  @override
  DbMoveGrade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbMoveGrade(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      expected: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected'],
      )!,
      accepted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accepted'],
      )!,
      firstAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_attempt'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      credit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      hintLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hint_level'],
      )!,
      checkCp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}check_cp'],
      ),
      checkStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_status'],
      ),
    );
  }

  @override
  $MoveGradesTable createAlias(String alias) {
    return $MoveGradesTable(attachedDatabase, alias);
  }
}

class DbMoveGrade extends DataClass implements Insertable<DbMoveGrade> {
  final String runId;
  final int ply;
  final String expected;
  final String accepted;
  final String? firstAttempt;
  final String result;
  final double credit;
  final int attempts;
  final int hintLevel;
  final int? checkCp;
  final String? checkStatus;
  const DbMoveGrade({
    required this.runId,
    required this.ply,
    required this.expected,
    required this.accepted,
    this.firstAttempt,
    required this.result,
    required this.credit,
    required this.attempts,
    required this.hintLevel,
    this.checkCp,
    this.checkStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['ply'] = Variable<int>(ply);
    map['expected'] = Variable<String>(expected);
    map['accepted'] = Variable<String>(accepted);
    if (!nullToAbsent || firstAttempt != null) {
      map['first_attempt'] = Variable<String>(firstAttempt);
    }
    map['result'] = Variable<String>(result);
    map['credit'] = Variable<double>(credit);
    map['attempts'] = Variable<int>(attempts);
    map['hint_level'] = Variable<int>(hintLevel);
    if (!nullToAbsent || checkCp != null) {
      map['check_cp'] = Variable<int>(checkCp);
    }
    if (!nullToAbsent || checkStatus != null) {
      map['check_status'] = Variable<String>(checkStatus);
    }
    return map;
  }

  MoveGradesCompanion toCompanion(bool nullToAbsent) {
    return MoveGradesCompanion(
      runId: Value(runId),
      ply: Value(ply),
      expected: Value(expected),
      accepted: Value(accepted),
      firstAttempt: firstAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstAttempt),
      result: Value(result),
      credit: Value(credit),
      attempts: Value(attempts),
      hintLevel: Value(hintLevel),
      checkCp: checkCp == null && nullToAbsent
          ? const Value.absent()
          : Value(checkCp),
      checkStatus: checkStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(checkStatus),
    );
  }

  factory DbMoveGrade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbMoveGrade(
      runId: serializer.fromJson<String>(json['runId']),
      ply: serializer.fromJson<int>(json['ply']),
      expected: serializer.fromJson<String>(json['expected']),
      accepted: serializer.fromJson<String>(json['accepted']),
      firstAttempt: serializer.fromJson<String?>(json['firstAttempt']),
      result: serializer.fromJson<String>(json['result']),
      credit: serializer.fromJson<double>(json['credit']),
      attempts: serializer.fromJson<int>(json['attempts']),
      hintLevel: serializer.fromJson<int>(json['hintLevel']),
      checkCp: serializer.fromJson<int?>(json['checkCp']),
      checkStatus: serializer.fromJson<String?>(json['checkStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'ply': serializer.toJson<int>(ply),
      'expected': serializer.toJson<String>(expected),
      'accepted': serializer.toJson<String>(accepted),
      'firstAttempt': serializer.toJson<String?>(firstAttempt),
      'result': serializer.toJson<String>(result),
      'credit': serializer.toJson<double>(credit),
      'attempts': serializer.toJson<int>(attempts),
      'hintLevel': serializer.toJson<int>(hintLevel),
      'checkCp': serializer.toJson<int?>(checkCp),
      'checkStatus': serializer.toJson<String?>(checkStatus),
    };
  }

  DbMoveGrade copyWith({
    String? runId,
    int? ply,
    String? expected,
    String? accepted,
    Value<String?> firstAttempt = const Value.absent(),
    String? result,
    double? credit,
    int? attempts,
    int? hintLevel,
    Value<int?> checkCp = const Value.absent(),
    Value<String?> checkStatus = const Value.absent(),
  }) => DbMoveGrade(
    runId: runId ?? this.runId,
    ply: ply ?? this.ply,
    expected: expected ?? this.expected,
    accepted: accepted ?? this.accepted,
    firstAttempt: firstAttempt.present ? firstAttempt.value : this.firstAttempt,
    result: result ?? this.result,
    credit: credit ?? this.credit,
    attempts: attempts ?? this.attempts,
    hintLevel: hintLevel ?? this.hintLevel,
    checkCp: checkCp.present ? checkCp.value : this.checkCp,
    checkStatus: checkStatus.present ? checkStatus.value : this.checkStatus,
  );
  DbMoveGrade copyWithCompanion(MoveGradesCompanion data) {
    return DbMoveGrade(
      runId: data.runId.present ? data.runId.value : this.runId,
      ply: data.ply.present ? data.ply.value : this.ply,
      expected: data.expected.present ? data.expected.value : this.expected,
      accepted: data.accepted.present ? data.accepted.value : this.accepted,
      firstAttempt: data.firstAttempt.present
          ? data.firstAttempt.value
          : this.firstAttempt,
      result: data.result.present ? data.result.value : this.result,
      credit: data.credit.present ? data.credit.value : this.credit,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      hintLevel: data.hintLevel.present ? data.hintLevel.value : this.hintLevel,
      checkCp: data.checkCp.present ? data.checkCp.value : this.checkCp,
      checkStatus: data.checkStatus.present
          ? data.checkStatus.value
          : this.checkStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbMoveGrade(')
          ..write('runId: $runId, ')
          ..write('ply: $ply, ')
          ..write('expected: $expected, ')
          ..write('accepted: $accepted, ')
          ..write('firstAttempt: $firstAttempt, ')
          ..write('result: $result, ')
          ..write('credit: $credit, ')
          ..write('attempts: $attempts, ')
          ..write('hintLevel: $hintLevel, ')
          ..write('checkCp: $checkCp, ')
          ..write('checkStatus: $checkStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    runId,
    ply,
    expected,
    accepted,
    firstAttempt,
    result,
    credit,
    attempts,
    hintLevel,
    checkCp,
    checkStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbMoveGrade &&
          other.runId == this.runId &&
          other.ply == this.ply &&
          other.expected == this.expected &&
          other.accepted == this.accepted &&
          other.firstAttempt == this.firstAttempt &&
          other.result == this.result &&
          other.credit == this.credit &&
          other.attempts == this.attempts &&
          other.hintLevel == this.hintLevel &&
          other.checkCp == this.checkCp &&
          other.checkStatus == this.checkStatus);
}

class MoveGradesCompanion extends UpdateCompanion<DbMoveGrade> {
  final Value<String> runId;
  final Value<int> ply;
  final Value<String> expected;
  final Value<String> accepted;
  final Value<String?> firstAttempt;
  final Value<String> result;
  final Value<double> credit;
  final Value<int> attempts;
  final Value<int> hintLevel;
  final Value<int?> checkCp;
  final Value<String?> checkStatus;
  final Value<int> rowid;
  const MoveGradesCompanion({
    this.runId = const Value.absent(),
    this.ply = const Value.absent(),
    this.expected = const Value.absent(),
    this.accepted = const Value.absent(),
    this.firstAttempt = const Value.absent(),
    this.result = const Value.absent(),
    this.credit = const Value.absent(),
    this.attempts = const Value.absent(),
    this.hintLevel = const Value.absent(),
    this.checkCp = const Value.absent(),
    this.checkStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoveGradesCompanion.insert({
    required String runId,
    required int ply,
    required String expected,
    required String accepted,
    this.firstAttempt = const Value.absent(),
    required String result,
    required double credit,
    required int attempts,
    required int hintLevel,
    this.checkCp = const Value.absent(),
    this.checkStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       ply = Value(ply),
       expected = Value(expected),
       accepted = Value(accepted),
       result = Value(result),
       credit = Value(credit),
       attempts = Value(attempts),
       hintLevel = Value(hintLevel);
  static Insertable<DbMoveGrade> custom({
    Expression<String>? runId,
    Expression<int>? ply,
    Expression<String>? expected,
    Expression<String>? accepted,
    Expression<String>? firstAttempt,
    Expression<String>? result,
    Expression<double>? credit,
    Expression<int>? attempts,
    Expression<int>? hintLevel,
    Expression<int>? checkCp,
    Expression<String>? checkStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (ply != null) 'ply': ply,
      if (expected != null) 'expected': expected,
      if (accepted != null) 'accepted': accepted,
      if (firstAttempt != null) 'first_attempt': firstAttempt,
      if (result != null) 'result': result,
      if (credit != null) 'credit': credit,
      if (attempts != null) 'attempts': attempts,
      if (hintLevel != null) 'hint_level': hintLevel,
      if (checkCp != null) 'check_cp': checkCp,
      if (checkStatus != null) 'check_status': checkStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoveGradesCompanion copyWith({
    Value<String>? runId,
    Value<int>? ply,
    Value<String>? expected,
    Value<String>? accepted,
    Value<String?>? firstAttempt,
    Value<String>? result,
    Value<double>? credit,
    Value<int>? attempts,
    Value<int>? hintLevel,
    Value<int?>? checkCp,
    Value<String?>? checkStatus,
    Value<int>? rowid,
  }) {
    return MoveGradesCompanion(
      runId: runId ?? this.runId,
      ply: ply ?? this.ply,
      expected: expected ?? this.expected,
      accepted: accepted ?? this.accepted,
      firstAttempt: firstAttempt ?? this.firstAttempt,
      result: result ?? this.result,
      credit: credit ?? this.credit,
      attempts: attempts ?? this.attempts,
      hintLevel: hintLevel ?? this.hintLevel,
      checkCp: checkCp ?? this.checkCp,
      checkStatus: checkStatus ?? this.checkStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (expected.present) {
      map['expected'] = Variable<String>(expected.value);
    }
    if (accepted.present) {
      map['accepted'] = Variable<String>(accepted.value);
    }
    if (firstAttempt.present) {
      map['first_attempt'] = Variable<String>(firstAttempt.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (hintLevel.present) {
      map['hint_level'] = Variable<int>(hintLevel.value);
    }
    if (checkCp.present) {
      map['check_cp'] = Variable<int>(checkCp.value);
    }
    if (checkStatus.present) {
      map['check_status'] = Variable<String>(checkStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoveGradesCompanion(')
          ..write('runId: $runId, ')
          ..write('ply: $ply, ')
          ..write('expected: $expected, ')
          ..write('accepted: $accepted, ')
          ..write('firstAttempt: $firstAttempt, ')
          ..write('result: $result, ')
          ..write('credit: $credit, ')
          ..write('attempts: $attempts, ')
          ..write('hintLevel: $hintLevel, ')
          ..write('checkCp: $checkCp, ')
          ..write('checkStatus: $checkStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviationEventsTable extends DeviationEvents
    with TableInfo<$DeviationEventsTable, DbDeviationEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviationEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviationUciMeta = const VerificationMeta(
    'deviationUci',
  );
  @override
  late final GeneratedColumn<String> deviationUci = GeneratedColumn<String>(
    'deviation_uci',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyUciMeta = const VerificationMeta(
    'replyUci',
  );
  @override
  late final GeneratedColumn<String> replyUci = GeneratedColumn<String>(
    'reply_uci',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestUciMeta = const VerificationMeta(
    'bestUci',
  );
  @override
  late final GeneratedColumn<String> bestUci = GeneratedColumn<String>(
    'best_uci',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lossCpMeta = const VerificationMeta('lossCp');
  @override
  late final GeneratedColumn<int> lossCp = GeneratedColumn<int>(
    'loss_cp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    ply,
    deviationUci,
    replyUci,
    bestUci,
    lossCp,
    passed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deviation_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDeviationEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('deviation_uci')) {
      context.handle(
        _deviationUciMeta,
        deviationUci.isAcceptableOrUnknown(
          data['deviation_uci']!,
          _deviationUciMeta,
        ),
      );
    }
    if (data.containsKey('reply_uci')) {
      context.handle(
        _replyUciMeta,
        replyUci.isAcceptableOrUnknown(data['reply_uci']!, _replyUciMeta),
      );
    }
    if (data.containsKey('best_uci')) {
      context.handle(
        _bestUciMeta,
        bestUci.isAcceptableOrUnknown(data['best_uci']!, _bestUciMeta),
      );
    } else if (isInserting) {
      context.missing(_bestUciMeta);
    }
    if (data.containsKey('loss_cp')) {
      context.handle(
        _lossCpMeta,
        lossCp.isAcceptableOrUnknown(data['loss_cp']!, _lossCpMeta),
      );
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    } else if (isInserting) {
      context.missing(_passedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId};
  @override
  DbDeviationEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDeviationEvent(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      deviationUci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deviation_uci'],
      ),
      replyUci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_uci'],
      ),
      bestUci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_uci'],
      )!,
      lossCp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loss_cp'],
      ),
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      )!,
    );
  }

  @override
  $DeviationEventsTable createAlias(String alias) {
    return $DeviationEventsTable(attachedDatabase, alias);
  }
}

class DbDeviationEvent extends DataClass
    implements Insertable<DbDeviationEvent> {
  final String runId;
  final int ply;
  final String? deviationUci;
  final String? replyUci;
  final String bestUci;
  final int? lossCp;
  final bool passed;
  const DbDeviationEvent({
    required this.runId,
    required this.ply,
    this.deviationUci,
    this.replyUci,
    required this.bestUci,
    this.lossCp,
    required this.passed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['ply'] = Variable<int>(ply);
    if (!nullToAbsent || deviationUci != null) {
      map['deviation_uci'] = Variable<String>(deviationUci);
    }
    if (!nullToAbsent || replyUci != null) {
      map['reply_uci'] = Variable<String>(replyUci);
    }
    map['best_uci'] = Variable<String>(bestUci);
    if (!nullToAbsent || lossCp != null) {
      map['loss_cp'] = Variable<int>(lossCp);
    }
    map['passed'] = Variable<bool>(passed);
    return map;
  }

  DeviationEventsCompanion toCompanion(bool nullToAbsent) {
    return DeviationEventsCompanion(
      runId: Value(runId),
      ply: Value(ply),
      deviationUci: deviationUci == null && nullToAbsent
          ? const Value.absent()
          : Value(deviationUci),
      replyUci: replyUci == null && nullToAbsent
          ? const Value.absent()
          : Value(replyUci),
      bestUci: Value(bestUci),
      lossCp: lossCp == null && nullToAbsent
          ? const Value.absent()
          : Value(lossCp),
      passed: Value(passed),
    );
  }

  factory DbDeviationEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDeviationEvent(
      runId: serializer.fromJson<String>(json['runId']),
      ply: serializer.fromJson<int>(json['ply']),
      deviationUci: serializer.fromJson<String?>(json['deviationUci']),
      replyUci: serializer.fromJson<String?>(json['replyUci']),
      bestUci: serializer.fromJson<String>(json['bestUci']),
      lossCp: serializer.fromJson<int?>(json['lossCp']),
      passed: serializer.fromJson<bool>(json['passed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'ply': serializer.toJson<int>(ply),
      'deviationUci': serializer.toJson<String?>(deviationUci),
      'replyUci': serializer.toJson<String?>(replyUci),
      'bestUci': serializer.toJson<String>(bestUci),
      'lossCp': serializer.toJson<int?>(lossCp),
      'passed': serializer.toJson<bool>(passed),
    };
  }

  DbDeviationEvent copyWith({
    String? runId,
    int? ply,
    Value<String?> deviationUci = const Value.absent(),
    Value<String?> replyUci = const Value.absent(),
    String? bestUci,
    Value<int?> lossCp = const Value.absent(),
    bool? passed,
  }) => DbDeviationEvent(
    runId: runId ?? this.runId,
    ply: ply ?? this.ply,
    deviationUci: deviationUci.present ? deviationUci.value : this.deviationUci,
    replyUci: replyUci.present ? replyUci.value : this.replyUci,
    bestUci: bestUci ?? this.bestUci,
    lossCp: lossCp.present ? lossCp.value : this.lossCp,
    passed: passed ?? this.passed,
  );
  DbDeviationEvent copyWithCompanion(DeviationEventsCompanion data) {
    return DbDeviationEvent(
      runId: data.runId.present ? data.runId.value : this.runId,
      ply: data.ply.present ? data.ply.value : this.ply,
      deviationUci: data.deviationUci.present
          ? data.deviationUci.value
          : this.deviationUci,
      replyUci: data.replyUci.present ? data.replyUci.value : this.replyUci,
      bestUci: data.bestUci.present ? data.bestUci.value : this.bestUci,
      lossCp: data.lossCp.present ? data.lossCp.value : this.lossCp,
      passed: data.passed.present ? data.passed.value : this.passed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDeviationEvent(')
          ..write('runId: $runId, ')
          ..write('ply: $ply, ')
          ..write('deviationUci: $deviationUci, ')
          ..write('replyUci: $replyUci, ')
          ..write('bestUci: $bestUci, ')
          ..write('lossCp: $lossCp, ')
          ..write('passed: $passed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(runId, ply, deviationUci, replyUci, bestUci, lossCp, passed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDeviationEvent &&
          other.runId == this.runId &&
          other.ply == this.ply &&
          other.deviationUci == this.deviationUci &&
          other.replyUci == this.replyUci &&
          other.bestUci == this.bestUci &&
          other.lossCp == this.lossCp &&
          other.passed == this.passed);
}

class DeviationEventsCompanion extends UpdateCompanion<DbDeviationEvent> {
  final Value<String> runId;
  final Value<int> ply;
  final Value<String?> deviationUci;
  final Value<String?> replyUci;
  final Value<String> bestUci;
  final Value<int?> lossCp;
  final Value<bool> passed;
  final Value<int> rowid;
  const DeviationEventsCompanion({
    this.runId = const Value.absent(),
    this.ply = const Value.absent(),
    this.deviationUci = const Value.absent(),
    this.replyUci = const Value.absent(),
    this.bestUci = const Value.absent(),
    this.lossCp = const Value.absent(),
    this.passed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviationEventsCompanion.insert({
    required String runId,
    required int ply,
    this.deviationUci = const Value.absent(),
    this.replyUci = const Value.absent(),
    required String bestUci,
    this.lossCp = const Value.absent(),
    required bool passed,
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       ply = Value(ply),
       bestUci = Value(bestUci),
       passed = Value(passed);
  static Insertable<DbDeviationEvent> custom({
    Expression<String>? runId,
    Expression<int>? ply,
    Expression<String>? deviationUci,
    Expression<String>? replyUci,
    Expression<String>? bestUci,
    Expression<int>? lossCp,
    Expression<bool>? passed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (ply != null) 'ply': ply,
      if (deviationUci != null) 'deviation_uci': deviationUci,
      if (replyUci != null) 'reply_uci': replyUci,
      if (bestUci != null) 'best_uci': bestUci,
      if (lossCp != null) 'loss_cp': lossCp,
      if (passed != null) 'passed': passed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviationEventsCompanion copyWith({
    Value<String>? runId,
    Value<int>? ply,
    Value<String?>? deviationUci,
    Value<String?>? replyUci,
    Value<String>? bestUci,
    Value<int?>? lossCp,
    Value<bool>? passed,
    Value<int>? rowid,
  }) {
    return DeviationEventsCompanion(
      runId: runId ?? this.runId,
      ply: ply ?? this.ply,
      deviationUci: deviationUci ?? this.deviationUci,
      replyUci: replyUci ?? this.replyUci,
      bestUci: bestUci ?? this.bestUci,
      lossCp: lossCp ?? this.lossCp,
      passed: passed ?? this.passed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (deviationUci.present) {
      map['deviation_uci'] = Variable<String>(deviationUci.value);
    }
    if (replyUci.present) {
      map['reply_uci'] = Variable<String>(replyUci.value);
    }
    if (bestUci.present) {
      map['best_uci'] = Variable<String>(bestUci.value);
    }
    if (lossCp.present) {
      map['loss_cp'] = Variable<int>(lossCp.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviationEventsCompanion(')
          ..write('runId: $runId, ')
          ..write('ply: $ply, ')
          ..write('deviationUci: $deviationUci, ')
          ..write('replyUci: $replyUci, ')
          ..write('bestUci: $bestUci, ')
          ..write('lossCp: $lossCp, ')
          ..write('passed: $passed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineStatsTableTable extends LineStatsTable
    with TableInfo<$LineStatsTableTable, DbLineStats> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _repertoireIdMeta = const VerificationMeta(
    'repertoireId',
  );
  @override
  late final GeneratedColumn<String> repertoireId = GeneratedColumn<String>(
    'repertoire_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineKeyMeta = const VerificationMeta(
    'lineKey',
  );
  @override
  late final GeneratedColumn<String> lineKey = GeneratedColumn<String>(
    'line_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
  );
  static const VerificationMeta _runCountMeta = const VerificationMeta(
    'runCount',
  );
  @override
  late final GeneratedColumn<int> runCount = GeneratedColumn<int>(
    'run_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<int> lastPlayedAt = GeneratedColumn<int>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inWeakPoolMeta = const VerificationMeta(
    'inWeakPool',
  );
  @override
  late final GeneratedColumn<bool> inWeakPool = GeneratedColumn<bool>(
    'in_weak_pool',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_weak_pool" IN (0, 1))',
    ),
  );
  static const VerificationMeta _weakCleanStreakMeta = const VerificationMeta(
    'weakCleanStreak',
  );
  @override
  late final GeneratedColumn<int> weakCleanStreak = GeneratedColumn<int>(
    'weak_clean_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srsStateMeta = const VerificationMeta(
    'srsState',
  );
  @override
  late final GeneratedColumn<String> srsState = GeneratedColumn<String>(
    'srs_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srsRepsMeta = const VerificationMeta(
    'srsReps',
  );
  @override
  late final GeneratedColumn<int> srsReps = GeneratedColumn<int>(
    'srs_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srsEaseMeta = const VerificationMeta(
    'srsEase',
  );
  @override
  late final GeneratedColumn<double> srsEase = GeneratedColumn<double>(
    'srs_ease',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srsIntervalDaysMeta = const VerificationMeta(
    'srsIntervalDays',
  );
  @override
  late final GeneratedColumn<int> srsIntervalDays = GeneratedColumn<int>(
    'srs_interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srsDueDayMeta = const VerificationMeta(
    'srsDueDay',
  );
  @override
  late final GeneratedColumn<String> srsDueDay = GeneratedColumn<String>(
    'srs_due_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _srsLapsesMeta = const VerificationMeta(
    'srsLapses',
  );
  @override
  late final GeneratedColumn<int> srsLapses = GeneratedColumn<int>(
    'srs_lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srsFirstSeenDayMeta = const VerificationMeta(
    'srsFirstSeenDay',
  );
  @override
  late final GeneratedColumn<String> srsFirstSeenDay = GeneratedColumn<String>(
    'srs_first_seen_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    repertoireId,
    lineKey,
    archived,
    runCount,
    accuracy,
    lastPlayedAt,
    inWeakPool,
    weakCleanStreak,
    srsState,
    srsReps,
    srsEase,
    srsIntervalDays,
    srsDueDay,
    srsLapses,
    srsFirstSeenDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbLineStats> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('repertoire_id')) {
      context.handle(
        _repertoireIdMeta,
        repertoireId.isAcceptableOrUnknown(
          data['repertoire_id']!,
          _repertoireIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repertoireIdMeta);
    }
    if (data.containsKey('line_key')) {
      context.handle(
        _lineKeyMeta,
        lineKey.isAcceptableOrUnknown(data['line_key']!, _lineKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_lineKeyMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    } else if (isInserting) {
      context.missing(_archivedMeta);
    }
    if (data.containsKey('run_count')) {
      context.handle(
        _runCountMeta,
        runCount.isAcceptableOrUnknown(data['run_count']!, _runCountMeta),
      );
    } else if (isInserting) {
      context.missing(_runCountMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('in_weak_pool')) {
      context.handle(
        _inWeakPoolMeta,
        inWeakPool.isAcceptableOrUnknown(
          data['in_weak_pool']!,
          _inWeakPoolMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inWeakPoolMeta);
    }
    if (data.containsKey('weak_clean_streak')) {
      context.handle(
        _weakCleanStreakMeta,
        weakCleanStreak.isAcceptableOrUnknown(
          data['weak_clean_streak']!,
          _weakCleanStreakMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weakCleanStreakMeta);
    }
    if (data.containsKey('srs_state')) {
      context.handle(
        _srsStateMeta,
        srsState.isAcceptableOrUnknown(data['srs_state']!, _srsStateMeta),
      );
    } else if (isInserting) {
      context.missing(_srsStateMeta);
    }
    if (data.containsKey('srs_reps')) {
      context.handle(
        _srsRepsMeta,
        srsReps.isAcceptableOrUnknown(data['srs_reps']!, _srsRepsMeta),
      );
    } else if (isInserting) {
      context.missing(_srsRepsMeta);
    }
    if (data.containsKey('srs_ease')) {
      context.handle(
        _srsEaseMeta,
        srsEase.isAcceptableOrUnknown(data['srs_ease']!, _srsEaseMeta),
      );
    } else if (isInserting) {
      context.missing(_srsEaseMeta);
    }
    if (data.containsKey('srs_interval_days')) {
      context.handle(
        _srsIntervalDaysMeta,
        srsIntervalDays.isAcceptableOrUnknown(
          data['srs_interval_days']!,
          _srsIntervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_srsIntervalDaysMeta);
    }
    if (data.containsKey('srs_due_day')) {
      context.handle(
        _srsDueDayMeta,
        srsDueDay.isAcceptableOrUnknown(data['srs_due_day']!, _srsDueDayMeta),
      );
    }
    if (data.containsKey('srs_lapses')) {
      context.handle(
        _srsLapsesMeta,
        srsLapses.isAcceptableOrUnknown(data['srs_lapses']!, _srsLapsesMeta),
      );
    } else if (isInserting) {
      context.missing(_srsLapsesMeta);
    }
    if (data.containsKey('srs_first_seen_day')) {
      context.handle(
        _srsFirstSeenDayMeta,
        srsFirstSeenDay.isAcceptableOrUnknown(
          data['srs_first_seen_day']!,
          _srsFirstSeenDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {repertoireId, lineKey};
  @override
  DbLineStats map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbLineStats(
      repertoireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repertoire_id'],
      )!,
      lineKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_key'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      runCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_count'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_at'],
      ),
      inWeakPool: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_weak_pool'],
      )!,
      weakCleanStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weak_clean_streak'],
      )!,
      srsState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}srs_state'],
      )!,
      srsReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}srs_reps'],
      )!,
      srsEase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}srs_ease'],
      )!,
      srsIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}srs_interval_days'],
      )!,
      srsDueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}srs_due_day'],
      ),
      srsLapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}srs_lapses'],
      )!,
      srsFirstSeenDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}srs_first_seen_day'],
      ),
    );
  }

  @override
  $LineStatsTableTable createAlias(String alias) {
    return $LineStatsTableTable(attachedDatabase, alias);
  }
}

class DbLineStats extends DataClass implements Insertable<DbLineStats> {
  final String repertoireId;
  final String lineKey;
  final bool archived;
  final int runCount;
  final double? accuracy;
  final int? lastPlayedAt;
  final bool inWeakPool;
  final int weakCleanStreak;
  final String srsState;
  final int srsReps;
  final double srsEase;
  final int srsIntervalDays;
  final String? srsDueDay;
  final int srsLapses;
  final String? srsFirstSeenDay;
  const DbLineStats({
    required this.repertoireId,
    required this.lineKey,
    required this.archived,
    required this.runCount,
    this.accuracy,
    this.lastPlayedAt,
    required this.inWeakPool,
    required this.weakCleanStreak,
    required this.srsState,
    required this.srsReps,
    required this.srsEase,
    required this.srsIntervalDays,
    this.srsDueDay,
    required this.srsLapses,
    this.srsFirstSeenDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['repertoire_id'] = Variable<String>(repertoireId);
    map['line_key'] = Variable<String>(lineKey);
    map['archived'] = Variable<bool>(archived);
    map['run_count'] = Variable<int>(runCount);
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<int>(lastPlayedAt);
    }
    map['in_weak_pool'] = Variable<bool>(inWeakPool);
    map['weak_clean_streak'] = Variable<int>(weakCleanStreak);
    map['srs_state'] = Variable<String>(srsState);
    map['srs_reps'] = Variable<int>(srsReps);
    map['srs_ease'] = Variable<double>(srsEase);
    map['srs_interval_days'] = Variable<int>(srsIntervalDays);
    if (!nullToAbsent || srsDueDay != null) {
      map['srs_due_day'] = Variable<String>(srsDueDay);
    }
    map['srs_lapses'] = Variable<int>(srsLapses);
    if (!nullToAbsent || srsFirstSeenDay != null) {
      map['srs_first_seen_day'] = Variable<String>(srsFirstSeenDay);
    }
    return map;
  }

  LineStatsTableCompanion toCompanion(bool nullToAbsent) {
    return LineStatsTableCompanion(
      repertoireId: Value(repertoireId),
      lineKey: Value(lineKey),
      archived: Value(archived),
      runCount: Value(runCount),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      inWeakPool: Value(inWeakPool),
      weakCleanStreak: Value(weakCleanStreak),
      srsState: Value(srsState),
      srsReps: Value(srsReps),
      srsEase: Value(srsEase),
      srsIntervalDays: Value(srsIntervalDays),
      srsDueDay: srsDueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(srsDueDay),
      srsLapses: Value(srsLapses),
      srsFirstSeenDay: srsFirstSeenDay == null && nullToAbsent
          ? const Value.absent()
          : Value(srsFirstSeenDay),
    );
  }

  factory DbLineStats.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbLineStats(
      repertoireId: serializer.fromJson<String>(json['repertoireId']),
      lineKey: serializer.fromJson<String>(json['lineKey']),
      archived: serializer.fromJson<bool>(json['archived']),
      runCount: serializer.fromJson<int>(json['runCount']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      lastPlayedAt: serializer.fromJson<int?>(json['lastPlayedAt']),
      inWeakPool: serializer.fromJson<bool>(json['inWeakPool']),
      weakCleanStreak: serializer.fromJson<int>(json['weakCleanStreak']),
      srsState: serializer.fromJson<String>(json['srsState']),
      srsReps: serializer.fromJson<int>(json['srsReps']),
      srsEase: serializer.fromJson<double>(json['srsEase']),
      srsIntervalDays: serializer.fromJson<int>(json['srsIntervalDays']),
      srsDueDay: serializer.fromJson<String?>(json['srsDueDay']),
      srsLapses: serializer.fromJson<int>(json['srsLapses']),
      srsFirstSeenDay: serializer.fromJson<String?>(json['srsFirstSeenDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'repertoireId': serializer.toJson<String>(repertoireId),
      'lineKey': serializer.toJson<String>(lineKey),
      'archived': serializer.toJson<bool>(archived),
      'runCount': serializer.toJson<int>(runCount),
      'accuracy': serializer.toJson<double?>(accuracy),
      'lastPlayedAt': serializer.toJson<int?>(lastPlayedAt),
      'inWeakPool': serializer.toJson<bool>(inWeakPool),
      'weakCleanStreak': serializer.toJson<int>(weakCleanStreak),
      'srsState': serializer.toJson<String>(srsState),
      'srsReps': serializer.toJson<int>(srsReps),
      'srsEase': serializer.toJson<double>(srsEase),
      'srsIntervalDays': serializer.toJson<int>(srsIntervalDays),
      'srsDueDay': serializer.toJson<String?>(srsDueDay),
      'srsLapses': serializer.toJson<int>(srsLapses),
      'srsFirstSeenDay': serializer.toJson<String?>(srsFirstSeenDay),
    };
  }

  DbLineStats copyWith({
    String? repertoireId,
    String? lineKey,
    bool? archived,
    int? runCount,
    Value<double?> accuracy = const Value.absent(),
    Value<int?> lastPlayedAt = const Value.absent(),
    bool? inWeakPool,
    int? weakCleanStreak,
    String? srsState,
    int? srsReps,
    double? srsEase,
    int? srsIntervalDays,
    Value<String?> srsDueDay = const Value.absent(),
    int? srsLapses,
    Value<String?> srsFirstSeenDay = const Value.absent(),
  }) => DbLineStats(
    repertoireId: repertoireId ?? this.repertoireId,
    lineKey: lineKey ?? this.lineKey,
    archived: archived ?? this.archived,
    runCount: runCount ?? this.runCount,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    inWeakPool: inWeakPool ?? this.inWeakPool,
    weakCleanStreak: weakCleanStreak ?? this.weakCleanStreak,
    srsState: srsState ?? this.srsState,
    srsReps: srsReps ?? this.srsReps,
    srsEase: srsEase ?? this.srsEase,
    srsIntervalDays: srsIntervalDays ?? this.srsIntervalDays,
    srsDueDay: srsDueDay.present ? srsDueDay.value : this.srsDueDay,
    srsLapses: srsLapses ?? this.srsLapses,
    srsFirstSeenDay: srsFirstSeenDay.present
        ? srsFirstSeenDay.value
        : this.srsFirstSeenDay,
  );
  DbLineStats copyWithCompanion(LineStatsTableCompanion data) {
    return DbLineStats(
      repertoireId: data.repertoireId.present
          ? data.repertoireId.value
          : this.repertoireId,
      lineKey: data.lineKey.present ? data.lineKey.value : this.lineKey,
      archived: data.archived.present ? data.archived.value : this.archived,
      runCount: data.runCount.present ? data.runCount.value : this.runCount,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      inWeakPool: data.inWeakPool.present
          ? data.inWeakPool.value
          : this.inWeakPool,
      weakCleanStreak: data.weakCleanStreak.present
          ? data.weakCleanStreak.value
          : this.weakCleanStreak,
      srsState: data.srsState.present ? data.srsState.value : this.srsState,
      srsReps: data.srsReps.present ? data.srsReps.value : this.srsReps,
      srsEase: data.srsEase.present ? data.srsEase.value : this.srsEase,
      srsIntervalDays: data.srsIntervalDays.present
          ? data.srsIntervalDays.value
          : this.srsIntervalDays,
      srsDueDay: data.srsDueDay.present ? data.srsDueDay.value : this.srsDueDay,
      srsLapses: data.srsLapses.present ? data.srsLapses.value : this.srsLapses,
      srsFirstSeenDay: data.srsFirstSeenDay.present
          ? data.srsFirstSeenDay.value
          : this.srsFirstSeenDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbLineStats(')
          ..write('repertoireId: $repertoireId, ')
          ..write('lineKey: $lineKey, ')
          ..write('archived: $archived, ')
          ..write('runCount: $runCount, ')
          ..write('accuracy: $accuracy, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('inWeakPool: $inWeakPool, ')
          ..write('weakCleanStreak: $weakCleanStreak, ')
          ..write('srsState: $srsState, ')
          ..write('srsReps: $srsReps, ')
          ..write('srsEase: $srsEase, ')
          ..write('srsIntervalDays: $srsIntervalDays, ')
          ..write('srsDueDay: $srsDueDay, ')
          ..write('srsLapses: $srsLapses, ')
          ..write('srsFirstSeenDay: $srsFirstSeenDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    repertoireId,
    lineKey,
    archived,
    runCount,
    accuracy,
    lastPlayedAt,
    inWeakPool,
    weakCleanStreak,
    srsState,
    srsReps,
    srsEase,
    srsIntervalDays,
    srsDueDay,
    srsLapses,
    srsFirstSeenDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbLineStats &&
          other.repertoireId == this.repertoireId &&
          other.lineKey == this.lineKey &&
          other.archived == this.archived &&
          other.runCount == this.runCount &&
          other.accuracy == this.accuracy &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.inWeakPool == this.inWeakPool &&
          other.weakCleanStreak == this.weakCleanStreak &&
          other.srsState == this.srsState &&
          other.srsReps == this.srsReps &&
          other.srsEase == this.srsEase &&
          other.srsIntervalDays == this.srsIntervalDays &&
          other.srsDueDay == this.srsDueDay &&
          other.srsLapses == this.srsLapses &&
          other.srsFirstSeenDay == this.srsFirstSeenDay);
}

class LineStatsTableCompanion extends UpdateCompanion<DbLineStats> {
  final Value<String> repertoireId;
  final Value<String> lineKey;
  final Value<bool> archived;
  final Value<int> runCount;
  final Value<double?> accuracy;
  final Value<int?> lastPlayedAt;
  final Value<bool> inWeakPool;
  final Value<int> weakCleanStreak;
  final Value<String> srsState;
  final Value<int> srsReps;
  final Value<double> srsEase;
  final Value<int> srsIntervalDays;
  final Value<String?> srsDueDay;
  final Value<int> srsLapses;
  final Value<String?> srsFirstSeenDay;
  final Value<int> rowid;
  const LineStatsTableCompanion({
    this.repertoireId = const Value.absent(),
    this.lineKey = const Value.absent(),
    this.archived = const Value.absent(),
    this.runCount = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.inWeakPool = const Value.absent(),
    this.weakCleanStreak = const Value.absent(),
    this.srsState = const Value.absent(),
    this.srsReps = const Value.absent(),
    this.srsEase = const Value.absent(),
    this.srsIntervalDays = const Value.absent(),
    this.srsDueDay = const Value.absent(),
    this.srsLapses = const Value.absent(),
    this.srsFirstSeenDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineStatsTableCompanion.insert({
    required String repertoireId,
    required String lineKey,
    required bool archived,
    required int runCount,
    this.accuracy = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    required bool inWeakPool,
    required int weakCleanStreak,
    required String srsState,
    required int srsReps,
    required double srsEase,
    required int srsIntervalDays,
    this.srsDueDay = const Value.absent(),
    required int srsLapses,
    this.srsFirstSeenDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : repertoireId = Value(repertoireId),
       lineKey = Value(lineKey),
       archived = Value(archived),
       runCount = Value(runCount),
       inWeakPool = Value(inWeakPool),
       weakCleanStreak = Value(weakCleanStreak),
       srsState = Value(srsState),
       srsReps = Value(srsReps),
       srsEase = Value(srsEase),
       srsIntervalDays = Value(srsIntervalDays),
       srsLapses = Value(srsLapses);
  static Insertable<DbLineStats> custom({
    Expression<String>? repertoireId,
    Expression<String>? lineKey,
    Expression<bool>? archived,
    Expression<int>? runCount,
    Expression<double>? accuracy,
    Expression<int>? lastPlayedAt,
    Expression<bool>? inWeakPool,
    Expression<int>? weakCleanStreak,
    Expression<String>? srsState,
    Expression<int>? srsReps,
    Expression<double>? srsEase,
    Expression<int>? srsIntervalDays,
    Expression<String>? srsDueDay,
    Expression<int>? srsLapses,
    Expression<String>? srsFirstSeenDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (repertoireId != null) 'repertoire_id': repertoireId,
      if (lineKey != null) 'line_key': lineKey,
      if (archived != null) 'archived': archived,
      if (runCount != null) 'run_count': runCount,
      if (accuracy != null) 'accuracy': accuracy,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (inWeakPool != null) 'in_weak_pool': inWeakPool,
      if (weakCleanStreak != null) 'weak_clean_streak': weakCleanStreak,
      if (srsState != null) 'srs_state': srsState,
      if (srsReps != null) 'srs_reps': srsReps,
      if (srsEase != null) 'srs_ease': srsEase,
      if (srsIntervalDays != null) 'srs_interval_days': srsIntervalDays,
      if (srsDueDay != null) 'srs_due_day': srsDueDay,
      if (srsLapses != null) 'srs_lapses': srsLapses,
      if (srsFirstSeenDay != null) 'srs_first_seen_day': srsFirstSeenDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineStatsTableCompanion copyWith({
    Value<String>? repertoireId,
    Value<String>? lineKey,
    Value<bool>? archived,
    Value<int>? runCount,
    Value<double?>? accuracy,
    Value<int?>? lastPlayedAt,
    Value<bool>? inWeakPool,
    Value<int>? weakCleanStreak,
    Value<String>? srsState,
    Value<int>? srsReps,
    Value<double>? srsEase,
    Value<int>? srsIntervalDays,
    Value<String?>? srsDueDay,
    Value<int>? srsLapses,
    Value<String?>? srsFirstSeenDay,
    Value<int>? rowid,
  }) {
    return LineStatsTableCompanion(
      repertoireId: repertoireId ?? this.repertoireId,
      lineKey: lineKey ?? this.lineKey,
      archived: archived ?? this.archived,
      runCount: runCount ?? this.runCount,
      accuracy: accuracy ?? this.accuracy,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      inWeakPool: inWeakPool ?? this.inWeakPool,
      weakCleanStreak: weakCleanStreak ?? this.weakCleanStreak,
      srsState: srsState ?? this.srsState,
      srsReps: srsReps ?? this.srsReps,
      srsEase: srsEase ?? this.srsEase,
      srsIntervalDays: srsIntervalDays ?? this.srsIntervalDays,
      srsDueDay: srsDueDay ?? this.srsDueDay,
      srsLapses: srsLapses ?? this.srsLapses,
      srsFirstSeenDay: srsFirstSeenDay ?? this.srsFirstSeenDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (repertoireId.present) {
      map['repertoire_id'] = Variable<String>(repertoireId.value);
    }
    if (lineKey.present) {
      map['line_key'] = Variable<String>(lineKey.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (runCount.present) {
      map['run_count'] = Variable<int>(runCount.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<int>(lastPlayedAt.value);
    }
    if (inWeakPool.present) {
      map['in_weak_pool'] = Variable<bool>(inWeakPool.value);
    }
    if (weakCleanStreak.present) {
      map['weak_clean_streak'] = Variable<int>(weakCleanStreak.value);
    }
    if (srsState.present) {
      map['srs_state'] = Variable<String>(srsState.value);
    }
    if (srsReps.present) {
      map['srs_reps'] = Variable<int>(srsReps.value);
    }
    if (srsEase.present) {
      map['srs_ease'] = Variable<double>(srsEase.value);
    }
    if (srsIntervalDays.present) {
      map['srs_interval_days'] = Variable<int>(srsIntervalDays.value);
    }
    if (srsDueDay.present) {
      map['srs_due_day'] = Variable<String>(srsDueDay.value);
    }
    if (srsLapses.present) {
      map['srs_lapses'] = Variable<int>(srsLapses.value);
    }
    if (srsFirstSeenDay.present) {
      map['srs_first_seen_day'] = Variable<String>(srsFirstSeenDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineStatsTableCompanion(')
          ..write('repertoireId: $repertoireId, ')
          ..write('lineKey: $lineKey, ')
          ..write('archived: $archived, ')
          ..write('runCount: $runCount, ')
          ..write('accuracy: $accuracy, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('inWeakPool: $inWeakPool, ')
          ..write('weakCleanStreak: $weakCleanStreak, ')
          ..write('srsState: $srsState, ')
          ..write('srsReps: $srsReps, ')
          ..write('srsEase: $srsEase, ')
          ..write('srsIntervalDays: $srsIntervalDays, ')
          ..write('srsDueDay: $srsDueDay, ')
          ..write('srsLapses: $srsLapses, ')
          ..write('srsFirstSeenDay: $srsFirstSeenDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlyStatsTable extends PlyStats
    with TableInfo<$PlyStatsTable, DbPlyStats> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _repertoireIdMeta = const VerificationMeta(
    'repertoireId',
  );
  @override
  late final GeneratedColumn<String> repertoireId = GeneratedColumn<String>(
    'repertoire_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ucisMeta = const VerificationMeta('ucis');
  @override
  late final GeneratedColumn<String> ucis = GeneratedColumn<String>(
    'ucis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missesMeta = const VerificationMeta('misses');
  @override
  late final GeneratedColumn<int> misses = GeneratedColumn<int>(
    'misses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    repertoireId,
    ucis,
    ply,
    attempts,
    misses,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ply_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlyStats> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('repertoire_id')) {
      context.handle(
        _repertoireIdMeta,
        repertoireId.isAcceptableOrUnknown(
          data['repertoire_id']!,
          _repertoireIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repertoireIdMeta);
    }
    if (data.containsKey('ucis')) {
      context.handle(
        _ucisMeta,
        ucis.isAcceptableOrUnknown(data['ucis']!, _ucisMeta),
      );
    } else if (isInserting) {
      context.missing(_ucisMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('misses')) {
      context.handle(
        _missesMeta,
        misses.isAcceptableOrUnknown(data['misses']!, _missesMeta),
      );
    } else if (isInserting) {
      context.missing(_missesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {repertoireId, ucis, ply};
  @override
  DbPlyStats map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlyStats(
      repertoireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repertoire_id'],
      )!,
      ucis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ucis'],
      )!,
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      misses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}misses'],
      )!,
    );
  }

  @override
  $PlyStatsTable createAlias(String alias) {
    return $PlyStatsTable(attachedDatabase, alias);
  }
}

class DbPlyStats extends DataClass implements Insertable<DbPlyStats> {
  final String repertoireId;
  final String ucis;
  final int ply;
  final int attempts;
  final int misses;
  const DbPlyStats({
    required this.repertoireId,
    required this.ucis,
    required this.ply,
    required this.attempts,
    required this.misses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['repertoire_id'] = Variable<String>(repertoireId);
    map['ucis'] = Variable<String>(ucis);
    map['ply'] = Variable<int>(ply);
    map['attempts'] = Variable<int>(attempts);
    map['misses'] = Variable<int>(misses);
    return map;
  }

  PlyStatsCompanion toCompanion(bool nullToAbsent) {
    return PlyStatsCompanion(
      repertoireId: Value(repertoireId),
      ucis: Value(ucis),
      ply: Value(ply),
      attempts: Value(attempts),
      misses: Value(misses),
    );
  }

  factory DbPlyStats.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlyStats(
      repertoireId: serializer.fromJson<String>(json['repertoireId']),
      ucis: serializer.fromJson<String>(json['ucis']),
      ply: serializer.fromJson<int>(json['ply']),
      attempts: serializer.fromJson<int>(json['attempts']),
      misses: serializer.fromJson<int>(json['misses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'repertoireId': serializer.toJson<String>(repertoireId),
      'ucis': serializer.toJson<String>(ucis),
      'ply': serializer.toJson<int>(ply),
      'attempts': serializer.toJson<int>(attempts),
      'misses': serializer.toJson<int>(misses),
    };
  }

  DbPlyStats copyWith({
    String? repertoireId,
    String? ucis,
    int? ply,
    int? attempts,
    int? misses,
  }) => DbPlyStats(
    repertoireId: repertoireId ?? this.repertoireId,
    ucis: ucis ?? this.ucis,
    ply: ply ?? this.ply,
    attempts: attempts ?? this.attempts,
    misses: misses ?? this.misses,
  );
  DbPlyStats copyWithCompanion(PlyStatsCompanion data) {
    return DbPlyStats(
      repertoireId: data.repertoireId.present
          ? data.repertoireId.value
          : this.repertoireId,
      ucis: data.ucis.present ? data.ucis.value : this.ucis,
      ply: data.ply.present ? data.ply.value : this.ply,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      misses: data.misses.present ? data.misses.value : this.misses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlyStats(')
          ..write('repertoireId: $repertoireId, ')
          ..write('ucis: $ucis, ')
          ..write('ply: $ply, ')
          ..write('attempts: $attempts, ')
          ..write('misses: $misses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(repertoireId, ucis, ply, attempts, misses);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlyStats &&
          other.repertoireId == this.repertoireId &&
          other.ucis == this.ucis &&
          other.ply == this.ply &&
          other.attempts == this.attempts &&
          other.misses == this.misses);
}

class PlyStatsCompanion extends UpdateCompanion<DbPlyStats> {
  final Value<String> repertoireId;
  final Value<String> ucis;
  final Value<int> ply;
  final Value<int> attempts;
  final Value<int> misses;
  final Value<int> rowid;
  const PlyStatsCompanion({
    this.repertoireId = const Value.absent(),
    this.ucis = const Value.absent(),
    this.ply = const Value.absent(),
    this.attempts = const Value.absent(),
    this.misses = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlyStatsCompanion.insert({
    required String repertoireId,
    required String ucis,
    required int ply,
    required int attempts,
    required int misses,
    this.rowid = const Value.absent(),
  }) : repertoireId = Value(repertoireId),
       ucis = Value(ucis),
       ply = Value(ply),
       attempts = Value(attempts),
       misses = Value(misses);
  static Insertable<DbPlyStats> custom({
    Expression<String>? repertoireId,
    Expression<String>? ucis,
    Expression<int>? ply,
    Expression<int>? attempts,
    Expression<int>? misses,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (repertoireId != null) 'repertoire_id': repertoireId,
      if (ucis != null) 'ucis': ucis,
      if (ply != null) 'ply': ply,
      if (attempts != null) 'attempts': attempts,
      if (misses != null) 'misses': misses,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlyStatsCompanion copyWith({
    Value<String>? repertoireId,
    Value<String>? ucis,
    Value<int>? ply,
    Value<int>? attempts,
    Value<int>? misses,
    Value<int>? rowid,
  }) {
    return PlyStatsCompanion(
      repertoireId: repertoireId ?? this.repertoireId,
      ucis: ucis ?? this.ucis,
      ply: ply ?? this.ply,
      attempts: attempts ?? this.attempts,
      misses: misses ?? this.misses,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (repertoireId.present) {
      map['repertoire_id'] = Variable<String>(repertoireId.value);
    }
    if (ucis.present) {
      map['ucis'] = Variable<String>(ucis.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (misses.present) {
      map['misses'] = Variable<int>(misses.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlyStatsCompanion(')
          ..write('repertoireId: $repertoireId, ')
          ..write('ucis: $ucis, ')
          ..write('ply: $ply, ')
          ..write('attempts: $attempts, ')
          ..write('misses: $misses, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, DbSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class DbSetting extends DataClass implements Insertable<DbSetting> {
  final String key;
  final String value;
  const DbSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory DbSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DbSetting copyWith({String? key, String? value}) =>
      DbSetting(key: key ?? this.key, value: value ?? this.value);
  DbSetting copyWithCompanion(SettingsCompanion data) {
    return DbSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<DbSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DbSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, DbSyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbSyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncState(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class DbSyncState extends DataClass implements Insertable<DbSyncState> {
  final String key;
  final String value;
  const DbSyncState({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(key: Value(key), value: Value(value));
  }

  factory DbSyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncState(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DbSyncState copyWith({String? key, String? value}) =>
      DbSyncState(key: key ?? this.key, value: value ?? this.value);
  DbSyncState copyWithCompanion(SyncStateCompanion data) {
    return DbSyncState(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncState(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncState &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<DbSyncState> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DbSyncState> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, DbAppMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbAppMeta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbAppMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAppMeta(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class DbAppMeta extends DataClass implements Insertable<DbAppMeta> {
  final String key;
  final String value;
  const DbAppMeta({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory DbAppMeta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAppMeta(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DbAppMeta copyWith({String? key, String? value}) =>
      DbAppMeta(key: key ?? this.key, value: value ?? this.value);
  DbAppMeta copyWithCompanion(AppMetaCompanion data) {
    return DbAppMeta(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAppMeta(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAppMeta &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<DbAppMeta> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DbAppMeta> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportedGamesTable extends ImportedGames
    with TableInfo<$ImportedGamesTable, DbImportedGame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedGamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeClassMeta = const VerificationMeta(
    'timeClass',
  );
  @override
  late final GeneratedColumn<String> timeClass = GeneratedColumn<String>(
    'time_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeControlMeta = const VerificationMeta(
    'timeControl',
  );
  @override
  late final GeneratedColumn<String> timeControl = GeneratedColumn<String>(
    'time_control',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratedMeta = const VerificationMeta('rated');
  @override
  late final GeneratedColumn<bool> rated = GeneratedColumn<bool>(
    'rated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rated" IN (0, 1))',
    ),
  );
  static const VerificationMeta _userWhiteMeta = const VerificationMeta(
    'userWhite',
  );
  @override
  late final GeneratedColumn<bool> userWhite = GeneratedColumn<bool>(
    'user_white',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_white" IN (0, 1))',
    ),
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultDetailMeta = const VerificationMeta(
    'resultDetail',
  );
  @override
  late final GeneratedColumn<String> resultDetail = GeneratedColumn<String>(
    'result_detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whiteNameMeta = const VerificationMeta(
    'whiteName',
  );
  @override
  late final GeneratedColumn<String> whiteName = GeneratedColumn<String>(
    'white_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blackNameMeta = const VerificationMeta(
    'blackName',
  );
  @override
  late final GeneratedColumn<String> blackName = GeneratedColumn<String>(
    'black_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whiteRatingMeta = const VerificationMeta(
    'whiteRating',
  );
  @override
  late final GeneratedColumn<int> whiteRating = GeneratedColumn<int>(
    'white_rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blackRatingMeta = const VerificationMeta(
    'blackRating',
  );
  @override
  late final GeneratedColumn<int> blackRating = GeneratedColumn<int>(
    'black_rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ecoMeta = const VerificationMeta('eco');
  @override
  late final GeneratedColumn<String> eco = GeneratedColumn<String>(
    'eco',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingMeta = const VerificationMeta(
    'opening',
  );
  @override
  late final GeneratedColumn<String> opening = GeneratedColumn<String>(
    'opening',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ucisMeta = const VerificationMeta('ucis');
  @override
  late final GeneratedColumn<String> ucis = GeneratedColumn<String>(
    'ucis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sansMeta = const VerificationMeta('sans');
  @override
  late final GeneratedColumn<String> sans = GeneratedColumn<String>(
    'sans',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clocksMeta = const VerificationMeta('clocks');
  @override
  late final GeneratedColumn<String> clocks = GeneratedColumn<String>(
    'clocks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pgnMeta = const VerificationMeta('pgn');
  @override
  late final GeneratedColumn<String> pgn = GeneratedColumn<String>(
    'pgn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    url,
    endTime,
    timeClass,
    timeControl,
    rated,
    userWhite,
    result,
    resultDetail,
    whiteName,
    blackName,
    whiteRating,
    blackRating,
    eco,
    opening,
    ucis,
    sans,
    clocks,
    pgn,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbImportedGame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('time_class')) {
      context.handle(
        _timeClassMeta,
        timeClass.isAcceptableOrUnknown(data['time_class']!, _timeClassMeta),
      );
    } else if (isInserting) {
      context.missing(_timeClassMeta);
    }
    if (data.containsKey('time_control')) {
      context.handle(
        _timeControlMeta,
        timeControl.isAcceptableOrUnknown(
          data['time_control']!,
          _timeControlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeControlMeta);
    }
    if (data.containsKey('rated')) {
      context.handle(
        _ratedMeta,
        rated.isAcceptableOrUnknown(data['rated']!, _ratedMeta),
      );
    } else if (isInserting) {
      context.missing(_ratedMeta);
    }
    if (data.containsKey('user_white')) {
      context.handle(
        _userWhiteMeta,
        userWhite.isAcceptableOrUnknown(data['user_white']!, _userWhiteMeta),
      );
    } else if (isInserting) {
      context.missing(_userWhiteMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('result_detail')) {
      context.handle(
        _resultDetailMeta,
        resultDetail.isAcceptableOrUnknown(
          data['result_detail']!,
          _resultDetailMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resultDetailMeta);
    }
    if (data.containsKey('white_name')) {
      context.handle(
        _whiteNameMeta,
        whiteName.isAcceptableOrUnknown(data['white_name']!, _whiteNameMeta),
      );
    } else if (isInserting) {
      context.missing(_whiteNameMeta);
    }
    if (data.containsKey('black_name')) {
      context.handle(
        _blackNameMeta,
        blackName.isAcceptableOrUnknown(data['black_name']!, _blackNameMeta),
      );
    } else if (isInserting) {
      context.missing(_blackNameMeta);
    }
    if (data.containsKey('white_rating')) {
      context.handle(
        _whiteRatingMeta,
        whiteRating.isAcceptableOrUnknown(
          data['white_rating']!,
          _whiteRatingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_whiteRatingMeta);
    }
    if (data.containsKey('black_rating')) {
      context.handle(
        _blackRatingMeta,
        blackRating.isAcceptableOrUnknown(
          data['black_rating']!,
          _blackRatingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_blackRatingMeta);
    }
    if (data.containsKey('eco')) {
      context.handle(
        _ecoMeta,
        eco.isAcceptableOrUnknown(data['eco']!, _ecoMeta),
      );
    }
    if (data.containsKey('opening')) {
      context.handle(
        _openingMeta,
        opening.isAcceptableOrUnknown(data['opening']!, _openingMeta),
      );
    }
    if (data.containsKey('ucis')) {
      context.handle(
        _ucisMeta,
        ucis.isAcceptableOrUnknown(data['ucis']!, _ucisMeta),
      );
    } else if (isInserting) {
      context.missing(_ucisMeta);
    }
    if (data.containsKey('sans')) {
      context.handle(
        _sansMeta,
        sans.isAcceptableOrUnknown(data['sans']!, _sansMeta),
      );
    } else if (isInserting) {
      context.missing(_sansMeta);
    }
    if (data.containsKey('clocks')) {
      context.handle(
        _clocksMeta,
        clocks.isAcceptableOrUnknown(data['clocks']!, _clocksMeta),
      );
    }
    if (data.containsKey('pgn')) {
      context.handle(
        _pgnMeta,
        pgn.isAcceptableOrUnknown(data['pgn']!, _pgnMeta),
      );
    } else if (isInserting) {
      context.missing(_pgnMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbImportedGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbImportedGame(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      timeClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_class'],
      )!,
      timeControl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_control'],
      )!,
      rated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rated'],
      )!,
      userWhite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_white'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      resultDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_detail'],
      )!,
      whiteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}white_name'],
      )!,
      blackName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}black_name'],
      )!,
      whiteRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}white_rating'],
      )!,
      blackRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}black_rating'],
      )!,
      eco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eco'],
      ),
      opening: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening'],
      ),
      ucis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ucis'],
      )!,
      sans: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sans'],
      )!,
      clocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clocks'],
      ),
      pgn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pgn'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ImportedGamesTable createAlias(String alias) {
    return $ImportedGamesTable(attachedDatabase, alias);
  }
}

class DbImportedGame extends DataClass implements Insertable<DbImportedGame> {
  /// `chesscom:<game id>`.
  final String id;

  /// The account the game was fetched for, lower case.
  final String username;
  final String url;

  /// Unix seconds.
  final int endTime;

  /// `bullet`, `blitz`, `rapid` or `daily`.
  final String timeClass;

  /// chess.com's time control, e.g. `180+2` or `1/86400`.
  final String timeControl;
  final bool rated;

  /// Whether [username] had White.
  final bool userWhite;

  /// From the user's side: `win`, `draw` or `loss`.
  final String result;

  /// chess.com's result code for the losing (or drawing) side, e.g.
  /// `checkmated`, `timeout`, `agreed`.
  final String resultDetail;
  final String whiteName;
  final String blackName;
  final int whiteRating;
  final int blackRating;
  final String? eco;
  final String? opening;

  /// Mainline moves in UCI, space-separated.
  final String ucis;

  /// Mainline moves in SAN, space-separated.
  final String sans;

  /// Remaining clock after each ply in tenths of a second, comma-separated,
  /// or null without `%clk`.
  final String? clocks;
  final String pgn;
  final int fetchedAt;
  const DbImportedGame({
    required this.id,
    required this.username,
    required this.url,
    required this.endTime,
    required this.timeClass,
    required this.timeControl,
    required this.rated,
    required this.userWhite,
    required this.result,
    required this.resultDetail,
    required this.whiteName,
    required this.blackName,
    required this.whiteRating,
    required this.blackRating,
    this.eco,
    this.opening,
    required this.ucis,
    required this.sans,
    this.clocks,
    required this.pgn,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['url'] = Variable<String>(url);
    map['end_time'] = Variable<int>(endTime);
    map['time_class'] = Variable<String>(timeClass);
    map['time_control'] = Variable<String>(timeControl);
    map['rated'] = Variable<bool>(rated);
    map['user_white'] = Variable<bool>(userWhite);
    map['result'] = Variable<String>(result);
    map['result_detail'] = Variable<String>(resultDetail);
    map['white_name'] = Variable<String>(whiteName);
    map['black_name'] = Variable<String>(blackName);
    map['white_rating'] = Variable<int>(whiteRating);
    map['black_rating'] = Variable<int>(blackRating);
    if (!nullToAbsent || eco != null) {
      map['eco'] = Variable<String>(eco);
    }
    if (!nullToAbsent || opening != null) {
      map['opening'] = Variable<String>(opening);
    }
    map['ucis'] = Variable<String>(ucis);
    map['sans'] = Variable<String>(sans);
    if (!nullToAbsent || clocks != null) {
      map['clocks'] = Variable<String>(clocks);
    }
    map['pgn'] = Variable<String>(pgn);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  ImportedGamesCompanion toCompanion(bool nullToAbsent) {
    return ImportedGamesCompanion(
      id: Value(id),
      username: Value(username),
      url: Value(url),
      endTime: Value(endTime),
      timeClass: Value(timeClass),
      timeControl: Value(timeControl),
      rated: Value(rated),
      userWhite: Value(userWhite),
      result: Value(result),
      resultDetail: Value(resultDetail),
      whiteName: Value(whiteName),
      blackName: Value(blackName),
      whiteRating: Value(whiteRating),
      blackRating: Value(blackRating),
      eco: eco == null && nullToAbsent ? const Value.absent() : Value(eco),
      opening: opening == null && nullToAbsent
          ? const Value.absent()
          : Value(opening),
      ucis: Value(ucis),
      sans: Value(sans),
      clocks: clocks == null && nullToAbsent
          ? const Value.absent()
          : Value(clocks),
      pgn: Value(pgn),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory DbImportedGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbImportedGame(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      url: serializer.fromJson<String>(json['url']),
      endTime: serializer.fromJson<int>(json['endTime']),
      timeClass: serializer.fromJson<String>(json['timeClass']),
      timeControl: serializer.fromJson<String>(json['timeControl']),
      rated: serializer.fromJson<bool>(json['rated']),
      userWhite: serializer.fromJson<bool>(json['userWhite']),
      result: serializer.fromJson<String>(json['result']),
      resultDetail: serializer.fromJson<String>(json['resultDetail']),
      whiteName: serializer.fromJson<String>(json['whiteName']),
      blackName: serializer.fromJson<String>(json['blackName']),
      whiteRating: serializer.fromJson<int>(json['whiteRating']),
      blackRating: serializer.fromJson<int>(json['blackRating']),
      eco: serializer.fromJson<String?>(json['eco']),
      opening: serializer.fromJson<String?>(json['opening']),
      ucis: serializer.fromJson<String>(json['ucis']),
      sans: serializer.fromJson<String>(json['sans']),
      clocks: serializer.fromJson<String?>(json['clocks']),
      pgn: serializer.fromJson<String>(json['pgn']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'url': serializer.toJson<String>(url),
      'endTime': serializer.toJson<int>(endTime),
      'timeClass': serializer.toJson<String>(timeClass),
      'timeControl': serializer.toJson<String>(timeControl),
      'rated': serializer.toJson<bool>(rated),
      'userWhite': serializer.toJson<bool>(userWhite),
      'result': serializer.toJson<String>(result),
      'resultDetail': serializer.toJson<String>(resultDetail),
      'whiteName': serializer.toJson<String>(whiteName),
      'blackName': serializer.toJson<String>(blackName),
      'whiteRating': serializer.toJson<int>(whiteRating),
      'blackRating': serializer.toJson<int>(blackRating),
      'eco': serializer.toJson<String?>(eco),
      'opening': serializer.toJson<String?>(opening),
      'ucis': serializer.toJson<String>(ucis),
      'sans': serializer.toJson<String>(sans),
      'clocks': serializer.toJson<String?>(clocks),
      'pgn': serializer.toJson<String>(pgn),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  DbImportedGame copyWith({
    String? id,
    String? username,
    String? url,
    int? endTime,
    String? timeClass,
    String? timeControl,
    bool? rated,
    bool? userWhite,
    String? result,
    String? resultDetail,
    String? whiteName,
    String? blackName,
    int? whiteRating,
    int? blackRating,
    Value<String?> eco = const Value.absent(),
    Value<String?> opening = const Value.absent(),
    String? ucis,
    String? sans,
    Value<String?> clocks = const Value.absent(),
    String? pgn,
    int? fetchedAt,
  }) => DbImportedGame(
    id: id ?? this.id,
    username: username ?? this.username,
    url: url ?? this.url,
    endTime: endTime ?? this.endTime,
    timeClass: timeClass ?? this.timeClass,
    timeControl: timeControl ?? this.timeControl,
    rated: rated ?? this.rated,
    userWhite: userWhite ?? this.userWhite,
    result: result ?? this.result,
    resultDetail: resultDetail ?? this.resultDetail,
    whiteName: whiteName ?? this.whiteName,
    blackName: blackName ?? this.blackName,
    whiteRating: whiteRating ?? this.whiteRating,
    blackRating: blackRating ?? this.blackRating,
    eco: eco.present ? eco.value : this.eco,
    opening: opening.present ? opening.value : this.opening,
    ucis: ucis ?? this.ucis,
    sans: sans ?? this.sans,
    clocks: clocks.present ? clocks.value : this.clocks,
    pgn: pgn ?? this.pgn,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  DbImportedGame copyWithCompanion(ImportedGamesCompanion data) {
    return DbImportedGame(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      url: data.url.present ? data.url.value : this.url,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      timeClass: data.timeClass.present ? data.timeClass.value : this.timeClass,
      timeControl: data.timeControl.present
          ? data.timeControl.value
          : this.timeControl,
      rated: data.rated.present ? data.rated.value : this.rated,
      userWhite: data.userWhite.present ? data.userWhite.value : this.userWhite,
      result: data.result.present ? data.result.value : this.result,
      resultDetail: data.resultDetail.present
          ? data.resultDetail.value
          : this.resultDetail,
      whiteName: data.whiteName.present ? data.whiteName.value : this.whiteName,
      blackName: data.blackName.present ? data.blackName.value : this.blackName,
      whiteRating: data.whiteRating.present
          ? data.whiteRating.value
          : this.whiteRating,
      blackRating: data.blackRating.present
          ? data.blackRating.value
          : this.blackRating,
      eco: data.eco.present ? data.eco.value : this.eco,
      opening: data.opening.present ? data.opening.value : this.opening,
      ucis: data.ucis.present ? data.ucis.value : this.ucis,
      sans: data.sans.present ? data.sans.value : this.sans,
      clocks: data.clocks.present ? data.clocks.value : this.clocks,
      pgn: data.pgn.present ? data.pgn.value : this.pgn,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbImportedGame(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('url: $url, ')
          ..write('endTime: $endTime, ')
          ..write('timeClass: $timeClass, ')
          ..write('timeControl: $timeControl, ')
          ..write('rated: $rated, ')
          ..write('userWhite: $userWhite, ')
          ..write('result: $result, ')
          ..write('resultDetail: $resultDetail, ')
          ..write('whiteName: $whiteName, ')
          ..write('blackName: $blackName, ')
          ..write('whiteRating: $whiteRating, ')
          ..write('blackRating: $blackRating, ')
          ..write('eco: $eco, ')
          ..write('opening: $opening, ')
          ..write('ucis: $ucis, ')
          ..write('sans: $sans, ')
          ..write('clocks: $clocks, ')
          ..write('pgn: $pgn, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    username,
    url,
    endTime,
    timeClass,
    timeControl,
    rated,
    userWhite,
    result,
    resultDetail,
    whiteName,
    blackName,
    whiteRating,
    blackRating,
    eco,
    opening,
    ucis,
    sans,
    clocks,
    pgn,
    fetchedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbImportedGame &&
          other.id == this.id &&
          other.username == this.username &&
          other.url == this.url &&
          other.endTime == this.endTime &&
          other.timeClass == this.timeClass &&
          other.timeControl == this.timeControl &&
          other.rated == this.rated &&
          other.userWhite == this.userWhite &&
          other.result == this.result &&
          other.resultDetail == this.resultDetail &&
          other.whiteName == this.whiteName &&
          other.blackName == this.blackName &&
          other.whiteRating == this.whiteRating &&
          other.blackRating == this.blackRating &&
          other.eco == this.eco &&
          other.opening == this.opening &&
          other.ucis == this.ucis &&
          other.sans == this.sans &&
          other.clocks == this.clocks &&
          other.pgn == this.pgn &&
          other.fetchedAt == this.fetchedAt);
}

class ImportedGamesCompanion extends UpdateCompanion<DbImportedGame> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> url;
  final Value<int> endTime;
  final Value<String> timeClass;
  final Value<String> timeControl;
  final Value<bool> rated;
  final Value<bool> userWhite;
  final Value<String> result;
  final Value<String> resultDetail;
  final Value<String> whiteName;
  final Value<String> blackName;
  final Value<int> whiteRating;
  final Value<int> blackRating;
  final Value<String?> eco;
  final Value<String?> opening;
  final Value<String> ucis;
  final Value<String> sans;
  final Value<String?> clocks;
  final Value<String> pgn;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const ImportedGamesCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.url = const Value.absent(),
    this.endTime = const Value.absent(),
    this.timeClass = const Value.absent(),
    this.timeControl = const Value.absent(),
    this.rated = const Value.absent(),
    this.userWhite = const Value.absent(),
    this.result = const Value.absent(),
    this.resultDetail = const Value.absent(),
    this.whiteName = const Value.absent(),
    this.blackName = const Value.absent(),
    this.whiteRating = const Value.absent(),
    this.blackRating = const Value.absent(),
    this.eco = const Value.absent(),
    this.opening = const Value.absent(),
    this.ucis = const Value.absent(),
    this.sans = const Value.absent(),
    this.clocks = const Value.absent(),
    this.pgn = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedGamesCompanion.insert({
    required String id,
    required String username,
    required String url,
    required int endTime,
    required String timeClass,
    required String timeControl,
    required bool rated,
    required bool userWhite,
    required String result,
    required String resultDetail,
    required String whiteName,
    required String blackName,
    required int whiteRating,
    required int blackRating,
    this.eco = const Value.absent(),
    this.opening = const Value.absent(),
    required String ucis,
    required String sans,
    this.clocks = const Value.absent(),
    required String pgn,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       url = Value(url),
       endTime = Value(endTime),
       timeClass = Value(timeClass),
       timeControl = Value(timeControl),
       rated = Value(rated),
       userWhite = Value(userWhite),
       result = Value(result),
       resultDetail = Value(resultDetail),
       whiteName = Value(whiteName),
       blackName = Value(blackName),
       whiteRating = Value(whiteRating),
       blackRating = Value(blackRating),
       ucis = Value(ucis),
       sans = Value(sans),
       pgn = Value(pgn),
       fetchedAt = Value(fetchedAt);
  static Insertable<DbImportedGame> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? url,
    Expression<int>? endTime,
    Expression<String>? timeClass,
    Expression<String>? timeControl,
    Expression<bool>? rated,
    Expression<bool>? userWhite,
    Expression<String>? result,
    Expression<String>? resultDetail,
    Expression<String>? whiteName,
    Expression<String>? blackName,
    Expression<int>? whiteRating,
    Expression<int>? blackRating,
    Expression<String>? eco,
    Expression<String>? opening,
    Expression<String>? ucis,
    Expression<String>? sans,
    Expression<String>? clocks,
    Expression<String>? pgn,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (url != null) 'url': url,
      if (endTime != null) 'end_time': endTime,
      if (timeClass != null) 'time_class': timeClass,
      if (timeControl != null) 'time_control': timeControl,
      if (rated != null) 'rated': rated,
      if (userWhite != null) 'user_white': userWhite,
      if (result != null) 'result': result,
      if (resultDetail != null) 'result_detail': resultDetail,
      if (whiteName != null) 'white_name': whiteName,
      if (blackName != null) 'black_name': blackName,
      if (whiteRating != null) 'white_rating': whiteRating,
      if (blackRating != null) 'black_rating': blackRating,
      if (eco != null) 'eco': eco,
      if (opening != null) 'opening': opening,
      if (ucis != null) 'ucis': ucis,
      if (sans != null) 'sans': sans,
      if (clocks != null) 'clocks': clocks,
      if (pgn != null) 'pgn': pgn,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedGamesCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? url,
    Value<int>? endTime,
    Value<String>? timeClass,
    Value<String>? timeControl,
    Value<bool>? rated,
    Value<bool>? userWhite,
    Value<String>? result,
    Value<String>? resultDetail,
    Value<String>? whiteName,
    Value<String>? blackName,
    Value<int>? whiteRating,
    Value<int>? blackRating,
    Value<String?>? eco,
    Value<String?>? opening,
    Value<String>? ucis,
    Value<String>? sans,
    Value<String?>? clocks,
    Value<String>? pgn,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ImportedGamesCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      url: url ?? this.url,
      endTime: endTime ?? this.endTime,
      timeClass: timeClass ?? this.timeClass,
      timeControl: timeControl ?? this.timeControl,
      rated: rated ?? this.rated,
      userWhite: userWhite ?? this.userWhite,
      result: result ?? this.result,
      resultDetail: resultDetail ?? this.resultDetail,
      whiteName: whiteName ?? this.whiteName,
      blackName: blackName ?? this.blackName,
      whiteRating: whiteRating ?? this.whiteRating,
      blackRating: blackRating ?? this.blackRating,
      eco: eco ?? this.eco,
      opening: opening ?? this.opening,
      ucis: ucis ?? this.ucis,
      sans: sans ?? this.sans,
      clocks: clocks ?? this.clocks,
      pgn: pgn ?? this.pgn,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (timeClass.present) {
      map['time_class'] = Variable<String>(timeClass.value);
    }
    if (timeControl.present) {
      map['time_control'] = Variable<String>(timeControl.value);
    }
    if (rated.present) {
      map['rated'] = Variable<bool>(rated.value);
    }
    if (userWhite.present) {
      map['user_white'] = Variable<bool>(userWhite.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (resultDetail.present) {
      map['result_detail'] = Variable<String>(resultDetail.value);
    }
    if (whiteName.present) {
      map['white_name'] = Variable<String>(whiteName.value);
    }
    if (blackName.present) {
      map['black_name'] = Variable<String>(blackName.value);
    }
    if (whiteRating.present) {
      map['white_rating'] = Variable<int>(whiteRating.value);
    }
    if (blackRating.present) {
      map['black_rating'] = Variable<int>(blackRating.value);
    }
    if (eco.present) {
      map['eco'] = Variable<String>(eco.value);
    }
    if (opening.present) {
      map['opening'] = Variable<String>(opening.value);
    }
    if (ucis.present) {
      map['ucis'] = Variable<String>(ucis.value);
    }
    if (sans.present) {
      map['sans'] = Variable<String>(sans.value);
    }
    if (clocks.present) {
      map['clocks'] = Variable<String>(clocks.value);
    }
    if (pgn.present) {
      map['pgn'] = Variable<String>(pgn.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedGamesCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('url: $url, ')
          ..write('endTime: $endTime, ')
          ..write('timeClass: $timeClass, ')
          ..write('timeControl: $timeControl, ')
          ..write('rated: $rated, ')
          ..write('userWhite: $userWhite, ')
          ..write('result: $result, ')
          ..write('resultDetail: $resultDetail, ')
          ..write('whiteName: $whiteName, ')
          ..write('blackName: $blackName, ')
          ..write('whiteRating: $whiteRating, ')
          ..write('blackRating: $blackRating, ')
          ..write('eco: $eco, ')
          ..write('opening: $opening, ')
          ..write('ucis: $ucis, ')
          ..write('sans: $sans, ')
          ..write('clocks: $clocks, ')
          ..write('pgn: $pgn, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameArchivesTable extends GameArchives
    with TableInfo<$GameArchivesTable, DbGameArchive> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameArchivesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archiveMeta = const VerificationMeta(
    'archive',
  );
  @override
  late final GeneratedColumn<String> archive = GeneratedColumn<String>(
    'archive',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    username,
    archive,
    etag,
    lastModified,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_archives';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbGameArchive> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('archive')) {
      context.handle(
        _archiveMeta,
        archive.isAcceptableOrUnknown(data['archive']!, _archiveMeta),
      );
    } else if (isInserting) {
      context.missing(_archiveMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {username, archive};
  @override
  DbGameArchive map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGameArchive(
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      archive: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archive'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $GameArchivesTable createAlias(String alias) {
    return $GameArchivesTable(attachedDatabase, alias);
  }
}

class DbGameArchive extends DataClass implements Insertable<DbGameArchive> {
  final String username;
  final String archive;
  final String? etag;
  final String? lastModified;
  final int fetchedAt;
  const DbGameArchive({
    required this.username,
    required this.archive,
    this.etag,
    this.lastModified,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['username'] = Variable<String>(username);
    map['archive'] = Variable<String>(archive);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  GameArchivesCompanion toCompanion(bool nullToAbsent) {
    return GameArchivesCompanion(
      username: Value(username),
      archive: Value(archive),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory DbGameArchive.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGameArchive(
      username: serializer.fromJson<String>(json['username']),
      archive: serializer.fromJson<String>(json['archive']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'username': serializer.toJson<String>(username),
      'archive': serializer.toJson<String>(archive),
      'etag': serializer.toJson<String?>(etag),
      'lastModified': serializer.toJson<String?>(lastModified),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  DbGameArchive copyWith({
    String? username,
    String? archive,
    Value<String?> etag = const Value.absent(),
    Value<String?> lastModified = const Value.absent(),
    int? fetchedAt,
  }) => DbGameArchive(
    username: username ?? this.username,
    archive: archive ?? this.archive,
    etag: etag.present ? etag.value : this.etag,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  DbGameArchive copyWithCompanion(GameArchivesCompanion data) {
    return DbGameArchive(
      username: data.username.present ? data.username.value : this.username,
      archive: data.archive.present ? data.archive.value : this.archive,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGameArchive(')
          ..write('username: $username, ')
          ..write('archive: $archive, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(username, archive, etag, lastModified, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGameArchive &&
          other.username == this.username &&
          other.archive == this.archive &&
          other.etag == this.etag &&
          other.lastModified == this.lastModified &&
          other.fetchedAt == this.fetchedAt);
}

class GameArchivesCompanion extends UpdateCompanion<DbGameArchive> {
  final Value<String> username;
  final Value<String> archive;
  final Value<String?> etag;
  final Value<String?> lastModified;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const GameArchivesCompanion({
    this.username = const Value.absent(),
    this.archive = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameArchivesCompanion.insert({
    required String username,
    required String archive,
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : username = Value(username),
       archive = Value(archive),
       fetchedAt = Value(fetchedAt);
  static Insertable<DbGameArchive> custom({
    Expression<String>? username,
    Expression<String>? archive,
    Expression<String>? etag,
    Expression<String>? lastModified,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (username != null) 'username': username,
      if (archive != null) 'archive': archive,
      if (etag != null) 'etag': etag,
      if (lastModified != null) 'last_modified': lastModified,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameArchivesCompanion copyWith({
    Value<String>? username,
    Value<String>? archive,
    Value<String?>? etag,
    Value<String?>? lastModified,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return GameArchivesCompanion(
      username: username ?? this.username,
      archive: archive ?? this.archive,
      etag: etag ?? this.etag,
      lastModified: lastModified ?? this.lastModified,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (archive.present) {
      map['archive'] = Variable<String>(archive.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameArchivesCompanion(')
          ..write('username: $username, ')
          ..write('archive: $archive, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameReviewsTable extends GameReviews
    with TableInfo<$GameReviewsTable, DbGameReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileMeta = const VerificationMeta(
    'profile',
  );
  @override
  late final GeneratedColumn<int> profile = GeneratedColumn<int>(
    'profile',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analysedMeta = const VerificationMeta(
    'analysed',
  );
  @override
  late final GeneratedColumn<int> analysed = GeneratedColumn<int>(
    'analysed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completeMeta = const VerificationMeta(
    'complete',
  );
  @override
  late final GeneratedColumn<bool> complete = GeneratedColumn<bool>(
    'complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("complete" IN (0, 1))',
    ),
  );
  static const VerificationMeta _whiteAccuracyMeta = const VerificationMeta(
    'whiteAccuracy',
  );
  @override
  late final GeneratedColumn<double> whiteAccuracy = GeneratedColumn<double>(
    'white_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blackAccuracyMeta = const VerificationMeta(
    'blackAccuracy',
  );
  @override
  late final GeneratedColumn<double> blackAccuracy = GeneratedColumn<double>(
    'black_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whitePerformanceMeta = const VerificationMeta(
    'whitePerformance',
  );
  @override
  late final GeneratedColumn<int> whitePerformance = GeneratedColumn<int>(
    'white_performance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blackPerformanceMeta = const VerificationMeta(
    'blackPerformance',
  );
  @override
  late final GeneratedColumn<int> blackPerformance = GeneratedColumn<int>(
    'black_performance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    profile,
    engine,
    analysed,
    total,
    complete,
    whiteAccuracy,
    blackAccuracy,
    whitePerformance,
    blackPerformance,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbGameReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('profile')) {
      context.handle(
        _profileMeta,
        profile.isAcceptableOrUnknown(data['profile']!, _profileMeta),
      );
    } else if (isInserting) {
      context.missing(_profileMeta);
    }
    if (data.containsKey('engine')) {
      context.handle(
        _engineMeta,
        engine.isAcceptableOrUnknown(data['engine']!, _engineMeta),
      );
    } else if (isInserting) {
      context.missing(_engineMeta);
    }
    if (data.containsKey('analysed')) {
      context.handle(
        _analysedMeta,
        analysed.isAcceptableOrUnknown(data['analysed']!, _analysedMeta),
      );
    } else if (isInserting) {
      context.missing(_analysedMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('complete')) {
      context.handle(
        _completeMeta,
        complete.isAcceptableOrUnknown(data['complete']!, _completeMeta),
      );
    } else if (isInserting) {
      context.missing(_completeMeta);
    }
    if (data.containsKey('white_accuracy')) {
      context.handle(
        _whiteAccuracyMeta,
        whiteAccuracy.isAcceptableOrUnknown(
          data['white_accuracy']!,
          _whiteAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('black_accuracy')) {
      context.handle(
        _blackAccuracyMeta,
        blackAccuracy.isAcceptableOrUnknown(
          data['black_accuracy']!,
          _blackAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('white_performance')) {
      context.handle(
        _whitePerformanceMeta,
        whitePerformance.isAcceptableOrUnknown(
          data['white_performance']!,
          _whitePerformanceMeta,
        ),
      );
    }
    if (data.containsKey('black_performance')) {
      context.handle(
        _blackPerformanceMeta,
        blackPerformance.isAcceptableOrUnknown(
          data['black_performance']!,
          _blackPerformanceMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, profile};
  @override
  DbGameReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGameReview(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      profile: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile'],
      )!,
      engine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine'],
      )!,
      analysed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}analysed'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      complete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}complete'],
      )!,
      whiteAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}white_accuracy'],
      ),
      blackAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}black_accuracy'],
      ),
      whitePerformance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}white_performance'],
      ),
      blackPerformance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}black_performance'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GameReviewsTable createAlias(String alias) {
    return $GameReviewsTable(attachedDatabase, alias);
  }
}

class DbGameReview extends DataClass implements Insertable<DbGameReview> {
  final String gameId;

  /// 0 Quick, 1 Standard, 2 Deep.
  final int profile;

  /// Engine name and version; a different engine invalidates the rows.
  final String engine;

  /// Positions analysed so far (resume point) and in total.
  final int analysed;
  final int total;
  final bool complete;
  final double? whiteAccuracy;
  final double? blackAccuracy;
  final int? whitePerformance;
  final int? blackPerformance;
  final int updatedAt;
  const DbGameReview({
    required this.gameId,
    required this.profile,
    required this.engine,
    required this.analysed,
    required this.total,
    required this.complete,
    this.whiteAccuracy,
    this.blackAccuracy,
    this.whitePerformance,
    this.blackPerformance,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['profile'] = Variable<int>(profile);
    map['engine'] = Variable<String>(engine);
    map['analysed'] = Variable<int>(analysed);
    map['total'] = Variable<int>(total);
    map['complete'] = Variable<bool>(complete);
    if (!nullToAbsent || whiteAccuracy != null) {
      map['white_accuracy'] = Variable<double>(whiteAccuracy);
    }
    if (!nullToAbsent || blackAccuracy != null) {
      map['black_accuracy'] = Variable<double>(blackAccuracy);
    }
    if (!nullToAbsent || whitePerformance != null) {
      map['white_performance'] = Variable<int>(whitePerformance);
    }
    if (!nullToAbsent || blackPerformance != null) {
      map['black_performance'] = Variable<int>(blackPerformance);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  GameReviewsCompanion toCompanion(bool nullToAbsent) {
    return GameReviewsCompanion(
      gameId: Value(gameId),
      profile: Value(profile),
      engine: Value(engine),
      analysed: Value(analysed),
      total: Value(total),
      complete: Value(complete),
      whiteAccuracy: whiteAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(whiteAccuracy),
      blackAccuracy: blackAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(blackAccuracy),
      whitePerformance: whitePerformance == null && nullToAbsent
          ? const Value.absent()
          : Value(whitePerformance),
      blackPerformance: blackPerformance == null && nullToAbsent
          ? const Value.absent()
          : Value(blackPerformance),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbGameReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGameReview(
      gameId: serializer.fromJson<String>(json['gameId']),
      profile: serializer.fromJson<int>(json['profile']),
      engine: serializer.fromJson<String>(json['engine']),
      analysed: serializer.fromJson<int>(json['analysed']),
      total: serializer.fromJson<int>(json['total']),
      complete: serializer.fromJson<bool>(json['complete']),
      whiteAccuracy: serializer.fromJson<double?>(json['whiteAccuracy']),
      blackAccuracy: serializer.fromJson<double?>(json['blackAccuracy']),
      whitePerformance: serializer.fromJson<int?>(json['whitePerformance']),
      blackPerformance: serializer.fromJson<int?>(json['blackPerformance']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'profile': serializer.toJson<int>(profile),
      'engine': serializer.toJson<String>(engine),
      'analysed': serializer.toJson<int>(analysed),
      'total': serializer.toJson<int>(total),
      'complete': serializer.toJson<bool>(complete),
      'whiteAccuracy': serializer.toJson<double?>(whiteAccuracy),
      'blackAccuracy': serializer.toJson<double?>(blackAccuracy),
      'whitePerformance': serializer.toJson<int?>(whitePerformance),
      'blackPerformance': serializer.toJson<int?>(blackPerformance),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DbGameReview copyWith({
    String? gameId,
    int? profile,
    String? engine,
    int? analysed,
    int? total,
    bool? complete,
    Value<double?> whiteAccuracy = const Value.absent(),
    Value<double?> blackAccuracy = const Value.absent(),
    Value<int?> whitePerformance = const Value.absent(),
    Value<int?> blackPerformance = const Value.absent(),
    int? updatedAt,
  }) => DbGameReview(
    gameId: gameId ?? this.gameId,
    profile: profile ?? this.profile,
    engine: engine ?? this.engine,
    analysed: analysed ?? this.analysed,
    total: total ?? this.total,
    complete: complete ?? this.complete,
    whiteAccuracy: whiteAccuracy.present
        ? whiteAccuracy.value
        : this.whiteAccuracy,
    blackAccuracy: blackAccuracy.present
        ? blackAccuracy.value
        : this.blackAccuracy,
    whitePerformance: whitePerformance.present
        ? whitePerformance.value
        : this.whitePerformance,
    blackPerformance: blackPerformance.present
        ? blackPerformance.value
        : this.blackPerformance,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbGameReview copyWithCompanion(GameReviewsCompanion data) {
    return DbGameReview(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      profile: data.profile.present ? data.profile.value : this.profile,
      engine: data.engine.present ? data.engine.value : this.engine,
      analysed: data.analysed.present ? data.analysed.value : this.analysed,
      total: data.total.present ? data.total.value : this.total,
      complete: data.complete.present ? data.complete.value : this.complete,
      whiteAccuracy: data.whiteAccuracy.present
          ? data.whiteAccuracy.value
          : this.whiteAccuracy,
      blackAccuracy: data.blackAccuracy.present
          ? data.blackAccuracy.value
          : this.blackAccuracy,
      whitePerformance: data.whitePerformance.present
          ? data.whitePerformance.value
          : this.whitePerformance,
      blackPerformance: data.blackPerformance.present
          ? data.blackPerformance.value
          : this.blackPerformance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGameReview(')
          ..write('gameId: $gameId, ')
          ..write('profile: $profile, ')
          ..write('engine: $engine, ')
          ..write('analysed: $analysed, ')
          ..write('total: $total, ')
          ..write('complete: $complete, ')
          ..write('whiteAccuracy: $whiteAccuracy, ')
          ..write('blackAccuracy: $blackAccuracy, ')
          ..write('whitePerformance: $whitePerformance, ')
          ..write('blackPerformance: $blackPerformance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    profile,
    engine,
    analysed,
    total,
    complete,
    whiteAccuracy,
    blackAccuracy,
    whitePerformance,
    blackPerformance,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGameReview &&
          other.gameId == this.gameId &&
          other.profile == this.profile &&
          other.engine == this.engine &&
          other.analysed == this.analysed &&
          other.total == this.total &&
          other.complete == this.complete &&
          other.whiteAccuracy == this.whiteAccuracy &&
          other.blackAccuracy == this.blackAccuracy &&
          other.whitePerformance == this.whitePerformance &&
          other.blackPerformance == this.blackPerformance &&
          other.updatedAt == this.updatedAt);
}

class GameReviewsCompanion extends UpdateCompanion<DbGameReview> {
  final Value<String> gameId;
  final Value<int> profile;
  final Value<String> engine;
  final Value<int> analysed;
  final Value<int> total;
  final Value<bool> complete;
  final Value<double?> whiteAccuracy;
  final Value<double?> blackAccuracy;
  final Value<int?> whitePerformance;
  final Value<int?> blackPerformance;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const GameReviewsCompanion({
    this.gameId = const Value.absent(),
    this.profile = const Value.absent(),
    this.engine = const Value.absent(),
    this.analysed = const Value.absent(),
    this.total = const Value.absent(),
    this.complete = const Value.absent(),
    this.whiteAccuracy = const Value.absent(),
    this.blackAccuracy = const Value.absent(),
    this.whitePerformance = const Value.absent(),
    this.blackPerformance = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameReviewsCompanion.insert({
    required String gameId,
    required int profile,
    required String engine,
    required int analysed,
    required int total,
    required bool complete,
    this.whiteAccuracy = const Value.absent(),
    this.blackAccuracy = const Value.absent(),
    this.whitePerformance = const Value.absent(),
    this.blackPerformance = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       profile = Value(profile),
       engine = Value(engine),
       analysed = Value(analysed),
       total = Value(total),
       complete = Value(complete),
       updatedAt = Value(updatedAt);
  static Insertable<DbGameReview> custom({
    Expression<String>? gameId,
    Expression<int>? profile,
    Expression<String>? engine,
    Expression<int>? analysed,
    Expression<int>? total,
    Expression<bool>? complete,
    Expression<double>? whiteAccuracy,
    Expression<double>? blackAccuracy,
    Expression<int>? whitePerformance,
    Expression<int>? blackPerformance,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (profile != null) 'profile': profile,
      if (engine != null) 'engine': engine,
      if (analysed != null) 'analysed': analysed,
      if (total != null) 'total': total,
      if (complete != null) 'complete': complete,
      if (whiteAccuracy != null) 'white_accuracy': whiteAccuracy,
      if (blackAccuracy != null) 'black_accuracy': blackAccuracy,
      if (whitePerformance != null) 'white_performance': whitePerformance,
      if (blackPerformance != null) 'black_performance': blackPerformance,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameReviewsCompanion copyWith({
    Value<String>? gameId,
    Value<int>? profile,
    Value<String>? engine,
    Value<int>? analysed,
    Value<int>? total,
    Value<bool>? complete,
    Value<double?>? whiteAccuracy,
    Value<double?>? blackAccuracy,
    Value<int?>? whitePerformance,
    Value<int?>? blackPerformance,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return GameReviewsCompanion(
      gameId: gameId ?? this.gameId,
      profile: profile ?? this.profile,
      engine: engine ?? this.engine,
      analysed: analysed ?? this.analysed,
      total: total ?? this.total,
      complete: complete ?? this.complete,
      whiteAccuracy: whiteAccuracy ?? this.whiteAccuracy,
      blackAccuracy: blackAccuracy ?? this.blackAccuracy,
      whitePerformance: whitePerformance ?? this.whitePerformance,
      blackPerformance: blackPerformance ?? this.blackPerformance,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (profile.present) {
      map['profile'] = Variable<int>(profile.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (analysed.present) {
      map['analysed'] = Variable<int>(analysed.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (complete.present) {
      map['complete'] = Variable<bool>(complete.value);
    }
    if (whiteAccuracy.present) {
      map['white_accuracy'] = Variable<double>(whiteAccuracy.value);
    }
    if (blackAccuracy.present) {
      map['black_accuracy'] = Variable<double>(blackAccuracy.value);
    }
    if (whitePerformance.present) {
      map['white_performance'] = Variable<int>(whitePerformance.value);
    }
    if (blackPerformance.present) {
      map['black_performance'] = Variable<int>(blackPerformance.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameReviewsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('profile: $profile, ')
          ..write('engine: $engine, ')
          ..write('analysed: $analysed, ')
          ..write('total: $total, ')
          ..write('complete: $complete, ')
          ..write('whiteAccuracy: $whiteAccuracy, ')
          ..write('blackAccuracy: $blackAccuracy, ')
          ..write('whitePerformance: $whitePerformance, ')
          ..write('blackPerformance: $blackPerformance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameAnalysisTable extends GameAnalysis
    with TableInfo<$GameAnalysisTable, DbGameAnalysis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameAnalysisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileMeta = const VerificationMeta(
    'profile',
  );
  @override
  late final GeneratedColumn<int> profile = GeneratedColumn<int>(
    'profile',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cpMeta = const VerificationMeta('cp');
  @override
  late final GeneratedColumn<int> cp = GeneratedColumn<int>(
    'cp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mateMeta = const VerificationMeta('mate');
  @override
  late final GeneratedColumn<int> mate = GeneratedColumn<int>(
    'mate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pvMeta = const VerificationMeta('pv');
  @override
  late final GeneratedColumn<String> pv = GeneratedColumn<String>(
    'pv',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cappedMeta = const VerificationMeta('capped');
  @override
  late final GeneratedColumn<bool> capped = GeneratedColumn<bool>(
    'capped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("capped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _secondCpMeta = const VerificationMeta(
    'secondCp',
  );
  @override
  late final GeneratedColumn<int> secondCp = GeneratedColumn<int>(
    'second_cp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondMateMeta = const VerificationMeta(
    'secondMate',
  );
  @override
  late final GeneratedColumn<int> secondMate = GeneratedColumn<int>(
    'second_mate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<int> label = GeneratedColumn<int>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    profile,
    ply,
    cp,
    mate,
    pv,
    depth,
    capped,
    secondCp,
    secondMate,
    label,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_analysis';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbGameAnalysis> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('profile')) {
      context.handle(
        _profileMeta,
        profile.isAcceptableOrUnknown(data['profile']!, _profileMeta),
      );
    } else if (isInserting) {
      context.missing(_profileMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('cp')) {
      context.handle(_cpMeta, cp.isAcceptableOrUnknown(data['cp']!, _cpMeta));
    }
    if (data.containsKey('mate')) {
      context.handle(
        _mateMeta,
        mate.isAcceptableOrUnknown(data['mate']!, _mateMeta),
      );
    }
    if (data.containsKey('pv')) {
      context.handle(_pvMeta, pv.isAcceptableOrUnknown(data['pv']!, _pvMeta));
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
    } else if (isInserting) {
      context.missing(_depthMeta);
    }
    if (data.containsKey('capped')) {
      context.handle(
        _cappedMeta,
        capped.isAcceptableOrUnknown(data['capped']!, _cappedMeta),
      );
    }
    if (data.containsKey('second_cp')) {
      context.handle(
        _secondCpMeta,
        secondCp.isAcceptableOrUnknown(data['second_cp']!, _secondCpMeta),
      );
    }
    if (data.containsKey('second_mate')) {
      context.handle(
        _secondMateMeta,
        secondMate.isAcceptableOrUnknown(data['second_mate']!, _secondMateMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, profile, ply};
  @override
  DbGameAnalysis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGameAnalysis(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      profile: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile'],
      )!,
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      cp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cp'],
      ),
      mate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mate'],
      ),
      pv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pv'],
      ),
      depth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depth'],
      )!,
      capped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}capped'],
      )!,
      secondCp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}second_cp'],
      ),
      secondMate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}second_mate'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $GameAnalysisTable createAlias(String alias) {
    return $GameAnalysisTable(attachedDatabase, alias);
  }
}

class DbGameAnalysis extends DataClass implements Insertable<DbGameAnalysis> {
  final String gameId;
  final int profile;
  final int ply;

  /// Best-line score: centipawns, or moves to mate when [mate] is set.
  final int? cp;
  final int? mate;

  /// Best move and its line (UCI, space-separated, at most 10 plies).
  final String? pv;
  final int depth;

  /// The per-position time cap stopped the search before [depth] was the
  /// profile's depth.
  final bool capped;

  /// Second-best move's score (MultiPV pass, candidates only).
  final int? secondCp;
  final int? secondMate;

  /// Classification of the move that led here (null for ply 0 and until
  /// classified); index into chess_core's `MoveLabel`.
  final int? label;
  const DbGameAnalysis({
    required this.gameId,
    required this.profile,
    required this.ply,
    this.cp,
    this.mate,
    this.pv,
    required this.depth,
    required this.capped,
    this.secondCp,
    this.secondMate,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['profile'] = Variable<int>(profile);
    map['ply'] = Variable<int>(ply);
    if (!nullToAbsent || cp != null) {
      map['cp'] = Variable<int>(cp);
    }
    if (!nullToAbsent || mate != null) {
      map['mate'] = Variable<int>(mate);
    }
    if (!nullToAbsent || pv != null) {
      map['pv'] = Variable<String>(pv);
    }
    map['depth'] = Variable<int>(depth);
    map['capped'] = Variable<bool>(capped);
    if (!nullToAbsent || secondCp != null) {
      map['second_cp'] = Variable<int>(secondCp);
    }
    if (!nullToAbsent || secondMate != null) {
      map['second_mate'] = Variable<int>(secondMate);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<int>(label);
    }
    return map;
  }

  GameAnalysisCompanion toCompanion(bool nullToAbsent) {
    return GameAnalysisCompanion(
      gameId: Value(gameId),
      profile: Value(profile),
      ply: Value(ply),
      cp: cp == null && nullToAbsent ? const Value.absent() : Value(cp),
      mate: mate == null && nullToAbsent ? const Value.absent() : Value(mate),
      pv: pv == null && nullToAbsent ? const Value.absent() : Value(pv),
      depth: Value(depth),
      capped: Value(capped),
      secondCp: secondCp == null && nullToAbsent
          ? const Value.absent()
          : Value(secondCp),
      secondMate: secondMate == null && nullToAbsent
          ? const Value.absent()
          : Value(secondMate),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory DbGameAnalysis.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGameAnalysis(
      gameId: serializer.fromJson<String>(json['gameId']),
      profile: serializer.fromJson<int>(json['profile']),
      ply: serializer.fromJson<int>(json['ply']),
      cp: serializer.fromJson<int?>(json['cp']),
      mate: serializer.fromJson<int?>(json['mate']),
      pv: serializer.fromJson<String?>(json['pv']),
      depth: serializer.fromJson<int>(json['depth']),
      capped: serializer.fromJson<bool>(json['capped']),
      secondCp: serializer.fromJson<int?>(json['secondCp']),
      secondMate: serializer.fromJson<int?>(json['secondMate']),
      label: serializer.fromJson<int?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'profile': serializer.toJson<int>(profile),
      'ply': serializer.toJson<int>(ply),
      'cp': serializer.toJson<int?>(cp),
      'mate': serializer.toJson<int?>(mate),
      'pv': serializer.toJson<String?>(pv),
      'depth': serializer.toJson<int>(depth),
      'capped': serializer.toJson<bool>(capped),
      'secondCp': serializer.toJson<int?>(secondCp),
      'secondMate': serializer.toJson<int?>(secondMate),
      'label': serializer.toJson<int?>(label),
    };
  }

  DbGameAnalysis copyWith({
    String? gameId,
    int? profile,
    int? ply,
    Value<int?> cp = const Value.absent(),
    Value<int?> mate = const Value.absent(),
    Value<String?> pv = const Value.absent(),
    int? depth,
    bool? capped,
    Value<int?> secondCp = const Value.absent(),
    Value<int?> secondMate = const Value.absent(),
    Value<int?> label = const Value.absent(),
  }) => DbGameAnalysis(
    gameId: gameId ?? this.gameId,
    profile: profile ?? this.profile,
    ply: ply ?? this.ply,
    cp: cp.present ? cp.value : this.cp,
    mate: mate.present ? mate.value : this.mate,
    pv: pv.present ? pv.value : this.pv,
    depth: depth ?? this.depth,
    capped: capped ?? this.capped,
    secondCp: secondCp.present ? secondCp.value : this.secondCp,
    secondMate: secondMate.present ? secondMate.value : this.secondMate,
    label: label.present ? label.value : this.label,
  );
  DbGameAnalysis copyWithCompanion(GameAnalysisCompanion data) {
    return DbGameAnalysis(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      profile: data.profile.present ? data.profile.value : this.profile,
      ply: data.ply.present ? data.ply.value : this.ply,
      cp: data.cp.present ? data.cp.value : this.cp,
      mate: data.mate.present ? data.mate.value : this.mate,
      pv: data.pv.present ? data.pv.value : this.pv,
      depth: data.depth.present ? data.depth.value : this.depth,
      capped: data.capped.present ? data.capped.value : this.capped,
      secondCp: data.secondCp.present ? data.secondCp.value : this.secondCp,
      secondMate: data.secondMate.present
          ? data.secondMate.value
          : this.secondMate,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGameAnalysis(')
          ..write('gameId: $gameId, ')
          ..write('profile: $profile, ')
          ..write('ply: $ply, ')
          ..write('cp: $cp, ')
          ..write('mate: $mate, ')
          ..write('pv: $pv, ')
          ..write('depth: $depth, ')
          ..write('capped: $capped, ')
          ..write('secondCp: $secondCp, ')
          ..write('secondMate: $secondMate, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    profile,
    ply,
    cp,
    mate,
    pv,
    depth,
    capped,
    secondCp,
    secondMate,
    label,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGameAnalysis &&
          other.gameId == this.gameId &&
          other.profile == this.profile &&
          other.ply == this.ply &&
          other.cp == this.cp &&
          other.mate == this.mate &&
          other.pv == this.pv &&
          other.depth == this.depth &&
          other.capped == this.capped &&
          other.secondCp == this.secondCp &&
          other.secondMate == this.secondMate &&
          other.label == this.label);
}

class GameAnalysisCompanion extends UpdateCompanion<DbGameAnalysis> {
  final Value<String> gameId;
  final Value<int> profile;
  final Value<int> ply;
  final Value<int?> cp;
  final Value<int?> mate;
  final Value<String?> pv;
  final Value<int> depth;
  final Value<bool> capped;
  final Value<int?> secondCp;
  final Value<int?> secondMate;
  final Value<int?> label;
  final Value<int> rowid;
  const GameAnalysisCompanion({
    this.gameId = const Value.absent(),
    this.profile = const Value.absent(),
    this.ply = const Value.absent(),
    this.cp = const Value.absent(),
    this.mate = const Value.absent(),
    this.pv = const Value.absent(),
    this.depth = const Value.absent(),
    this.capped = const Value.absent(),
    this.secondCp = const Value.absent(),
    this.secondMate = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameAnalysisCompanion.insert({
    required String gameId,
    required int profile,
    required int ply,
    this.cp = const Value.absent(),
    this.mate = const Value.absent(),
    this.pv = const Value.absent(),
    required int depth,
    this.capped = const Value.absent(),
    this.secondCp = const Value.absent(),
    this.secondMate = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       profile = Value(profile),
       ply = Value(ply),
       depth = Value(depth);
  static Insertable<DbGameAnalysis> custom({
    Expression<String>? gameId,
    Expression<int>? profile,
    Expression<int>? ply,
    Expression<int>? cp,
    Expression<int>? mate,
    Expression<String>? pv,
    Expression<int>? depth,
    Expression<bool>? capped,
    Expression<int>? secondCp,
    Expression<int>? secondMate,
    Expression<int>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (profile != null) 'profile': profile,
      if (ply != null) 'ply': ply,
      if (cp != null) 'cp': cp,
      if (mate != null) 'mate': mate,
      if (pv != null) 'pv': pv,
      if (depth != null) 'depth': depth,
      if (capped != null) 'capped': capped,
      if (secondCp != null) 'second_cp': secondCp,
      if (secondMate != null) 'second_mate': secondMate,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameAnalysisCompanion copyWith({
    Value<String>? gameId,
    Value<int>? profile,
    Value<int>? ply,
    Value<int?>? cp,
    Value<int?>? mate,
    Value<String?>? pv,
    Value<int>? depth,
    Value<bool>? capped,
    Value<int?>? secondCp,
    Value<int?>? secondMate,
    Value<int?>? label,
    Value<int>? rowid,
  }) {
    return GameAnalysisCompanion(
      gameId: gameId ?? this.gameId,
      profile: profile ?? this.profile,
      ply: ply ?? this.ply,
      cp: cp ?? this.cp,
      mate: mate ?? this.mate,
      pv: pv ?? this.pv,
      depth: depth ?? this.depth,
      capped: capped ?? this.capped,
      secondCp: secondCp ?? this.secondCp,
      secondMate: secondMate ?? this.secondMate,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (profile.present) {
      map['profile'] = Variable<int>(profile.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (cp.present) {
      map['cp'] = Variable<int>(cp.value);
    }
    if (mate.present) {
      map['mate'] = Variable<int>(mate.value);
    }
    if (pv.present) {
      map['pv'] = Variable<String>(pv.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (capped.present) {
      map['capped'] = Variable<bool>(capped.value);
    }
    if (secondCp.present) {
      map['second_cp'] = Variable<int>(secondCp.value);
    }
    if (secondMate.present) {
      map['second_mate'] = Variable<int>(secondMate.value);
    }
    if (label.present) {
      map['label'] = Variable<int>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameAnalysisCompanion(')
          ..write('gameId: $gameId, ')
          ..write('profile: $profile, ')
          ..write('ply: $ply, ')
          ..write('cp: $cp, ')
          ..write('mate: $mate, ')
          ..write('pv: $pv, ')
          ..write('depth: $depth, ')
          ..write('capped: $capped, ')
          ..write('secondCp: $secondCp, ')
          ..write('secondMate: $secondMate, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RepertoiresTable repertoires = $RepertoiresTable(this);
  late final $NodesTable nodes = $NodesTable(this);
  late final $LinesTable lines = $LinesTable(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $MoveGradesTable moveGrades = $MoveGradesTable(this);
  late final $DeviationEventsTable deviationEvents = $DeviationEventsTable(
    this,
  );
  late final $LineStatsTableTable lineStatsTable = $LineStatsTableTable(this);
  late final $PlyStatsTable plyStats = $PlyStatsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $ImportedGamesTable importedGames = $ImportedGamesTable(this);
  late final $GameArchivesTable gameArchives = $GameArchivesTable(this);
  late final $GameReviewsTable gameReviews = $GameReviewsTable(this);
  late final $GameAnalysisTable gameAnalysis = $GameAnalysisTable(this);
  late final Index linesByOrdinal = Index(
    'lines_by_ordinal',
    'CREATE INDEX lines_by_ordinal ON lines (repertoire_id, ordinal)',
  );
  late final Index runsByLine = Index(
    'runs_by_line',
    'CREATE INDEX runs_by_line ON runs (repertoire_id, line_key, finished_at)',
  );
  late final Index runsByDay = Index(
    'runs_by_day',
    'CREATE INDEX runs_by_day ON runs (local_day)',
  );
  late final Index runsBySynced = Index(
    'runs_by_synced',
    'CREATE INDEX runs_by_synced ON runs (synced_at)',
  );
  late final Index runsDailyStats = Index(
    'runs_daily_stats',
    'CREATE INDEX runs_daily_stats ON runs (repertoire_id, completed, local_day, graded_count, credit_sum)',
  );
  late final Index runsKeyUcis = Index(
    'runs_key_ucis',
    'CREATE INDEX runs_key_ucis ON runs (repertoire_id, line_key, ucis)',
  );
  late final Index gamesByUser = Index(
    'games_by_user',
    'CREATE INDEX games_by_user ON imported_games (username, end_time)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    repertoires,
    nodes,
    lines,
    runs,
    moveGrades,
    deviationEvents,
    lineStatsTable,
    plyStats,
    settings,
    syncState,
    appMeta,
    importedGames,
    gameArchives,
    gameReviews,
    gameAnalysis,
    linesByOrdinal,
    runsByLine,
    runsByDay,
    runsBySynced,
    runsDailyStats,
    runsKeyUcis,
    gamesByUser,
  ];
}

typedef $$RepertoiresTableCreateCompanionBuilder =
    RepertoiresCompanion Function({
      required String id,
      required String name,
      required String color,
      required String pgn,
      required String pgnHash,
      Value<String?> description,
      required int createdAt,
      required int updatedAt,
      required String updatedBy,
      Value<bool> deleted,
      Value<int?> lastTrainedAt,
      Value<String> drillStartFrom,
      Value<String?> lastMode,
      Value<int> rowid,
    });
typedef $$RepertoiresTableUpdateCompanionBuilder =
    RepertoiresCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> color,
      Value<String> pgn,
      Value<String> pgnHash,
      Value<String?> description,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<bool> deleted,
      Value<int?> lastTrainedAt,
      Value<String> drillStartFrom,
      Value<String?> lastMode,
      Value<int> rowid,
    });

class $$RepertoiresTableFilterComposer
    extends Composer<_$AppDatabase, $RepertoiresTable> {
  $$RepertoiresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pgnHash => $composableBuilder(
    column: $table.pgnHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTrainedAt => $composableBuilder(
    column: $table.lastTrainedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drillStartFrom => $composableBuilder(
    column: $table.drillStartFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMode => $composableBuilder(
    column: $table.lastMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RepertoiresTableOrderingComposer
    extends Composer<_$AppDatabase, $RepertoiresTable> {
  $$RepertoiresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pgnHash => $composableBuilder(
    column: $table.pgnHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTrainedAt => $composableBuilder(
    column: $table.lastTrainedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drillStartFrom => $composableBuilder(
    column: $table.drillStartFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMode => $composableBuilder(
    column: $table.lastMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RepertoiresTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepertoiresTable> {
  $$RepertoiresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get pgn =>
      $composableBuilder(column: $table.pgn, builder: (column) => column);

  GeneratedColumn<String> get pgnHash =>
      $composableBuilder(column: $table.pgnHash, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get lastTrainedAt => $composableBuilder(
    column: $table.lastTrainedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drillStartFrom => $composableBuilder(
    column: $table.drillStartFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMode =>
      $composableBuilder(column: $table.lastMode, builder: (column) => column);
}

class $$RepertoiresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepertoiresTable,
          DbRepertoire,
          $$RepertoiresTableFilterComposer,
          $$RepertoiresTableOrderingComposer,
          $$RepertoiresTableAnnotationComposer,
          $$RepertoiresTableCreateCompanionBuilder,
          $$RepertoiresTableUpdateCompanionBuilder,
          (
            DbRepertoire,
            BaseReferences<_$AppDatabase, $RepertoiresTable, DbRepertoire>,
          ),
          DbRepertoire,
          PrefetchHooks Function()
        > {
  $$RepertoiresTableTableManager(_$AppDatabase db, $RepertoiresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepertoiresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepertoiresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepertoiresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> pgn = const Value.absent(),
                Value<String> pgnHash = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> lastTrainedAt = const Value.absent(),
                Value<String> drillStartFrom = const Value.absent(),
                Value<String?> lastMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepertoiresCompanion(
                id: id,
                name: name,
                color: color,
                pgn: pgn,
                pgnHash: pgnHash,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deleted: deleted,
                lastTrainedAt: lastTrainedAt,
                drillStartFrom: drillStartFrom,
                lastMode: lastMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String color,
                required String pgn,
                required String pgnHash,
                Value<String?> description = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String updatedBy,
                Value<bool> deleted = const Value.absent(),
                Value<int?> lastTrainedAt = const Value.absent(),
                Value<String> drillStartFrom = const Value.absent(),
                Value<String?> lastMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepertoiresCompanion.insert(
                id: id,
                name: name,
                color: color,
                pgn: pgn,
                pgnHash: pgnHash,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deleted: deleted,
                lastTrainedAt: lastTrainedAt,
                drillStartFrom: drillStartFrom,
                lastMode: lastMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RepertoiresTable, DbRepertoire>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RepertoiresTable,
                    DbRepertoire
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RepertoiresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepertoiresTable,
      DbRepertoire,
      $$RepertoiresTableFilterComposer,
      $$RepertoiresTableOrderingComposer,
      $$RepertoiresTableAnnotationComposer,
      $$RepertoiresTableCreateCompanionBuilder,
      $$RepertoiresTableUpdateCompanionBuilder,
      (
        DbRepertoire,
        BaseReferences<_$AppDatabase, $RepertoiresTable, DbRepertoire>,
      ),
      DbRepertoire,
      PrefetchHooks Function()
    >;
typedef $$NodesTableCreateCompanionBuilder = NodesCompanion Function({
  required String repertoireId,
  required int nodeId,
  Value<int?> parentId,
  required int ply,
  Value<String?> san,
  Value<String?> uci,
  required String fen,
  required bool isUserMove,
  required int childIndex,
  Value<String?> why,
  Value<String?> plan,
  Value<String?> watch,
  Value<String?> alt,
  Value<String?> shapes,
  Value<String?> rawComment,
  Value<String?> nags,
  Value<int> rowid,
});
typedef $$NodesTableUpdateCompanionBuilder = NodesCompanion Function({
  Value<String> repertoireId,
  Value<int> nodeId,
  Value<int?> parentId,
  Value<int> ply,
  Value<String?> san,
  Value<String?> uci,
  Value<String> fen,
  Value<bool> isUserMove,
  Value<int> childIndex,
  Value<String?> why,
  Value<String?> plan,
  Value<String?> watch,
  Value<String?> alt,
  Value<String?> shapes,
  Value<String?> rawComment,
  Value<String?> nags,
  Value<int> rowid,
});

class $$NodesTableFilterComposer extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get san => $composableBuilder(
    column: $table.san,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uci => $composableBuilder(
    column: $table.uci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fen => $composableBuilder(
    column: $table.fen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUserMove => $composableBuilder(
    column: $table.isUserMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get childIndex => $composableBuilder(
    column: $table.childIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get why => $composableBuilder(
    column: $table.why,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watch => $composableBuilder(
    column: $table.watch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alt => $composableBuilder(
    column: $table.alt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shapes => $composableBuilder(
    column: $table.shapes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawComment => $composableBuilder(
    column: $table.rawComment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nags => $composableBuilder(
    column: $table.nags,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NodesTableOrderingComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get san => $composableBuilder(
    column: $table.san,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uci => $composableBuilder(
    column: $table.uci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fen => $composableBuilder(
    column: $table.fen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUserMove => $composableBuilder(
    column: $table.isUserMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get childIndex => $composableBuilder(
    column: $table.childIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get why => $composableBuilder(
    column: $table.why,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watch => $composableBuilder(
    column: $table.watch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alt => $composableBuilder(
    column: $table.alt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shapes => $composableBuilder(
    column: $table.shapes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawComment => $composableBuilder(
    column: $table.rawComment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nags => $composableBuilder(
    column: $table.nags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<String> get san =>
      $composableBuilder(column: $table.san, builder: (column) => column);

  GeneratedColumn<String> get uci =>
      $composableBuilder(column: $table.uci, builder: (column) => column);

  GeneratedColumn<String> get fen =>
      $composableBuilder(column: $table.fen, builder: (column) => column);

  GeneratedColumn<bool> get isUserMove => $composableBuilder(
    column: $table.isUserMove,
    builder: (column) => column,
  );

  GeneratedColumn<int> get childIndex => $composableBuilder(
    column: $table.childIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get why =>
      $composableBuilder(column: $table.why, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<String> get watch =>
      $composableBuilder(column: $table.watch, builder: (column) => column);

  GeneratedColumn<String> get alt =>
      $composableBuilder(column: $table.alt, builder: (column) => column);

  GeneratedColumn<String> get shapes =>
      $composableBuilder(column: $table.shapes, builder: (column) => column);

  GeneratedColumn<String> get rawComment => $composableBuilder(
    column: $table.rawComment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nags =>
      $composableBuilder(column: $table.nags, builder: (column) => column);
}

class $$NodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodesTable,
          DbNode,
          $$NodesTableFilterComposer,
          $$NodesTableOrderingComposer,
          $$NodesTableAnnotationComposer,
          $$NodesTableCreateCompanionBuilder,
          $$NodesTableUpdateCompanionBuilder,
          (DbNode, BaseReferences<_$AppDatabase, $NodesTable, DbNode>),
          DbNode,
          PrefetchHooks Function()
        > {
  $$NodesTableTableManager(_$AppDatabase db, $NodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> repertoireId = const Value.absent(),
                Value<int> nodeId = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<String?> san = const Value.absent(),
                Value<String?> uci = const Value.absent(),
                Value<String> fen = const Value.absent(),
                Value<bool> isUserMove = const Value.absent(),
                Value<int> childIndex = const Value.absent(),
                Value<String?> why = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<String?> watch = const Value.absent(),
                Value<String?> alt = const Value.absent(),
                Value<String?> shapes = const Value.absent(),
                Value<String?> rawComment = const Value.absent(),
                Value<String?> nags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodesCompanion(
                repertoireId: repertoireId,
                nodeId: nodeId,
                parentId: parentId,
                ply: ply,
                san: san,
                uci: uci,
                fen: fen,
                isUserMove: isUserMove,
                childIndex: childIndex,
                why: why,
                plan: plan,
                watch: watch,
                alt: alt,
                shapes: shapes,
                rawComment: rawComment,
                nags: nags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String repertoireId,
                required int nodeId,
                Value<int?> parentId = const Value.absent(),
                required int ply,
                Value<String?> san = const Value.absent(),
                Value<String?> uci = const Value.absent(),
                required String fen,
                required bool isUserMove,
                required int childIndex,
                Value<String?> why = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<String?> watch = const Value.absent(),
                Value<String?> alt = const Value.absent(),
                Value<String?> shapes = const Value.absent(),
                Value<String?> rawComment = const Value.absent(),
                Value<String?> nags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodesCompanion.insert(
                repertoireId: repertoireId,
                nodeId: nodeId,
                parentId: parentId,
                ply: ply,
                san: san,
                uci: uci,
                fen: fen,
                isUserMove: isUserMove,
                childIndex: childIndex,
                why: why,
                plan: plan,
                watch: watch,
                alt: alt,
                shapes: shapes,
                rawComment: rawComment,
                nags: nags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NodesTable, DbNode>(table),
                  BaseReferences<_$AppDatabase, $NodesTable, DbNode>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodesTable,
      DbNode,
      $$NodesTableFilterComposer,
      $$NodesTableOrderingComposer,
      $$NodesTableAnnotationComposer,
      $$NodesTableCreateCompanionBuilder,
      $$NodesTableUpdateCompanionBuilder,
      (DbNode, BaseReferences<_$AppDatabase, $NodesTable, DbNode>),
      DbNode,
      PrefetchHooks Function()
    >;
typedef $$LinesTableCreateCompanionBuilder = LinesCompanion Function({
  required String repertoireId,
  required String lineKey,
  required int leafNodeId,
  required int ordinal,
  required int plies,
  required int userMoveCount,
  required int branchPly,
  required String label,
  required String ucis,
  Value<int> rowid,
});
typedef $$LinesTableUpdateCompanionBuilder = LinesCompanion Function({
  Value<String> repertoireId,
  Value<String> lineKey,
  Value<int> leafNodeId,
  Value<int> ordinal,
  Value<int> plies,
  Value<int> userMoveCount,
  Value<int> branchPly,
  Value<String> label,
  Value<String> ucis,
  Value<int> rowid,
});

class $$LinesTableFilterComposer extends Composer<_$AppDatabase, $LinesTable> {
  $$LinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineKey => $composableBuilder(
    column: $table.lineKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leafNodeId => $composableBuilder(
    column: $table.leafNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plies => $composableBuilder(
    column: $table.plies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userMoveCount => $composableBuilder(
    column: $table.userMoveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get branchPly => $composableBuilder(
    column: $table.branchPly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinesTableOrderingComposer
    extends Composer<_$AppDatabase, $LinesTable> {
  $$LinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineKey => $composableBuilder(
    column: $table.lineKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leafNodeId => $composableBuilder(
    column: $table.leafNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plies => $composableBuilder(
    column: $table.plies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userMoveCount => $composableBuilder(
    column: $table.userMoveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get branchPly => $composableBuilder(
    column: $table.branchPly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinesTable> {
  $$LinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lineKey =>
      $composableBuilder(column: $table.lineKey, builder: (column) => column);

  GeneratedColumn<int> get leafNodeId => $composableBuilder(
    column: $table.leafNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<int> get plies =>
      $composableBuilder(column: $table.plies, builder: (column) => column);

  GeneratedColumn<int> get userMoveCount => $composableBuilder(
    column: $table.userMoveCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get branchPly =>
      $composableBuilder(column: $table.branchPly, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get ucis =>
      $composableBuilder(column: $table.ucis, builder: (column) => column);
}

class $$LinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinesTable,
          DbLine,
          $$LinesTableFilterComposer,
          $$LinesTableOrderingComposer,
          $$LinesTableAnnotationComposer,
          $$LinesTableCreateCompanionBuilder,
          $$LinesTableUpdateCompanionBuilder,
          (DbLine, BaseReferences<_$AppDatabase, $LinesTable, DbLine>),
          DbLine,
          PrefetchHooks Function()
        > {
  $$LinesTableTableManager(_$AppDatabase db, $LinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> repertoireId = const Value.absent(),
                Value<String> lineKey = const Value.absent(),
                Value<int> leafNodeId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> plies = const Value.absent(),
                Value<int> userMoveCount = const Value.absent(),
                Value<int> branchPly = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> ucis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinesCompanion(
                repertoireId: repertoireId,
                lineKey: lineKey,
                leafNodeId: leafNodeId,
                ordinal: ordinal,
                plies: plies,
                userMoveCount: userMoveCount,
                branchPly: branchPly,
                label: label,
                ucis: ucis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String repertoireId,
                required String lineKey,
                required int leafNodeId,
                required int ordinal,
                required int plies,
                required int userMoveCount,
                required int branchPly,
                required String label,
                required String ucis,
                Value<int> rowid = const Value.absent(),
              }) => LinesCompanion.insert(
                repertoireId: repertoireId,
                lineKey: lineKey,
                leafNodeId: leafNodeId,
                ordinal: ordinal,
                plies: plies,
                userMoveCount: userMoveCount,
                branchPly: branchPly,
                label: label,
                ucis: ucis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LinesTable, DbLine>(table),
                  BaseReferences<_$AppDatabase, $LinesTable, DbLine>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinesTable,
      DbLine,
      $$LinesTableFilterComposer,
      $$LinesTableOrderingComposer,
      $$LinesTableAnnotationComposer,
      $$LinesTableCreateCompanionBuilder,
      $$LinesTableUpdateCompanionBuilder,
      (DbLine, BaseReferences<_$AppDatabase, $LinesTable, DbLine>),
      DbLine,
      PrefetchHooks Function()
    >;
typedef $$RunsTableCreateCompanionBuilder = RunsCompanion Function({
  required String id,
  required String repertoireId,
  required String lineKey,
  required String ucis,
  required String mode,
  required int startPly,
  required String wrongMoveMode,
  required int startedAt,
  required int finishedAt,
  required String localDay,
  required bool completed,
  required bool deviated,
  required int gradedCount,
  required double creditSum,
  required int hintCount,
  required String deviceId,
  Value<int?> syncedAt,
  required int schema,
  Value<int> rowid,
});
typedef $$RunsTableUpdateCompanionBuilder = RunsCompanion Function({
  Value<String> id,
  Value<String> repertoireId,
  Value<String> lineKey,
  Value<String> ucis,
  Value<String> mode,
  Value<int> startPly,
  Value<String> wrongMoveMode,
  Value<int> startedAt,
  Value<int> finishedAt,
  Value<String> localDay,
  Value<bool> completed,
  Value<bool> deviated,
  Value<int> gradedCount,
  Value<double> creditSum,
  Value<int> hintCount,
  Value<String> deviceId,
  Value<int?> syncedAt,
  Value<int> schema,
  Value<int> rowid,
});

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineKey => $composableBuilder(
    column: $table.lineKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPly => $composableBuilder(
    column: $table.startPly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wrongMoveMode => $composableBuilder(
    column: $table.wrongMoveMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deviated => $composableBuilder(
    column: $table.deviated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gradedCount => $composableBuilder(
    column: $table.gradedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditSum => $composableBuilder(
    column: $table.creditSum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintCount => $composableBuilder(
    column: $table.hintCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schema => $composableBuilder(
    column: $table.schema,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineKey => $composableBuilder(
    column: $table.lineKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPly => $composableBuilder(
    column: $table.startPly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wrongMoveMode => $composableBuilder(
    column: $table.wrongMoveMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deviated => $composableBuilder(
    column: $table.deviated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gradedCount => $composableBuilder(
    column: $table.gradedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditSum => $composableBuilder(
    column: $table.creditSum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintCount => $composableBuilder(
    column: $table.hintCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schema => $composableBuilder(
    column: $table.schema,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lineKey =>
      $composableBuilder(column: $table.lineKey, builder: (column) => column);

  GeneratedColumn<String> get ucis =>
      $composableBuilder(column: $table.ucis, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get startPly =>
      $composableBuilder(column: $table.startPly, builder: (column) => column);

  GeneratedColumn<String> get wrongMoveMode => $composableBuilder(
    column: $table.wrongMoveMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get deviated =>
      $composableBuilder(column: $table.deviated, builder: (column) => column);

  GeneratedColumn<int> get gradedCount => $composableBuilder(
    column: $table.gradedCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditSum =>
      $composableBuilder(column: $table.creditSum, builder: (column) => column);

  GeneratedColumn<int> get hintCount =>
      $composableBuilder(column: $table.hintCount, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get schema =>
      $composableBuilder(column: $table.schema, builder: (column) => column);
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          DbRun,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (DbRun, BaseReferences<_$AppDatabase, $RunsTable, DbRun>),
          DbRun,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> repertoireId = const Value.absent(),
                Value<String> lineKey = const Value.absent(),
                Value<String> ucis = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> startPly = const Value.absent(),
                Value<String> wrongMoveMode = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> finishedAt = const Value.absent(),
                Value<String> localDay = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> deviated = const Value.absent(),
                Value<int> gradedCount = const Value.absent(),
                Value<double> creditSum = const Value.absent(),
                Value<int> hintCount = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> schema = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                repertoireId: repertoireId,
                lineKey: lineKey,
                ucis: ucis,
                mode: mode,
                startPly: startPly,
                wrongMoveMode: wrongMoveMode,
                startedAt: startedAt,
                finishedAt: finishedAt,
                localDay: localDay,
                completed: completed,
                deviated: deviated,
                gradedCount: gradedCount,
                creditSum: creditSum,
                hintCount: hintCount,
                deviceId: deviceId,
                syncedAt: syncedAt,
                schema: schema,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String repertoireId,
                required String lineKey,
                required String ucis,
                required String mode,
                required int startPly,
                required String wrongMoveMode,
                required int startedAt,
                required int finishedAt,
                required String localDay,
                required bool completed,
                required bool deviated,
                required int gradedCount,
                required double creditSum,
                required int hintCount,
                required String deviceId,
                Value<int?> syncedAt = const Value.absent(),
                required int schema,
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                repertoireId: repertoireId,
                lineKey: lineKey,
                ucis: ucis,
                mode: mode,
                startPly: startPly,
                wrongMoveMode: wrongMoveMode,
                startedAt: startedAt,
                finishedAt: finishedAt,
                localDay: localDay,
                completed: completed,
                deviated: deviated,
                gradedCount: gradedCount,
                creditSum: creditSum,
                hintCount: hintCount,
                deviceId: deviceId,
                syncedAt: syncedAt,
                schema: schema,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RunsTable, DbRun>(table),
                  BaseReferences<_$AppDatabase, $RunsTable, DbRun>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      DbRun,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (DbRun, BaseReferences<_$AppDatabase, $RunsTable, DbRun>),
      DbRun,
      PrefetchHooks Function()
    >;
typedef $$MoveGradesTableCreateCompanionBuilder = MoveGradesCompanion Function({
  required String runId,
  required int ply,
  required String expected,
  required String accepted,
  Value<String?> firstAttempt,
  required String result,
  required double credit,
  required int attempts,
  required int hintLevel,
  Value<int?> checkCp,
  Value<String?> checkStatus,
  Value<int> rowid,
});
typedef $$MoveGradesTableUpdateCompanionBuilder = MoveGradesCompanion Function({
  Value<String> runId,
  Value<int> ply,
  Value<String> expected,
  Value<String> accepted,
  Value<String?> firstAttempt,
  Value<String> result,
  Value<double> credit,
  Value<int> attempts,
  Value<int> hintLevel,
  Value<int?> checkCp,
  Value<String?> checkStatus,
  Value<int> rowid,
});

class $$MoveGradesTableFilterComposer
    extends Composer<_$AppDatabase, $MoveGradesTable> {
  $$MoveGradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expected => $composableBuilder(
    column: $table.expected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accepted => $composableBuilder(
    column: $table.accepted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstAttempt => $composableBuilder(
    column: $table.firstAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintLevel => $composableBuilder(
    column: $table.hintLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkCp => $composableBuilder(
    column: $table.checkCp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkStatus => $composableBuilder(
    column: $table.checkStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoveGradesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoveGradesTable> {
  $$MoveGradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expected => $composableBuilder(
    column: $table.expected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accepted => $composableBuilder(
    column: $table.accepted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstAttempt => $composableBuilder(
    column: $table.firstAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintLevel => $composableBuilder(
    column: $table.hintLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkCp => $composableBuilder(
    column: $table.checkCp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkStatus => $composableBuilder(
    column: $table.checkStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoveGradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoveGradesTable> {
  $$MoveGradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<String> get expected =>
      $composableBuilder(column: $table.expected, builder: (column) => column);

  GeneratedColumn<String> get accepted =>
      $composableBuilder(column: $table.accepted, builder: (column) => column);

  GeneratedColumn<String> get firstAttempt => $composableBuilder(
    column: $table.firstAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<double> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get hintLevel =>
      $composableBuilder(column: $table.hintLevel, builder: (column) => column);

  GeneratedColumn<int> get checkCp =>
      $composableBuilder(column: $table.checkCp, builder: (column) => column);

  GeneratedColumn<String> get checkStatus => $composableBuilder(
    column: $table.checkStatus,
    builder: (column) => column,
  );
}

class $$MoveGradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoveGradesTable,
          DbMoveGrade,
          $$MoveGradesTableFilterComposer,
          $$MoveGradesTableOrderingComposer,
          $$MoveGradesTableAnnotationComposer,
          $$MoveGradesTableCreateCompanionBuilder,
          $$MoveGradesTableUpdateCompanionBuilder,
          (
            DbMoveGrade,
            BaseReferences<_$AppDatabase, $MoveGradesTable, DbMoveGrade>,
          ),
          DbMoveGrade,
          PrefetchHooks Function()
        > {
  $$MoveGradesTableTableManager(_$AppDatabase db, $MoveGradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoveGradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoveGradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoveGradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<String> expected = const Value.absent(),
                Value<String> accepted = const Value.absent(),
                Value<String?> firstAttempt = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<double> credit = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> hintLevel = const Value.absent(),
                Value<int?> checkCp = const Value.absent(),
                Value<String?> checkStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoveGradesCompanion(
                runId: runId,
                ply: ply,
                expected: expected,
                accepted: accepted,
                firstAttempt: firstAttempt,
                result: result,
                credit: credit,
                attempts: attempts,
                hintLevel: hintLevel,
                checkCp: checkCp,
                checkStatus: checkStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required int ply,
                required String expected,
                required String accepted,
                Value<String?> firstAttempt = const Value.absent(),
                required String result,
                required double credit,
                required int attempts,
                required int hintLevel,
                Value<int?> checkCp = const Value.absent(),
                Value<String?> checkStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoveGradesCompanion.insert(
                runId: runId,
                ply: ply,
                expected: expected,
                accepted: accepted,
                firstAttempt: firstAttempt,
                result: result,
                credit: credit,
                attempts: attempts,
                hintLevel: hintLevel,
                checkCp: checkCp,
                checkStatus: checkStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoveGradesTable, DbMoveGrade>(table),
                  BaseReferences<_$AppDatabase, $MoveGradesTable, DbMoveGrade>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoveGradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoveGradesTable,
      DbMoveGrade,
      $$MoveGradesTableFilterComposer,
      $$MoveGradesTableOrderingComposer,
      $$MoveGradesTableAnnotationComposer,
      $$MoveGradesTableCreateCompanionBuilder,
      $$MoveGradesTableUpdateCompanionBuilder,
      (
        DbMoveGrade,
        BaseReferences<_$AppDatabase, $MoveGradesTable, DbMoveGrade>,
      ),
      DbMoveGrade,
      PrefetchHooks Function()
    >;
typedef $$DeviationEventsTableCreateCompanionBuilder =
    DeviationEventsCompanion Function({
      required String runId,
      required int ply,
      Value<String?> deviationUci,
      Value<String?> replyUci,
      required String bestUci,
      Value<int?> lossCp,
      required bool passed,
      Value<int> rowid,
    });
typedef $$DeviationEventsTableUpdateCompanionBuilder =
    DeviationEventsCompanion Function({
      Value<String> runId,
      Value<int> ply,
      Value<String?> deviationUci,
      Value<String?> replyUci,
      Value<String> bestUci,
      Value<int?> lossCp,
      Value<bool> passed,
      Value<int> rowid,
    });

class $$DeviationEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviationEventsTable> {
  $$DeviationEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviationUci => $composableBuilder(
    column: $table.deviationUci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyUci => $composableBuilder(
    column: $table.replyUci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestUci => $composableBuilder(
    column: $table.bestUci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lossCp => $composableBuilder(
    column: $table.lossCp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviationEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviationEventsTable> {
  $$DeviationEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviationUci => $composableBuilder(
    column: $table.deviationUci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyUci => $composableBuilder(
    column: $table.replyUci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestUci => $composableBuilder(
    column: $table.bestUci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lossCp => $composableBuilder(
    column: $table.lossCp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviationEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviationEventsTable> {
  $$DeviationEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<String> get deviationUci => $composableBuilder(
    column: $table.deviationUci,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyUci =>
      $composableBuilder(column: $table.replyUci, builder: (column) => column);

  GeneratedColumn<String> get bestUci =>
      $composableBuilder(column: $table.bestUci, builder: (column) => column);

  GeneratedColumn<int> get lossCp =>
      $composableBuilder(column: $table.lossCp, builder: (column) => column);

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);
}

class $$DeviationEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviationEventsTable,
          DbDeviationEvent,
          $$DeviationEventsTableFilterComposer,
          $$DeviationEventsTableOrderingComposer,
          $$DeviationEventsTableAnnotationComposer,
          $$DeviationEventsTableCreateCompanionBuilder,
          $$DeviationEventsTableUpdateCompanionBuilder,
          (
            DbDeviationEvent,
            BaseReferences<
              _$AppDatabase,
              $DeviationEventsTable,
              DbDeviationEvent
            >,
          ),
          DbDeviationEvent,
          PrefetchHooks Function()
        > {
  $$DeviationEventsTableTableManager(
    _$AppDatabase db,
    $DeviationEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviationEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviationEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviationEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<String?> deviationUci = const Value.absent(),
                Value<String?> replyUci = const Value.absent(),
                Value<String> bestUci = const Value.absent(),
                Value<int?> lossCp = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviationEventsCompanion(
                runId: runId,
                ply: ply,
                deviationUci: deviationUci,
                replyUci: replyUci,
                bestUci: bestUci,
                lossCp: lossCp,
                passed: passed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required int ply,
                Value<String?> deviationUci = const Value.absent(),
                Value<String?> replyUci = const Value.absent(),
                required String bestUci,
                Value<int?> lossCp = const Value.absent(),
                required bool passed,
                Value<int> rowid = const Value.absent(),
              }) => DeviationEventsCompanion.insert(
                runId: runId,
                ply: ply,
                deviationUci: deviationUci,
                replyUci: replyUci,
                bestUci: bestUci,
                lossCp: lossCp,
                passed: passed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviationEventsTable, DbDeviationEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviationEventsTable,
                    DbDeviationEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviationEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviationEventsTable,
      DbDeviationEvent,
      $$DeviationEventsTableFilterComposer,
      $$DeviationEventsTableOrderingComposer,
      $$DeviationEventsTableAnnotationComposer,
      $$DeviationEventsTableCreateCompanionBuilder,
      $$DeviationEventsTableUpdateCompanionBuilder,
      (
        DbDeviationEvent,
        BaseReferences<_$AppDatabase, $DeviationEventsTable, DbDeviationEvent>,
      ),
      DbDeviationEvent,
      PrefetchHooks Function()
    >;
typedef $$LineStatsTableTableCreateCompanionBuilder =
    LineStatsTableCompanion Function({
      required String repertoireId,
      required String lineKey,
      required bool archived,
      required int runCount,
      Value<double?> accuracy,
      Value<int?> lastPlayedAt,
      required bool inWeakPool,
      required int weakCleanStreak,
      required String srsState,
      required int srsReps,
      required double srsEase,
      required int srsIntervalDays,
      Value<String?> srsDueDay,
      required int srsLapses,
      Value<String?> srsFirstSeenDay,
      Value<int> rowid,
    });
typedef $$LineStatsTableTableUpdateCompanionBuilder =
    LineStatsTableCompanion Function({
      Value<String> repertoireId,
      Value<String> lineKey,
      Value<bool> archived,
      Value<int> runCount,
      Value<double?> accuracy,
      Value<int?> lastPlayedAt,
      Value<bool> inWeakPool,
      Value<int> weakCleanStreak,
      Value<String> srsState,
      Value<int> srsReps,
      Value<double> srsEase,
      Value<int> srsIntervalDays,
      Value<String?> srsDueDay,
      Value<int> srsLapses,
      Value<String?> srsFirstSeenDay,
      Value<int> rowid,
    });

class $$LineStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LineStatsTableTable> {
  $$LineStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineKey => $composableBuilder(
    column: $table.lineKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runCount => $composableBuilder(
    column: $table.runCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inWeakPool => $composableBuilder(
    column: $table.inWeakPool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weakCleanStreak => $composableBuilder(
    column: $table.weakCleanStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get srsState => $composableBuilder(
    column: $table.srsState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get srsReps => $composableBuilder(
    column: $table.srsReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get srsEase => $composableBuilder(
    column: $table.srsEase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get srsIntervalDays => $composableBuilder(
    column: $table.srsIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get srsDueDay => $composableBuilder(
    column: $table.srsDueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get srsLapses => $composableBuilder(
    column: $table.srsLapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get srsFirstSeenDay => $composableBuilder(
    column: $table.srsFirstSeenDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LineStatsTableTable> {
  $$LineStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineKey => $composableBuilder(
    column: $table.lineKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runCount => $composableBuilder(
    column: $table.runCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inWeakPool => $composableBuilder(
    column: $table.inWeakPool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weakCleanStreak => $composableBuilder(
    column: $table.weakCleanStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get srsState => $composableBuilder(
    column: $table.srsState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get srsReps => $composableBuilder(
    column: $table.srsReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get srsEase => $composableBuilder(
    column: $table.srsEase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get srsIntervalDays => $composableBuilder(
    column: $table.srsIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get srsDueDay => $composableBuilder(
    column: $table.srsDueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get srsLapses => $composableBuilder(
    column: $table.srsLapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get srsFirstSeenDay => $composableBuilder(
    column: $table.srsFirstSeenDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineStatsTableTable> {
  $$LineStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lineKey =>
      $composableBuilder(column: $table.lineKey, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get runCount =>
      $composableBuilder(column: $table.runCount, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inWeakPool => $composableBuilder(
    column: $table.inWeakPool,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weakCleanStreak => $composableBuilder(
    column: $table.weakCleanStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get srsState =>
      $composableBuilder(column: $table.srsState, builder: (column) => column);

  GeneratedColumn<int> get srsReps =>
      $composableBuilder(column: $table.srsReps, builder: (column) => column);

  GeneratedColumn<double> get srsEase =>
      $composableBuilder(column: $table.srsEase, builder: (column) => column);

  GeneratedColumn<int> get srsIntervalDays => $composableBuilder(
    column: $table.srsIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get srsDueDay =>
      $composableBuilder(column: $table.srsDueDay, builder: (column) => column);

  GeneratedColumn<int> get srsLapses =>
      $composableBuilder(column: $table.srsLapses, builder: (column) => column);

  GeneratedColumn<String> get srsFirstSeenDay => $composableBuilder(
    column: $table.srsFirstSeenDay,
    builder: (column) => column,
  );
}

class $$LineStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineStatsTableTable,
          DbLineStats,
          $$LineStatsTableTableFilterComposer,
          $$LineStatsTableTableOrderingComposer,
          $$LineStatsTableTableAnnotationComposer,
          $$LineStatsTableTableCreateCompanionBuilder,
          $$LineStatsTableTableUpdateCompanionBuilder,
          (
            DbLineStats,
            BaseReferences<_$AppDatabase, $LineStatsTableTable, DbLineStats>,
          ),
          DbLineStats,
          PrefetchHooks Function()
        > {
  $$LineStatsTableTableTableManager(
    _$AppDatabase db,
    $LineStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineStatsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> repertoireId = const Value.absent(),
                Value<String> lineKey = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> runCount = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<bool> inWeakPool = const Value.absent(),
                Value<int> weakCleanStreak = const Value.absent(),
                Value<String> srsState = const Value.absent(),
                Value<int> srsReps = const Value.absent(),
                Value<double> srsEase = const Value.absent(),
                Value<int> srsIntervalDays = const Value.absent(),
                Value<String?> srsDueDay = const Value.absent(),
                Value<int> srsLapses = const Value.absent(),
                Value<String?> srsFirstSeenDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineStatsTableCompanion(
                repertoireId: repertoireId,
                lineKey: lineKey,
                archived: archived,
                runCount: runCount,
                accuracy: accuracy,
                lastPlayedAt: lastPlayedAt,
                inWeakPool: inWeakPool,
                weakCleanStreak: weakCleanStreak,
                srsState: srsState,
                srsReps: srsReps,
                srsEase: srsEase,
                srsIntervalDays: srsIntervalDays,
                srsDueDay: srsDueDay,
                srsLapses: srsLapses,
                srsFirstSeenDay: srsFirstSeenDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String repertoireId,
                required String lineKey,
                required bool archived,
                required int runCount,
                Value<double?> accuracy = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                required bool inWeakPool,
                required int weakCleanStreak,
                required String srsState,
                required int srsReps,
                required double srsEase,
                required int srsIntervalDays,
                Value<String?> srsDueDay = const Value.absent(),
                required int srsLapses,
                Value<String?> srsFirstSeenDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineStatsTableCompanion.insert(
                repertoireId: repertoireId,
                lineKey: lineKey,
                archived: archived,
                runCount: runCount,
                accuracy: accuracy,
                lastPlayedAt: lastPlayedAt,
                inWeakPool: inWeakPool,
                weakCleanStreak: weakCleanStreak,
                srsState: srsState,
                srsReps: srsReps,
                srsEase: srsEase,
                srsIntervalDays: srsIntervalDays,
                srsDueDay: srsDueDay,
                srsLapses: srsLapses,
                srsFirstSeenDay: srsFirstSeenDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineStatsTableTable, DbLineStats>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LineStatsTableTable,
                    DbLineStats
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineStatsTableTable,
      DbLineStats,
      $$LineStatsTableTableFilterComposer,
      $$LineStatsTableTableOrderingComposer,
      $$LineStatsTableTableAnnotationComposer,
      $$LineStatsTableTableCreateCompanionBuilder,
      $$LineStatsTableTableUpdateCompanionBuilder,
      (
        DbLineStats,
        BaseReferences<_$AppDatabase, $LineStatsTableTable, DbLineStats>,
      ),
      DbLineStats,
      PrefetchHooks Function()
    >;
typedef $$PlyStatsTableCreateCompanionBuilder = PlyStatsCompanion Function({
  required String repertoireId,
  required String ucis,
  required int ply,
  required int attempts,
  required int misses,
  Value<int> rowid,
});
typedef $$PlyStatsTableUpdateCompanionBuilder = PlyStatsCompanion Function({
  Value<String> repertoireId,
  Value<String> ucis,
  Value<int> ply,
  Value<int> attempts,
  Value<int> misses,
  Value<int> rowid,
});

class $$PlyStatsTableFilterComposer
    extends Composer<_$AppDatabase, $PlyStatsTable> {
  $$PlyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get misses => $composableBuilder(
    column: $table.misses,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlyStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlyStatsTable> {
  $$PlyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get misses => $composableBuilder(
    column: $table.misses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlyStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlyStatsTable> {
  $$PlyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get repertoireId => $composableBuilder(
    column: $table.repertoireId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ucis =>
      $composableBuilder(column: $table.ucis, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get misses =>
      $composableBuilder(column: $table.misses, builder: (column) => column);
}

class $$PlyStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlyStatsTable,
          DbPlyStats,
          $$PlyStatsTableFilterComposer,
          $$PlyStatsTableOrderingComposer,
          $$PlyStatsTableAnnotationComposer,
          $$PlyStatsTableCreateCompanionBuilder,
          $$PlyStatsTableUpdateCompanionBuilder,
          (
            DbPlyStats,
            BaseReferences<_$AppDatabase, $PlyStatsTable, DbPlyStats>,
          ),
          DbPlyStats,
          PrefetchHooks Function()
        > {
  $$PlyStatsTableTableManager(_$AppDatabase db, $PlyStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlyStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> repertoireId = const Value.absent(),
                Value<String> ucis = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> misses = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlyStatsCompanion(
                repertoireId: repertoireId,
                ucis: ucis,
                ply: ply,
                attempts: attempts,
                misses: misses,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String repertoireId,
                required String ucis,
                required int ply,
                required int attempts,
                required int misses,
                Value<int> rowid = const Value.absent(),
              }) => PlyStatsCompanion.insert(
                repertoireId: repertoireId,
                ucis: ucis,
                ply: ply,
                attempts: attempts,
                misses: misses,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlyStatsTable, DbPlyStats>(table),
                  BaseReferences<_$AppDatabase, $PlyStatsTable, DbPlyStats>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlyStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlyStatsTable,
      DbPlyStats,
      $$PlyStatsTableFilterComposer,
      $$PlyStatsTableOrderingComposer,
      $$PlyStatsTableAnnotationComposer,
      $$PlyStatsTableCreateCompanionBuilder,
      $$PlyStatsTableUpdateCompanionBuilder,
      (DbPlyStats, BaseReferences<_$AppDatabase, $PlyStatsTable, DbPlyStats>),
      DbPlyStats,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          DbSetting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (DbSetting, BaseReferences<_$AppDatabase, $SettingsTable, DbSetting>),
          DbSetting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, DbSetting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, DbSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      DbSetting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (DbSetting, BaseReferences<_$AppDatabase, $SettingsTable, DbSetting>),
      DbSetting,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          DbSyncState,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            DbSyncState,
            BaseReferences<_$AppDatabase, $SyncStateTable, DbSyncState>,
          ),
          DbSyncState,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncStateCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SyncStateCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, DbSyncState>(table),
                  BaseReferences<_$AppDatabase, $SyncStateTable, DbSyncState>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      DbSyncState,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        DbSyncState,
        BaseReferences<_$AppDatabase, $SyncStateTable, DbSyncState>,
      ),
      DbSyncState,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          DbAppMeta,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (DbAppMeta, BaseReferences<_$AppDatabase, $AppMetaTable, DbAppMeta>),
          DbAppMeta,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, DbAppMeta>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, DbAppMeta>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      DbAppMeta,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (DbAppMeta, BaseReferences<_$AppDatabase, $AppMetaTable, DbAppMeta>),
      DbAppMeta,
      PrefetchHooks Function()
    >;
typedef $$ImportedGamesTableCreateCompanionBuilder =
    ImportedGamesCompanion Function({
      required String id,
      required String username,
      required String url,
      required int endTime,
      required String timeClass,
      required String timeControl,
      required bool rated,
      required bool userWhite,
      required String result,
      required String resultDetail,
      required String whiteName,
      required String blackName,
      required int whiteRating,
      required int blackRating,
      Value<String?> eco,
      Value<String?> opening,
      required String ucis,
      required String sans,
      Value<String?> clocks,
      required String pgn,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$ImportedGamesTableUpdateCompanionBuilder =
    ImportedGamesCompanion Function({
      Value<String> id,
      Value<String> username,
      Value<String> url,
      Value<int> endTime,
      Value<String> timeClass,
      Value<String> timeControl,
      Value<bool> rated,
      Value<bool> userWhite,
      Value<String> result,
      Value<String> resultDetail,
      Value<String> whiteName,
      Value<String> blackName,
      Value<int> whiteRating,
      Value<int> blackRating,
      Value<String?> eco,
      Value<String?> opening,
      Value<String> ucis,
      Value<String> sans,
      Value<String?> clocks,
      Value<String> pgn,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$ImportedGamesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportedGamesTable> {
  $$ImportedGamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeClass => $composableBuilder(
    column: $table.timeClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeControl => $composableBuilder(
    column: $table.timeControl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rated => $composableBuilder(
    column: $table.rated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userWhite => $composableBuilder(
    column: $table.userWhite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultDetail => $composableBuilder(
    column: $table.resultDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whiteName => $composableBuilder(
    column: $table.whiteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blackName => $composableBuilder(
    column: $table.blackName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get whiteRating => $composableBuilder(
    column: $table.whiteRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blackRating => $composableBuilder(
    column: $table.blackRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eco => $composableBuilder(
    column: $table.eco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opening => $composableBuilder(
    column: $table.opening,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sans => $composableBuilder(
    column: $table.sans,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clocks => $composableBuilder(
    column: $table.clocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportedGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportedGamesTable> {
  $$ImportedGamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeClass => $composableBuilder(
    column: $table.timeClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeControl => $composableBuilder(
    column: $table.timeControl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rated => $composableBuilder(
    column: $table.rated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userWhite => $composableBuilder(
    column: $table.userWhite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultDetail => $composableBuilder(
    column: $table.resultDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whiteName => $composableBuilder(
    column: $table.whiteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blackName => $composableBuilder(
    column: $table.blackName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get whiteRating => $composableBuilder(
    column: $table.whiteRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blackRating => $composableBuilder(
    column: $table.blackRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eco => $composableBuilder(
    column: $table.eco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opening => $composableBuilder(
    column: $table.opening,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ucis => $composableBuilder(
    column: $table.ucis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sans => $composableBuilder(
    column: $table.sans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clocks => $composableBuilder(
    column: $table.clocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportedGamesTable> {
  $$ImportedGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get timeClass =>
      $composableBuilder(column: $table.timeClass, builder: (column) => column);

  GeneratedColumn<String> get timeControl => $composableBuilder(
    column: $table.timeControl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rated =>
      $composableBuilder(column: $table.rated, builder: (column) => column);

  GeneratedColumn<bool> get userWhite =>
      $composableBuilder(column: $table.userWhite, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get resultDetail => $composableBuilder(
    column: $table.resultDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whiteName =>
      $composableBuilder(column: $table.whiteName, builder: (column) => column);

  GeneratedColumn<String> get blackName =>
      $composableBuilder(column: $table.blackName, builder: (column) => column);

  GeneratedColumn<int> get whiteRating => $composableBuilder(
    column: $table.whiteRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get blackRating => $composableBuilder(
    column: $table.blackRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eco =>
      $composableBuilder(column: $table.eco, builder: (column) => column);

  GeneratedColumn<String> get opening =>
      $composableBuilder(column: $table.opening, builder: (column) => column);

  GeneratedColumn<String> get ucis =>
      $composableBuilder(column: $table.ucis, builder: (column) => column);

  GeneratedColumn<String> get sans =>
      $composableBuilder(column: $table.sans, builder: (column) => column);

  GeneratedColumn<String> get clocks =>
      $composableBuilder(column: $table.clocks, builder: (column) => column);

  GeneratedColumn<String> get pgn =>
      $composableBuilder(column: $table.pgn, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ImportedGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportedGamesTable,
          DbImportedGame,
          $$ImportedGamesTableFilterComposer,
          $$ImportedGamesTableOrderingComposer,
          $$ImportedGamesTableAnnotationComposer,
          $$ImportedGamesTableCreateCompanionBuilder,
          $$ImportedGamesTableUpdateCompanionBuilder,
          (
            DbImportedGame,
            BaseReferences<_$AppDatabase, $ImportedGamesTable, DbImportedGame>,
          ),
          DbImportedGame,
          PrefetchHooks Function()
        > {
  $$ImportedGamesTableTableManager(_$AppDatabase db, $ImportedGamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<String> timeClass = const Value.absent(),
                Value<String> timeControl = const Value.absent(),
                Value<bool> rated = const Value.absent(),
                Value<bool> userWhite = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String> resultDetail = const Value.absent(),
                Value<String> whiteName = const Value.absent(),
                Value<String> blackName = const Value.absent(),
                Value<int> whiteRating = const Value.absent(),
                Value<int> blackRating = const Value.absent(),
                Value<String?> eco = const Value.absent(),
                Value<String?> opening = const Value.absent(),
                Value<String> ucis = const Value.absent(),
                Value<String> sans = const Value.absent(),
                Value<String?> clocks = const Value.absent(),
                Value<String> pgn = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedGamesCompanion(
                id: id,
                username: username,
                url: url,
                endTime: endTime,
                timeClass: timeClass,
                timeControl: timeControl,
                rated: rated,
                userWhite: userWhite,
                result: result,
                resultDetail: resultDetail,
                whiteName: whiteName,
                blackName: blackName,
                whiteRating: whiteRating,
                blackRating: blackRating,
                eco: eco,
                opening: opening,
                ucis: ucis,
                sans: sans,
                clocks: clocks,
                pgn: pgn,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                required String url,
                required int endTime,
                required String timeClass,
                required String timeControl,
                required bool rated,
                required bool userWhite,
                required String result,
                required String resultDetail,
                required String whiteName,
                required String blackName,
                required int whiteRating,
                required int blackRating,
                Value<String?> eco = const Value.absent(),
                Value<String?> opening = const Value.absent(),
                required String ucis,
                required String sans,
                Value<String?> clocks = const Value.absent(),
                required String pgn,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImportedGamesCompanion.insert(
                id: id,
                username: username,
                url: url,
                endTime: endTime,
                timeClass: timeClass,
                timeControl: timeControl,
                rated: rated,
                userWhite: userWhite,
                result: result,
                resultDetail: resultDetail,
                whiteName: whiteName,
                blackName: blackName,
                whiteRating: whiteRating,
                blackRating: blackRating,
                eco: eco,
                opening: opening,
                ucis: ucis,
                sans: sans,
                clocks: clocks,
                pgn: pgn,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportedGamesTable, DbImportedGame>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImportedGamesTable,
                    DbImportedGame
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportedGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportedGamesTable,
      DbImportedGame,
      $$ImportedGamesTableFilterComposer,
      $$ImportedGamesTableOrderingComposer,
      $$ImportedGamesTableAnnotationComposer,
      $$ImportedGamesTableCreateCompanionBuilder,
      $$ImportedGamesTableUpdateCompanionBuilder,
      (
        DbImportedGame,
        BaseReferences<_$AppDatabase, $ImportedGamesTable, DbImportedGame>,
      ),
      DbImportedGame,
      PrefetchHooks Function()
    >;
typedef $$GameArchivesTableCreateCompanionBuilder =
    GameArchivesCompanion Function({
      required String username,
      required String archive,
      Value<String?> etag,
      Value<String?> lastModified,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$GameArchivesTableUpdateCompanionBuilder =
    GameArchivesCompanion Function({
      Value<String> username,
      Value<String> archive,
      Value<String?> etag,
      Value<String?> lastModified,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$GameArchivesTableFilterComposer
    extends Composer<_$AppDatabase, $GameArchivesTable> {
  $$GameArchivesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archive => $composableBuilder(
    column: $table.archive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameArchivesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameArchivesTable> {
  $$GameArchivesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archive => $composableBuilder(
    column: $table.archive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameArchivesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameArchivesTable> {
  $$GameArchivesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get archive =>
      $composableBuilder(column: $table.archive, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$GameArchivesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameArchivesTable,
          DbGameArchive,
          $$GameArchivesTableFilterComposer,
          $$GameArchivesTableOrderingComposer,
          $$GameArchivesTableAnnotationComposer,
          $$GameArchivesTableCreateCompanionBuilder,
          $$GameArchivesTableUpdateCompanionBuilder,
          (
            DbGameArchive,
            BaseReferences<_$AppDatabase, $GameArchivesTable, DbGameArchive>,
          ),
          DbGameArchive,
          PrefetchHooks Function()
        > {
  $$GameArchivesTableTableManager(_$AppDatabase db, $GameArchivesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameArchivesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameArchivesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameArchivesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> username = const Value.absent(),
                Value<String> archive = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameArchivesCompanion(
                username: username,
                archive: archive,
                etag: etag,
                lastModified: lastModified,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String username,
                required String archive,
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => GameArchivesCompanion.insert(
                username: username,
                archive: archive,
                etag: etag,
                lastModified: lastModified,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameArchivesTable, DbGameArchive>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameArchivesTable,
                    DbGameArchive
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameArchivesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameArchivesTable,
      DbGameArchive,
      $$GameArchivesTableFilterComposer,
      $$GameArchivesTableOrderingComposer,
      $$GameArchivesTableAnnotationComposer,
      $$GameArchivesTableCreateCompanionBuilder,
      $$GameArchivesTableUpdateCompanionBuilder,
      (
        DbGameArchive,
        BaseReferences<_$AppDatabase, $GameArchivesTable, DbGameArchive>,
      ),
      DbGameArchive,
      PrefetchHooks Function()
    >;
typedef $$GameReviewsTableCreateCompanionBuilder =
    GameReviewsCompanion Function({
      required String gameId,
      required int profile,
      required String engine,
      required int analysed,
      required int total,
      required bool complete,
      Value<double?> whiteAccuracy,
      Value<double?> blackAccuracy,
      Value<int?> whitePerformance,
      Value<int?> blackPerformance,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$GameReviewsTableUpdateCompanionBuilder =
    GameReviewsCompanion Function({
      Value<String> gameId,
      Value<int> profile,
      Value<String> engine,
      Value<int> analysed,
      Value<int> total,
      Value<bool> complete,
      Value<double?> whiteAccuracy,
      Value<double?> blackAccuracy,
      Value<int?> whitePerformance,
      Value<int?> blackPerformance,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$GameReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $GameReviewsTable> {
  $$GameReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get analysed => $composableBuilder(
    column: $table.analysed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get complete => $composableBuilder(
    column: $table.complete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get whiteAccuracy => $composableBuilder(
    column: $table.whiteAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get blackAccuracy => $composableBuilder(
    column: $table.blackAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get whitePerformance => $composableBuilder(
    column: $table.whitePerformance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blackPerformance => $composableBuilder(
    column: $table.blackPerformance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameReviewsTable> {
  $$GameReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get analysed => $composableBuilder(
    column: $table.analysed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get complete => $composableBuilder(
    column: $table.complete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get whiteAccuracy => $composableBuilder(
    column: $table.whiteAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get blackAccuracy => $composableBuilder(
    column: $table.blackAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get whitePerformance => $composableBuilder(
    column: $table.whitePerformance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blackPerformance => $composableBuilder(
    column: $table.blackPerformance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameReviewsTable> {
  $$GameReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get profile =>
      $composableBuilder(column: $table.profile, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<int> get analysed =>
      $composableBuilder(column: $table.analysed, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<bool> get complete =>
      $composableBuilder(column: $table.complete, builder: (column) => column);

  GeneratedColumn<double> get whiteAccuracy => $composableBuilder(
    column: $table.whiteAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get blackAccuracy => $composableBuilder(
    column: $table.blackAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get whitePerformance => $composableBuilder(
    column: $table.whitePerformance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get blackPerformance => $composableBuilder(
    column: $table.blackPerformance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GameReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameReviewsTable,
          DbGameReview,
          $$GameReviewsTableFilterComposer,
          $$GameReviewsTableOrderingComposer,
          $$GameReviewsTableAnnotationComposer,
          $$GameReviewsTableCreateCompanionBuilder,
          $$GameReviewsTableUpdateCompanionBuilder,
          (
            DbGameReview,
            BaseReferences<_$AppDatabase, $GameReviewsTable, DbGameReview>,
          ),
          DbGameReview,
          PrefetchHooks Function()
        > {
  $$GameReviewsTableTableManager(_$AppDatabase db, $GameReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<int> profile = const Value.absent(),
                Value<String> engine = const Value.absent(),
                Value<int> analysed = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<bool> complete = const Value.absent(),
                Value<double?> whiteAccuracy = const Value.absent(),
                Value<double?> blackAccuracy = const Value.absent(),
                Value<int?> whitePerformance = const Value.absent(),
                Value<int?> blackPerformance = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameReviewsCompanion(
                gameId: gameId,
                profile: profile,
                engine: engine,
                analysed: analysed,
                total: total,
                complete: complete,
                whiteAccuracy: whiteAccuracy,
                blackAccuracy: blackAccuracy,
                whitePerformance: whitePerformance,
                blackPerformance: blackPerformance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required int profile,
                required String engine,
                required int analysed,
                required int total,
                required bool complete,
                Value<double?> whiteAccuracy = const Value.absent(),
                Value<double?> blackAccuracy = const Value.absent(),
                Value<int?> whitePerformance = const Value.absent(),
                Value<int?> blackPerformance = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GameReviewsCompanion.insert(
                gameId: gameId,
                profile: profile,
                engine: engine,
                analysed: analysed,
                total: total,
                complete: complete,
                whiteAccuracy: whiteAccuracy,
                blackAccuracy: blackAccuracy,
                whitePerformance: whitePerformance,
                blackPerformance: blackPerformance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameReviewsTable, DbGameReview>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameReviewsTable,
                    DbGameReview
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameReviewsTable,
      DbGameReview,
      $$GameReviewsTableFilterComposer,
      $$GameReviewsTableOrderingComposer,
      $$GameReviewsTableAnnotationComposer,
      $$GameReviewsTableCreateCompanionBuilder,
      $$GameReviewsTableUpdateCompanionBuilder,
      (
        DbGameReview,
        BaseReferences<_$AppDatabase, $GameReviewsTable, DbGameReview>,
      ),
      DbGameReview,
      PrefetchHooks Function()
    >;
typedef $$GameAnalysisTableCreateCompanionBuilder =
    GameAnalysisCompanion Function({
      required String gameId,
      required int profile,
      required int ply,
      Value<int?> cp,
      Value<int?> mate,
      Value<String?> pv,
      required int depth,
      Value<bool> capped,
      Value<int?> secondCp,
      Value<int?> secondMate,
      Value<int?> label,
      Value<int> rowid,
    });
typedef $$GameAnalysisTableUpdateCompanionBuilder =
    GameAnalysisCompanion Function({
      Value<String> gameId,
      Value<int> profile,
      Value<int> ply,
      Value<int?> cp,
      Value<int?> mate,
      Value<String?> pv,
      Value<int> depth,
      Value<bool> capped,
      Value<int?> secondCp,
      Value<int?> secondMate,
      Value<int?> label,
      Value<int> rowid,
    });

class $$GameAnalysisTableFilterComposer
    extends Composer<_$AppDatabase, $GameAnalysisTable> {
  $$GameAnalysisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cp => $composableBuilder(
    column: $table.cp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mate => $composableBuilder(
    column: $table.mate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pv => $composableBuilder(
    column: $table.pv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get capped => $composableBuilder(
    column: $table.capped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondCp => $composableBuilder(
    column: $table.secondCp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondMate => $composableBuilder(
    column: $table.secondMate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameAnalysisTableOrderingComposer
    extends Composer<_$AppDatabase, $GameAnalysisTable> {
  $$GameAnalysisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cp => $composableBuilder(
    column: $table.cp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mate => $composableBuilder(
    column: $table.mate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pv => $composableBuilder(
    column: $table.pv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get capped => $composableBuilder(
    column: $table.capped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondCp => $composableBuilder(
    column: $table.secondCp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondMate => $composableBuilder(
    column: $table.secondMate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameAnalysisTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameAnalysisTable> {
  $$GameAnalysisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get profile =>
      $composableBuilder(column: $table.profile, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<int> get cp =>
      $composableBuilder(column: $table.cp, builder: (column) => column);

  GeneratedColumn<int> get mate =>
      $composableBuilder(column: $table.mate, builder: (column) => column);

  GeneratedColumn<String> get pv =>
      $composableBuilder(column: $table.pv, builder: (column) => column);

  GeneratedColumn<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<bool> get capped =>
      $composableBuilder(column: $table.capped, builder: (column) => column);

  GeneratedColumn<int> get secondCp =>
      $composableBuilder(column: $table.secondCp, builder: (column) => column);

  GeneratedColumn<int> get secondMate => $composableBuilder(
    column: $table.secondMate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$GameAnalysisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameAnalysisTable,
          DbGameAnalysis,
          $$GameAnalysisTableFilterComposer,
          $$GameAnalysisTableOrderingComposer,
          $$GameAnalysisTableAnnotationComposer,
          $$GameAnalysisTableCreateCompanionBuilder,
          $$GameAnalysisTableUpdateCompanionBuilder,
          (
            DbGameAnalysis,
            BaseReferences<_$AppDatabase, $GameAnalysisTable, DbGameAnalysis>,
          ),
          DbGameAnalysis,
          PrefetchHooks Function()
        > {
  $$GameAnalysisTableTableManager(_$AppDatabase db, $GameAnalysisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameAnalysisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameAnalysisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameAnalysisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<int> profile = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<int?> cp = const Value.absent(),
                Value<int?> mate = const Value.absent(),
                Value<String?> pv = const Value.absent(),
                Value<int> depth = const Value.absent(),
                Value<bool> capped = const Value.absent(),
                Value<int?> secondCp = const Value.absent(),
                Value<int?> secondMate = const Value.absent(),
                Value<int?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameAnalysisCompanion(
                gameId: gameId,
                profile: profile,
                ply: ply,
                cp: cp,
                mate: mate,
                pv: pv,
                depth: depth,
                capped: capped,
                secondCp: secondCp,
                secondMate: secondMate,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required int profile,
                required int ply,
                Value<int?> cp = const Value.absent(),
                Value<int?> mate = const Value.absent(),
                Value<String?> pv = const Value.absent(),
                required int depth,
                Value<bool> capped = const Value.absent(),
                Value<int?> secondCp = const Value.absent(),
                Value<int?> secondMate = const Value.absent(),
                Value<int?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameAnalysisCompanion.insert(
                gameId: gameId,
                profile: profile,
                ply: ply,
                cp: cp,
                mate: mate,
                pv: pv,
                depth: depth,
                capped: capped,
                secondCp: secondCp,
                secondMate: secondMate,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameAnalysisTable, DbGameAnalysis>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameAnalysisTable,
                    DbGameAnalysis
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameAnalysisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameAnalysisTable,
      DbGameAnalysis,
      $$GameAnalysisTableFilterComposer,
      $$GameAnalysisTableOrderingComposer,
      $$GameAnalysisTableAnnotationComposer,
      $$GameAnalysisTableCreateCompanionBuilder,
      $$GameAnalysisTableUpdateCompanionBuilder,
      (
        DbGameAnalysis,
        BaseReferences<_$AppDatabase, $GameAnalysisTable, DbGameAnalysis>,
      ),
      DbGameAnalysis,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RepertoiresTableTableManager get repertoires =>
      $$RepertoiresTableTableManager(_db, _db.repertoires);
  $$NodesTableTableManager get nodes =>
      $$NodesTableTableManager(_db, _db.nodes);
  $$LinesTableTableManager get lines =>
      $$LinesTableTableManager(_db, _db.lines);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$MoveGradesTableTableManager get moveGrades =>
      $$MoveGradesTableTableManager(_db, _db.moveGrades);
  $$DeviationEventsTableTableManager get deviationEvents =>
      $$DeviationEventsTableTableManager(_db, _db.deviationEvents);
  $$LineStatsTableTableTableManager get lineStatsTable =>
      $$LineStatsTableTableTableManager(_db, _db.lineStatsTable);
  $$PlyStatsTableTableManager get plyStats =>
      $$PlyStatsTableTableManager(_db, _db.plyStats);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$ImportedGamesTableTableManager get importedGames =>
      $$ImportedGamesTableTableManager(_db, _db.importedGames);
  $$GameArchivesTableTableManager get gameArchives =>
      $$GameArchivesTableTableManager(_db, _db.gameArchives);
  $$GameReviewsTableTableManager get gameReviews =>
      $$GameReviewsTableTableManager(_db, _db.gameReviews);
  $$GameAnalysisTableTableManager get gameAnalysis =>
      $$GameAnalysisTableTableManager(_db, _db.gameAnalysis);
}
