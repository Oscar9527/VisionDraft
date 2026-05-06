// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_index_database.dart';

// ignore_for_file: type=lint
class $RecentProjectsTable extends RecentProjects
    with TableInfo<$RecentProjectsTable, RecentProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentProjectsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bundlePathMeta = const VerificationMeta(
    'bundlePath',
  );
  @override
  late final GeneratedColumn<String> bundlePath = GeneratedColumn<String>(
    'bundle_path',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bundlePath,
    updatedAt,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentProject> instance, {
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
    if (data.containsKey('bundle_path')) {
      context.handle(
        _bundlePathMeta,
        bundlePath.isAcceptableOrUnknown(data['bundle_path']!, _bundlePathMeta),
      );
    } else if (isInserting) {
      context.missing(_bundlePathMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bundlePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_path'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
    );
  }

  @override
  $RecentProjectsTable createAlias(String alias) {
    return $RecentProjectsTable(attachedDatabase, alias);
  }
}

class RecentProject extends DataClass implements Insertable<RecentProject> {
  final String id;
  final String name;
  final String bundlePath;
  final DateTime updatedAt;
  final DateTime lastOpenedAt;
  const RecentProject({
    required this.id,
    required this.name,
    required this.bundlePath,
    required this.updatedAt,
    required this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['bundle_path'] = Variable<String>(bundlePath);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    return map;
  }

  RecentProjectsCompanion toCompanion(bool nullToAbsent) {
    return RecentProjectsCompanion(
      id: Value(id),
      name: Value(name),
      bundlePath: Value(bundlePath),
      updatedAt: Value(updatedAt),
      lastOpenedAt: Value(lastOpenedAt),
    );
  }

  factory RecentProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentProject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bundlePath: serializer.fromJson<String>(json['bundlePath']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bundlePath': serializer.toJson<String>(bundlePath),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
    };
  }

  RecentProject copyWith({
    String? id,
    String? name,
    String? bundlePath,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
  }) => RecentProject(
    id: id ?? this.id,
    name: name ?? this.name,
    bundlePath: bundlePath ?? this.bundlePath,
    updatedAt: updatedAt ?? this.updatedAt,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
  RecentProject copyWithCompanion(RecentProjectsCompanion data) {
    return RecentProject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bundlePath: data.bundlePath.present
          ? data.bundlePath.value
          : this.bundlePath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentProject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bundlePath: $bundlePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, bundlePath, updatedAt, lastOpenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentProject &&
          other.id == this.id &&
          other.name == this.name &&
          other.bundlePath == this.bundlePath &&
          other.updatedAt == this.updatedAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class RecentProjectsCompanion extends UpdateCompanion<RecentProject> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bundlePath;
  final Value<DateTime> updatedAt;
  final Value<DateTime> lastOpenedAt;
  final Value<int> rowid;
  const RecentProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bundlePath = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentProjectsCompanion.insert({
    required String id,
    required String name,
    required String bundlePath,
    required DateTime updatedAt,
    required DateTime lastOpenedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bundlePath = Value(bundlePath),
       updatedAt = Value(updatedAt),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<RecentProject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bundlePath,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bundlePath != null) 'bundle_path': bundlePath,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bundlePath,
    Value<DateTime>? updatedAt,
    Value<DateTime>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return RecentProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bundlePath: bundlePath ?? this.bundlePath,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
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
    if (bundlePath.present) {
      map['bundle_path'] = Variable<String>(bundlePath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bundlePath: $bundlePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectSearchIndexTable extends ProjectSearchIndex
    with TableInfo<$ProjectSearchIndexTable, ProjectSearchIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectSearchIndexTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [projectId, searchText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_search_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectSearchIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId};
  @override
  ProjectSearchIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectSearchIndexData(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $ProjectSearchIndexTable createAlias(String alias) {
    return $ProjectSearchIndexTable(attachedDatabase, alias);
  }
}

class ProjectSearchIndexData extends DataClass
    implements Insertable<ProjectSearchIndexData> {
  final String projectId;
  final String searchText;
  const ProjectSearchIndexData({
    required this.projectId,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  ProjectSearchIndexCompanion toCompanion(bool nullToAbsent) {
    return ProjectSearchIndexCompanion(
      projectId: Value(projectId),
      searchText: Value(searchText),
    );
  }

  factory ProjectSearchIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectSearchIndexData(
      projectId: serializer.fromJson<String>(json['projectId']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  ProjectSearchIndexData copyWith({String? projectId, String? searchText}) =>
      ProjectSearchIndexData(
        projectId: projectId ?? this.projectId,
        searchText: searchText ?? this.searchText,
      );
  ProjectSearchIndexData copyWithCompanion(ProjectSearchIndexCompanion data) {
    return ProjectSearchIndexData(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectSearchIndexData(')
          ..write('projectId: $projectId, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectId, searchText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectSearchIndexData &&
          other.projectId == this.projectId &&
          other.searchText == this.searchText);
}

class ProjectSearchIndexCompanion
    extends UpdateCompanion<ProjectSearchIndexData> {
  final Value<String> projectId;
  final Value<String> searchText;
  final Value<int> rowid;
  const ProjectSearchIndexCompanion({
    this.projectId = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectSearchIndexCompanion.insert({
    required String projectId,
    required String searchText,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       searchText = Value(searchText);
  static Insertable<ProjectSearchIndexData> custom({
    Expression<String>? projectId,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectSearchIndexCompanion copyWith({
    Value<String>? projectId,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return ProjectSearchIndexCompanion(
      projectId: projectId ?? this.projectId,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectSearchIndexCompanion(')
          ..write('projectId: $projectId, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrashEntriesTable extends TrashEntries
    with TableInfo<$TrashEntriesTable, TrashEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrashEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bundlePathMeta = const VerificationMeta(
    'bundlePath',
  );
  @override
  late final GeneratedColumn<String> bundlePath = GeneratedColumn<String>(
    'bundle_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bundlePath, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trash_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrashEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bundle_path')) {
      context.handle(
        _bundlePathMeta,
        bundlePath.isAcceptableOrUnknown(data['bundle_path']!, _bundlePathMeta),
      );
    } else if (isInserting) {
      context.missing(_bundlePathMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrashEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrashEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bundlePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_path'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $TrashEntriesTable createAlias(String alias) {
    return $TrashEntriesTable(attachedDatabase, alias);
  }
}

class TrashEntry extends DataClass implements Insertable<TrashEntry> {
  final String id;
  final String bundlePath;
  final DateTime deletedAt;
  const TrashEntry({
    required this.id,
    required this.bundlePath,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bundle_path'] = Variable<String>(bundlePath);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  TrashEntriesCompanion toCompanion(bool nullToAbsent) {
    return TrashEntriesCompanion(
      id: Value(id),
      bundlePath: Value(bundlePath),
      deletedAt: Value(deletedAt),
    );
  }

  factory TrashEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrashEntry(
      id: serializer.fromJson<String>(json['id']),
      bundlePath: serializer.fromJson<String>(json['bundlePath']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bundlePath': serializer.toJson<String>(bundlePath),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  TrashEntry copyWith({String? id, String? bundlePath, DateTime? deletedAt}) =>
      TrashEntry(
        id: id ?? this.id,
        bundlePath: bundlePath ?? this.bundlePath,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  TrashEntry copyWithCompanion(TrashEntriesCompanion data) {
    return TrashEntry(
      id: data.id.present ? data.id.value : this.id,
      bundlePath: data.bundlePath.present
          ? data.bundlePath.value
          : this.bundlePath,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrashEntry(')
          ..write('id: $id, ')
          ..write('bundlePath: $bundlePath, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bundlePath, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrashEntry &&
          other.id == this.id &&
          other.bundlePath == this.bundlePath &&
          other.deletedAt == this.deletedAt);
}

class TrashEntriesCompanion extends UpdateCompanion<TrashEntry> {
  final Value<String> id;
  final Value<String> bundlePath;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const TrashEntriesCompanion({
    this.id = const Value.absent(),
    this.bundlePath = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrashEntriesCompanion.insert({
    required String id,
    required String bundlePath,
    required DateTime deletedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bundlePath = Value(bundlePath),
       deletedAt = Value(deletedAt);
  static Insertable<TrashEntry> custom({
    Expression<String>? id,
    Expression<String>? bundlePath,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bundlePath != null) 'bundle_path': bundlePath,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrashEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? bundlePath,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return TrashEntriesCompanion(
      id: id ?? this.id,
      bundlePath: bundlePath ?? this.bundlePath,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bundlePath.present) {
      map['bundle_path'] = Variable<String>(bundlePath.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrashEntriesCompanion(')
          ..write('id: $id, ')
          ..write('bundlePath: $bundlePath, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppIndexDatabase extends GeneratedDatabase {
  _$AppIndexDatabase(QueryExecutor e) : super(e);
  $AppIndexDatabaseManager get managers => $AppIndexDatabaseManager(this);
  late final $RecentProjectsTable recentProjects = $RecentProjectsTable(this);
  late final $ProjectSearchIndexTable projectSearchIndex =
      $ProjectSearchIndexTable(this);
  late final $TrashEntriesTable trashEntries = $TrashEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentProjects,
    projectSearchIndex,
    trashEntries,
  ];
}

typedef $$RecentProjectsTableCreateCompanionBuilder =
    RecentProjectsCompanion Function({
      required String id,
      required String name,
      required String bundlePath,
      required DateTime updatedAt,
      required DateTime lastOpenedAt,
      Value<int> rowid,
    });
typedef $$RecentProjectsTableUpdateCompanionBuilder =
    RecentProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bundlePath,
      Value<DateTime> updatedAt,
      Value<DateTime> lastOpenedAt,
      Value<int> rowid,
    });

class $$RecentProjectsTableFilterComposer
    extends Composer<_$AppIndexDatabase, $RecentProjectsTable> {
  $$RecentProjectsTableFilterComposer({
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

  ColumnFilters<String> get bundlePath => $composableBuilder(
    column: $table.bundlePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentProjectsTableOrderingComposer
    extends Composer<_$AppIndexDatabase, $RecentProjectsTable> {
  $$RecentProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get bundlePath => $composableBuilder(
    column: $table.bundlePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentProjectsTableAnnotationComposer
    extends Composer<_$AppIndexDatabase, $RecentProjectsTable> {
  $$RecentProjectsTableAnnotationComposer({
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

  GeneratedColumn<String> get bundlePath => $composableBuilder(
    column: $table.bundlePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );
}

class $$RecentProjectsTableTableManager
    extends
        RootTableManager<
          _$AppIndexDatabase,
          $RecentProjectsTable,
          RecentProject,
          $$RecentProjectsTableFilterComposer,
          $$RecentProjectsTableOrderingComposer,
          $$RecentProjectsTableAnnotationComposer,
          $$RecentProjectsTableCreateCompanionBuilder,
          $$RecentProjectsTableUpdateCompanionBuilder,
          (
            RecentProject,
            BaseReferences<
              _$AppIndexDatabase,
              $RecentProjectsTable,
              RecentProject
            >,
          ),
          RecentProject,
          PrefetchHooks Function()
        > {
  $$RecentProjectsTableTableManager(
    _$AppIndexDatabase db,
    $RecentProjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bundlePath = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentProjectsCompanion(
                id: id,
                name: name,
                bundlePath: bundlePath,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String bundlePath,
                required DateTime updatedAt,
                required DateTime lastOpenedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentProjectsCompanion.insert(
                id: id,
                name: name,
                bundlePath: bundlePath,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppIndexDatabase,
      $RecentProjectsTable,
      RecentProject,
      $$RecentProjectsTableFilterComposer,
      $$RecentProjectsTableOrderingComposer,
      $$RecentProjectsTableAnnotationComposer,
      $$RecentProjectsTableCreateCompanionBuilder,
      $$RecentProjectsTableUpdateCompanionBuilder,
      (
        RecentProject,
        BaseReferences<_$AppIndexDatabase, $RecentProjectsTable, RecentProject>,
      ),
      RecentProject,
      PrefetchHooks Function()
    >;
typedef $$ProjectSearchIndexTableCreateCompanionBuilder =
    ProjectSearchIndexCompanion Function({
      required String projectId,
      required String searchText,
      Value<int> rowid,
    });
typedef $$ProjectSearchIndexTableUpdateCompanionBuilder =
    ProjectSearchIndexCompanion Function({
      Value<String> projectId,
      Value<String> searchText,
      Value<int> rowid,
    });

class $$ProjectSearchIndexTableFilterComposer
    extends Composer<_$AppIndexDatabase, $ProjectSearchIndexTable> {
  $$ProjectSearchIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectSearchIndexTableOrderingComposer
    extends Composer<_$AppIndexDatabase, $ProjectSearchIndexTable> {
  $$ProjectSearchIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectSearchIndexTableAnnotationComposer
    extends Composer<_$AppIndexDatabase, $ProjectSearchIndexTable> {
  $$ProjectSearchIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );
}

class $$ProjectSearchIndexTableTableManager
    extends
        RootTableManager<
          _$AppIndexDatabase,
          $ProjectSearchIndexTable,
          ProjectSearchIndexData,
          $$ProjectSearchIndexTableFilterComposer,
          $$ProjectSearchIndexTableOrderingComposer,
          $$ProjectSearchIndexTableAnnotationComposer,
          $$ProjectSearchIndexTableCreateCompanionBuilder,
          $$ProjectSearchIndexTableUpdateCompanionBuilder,
          (
            ProjectSearchIndexData,
            BaseReferences<
              _$AppIndexDatabase,
              $ProjectSearchIndexTable,
              ProjectSearchIndexData
            >,
          ),
          ProjectSearchIndexData,
          PrefetchHooks Function()
        > {
  $$ProjectSearchIndexTableTableManager(
    _$AppIndexDatabase db,
    $ProjectSearchIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectSearchIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectSearchIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectSearchIndexTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> projectId = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectSearchIndexCompanion(
                projectId: projectId,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String projectId,
                required String searchText,
                Value<int> rowid = const Value.absent(),
              }) => ProjectSearchIndexCompanion.insert(
                projectId: projectId,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectSearchIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$AppIndexDatabase,
      $ProjectSearchIndexTable,
      ProjectSearchIndexData,
      $$ProjectSearchIndexTableFilterComposer,
      $$ProjectSearchIndexTableOrderingComposer,
      $$ProjectSearchIndexTableAnnotationComposer,
      $$ProjectSearchIndexTableCreateCompanionBuilder,
      $$ProjectSearchIndexTableUpdateCompanionBuilder,
      (
        ProjectSearchIndexData,
        BaseReferences<
          _$AppIndexDatabase,
          $ProjectSearchIndexTable,
          ProjectSearchIndexData
        >,
      ),
      ProjectSearchIndexData,
      PrefetchHooks Function()
    >;
typedef $$TrashEntriesTableCreateCompanionBuilder =
    TrashEntriesCompanion Function({
      required String id,
      required String bundlePath,
      required DateTime deletedAt,
      Value<int> rowid,
    });
typedef $$TrashEntriesTableUpdateCompanionBuilder =
    TrashEntriesCompanion Function({
      Value<String> id,
      Value<String> bundlePath,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

class $$TrashEntriesTableFilterComposer
    extends Composer<_$AppIndexDatabase, $TrashEntriesTable> {
  $$TrashEntriesTableFilterComposer({
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

  ColumnFilters<String> get bundlePath => $composableBuilder(
    column: $table.bundlePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrashEntriesTableOrderingComposer
    extends Composer<_$AppIndexDatabase, $TrashEntriesTable> {
  $$TrashEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get bundlePath => $composableBuilder(
    column: $table.bundlePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrashEntriesTableAnnotationComposer
    extends Composer<_$AppIndexDatabase, $TrashEntriesTable> {
  $$TrashEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bundlePath => $composableBuilder(
    column: $table.bundlePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TrashEntriesTableTableManager
    extends
        RootTableManager<
          _$AppIndexDatabase,
          $TrashEntriesTable,
          TrashEntry,
          $$TrashEntriesTableFilterComposer,
          $$TrashEntriesTableOrderingComposer,
          $$TrashEntriesTableAnnotationComposer,
          $$TrashEntriesTableCreateCompanionBuilder,
          $$TrashEntriesTableUpdateCompanionBuilder,
          (
            TrashEntry,
            BaseReferences<_$AppIndexDatabase, $TrashEntriesTable, TrashEntry>,
          ),
          TrashEntry,
          PrefetchHooks Function()
        > {
  $$TrashEntriesTableTableManager(
    _$AppIndexDatabase db,
    $TrashEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrashEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrashEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrashEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bundlePath = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrashEntriesCompanion(
                id: id,
                bundlePath: bundlePath,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bundlePath,
                required DateTime deletedAt,
                Value<int> rowid = const Value.absent(),
              }) => TrashEntriesCompanion.insert(
                id: id,
                bundlePath: bundlePath,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrashEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppIndexDatabase,
      $TrashEntriesTable,
      TrashEntry,
      $$TrashEntriesTableFilterComposer,
      $$TrashEntriesTableOrderingComposer,
      $$TrashEntriesTableAnnotationComposer,
      $$TrashEntriesTableCreateCompanionBuilder,
      $$TrashEntriesTableUpdateCompanionBuilder,
      (
        TrashEntry,
        BaseReferences<_$AppIndexDatabase, $TrashEntriesTable, TrashEntry>,
      ),
      TrashEntry,
      PrefetchHooks Function()
    >;

class $AppIndexDatabaseManager {
  final _$AppIndexDatabase _db;
  $AppIndexDatabaseManager(this._db);
  $$RecentProjectsTableTableManager get recentProjects =>
      $$RecentProjectsTableTableManager(_db, _db.recentProjects);
  $$ProjectSearchIndexTableTableManager get projectSearchIndex =>
      $$ProjectSearchIndexTableTableManager(_db, _db.projectSearchIndex);
  $$TrashEntriesTableTableManager get trashEntries =>
      $$TrashEntriesTableTableManager(_db, _db.trashEntries);
}
