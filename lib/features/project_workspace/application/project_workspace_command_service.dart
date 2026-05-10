import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/command/command_bus.dart';
import '../../../core/history/history_entry.dart';
import '../../../core/history/history_manager.dart';
import '../domain/commands/workspace_commands.dart';
import '../domain/models/asset_ref.dart';
import '../domain/models/board_preset.dart';
import '../domain/models/column_preset.dart';
import '../domain/models/custom_column_definition.dart';
import '../domain/models/plan_board.dart';
import '../domain/models/shot_record.dart';
import '../domain/models/storyboard_scene.dart';
import '../domain/repositories/project_workspace_repository.dart';

class ProjectWorkspaceCommandService {
  ProjectWorkspaceCommandService({
    required this.commandBus,
    required this.historyManager,
    required this.workspaceRepository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid() {
    _registerHandlers();
  }

  final CommandBus commandBus;
  final HistoryManager historyManager;
  final ProjectWorkspaceRepository workspaceRepository;
  final Uuid _uuid;

  void _registerHandlers() {
    commandBus.register<CreateShotCommand>(_handleCreateShot);
    commandBus.register<DeleteShotCommand>(_handleDeleteShot);
    commandBus.register<UpdateShotFieldCommand>(_handleUpdateShotField);
    commandBus.register<BatchUpdateShotFieldCommand>(_handleBatchUpdateField);
    commandBus.register<ReorderShotCommand>(_handleReorderShot);
    commandBus.register<AssignShotToPlanCommand>(_handleAssignShotToPlan);
    commandBus.register<ImportAssetCommand>(_handleImportAsset);
    commandBus.register<RelinkAssetCommand>(_handleRelinkAsset);
    commandBus.register<UpdateViewPresetCommand>(_handleUpdateViewPreset);
    commandBus.register<CreateCustomColumnCommand>(_handleCreateCustomColumn);
    commandBus.register<RenameCustomColumnCommand>(_handleRenameCustomColumn);
    commandBus.register<DeleteCustomColumnCommand>(_handleDeleteCustomColumn);
    commandBus.register<SaveColumnTemplateCommand>(_handleSaveColumnTemplate);
    commandBus.register<ApplyColumnTemplateCommand>(_handleApplyColumnTemplate);
    commandBus.register<DeleteColumnTemplateCommand>(
      _handleDeleteColumnTemplate,
    );
    commandBus.register<AddFixedFieldOptionCommand>(_handleAddFixedFieldOption);
    commandBus.register<CreatePlanSectionCommand>(_handleCreatePlanSection);
    commandBus.register<RenamePlanSectionCommand>(_handleRenamePlanSection);
    commandBus.register<DeletePlanSectionCommand>(_handleDeletePlanSection);
    commandBus.register<ReorderPlanSectionShotsCommand>(
      _handleReorderPlanSectionShots,
    );
    commandBus.register<UnassignShotFromPlanCommand>(
      _handleUnassignShotFromPlan,
    );
    commandBus.register<CreateSceneCommand>(_handleCreateScene);
    commandBus.register<UpdateSceneCommand>(_handleUpdateScene);
    commandBus.register<DeleteEmptySceneCommand>(_handleDeleteEmptyScene);
    commandBus.register<ReorderScenesCommand>(_handleReorderScenes);
  }

  Future<ShotRecord> createShot(
    String projectId, {
    ShotRecord? seedShot,
    int? insertIndex,
    String? sceneId,
  }) async {
    final effectiveSeedShot = seedShot == null
        ? null
        : seedShot.id.trim().isEmpty
        ? seedShot.copyWith(id: _uuid.v4())
        : seedShot;
    final result = await commandBus.dispatch(
      CreateShotCommand(
        projectId: projectId,
        seedShot: effectiveSeedShot,
        insertIndex: insertIndex,
        sceneId: sceneId,
      ),
    );
    return result.payload! as ShotRecord;
  }

  Future<void> deleteShot({
    required String projectId,
    required String shotId,
  }) async {
    await commandBus.dispatch(
      DeleteShotCommand(projectId: projectId, shotId: shotId),
    );
  }

  Future<List<ShotRecord>> importSeedShotsBatch(
    String projectId, {
    required List<ShotRecord> seedShots,
  }) async {
    if (seedShots.isEmpty) {
      return const [];
    }

    final existingShots = await workspaceRepository.loadShots(projectId);
    final effectiveSeeds = <ShotRecord>[];
    final reusableScaffolds = _detectReusableScaffoldShots(existingShots);
    final reusedShotIds = <String>[];
    final deletedScaffolds = <ShotRecord>[];
    final createdShots = <ShotRecord>[];
    final originalPlanBoard = await workspaceRepository.loadPlanBoard(projectId);

    try {
      for (var index = 0; index < seedShots.length; index++) {
        final seed = seedShots[index];
        if (index < reusableScaffolds.length) {
          final target = reusableScaffolds[index];
          reusedShotIds.add(target.id);
          await _overwriteShotFromSeed(
            projectId: projectId,
            shotId: target.id,
            seed: seed,
          );
          continue;
        }

        final effectiveSeed =
            (seed.id.trim().isEmpty ? seed.copyWith(id: _uuid.v4()) : seed)
                .copyWith(orderIndex: existingShots.length + createdShots.length);
        effectiveSeeds.add(effectiveSeed);
        final created = await workspaceRepository.createShot(
          projectId,
          seedShot: effectiveSeed,
        );
        createdShots.add(created);
      }

      for (final scaffold in reusableScaffolds.skip(seedShots.length)) {
        deletedScaffolds.add(scaffold);
        await workspaceRepository.deleteShot(projectId, scaffold.id);
      }
    } catch (_) {
      for (final shot in createdShots.reversed) {
        await workspaceRepository.deleteShot(projectId, shot.id);
      }
      rethrow;
    }

    historyManager.record(
      HistoryEntry(
        label: 'ImportAiStoryboardDrafts',
        createdAt: DateTime.now(),
        undo: () => _undoImportedSeedShotsBatch(
          projectId: projectId,
          originalShots: existingShots,
          originalPlanBoard: originalPlanBoard,
          createdShots: createdShots,
          reusedShotIds: reusedShotIds,
          deletedScaffolds: deletedScaffolds,
        ),
        redo: () => _redoImportedSeedShotsBatch(
          projectId: projectId,
          originalShots: existingShots,
          originalPlanBoard: originalPlanBoard,
          effectiveSeeds: effectiveSeeds,
          reusableScaffolds: reusableScaffolds,
          reusedShotIds: reusedShotIds,
          deletedScaffolds: deletedScaffolds,
          sourceSeeds: seedShots,
        ),
      ),
    );

    return workspaceRepository.loadShots(projectId);
  }

  Future<void> updateField({
    required String projectId,
    required String shotId,
    required String fieldKey,
    required Object? value,
  }) async {
    await commandBus.dispatch(
      UpdateShotFieldCommand(
        projectId: projectId,
        shotId: shotId,
        fieldKey: fieldKey,
        value: value,
      ),
    );
  }

  Future<void> batchUpdateField({
    required String projectId,
    required List<String> shotIds,
    required String fieldKey,
    required Object? value,
  }) async {
    await commandBus.dispatch(
      BatchUpdateShotFieldCommand(
        projectId: projectId,
        updates: [
          for (final shotId in shotIds)
            BatchFieldUpdate(shotId: shotId, fieldKey: fieldKey, value: value),
        ],
      ),
    );
  }

  Future<void> reorderShots({
    required String projectId,
    required String shotId,
    required int toIndex,
  }) async {
    await commandBus.dispatch(
      ReorderShotCommand(
        projectId: projectId,
        shotId: shotId,
        toIndex: toIndex,
      ),
    );
  }

  Future<void> importAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String sourcePath,
    required AssetMode assetMode,
  }) async {
    final bundle = await workspaceRepository.loadBundle(projectId);
    final extension = p.extension(sourcePath);
    final fingerprint = await _fingerprintFile(sourcePath);
    final managedTargetPath = p.join(
      bundle.assetsPath,
      '$fingerprint$extension',
    );
    await commandBus.dispatch(
      ImportAssetCommand(
        projectId: projectId,
        shotId: shotId,
        sourcePath: sourcePath,
        assetMode: assetMode,
        managedTargetPath: managedTargetPath,
        targetField: targetField,
        fingerprint: fingerprint,
      ),
    );
  }

  Future<void> relinkAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String newPath,
  }) async {
    await commandBus.dispatch(
      RelinkAssetCommand(
        projectId: projectId,
        shotId: shotId,
        targetField: targetField,
        newPath: newPath,
      ),
    );
  }

  Future<void> assignShotToPlan({
    required String projectId,
    required String shotId,
    required String sectionId,
  }) async {
    await commandBus.dispatch(
      AssignShotToPlanCommand(
        projectId: projectId,
        shotId: shotId,
        sectionId: sectionId,
      ),
    );
  }

  Future<void> updateBoardPreset(String projectId, BoardPreset preset) async {
    await commandBus.dispatch(
      UpdateViewPresetCommand(projectId: projectId, boardPreset: preset),
    );
  }

  Future<void> updateColumnPreset(String projectId, ColumnPreset preset) async {
    await commandBus.dispatch(
      UpdateViewPresetCommand(projectId: projectId, columnPreset: preset),
    );
  }

  Future<void> createCustomColumn({
    required String projectId,
    required String name,
    required CustomColumnType type,
    BuiltInEnumSource? enumSource,
  }) async {
    await commandBus.dispatch(
      CreateCustomColumnCommand(
        projectId: projectId,
        name: name,
        type: type,
        enumSource: enumSource,
      ),
    );
  }

  Future<void> renameCustomColumn({
    required String projectId,
    required String columnId,
    required String name,
  }) async {
    await commandBus.dispatch(
      RenameCustomColumnCommand(
        projectId: projectId,
        columnId: columnId,
        name: name,
      ),
    );
  }

  Future<void> deleteCustomColumn({
    required String projectId,
    required String columnId,
  }) async {
    await commandBus.dispatch(
      DeleteCustomColumnCommand(projectId: projectId, columnId: columnId),
    );
  }

  Future<void> saveColumnTemplate({
    required String projectId,
    required String name,
  }) async {
    await commandBus.dispatch(
      SaveColumnTemplateCommand(projectId: projectId, name: name),
    );
  }

  Future<void> applyColumnTemplate({
    required String projectId,
    required String templateId,
  }) async {
    await commandBus.dispatch(
      ApplyColumnTemplateCommand(projectId: projectId, templateId: templateId),
    );
  }

  Future<void> deleteColumnTemplate({
    required String projectId,
    required String templateId,
  }) async {
    await commandBus.dispatch(
      DeleteColumnTemplateCommand(projectId: projectId, templateId: templateId),
    );
  }

  Future<void> addFixedFieldOption({
    required String projectId,
    required String fieldKey,
    required String option,
  }) async {
    await commandBus.dispatch(
      AddFixedFieldOptionCommand(
        projectId: projectId,
        fieldKey: fieldKey,
        option: option,
      ),
    );
  }

  Future<void> deleteFixedFieldOption({
    required String projectId,
    required String fieldKey,
    required String option,
  }) async {
    await workspaceRepository.deleteFixedFieldCustomOption(
      projectId: projectId,
      fieldKey: fieldKey,
      option: option,
    );
  }

  Future<void> deleteCustomColumnOption({
    required String projectId,
    required String columnId,
    required String option,
  }) async {
    await workspaceRepository.deleteCustomColumnOption(
      projectId: projectId,
      columnId: columnId,
      option: option,
    );
  }

  Future<void> createPlanSection(String projectId, String name) async {
    await commandBus.dispatch(
      CreatePlanSectionCommand(projectId: projectId, name: name),
    );
  }

  Future<void> renamePlanSection({
    required String projectId,
    required String sectionId,
    required String name,
  }) async {
    await commandBus.dispatch(
      RenamePlanSectionCommand(
        projectId: projectId,
        sectionId: sectionId,
        name: name,
      ),
    );
  }

  Future<void> deletePlanSection({
    required String projectId,
    required String sectionId,
  }) async {
    await commandBus.dispatch(
      DeletePlanSectionCommand(projectId: projectId, sectionId: sectionId),
    );
  }

  Future<void> reorderPlanSectionShots({
    required String projectId,
    required String sectionId,
    required List<String> orderedShotIds,
  }) async {
    await commandBus.dispatch(
      ReorderPlanSectionShotsCommand(
        projectId: projectId,
        sectionId: sectionId,
        orderedShotIds: orderedShotIds,
      ),
    );
  }

  Future<void> unassignShotFromPlan({
    required String projectId,
    required String shotId,
  }) async {
    await commandBus.dispatch(
      UnassignShotFromPlanCommand(projectId: projectId, shotId: shotId),
    );
  }

  Future<void> createScene({
    required String projectId,
    required int insertIndex,
    String name = '',
  }) async {
    await commandBus.dispatch(
      CreateSceneCommand(
        projectId: projectId,
        insertIndex: insertIndex,
        name: name,
      ),
    );
  }

  Future<void> updateScene({
    required String projectId,
    required StoryboardScene scene,
  }) async {
    await commandBus.dispatch(
      UpdateSceneCommand(projectId: projectId, scene: scene),
    );
  }

  Future<void> deleteEmptyScene({
    required String projectId,
    required String sceneId,
  }) async {
    await commandBus.dispatch(
      DeleteEmptySceneCommand(projectId: projectId, sceneId: sceneId),
    );
  }

  Future<void> reorderScenes({
    required String projectId,
    required List<String> orderedSceneIds,
  }) async {
    await commandBus.dispatch(
      ReorderScenesCommand(projectId: projectId, orderedSceneIds: orderedSceneIds),
    );
  }

  Future<void> undo(String projectId) async {
    await historyManager.undo();
  }

  Future<void> redo(String projectId) async {
    await historyManager.redo();
  }

  Future<CommandResult> _handleCreateShot(CreateShotCommand command) async {
    final created = await workspaceRepository.createShot(
      command.projectId,
      seedShot: command.seedShot,
      insertIndex: command.insertIndex,
      sceneId: command.sceneId,
    );
    final seed = created.copyWith();
    return CommandResult(
      payload: created,
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () =>
            workspaceRepository.deleteShot(command.projectId, created.id),
        redo: () async {
          await workspaceRepository.createShot(
            command.projectId,
            seedShot: seed,
          );
        },
      ),
    );
  }

  Future<CommandResult> _handleDeleteShot(DeleteShotCommand command) async {
    final shots = await workspaceRepository.loadShots(command.projectId);
    final shot = shots.firstWhere((item) => item.id == command.shotId);
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final previousSectionId = _findShotSectionId(board, command.shotId);
    final previousSectionOrder = previousSectionId == null
        ? null
        : board.sections
              .firstWhere((item) => item.id == previousSectionId)
              .shotIds;

    await workspaceRepository.deleteShot(command.projectId, command.shotId);

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          await workspaceRepository.createShot(
            command.projectId,
            seedShot: shot,
          );
          if (previousSectionId != null) {
            await workspaceRepository.assignShotToSection(
              command.projectId,
              shot.id,
              previousSectionId,
            );
            if (previousSectionOrder != null) {
              await workspaceRepository.reorderSectionShots(
                command.projectId,
                previousSectionId,
                previousSectionOrder,
              );
            }
          }
        },
        redo: () =>
            workspaceRepository.deleteShot(command.projectId, command.shotId),
      ),
    );
  }

  Future<CommandResult> _handleUpdateShotField(
    UpdateShotFieldCommand command,
  ) async {
    final shots = await workspaceRepository.loadShots(command.projectId);
    final shot = shots.firstWhere((item) => item.id == command.shotId);
    final before = _readShotFieldValue(shot, command.fieldKey);
    final beforePayload = before is AssetRef
        ? AssetRefPayload.fromAssetRef(before)
        : before;
    final afterPayload = command.value is AssetRef
        ? AssetRefPayload.fromAssetRef(command.value as AssetRef)
        : command.value;

    await workspaceRepository.updateShotField(
      command.projectId,
      command.shotId,
      command.fieldKey,
      command.value,
    );

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        mergeKey: '${command.projectId}:${command.shotId}:${command.fieldKey}',
        undo: () => workspaceRepository.updateShotField(
          command.projectId,
          command.shotId,
          command.fieldKey,
          beforePayload,
        ),
        redo: () => workspaceRepository.updateShotField(
          command.projectId,
          command.shotId,
          command.fieldKey,
          afterPayload,
        ),
      ),
    );
  }

  Future<CommandResult> _handleBatchUpdateField(
    BatchUpdateShotFieldCommand command,
  ) async {
    final shots = await workspaceRepository.loadShots(command.projectId);
    final beforeValues = <String, Object?>{};

    for (final update in command.updates) {
      final shot = shots.firstWhere((item) => item.id == update.shotId);
      beforeValues[update.shotId] = _readShotFieldValue(shot, update.fieldKey);
      await workspaceRepository.updateShotField(
        command.projectId,
        update.shotId,
        update.fieldKey,
        update.value,
      );
    }

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          for (final update in command.updates) {
            await workspaceRepository.updateShotField(
              command.projectId,
              update.shotId,
              update.fieldKey,
              beforeValues[update.shotId],
            );
          }
        },
        redo: () async {
          for (final update in command.updates) {
            await workspaceRepository.updateShotField(
              command.projectId,
              update.shotId,
              update.fieldKey,
              update.value,
            );
          }
        },
      ),
    );
  }

  Future<CommandResult> _handleReorderShot(ReorderShotCommand command) async {
    final shots = await workspaceRepository.loadShots(command.projectId);
    final originalIds = shots.map((shot) => shot.id).toList();
    final fromIndex = originalIds.indexOf(command.shotId);
    if (fromIndex < 0) {
      return const CommandResult();
    }
    final nextIds = [...originalIds];
    final moved = nextIds.removeAt(fromIndex);
    final safeIndex = command.toIndex.clamp(0, nextIds.length);
    nextIds.insert(safeIndex, moved);
    await workspaceRepository.reorderShots(command.projectId, nextIds);

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () =>
            workspaceRepository.reorderShots(command.projectId, originalIds),
        redo: () =>
            workspaceRepository.reorderShots(command.projectId, nextIds),
      ),
    );
  }

  Future<CommandResult> _handleAssignShotToPlan(
    AssignShotToPlanCommand command,
  ) async {
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final previousSectionId = _findShotSectionId(board, command.shotId);
    await workspaceRepository.assignShotToSection(
      command.projectId,
      command.shotId,
      command.sectionId,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          if (previousSectionId == null) {
            await workspaceRepository.unassignShot(
              command.projectId,
              command.shotId,
            );
            return;
          }
          await workspaceRepository.assignShotToSection(
            command.projectId,
            command.shotId,
            previousSectionId,
          );
        },
        redo: () => workspaceRepository.assignShotToSection(
          command.projectId,
          command.shotId,
          command.sectionId,
        ),
      ),
    );
  }

  Future<CommandResult> _handleImportAsset(ImportAssetCommand command) async {
    final shots = await workspaceRepository.loadShots(command.projectId);
    final shot = shots.firstWhere((item) => item.id == command.shotId);
    final previous = _readShotFieldValue(shot, command.targetField);

    if (command.assetMode == AssetMode.managed) {
      await workspaceRepository.importManagedAsset(
        projectId: command.projectId,
        shotId: command.shotId,
        targetField: command.targetField,
        sourcePath: command.sourcePath,
        managedTargetPath: command.managedTargetPath,
        fingerprint: command.fingerprint,
      );
    } else {
      await workspaceRepository.attachLinkedAsset(
        projectId: command.projectId,
        shotId: command.shotId,
        targetField: command.targetField,
        sourcePath: command.sourcePath,
        fingerprint: command.fingerprint,
      );
    }

    Future<void> restorePrevious() async {
      if (command.assetMode == AssetMode.managed) {
        final file = File(command.managedTargetPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      if (previous == null) {
        await workspaceRepository.removeAssetRef(
          command.projectId,
          command.shotId,
          command.targetField,
        );
        return;
      }
      await workspaceRepository.updateShotField(
        command.projectId,
        command.shotId,
        command.targetField,
        AssetRefPayload.fromAssetRef(previous as AssetRef),
      );
    }

    Future<void> reapplyImport() async {
      if (command.assetMode == AssetMode.managed) {
        await workspaceRepository.importManagedAsset(
          projectId: command.projectId,
          shotId: command.shotId,
          targetField: command.targetField,
          sourcePath: command.sourcePath,
          managedTargetPath: command.managedTargetPath,
          fingerprint: command.fingerprint,
        );
        return;
      }
      await workspaceRepository.attachLinkedAsset(
        projectId: command.projectId,
        shotId: command.shotId,
        targetField: command.targetField,
        sourcePath: command.sourcePath,
        fingerprint: command.fingerprint,
      );
    }

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: restorePrevious,
        redo: reapplyImport,
      ),
    );
  }

  Future<CommandResult> _handleRelinkAsset(RelinkAssetCommand command) async {
    final shots = await workspaceRepository.loadShots(command.projectId);
    final shot = shots.firstWhere((item) => item.id == command.shotId);
    final previous = _readShotFieldValue(shot, command.targetField);
    final previousAsset = previous as AssetRef?;
    final nextFingerprint = await _fingerprintFile(command.newPath);
    await workspaceRepository.relinkAsset(
      projectId: command.projectId,
      shotId: command.shotId,
      targetField: command.targetField,
      newPath: command.newPath,
      fingerprint: nextFingerprint,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          if (previousAsset == null) {
            await workspaceRepository.removeAssetRef(
              command.projectId,
              command.shotId,
              command.targetField,
            );
            return;
          }
          await workspaceRepository.updateShotField(
            command.projectId,
            command.shotId,
            command.targetField,
            AssetRefPayload.fromAssetRef(previousAsset),
          );
        },
        redo: () => workspaceRepository.relinkAsset(
          projectId: command.projectId,
          shotId: command.shotId,
          targetField: command.targetField,
          newPath: command.newPath,
          fingerprint: nextFingerprint,
        ),
      ),
    );
  }

  Future<CommandResult> _handleUpdateViewPreset(
    UpdateViewPresetCommand command,
  ) async {
    final currentBoard = await workspaceRepository.loadBoardPreset(
      command.projectId,
    );
    final currentColumn = await workspaceRepository.loadColumnPreset(
      command.projectId,
    );
    final nextBoard = command.boardPreset;
    final nextColumn = command.columnPreset;

    if (nextBoard != null) {
      await workspaceRepository.updateBoardPreset(command.projectId, nextBoard);
    }
    if (nextColumn != null) {
      await workspaceRepository.updateColumnPreset(
        command.projectId,
        nextColumn,
      );
    }

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          if (nextBoard != null) {
            await workspaceRepository.updateBoardPreset(
              command.projectId,
              currentBoard,
            );
          }
          if (nextColumn != null) {
            await workspaceRepository.updateColumnPreset(
              command.projectId,
              currentColumn,
            );
          }
        },
        redo: () async {
          if (nextBoard != null) {
            await workspaceRepository.updateBoardPreset(
              command.projectId,
              nextBoard,
            );
          }
          if (nextColumn != null) {
            await workspaceRepository.updateColumnPreset(
              command.projectId,
              nextColumn,
            );
          }
        },
      ),
    );
  }

  Future<CommandResult> _handleCreateCustomColumn(
    CreateCustomColumnCommand command,
  ) async {
    final previousPreset = await workspaceRepository.loadColumnPreset(
      command.projectId,
    );
    final previousTemplates = await workspaceRepository.loadColumnTemplates(
      command.projectId,
    );
    final now = DateTime.now();
    final created = await workspaceRepository.createCustomColumn(
      projectId: command.projectId,
      name: command.name,
      type: command.type,
      enumSource: command.enumSource,
      createdAt: now,
      updatedAt: now,
    );
    final nextPreset = _appendFieldToActivePreset(
      previousPreset,
      created.fieldKey,
    );
    await workspaceRepository.updateColumnPreset(command.projectId, nextPreset);

    for (final template in previousTemplates) {
      final nextTemplate = template.copyWith(
        fieldOrderKeys: [...template.fieldOrderKeys, created.fieldKey],
        updatedAt: now,
      );
      await workspaceRepository.saveColumnTemplate(
        projectId: command.projectId,
        name: nextTemplate.name,
        sourcePreset: ColumnPreset(
          id: nextTemplate.id,
          name: nextTemplate.name,
          kind: ColumnPresetKind.template,
          visibleFieldKeys: nextTemplate.visibleFieldKeys,
          fieldOrderKeys: nextTemplate.fieldOrderKeys,
          updatedAt: nextTemplate.updatedAt,
        ),
        templateId: template.id,
      );
    }

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          await workspaceRepository.deleteCustomColumn(
            projectId: command.projectId,
            columnId: created.id,
          );
          await workspaceRepository.updateColumnPreset(
            command.projectId,
            previousPreset,
          );
          for (final template in previousTemplates) {
            await workspaceRepository.saveColumnTemplate(
              projectId: command.projectId,
              name: template.name,
              sourcePreset: ColumnPreset(
                id: template.id,
                name: template.name,
                kind: ColumnPresetKind.template,
                visibleFieldKeys: template.visibleFieldKeys,
                fieldOrderKeys: template.fieldOrderKeys,
                updatedAt: template.updatedAt,
              ),
              templateId: template.id,
            );
          }
        },
        redo: () async {
          await workspaceRepository.createCustomColumn(
            projectId: command.projectId,
            name: created.name,
            type: created.type,
            enumSource: created.enumSource,
            columnId: created.id,
            createdAt: created.createdAt,
            updatedAt: created.updatedAt,
          );
          await workspaceRepository.updateColumnPreset(
            command.projectId,
            nextPreset,
          );
          for (final template in previousTemplates) {
            final nextTemplate = template.copyWith(
              fieldOrderKeys: [...template.fieldOrderKeys, created.fieldKey],
              updatedAt: now,
            );
            await workspaceRepository.saveColumnTemplate(
              projectId: command.projectId,
              name: nextTemplate.name,
              sourcePreset: ColumnPreset(
                id: nextTemplate.id,
                name: nextTemplate.name,
                kind: ColumnPresetKind.template,
                visibleFieldKeys: nextTemplate.visibleFieldKeys,
                fieldOrderKeys: nextTemplate.fieldOrderKeys,
                updatedAt: nextTemplate.updatedAt,
              ),
              templateId: template.id,
            );
          }
        },
      ),
    );
  }

  Future<CommandResult> _handleRenameCustomColumn(
    RenameCustomColumnCommand command,
  ) async {
    final columns = await workspaceRepository.loadCustomColumns(
      command.projectId,
    );
    final column = columns.firstWhere((item) => item.id == command.columnId);
    await workspaceRepository.renameCustomColumn(
      projectId: command.projectId,
      columnId: command.columnId,
      name: command.name,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.renameCustomColumn(
          projectId: command.projectId,
          columnId: command.columnId,
          name: column.name,
        ),
        redo: () => workspaceRepository.renameCustomColumn(
          projectId: command.projectId,
          columnId: command.columnId,
          name: command.name,
        ),
      ),
    );
  }

  Future<CommandResult> _handleDeleteCustomColumn(
    DeleteCustomColumnCommand command,
  ) async {
    final columns = await workspaceRepository.loadCustomColumns(
      command.projectId,
    );
    final target = columns.firstWhere((item) => item.id == command.columnId);
    final shots = await workspaceRepository.loadShots(command.projectId);
    final preset = await workspaceRepository.loadColumnPreset(
      command.projectId,
    );
    final templates = await workspaceRepository.loadColumnTemplates(
      command.projectId,
    );
    final targetCustomOptions = [...target.customOptions];
    final shotValues = <String, Object?>{
      for (final shot in shots)
        shot.id: shot.customFieldValues[target.fieldKey],
    };

    await workspaceRepository.deleteCustomColumn(
      projectId: command.projectId,
      columnId: command.columnId,
    );

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          await workspaceRepository.createCustomColumn(
            projectId: command.projectId,
            name: target.name,
            type: target.type,
            enumSource: target.enumSource,
            customOptions: targetCustomOptions,
            columnId: target.id,
            createdAt: target.createdAt,
            updatedAt: DateTime.now(),
          );
          await workspaceRepository.updateColumnPreset(
            command.projectId,
            preset,
          );
          for (final template in templates) {
            await workspaceRepository.saveColumnTemplate(
              projectId: command.projectId,
              name: template.name,
              sourcePreset: ColumnPreset(
                id: template.id,
                name: template.name,
                kind: ColumnPresetKind.template,
                visibleFieldKeys: template.visibleFieldKeys,
                fieldOrderKeys: template.fieldOrderKeys,
                updatedAt: template.updatedAt,
              ),
              templateId: template.id,
            );
          }
          for (final entry in shotValues.entries) {
            if (entry.value == null) {
              continue;
            }
            await workspaceRepository.updateCustomFieldValue(
              projectId: command.projectId,
              shotId: entry.key,
              columnId: target.id,
              value: entry.value,
            );
          }
        },
        redo: () => workspaceRepository.deleteCustomColumn(
          projectId: command.projectId,
          columnId: command.columnId,
        ),
      ),
    );
  }

  Future<CommandResult> _handleSaveColumnTemplate(
    SaveColumnTemplateCommand command,
  ) async {
    final active = await workspaceRepository.loadColumnPreset(
      command.projectId,
    );
    final templates = await workspaceRepository.loadColumnTemplates(
      command.projectId,
    );
    final existing = templates
        .where((item) => item.name == command.name)
        .firstOrNull;
    final previous = existing;
    final saved = await workspaceRepository.saveColumnTemplate(
      projectId: command.projectId,
      name: command.name,
      sourcePreset: active,
      templateId: existing?.id,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          await workspaceRepository.deleteColumnTemplate(
            projectId: command.projectId,
            templateId: saved.id,
          );
          if (previous != null) {
            await workspaceRepository.saveColumnTemplate(
              projectId: command.projectId,
              name: previous.name,
              sourcePreset: ColumnPreset(
                id: previous.id,
                name: previous.name,
                kind: ColumnPresetKind.template,
                visibleFieldKeys: previous.visibleFieldKeys,
                fieldOrderKeys: previous.fieldOrderKeys,
                updatedAt: previous.updatedAt,
              ),
              templateId: previous.id,
            );
          }
        },
        redo: () => workspaceRepository.saveColumnTemplate(
          projectId: command.projectId,
          name: command.name,
          sourcePreset: active,
          templateId: saved.id,
        ),
      ),
    );
  }

  Future<CommandResult> _handleApplyColumnTemplate(
    ApplyColumnTemplateCommand command,
  ) async {
    final active = await workspaceRepository.loadColumnPreset(
      command.projectId,
    );
    final templates = await workspaceRepository.loadColumnTemplates(
      command.projectId,
    );
    final template = templates.firstWhere(
      (item) => item.id == command.templateId,
    );
    final nextPreset = active.copyWith(
      visibleFieldKeys: template.visibleFieldKeys,
      fieldOrderKeys: template.fieldOrderKeys,
      updatedAt: DateTime.now(),
    );
    await workspaceRepository.updateColumnPreset(command.projectId, nextPreset);
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () =>
            workspaceRepository.updateColumnPreset(command.projectId, active),
        redo: () => workspaceRepository.updateColumnPreset(
          command.projectId,
          nextPreset,
        ),
      ),
    );
  }

  Future<CommandResult> _handleDeleteColumnTemplate(
    DeleteColumnTemplateCommand command,
  ) async {
    final templates = await workspaceRepository.loadColumnTemplates(
      command.projectId,
    );
    final template = templates.firstWhere(
      (item) => item.id == command.templateId,
    );
    await workspaceRepository.deleteColumnTemplate(
      projectId: command.projectId,
      templateId: command.templateId,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.saveColumnTemplate(
          projectId: command.projectId,
          name: template.name,
          sourcePreset: ColumnPreset(
            id: template.id,
            name: template.name,
            kind: ColumnPresetKind.template,
            visibleFieldKeys: template.visibleFieldKeys,
            fieldOrderKeys: template.fieldOrderKeys,
            updatedAt: template.updatedAt,
          ),
          templateId: template.id,
        ),
        redo: () => workspaceRepository.deleteColumnTemplate(
          projectId: command.projectId,
          templateId: command.templateId,
        ),
      ),
    );
  }

  Future<CommandResult> _handleAddFixedFieldOption(
    AddFixedFieldOptionCommand command,
  ) async {
    final before = await workspaceRepository.loadFixedFieldCustomOptions(
      command.projectId,
    );
    await workspaceRepository.addFixedFieldCustomOption(
      projectId: command.projectId,
      fieldKey: command.fieldKey,
      option: command.option,
    );
    final after = await workspaceRepository.loadFixedFieldCustomOptions(
      command.projectId,
    );

    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.replaceFixedFieldCustomOptions(
          projectId: command.projectId,
          nextOptionsByFieldKey: before,
        ),
        redo: () => workspaceRepository.replaceFixedFieldCustomOptions(
          projectId: command.projectId,
          nextOptionsByFieldKey: after,
        ),
      ),
    );
  }

  Future<CommandResult> _handleCreatePlanSection(
    CreatePlanSectionCommand command,
  ) async {
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final section = PlanSection(
      id: _uuid.v4(),
      name: command.name,
      orderIndex: board.sections.length,
      shotIds: const [],
    );
    await workspaceRepository.createPlanSection(command.projectId, section);
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.deletePlanSection(
          command.projectId,
          section.id,
        ),
        redo: () =>
            workspaceRepository.createPlanSection(command.projectId, section),
      ),
    );
  }

  Future<CommandResult> _handleRenamePlanSection(
    RenamePlanSectionCommand command,
  ) async {
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final section = board.sections.firstWhere(
      (item) => item.id == command.sectionId,
    );
    await workspaceRepository.renamePlanSection(
      command.projectId,
      command.sectionId,
      command.name,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.renamePlanSection(
          command.projectId,
          command.sectionId,
          section.name,
        ),
        redo: () => workspaceRepository.renamePlanSection(
          command.projectId,
          command.sectionId,
          command.name,
        ),
      ),
    );
  }

  Future<CommandResult> _handleDeletePlanSection(
    DeletePlanSectionCommand command,
  ) async {
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final section = board.sections.firstWhere(
      (item) => item.id == command.sectionId,
    );
    final orderIndex = board.sections.indexWhere(
      (item) => item.id == command.sectionId,
    );
    await workspaceRepository.deletePlanSection(
      command.projectId,
      command.sectionId,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () async {
          await workspaceRepository.createPlanSection(
            command.projectId,
            PlanSection(
              id: section.id,
              name: section.name,
              orderIndex: orderIndex < 0 ? 0 : orderIndex,
              shotIds: const [],
            ),
          );
          for (final shotId in section.shotIds) {
            await workspaceRepository.assignShotToSection(
              command.projectId,
              shotId,
              section.id,
            );
          }
          if (section.shotIds.isNotEmpty) {
            await workspaceRepository.reorderSectionShots(
              command.projectId,
              section.id,
              section.shotIds,
            );
          }
        },
        redo: () => workspaceRepository.deletePlanSection(
          command.projectId,
          command.sectionId,
        ),
      ),
    );
  }

  Future<CommandResult> _handleReorderPlanSectionShots(
    ReorderPlanSectionShotsCommand command,
  ) async {
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final section = board.sections.firstWhere(
      (item) => item.id == command.sectionId,
    );
    final previousIds = [...section.shotIds];
    await workspaceRepository.reorderSectionShots(
      command.projectId,
      command.sectionId,
      command.orderedShotIds,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.reorderSectionShots(
          command.projectId,
          command.sectionId,
          previousIds,
        ),
        redo: () => workspaceRepository.reorderSectionShots(
          command.projectId,
          command.sectionId,
          command.orderedShotIds,
        ),
      ),
    );
  }

  Future<CommandResult> _handleUnassignShotFromPlan(
    UnassignShotFromPlanCommand command,
  ) async {
    final board = await workspaceRepository.loadPlanBoard(command.projectId);
    final previousSectionId = _findShotSectionId(board, command.shotId);
    if (previousSectionId == null) {
      return const CommandResult();
    }
    await workspaceRepository.unassignShot(command.projectId, command.shotId);
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.assignShotToSection(
          command.projectId,
          command.shotId,
          previousSectionId,
        ),
        redo: () =>
            workspaceRepository.unassignShot(command.projectId, command.shotId),
      ),
    );
  }

  Future<CommandResult> _handleCreateScene(CreateSceneCommand command) async {
    final scene = await workspaceRepository.createScene(
      projectId: command.projectId,
      insertIndex: command.insertIndex,
      name: command.name,
      numberMode: command.numberMode,
      manualNumber: command.manualNumber,
    );
    return CommandResult(
      payload: scene,
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.deleteScene(command.projectId, scene.id),
        redo: () => workspaceRepository.createScene(
          projectId: command.projectId,
          insertIndex: scene.sortIndex,
          sceneId: scene.id,
          name: scene.name,
          numberMode: scene.numberMode,
          manualNumber: scene.manualNumber,
        ),
      ),
    );
  }

  Future<CommandResult> _handleUpdateScene(UpdateSceneCommand command) async {
    final scenes = await workspaceRepository.loadScenes(command.projectId);
    final previous = scenes.firstWhere((item) => item.id == command.scene.id);
    await workspaceRepository.updateScene(command.projectId, command.scene);
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.updateScene(command.projectId, previous),
        redo: () =>
            workspaceRepository.updateScene(command.projectId, command.scene),
      ),
    );
  }

  Future<CommandResult> _handleDeleteEmptyScene(
    DeleteEmptySceneCommand command,
  ) async {
    final scenes = await workspaceRepository.loadScenes(command.projectId);
    final previous = scenes.firstWhere((item) => item.id == command.sceneId);
    await workspaceRepository.deleteScene(command.projectId, command.sceneId);
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.createScene(
          projectId: command.projectId,
          insertIndex: previous.sortIndex,
          sceneId: previous.id,
          name: previous.name,
          numberMode: previous.numberMode,
          manualNumber: previous.manualNumber,
        ),
        redo: () =>
            workspaceRepository.deleteScene(command.projectId, command.sceneId),
      ),
    );
  }

  Future<CommandResult> _handleReorderScenes(ReorderScenesCommand command) async {
    final scenes = await workspaceRepository.loadScenes(command.projectId);
    final previous = scenes.map((item) => item.id).toList();
    await workspaceRepository.reorderScenes(
      command.projectId,
      command.orderedSceneIds,
    );
    return CommandResult(
      historyEntry: HistoryEntry(
        label: command.label,
        createdAt: DateTime.now(),
        undo: () => workspaceRepository.reorderScenes(command.projectId, previous),
        redo: () => workspaceRepository.reorderScenes(
          command.projectId,
          command.orderedSceneIds,
        ),
      ),
    );
  }

  List<ShotRecord> _detectReusableScaffoldShots(List<ShotRecord> shots) {
    final reusable = <ShotRecord>[];
    for (final shot in shots) {
      if (!_isScaffoldShot(shot)) {
        break;
      }
      reusable.add(shot);
    }
    return reusable;
  }

  bool _isScaffoldShot(ShotRecord shot) {
    final hasCustomData = shot.customFieldValues.values.any((value) {
      if (value == null) {
        return false;
      }
      if (value is AssetRef) {
        return true;
      }
      return value.toString().trim().isNotEmpty;
    });
    return shot.frameImage == null &&
        shot.referenceImage == null &&
        !hasCustomData &&
        shot.durationSec == 0 &&
        shot.content.trim().isEmpty &&
        shot.dialogue.trim().isEmpty &&
        shot.notes.trim().isEmpty &&
        shot.sceneExpectation.trim().isEmpty &&
        shot.audio.trim().isEmpty &&
        shot.shotSize.trim() == '中景' &&
        shot.cameraAngle.trim() == '平视' &&
        shot.cameraMove.trim() == '固定' &&
        shot.cameraRig.trim() == '手持' &&
        shot.focalLength.trim() == '35mm' &&
        int.tryParse(shot.shotNo.trim()) != null;
  }

  Future<void> _overwriteShotFromSeed({
    required String projectId,
    required String shotId,
    required ShotRecord seed,
  }) async {
    final updates = <String, Object?>{
      'shotNo': seed.shotNo,
      'shotSize': seed.shotSize,
      'durationSec': seed.durationSec,
      'content': seed.content,
      'dialogue': seed.dialogue,
      'notes': seed.notes,
      'sceneExpectation': seed.sceneExpectation,
      'audio': seed.audio,
      'cameraAngle': seed.cameraAngle,
      'cameraMove': seed.cameraMove,
      'cameraRig': seed.cameraRig,
      'focalLength': seed.focalLength,
    };
    for (final entry in updates.entries) {
      await workspaceRepository.updateShotField(
        projectId,
        shotId,
        entry.key,
        entry.value,
      );
    }
  }

  Future<void> _restoreShotSnapshot({
    required String projectId,
    required ShotRecord shot,
  }) async {
    final updates = <String, Object?>{
      'shotNo': shot.shotNo,
      'shotSize': shot.shotSize,
      'durationSec': shot.durationSec,
      'content': shot.content,
      'dialogue': shot.dialogue,
      'notes': shot.notes,
      'sceneExpectation': shot.sceneExpectation,
      'audio': shot.audio,
      'cameraAngle': shot.cameraAngle,
      'cameraMove': shot.cameraMove,
      'cameraRig': shot.cameraRig,
      'focalLength': shot.focalLength,
      'frameImage': shot.frameImage == null
          ? null
          : AssetRefPayload.fromAssetRef(shot.frameImage!),
      'referenceImage': shot.referenceImage == null
          ? null
          : AssetRefPayload.fromAssetRef(shot.referenceImage!),
      ...{
        for (final entry in shot.customFieldValues.entries)
          entry.key: entry.value is AssetRef
              ? AssetRefPayload.fromAssetRef(entry.value as AssetRef)
              : entry.value,
      },
    };
    for (final entry in updates.entries) {
      await workspaceRepository.updateShotField(
        projectId,
        shot.id,
        entry.key,
        entry.value,
      );
    }
  }

  Future<void> _restorePlanAssignments({
    required String projectId,
    required PlanBoard board,
    required Set<String> shotIds,
  }) async {
    for (final section in board.sections) {
      final sectionShotIds = section.shotIds
          .where((shotId) => shotIds.contains(shotId))
          .toList();
      if (sectionShotIds.isEmpty) {
        continue;
      }
      for (final shotId in sectionShotIds) {
        await workspaceRepository.assignShotToSection(
          projectId,
          shotId,
          section.id,
        );
      }
      await workspaceRepository.reorderSectionShots(
        projectId,
        section.id,
        section.shotIds,
      );
    }
  }

  Future<void> _undoImportedSeedShotsBatch({
    required String projectId,
    required List<ShotRecord> originalShots,
    required PlanBoard originalPlanBoard,
    required List<ShotRecord> createdShots,
    required List<String> reusedShotIds,
    required List<ShotRecord> deletedScaffolds,
  }) async {
    for (final shot in createdShots.reversed) {
      await workspaceRepository.deleteShot(projectId, shot.id);
    }
    for (final shot in deletedScaffolds) {
      await workspaceRepository.createShot(projectId, seedShot: shot);
    }
    final originalById = {for (final shot in originalShots) shot.id: shot};
    for (final shotId in reusedShotIds) {
      final snapshot = originalById[shotId];
      if (snapshot != null) {
        await _restoreShotSnapshot(projectId: projectId, shot: snapshot);
      }
    }
    await workspaceRepository.reorderShots(
      projectId,
      originalShots.map((shot) => shot.id).toList(),
    );
    await _restorePlanAssignments(
      projectId: projectId,
      board: originalPlanBoard,
      shotIds: {
        ...reusedShotIds,
        ...deletedScaffolds.map((shot) => shot.id),
      },
    );
  }

  Future<void> _redoImportedSeedShotsBatch({
    required String projectId,
    required List<ShotRecord> originalShots,
    required PlanBoard originalPlanBoard,
    required List<ShotRecord> effectiveSeeds,
    required List<ShotRecord> reusableScaffolds,
    required List<String> reusedShotIds,
    required List<ShotRecord> deletedScaffolds,
    required List<ShotRecord> sourceSeeds,
  }) async {
    for (var index = 0; index < sourceSeeds.length; index++) {
      final seed = sourceSeeds[index];
      if (index < reusableScaffolds.length) {
        await _overwriteShotFromSeed(
          projectId: projectId,
          shotId: reusableScaffolds[index].id,
          seed: seed,
        );
        continue;
      }
      final effectiveSeed = effectiveSeeds[index - reusableScaffolds.length];
      await workspaceRepository.createShot(projectId, seedShot: effectiveSeed);
    }
    for (final scaffold in reusableScaffolds.skip(sourceSeeds.length)) {
      await workspaceRepository.deleteShot(projectId, scaffold.id);
    }
    await _restorePlanAssignments(
      projectId: projectId,
      board: originalPlanBoard,
      shotIds: reusedShotIds.toSet(),
    );
    final createdIds = effectiveSeeds.map((shot) => shot.id).toSet();
    final finalIds = <String>[
      for (final shot in originalShots)
        if (!deletedScaffolds.any((item) => item.id == shot.id) ||
            reusedShotIds.contains(shot.id))
          shot.id,
      ...createdIds,
    ];
    await workspaceRepository.reorderShots(projectId, finalIds);
  }

  Object? _readShotFieldValue(ShotRecord shot, String fieldKey) {
    return switch (fieldKey) {
      'shotNo' => shot.shotNo,
      'frameImage' => shot.frameImage,
      'referenceImage' => shot.referenceImage,
      'shotSize' => shot.shotSize,
      'durationSec' => shot.durationSec,
      'content' => shot.content,
      'dialogue' => shot.dialogue,
      'notes' => shot.notes,
      'sceneExpectation' => shot.sceneExpectation,
      'audio' => shot.audio,
      'cameraAngle' => shot.cameraAngle,
      'cameraMove' => shot.cameraMove,
      'cameraRig' => shot.cameraRig,
      'focalLength' => shot.focalLength,
      _ => shot.customFieldValues[fieldKey],
    };
  }

  ColumnPreset _appendFieldToActivePreset(
    ColumnPreset preset,
    String fieldKey,
  ) {
    final visible = [...preset.visibleFieldKeys];
    if (!visible.contains(fieldKey)) {
      visible.add(fieldKey);
    }
    final order = [...preset.fieldOrderKeys];
    if (!order.contains(fieldKey)) {
      order.add(fieldKey);
    }
    return preset.copyWith(
      visibleFieldKeys: visible,
      fieldOrderKeys: order,
      updatedAt: DateTime.now(),
    );
  }

  String? _findShotSectionId(PlanBoard board, String shotId) {
    for (final section in board.sections) {
      if (section.shotIds.contains(shotId)) {
        return section.id;
      }
    }
    return null;
  }

  Future<String> _fingerprintFile(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      throw StateError('Asset source not found: $sourcePath');
    }
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }
}
