// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShotsTable extends Shots with TableInfo<$ShotsTable, Shot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sceneIdMeta = const VerificationMeta(
    'sceneId',
  );
  @override
  late final GeneratedColumn<String> sceneId = GeneratedColumn<String>(
    'scene_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default-scene'),
  );
  static const VerificationMeta _shotNoMeta = const VerificationMeta('shotNo');
  @override
  late final GeneratedColumn<String> shotNo = GeneratedColumn<String>(
    'shot_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shotSizeMeta = const VerificationMeta(
    'shotSize',
  );
  @override
  late final GeneratedColumn<String> shotSize = GeneratedColumn<String>(
    'shot_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dialogueMeta = const VerificationMeta(
    'dialogue',
  );
  @override
  late final GeneratedColumn<String> dialogue = GeneratedColumn<String>(
    'dialogue',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sceneExpectationMeta = const VerificationMeta(
    'sceneExpectation',
  );
  @override
  late final GeneratedColumn<String> sceneExpectation = GeneratedColumn<String>(
    'scene_expectation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _audioMeta = const VerificationMeta('audio');
  @override
  late final GeneratedColumn<String> audio = GeneratedColumn<String>(
    'audio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cameraAngleMeta = const VerificationMeta(
    'cameraAngle',
  );
  @override
  late final GeneratedColumn<String> cameraAngle = GeneratedColumn<String>(
    'camera_angle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cameraMoveMeta = const VerificationMeta(
    'cameraMove',
  );
  @override
  late final GeneratedColumn<String> cameraMove = GeneratedColumn<String>(
    'camera_move',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cameraRigMeta = const VerificationMeta(
    'cameraRig',
  );
  @override
  late final GeneratedColumn<String> cameraRig = GeneratedColumn<String>(
    'camera_rig',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _focalLengthMeta = const VerificationMeta(
    'focalLength',
  );
  @override
  late final GeneratedColumn<String> focalLength = GeneratedColumn<String>(
    'focal_length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    orderIndex,
    sceneId,
    shotNo,
    shotSize,
    durationSec,
    content,
    dialogue,
    notes,
    sceneExpectation,
    audio,
    cameraAngle,
    cameraMove,
    cameraRig,
    focalLength,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('scene_id')) {
      context.handle(
        _sceneIdMeta,
        sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta),
      );
    }
    if (data.containsKey('shot_no')) {
      context.handle(
        _shotNoMeta,
        shotNo.isAcceptableOrUnknown(data['shot_no']!, _shotNoMeta),
      );
    } else if (isInserting) {
      context.missing(_shotNoMeta);
    }
    if (data.containsKey('shot_size')) {
      context.handle(
        _shotSizeMeta,
        shotSize.isAcceptableOrUnknown(data['shot_size']!, _shotSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_shotSizeMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('dialogue')) {
      context.handle(
        _dialogueMeta,
        dialogue.isAcceptableOrUnknown(data['dialogue']!, _dialogueMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('scene_expectation')) {
      context.handle(
        _sceneExpectationMeta,
        sceneExpectation.isAcceptableOrUnknown(
          data['scene_expectation']!,
          _sceneExpectationMeta,
        ),
      );
    }
    if (data.containsKey('audio')) {
      context.handle(
        _audioMeta,
        audio.isAcceptableOrUnknown(data['audio']!, _audioMeta),
      );
    }
    if (data.containsKey('camera_angle')) {
      context.handle(
        _cameraAngleMeta,
        cameraAngle.isAcceptableOrUnknown(
          data['camera_angle']!,
          _cameraAngleMeta,
        ),
      );
    }
    if (data.containsKey('camera_move')) {
      context.handle(
        _cameraMoveMeta,
        cameraMove.isAcceptableOrUnknown(data['camera_move']!, _cameraMoveMeta),
      );
    }
    if (data.containsKey('camera_rig')) {
      context.handle(
        _cameraRigMeta,
        cameraRig.isAcceptableOrUnknown(data['camera_rig']!, _cameraRigMeta),
      );
    }
    if (data.containsKey('focal_length')) {
      context.handle(
        _focalLengthMeta,
        focalLength.isAcceptableOrUnknown(
          data['focal_length']!,
          _focalLengthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      sceneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scene_id'],
      )!,
      shotNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shot_no'],
      )!,
      shotSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shot_size'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      dialogue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dialogue'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      sceneExpectation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scene_expectation'],
      )!,
      audio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio'],
      )!,
      cameraAngle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camera_angle'],
      )!,
      cameraMove: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camera_move'],
      )!,
      cameraRig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camera_rig'],
      )!,
      focalLength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focal_length'],
      )!,
    );
  }

  @override
  $ShotsTable createAlias(String alias) {
    return $ShotsTable(attachedDatabase, alias);
  }
}

class Shot extends DataClass implements Insertable<Shot> {
  final String id;
  final String projectId;
  final int orderIndex;
  final String sceneId;
  final String shotNo;
  final String shotSize;
  final int durationSec;
  final String content;
  final String dialogue;
  final String notes;
  final String sceneExpectation;
  final String audio;
  final String cameraAngle;
  final String cameraMove;
  final String cameraRig;
  final String focalLength;
  const Shot({
    required this.id,
    required this.projectId,
    required this.orderIndex,
    required this.sceneId,
    required this.shotNo,
    required this.shotSize,
    required this.durationSec,
    required this.content,
    required this.dialogue,
    required this.notes,
    required this.sceneExpectation,
    required this.audio,
    required this.cameraAngle,
    required this.cameraMove,
    required this.cameraRig,
    required this.focalLength,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['order_index'] = Variable<int>(orderIndex);
    map['scene_id'] = Variable<String>(sceneId);
    map['shot_no'] = Variable<String>(shotNo);
    map['shot_size'] = Variable<String>(shotSize);
    map['duration_sec'] = Variable<int>(durationSec);
    map['content'] = Variable<String>(content);
    map['dialogue'] = Variable<String>(dialogue);
    map['notes'] = Variable<String>(notes);
    map['scene_expectation'] = Variable<String>(sceneExpectation);
    map['audio'] = Variable<String>(audio);
    map['camera_angle'] = Variable<String>(cameraAngle);
    map['camera_move'] = Variable<String>(cameraMove);
    map['camera_rig'] = Variable<String>(cameraRig);
    map['focal_length'] = Variable<String>(focalLength);
    return map;
  }

  ShotsCompanion toCompanion(bool nullToAbsent) {
    return ShotsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      orderIndex: Value(orderIndex),
      sceneId: Value(sceneId),
      shotNo: Value(shotNo),
      shotSize: Value(shotSize),
      durationSec: Value(durationSec),
      content: Value(content),
      dialogue: Value(dialogue),
      notes: Value(notes),
      sceneExpectation: Value(sceneExpectation),
      audio: Value(audio),
      cameraAngle: Value(cameraAngle),
      cameraMove: Value(cameraMove),
      cameraRig: Value(cameraRig),
      focalLength: Value(focalLength),
    );
  }

  factory Shot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shot(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      sceneId: serializer.fromJson<String>(json['sceneId']),
      shotNo: serializer.fromJson<String>(json['shotNo']),
      shotSize: serializer.fromJson<String>(json['shotSize']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      content: serializer.fromJson<String>(json['content']),
      dialogue: serializer.fromJson<String>(json['dialogue']),
      notes: serializer.fromJson<String>(json['notes']),
      sceneExpectation: serializer.fromJson<String>(json['sceneExpectation']),
      audio: serializer.fromJson<String>(json['audio']),
      cameraAngle: serializer.fromJson<String>(json['cameraAngle']),
      cameraMove: serializer.fromJson<String>(json['cameraMove']),
      cameraRig: serializer.fromJson<String>(json['cameraRig']),
      focalLength: serializer.fromJson<String>(json['focalLength']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'sceneId': serializer.toJson<String>(sceneId),
      'shotNo': serializer.toJson<String>(shotNo),
      'shotSize': serializer.toJson<String>(shotSize),
      'durationSec': serializer.toJson<int>(durationSec),
      'content': serializer.toJson<String>(content),
      'dialogue': serializer.toJson<String>(dialogue),
      'notes': serializer.toJson<String>(notes),
      'sceneExpectation': serializer.toJson<String>(sceneExpectation),
      'audio': serializer.toJson<String>(audio),
      'cameraAngle': serializer.toJson<String>(cameraAngle),
      'cameraMove': serializer.toJson<String>(cameraMove),
      'cameraRig': serializer.toJson<String>(cameraRig),
      'focalLength': serializer.toJson<String>(focalLength),
    };
  }

  Shot copyWith({
    String? id,
    String? projectId,
    int? orderIndex,
    String? sceneId,
    String? shotNo,
    String? shotSize,
    int? durationSec,
    String? content,
    String? dialogue,
    String? notes,
    String? sceneExpectation,
    String? audio,
    String? cameraAngle,
    String? cameraMove,
    String? cameraRig,
    String? focalLength,
  }) => Shot(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    orderIndex: orderIndex ?? this.orderIndex,
    sceneId: sceneId ?? this.sceneId,
    shotNo: shotNo ?? this.shotNo,
    shotSize: shotSize ?? this.shotSize,
    durationSec: durationSec ?? this.durationSec,
    content: content ?? this.content,
    dialogue: dialogue ?? this.dialogue,
    notes: notes ?? this.notes,
    sceneExpectation: sceneExpectation ?? this.sceneExpectation,
    audio: audio ?? this.audio,
    cameraAngle: cameraAngle ?? this.cameraAngle,
    cameraMove: cameraMove ?? this.cameraMove,
    cameraRig: cameraRig ?? this.cameraRig,
    focalLength: focalLength ?? this.focalLength,
  );
  Shot copyWithCompanion(ShotsCompanion data) {
    return Shot(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      shotNo: data.shotNo.present ? data.shotNo.value : this.shotNo,
      shotSize: data.shotSize.present ? data.shotSize.value : this.shotSize,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      content: data.content.present ? data.content.value : this.content,
      dialogue: data.dialogue.present ? data.dialogue.value : this.dialogue,
      notes: data.notes.present ? data.notes.value : this.notes,
      sceneExpectation: data.sceneExpectation.present
          ? data.sceneExpectation.value
          : this.sceneExpectation,
      audio: data.audio.present ? data.audio.value : this.audio,
      cameraAngle: data.cameraAngle.present
          ? data.cameraAngle.value
          : this.cameraAngle,
      cameraMove: data.cameraMove.present
          ? data.cameraMove.value
          : this.cameraMove,
      cameraRig: data.cameraRig.present ? data.cameraRig.value : this.cameraRig,
      focalLength: data.focalLength.present
          ? data.focalLength.value
          : this.focalLength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shot(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('sceneId: $sceneId, ')
          ..write('shotNo: $shotNo, ')
          ..write('shotSize: $shotSize, ')
          ..write('durationSec: $durationSec, ')
          ..write('content: $content, ')
          ..write('dialogue: $dialogue, ')
          ..write('notes: $notes, ')
          ..write('sceneExpectation: $sceneExpectation, ')
          ..write('audio: $audio, ')
          ..write('cameraAngle: $cameraAngle, ')
          ..write('cameraMove: $cameraMove, ')
          ..write('cameraRig: $cameraRig, ')
          ..write('focalLength: $focalLength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    orderIndex,
    sceneId,
    shotNo,
    shotSize,
    durationSec,
    content,
    dialogue,
    notes,
    sceneExpectation,
    audio,
    cameraAngle,
    cameraMove,
    cameraRig,
    focalLength,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shot &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.orderIndex == this.orderIndex &&
          other.sceneId == this.sceneId &&
          other.shotNo == this.shotNo &&
          other.shotSize == this.shotSize &&
          other.durationSec == this.durationSec &&
          other.content == this.content &&
          other.dialogue == this.dialogue &&
          other.notes == this.notes &&
          other.sceneExpectation == this.sceneExpectation &&
          other.audio == this.audio &&
          other.cameraAngle == this.cameraAngle &&
          other.cameraMove == this.cameraMove &&
          other.cameraRig == this.cameraRig &&
          other.focalLength == this.focalLength);
}

class ShotsCompanion extends UpdateCompanion<Shot> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<int> orderIndex;
  final Value<String> sceneId;
  final Value<String> shotNo;
  final Value<String> shotSize;
  final Value<int> durationSec;
  final Value<String> content;
  final Value<String> dialogue;
  final Value<String> notes;
  final Value<String> sceneExpectation;
  final Value<String> audio;
  final Value<String> cameraAngle;
  final Value<String> cameraMove;
  final Value<String> cameraRig;
  final Value<String> focalLength;
  final Value<int> rowid;
  const ShotsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.shotNo = const Value.absent(),
    this.shotSize = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.content = const Value.absent(),
    this.dialogue = const Value.absent(),
    this.notes = const Value.absent(),
    this.sceneExpectation = const Value.absent(),
    this.audio = const Value.absent(),
    this.cameraAngle = const Value.absent(),
    this.cameraMove = const Value.absent(),
    this.cameraRig = const Value.absent(),
    this.focalLength = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShotsCompanion.insert({
    required String id,
    required String projectId,
    required int orderIndex,
    this.sceneId = const Value.absent(),
    required String shotNo,
    required String shotSize,
    required int durationSec,
    this.content = const Value.absent(),
    this.dialogue = const Value.absent(),
    this.notes = const Value.absent(),
    this.sceneExpectation = const Value.absent(),
    this.audio = const Value.absent(),
    this.cameraAngle = const Value.absent(),
    this.cameraMove = const Value.absent(),
    this.cameraRig = const Value.absent(),
    this.focalLength = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       orderIndex = Value(orderIndex),
       shotNo = Value(shotNo),
       shotSize = Value(shotSize),
       durationSec = Value(durationSec);
  static Insertable<Shot> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<int>? orderIndex,
    Expression<String>? sceneId,
    Expression<String>? shotNo,
    Expression<String>? shotSize,
    Expression<int>? durationSec,
    Expression<String>? content,
    Expression<String>? dialogue,
    Expression<String>? notes,
    Expression<String>? sceneExpectation,
    Expression<String>? audio,
    Expression<String>? cameraAngle,
    Expression<String>? cameraMove,
    Expression<String>? cameraRig,
    Expression<String>? focalLength,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (sceneId != null) 'scene_id': sceneId,
      if (shotNo != null) 'shot_no': shotNo,
      if (shotSize != null) 'shot_size': shotSize,
      if (durationSec != null) 'duration_sec': durationSec,
      if (content != null) 'content': content,
      if (dialogue != null) 'dialogue': dialogue,
      if (notes != null) 'notes': notes,
      if (sceneExpectation != null) 'scene_expectation': sceneExpectation,
      if (audio != null) 'audio': audio,
      if (cameraAngle != null) 'camera_angle': cameraAngle,
      if (cameraMove != null) 'camera_move': cameraMove,
      if (cameraRig != null) 'camera_rig': cameraRig,
      if (focalLength != null) 'focal_length': focalLength,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShotsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<int>? orderIndex,
    Value<String>? sceneId,
    Value<String>? shotNo,
    Value<String>? shotSize,
    Value<int>? durationSec,
    Value<String>? content,
    Value<String>? dialogue,
    Value<String>? notes,
    Value<String>? sceneExpectation,
    Value<String>? audio,
    Value<String>? cameraAngle,
    Value<String>? cameraMove,
    Value<String>? cameraRig,
    Value<String>? focalLength,
    Value<int>? rowid,
  }) {
    return ShotsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      orderIndex: orderIndex ?? this.orderIndex,
      sceneId: sceneId ?? this.sceneId,
      shotNo: shotNo ?? this.shotNo,
      shotSize: shotSize ?? this.shotSize,
      durationSec: durationSec ?? this.durationSec,
      content: content ?? this.content,
      dialogue: dialogue ?? this.dialogue,
      notes: notes ?? this.notes,
      sceneExpectation: sceneExpectation ?? this.sceneExpectation,
      audio: audio ?? this.audio,
      cameraAngle: cameraAngle ?? this.cameraAngle,
      cameraMove: cameraMove ?? this.cameraMove,
      cameraRig: cameraRig ?? this.cameraRig,
      focalLength: focalLength ?? this.focalLength,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<String>(sceneId.value);
    }
    if (shotNo.present) {
      map['shot_no'] = Variable<String>(shotNo.value);
    }
    if (shotSize.present) {
      map['shot_size'] = Variable<String>(shotSize.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (dialogue.present) {
      map['dialogue'] = Variable<String>(dialogue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sceneExpectation.present) {
      map['scene_expectation'] = Variable<String>(sceneExpectation.value);
    }
    if (audio.present) {
      map['audio'] = Variable<String>(audio.value);
    }
    if (cameraAngle.present) {
      map['camera_angle'] = Variable<String>(cameraAngle.value);
    }
    if (cameraMove.present) {
      map['camera_move'] = Variable<String>(cameraMove.value);
    }
    if (cameraRig.present) {
      map['camera_rig'] = Variable<String>(cameraRig.value);
    }
    if (focalLength.present) {
      map['focal_length'] = Variable<String>(focalLength.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('sceneId: $sceneId, ')
          ..write('shotNo: $shotNo, ')
          ..write('shotSize: $shotSize, ')
          ..write('durationSec: $durationSec, ')
          ..write('content: $content, ')
          ..write('dialogue: $dialogue, ')
          ..write('notes: $notes, ')
          ..write('sceneExpectation: $sceneExpectation, ')
          ..write('audio: $audio, ')
          ..write('cameraAngle: $cameraAngle, ')
          ..write('cameraMove: $cameraMove, ')
          ..write('cameraRig: $cameraRig, ')
          ..write('focalLength: $focalLength, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShotAssetsTable extends ShotAssets
    with TableInfo<$ShotAssetsTable, ShotAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<String> shotId = GeneratedColumn<String>(
    'shot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldKeyMeta = const VerificationMeta(
    'fieldKey',
  );
  @override
  late final GeneratedColumn<String> fieldKey = GeneratedColumn<String>(
    'field_key',
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
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missingStateMeta = const VerificationMeta(
    'missingState',
  );
  @override
  late final GeneratedColumn<String> missingState = GeneratedColumn<String>(
    'missing_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shotId,
    fieldKey,
    mode,
    uri,
    fingerprint,
    missingState,
    width,
    height,
    bytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shot_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShotAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shot_id')) {
      context.handle(
        _shotIdMeta,
        shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('field_key')) {
      context.handle(
        _fieldKeyMeta,
        fieldKey.isAcceptableOrUnknown(data['field_key']!, _fieldKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldKeyMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('missing_state')) {
      context.handle(
        _missingStateMeta,
        missingState.isAcceptableOrUnknown(
          data['missing_state']!,
          _missingStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_missingStateMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShotAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShotAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shot_id'],
      )!,
      fieldKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_key'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      missingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}missing_state'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      ),
    );
  }

  @override
  $ShotAssetsTable createAlias(String alias) {
    return $ShotAssetsTable(attachedDatabase, alias);
  }
}

class ShotAsset extends DataClass implements Insertable<ShotAsset> {
  final String id;
  final String shotId;
  final String fieldKey;
  final String mode;
  final String uri;
  final String fingerprint;
  final String missingState;
  final int? width;
  final int? height;
  final int? bytes;
  const ShotAsset({
    required this.id,
    required this.shotId,
    required this.fieldKey,
    required this.mode,
    required this.uri,
    required this.fingerprint,
    required this.missingState,
    this.width,
    this.height,
    this.bytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shot_id'] = Variable<String>(shotId);
    map['field_key'] = Variable<String>(fieldKey);
    map['mode'] = Variable<String>(mode);
    map['uri'] = Variable<String>(uri);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['missing_state'] = Variable<String>(missingState);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || bytes != null) {
      map['bytes'] = Variable<int>(bytes);
    }
    return map;
  }

  ShotAssetsCompanion toCompanion(bool nullToAbsent) {
    return ShotAssetsCompanion(
      id: Value(id),
      shotId: Value(shotId),
      fieldKey: Value(fieldKey),
      mode: Value(mode),
      uri: Value(uri),
      fingerprint: Value(fingerprint),
      missingState: Value(missingState),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      bytes: bytes == null && nullToAbsent
          ? const Value.absent()
          : Value(bytes),
    );
  }

  factory ShotAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShotAsset(
      id: serializer.fromJson<String>(json['id']),
      shotId: serializer.fromJson<String>(json['shotId']),
      fieldKey: serializer.fromJson<String>(json['fieldKey']),
      mode: serializer.fromJson<String>(json['mode']),
      uri: serializer.fromJson<String>(json['uri']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      missingState: serializer.fromJson<String>(json['missingState']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      bytes: serializer.fromJson<int?>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shotId': serializer.toJson<String>(shotId),
      'fieldKey': serializer.toJson<String>(fieldKey),
      'mode': serializer.toJson<String>(mode),
      'uri': serializer.toJson<String>(uri),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'missingState': serializer.toJson<String>(missingState),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'bytes': serializer.toJson<int?>(bytes),
    };
  }

  ShotAsset copyWith({
    String? id,
    String? shotId,
    String? fieldKey,
    String? mode,
    String? uri,
    String? fingerprint,
    String? missingState,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> bytes = const Value.absent(),
  }) => ShotAsset(
    id: id ?? this.id,
    shotId: shotId ?? this.shotId,
    fieldKey: fieldKey ?? this.fieldKey,
    mode: mode ?? this.mode,
    uri: uri ?? this.uri,
    fingerprint: fingerprint ?? this.fingerprint,
    missingState: missingState ?? this.missingState,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    bytes: bytes.present ? bytes.value : this.bytes,
  );
  ShotAsset copyWithCompanion(ShotAssetsCompanion data) {
    return ShotAsset(
      id: data.id.present ? data.id.value : this.id,
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      fieldKey: data.fieldKey.present ? data.fieldKey.value : this.fieldKey,
      mode: data.mode.present ? data.mode.value : this.mode,
      uri: data.uri.present ? data.uri.value : this.uri,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      missingState: data.missingState.present
          ? data.missingState.value
          : this.missingState,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShotAsset(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('fieldKey: $fieldKey, ')
          ..write('mode: $mode, ')
          ..write('uri: $uri, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('missingState: $missingState, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shotId,
    fieldKey,
    mode,
    uri,
    fingerprint,
    missingState,
    width,
    height,
    bytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShotAsset &&
          other.id == this.id &&
          other.shotId == this.shotId &&
          other.fieldKey == this.fieldKey &&
          other.mode == this.mode &&
          other.uri == this.uri &&
          other.fingerprint == this.fingerprint &&
          other.missingState == this.missingState &&
          other.width == this.width &&
          other.height == this.height &&
          other.bytes == this.bytes);
}

class ShotAssetsCompanion extends UpdateCompanion<ShotAsset> {
  final Value<String> id;
  final Value<String> shotId;
  final Value<String> fieldKey;
  final Value<String> mode;
  final Value<String> uri;
  final Value<String> fingerprint;
  final Value<String> missingState;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> bytes;
  final Value<int> rowid;
  const ShotAssetsCompanion({
    this.id = const Value.absent(),
    this.shotId = const Value.absent(),
    this.fieldKey = const Value.absent(),
    this.mode = const Value.absent(),
    this.uri = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.missingState = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShotAssetsCompanion.insert({
    required String id,
    required String shotId,
    required String fieldKey,
    required String mode,
    required String uri,
    required String fingerprint,
    required String missingState,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shotId = Value(shotId),
       fieldKey = Value(fieldKey),
       mode = Value(mode),
       uri = Value(uri),
       fingerprint = Value(fingerprint),
       missingState = Value(missingState);
  static Insertable<ShotAsset> custom({
    Expression<String>? id,
    Expression<String>? shotId,
    Expression<String>? fieldKey,
    Expression<String>? mode,
    Expression<String>? uri,
    Expression<String>? fingerprint,
    Expression<String>? missingState,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shotId != null) 'shot_id': shotId,
      if (fieldKey != null) 'field_key': fieldKey,
      if (mode != null) 'mode': mode,
      if (uri != null) 'uri': uri,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (missingState != null) 'missing_state': missingState,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShotAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? shotId,
    Value<String>? fieldKey,
    Value<String>? mode,
    Value<String>? uri,
    Value<String>? fingerprint,
    Value<String>? missingState,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? bytes,
    Value<int>? rowid,
  }) {
    return ShotAssetsCompanion(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      fieldKey: fieldKey ?? this.fieldKey,
      mode: mode ?? this.mode,
      uri: uri ?? this.uri,
      fingerprint: fingerprint ?? this.fingerprint,
      missingState: missingState ?? this.missingState,
      width: width ?? this.width,
      height: height ?? this.height,
      bytes: bytes ?? this.bytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shotId.present) {
      map['shot_id'] = Variable<String>(shotId.value);
    }
    if (fieldKey.present) {
      map['field_key'] = Variable<String>(fieldKey.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (missingState.present) {
      map['missing_state'] = Variable<String>(missingState.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotAssetsCompanion(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('fieldKey: $fieldKey, ')
          ..write('mode: $mode, ')
          ..write('uri: $uri, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('missingState: $missingState, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoryboardScenesTable extends StoryboardScenes
    with TableInfo<$StoryboardScenesTable, StoryboardScene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoryboardScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberModeMeta = const VerificationMeta(
    'numberMode',
  );
  @override
  late final GeneratedColumn<String> numberMode = GeneratedColumn<String>(
    'number_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _manualNumberMeta = const VerificationMeta(
    'manualNumber',
  );
  @override
  late final GeneratedColumn<String> manualNumber = GeneratedColumn<String>(
    'manual_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    sortIndex,
    numberMode,
    manualNumber,
    name,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storyboard_scenes';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoryboardScene> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('number_mode')) {
      context.handle(
        _numberModeMeta,
        numberMode.isAcceptableOrUnknown(data['number_mode']!, _numberModeMeta),
      );
    }
    if (data.containsKey('manual_number')) {
      context.handle(
        _manualNumberMeta,
        manualNumber.isAcceptableOrUnknown(
          data['manual_number']!,
          _manualNumberMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoryboardScene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoryboardScene(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      numberMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_mode'],
      )!,
      manualNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StoryboardScenesTable createAlias(String alias) {
    return $StoryboardScenesTable(attachedDatabase, alias);
  }
}

class StoryboardScene extends DataClass implements Insertable<StoryboardScene> {
  final String id;
  final String projectId;
  final int sortIndex;
  final String numberMode;
  final String manualNumber;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StoryboardScene({
    required this.id,
    required this.projectId,
    required this.sortIndex,
    required this.numberMode,
    required this.manualNumber,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['sort_index'] = Variable<int>(sortIndex);
    map['number_mode'] = Variable<String>(numberMode);
    map['manual_number'] = Variable<String>(manualNumber);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StoryboardScenesCompanion toCompanion(bool nullToAbsent) {
    return StoryboardScenesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      sortIndex: Value(sortIndex),
      numberMode: Value(numberMode),
      manualNumber: Value(manualNumber),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoryboardScene.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoryboardScene(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      numberMode: serializer.fromJson<String>(json['numberMode']),
      manualNumber: serializer.fromJson<String>(json['manualNumber']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'numberMode': serializer.toJson<String>(numberMode),
      'manualNumber': serializer.toJson<String>(manualNumber),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StoryboardScene copyWith({
    String? id,
    String? projectId,
    int? sortIndex,
    String? numberMode,
    String? manualNumber,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StoryboardScene(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    sortIndex: sortIndex ?? this.sortIndex,
    numberMode: numberMode ?? this.numberMode,
    manualNumber: manualNumber ?? this.manualNumber,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StoryboardScene copyWithCompanion(StoryboardScenesCompanion data) {
    return StoryboardScene(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      numberMode: data.numberMode.present
          ? data.numberMode.value
          : this.numberMode,
      manualNumber: data.manualNumber.present
          ? data.manualNumber.value
          : this.manualNumber,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoryboardScene(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('numberMode: $numberMode, ')
          ..write('manualNumber: $manualNumber, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    sortIndex,
    numberMode,
    manualNumber,
    name,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoryboardScene &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.sortIndex == this.sortIndex &&
          other.numberMode == this.numberMode &&
          other.manualNumber == this.manualNumber &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StoryboardScenesCompanion extends UpdateCompanion<StoryboardScene> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<int> sortIndex;
  final Value<String> numberMode;
  final Value<String> manualNumber;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StoryboardScenesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.numberMode = const Value.absent(),
    this.manualNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoryboardScenesCompanion.insert({
    required String id,
    required String projectId,
    required int sortIndex,
    this.numberMode = const Value.absent(),
    this.manualNumber = const Value.absent(),
    this.name = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       sortIndex = Value(sortIndex),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StoryboardScene> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<int>? sortIndex,
    Expression<String>? numberMode,
    Expression<String>? manualNumber,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (numberMode != null) 'number_mode': numberMode,
      if (manualNumber != null) 'manual_number': manualNumber,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoryboardScenesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<int>? sortIndex,
    Value<String>? numberMode,
    Value<String>? manualNumber,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StoryboardScenesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sortIndex: sortIndex ?? this.sortIndex,
      numberMode: numberMode ?? this.numberMode,
      manualNumber: manualNumber ?? this.manualNumber,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (numberMode.present) {
      map['number_mode'] = Variable<String>(numberMode.value);
    }
    if (manualNumber.present) {
      map['manual_number'] = Variable<String>(manualNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoryboardScenesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('numberMode: $numberMode, ')
          ..write('manualNumber: $manualNumber, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomColumnsTable extends CustomColumns
    with TableInfo<$CustomColumnsTable, CustomColumn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomColumnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enumSourceIdMeta = const VerificationMeta(
    'enumSourceId',
  );
  @override
  late final GeneratedColumn<String> enumSourceId = GeneratedColumn<String>(
    'enum_source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customOptionsJsonMeta = const VerificationMeta(
    'customOptionsJson',
  );
  @override
  late final GeneratedColumn<String> customOptionsJson =
      GeneratedColumn<String>(
        'custom_options_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    type,
    enumSourceId,
    customOptionsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_columns';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomColumn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('enum_source_id')) {
      context.handle(
        _enumSourceIdMeta,
        enumSourceId.isAcceptableOrUnknown(
          data['enum_source_id']!,
          _enumSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_options_json')) {
      context.handle(
        _customOptionsJsonMeta,
        customOptionsJson.isAcceptableOrUnknown(
          data['custom_options_json']!,
          _customOptionsJsonMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomColumn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomColumn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      enumSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enum_source_id'],
      ),
      customOptionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_options_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomColumnsTable createAlias(String alias) {
    return $CustomColumnsTable(attachedDatabase, alias);
  }
}

class CustomColumn extends DataClass implements Insertable<CustomColumn> {
  final String id;
  final String projectId;
  final String name;
  final String type;
  final String? enumSourceId;
  final String customOptionsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomColumn({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    this.enumSourceId,
    required this.customOptionsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || enumSourceId != null) {
      map['enum_source_id'] = Variable<String>(enumSourceId);
    }
    map['custom_options_json'] = Variable<String>(customOptionsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomColumnsCompanion toCompanion(bool nullToAbsent) {
    return CustomColumnsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      type: Value(type),
      enumSourceId: enumSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(enumSourceId),
      customOptionsJson: Value(customOptionsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomColumn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomColumn(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      enumSourceId: serializer.fromJson<String?>(json['enumSourceId']),
      customOptionsJson: serializer.fromJson<String>(json['customOptionsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'enumSourceId': serializer.toJson<String?>(enumSourceId),
      'customOptionsJson': serializer.toJson<String>(customOptionsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomColumn copyWith({
    String? id,
    String? projectId,
    String? name,
    String? type,
    Value<String?> enumSourceId = const Value.absent(),
    String? customOptionsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomColumn(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    type: type ?? this.type,
    enumSourceId: enumSourceId.present ? enumSourceId.value : this.enumSourceId,
    customOptionsJson: customOptionsJson ?? this.customOptionsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomColumn copyWithCompanion(CustomColumnsCompanion data) {
    return CustomColumn(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      enumSourceId: data.enumSourceId.present
          ? data.enumSourceId.value
          : this.enumSourceId,
      customOptionsJson: data.customOptionsJson.present
          ? data.customOptionsJson.value
          : this.customOptionsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomColumn(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('enumSourceId: $enumSourceId, ')
          ..write('customOptionsJson: $customOptionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    name,
    type,
    enumSourceId,
    customOptionsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomColumn &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.type == this.type &&
          other.enumSourceId == this.enumSourceId &&
          other.customOptionsJson == this.customOptionsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomColumnsCompanion extends UpdateCompanion<CustomColumn> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> enumSourceId;
  final Value<String> customOptionsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomColumnsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.enumSourceId = const Value.absent(),
    this.customOptionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomColumnsCompanion.insert({
    required String id,
    required String projectId,
    required String name,
    required String type,
    this.enumSourceId = const Value.absent(),
    this.customOptionsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomColumn> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? enumSourceId,
    Expression<String>? customOptionsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (enumSourceId != null) 'enum_source_id': enumSourceId,
      if (customOptionsJson != null) 'custom_options_json': customOptionsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomColumnsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? enumSourceId,
    Value<String>? customOptionsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomColumnsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      enumSourceId: enumSourceId ?? this.enumSourceId,
      customOptionsJson: customOptionsJson ?? this.customOptionsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (enumSourceId.present) {
      map['enum_source_id'] = Variable<String>(enumSourceId.value);
    }
    if (customOptionsJson.present) {
      map['custom_options_json'] = Variable<String>(customOptionsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomColumnsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('enumSourceId: $enumSourceId, ')
          ..write('customOptionsJson: $customOptionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShotCustomValuesTable extends ShotCustomValues
    with TableInfo<$ShotCustomValuesTable, ShotCustomValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotCustomValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<String> shotId = GeneratedColumn<String>(
    'shot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _columnIdMeta = const VerificationMeta(
    'columnId',
  );
  @override
  late final GeneratedColumn<String> columnId = GeneratedColumn<String>(
    'column_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberValueMeta = const VerificationMeta(
    'numberValue',
  );
  @override
  late final GeneratedColumn<double> numberValue = GeneratedColumn<double>(
    'number_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enumValueMeta = const VerificationMeta(
    'enumValue',
  );
  @override
  late final GeneratedColumn<String> enumValue = GeneratedColumn<String>(
    'enum_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    shotId,
    columnId,
    textValue,
    numberValue,
    enumValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shot_custom_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShotCustomValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shot_id')) {
      context.handle(
        _shotIdMeta,
        shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('column_id')) {
      context.handle(
        _columnIdMeta,
        columnId.isAcceptableOrUnknown(data['column_id']!, _columnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_columnIdMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('number_value')) {
      context.handle(
        _numberValueMeta,
        numberValue.isAcceptableOrUnknown(
          data['number_value']!,
          _numberValueMeta,
        ),
      );
    }
    if (data.containsKey('enum_value')) {
      context.handle(
        _enumValueMeta,
        enumValue.isAcceptableOrUnknown(data['enum_value']!, _enumValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shotId, columnId};
  @override
  ShotCustomValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShotCustomValue(
      shotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shot_id'],
      )!,
      columnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}column_id'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      numberValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number_value'],
      ),
      enumValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enum_value'],
      ),
    );
  }

  @override
  $ShotCustomValuesTable createAlias(String alias) {
    return $ShotCustomValuesTable(attachedDatabase, alias);
  }
}

class ShotCustomValue extends DataClass implements Insertable<ShotCustomValue> {
  final String shotId;
  final String columnId;
  final String? textValue;
  final double? numberValue;
  final String? enumValue;
  const ShotCustomValue({
    required this.shotId,
    required this.columnId,
    this.textValue,
    this.numberValue,
    this.enumValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shot_id'] = Variable<String>(shotId);
    map['column_id'] = Variable<String>(columnId);
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    if (!nullToAbsent || numberValue != null) {
      map['number_value'] = Variable<double>(numberValue);
    }
    if (!nullToAbsent || enumValue != null) {
      map['enum_value'] = Variable<String>(enumValue);
    }
    return map;
  }

  ShotCustomValuesCompanion toCompanion(bool nullToAbsent) {
    return ShotCustomValuesCompanion(
      shotId: Value(shotId),
      columnId: Value(columnId),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      numberValue: numberValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numberValue),
      enumValue: enumValue == null && nullToAbsent
          ? const Value.absent()
          : Value(enumValue),
    );
  }

  factory ShotCustomValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShotCustomValue(
      shotId: serializer.fromJson<String>(json['shotId']),
      columnId: serializer.fromJson<String>(json['columnId']),
      textValue: serializer.fromJson<String?>(json['textValue']),
      numberValue: serializer.fromJson<double?>(json['numberValue']),
      enumValue: serializer.fromJson<String?>(json['enumValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shotId': serializer.toJson<String>(shotId),
      'columnId': serializer.toJson<String>(columnId),
      'textValue': serializer.toJson<String?>(textValue),
      'numberValue': serializer.toJson<double?>(numberValue),
      'enumValue': serializer.toJson<String?>(enumValue),
    };
  }

  ShotCustomValue copyWith({
    String? shotId,
    String? columnId,
    Value<String?> textValue = const Value.absent(),
    Value<double?> numberValue = const Value.absent(),
    Value<String?> enumValue = const Value.absent(),
  }) => ShotCustomValue(
    shotId: shotId ?? this.shotId,
    columnId: columnId ?? this.columnId,
    textValue: textValue.present ? textValue.value : this.textValue,
    numberValue: numberValue.present ? numberValue.value : this.numberValue,
    enumValue: enumValue.present ? enumValue.value : this.enumValue,
  );
  ShotCustomValue copyWithCompanion(ShotCustomValuesCompanion data) {
    return ShotCustomValue(
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      columnId: data.columnId.present ? data.columnId.value : this.columnId,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      numberValue: data.numberValue.present
          ? data.numberValue.value
          : this.numberValue,
      enumValue: data.enumValue.present ? data.enumValue.value : this.enumValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShotCustomValue(')
          ..write('shotId: $shotId, ')
          ..write('columnId: $columnId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('enumValue: $enumValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(shotId, columnId, textValue, numberValue, enumValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShotCustomValue &&
          other.shotId == this.shotId &&
          other.columnId == this.columnId &&
          other.textValue == this.textValue &&
          other.numberValue == this.numberValue &&
          other.enumValue == this.enumValue);
}

class ShotCustomValuesCompanion extends UpdateCompanion<ShotCustomValue> {
  final Value<String> shotId;
  final Value<String> columnId;
  final Value<String?> textValue;
  final Value<double?> numberValue;
  final Value<String?> enumValue;
  final Value<int> rowid;
  const ShotCustomValuesCompanion({
    this.shotId = const Value.absent(),
    this.columnId = const Value.absent(),
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.enumValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShotCustomValuesCompanion.insert({
    required String shotId,
    required String columnId,
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.enumValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : shotId = Value(shotId),
       columnId = Value(columnId);
  static Insertable<ShotCustomValue> custom({
    Expression<String>? shotId,
    Expression<String>? columnId,
    Expression<String>? textValue,
    Expression<double>? numberValue,
    Expression<String>? enumValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shotId != null) 'shot_id': shotId,
      if (columnId != null) 'column_id': columnId,
      if (textValue != null) 'text_value': textValue,
      if (numberValue != null) 'number_value': numberValue,
      if (enumValue != null) 'enum_value': enumValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShotCustomValuesCompanion copyWith({
    Value<String>? shotId,
    Value<String>? columnId,
    Value<String?>? textValue,
    Value<double?>? numberValue,
    Value<String?>? enumValue,
    Value<int>? rowid,
  }) {
    return ShotCustomValuesCompanion(
      shotId: shotId ?? this.shotId,
      columnId: columnId ?? this.columnId,
      textValue: textValue ?? this.textValue,
      numberValue: numberValue ?? this.numberValue,
      enumValue: enumValue ?? this.enumValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shotId.present) {
      map['shot_id'] = Variable<String>(shotId.value);
    }
    if (columnId.present) {
      map['column_id'] = Variable<String>(columnId.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (numberValue.present) {
      map['number_value'] = Variable<double>(numberValue.value);
    }
    if (enumValue.present) {
      map['enum_value'] = Variable<String>(enumValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotCustomValuesCompanion(')
          ..write('shotId: $shotId, ')
          ..write('columnId: $columnId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('enumValue: $enumValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanSectionsTable extends PlanSections
    with TableInfo<$PlanSectionsTable, PlanSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
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
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, name, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanSection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanSection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $PlanSectionsTable createAlias(String alias) {
    return $PlanSectionsTable(attachedDatabase, alias);
  }
}

class PlanSection extends DataClass implements Insertable<PlanSection> {
  final String id;
  final String projectId;
  final String name;
  final int orderIndex;
  const PlanSection({
    required this.id,
    required this.projectId,
    required this.name,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  PlanSectionsCompanion toCompanion(bool nullToAbsent) {
    return PlanSectionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      orderIndex: Value(orderIndex),
    );
  }

  factory PlanSection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanSection(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  PlanSection copyWith({
    String? id,
    String? projectId,
    String? name,
    int? orderIndex,
  }) => PlanSection(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  PlanSection copyWithCompanion(PlanSectionsCompanion data) {
    return PlanSection(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanSection(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, name, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanSection &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex);
}

class PlanSectionsCompanion extends UpdateCompanion<PlanSection> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> name;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const PlanSectionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanSectionsCompanion.insert({
    required String id,
    required String projectId,
    required String name,
    required int orderIndex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       name = Value(name),
       orderIndex = Value(orderIndex);
  static Insertable<PlanSection> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? name,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return PlanSectionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanSectionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanAssignmentsTable extends PlanAssignments
    with TableInfo<$PlanAssignmentsTable, PlanAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<String> shotId = GeneratedColumn<String>(
    'shot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [shotId, sectionId, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shot_id')) {
      context.handle(
        _shotIdMeta,
        shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shotId, sectionId};
  @override
  PlanAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanAssignment(
      shotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shot_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $PlanAssignmentsTable createAlias(String alias) {
    return $PlanAssignmentsTable(attachedDatabase, alias);
  }
}

class PlanAssignment extends DataClass implements Insertable<PlanAssignment> {
  final String shotId;
  final String sectionId;
  final int orderIndex;
  const PlanAssignment({
    required this.shotId,
    required this.sectionId,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shot_id'] = Variable<String>(shotId);
    map['section_id'] = Variable<String>(sectionId);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  PlanAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return PlanAssignmentsCompanion(
      shotId: Value(shotId),
      sectionId: Value(sectionId),
      orderIndex: Value(orderIndex),
    );
  }

  factory PlanAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanAssignment(
      shotId: serializer.fromJson<String>(json['shotId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shotId': serializer.toJson<String>(shotId),
      'sectionId': serializer.toJson<String>(sectionId),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  PlanAssignment copyWith({
    String? shotId,
    String? sectionId,
    int? orderIndex,
  }) => PlanAssignment(
    shotId: shotId ?? this.shotId,
    sectionId: sectionId ?? this.sectionId,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  PlanAssignment copyWithCompanion(PlanAssignmentsCompanion data) {
    return PlanAssignment(
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanAssignment(')
          ..write('shotId: $shotId, ')
          ..write('sectionId: $sectionId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(shotId, sectionId, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanAssignment &&
          other.shotId == this.shotId &&
          other.sectionId == this.sectionId &&
          other.orderIndex == this.orderIndex);
}

class PlanAssignmentsCompanion extends UpdateCompanion<PlanAssignment> {
  final Value<String> shotId;
  final Value<String> sectionId;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const PlanAssignmentsCompanion({
    this.shotId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanAssignmentsCompanion.insert({
    required String shotId,
    required String sectionId,
    required int orderIndex,
    this.rowid = const Value.absent(),
  }) : shotId = Value(shotId),
       sectionId = Value(sectionId),
       orderIndex = Value(orderIndex);
  static Insertable<PlanAssignment> custom({
    Expression<String>? shotId,
    Expression<String>? sectionId,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shotId != null) 'shot_id': shotId,
      if (sectionId != null) 'section_id': sectionId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanAssignmentsCompanion copyWith({
    Value<String>? shotId,
    Value<String>? sectionId,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return PlanAssignmentsCompanion(
      shotId: shotId ?? this.shotId,
      sectionId: sectionId ?? this.sectionId,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shotId.present) {
      map['shot_id'] = Variable<String>(shotId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanAssignmentsCompanion(')
          ..write('shotId: $shotId, ')
          ..write('sectionId: $sectionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColumnPresetsTable extends ColumnPresets
    with TableInfo<$ColumnPresetsTable, ColumnPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColumnPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _visibleFieldsJsonMeta = const VerificationMeta(
    'visibleFieldsJson',
  );
  @override
  late final GeneratedColumn<String> visibleFieldsJson =
      GeneratedColumn<String>(
        'visible_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fieldOrderJsonMeta = const VerificationMeta(
    'fieldOrderJson',
  );
  @override
  late final GeneratedColumn<String> fieldOrderJson = GeneratedColumn<String>(
    'field_order_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    kind,
    visibleFieldsJson,
    fieldOrderJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'column_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColumnPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('visible_fields_json')) {
      context.handle(
        _visibleFieldsJsonMeta,
        visibleFieldsJson.isAcceptableOrUnknown(
          data['visible_fields_json']!,
          _visibleFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visibleFieldsJsonMeta);
    }
    if (data.containsKey('field_order_json')) {
      context.handle(
        _fieldOrderJsonMeta,
        fieldOrderJson.isAcceptableOrUnknown(
          data['field_order_json']!,
          _fieldOrderJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fieldOrderJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ColumnPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColumnPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      visibleFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visible_fields_json'],
      )!,
      fieldOrderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_order_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ColumnPresetsTable createAlias(String alias) {
    return $ColumnPresetsTable(attachedDatabase, alias);
  }
}

class ColumnPreset extends DataClass implements Insertable<ColumnPreset> {
  final String id;
  final String projectId;
  final String name;
  final String kind;
  final String visibleFieldsJson;
  final String fieldOrderJson;
  final DateTime? updatedAt;
  const ColumnPreset({
    required this.id,
    required this.projectId,
    required this.name,
    required this.kind,
    required this.visibleFieldsJson,
    required this.fieldOrderJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['visible_fields_json'] = Variable<String>(visibleFieldsJson);
    map['field_order_json'] = Variable<String>(fieldOrderJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ColumnPresetsCompanion toCompanion(bool nullToAbsent) {
    return ColumnPresetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      kind: Value(kind),
      visibleFieldsJson: Value(visibleFieldsJson),
      fieldOrderJson: Value(fieldOrderJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ColumnPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColumnPreset(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      visibleFieldsJson: serializer.fromJson<String>(json['visibleFieldsJson']),
      fieldOrderJson: serializer.fromJson<String>(json['fieldOrderJson']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'visibleFieldsJson': serializer.toJson<String>(visibleFieldsJson),
      'fieldOrderJson': serializer.toJson<String>(fieldOrderJson),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ColumnPreset copyWith({
    String? id,
    String? projectId,
    String? name,
    String? kind,
    String? visibleFieldsJson,
    String? fieldOrderJson,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ColumnPreset(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    visibleFieldsJson: visibleFieldsJson ?? this.visibleFieldsJson,
    fieldOrderJson: fieldOrderJson ?? this.fieldOrderJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ColumnPreset copyWithCompanion(ColumnPresetsCompanion data) {
    return ColumnPreset(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      visibleFieldsJson: data.visibleFieldsJson.present
          ? data.visibleFieldsJson.value
          : this.visibleFieldsJson,
      fieldOrderJson: data.fieldOrderJson.present
          ? data.fieldOrderJson.value
          : this.fieldOrderJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColumnPreset(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('visibleFieldsJson: $visibleFieldsJson, ')
          ..write('fieldOrderJson: $fieldOrderJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    name,
    kind,
    visibleFieldsJson,
    fieldOrderJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColumnPreset &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.visibleFieldsJson == this.visibleFieldsJson &&
          other.fieldOrderJson == this.fieldOrderJson &&
          other.updatedAt == this.updatedAt);
}

class ColumnPresetsCompanion extends UpdateCompanion<ColumnPreset> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> visibleFieldsJson;
  final Value<String> fieldOrderJson;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ColumnPresetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.visibleFieldsJson = const Value.absent(),
    this.fieldOrderJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColumnPresetsCompanion.insert({
    required String id,
    required String projectId,
    required String name,
    this.kind = const Value.absent(),
    required String visibleFieldsJson,
    required String fieldOrderJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       name = Value(name),
       visibleFieldsJson = Value(visibleFieldsJson),
       fieldOrderJson = Value(fieldOrderJson);
  static Insertable<ColumnPreset> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? visibleFieldsJson,
    Expression<String>? fieldOrderJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (visibleFieldsJson != null) 'visible_fields_json': visibleFieldsJson,
      if (fieldOrderJson != null) 'field_order_json': fieldOrderJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColumnPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? visibleFieldsJson,
    Value<String>? fieldOrderJson,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ColumnPresetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      visibleFieldsJson: visibleFieldsJson ?? this.visibleFieldsJson,
      fieldOrderJson: fieldOrderJson ?? this.fieldOrderJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (visibleFieldsJson.present) {
      map['visible_fields_json'] = Variable<String>(visibleFieldsJson.value);
    }
    if (fieldOrderJson.present) {
      map['field_order_json'] = Variable<String>(fieldOrderJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColumnPresetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('visibleFieldsJson: $visibleFieldsJson, ')
          ..write('fieldOrderJson: $fieldOrderJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoardPresetsTable extends BoardPresets
    with TableInfo<$BoardPresetsTable, BoardPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
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
  static const VerificationMeta _aspectRatioMeta = const VerificationMeta(
    'aspectRatio',
  );
  @override
  late final GeneratedColumn<double> aspectRatio = GeneratedColumn<double>(
    'aspect_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fitModeMeta = const VerificationMeta(
    'fitMode',
  );
  @override
  late final GeneratedColumn<String> fitMode = GeneratedColumn<String>(
    'fit_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textAlignModeMeta = const VerificationMeta(
    'textAlignMode',
  );
  @override
  late final GeneratedColumn<String> textAlignMode = GeneratedColumn<String>(
    'text_align_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textScaleModeMeta = const VerificationMeta(
    'textScaleMode',
  );
  @override
  late final GeneratedColumn<String> textScaleMode = GeneratedColumn<String>(
    'text_scale_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('small'),
  );
  static const VerificationMeta _shotNumberModeMeta = const VerificationMeta(
    'shotNumberMode',
  );
  @override
  late final GeneratedColumn<String> shotNumberMode = GeneratedColumn<String>(
    'shot_number_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _primaryFieldsJsonMeta = const VerificationMeta(
    'primaryFieldsJson',
  );
  @override
  late final GeneratedColumn<String> primaryFieldsJson =
      GeneratedColumn<String>(
        'primary_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _secondaryFieldsJsonMeta =
      const VerificationMeta('secondaryFieldsJson');
  @override
  late final GeneratedColumn<String> secondaryFieldsJson =
      GeneratedColumn<String>(
        'secondary_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    aspectRatio,
    fitMode,
    textAlignMode,
    textScaleMode,
    shotNumberMode,
    primaryFieldsJson,
    secondaryFieldsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('aspect_ratio')) {
      context.handle(
        _aspectRatioMeta,
        aspectRatio.isAcceptableOrUnknown(
          data['aspect_ratio']!,
          _aspectRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aspectRatioMeta);
    }
    if (data.containsKey('fit_mode')) {
      context.handle(
        _fitModeMeta,
        fitMode.isAcceptableOrUnknown(data['fit_mode']!, _fitModeMeta),
      );
    } else if (isInserting) {
      context.missing(_fitModeMeta);
    }
    if (data.containsKey('text_align_mode')) {
      context.handle(
        _textAlignModeMeta,
        textAlignMode.isAcceptableOrUnknown(
          data['text_align_mode']!,
          _textAlignModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textAlignModeMeta);
    }
    if (data.containsKey('text_scale_mode')) {
      context.handle(
        _textScaleModeMeta,
        textScaleMode.isAcceptableOrUnknown(
          data['text_scale_mode']!,
          _textScaleModeMeta,
        ),
      );
    }
    if (data.containsKey('shot_number_mode')) {
      context.handle(
        _shotNumberModeMeta,
        shotNumberMode.isAcceptableOrUnknown(
          data['shot_number_mode']!,
          _shotNumberModeMeta,
        ),
      );
    }
    if (data.containsKey('primary_fields_json')) {
      context.handle(
        _primaryFieldsJsonMeta,
        primaryFieldsJson.isAcceptableOrUnknown(
          data['primary_fields_json']!,
          _primaryFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryFieldsJsonMeta);
    }
    if (data.containsKey('secondary_fields_json')) {
      context.handle(
        _secondaryFieldsJsonMeta,
        secondaryFieldsJson.isAcceptableOrUnknown(
          data['secondary_fields_json']!,
          _secondaryFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondaryFieldsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoardPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      aspectRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aspect_ratio'],
      )!,
      fitMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fit_mode'],
      )!,
      textAlignMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_align_mode'],
      )!,
      textScaleMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_scale_mode'],
      )!,
      shotNumberMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shot_number_mode'],
      )!,
      primaryFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_fields_json'],
      )!,
      secondaryFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_fields_json'],
      )!,
    );
  }

  @override
  $BoardPresetsTable createAlias(String alias) {
    return $BoardPresetsTable(attachedDatabase, alias);
  }
}

class BoardPreset extends DataClass implements Insertable<BoardPreset> {
  final String id;
  final String projectId;
  final String name;
  final double aspectRatio;
  final String fitMode;
  final String textAlignMode;
  final String textScaleMode;
  final String shotNumberMode;
  final String primaryFieldsJson;
  final String secondaryFieldsJson;
  const BoardPreset({
    required this.id,
    required this.projectId,
    required this.name,
    required this.aspectRatio,
    required this.fitMode,
    required this.textAlignMode,
    required this.textScaleMode,
    required this.shotNumberMode,
    required this.primaryFieldsJson,
    required this.secondaryFieldsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['aspect_ratio'] = Variable<double>(aspectRatio);
    map['fit_mode'] = Variable<String>(fitMode);
    map['text_align_mode'] = Variable<String>(textAlignMode);
    map['text_scale_mode'] = Variable<String>(textScaleMode);
    map['shot_number_mode'] = Variable<String>(shotNumberMode);
    map['primary_fields_json'] = Variable<String>(primaryFieldsJson);
    map['secondary_fields_json'] = Variable<String>(secondaryFieldsJson);
    return map;
  }

  BoardPresetsCompanion toCompanion(bool nullToAbsent) {
    return BoardPresetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      aspectRatio: Value(aspectRatio),
      fitMode: Value(fitMode),
      textAlignMode: Value(textAlignMode),
      textScaleMode: Value(textScaleMode),
      shotNumberMode: Value(shotNumberMode),
      primaryFieldsJson: Value(primaryFieldsJson),
      secondaryFieldsJson: Value(secondaryFieldsJson),
    );
  }

  factory BoardPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardPreset(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      aspectRatio: serializer.fromJson<double>(json['aspectRatio']),
      fitMode: serializer.fromJson<String>(json['fitMode']),
      textAlignMode: serializer.fromJson<String>(json['textAlignMode']),
      textScaleMode: serializer.fromJson<String>(json['textScaleMode']),
      shotNumberMode: serializer.fromJson<String>(json['shotNumberMode']),
      primaryFieldsJson: serializer.fromJson<String>(json['primaryFieldsJson']),
      secondaryFieldsJson: serializer.fromJson<String>(
        json['secondaryFieldsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'aspectRatio': serializer.toJson<double>(aspectRatio),
      'fitMode': serializer.toJson<String>(fitMode),
      'textAlignMode': serializer.toJson<String>(textAlignMode),
      'textScaleMode': serializer.toJson<String>(textScaleMode),
      'shotNumberMode': serializer.toJson<String>(shotNumberMode),
      'primaryFieldsJson': serializer.toJson<String>(primaryFieldsJson),
      'secondaryFieldsJson': serializer.toJson<String>(secondaryFieldsJson),
    };
  }

  BoardPreset copyWith({
    String? id,
    String? projectId,
    String? name,
    double? aspectRatio,
    String? fitMode,
    String? textAlignMode,
    String? textScaleMode,
    String? shotNumberMode,
    String? primaryFieldsJson,
    String? secondaryFieldsJson,
  }) => BoardPreset(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    fitMode: fitMode ?? this.fitMode,
    textAlignMode: textAlignMode ?? this.textAlignMode,
    textScaleMode: textScaleMode ?? this.textScaleMode,
    shotNumberMode: shotNumberMode ?? this.shotNumberMode,
    primaryFieldsJson: primaryFieldsJson ?? this.primaryFieldsJson,
    secondaryFieldsJson: secondaryFieldsJson ?? this.secondaryFieldsJson,
  );
  BoardPreset copyWithCompanion(BoardPresetsCompanion data) {
    return BoardPreset(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      aspectRatio: data.aspectRatio.present
          ? data.aspectRatio.value
          : this.aspectRatio,
      fitMode: data.fitMode.present ? data.fitMode.value : this.fitMode,
      textAlignMode: data.textAlignMode.present
          ? data.textAlignMode.value
          : this.textAlignMode,
      textScaleMode: data.textScaleMode.present
          ? data.textScaleMode.value
          : this.textScaleMode,
      shotNumberMode: data.shotNumberMode.present
          ? data.shotNumberMode.value
          : this.shotNumberMode,
      primaryFieldsJson: data.primaryFieldsJson.present
          ? data.primaryFieldsJson.value
          : this.primaryFieldsJson,
      secondaryFieldsJson: data.secondaryFieldsJson.present
          ? data.secondaryFieldsJson.value
          : this.secondaryFieldsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardPreset(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('aspectRatio: $aspectRatio, ')
          ..write('fitMode: $fitMode, ')
          ..write('textAlignMode: $textAlignMode, ')
          ..write('textScaleMode: $textScaleMode, ')
          ..write('shotNumberMode: $shotNumberMode, ')
          ..write('primaryFieldsJson: $primaryFieldsJson, ')
          ..write('secondaryFieldsJson: $secondaryFieldsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    name,
    aspectRatio,
    fitMode,
    textAlignMode,
    textScaleMode,
    shotNumberMode,
    primaryFieldsJson,
    secondaryFieldsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardPreset &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.aspectRatio == this.aspectRatio &&
          other.fitMode == this.fitMode &&
          other.textAlignMode == this.textAlignMode &&
          other.textScaleMode == this.textScaleMode &&
          other.shotNumberMode == this.shotNumberMode &&
          other.primaryFieldsJson == this.primaryFieldsJson &&
          other.secondaryFieldsJson == this.secondaryFieldsJson);
}

class BoardPresetsCompanion extends UpdateCompanion<BoardPreset> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> name;
  final Value<double> aspectRatio;
  final Value<String> fitMode;
  final Value<String> textAlignMode;
  final Value<String> textScaleMode;
  final Value<String> shotNumberMode;
  final Value<String> primaryFieldsJson;
  final Value<String> secondaryFieldsJson;
  final Value<int> rowid;
  const BoardPresetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.aspectRatio = const Value.absent(),
    this.fitMode = const Value.absent(),
    this.textAlignMode = const Value.absent(),
    this.textScaleMode = const Value.absent(),
    this.shotNumberMode = const Value.absent(),
    this.primaryFieldsJson = const Value.absent(),
    this.secondaryFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoardPresetsCompanion.insert({
    required String id,
    required String projectId,
    required String name,
    required double aspectRatio,
    required String fitMode,
    required String textAlignMode,
    this.textScaleMode = const Value.absent(),
    this.shotNumberMode = const Value.absent(),
    required String primaryFieldsJson,
    required String secondaryFieldsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       name = Value(name),
       aspectRatio = Value(aspectRatio),
       fitMode = Value(fitMode),
       textAlignMode = Value(textAlignMode),
       primaryFieldsJson = Value(primaryFieldsJson),
       secondaryFieldsJson = Value(secondaryFieldsJson);
  static Insertable<BoardPreset> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<double>? aspectRatio,
    Expression<String>? fitMode,
    Expression<String>? textAlignMode,
    Expression<String>? textScaleMode,
    Expression<String>? shotNumberMode,
    Expression<String>? primaryFieldsJson,
    Expression<String>? secondaryFieldsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (aspectRatio != null) 'aspect_ratio': aspectRatio,
      if (fitMode != null) 'fit_mode': fitMode,
      if (textAlignMode != null) 'text_align_mode': textAlignMode,
      if (textScaleMode != null) 'text_scale_mode': textScaleMode,
      if (shotNumberMode != null) 'shot_number_mode': shotNumberMode,
      if (primaryFieldsJson != null) 'primary_fields_json': primaryFieldsJson,
      if (secondaryFieldsJson != null)
        'secondary_fields_json': secondaryFieldsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoardPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? name,
    Value<double>? aspectRatio,
    Value<String>? fitMode,
    Value<String>? textAlignMode,
    Value<String>? textScaleMode,
    Value<String>? shotNumberMode,
    Value<String>? primaryFieldsJson,
    Value<String>? secondaryFieldsJson,
    Value<int>? rowid,
  }) {
    return BoardPresetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      fitMode: fitMode ?? this.fitMode,
      textAlignMode: textAlignMode ?? this.textAlignMode,
      textScaleMode: textScaleMode ?? this.textScaleMode,
      shotNumberMode: shotNumberMode ?? this.shotNumberMode,
      primaryFieldsJson: primaryFieldsJson ?? this.primaryFieldsJson,
      secondaryFieldsJson: secondaryFieldsJson ?? this.secondaryFieldsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aspectRatio.present) {
      map['aspect_ratio'] = Variable<double>(aspectRatio.value);
    }
    if (fitMode.present) {
      map['fit_mode'] = Variable<String>(fitMode.value);
    }
    if (textAlignMode.present) {
      map['text_align_mode'] = Variable<String>(textAlignMode.value);
    }
    if (textScaleMode.present) {
      map['text_scale_mode'] = Variable<String>(textScaleMode.value);
    }
    if (shotNumberMode.present) {
      map['shot_number_mode'] = Variable<String>(shotNumberMode.value);
    }
    if (primaryFieldsJson.present) {
      map['primary_fields_json'] = Variable<String>(primaryFieldsJson.value);
    }
    if (secondaryFieldsJson.present) {
      map['secondary_fields_json'] = Variable<String>(
        secondaryFieldsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardPresetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('aspectRatio: $aspectRatio, ')
          ..write('fitMode: $fitMode, ')
          ..write('textAlignMode: $textAlignMode, ')
          ..write('textScaleMode: $textScaleMode, ')
          ..write('shotNumberMode: $shotNumberMode, ')
          ..write('primaryFieldsJson: $primaryFieldsJson, ')
          ..write('secondaryFieldsJson: $secondaryFieldsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallSheetsTable extends CallSheets
    with TableInfo<$CallSheetsTable, CallSheet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallSheetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionSummariesJsonMeta =
      const VerificationMeta('sectionSummariesJson');
  @override
  late final GeneratedColumn<String> sectionSummariesJson =
      GeneratedColumn<String>(
        'section_summaries_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    title,
    sectionSummariesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_sheets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallSheet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('section_summaries_json')) {
      context.handle(
        _sectionSummariesJsonMeta,
        sectionSummariesJson.isAcceptableOrUnknown(
          data['section_summaries_json']!,
          _sectionSummariesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionSummariesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallSheet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallSheet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sectionSummariesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_summaries_json'],
      )!,
    );
  }

  @override
  $CallSheetsTable createAlias(String alias) {
    return $CallSheetsTable(attachedDatabase, alias);
  }
}

class CallSheet extends DataClass implements Insertable<CallSheet> {
  final String id;
  final String projectId;
  final String title;
  final String sectionSummariesJson;
  const CallSheet({
    required this.id,
    required this.projectId,
    required this.title,
    required this.sectionSummariesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    map['section_summaries_json'] = Variable<String>(sectionSummariesJson);
    return map;
  }

  CallSheetsCompanion toCompanion(bool nullToAbsent) {
    return CallSheetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      sectionSummariesJson: Value(sectionSummariesJson),
    );
  }

  factory CallSheet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallSheet(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      sectionSummariesJson: serializer.fromJson<String>(
        json['sectionSummariesJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'sectionSummariesJson': serializer.toJson<String>(sectionSummariesJson),
    };
  }

  CallSheet copyWith({
    String? id,
    String? projectId,
    String? title,
    String? sectionSummariesJson,
  }) => CallSheet(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    sectionSummariesJson: sectionSummariesJson ?? this.sectionSummariesJson,
  );
  CallSheet copyWithCompanion(CallSheetsCompanion data) {
    return CallSheet(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      sectionSummariesJson: data.sectionSummariesJson.present
          ? data.sectionSummariesJson.value
          : this.sectionSummariesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallSheet(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('sectionSummariesJson: $sectionSummariesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, title, sectionSummariesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallSheet &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.sectionSummariesJson == this.sectionSummariesJson);
}

class CallSheetsCompanion extends UpdateCompanion<CallSheet> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> title;
  final Value<String> sectionSummariesJson;
  final Value<int> rowid;
  const CallSheetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.sectionSummariesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallSheetsCompanion.insert({
    required String id,
    required String projectId,
    required String title,
    required String sectionSummariesJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       title = Value(title),
       sectionSummariesJson = Value(sectionSummariesJson);
  static Insertable<CallSheet> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<String>? sectionSummariesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (sectionSummariesJson != null)
        'section_summaries_json': sectionSummariesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallSheetsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? title,
    Value<String>? sectionSummariesJson,
    Value<int>? rowid,
  }) {
    return CallSheetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      sectionSummariesJson: sectionSummariesJson ?? this.sectionSummariesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sectionSummariesJson.present) {
      map['section_summaries_json'] = Variable<String>(
        sectionSummariesJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallSheetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('sectionSummariesJson: $sectionSummariesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventLogTable extends EventLog
    with TableInfo<$EventLogTable, EventLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    eventType,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EventLogTable createAlias(String alias) {
    return $EventLogTable(attachedDatabase, alias);
  }
}

class EventLogData extends DataClass implements Insertable<EventLogData> {
  final int id;
  final String projectId;
  final String eventType;
  final String payloadJson;
  final DateTime createdAt;
  const EventLogData({
    required this.id,
    required this.projectId,
    required this.eventType,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<String>(projectId);
    map['event_type'] = Variable<String>(eventType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EventLogCompanion toCompanion(bool nullToAbsent) {
    return EventLogCompanion(
      id: Value(id),
      projectId: Value(projectId),
      eventType: Value(eventType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory EventLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventLogData(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<String>(projectId),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EventLogData copyWith({
    int? id,
    String? projectId,
    String? eventType,
    String? payloadJson,
    DateTime? createdAt,
  }) => EventLogData(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    eventType: eventType ?? this.eventType,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  EventLogData copyWithCompanion(EventLogCompanion data) {
    return EventLogData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventLogData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, eventType, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventLogData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class EventLogCompanion extends UpdateCompanion<EventLogData> {
  final Value<int> id;
  final Value<String> projectId;
  final Value<String> eventType;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  const EventLogCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EventLogCompanion.insert({
    this.id = const Value.absent(),
    required String projectId,
    required String eventType,
    required String payloadJson,
    required DateTime createdAt,
  }) : projectId = Value(projectId),
       eventType = Value(eventType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<EventLogData> custom({
    Expression<int>? id,
    Expression<String>? projectId,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EventLogCompanion copyWith({
    Value<int>? id,
    Value<String>? projectId,
    Value<String>? eventType,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
  }) {
    return EventLogCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventLogCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ShotsTable shots = $ShotsTable(this);
  late final $ShotAssetsTable shotAssets = $ShotAssetsTable(this);
  late final $StoryboardScenesTable storyboardScenes = $StoryboardScenesTable(
    this,
  );
  late final $CustomColumnsTable customColumns = $CustomColumnsTable(this);
  late final $ShotCustomValuesTable shotCustomValues = $ShotCustomValuesTable(
    this,
  );
  late final $PlanSectionsTable planSections = $PlanSectionsTable(this);
  late final $PlanAssignmentsTable planAssignments = $PlanAssignmentsTable(
    this,
  );
  late final $ColumnPresetsTable columnPresets = $ColumnPresetsTable(this);
  late final $BoardPresetsTable boardPresets = $BoardPresetsTable(this);
  late final $CallSheetsTable callSheets = $CallSheetsTable(this);
  late final $EventLogTable eventLog = $EventLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    shots,
    shotAssets,
    storyboardScenes,
    customColumns,
    shotCustomValues,
    planSections,
    planAssignments,
    columnPresets,
    boardPresets,
    callSheets,
    eventLog,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$ShotsTableCreateCompanionBuilder =
    ShotsCompanion Function({
      required String id,
      required String projectId,
      required int orderIndex,
      Value<String> sceneId,
      required String shotNo,
      required String shotSize,
      required int durationSec,
      Value<String> content,
      Value<String> dialogue,
      Value<String> notes,
      Value<String> sceneExpectation,
      Value<String> audio,
      Value<String> cameraAngle,
      Value<String> cameraMove,
      Value<String> cameraRig,
      Value<String> focalLength,
      Value<int> rowid,
    });
typedef $$ShotsTableUpdateCompanionBuilder =
    ShotsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<int> orderIndex,
      Value<String> sceneId,
      Value<String> shotNo,
      Value<String> shotSize,
      Value<int> durationSec,
      Value<String> content,
      Value<String> dialogue,
      Value<String> notes,
      Value<String> sceneExpectation,
      Value<String> audio,
      Value<String> cameraAngle,
      Value<String> cameraMove,
      Value<String> cameraRig,
      Value<String> focalLength,
      Value<int> rowid,
    });

class $$ShotsTableFilterComposer extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sceneId => $composableBuilder(
    column: $table.sceneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shotNo => $composableBuilder(
    column: $table.shotNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shotSize => $composableBuilder(
    column: $table.shotSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dialogue => $composableBuilder(
    column: $table.dialogue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sceneExpectation => $composableBuilder(
    column: $table.sceneExpectation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cameraAngle => $composableBuilder(
    column: $table.cameraAngle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cameraMove => $composableBuilder(
    column: $table.cameraMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cameraRig => $composableBuilder(
    column: $table.cameraRig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sceneId => $composableBuilder(
    column: $table.sceneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shotNo => $composableBuilder(
    column: $table.shotNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shotSize => $composableBuilder(
    column: $table.shotSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dialogue => $composableBuilder(
    column: $table.dialogue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sceneExpectation => $composableBuilder(
    column: $table.sceneExpectation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cameraAngle => $composableBuilder(
    column: $table.cameraAngle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cameraMove => $composableBuilder(
    column: $table.cameraMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cameraRig => $composableBuilder(
    column: $table.cameraRig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sceneId =>
      $composableBuilder(column: $table.sceneId, builder: (column) => column);

  GeneratedColumn<String> get shotNo =>
      $composableBuilder(column: $table.shotNo, builder: (column) => column);

  GeneratedColumn<String> get shotSize =>
      $composableBuilder(column: $table.shotSize, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get dialogue =>
      $composableBuilder(column: $table.dialogue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get sceneExpectation => $composableBuilder(
    column: $table.sceneExpectation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audio =>
      $composableBuilder(column: $table.audio, builder: (column) => column);

  GeneratedColumn<String> get cameraAngle => $composableBuilder(
    column: $table.cameraAngle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cameraMove => $composableBuilder(
    column: $table.cameraMove,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cameraRig =>
      $composableBuilder(column: $table.cameraRig, builder: (column) => column);

  GeneratedColumn<String> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => column,
  );
}

class $$ShotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShotsTable,
          Shot,
          $$ShotsTableFilterComposer,
          $$ShotsTableOrderingComposer,
          $$ShotsTableAnnotationComposer,
          $$ShotsTableCreateCompanionBuilder,
          $$ShotsTableUpdateCompanionBuilder,
          (Shot, BaseReferences<_$AppDatabase, $ShotsTable, Shot>),
          Shot,
          PrefetchHooks Function()
        > {
  $$ShotsTableTableManager(_$AppDatabase db, $ShotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> sceneId = const Value.absent(),
                Value<String> shotNo = const Value.absent(),
                Value<String> shotSize = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> dialogue = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> sceneExpectation = const Value.absent(),
                Value<String> audio = const Value.absent(),
                Value<String> cameraAngle = const Value.absent(),
                Value<String> cameraMove = const Value.absent(),
                Value<String> cameraRig = const Value.absent(),
                Value<String> focalLength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotsCompanion(
                id: id,
                projectId: projectId,
                orderIndex: orderIndex,
                sceneId: sceneId,
                shotNo: shotNo,
                shotSize: shotSize,
                durationSec: durationSec,
                content: content,
                dialogue: dialogue,
                notes: notes,
                sceneExpectation: sceneExpectation,
                audio: audio,
                cameraAngle: cameraAngle,
                cameraMove: cameraMove,
                cameraRig: cameraRig,
                focalLength: focalLength,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required int orderIndex,
                Value<String> sceneId = const Value.absent(),
                required String shotNo,
                required String shotSize,
                required int durationSec,
                Value<String> content = const Value.absent(),
                Value<String> dialogue = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> sceneExpectation = const Value.absent(),
                Value<String> audio = const Value.absent(),
                Value<String> cameraAngle = const Value.absent(),
                Value<String> cameraMove = const Value.absent(),
                Value<String> cameraRig = const Value.absent(),
                Value<String> focalLength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotsCompanion.insert(
                id: id,
                projectId: projectId,
                orderIndex: orderIndex,
                sceneId: sceneId,
                shotNo: shotNo,
                shotSize: shotSize,
                durationSec: durationSec,
                content: content,
                dialogue: dialogue,
                notes: notes,
                sceneExpectation: sceneExpectation,
                audio: audio,
                cameraAngle: cameraAngle,
                cameraMove: cameraMove,
                cameraRig: cameraRig,
                focalLength: focalLength,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShotsTable,
      Shot,
      $$ShotsTableFilterComposer,
      $$ShotsTableOrderingComposer,
      $$ShotsTableAnnotationComposer,
      $$ShotsTableCreateCompanionBuilder,
      $$ShotsTableUpdateCompanionBuilder,
      (Shot, BaseReferences<_$AppDatabase, $ShotsTable, Shot>),
      Shot,
      PrefetchHooks Function()
    >;
typedef $$ShotAssetsTableCreateCompanionBuilder =
    ShotAssetsCompanion Function({
      required String id,
      required String shotId,
      required String fieldKey,
      required String mode,
      required String uri,
      required String fingerprint,
      required String missingState,
      Value<int?> width,
      Value<int?> height,
      Value<int?> bytes,
      Value<int> rowid,
    });
typedef $$ShotAssetsTableUpdateCompanionBuilder =
    ShotAssetsCompanion Function({
      Value<String> id,
      Value<String> shotId,
      Value<String> fieldKey,
      Value<String> mode,
      Value<String> uri,
      Value<String> fingerprint,
      Value<String> missingState,
      Value<int?> width,
      Value<int?> height,
      Value<int?> bytes,
      Value<int> rowid,
    });

class $$ShotAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $ShotAssetsTable> {
  $$ShotAssetsTableFilterComposer({
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

  ColumnFilters<String> get shotId => $composableBuilder(
    column: $table.shotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldKey => $composableBuilder(
    column: $table.fieldKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missingState => $composableBuilder(
    column: $table.missingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShotAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShotAssetsTable> {
  $$ShotAssetsTableOrderingComposer({
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

  ColumnOrderings<String> get shotId => $composableBuilder(
    column: $table.shotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldKey => $composableBuilder(
    column: $table.fieldKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missingState => $composableBuilder(
    column: $table.missingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShotAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShotAssetsTable> {
  $$ShotAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shotId =>
      $composableBuilder(column: $table.shotId, builder: (column) => column);

  GeneratedColumn<String> get fieldKey =>
      $composableBuilder(column: $table.fieldKey, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get missingState => $composableBuilder(
    column: $table.missingState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$ShotAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShotAssetsTable,
          ShotAsset,
          $$ShotAssetsTableFilterComposer,
          $$ShotAssetsTableOrderingComposer,
          $$ShotAssetsTableAnnotationComposer,
          $$ShotAssetsTableCreateCompanionBuilder,
          $$ShotAssetsTableUpdateCompanionBuilder,
          (
            ShotAsset,
            BaseReferences<_$AppDatabase, $ShotAssetsTable, ShotAsset>,
          ),
          ShotAsset,
          PrefetchHooks Function()
        > {
  $$ShotAssetsTableTableManager(_$AppDatabase db, $ShotAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShotAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShotAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShotAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shotId = const Value.absent(),
                Value<String> fieldKey = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String> missingState = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotAssetsCompanion(
                id: id,
                shotId: shotId,
                fieldKey: fieldKey,
                mode: mode,
                uri: uri,
                fingerprint: fingerprint,
                missingState: missingState,
                width: width,
                height: height,
                bytes: bytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shotId,
                required String fieldKey,
                required String mode,
                required String uri,
                required String fingerprint,
                required String missingState,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotAssetsCompanion.insert(
                id: id,
                shotId: shotId,
                fieldKey: fieldKey,
                mode: mode,
                uri: uri,
                fingerprint: fingerprint,
                missingState: missingState,
                width: width,
                height: height,
                bytes: bytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShotAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShotAssetsTable,
      ShotAsset,
      $$ShotAssetsTableFilterComposer,
      $$ShotAssetsTableOrderingComposer,
      $$ShotAssetsTableAnnotationComposer,
      $$ShotAssetsTableCreateCompanionBuilder,
      $$ShotAssetsTableUpdateCompanionBuilder,
      (ShotAsset, BaseReferences<_$AppDatabase, $ShotAssetsTable, ShotAsset>),
      ShotAsset,
      PrefetchHooks Function()
    >;
typedef $$StoryboardScenesTableCreateCompanionBuilder =
    StoryboardScenesCompanion Function({
      required String id,
      required String projectId,
      required int sortIndex,
      Value<String> numberMode,
      Value<String> manualNumber,
      Value<String> name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StoryboardScenesTableUpdateCompanionBuilder =
    StoryboardScenesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<int> sortIndex,
      Value<String> numberMode,
      Value<String> manualNumber,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$StoryboardScenesTableFilterComposer
    extends Composer<_$AppDatabase, $StoryboardScenesTable> {
  $$StoryboardScenesTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberMode => $composableBuilder(
    column: $table.numberMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualNumber => $composableBuilder(
    column: $table.manualNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoryboardScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoryboardScenesTable> {
  $$StoryboardScenesTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberMode => $composableBuilder(
    column: $table.numberMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualNumber => $composableBuilder(
    column: $table.manualNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoryboardScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoryboardScenesTable> {
  $$StoryboardScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<String> get numberMode => $composableBuilder(
    column: $table.numberMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manualNumber => $composableBuilder(
    column: $table.manualNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StoryboardScenesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoryboardScenesTable,
          StoryboardScene,
          $$StoryboardScenesTableFilterComposer,
          $$StoryboardScenesTableOrderingComposer,
          $$StoryboardScenesTableAnnotationComposer,
          $$StoryboardScenesTableCreateCompanionBuilder,
          $$StoryboardScenesTableUpdateCompanionBuilder,
          (
            StoryboardScene,
            BaseReferences<
              _$AppDatabase,
              $StoryboardScenesTable,
              StoryboardScene
            >,
          ),
          StoryboardScene,
          PrefetchHooks Function()
        > {
  $$StoryboardScenesTableTableManager(
    _$AppDatabase db,
    $StoryboardScenesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoryboardScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoryboardScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoryboardScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<String> numberMode = const Value.absent(),
                Value<String> manualNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoryboardScenesCompanion(
                id: id,
                projectId: projectId,
                sortIndex: sortIndex,
                numberMode: numberMode,
                manualNumber: manualNumber,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required int sortIndex,
                Value<String> numberMode = const Value.absent(),
                Value<String> manualNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StoryboardScenesCompanion.insert(
                id: id,
                projectId: projectId,
                sortIndex: sortIndex,
                numberMode: numberMode,
                manualNumber: manualNumber,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoryboardScenesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoryboardScenesTable,
      StoryboardScene,
      $$StoryboardScenesTableFilterComposer,
      $$StoryboardScenesTableOrderingComposer,
      $$StoryboardScenesTableAnnotationComposer,
      $$StoryboardScenesTableCreateCompanionBuilder,
      $$StoryboardScenesTableUpdateCompanionBuilder,
      (
        StoryboardScene,
        BaseReferences<_$AppDatabase, $StoryboardScenesTable, StoryboardScene>,
      ),
      StoryboardScene,
      PrefetchHooks Function()
    >;
typedef $$CustomColumnsTableCreateCompanionBuilder =
    CustomColumnsCompanion Function({
      required String id,
      required String projectId,
      required String name,
      required String type,
      Value<String?> enumSourceId,
      Value<String> customOptionsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CustomColumnsTableUpdateCompanionBuilder =
    CustomColumnsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> name,
      Value<String> type,
      Value<String?> enumSourceId,
      Value<String> customOptionsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CustomColumnsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomColumnsTable> {
  $$CustomColumnsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enumSourceId => $composableBuilder(
    column: $table.enumSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customOptionsJson => $composableBuilder(
    column: $table.customOptionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomColumnsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomColumnsTable> {
  $$CustomColumnsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enumSourceId => $composableBuilder(
    column: $table.enumSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customOptionsJson => $composableBuilder(
    column: $table.customOptionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomColumnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomColumnsTable> {
  $$CustomColumnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get enumSourceId => $composableBuilder(
    column: $table.enumSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customOptionsJson => $composableBuilder(
    column: $table.customOptionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomColumnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomColumnsTable,
          CustomColumn,
          $$CustomColumnsTableFilterComposer,
          $$CustomColumnsTableOrderingComposer,
          $$CustomColumnsTableAnnotationComposer,
          $$CustomColumnsTableCreateCompanionBuilder,
          $$CustomColumnsTableUpdateCompanionBuilder,
          (
            CustomColumn,
            BaseReferences<_$AppDatabase, $CustomColumnsTable, CustomColumn>,
          ),
          CustomColumn,
          PrefetchHooks Function()
        > {
  $$CustomColumnsTableTableManager(_$AppDatabase db, $CustomColumnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomColumnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomColumnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomColumnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> enumSourceId = const Value.absent(),
                Value<String> customOptionsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomColumnsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                type: type,
                enumSourceId: enumSourceId,
                customOptionsJson: customOptionsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String name,
                required String type,
                Value<String?> enumSourceId = const Value.absent(),
                Value<String> customOptionsJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomColumnsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                type: type,
                enumSourceId: enumSourceId,
                customOptionsJson: customOptionsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomColumnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomColumnsTable,
      CustomColumn,
      $$CustomColumnsTableFilterComposer,
      $$CustomColumnsTableOrderingComposer,
      $$CustomColumnsTableAnnotationComposer,
      $$CustomColumnsTableCreateCompanionBuilder,
      $$CustomColumnsTableUpdateCompanionBuilder,
      (
        CustomColumn,
        BaseReferences<_$AppDatabase, $CustomColumnsTable, CustomColumn>,
      ),
      CustomColumn,
      PrefetchHooks Function()
    >;
typedef $$ShotCustomValuesTableCreateCompanionBuilder =
    ShotCustomValuesCompanion Function({
      required String shotId,
      required String columnId,
      Value<String?> textValue,
      Value<double?> numberValue,
      Value<String?> enumValue,
      Value<int> rowid,
    });
typedef $$ShotCustomValuesTableUpdateCompanionBuilder =
    ShotCustomValuesCompanion Function({
      Value<String> shotId,
      Value<String> columnId,
      Value<String?> textValue,
      Value<double?> numberValue,
      Value<String?> enumValue,
      Value<int> rowid,
    });

class $$ShotCustomValuesTableFilterComposer
    extends Composer<_$AppDatabase, $ShotCustomValuesTable> {
  $$ShotCustomValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get shotId => $composableBuilder(
    column: $table.shotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get columnId => $composableBuilder(
    column: $table.columnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enumValue => $composableBuilder(
    column: $table.enumValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShotCustomValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShotCustomValuesTable> {
  $$ShotCustomValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get shotId => $composableBuilder(
    column: $table.shotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get columnId => $composableBuilder(
    column: $table.columnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enumValue => $composableBuilder(
    column: $table.enumValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShotCustomValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShotCustomValuesTable> {
  $$ShotCustomValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get shotId =>
      $composableBuilder(column: $table.shotId, builder: (column) => column);

  GeneratedColumn<String> get columnId =>
      $composableBuilder(column: $table.columnId, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enumValue =>
      $composableBuilder(column: $table.enumValue, builder: (column) => column);
}

class $$ShotCustomValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShotCustomValuesTable,
          ShotCustomValue,
          $$ShotCustomValuesTableFilterComposer,
          $$ShotCustomValuesTableOrderingComposer,
          $$ShotCustomValuesTableAnnotationComposer,
          $$ShotCustomValuesTableCreateCompanionBuilder,
          $$ShotCustomValuesTableUpdateCompanionBuilder,
          (
            ShotCustomValue,
            BaseReferences<
              _$AppDatabase,
              $ShotCustomValuesTable,
              ShotCustomValue
            >,
          ),
          ShotCustomValue,
          PrefetchHooks Function()
        > {
  $$ShotCustomValuesTableTableManager(
    _$AppDatabase db,
    $ShotCustomValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShotCustomValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShotCustomValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShotCustomValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> shotId = const Value.absent(),
                Value<String> columnId = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<String?> enumValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotCustomValuesCompanion(
                shotId: shotId,
                columnId: columnId,
                textValue: textValue,
                numberValue: numberValue,
                enumValue: enumValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String shotId,
                required String columnId,
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<String?> enumValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotCustomValuesCompanion.insert(
                shotId: shotId,
                columnId: columnId,
                textValue: textValue,
                numberValue: numberValue,
                enumValue: enumValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShotCustomValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShotCustomValuesTable,
      ShotCustomValue,
      $$ShotCustomValuesTableFilterComposer,
      $$ShotCustomValuesTableOrderingComposer,
      $$ShotCustomValuesTableAnnotationComposer,
      $$ShotCustomValuesTableCreateCompanionBuilder,
      $$ShotCustomValuesTableUpdateCompanionBuilder,
      (
        ShotCustomValue,
        BaseReferences<_$AppDatabase, $ShotCustomValuesTable, ShotCustomValue>,
      ),
      ShotCustomValue,
      PrefetchHooks Function()
    >;
typedef $$PlanSectionsTableCreateCompanionBuilder =
    PlanSectionsCompanion Function({
      required String id,
      required String projectId,
      required String name,
      required int orderIndex,
      Value<int> rowid,
    });
typedef $$PlanSectionsTableUpdateCompanionBuilder =
    PlanSectionsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> name,
      Value<int> orderIndex,
      Value<int> rowid,
    });

class $$PlanSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanSectionsTable> {
  $$PlanSectionsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanSectionsTable> {
  $$PlanSectionsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanSectionsTable> {
  $$PlanSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$PlanSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanSectionsTable,
          PlanSection,
          $$PlanSectionsTableFilterComposer,
          $$PlanSectionsTableOrderingComposer,
          $$PlanSectionsTableAnnotationComposer,
          $$PlanSectionsTableCreateCompanionBuilder,
          $$PlanSectionsTableUpdateCompanionBuilder,
          (
            PlanSection,
            BaseReferences<_$AppDatabase, $PlanSectionsTable, PlanSection>,
          ),
          PlanSection,
          PrefetchHooks Function()
        > {
  $$PlanSectionsTableTableManager(_$AppDatabase db, $PlanSectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanSectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanSectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanSectionsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String name,
                required int orderIndex,
                Value<int> rowid = const Value.absent(),
              }) => PlanSectionsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanSectionsTable,
      PlanSection,
      $$PlanSectionsTableFilterComposer,
      $$PlanSectionsTableOrderingComposer,
      $$PlanSectionsTableAnnotationComposer,
      $$PlanSectionsTableCreateCompanionBuilder,
      $$PlanSectionsTableUpdateCompanionBuilder,
      (
        PlanSection,
        BaseReferences<_$AppDatabase, $PlanSectionsTable, PlanSection>,
      ),
      PlanSection,
      PrefetchHooks Function()
    >;
typedef $$PlanAssignmentsTableCreateCompanionBuilder =
    PlanAssignmentsCompanion Function({
      required String shotId,
      required String sectionId,
      required int orderIndex,
      Value<int> rowid,
    });
typedef $$PlanAssignmentsTableUpdateCompanionBuilder =
    PlanAssignmentsCompanion Function({
      Value<String> shotId,
      Value<String> sectionId,
      Value<int> orderIndex,
      Value<int> rowid,
    });

class $$PlanAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanAssignmentsTable> {
  $$PlanAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get shotId => $composableBuilder(
    column: $table.shotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanAssignmentsTable> {
  $$PlanAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get shotId => $composableBuilder(
    column: $table.shotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanAssignmentsTable> {
  $$PlanAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get shotId =>
      $composableBuilder(column: $table.shotId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$PlanAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanAssignmentsTable,
          PlanAssignment,
          $$PlanAssignmentsTableFilterComposer,
          $$PlanAssignmentsTableOrderingComposer,
          $$PlanAssignmentsTableAnnotationComposer,
          $$PlanAssignmentsTableCreateCompanionBuilder,
          $$PlanAssignmentsTableUpdateCompanionBuilder,
          (
            PlanAssignment,
            BaseReferences<
              _$AppDatabase,
              $PlanAssignmentsTable,
              PlanAssignment
            >,
          ),
          PlanAssignment,
          PrefetchHooks Function()
        > {
  $$PlanAssignmentsTableTableManager(
    _$AppDatabase db,
    $PlanAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanAssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> shotId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanAssignmentsCompanion(
                shotId: shotId,
                sectionId: sectionId,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String shotId,
                required String sectionId,
                required int orderIndex,
                Value<int> rowid = const Value.absent(),
              }) => PlanAssignmentsCompanion.insert(
                shotId: shotId,
                sectionId: sectionId,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanAssignmentsTable,
      PlanAssignment,
      $$PlanAssignmentsTableFilterComposer,
      $$PlanAssignmentsTableOrderingComposer,
      $$PlanAssignmentsTableAnnotationComposer,
      $$PlanAssignmentsTableCreateCompanionBuilder,
      $$PlanAssignmentsTableUpdateCompanionBuilder,
      (
        PlanAssignment,
        BaseReferences<_$AppDatabase, $PlanAssignmentsTable, PlanAssignment>,
      ),
      PlanAssignment,
      PrefetchHooks Function()
    >;
typedef $$ColumnPresetsTableCreateCompanionBuilder =
    ColumnPresetsCompanion Function({
      required String id,
      required String projectId,
      required String name,
      Value<String> kind,
      required String visibleFieldsJson,
      required String fieldOrderJson,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ColumnPresetsTableUpdateCompanionBuilder =
    ColumnPresetsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> name,
      Value<String> kind,
      Value<String> visibleFieldsJson,
      Value<String> fieldOrderJson,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$ColumnPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $ColumnPresetsTable> {
  $$ColumnPresetsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibleFieldsJson => $composableBuilder(
    column: $table.visibleFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldOrderJson => $composableBuilder(
    column: $table.fieldOrderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ColumnPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ColumnPresetsTable> {
  $$ColumnPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibleFieldsJson => $composableBuilder(
    column: $table.visibleFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldOrderJson => $composableBuilder(
    column: $table.fieldOrderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColumnPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColumnPresetsTable> {
  $$ColumnPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get visibleFieldsJson => $composableBuilder(
    column: $table.visibleFieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldOrderJson => $composableBuilder(
    column: $table.fieldOrderJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ColumnPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColumnPresetsTable,
          ColumnPreset,
          $$ColumnPresetsTableFilterComposer,
          $$ColumnPresetsTableOrderingComposer,
          $$ColumnPresetsTableAnnotationComposer,
          $$ColumnPresetsTableCreateCompanionBuilder,
          $$ColumnPresetsTableUpdateCompanionBuilder,
          (
            ColumnPreset,
            BaseReferences<_$AppDatabase, $ColumnPresetsTable, ColumnPreset>,
          ),
          ColumnPreset,
          PrefetchHooks Function()
        > {
  $$ColumnPresetsTableTableManager(_$AppDatabase db, $ColumnPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColumnPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColumnPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColumnPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> visibleFieldsJson = const Value.absent(),
                Value<String> fieldOrderJson = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColumnPresetsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                kind: kind,
                visibleFieldsJson: visibleFieldsJson,
                fieldOrderJson: fieldOrderJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String name,
                Value<String> kind = const Value.absent(),
                required String visibleFieldsJson,
                required String fieldOrderJson,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColumnPresetsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                kind: kind,
                visibleFieldsJson: visibleFieldsJson,
                fieldOrderJson: fieldOrderJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ColumnPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColumnPresetsTable,
      ColumnPreset,
      $$ColumnPresetsTableFilterComposer,
      $$ColumnPresetsTableOrderingComposer,
      $$ColumnPresetsTableAnnotationComposer,
      $$ColumnPresetsTableCreateCompanionBuilder,
      $$ColumnPresetsTableUpdateCompanionBuilder,
      (
        ColumnPreset,
        BaseReferences<_$AppDatabase, $ColumnPresetsTable, ColumnPreset>,
      ),
      ColumnPreset,
      PrefetchHooks Function()
    >;
typedef $$BoardPresetsTableCreateCompanionBuilder =
    BoardPresetsCompanion Function({
      required String id,
      required String projectId,
      required String name,
      required double aspectRatio,
      required String fitMode,
      required String textAlignMode,
      Value<String> textScaleMode,
      Value<String> shotNumberMode,
      required String primaryFieldsJson,
      required String secondaryFieldsJson,
      Value<int> rowid,
    });
typedef $$BoardPresetsTableUpdateCompanionBuilder =
    BoardPresetsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> name,
      Value<double> aspectRatio,
      Value<String> fitMode,
      Value<String> textAlignMode,
      Value<String> textScaleMode,
      Value<String> shotNumberMode,
      Value<String> primaryFieldsJson,
      Value<String> secondaryFieldsJson,
      Value<int> rowid,
    });

class $$BoardPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardPresetsTable> {
  $$BoardPresetsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fitMode => $composableBuilder(
    column: $table.fitMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textAlignMode => $composableBuilder(
    column: $table.textAlignMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textScaleMode => $composableBuilder(
    column: $table.textScaleMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shotNumberMode => $composableBuilder(
    column: $table.shotNumberMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryFieldsJson => $composableBuilder(
    column: $table.primaryFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryFieldsJson => $composableBuilder(
    column: $table.secondaryFieldsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardPresetsTable> {
  $$BoardPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fitMode => $composableBuilder(
    column: $table.fitMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textAlignMode => $composableBuilder(
    column: $table.textAlignMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textScaleMode => $composableBuilder(
    column: $table.textScaleMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shotNumberMode => $composableBuilder(
    column: $table.shotNumberMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryFieldsJson => $composableBuilder(
    column: $table.primaryFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryFieldsJson => $composableBuilder(
    column: $table.secondaryFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardPresetsTable> {
  $$BoardPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fitMode =>
      $composableBuilder(column: $table.fitMode, builder: (column) => column);

  GeneratedColumn<String> get textAlignMode => $composableBuilder(
    column: $table.textAlignMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textScaleMode => $composableBuilder(
    column: $table.textScaleMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shotNumberMode => $composableBuilder(
    column: $table.shotNumberMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryFieldsJson => $composableBuilder(
    column: $table.primaryFieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryFieldsJson => $composableBuilder(
    column: $table.secondaryFieldsJson,
    builder: (column) => column,
  );
}

class $$BoardPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardPresetsTable,
          BoardPreset,
          $$BoardPresetsTableFilterComposer,
          $$BoardPresetsTableOrderingComposer,
          $$BoardPresetsTableAnnotationComposer,
          $$BoardPresetsTableCreateCompanionBuilder,
          $$BoardPresetsTableUpdateCompanionBuilder,
          (
            BoardPreset,
            BaseReferences<_$AppDatabase, $BoardPresetsTable, BoardPreset>,
          ),
          BoardPreset,
          PrefetchHooks Function()
        > {
  $$BoardPresetsTableTableManager(_$AppDatabase db, $BoardPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> aspectRatio = const Value.absent(),
                Value<String> fitMode = const Value.absent(),
                Value<String> textAlignMode = const Value.absent(),
                Value<String> textScaleMode = const Value.absent(),
                Value<String> shotNumberMode = const Value.absent(),
                Value<String> primaryFieldsJson = const Value.absent(),
                Value<String> secondaryFieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardPresetsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                aspectRatio: aspectRatio,
                fitMode: fitMode,
                textAlignMode: textAlignMode,
                textScaleMode: textScaleMode,
                shotNumberMode: shotNumberMode,
                primaryFieldsJson: primaryFieldsJson,
                secondaryFieldsJson: secondaryFieldsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String name,
                required double aspectRatio,
                required String fitMode,
                required String textAlignMode,
                Value<String> textScaleMode = const Value.absent(),
                Value<String> shotNumberMode = const Value.absent(),
                required String primaryFieldsJson,
                required String secondaryFieldsJson,
                Value<int> rowid = const Value.absent(),
              }) => BoardPresetsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                aspectRatio: aspectRatio,
                fitMode: fitMode,
                textAlignMode: textAlignMode,
                textScaleMode: textScaleMode,
                shotNumberMode: shotNumberMode,
                primaryFieldsJson: primaryFieldsJson,
                secondaryFieldsJson: secondaryFieldsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardPresetsTable,
      BoardPreset,
      $$BoardPresetsTableFilterComposer,
      $$BoardPresetsTableOrderingComposer,
      $$BoardPresetsTableAnnotationComposer,
      $$BoardPresetsTableCreateCompanionBuilder,
      $$BoardPresetsTableUpdateCompanionBuilder,
      (
        BoardPreset,
        BaseReferences<_$AppDatabase, $BoardPresetsTable, BoardPreset>,
      ),
      BoardPreset,
      PrefetchHooks Function()
    >;
typedef $$CallSheetsTableCreateCompanionBuilder =
    CallSheetsCompanion Function({
      required String id,
      required String projectId,
      required String title,
      required String sectionSummariesJson,
      Value<int> rowid,
    });
typedef $$CallSheetsTableUpdateCompanionBuilder =
    CallSheetsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> title,
      Value<String> sectionSummariesJson,
      Value<int> rowid,
    });

class $$CallSheetsTableFilterComposer
    extends Composer<_$AppDatabase, $CallSheetsTable> {
  $$CallSheetsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionSummariesJson => $composableBuilder(
    column: $table.sectionSummariesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallSheetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallSheetsTable> {
  $$CallSheetsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionSummariesJson => $composableBuilder(
    column: $table.sectionSummariesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallSheetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallSheetsTable> {
  $$CallSheetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sectionSummariesJson => $composableBuilder(
    column: $table.sectionSummariesJson,
    builder: (column) => column,
  );
}

class $$CallSheetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallSheetsTable,
          CallSheet,
          $$CallSheetsTableFilterComposer,
          $$CallSheetsTableOrderingComposer,
          $$CallSheetsTableAnnotationComposer,
          $$CallSheetsTableCreateCompanionBuilder,
          $$CallSheetsTableUpdateCompanionBuilder,
          (
            CallSheet,
            BaseReferences<_$AppDatabase, $CallSheetsTable, CallSheet>,
          ),
          CallSheet,
          PrefetchHooks Function()
        > {
  $$CallSheetsTableTableManager(_$AppDatabase db, $CallSheetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallSheetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallSheetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallSheetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sectionSummariesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallSheetsCompanion(
                id: id,
                projectId: projectId,
                title: title,
                sectionSummariesJson: sectionSummariesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String title,
                required String sectionSummariesJson,
                Value<int> rowid = const Value.absent(),
              }) => CallSheetsCompanion.insert(
                id: id,
                projectId: projectId,
                title: title,
                sectionSummariesJson: sectionSummariesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallSheetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallSheetsTable,
      CallSheet,
      $$CallSheetsTableFilterComposer,
      $$CallSheetsTableOrderingComposer,
      $$CallSheetsTableAnnotationComposer,
      $$CallSheetsTableCreateCompanionBuilder,
      $$CallSheetsTableUpdateCompanionBuilder,
      (CallSheet, BaseReferences<_$AppDatabase, $CallSheetsTable, CallSheet>),
      CallSheet,
      PrefetchHooks Function()
    >;
typedef $$EventLogTableCreateCompanionBuilder =
    EventLogCompanion Function({
      Value<int> id,
      required String projectId,
      required String eventType,
      required String payloadJson,
      required DateTime createdAt,
    });
typedef $$EventLogTableUpdateCompanionBuilder =
    EventLogCompanion Function({
      Value<int> id,
      Value<String> projectId,
      Value<String> eventType,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
    });

class $$EventLogTableFilterComposer
    extends Composer<_$AppDatabase, $EventLogTable> {
  $$EventLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventLogTableOrderingComposer
    extends Composer<_$AppDatabase, $EventLogTable> {
  $$EventLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventLogTable> {
  $$EventLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EventLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventLogTable,
          EventLogData,
          $$EventLogTableFilterComposer,
          $$EventLogTableOrderingComposer,
          $$EventLogTableAnnotationComposer,
          $$EventLogTableCreateCompanionBuilder,
          $$EventLogTableUpdateCompanionBuilder,
          (
            EventLogData,
            BaseReferences<_$AppDatabase, $EventLogTable, EventLogData>,
          ),
          EventLogData,
          PrefetchHooks Function()
        > {
  $$EventLogTableTableManager(_$AppDatabase db, $EventLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EventLogCompanion(
                id: id,
                projectId: projectId,
                eventType: eventType,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String projectId,
                required String eventType,
                required String payloadJson,
                required DateTime createdAt,
              }) => EventLogCompanion.insert(
                id: id,
                projectId: projectId,
                eventType: eventType,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventLogTable,
      EventLogData,
      $$EventLogTableFilterComposer,
      $$EventLogTableOrderingComposer,
      $$EventLogTableAnnotationComposer,
      $$EventLogTableCreateCompanionBuilder,
      $$EventLogTableUpdateCompanionBuilder,
      (
        EventLogData,
        BaseReferences<_$AppDatabase, $EventLogTable, EventLogData>,
      ),
      EventLogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ShotsTableTableManager get shots =>
      $$ShotsTableTableManager(_db, _db.shots);
  $$ShotAssetsTableTableManager get shotAssets =>
      $$ShotAssetsTableTableManager(_db, _db.shotAssets);
  $$StoryboardScenesTableTableManager get storyboardScenes =>
      $$StoryboardScenesTableTableManager(_db, _db.storyboardScenes);
  $$CustomColumnsTableTableManager get customColumns =>
      $$CustomColumnsTableTableManager(_db, _db.customColumns);
  $$ShotCustomValuesTableTableManager get shotCustomValues =>
      $$ShotCustomValuesTableTableManager(_db, _db.shotCustomValues);
  $$PlanSectionsTableTableManager get planSections =>
      $$PlanSectionsTableTableManager(_db, _db.planSections);
  $$PlanAssignmentsTableTableManager get planAssignments =>
      $$PlanAssignmentsTableTableManager(_db, _db.planAssignments);
  $$ColumnPresetsTableTableManager get columnPresets =>
      $$ColumnPresetsTableTableManager(_db, _db.columnPresets);
  $$BoardPresetsTableTableManager get boardPresets =>
      $$BoardPresetsTableTableManager(_db, _db.boardPresets);
  $$CallSheetsTableTableManager get callSheets =>
      $$CallSheetsTableTableManager(_db, _db.callSheets);
  $$EventLogTableTableManager get eventLog =>
      $$EventLogTableTableManager(_db, _db.eventLog);
}
