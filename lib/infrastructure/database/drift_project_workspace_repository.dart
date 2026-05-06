import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/project_workspace/domain/commands/workspace_commands.dart';
import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../../features/project_workspace/domain/models/board_preset.dart'
    as board_domain;
import '../../features/project_workspace/domain/models/call_sheet.dart'
    as call_domain;
import '../../features/project_workspace/domain/models/column_preset.dart'
    as column_domain;
import '../../features/project_workspace/domain/models/column_template.dart';
import '../../features/project_workspace/domain/models/custom_column_definition.dart';
import '../../features/project_workspace/domain/models/custom_field_value.dart';
import '../../features/project_workspace/domain/models/plan_board.dart'
    as plan_domain;
import '../../features/project_workspace/domain/models/project_bundle.dart';
import '../../features/project_workspace/domain/models/shot_fields.dart';
import '../../features/project_workspace/domain/models/shot_record.dart';
import '../../features/project_workspace/domain/repositories/project_workspace_repository.dart';
import '../filesystem/project_bundle_service.dart';
import 'app_database.dart' as db;
import 'app_index_database.dart' as index_db;

const _fixedFieldOptionsEventType = 'fixed_field_custom_options';

class DriftProjectWorkspaceRepository implements ProjectWorkspaceRepository {
  DriftProjectWorkspaceRepository({
    required this.bundleService,
    required this.indexDatabaseFactory,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final ProjectBundleService bundleService;
  final Future<index_db.AppIndexDatabase> Function() indexDatabaseFactory;
  final Uuid _uuid;

  Future<void> initializeProject(ProjectBundle bundle) async {
    final database = db.AppDatabase(File(bundle.databasePath));
    try {
      await database.transaction(() async {
        await database.into(database.projects).insert(
              db.ProjectsCompanion.insert(
                id: bundle.id,
                name: bundle.name,
                createdAt: bundle.createdAt,
                updatedAt: bundle.updatedAt,
              ),
            );

        await database.into(database.columnPresets).insert(
              db.ColumnPresetsCompanion.insert(
                id: 'active',
                projectId: bundle.id,
                name: '当前布局',
                kind: const Value('active'),
                visibleFieldsJson: jsonEncode(
                  <String>[
                    'shotNo',
                    'frameImage',
                    'shotSize',
                    'durationSec',
                    'content',
                    'notes',
                  ],
                ),
                fieldOrderJson: jsonEncode(
                  fixedShotFields.map((field) => field.storageKey).toList(),
                ),
                updatedAt: Value(bundle.updatedAt),
              ),
            );

        await database.into(database.boardPresets).insert(
              db.BoardPresetsCompanion.insert(
                id: 'default',
                projectId: bundle.id,
                name: board_domain.BoardPreset.initial().name,
                aspectRatio: board_domain.BoardPreset.initial().aspectRatio,
                fitMode: board_domain.BoardPreset.initial().fitMode.name,
                textAlignMode: board_domain.BoardPreset.initial().textAlignMode.name,
                textScaleMode: Value(
                  board_domain.BoardPreset.initial().textScaleMode.name,
                ),
                shotNumberMode: Value(
                  board_domain.BoardPreset.initial().shotNumberMode.name,
                ),
                primaryFieldsJson: jsonEncode(
                  board_domain.BoardPreset.initial().primaryFields,
                ),
                secondaryFieldsJson: jsonEncode(
                  board_domain.BoardPreset.initial().secondaryFields,
                ),
              ),
            );

        await database.into(database.callSheets).insert(
              db.CallSheetsCompanion.insert(
                id: 'default',
                projectId: bundle.id,
                title: '拍摄通告',
                sectionSummariesJson: jsonEncode(const <String>[]),
              ),
            );

        await database.into(database.planSections).insert(
              db.PlanSectionsCompanion.insert(
                id: 'default-section',
                projectId: bundle.id,
                name: '计划 1',
                orderIndex: 0,
              ),
            );

        for (var index = 0; index < 3; index++) {
          await database.into(database.shots).insert(
                db.ShotsCompanion.insert(
                  id: _uuid.v4(),
                  projectId: bundle.id,
                  orderIndex: index,
                  shotNo: '${index + 1}',
                  shotSize: '中景',
                  durationSec: 0,
                  content: const Value(''),
                  dialogue: const Value(''),
                  notes: const Value(''),
                  sceneExpectation: const Value(''),
                  audio: const Value(''),
                  cameraAngle: const Value('平视'),
                  cameraMove: const Value('固定'),
                  cameraRig: const Value('手持'),
                  focalLength: const Value('35mm'),
                ),
              );
        }
      });
    } finally {
      await database.close();
    }
  }

  Future<ProjectBundle> _resolveBundle(String projectId) async {
    final indexDatabase = await indexDatabaseFactory();
    try {
      final row = await (indexDatabase.select(indexDatabase.recentProjects)
            ..where((tbl) => tbl.id.equals(projectId)))
          .getSingleOrNull();
      if (row == null) {
        throw StateError('Project $projectId not found in index database');
      }
      return bundleService.loadBundle(Directory(row.bundlePath));
    } finally {
      await indexDatabase.close();
    }
  }

  Future<T> _withDb<T>(
    String projectId,
    Future<T> Function(db.AppDatabase database, ProjectBundle bundle) action,
  ) async {
    final bundle = await _resolveBundle(projectId);
    final database = db.AppDatabase(File(bundle.databasePath));
    try {
      return await action(database, bundle);
    } finally {
      await database.close();
    }
  }

  @override
  Future<ProjectBundle> loadBundle(String projectId) => _resolveBundle(projectId);

  @override
  Future<List<ShotRecord>> loadShots(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final shotRows = await (database.select(database.shots)
            ..where((tbl) => tbl.projectId.equals(projectId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      final assetRows = await database.select(database.shotAssets).get();
      final customColumns = await loadCustomColumns(projectId);
      final valueRows = await database.select(database.shotCustomValues).get();
      final assetsByShotId = <String, List<db.ShotAsset>>{};
      for (final asset in assetRows) {
        assetsByShotId.putIfAbsent(asset.shotId, () => []).add(asset);
      }
      final valuesByShotId = <String, Map<String, CustomFieldValue>>{};
      for (final value in valueRows) {
        valuesByShotId.putIfAbsent(value.shotId, () => {})[value.columnId] =
            CustomFieldValue(
              shotId: value.shotId,
              columnId: value.columnId,
              textValue: value.textValue,
              numberValue: value.numberValue,
              enumValue: value.enumValue,
            );
      }
      return shotRows
          .map(
            (shot) => _mapShotRecord(
              shot,
              assetsByShotId[shot.id] ?? const <db.ShotAsset>[],
              valuesByShotId[shot.id] ?? const <String, CustomFieldValue>{},
              customColumns,
              bundle,
            ),
          )
          .toList();
    });
  }

  @override
  Future<column_domain.ColumnPreset> loadColumnPreset(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final preset = await (database.select(database.columnPresets)
            ..where((tbl) => tbl.projectId.equals(projectId) & tbl.kind.equals('active'))
            ..limit(1))
          .getSingle();
      final visibleFieldKeys =
          (jsonDecode(preset.visibleFieldsJson) as List<dynamic>).cast<String>();
      final fieldOrderKeys =
          (jsonDecode(preset.fieldOrderJson) as List<dynamic>).cast<String>();
      return column_domain.ColumnPreset(
        id: preset.id,
        name: preset.name,
        kind: column_domain.ColumnPresetKind.active,
        visibleFieldKeys: visibleFieldKeys,
        fieldOrderKeys: fieldOrderKeys,
        updatedAt: preset.updatedAt ?? bundle.updatedAt,
      );
    });
  }

  @override
  Future<List<ColumnTemplate>> loadColumnTemplates(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final rows = await (database.select(database.columnPresets)
            ..where((tbl) => tbl.projectId.equals(projectId) & tbl.kind.equals('template'))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
          .get();
      return rows
          .map(
            (row) => ColumnTemplate(
              id: row.id,
              projectId: row.projectId,
              name: row.name,
              visibleFieldKeys:
                  (jsonDecode(row.visibleFieldsJson) as List<dynamic>).cast<String>(),
              fieldOrderKeys:
                  (jsonDecode(row.fieldOrderJson) as List<dynamic>).cast<String>(),
              updatedAt: row.updatedAt ?? bundle.updatedAt,
            ),
          )
          .toList();
    });
  }

  @override
  Future<List<CustomColumnDefinition>> loadCustomColumns(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final rows = await (database.select(database.customColumns)
            ..where((tbl) => tbl.projectId.equals(projectId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .get();
      return rows
          .map(
            (row) => CustomColumnDefinition(
              id: row.id,
              projectId: row.projectId,
              name: row.name,
              type: CustomColumnType.values.byName(row.type),
              enumSource: row.enumSourceId == null
                  ? null
                  : BuiltInEnumSource.values.byName(row.enumSourceId!),
              customOptions:
                  (jsonDecode(row.customOptionsJson) as List<dynamic>).cast<String>(),
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Map<String, List<String>>> loadFixedFieldCustomOptions(
    String projectId,
  ) async {
    return _withDb(projectId, (database, bundle) async {
      return _loadFixedFieldCustomOptionsWithDb(database, projectId);
    });
  }

  @override
  Future<Map<String, Map<String, CustomFieldValue>>> loadCustomFieldValuesByShot(
    String projectId,
  ) async {
    return _withDb(projectId, (database, bundle) async {
      final rows = await database.select(database.shotCustomValues).get();
      final result = <String, Map<String, CustomFieldValue>>{};
      for (final row in rows) {
        result.putIfAbsent(row.shotId, () => {})[row.columnId] = CustomFieldValue(
          shotId: row.shotId,
          columnId: row.columnId,
          textValue: row.textValue,
          numberValue: row.numberValue,
          enumValue: row.enumValue,
        );
      }
      return result;
    });
  }

  @override
  Future<board_domain.BoardPreset> loadBoardPreset(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final preset = await (database.select(database.boardPresets)
            ..where((tbl) => tbl.projectId.equals(projectId))
            ..limit(1))
          .getSingle();
      return board_domain.BoardPreset(
        id: preset.id,
        name: preset.name,
        aspectRatio: preset.aspectRatio,
        fitMode: board_domain.ImageFitMode.values.byName(preset.fitMode),
        textAlignMode:
            board_domain.TextAlignMode.values.byName(preset.textAlignMode),
        textScaleMode:
            board_domain.TextScaleMode.values.byName(preset.textScaleMode),
        shotNumberMode:
            board_domain.ShotNumberMode.values.byName(preset.shotNumberMode),
        primaryFields:
            (jsonDecode(preset.primaryFieldsJson) as List<dynamic>).cast<String>(),
        secondaryFields:
            (jsonDecode(preset.secondaryFieldsJson) as List<dynamic>).cast<String>(),
      );
    });
  }

  @override
  Future<plan_domain.PlanBoard> loadPlanBoard(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final sections = await (database.select(database.planSections)
            ..where((tbl) => tbl.projectId.equals(projectId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      final assignments = await database.select(database.planAssignments).get();
      final shots = await (database.select(database.shots)
            ..where((tbl) => tbl.projectId.equals(projectId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      final assignedShotIds = assignments.map((item) => item.shotId).toSet();

      return plan_domain.PlanBoard(
        unassignedShotIds: shots
            .where((shot) => !assignedShotIds.contains(shot.id))
            .map((shot) => shot.id)
            .toList(),
        sections: sections.map((section) {
          final sectionAssignments = assignments
              .where((assignment) => assignment.sectionId == section.id)
              .sorted((a, b) => a.orderIndex.compareTo(b.orderIndex));
          return plan_domain.PlanSection(
            id: section.id,
            name: section.name,
            orderIndex: section.orderIndex,
            shotIds: sectionAssignments.map((item) => item.shotId).toList(),
          );
        }).toList(),
      );
    });
  }

  @override
  Future<call_domain.CallSheet> loadCallSheet(String projectId) async {
    return _withDb(projectId, (database, bundle) async {
      final row = await (database.select(database.callSheets)
            ..where((tbl) => tbl.projectId.equals(projectId))
            ..limit(1))
          .getSingle();
      return call_domain.CallSheet(
        id: row.id,
        title: row.title,
        sectionSummaries:
            (jsonDecode(row.sectionSummariesJson) as List<dynamic>).cast<String>(),
      );
    });
  }

  @override
  Future<ShotRecord> createShot(
    String projectId, {
    ShotRecord? seedShot,
  }) async {
    return _withDb(projectId, (database, bundle) async {
      final shotCount = await _countShots(database, projectId);
      final orderIndex = seedShot?.orderIndex ?? shotCount;
      final shotId = seedShot?.id ?? _uuid.v4();

      if (seedShot != null) {
        await _shiftShotOrders(
          database,
          projectId,
          startIndex: orderIndex,
          delta: 1,
        );
      }

      final row = seedShot ??
          ShotRecord(
            id: shotId,
            orderIndex: orderIndex,
            shotNo: '${shotCount + 1}',
            shotSize: '涓櫙',
            durationSec: 0,
            content: '',
            dialogue: '',
            notes: '',
            sceneExpectation: '',
            audio: '',
            cameraAngle: '骞宠',
            cameraMove: '鍥哄畾',
            cameraRig: '鎵嬫寔',
            focalLength: '35mm',
          );

      await database.into(database.shots).insert(
            db.ShotsCompanion.insert(
              id: row.id,
              projectId: projectId,
              orderIndex: row.orderIndex,
              shotNo: row.shotNo,
              shotSize: row.shotSize,
              durationSec: row.durationSec,
              content: Value(row.content),
              dialogue: Value(row.dialogue),
              notes: Value(row.notes),
              sceneExpectation: Value(row.sceneExpectation),
              audio: Value(row.audio),
              cameraAngle: Value(row.cameraAngle),
              cameraMove: Value(row.cameraMove),
              cameraRig: Value(row.cameraRig),
              focalLength: Value(row.focalLength),
            ),
          );

      if (row.frameImage != null) {
        await _upsertAsset(
          database,
          bundle,
          shotId: row.id,
          fieldKey: ShotFieldKey.frameImage.storageKey,
          asset: row.frameImage!,
        );
      }
      if (row.referenceImage != null) {
        await _upsertAsset(
          database,
          bundle,
          shotId: row.id,
          fieldKey: ShotFieldKey.referenceImage.storageKey,
          asset: row.referenceImage!,
        );
      }

      await _touchProject(database, projectId);
      return _loadShotRecordById(database, bundle, shotId);
    });
  }

  @override
  Future<void> deleteShot(String projectId, String shotId) async {
    await _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        await (database.delete(database.shotAssets)
              ..where((tbl) => tbl.shotId.equals(shotId)))
            .go();
        await (database.delete(database.shotCustomValues)
              ..where((tbl) => tbl.shotId.equals(shotId)))
            .go();
        await (database.delete(database.planAssignments)
              ..where((tbl) => tbl.shotId.equals(shotId)))
            .go();
        await (database.delete(database.shots)..where((tbl) => tbl.id.equals(shotId)))
            .go();
        await _normalizeShotOrders(database, projectId);
      });
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<ShotRecord> updateShotField(
    String projectId,
    String shotId,
    String fieldKey,
    Object? value,
  ) async {
    return _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        switch (fieldKey) {
          case 'shotNo':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(shotNo: Value((value ?? '') as String)),
            );
            break;
          case 'shotSize':
            if (value is String) {
              await _ensureFixedFieldCustomOption(
                database,
                projectId,
                fieldKey,
                value,
              );
            }
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(shotSize: Value((value ?? '') as String)),
            );
            break;
          case 'durationSec':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(durationSec: Value((value ?? 0) as int)),
            );
            break;
          case 'content':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(content: Value((value ?? '') as String)),
            );
            break;
          case 'dialogue':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(dialogue: Value((value ?? '') as String)),
            );
            break;
          case 'notes':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(notes: Value((value ?? '') as String)),
            );
            break;
          case 'sceneExpectation':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(sceneExpectation: Value((value ?? '') as String)),
            );
            break;
          case 'audio':
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(audio: Value((value ?? '') as String)),
            );
            break;
          case 'cameraAngle':
            if (value is String) {
              await _ensureFixedFieldCustomOption(
                database,
                projectId,
                fieldKey,
                value,
              );
            }
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(cameraAngle: Value((value ?? '') as String)),
            );
            break;
          case 'cameraMove':
            if (value is String) {
              await _ensureFixedFieldCustomOption(
                database,
                projectId,
                fieldKey,
                value,
              );
            }
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(cameraMove: Value((value ?? '') as String)),
            );
            break;
          case 'cameraRig':
            if (value is String) {
              await _ensureFixedFieldCustomOption(
                database,
                projectId,
                fieldKey,
                value,
              );
            }
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(cameraRig: Value((value ?? '') as String)),
            );
            break;
          case 'focalLength':
            if (value is String) {
              await _ensureFixedFieldCustomOption(
                database,
                projectId,
                fieldKey,
                value,
              );
            }
            await _updateShotRow(
              database,
              shotId,
              db.ShotsCompanion(focalLength: Value((value ?? '') as String)),
            );
            break;
          case 'frameImage':
          case 'referenceImage':
            if (value == null) {
              await (database.delete(database.shotAssets)
                    ..where(
                      (tbl) =>
                          tbl.shotId.equals(shotId) & tbl.fieldKey.equals(fieldKey),
                    ))
                  .go();
            } else {
              final payload = switch (value) {
                AssetRefPayload data => data.toAssetRef(),
                AssetRef data => data,
                _ => throw ArgumentError.value(
                    value,
                    'value',
                    'Unsupported asset payload for $fieldKey',
                  ),
              };
              await _upsertAsset(
                database,
                bundle,
                shotId: shotId,
                fieldKey: fieldKey,
                asset: payload,
              );
            }
            break;
          default:
            if (fieldKey.startsWith('custom:')) {
              final columnId = fieldKey.substring('custom:'.length);
              await updateCustomFieldValue(
                projectId: projectId,
                shotId: shotId,
                columnId: columnId,
                value: value,
              );
            } else {
              throw ArgumentError.value(fieldKey, 'fieldKey', 'Unsupported field');
            }
        }
      });
      await _touchProject(database, projectId);
      return _loadShotRecordById(database, bundle, shotId);
    });
  }

  @override
  Future<void> updateCustomFieldValue({
    required String projectId,
    required String shotId,
    required String columnId,
    required Object? value,
  }) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.delete(database.shotCustomValues)
            ..where((tbl) => tbl.shotId.equals(shotId) & tbl.columnId.equals(columnId)))
          .go();
      if (value == null) {
        return;
      }
      final customColumns = await loadCustomColumns(projectId);
      final column = customColumns.firstWhere((item) => item.id == columnId);
      if (column.type == CustomColumnType.singleSelect && value is String) {
        final nextValue = value.trim();
        if (nextValue.isNotEmpty && !column.options.contains(nextValue)) {
          final nextCustomOptions = [...column.customOptions, nextValue];
          await (database.update(database.customColumns)
                ..where((tbl) => tbl.id.equals(columnId)))
              .write(
            db.CustomColumnsCompanion(
              customOptionsJson: Value(jsonEncode(nextCustomOptions)),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
      final row = switch (column.type) {
        CustomColumnType.text => db.ShotCustomValuesCompanion.insert(
            shotId: shotId,
            columnId: columnId,
            textValue: Value(value.toString()),
          ),
        CustomColumnType.number => db.ShotCustomValuesCompanion.insert(
            shotId: shotId,
            columnId: columnId,
            numberValue: Value((value as num).toDouble()),
          ),
        CustomColumnType.singleSelect => db.ShotCustomValuesCompanion.insert(
            shotId: shotId,
            columnId: columnId,
            enumValue: Value(value.toString()),
          ),
      };
      await database.into(database.shotCustomValues).insert(row);
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<AssetRef> importManagedAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String sourcePath,
    required String managedTargetPath,
    required String fingerprint,
  }) async {
    return _withDb(projectId, (database, bundle) async {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw StateError('Asset source not found: $sourcePath');
      }
      final targetFile = File(managedTargetPath);
      await targetFile.parent.create(recursive: true);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await sourceFile.copy(targetFile.path);
      final stat = await targetFile.stat();
      final asset = AssetRef(
        mode: AssetMode.managed,
        uri: targetFile.path,
        fingerprint: fingerprint,
        missingState: MissingState.available,
        bytes: stat.size,
      );
      await _upsertAsset(
        database,
        bundle,
        shotId: shotId,
        fieldKey: targetField,
        asset: asset,
      );
      await _touchProject(database, projectId);
      return asset;
    });
  }

  @override
  Future<AssetRef> attachLinkedAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String sourcePath,
    required String fingerprint,
  }) async {
    return _withDb(projectId, (database, bundle) async {
      final file = File(sourcePath);
      final exists = await file.exists();
      final asset = AssetRef(
        mode: AssetMode.linked,
        uri: sourcePath,
        fingerprint: fingerprint,
        missingState:
            exists ? MissingState.available : MissingState.relinkRequired,
        bytes: exists ? (await file.stat()).size : null,
      );
      await _upsertAsset(
        database,
        bundle,
        shotId: shotId,
        fieldKey: targetField,
        asset: asset,
      );
      await _touchProject(database, projectId);
      return asset;
    });
  }

  @override
  Future<void> removeAssetRef(
    String projectId,
    String shotId,
    String targetField,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.delete(database.shotAssets)
            ..where(
              (tbl) => tbl.shotId.equals(shotId) & tbl.fieldKey.equals(targetField),
            ))
          .go();
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<AssetRef> relinkAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String newPath,
    required String fingerprint,
  }) async {
    return _withDb(projectId, (database, bundle) async {
      final file = File(newPath);
      final exists = await file.exists();
      final current = await _loadAsset(database, shotId, targetField);
      final asset = AssetRef(
        mode: current?.mode ?? AssetMode.linked,
        uri: newPath,
        fingerprint: fingerprint,
        missingState:
            exists ? MissingState.available : MissingState.relinkRequired,
        width: current?.width,
        height: current?.height,
        bytes: exists ? (await file.stat()).size : null,
      );
      await _upsertAsset(
        database,
        bundle,
        shotId: shotId,
        fieldKey: targetField,
        asset: asset,
      );
      await _touchProject(database, projectId);
      return asset;
    });
  }

  @override
  Future<void> updateBoardPreset(
    String projectId,
    board_domain.BoardPreset preset,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.update(database.boardPresets)
            ..where((tbl) => tbl.id.equals(preset.id)))
          .write(
        db.BoardPresetsCompanion(
          name: Value(preset.name),
          aspectRatio: Value(preset.aspectRatio),
          fitMode: Value(preset.fitMode.name),
          textAlignMode: Value(preset.textAlignMode.name),
          textScaleMode: Value(preset.textScaleMode.name),
          shotNumberMode: Value(preset.shotNumberMode.name),
          primaryFieldsJson: Value(jsonEncode(preset.primaryFields)),
          secondaryFieldsJson: Value(jsonEncode(preset.secondaryFields)),
        ),
      );
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> updateColumnPreset(
    String projectId,
    column_domain.ColumnPreset preset,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.update(database.columnPresets)
            ..where((tbl) => tbl.id.equals(preset.id)))
          .write(
        db.ColumnPresetsCompanion(
          name: Value(preset.name),
          kind: Value(preset.kind.name),
          visibleFieldsJson: Value(jsonEncode(preset.visibleFieldKeys)),
          fieldOrderJson: Value(jsonEncode(preset.fieldOrderKeys)),
          updatedAt: Value(preset.updatedAt),
        ),
      );
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<CustomColumnDefinition> createCustomColumn({
    required String projectId,
    required String name,
    required CustomColumnType type,
    BuiltInEnumSource? enumSource,
    List<String>? customOptions,
    String? columnId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    return _withDb(projectId, (database, bundle) async {
      final now = updatedAt ?? DateTime.now();
      final created = createdAt ?? now;
      final column = CustomColumnDefinition(
        id: columnId ?? _uuid.v4(),
        projectId: projectId,
        name: name,
        type: type,
        enumSource: enumSource,
        customOptions: customOptions ?? const [],
        createdAt: created,
        updatedAt: now,
      );
      await database.into(database.customColumns).insertOnConflictUpdate(
            db.CustomColumnsCompanion.insert(
              id: column.id,
              projectId: projectId,
              name: name,
              type: type.name,
              enumSourceId: Value(enumSource?.name),
              customOptionsJson: Value(jsonEncode(column.customOptions)),
              createdAt: created,
              updatedAt: now,
            ),
          );
      await _touchProject(database, projectId);
      return column;
    });
  }

  @override
  Future<void> renameCustomColumn({
    required String projectId,
    required String columnId,
    required String name,
  }) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.update(database.customColumns)
            ..where((tbl) => tbl.id.equals(columnId)))
          .write(
        db.CustomColumnsCompanion(
          name: Value(name),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> deleteCustomColumn({
    required String projectId,
    required String columnId,
  }) async {
    await _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        await (database.delete(database.shotCustomValues)
              ..where((tbl) => tbl.columnId.equals(columnId)))
            .go();
        await (database.delete(database.customColumns)
              ..where((tbl) => tbl.id.equals(columnId)))
            .go();
        final templates = await (database.select(database.columnPresets)
              ..where((tbl) => tbl.projectId.equals(projectId)))
            .get();
        for (final row in templates) {
          final visible = (jsonDecode(row.visibleFieldsJson) as List<dynamic>).cast<String>()
              ..remove('custom:$columnId');
          final order = (jsonDecode(row.fieldOrderJson) as List<dynamic>).cast<String>()
              ..remove('custom:$columnId');
          await (database.update(database.columnPresets)
                ..where((tbl) => tbl.id.equals(row.id)))
              .write(
            db.ColumnPresetsCompanion(
              visibleFieldsJson: Value(jsonEncode(visible)),
              fieldOrderJson: Value(jsonEncode(order)),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      });
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> addFixedFieldCustomOption({
    required String projectId,
    required String fieldKey,
    required String option,
  }) async {
    await _withDb(projectId, (database, bundle) async {
      await _ensureFixedFieldCustomOption(
        database,
        projectId,
        fieldKey,
        option,
      );
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> replaceFixedFieldCustomOptions({
    required String projectId,
    required Map<String, List<String>> nextOptionsByFieldKey,
  }) async {
    await _withDb(projectId, (database, bundle) async {
      await _replaceFixedFieldCustomOptionsWithDb(
        database,
        projectId,
        nextOptionsByFieldKey,
      );
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<ColumnTemplate> saveColumnTemplate({
    required String projectId,
    required String name,
    required column_domain.ColumnPreset sourcePreset,
    String? templateId,
  }) async {
    return _withDb(projectId, (database, bundle) async {
      final id = templateId ?? _uuid.v4();
      final template = ColumnTemplate(
        id: id,
        projectId: projectId,
        name: name,
        visibleFieldKeys: sourcePreset.visibleFieldKeys,
        fieldOrderKeys: sourcePreset.fieldOrderKeys,
        updatedAt: DateTime.now(),
      );
      await database.into(database.columnPresets).insertOnConflictUpdate(
            db.ColumnPresetsCompanion.insert(
              id: id,
              projectId: projectId,
              name: name,
              kind: const Value('template'),
              visibleFieldsJson: jsonEncode(sourcePreset.visibleFieldKeys),
              fieldOrderJson: jsonEncode(sourcePreset.fieldOrderKeys),
              updatedAt: Value(template.updatedAt),
            ),
          );
      await _touchProject(database, projectId);
      return template;
    });
  }

  @override
  Future<void> deleteColumnTemplate({
    required String projectId,
    required String templateId,
  }) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.delete(database.columnPresets)
            ..where((tbl) => tbl.id.equals(templateId) & tbl.kind.equals('template')))
          .go();
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> assignShotToSection(
    String projectId,
    String shotId,
    String sectionId,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        await (database.delete(database.planAssignments)
              ..where((tbl) => tbl.shotId.equals(shotId)))
            .go();
        final nextOrder = await _nextSectionOrderIndex(database, sectionId);
        await database.into(database.planAssignments).insert(
              db.PlanAssignmentsCompanion.insert(
                shotId: shotId,
                sectionId: sectionId,
                orderIndex: nextOrder,
              ),
            );
      });
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> unassignShot(String projectId, String shotId) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.delete(database.planAssignments)
            ..where((tbl) => tbl.shotId.equals(shotId)))
          .go();
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> createPlanSection(
    String projectId,
    plan_domain.PlanSection section,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await database.into(database.planSections).insertOnConflictUpdate(
            db.PlanSectionsCompanion.insert(
              id: section.id,
              projectId: projectId,
              name: section.name,
              orderIndex: section.orderIndex,
            ),
          );
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> deletePlanSection(String projectId, String sectionId) async {
    await _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        await (database.delete(database.planAssignments)
              ..where((tbl) => tbl.sectionId.equals(sectionId)))
            .go();
        await (database.delete(database.planSections)
              ..where((tbl) => tbl.id.equals(sectionId)))
            .go();
      });
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> renamePlanSection(
    String projectId,
    String sectionId,
    String name,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await (database.update(database.planSections)
            ..where((tbl) => tbl.id.equals(sectionId)))
          .write(db.PlanSectionsCompanion(name: Value(name)));
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> reorderSectionShots(
    String projectId,
    String sectionId,
    List<String> orderedShotIds,
  ) async {
    await _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        for (var index = 0; index < orderedShotIds.length; index++) {
          await (database.update(database.planAssignments)
                ..where(
                  (tbl) =>
                      tbl.sectionId.equals(sectionId) &
                      tbl.shotId.equals(orderedShotIds[index]),
                ))
              .write(
            db.PlanAssignmentsCompanion(orderIndex: Value(index)),
          );
        }
      });
      await _touchProject(database, projectId);
    });
  }

  @override
  Future<void> reorderShots(String projectId, List<String> orderedShotIds) async {
    await _withDb(projectId, (database, bundle) async {
      await database.transaction(() async {
        for (var index = 0; index < orderedShotIds.length; index++) {
          await (database.update(database.shots)
                ..where((tbl) => tbl.id.equals(orderedShotIds[index])))
              .write(db.ShotsCompanion(orderIndex: Value(index)));
        }
      });
      await _touchProject(database, projectId);
    });
  }

  Future<void> _updateShotRow(
    db.AppDatabase database,
    String shotId,
    db.ShotsCompanion companion,
  ) {
    return (database.update(database.shots)..where((tbl) => tbl.id.equals(shotId)))
        .write(companion);
  }

  Future<int> _countShots(db.AppDatabase database, String projectId) {
    final countExpression = database.shots.id.count();
    return (database.selectOnly(database.shots)
          ..addColumns([countExpression])
          ..where(database.shots.projectId.equals(projectId)))
        .map((row) => row.read(countExpression) ?? 0)
        .getSingle();
  }

  Future<int> _nextSectionOrderIndex(
    db.AppDatabase database,
    String sectionId,
  ) async {
    final maxExpression = database.planAssignments.orderIndex.max();
    return (database.selectOnly(database.planAssignments)
          ..addColumns([maxExpression])
          ..where(database.planAssignments.sectionId.equals(sectionId)))
        .map((row) => (row.read(maxExpression) ?? -1) + 1)
        .getSingle();
  }

  Future<void> _shiftShotOrders(
    db.AppDatabase database,
    String projectId, {
    required int startIndex,
    required int delta,
  }) async {
    final affected = await (database.select(database.shots)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) &
                tbl.orderIndex.isBiggerOrEqualValue(startIndex),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.orderIndex)]))
        .get();
    for (final row in affected) {
      await (database.update(database.shots)..where((tbl) => tbl.id.equals(row.id)))
          .write(db.ShotsCompanion(orderIndex: Value(row.orderIndex + delta)));
    }
  }

  Future<void> _normalizeShotOrders(
    db.AppDatabase database,
    String projectId,
  ) async {
    final rows = await (database.select(database.shots)
          ..where((tbl) => tbl.projectId.equals(projectId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();
    for (var index = 0; index < rows.length; index++) {
      if (rows[index].orderIndex == index) {
        continue;
      }
      await (database.update(database.shots)
            ..where((tbl) => tbl.id.equals(rows[index].id)))
          .write(db.ShotsCompanion(orderIndex: Value(index)));
    }
  }

  Future<void> _upsertAsset(
    db.AppDatabase database,
    ProjectBundle bundle, {
    required String shotId,
    required String fieldKey,
    required AssetRef asset,
  }) async {
    final existing = await _loadShotAssetRow(database, shotId, fieldKey);
    final storedUri = _storedAssetUri(bundle, asset);
    final companion = db.ShotAssetsCompanion(
      shotId: Value(shotId),
      fieldKey: Value(fieldKey),
      mode: Value(asset.mode.name),
      uri: Value(storedUri),
      fingerprint: Value(asset.fingerprint),
      missingState: Value(asset.missingState.name),
      width: Value(asset.width),
      height: Value(asset.height),
      bytes: Value(asset.bytes),
    );

    if (existing == null) {
      await database.into(database.shotAssets).insert(
            db.ShotAssetsCompanion.insert(
              id: _uuid.v4(),
              shotId: shotId,
              fieldKey: fieldKey,
              mode: asset.mode.name,
              uri: storedUri,
              fingerprint: asset.fingerprint,
              missingState: asset.missingState.name,
              width: Value(asset.width),
              height: Value(asset.height),
              bytes: Value(asset.bytes),
            ),
          );
      return;
    }

    await (database.update(database.shotAssets)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .write(companion);
  }

  Future<db.ShotAsset?> _loadShotAssetRow(
    db.AppDatabase database,
    String shotId,
    String fieldKey,
  ) {
    return (database.select(database.shotAssets)
          ..where(
            (tbl) => tbl.shotId.equals(shotId) & tbl.fieldKey.equals(fieldKey),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<AssetRef?> _loadAsset(
    db.AppDatabase database,
    String shotId,
    String fieldKey,
  ) async {
    final row = await _loadShotAssetRow(database, shotId, fieldKey);
    if (row == null) {
      return null;
    }
    return AssetRef(
      mode: AssetMode.values.byName(row.mode),
      uri: row.uri,
      fingerprint: row.fingerprint,
      missingState: MissingState.values.byName(row.missingState),
      width: row.width,
      height: row.height,
      bytes: row.bytes,
    );
  }

  Future<ShotRecord> _loadShotRecordById(
    db.AppDatabase database,
    ProjectBundle bundle,
    String shotId,
  ) async {
    final shot = await (database.select(database.shots)
          ..where((tbl) => tbl.id.equals(shotId))
          ..limit(1))
        .getSingle();
    final assets = await (database.select(database.shotAssets)
          ..where((tbl) => tbl.shotId.equals(shotId)))
        .get();
    final customColumns = await loadCustomColumns(bundle.id);
    final values = await (database.select(database.shotCustomValues)
          ..where((tbl) => tbl.shotId.equals(shotId)))
        .get();
    final valuesByColumn = <String, CustomFieldValue>{};
    for (final value in values) {
      valuesByColumn[value.columnId] = CustomFieldValue(
        shotId: value.shotId,
        columnId: value.columnId,
        textValue: value.textValue,
        numberValue: value.numberValue,
        enumValue: value.enumValue,
      );
    }
    return _mapShotRecord(shot, assets, valuesByColumn, customColumns, bundle);
  }

  ShotRecord _mapShotRecord(
    db.Shot shot,
    List<db.ShotAsset> shotAssets,
    Map<String, CustomFieldValue> customValues,
    List<CustomColumnDefinition> customColumns,
    ProjectBundle bundle,
  ) {
    AssetRef? resolveAsset(String key) {
      final record =
          shotAssets.firstWhereOrNull((asset) => asset.fieldKey == key);
      if (record == null) {
        return null;
      }
      return AssetRef(
        mode: AssetMode.values.byName(record.mode),
        uri: _resolvedAssetUri(bundle, record),
        fingerprint: record.fingerprint,
        missingState: MissingState.values.byName(record.missingState),
        width: record.width,
        height: record.height,
        bytes: record.bytes,
      );
    }

    final customFieldValues = <String, Object?>{};
    for (final column in customColumns) {
      final value = customValues[column.id];
      if (value == null) {
        continue;
      }
      customFieldValues[column.fieldKey] = value.value;
    }

    return ShotRecord(
      id: shot.id,
      orderIndex: shot.orderIndex,
      shotNo: shot.shotNo,
      shotSize: shot.shotSize,
      durationSec: shot.durationSec,
      content: shot.content,
      dialogue: shot.dialogue,
      notes: shot.notes,
      sceneExpectation: shot.sceneExpectation,
      audio: shot.audio,
      cameraAngle: shot.cameraAngle,
      cameraMove: shot.cameraMove,
      cameraRig: shot.cameraRig,
      focalLength: shot.focalLength,
      frameImage: resolveAsset(ShotFieldKey.frameImage.storageKey),
      referenceImage: resolveAsset(ShotFieldKey.referenceImage.storageKey),
      customFieldValues: customFieldValues,
    );
  }

  String _storedAssetUri(ProjectBundle bundle, AssetRef asset) {
    if (asset.mode != AssetMode.managed) {
      return asset.uri;
    }
    if (!p.isAbsolute(asset.uri)) {
      return asset.uri;
    }
    return p.relative(asset.uri, from: bundle.rootPath);
  }

  String _resolvedAssetUri(ProjectBundle bundle, db.ShotAsset asset) {
    if (asset.mode != AssetMode.managed.name || p.isAbsolute(asset.uri)) {
      return asset.uri;
    }
    return p.normalize(p.join(bundle.rootPath, asset.uri));
  }

  Future<void> _touchProject(db.AppDatabase database, String projectId) {
    final now = DateTime.now();
    return (database.update(database.projects)
          ..where((tbl) => tbl.id.equals(projectId)))
        .write(db.ProjectsCompanion(updatedAt: Value(now)));
  }

  Future<Map<String, List<String>>> _loadFixedFieldCustomOptionsWithDb(
    db.AppDatabase database,
    String projectId,
  ) async {
    final rows = await (database.select(database.eventLog)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) &
                tbl.eventType.equals(_fixedFieldOptionsEventType),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(1))
        .get();
    if (rows.isEmpty) {
      return const {};
    }
    final payload = jsonDecode(rows.first.payloadJson);
    if (payload is! Map<String, dynamic>) {
      return const {};
    }
    return {
      for (final entry in payload.entries)
        entry.key: (entry.value as List<dynamic>).cast<String>(),
    };
  }

  Future<void> _replaceFixedFieldCustomOptionsWithDb(
    db.AppDatabase database,
    String projectId,
    Map<String, List<String>> nextOptionsByFieldKey,
  ) {
    return database.into(database.eventLog).insert(
          db.EventLogCompanion.insert(
            projectId: projectId,
            eventType: _fixedFieldOptionsEventType,
            payloadJson: jsonEncode(nextOptionsByFieldKey),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> _ensureFixedFieldCustomOption(
    db.AppDatabase database,
    String projectId,
    String fieldKey,
    String option,
  ) async {
    final normalizedOption = option.trim();
    if (normalizedOption.isEmpty) {
      return;
    }

    final baseOptions = fixedFieldBaseOptionsByKey[fieldKey] ?? const <String>[];
    if (baseOptions.contains(normalizedOption)) {
      return;
    }

    final current = await _loadFixedFieldCustomOptionsWithDb(database, projectId);
    final existing = current[fieldKey] ?? const <String>[];
    if (existing.contains(normalizedOption)) {
      return;
    }

    final next = <String, List<String>>{
      for (final entry in current.entries) entry.key: [...entry.value],
    };
    next[fieldKey] = [...existing, normalizedOption];
    await _replaceFixedFieldCustomOptionsWithDb(database, projectId, next);
  }
}

