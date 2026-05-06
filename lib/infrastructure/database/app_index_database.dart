import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_index_database.g.dart';

class RecentProjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bundlePath => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProjectSearchIndex extends Table {
  TextColumn get projectId => text()();
  TextColumn get searchText => text()();

  @override
  Set<Column<Object>> get primaryKey => {projectId};
}

class TrashEntries extends Table {
  TextColumn get id => text()();
  TextColumn get bundlePath => text()();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    RecentProjects,
    ProjectSearchIndex,
    TrashEntries,
  ],
)
class AppIndexDatabase extends _$AppIndexDatabase {
  AppIndexDatabase(File file) : super(NativeDatabase(file));

  @override
  int get schemaVersion => 1;
}
