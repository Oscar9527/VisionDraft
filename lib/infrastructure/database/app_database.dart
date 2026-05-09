import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Shots extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  IntColumn get orderIndex => integer()();
  TextColumn get shotNo => text()();
  TextColumn get shotSize => text()();
  IntColumn get durationSec => integer()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get dialogue => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get sceneExpectation => text().withDefault(const Constant(''))();
  TextColumn get audio => text().withDefault(const Constant(''))();
  TextColumn get cameraAngle => text().withDefault(const Constant(''))();
  TextColumn get cameraMove => text().withDefault(const Constant(''))();
  TextColumn get cameraRig => text().withDefault(const Constant(''))();
  TextColumn get focalLength => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ShotAssets extends Table {
  TextColumn get id => text()();
  TextColumn get shotId => text()();
  TextColumn get fieldKey => text()();
  TextColumn get mode => text()();
  TextColumn get uri => text()();
  TextColumn get fingerprint => text()();
  TextColumn get missingState => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get bytes => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CustomColumns extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get enumSourceId => text().nullable()();
  TextColumn get customOptionsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ShotCustomValues extends Table {
  TextColumn get shotId => text()();
  TextColumn get columnId => text()();
  TextColumn get textValue => text().nullable()();
  RealColumn get numberValue => real().nullable()();
  TextColumn get enumValue => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {shotId, columnId};
}

class PlanSections extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlanAssignments extends Table {
  TextColumn get shotId => text()();
  TextColumn get sectionId => text()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column<Object>> get primaryKey => {shotId, sectionId};
}

class ColumnPresets extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  TextColumn get kind => text().withDefault(const Constant('active'))();
  TextColumn get visibleFieldsJson => text()();
  TextColumn get fieldOrderJson => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BoardPresets extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  RealColumn get aspectRatio => real()();
  TextColumn get fitMode => text()();
  TextColumn get textAlignMode => text()();
  TextColumn get textScaleMode => text().withDefault(const Constant('small'))();
  TextColumn get shotNumberMode => text().withDefault(const Constant('custom'))();
  TextColumn get primaryFieldsJson => text()();
  TextColumn get secondaryFieldsJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CallSheets extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get sectionSummariesJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EventLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get projectId => text()();
  TextColumn get eventType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [
    Projects,
    Shots,
    ShotAssets,
    CustomColumns,
    ShotCustomValues,
    PlanSections,
    PlanAssignments,
    ColumnPresets,
    BoardPresets,
    CallSheets,
    EventLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(File file) : super(NativeDatabase(file));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await _repairLegacyDateTimeValues();
        },
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(customColumns);
            await migrator.createTable(shotCustomValues);
            await migrator.addColumn(columnPresets, columnPresets.kind);
            await migrator.addColumn(columnPresets, columnPresets.updatedAt);
            await migrator.addColumn(boardPresets, boardPresets.textScaleMode);
            await migrator.addColumn(boardPresets, boardPresets.shotNumberMode);

            await customStatement(
              "UPDATE column_presets SET kind = 'active' WHERE kind IS NULL OR kind = ''",
            );
            await customStatement(
              "UPDATE board_presets SET text_scale_mode = 'small' WHERE text_scale_mode IS NULL OR text_scale_mode = ''",
            );
            await customStatement(
              "UPDATE board_presets SET shot_number_mode = 'custom' WHERE shot_number_mode IS NULL OR shot_number_mode = ''",
            );
            await customStatement(
              "UPDATE column_presets SET updated_at = CAST(strftime('%s','now') AS INTEGER) WHERE updated_at IS NULL",
            );
          }
          if (from == 2) {
            await migrator.addColumn(customColumns, customColumns.customOptionsJson);
            await customStatement(
              "UPDATE custom_columns SET custom_options_json = '[]' WHERE custom_options_json IS NULL OR custom_options_json = ''",
            );
          }
        },
      );

  Future<void> _repairLegacyDateTimeValues() async {
    await customStatement("""
      UPDATE column_presets
      SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER)
      WHERE typeof(updated_at) = 'text' AND updated_at IS NOT NULL AND updated_at != ''
    """);
  }
}
