import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/providers.dart';
import '../../../core/history/history_entry.dart';
import '../../ai_storyboard/domain/ai_shot_draft.dart';
import '../domain/models/asset_ref.dart';
import '../domain/models/board_preset.dart';
import '../domain/models/column_preset.dart';
import '../domain/models/custom_column_definition.dart';
import '../domain/models/shot_record.dart';
import '../domain/models/shot_fields.dart';
import '../domain/models/storyboard_row.dart';
import '../domain/models/storyboard_scene.dart';
import '../domain/queries/project_workspace_snapshot.dart';

class ProjectWorkspaceController
    extends FamilyNotifier<ProjectWorkspaceSnapshot, String> {
  @override
  ProjectWorkspaceSnapshot build(String projectId) {
    Future.microtask(() => load(projectId));
    return ProjectWorkspaceSnapshot.empty(projectId);
  }

  Future<void> load(String projectId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    try {
      final bundle = await repo.loadBundle(projectId);
      final shots = await repo.loadShots(projectId);
      final columnPreset = await repo.loadColumnPreset(projectId);
      final columnTemplates = await repo.loadColumnTemplates(projectId);
      final customColumns = await repo.loadCustomColumns(projectId);
      final fixedFieldCustomOptions = await repo.loadFixedFieldCustomOptions(
        projectId,
      );
      final scenes = await repo.loadScenes(projectId);
      final boardPreset = await repo.loadBoardPreset(projectId);
      final planBoard = await repo.loadPlanBoard(projectId);
      final callSheet = await repo.loadCallSheet(projectId);
      state = ProjectWorkspaceSnapshot(
        bundle: bundle,
        shots: shots,
        columnPreset: columnPreset,
        columnTemplates: columnTemplates,
        customColumns: customColumns,
        fixedFieldCustomOptions: fixedFieldCustomOptions,
        scenes: scenes,
        storyboardRows: _buildStoryboardRows(scenes, shots),
        boardPreset: boardPreset,
        planBoard: planBoard,
        callSheet: callSheet,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> createShot({int? insertIndex, String? sceneId}) async {
    final created = await ref
        .read(workspaceCommandServiceProvider)
        .createShot(arg, insertIndex: insertIndex, sceneId: sceneId);
    final nextShots = [...state.shots];
    final targetIndex =
        insertIndex?.clamp(0, nextShots.length) ?? created.orderIndex;
    nextShots.insert(targetIndex, created);
    state = state.copyWith(
      shots: _normalizeOrderIndexes(nextShots),
      storyboardRows: _buildStoryboardRows(
        state.scenes,
        _normalizeOrderIndexes(nextShots),
      ),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> deleteShot(String shotId) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deleteShot(projectId: arg, shotId: shotId);
    state = state.copyWith(
      shots: _normalizeOrderIndexes(
        state.shots.where((shot) => shot.id != shotId).toList(),
      ),
      storyboardRows: _buildStoryboardRows(
        state.scenes,
        _normalizeOrderIndexes(
          state.shots.where((shot) => shot.id != shotId).toList(),
        ),
      ),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> reorderShots(int oldIndex, int newIndex) async {
    final shots = state.shots;
    if (oldIndex < 0 || oldIndex >= shots.length) {
      return;
    }
    final safeTarget = newIndex > oldIndex ? newIndex - 1 : newIndex;
    await ref
        .read(workspaceCommandServiceProvider)
        .reorderShots(
          projectId: arg,
          shotId: shots[oldIndex].id,
          toIndex: safeTarget,
        );
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final nextShots = await repo.loadShots(arg);
    state = state.copyWith(
      shots: nextShots,
      storyboardRows: _buildStoryboardRows(state.scenes, nextShots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> reorderShotIds(List<String> orderedShotIds) async {
    if (orderedShotIds.isEmpty) {
      return;
    }
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    await repo.reorderShots(arg, orderedShotIds);
    final nextShots = await repo.loadShots(arg);
    state = state.copyWith(
      shots: nextShots,
      storyboardRows: _buildStoryboardRows(state.scenes, nextShots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> applySceneShotStructure({
    required List<String> orderedSceneIds,
    required Map<String, List<String>> orderedShotIdsByScene,
  }) async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    await repo.applySceneShotStructure(
      projectId: arg,
      orderedSceneIds: orderedSceneIds,
      orderedShotIdsByScene: orderedShotIdsByScene,
    );
    final scenes = await repo.loadScenes(arg);
    final shots = await repo.loadShots(arg);
    state = state.copyWith(
      scenes: scenes,
      shots: shots,
      storyboardRows: _buildStoryboardRows(scenes, shots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> moveShotsToScene({
    required List<String> shotIds,
    required String targetSceneId,
    int? targetIndex,
  }) async {
    if (shotIds.isEmpty) {
      return;
    }
    final movingShotIdSet = shotIds.toSet();
    final orderedShots = [...state.shots]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final orderedScenes = [...state.scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final orderedSceneIds = orderedScenes.map((scene) => scene.id).toList();
    final orderedShotIdsByScene = <String, List<String>>{
      for (final scene in orderedScenes) scene.id: <String>[],
    };
    for (final shot in orderedShots) {
      if (movingShotIdSet.contains(shot.id)) {
        continue;
      }
      orderedShotIdsByScene
          .putIfAbsent(shot.sceneId, () => <String>[])
          .add(shot.id);
    }
    final movingShots = [
      for (final shot in orderedShots)
        if (movingShotIdSet.contains(shot.id)) shot,
    ];
    if (movingShots.isEmpty) {
      return;
    }

    final targetShots = orderedShotIdsByScene.putIfAbsent(
      targetSceneId,
      () => <String>[],
    );
    final originalTargetShotIds = [
      for (final shot in orderedShots)
        if (shot.sceneId == targetSceneId) shot.id,
    ];
    final originalTargetIndex = (targetIndex ?? originalTargetShotIds.length)
        .clamp(0, originalTargetShotIds.length);
    final removedBeforeTarget = originalTargetShotIds
        .take(originalTargetIndex)
        .where(movingShotIdSet.contains)
        .length;
    final safeTargetIndex = (originalTargetIndex - removedBeforeTarget).clamp(
      0,
      targetShots.length,
    );
    targetShots.insertAll(safeTargetIndex, movingShots.map((shot) => shot.id));

    await applySceneShotStructureWithHistory(
      orderedSceneIds: orderedSceneIds,
      orderedShotIdsByScene: orderedShotIdsByScene,
    );
  }

  Future<void> moveShotToScene({
    required String shotId,
    required String targetSceneId,
    int? targetIndex,
  }) {
    return moveShotsToScene(
      shotIds: [shotId],
      targetSceneId: targetSceneId,
      targetIndex: targetIndex,
    );
  }

  Future<void> applySceneShotStructureWithHistory({
    required List<String> orderedSceneIds,
    required Map<String, List<String>> orderedShotIdsByScene,
  }) async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final previousScenes = await repo.loadScenes(arg);
    final previousOrderedSceneIds = [
      ...previousScenes..sort((a, b) => a.sortIndex.compareTo(b.sortIndex)),
    ].map((scene) => scene.id).toList();
    final previousShots = await repo.loadShots(arg);
    final previousOrderedShotIdsByScene = <String, List<String>>{
      for (final sceneId in previousOrderedSceneIds) sceneId: <String>[],
    };
    for (final shot in [
      ...previousShots,
    ]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex))) {
      previousOrderedShotIdsByScene
          .putIfAbsent(shot.sceneId, () => <String>[])
          .add(shot.id);
    }

    final historyManager = ref.read(historyManagerProvider);

    await repo.applySceneShotStructure(
      projectId: arg,
      orderedSceneIds: orderedSceneIds,
      orderedShotIdsByScene: orderedShotIdsByScene,
    );

    historyManager.record(
      HistoryEntry(
        label: 'ApplySceneShotStructure',
        createdAt: DateTime.now(),
        undo: () => repo.applySceneShotStructure(
          projectId: arg,
          orderedSceneIds: previousOrderedSceneIds,
          orderedShotIdsByScene: previousOrderedShotIdsByScene,
        ),
        redo: () => repo.applySceneShotStructure(
          projectId: arg,
          orderedSceneIds: orderedSceneIds,
          orderedShotIdsByScene: orderedShotIdsByScene,
        ),
      ),
    );

    final scenes = await repo.loadScenes(arg);
    final shots = await repo.loadShots(arg);
    state = state.copyWith(
      scenes: scenes,
      shots: shots,
      storyboardRows: _buildStoryboardRows(scenes, shots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> updateShotField({
    required String shotId,
    required String fieldKey,
    required Object? value,
  }) async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    await ref
        .read(workspaceCommandServiceProvider)
        .updateField(
          projectId: arg,
          shotId: shotId,
          fieldKey: fieldKey,
          value: value,
        );
    final updatedShot = await repo.loadShot(arg, shotId);
    final fixedFieldCustomOptions =
        fixedFieldSupportsCustomValue(fieldKey) && value is String
        ? await repo.loadFixedFieldCustomOptions(arg)
        : state.fixedFieldCustomOptions;
    final customColumns = fieldKey.startsWith('custom:')
        ? await repo.loadCustomColumns(arg)
        : state.customColumns;
    state = state.copyWith(
      shots: _replaceShot(updatedShot),
      storyboardRows: _buildStoryboardRows(
        state.scenes,
        _replaceShot(updatedShot),
      ),
      fixedFieldCustomOptions: fixedFieldCustomOptions,
      customColumns: customColumns,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> importAsset({
    required String shotId,
    required String targetField,
    required String sourcePath,
    required AssetMode assetMode,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .importAsset(
          projectId: arg,
          shotId: shotId,
          targetField: targetField,
          sourcePath: sourcePath,
          assetMode: assetMode,
        );
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final updatedShot = await repo.loadShot(arg, shotId);
    state = state.copyWith(
      shots: _replaceShot(updatedShot),
      storyboardRows: _buildStoryboardRows(
        state.scenes,
        _replaceShot(updatedShot),
      ),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> relinkAsset({
    required String shotId,
    required String targetField,
    required String newPath,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .relinkAsset(
          projectId: arg,
          shotId: shotId,
          targetField: targetField,
          newPath: newPath,
        );
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final updatedShot = await repo.loadShot(arg, shotId);
    state = state.copyWith(
      shots: _replaceShot(updatedShot),
      storyboardRows: _buildStoryboardRows(
        state.scenes,
        _replaceShot(updatedShot),
      ),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> assignShotToPlan({
    required String shotId,
    required String sectionId,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .assignShotToPlan(projectId: arg, shotId: shotId, sectionId: sectionId);
    await _refreshPlanBoard();
  }

  Future<void> unassignShotFromPlan({required String shotId}) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .unassignShotFromPlan(projectId: arg, shotId: shotId);
    await _refreshPlanBoard();
  }

  Future<void> updateBoardPreset(BoardPreset preset) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .updateBoardPreset(arg, preset);
    state = state.copyWith(
      boardPreset: preset,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> updateColumnPreset(ColumnPreset preset) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .updateColumnPreset(arg, preset);
    state = state.copyWith(
      columnPreset: preset,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> createPlanSection(String name) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .createPlanSection(arg, name);
    await _refreshPlanBoard();
  }

  Future<void> renamePlanSection({
    required String sectionId,
    required String name,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .renamePlanSection(projectId: arg, sectionId: sectionId, name: name);
    await _refreshPlanBoard();
  }

  Future<void> deletePlanSection({required String sectionId}) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deletePlanSection(projectId: arg, sectionId: sectionId);
    await _refreshPlanBoard();
  }

  Future<void> reorderPlanSectionShots({
    required String sectionId,
    required List<String> orderedShotIds,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .reorderPlanSectionShots(
          projectId: arg,
          sectionId: sectionId,
          orderedShotIds: orderedShotIds,
        );
    await _refreshPlanBoard();
  }

  Future<void> batchUpdateShotField({
    required List<String> shotIds,
    required String fieldKey,
    required Object? value,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .batchUpdateField(
          projectId: arg,
          shotIds: shotIds,
          fieldKey: fieldKey,
          value: value,
        );
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final updatedShots = await Future.wait(
      shotIds.map((shotId) => repo.loadShot(arg, shotId)),
    );
    final fixedFieldCustomOptions =
        fixedFieldSupportsCustomValue(fieldKey) && value is String
        ? await repo.loadFixedFieldCustomOptions(arg)
        : state.fixedFieldCustomOptions;
    final customColumns = fieldKey.startsWith('custom:')
        ? await repo.loadCustomColumns(arg)
        : state.customColumns;
    state = state.copyWith(
      shots: _replaceShots(updatedShots),
      storyboardRows: _buildStoryboardRows(
        state.scenes,
        _replaceShots(updatedShots),
      ),
      fixedFieldCustomOptions: fixedFieldCustomOptions,
      customColumns: customColumns,
      isLoading: false,
      clearError: true,
    );
  }

  Future<StoryboardScene> createScene({
    required int insertIndex,
    String name = '',
  }) async {
    final scene = await ref
        .read(workspaceCommandServiceProvider)
        .createScene(projectId: arg, insertIndex: insertIndex, name: name);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final scenes = await repo.loadScenes(arg);
    state = state.copyWith(
      scenes: scenes,
      storyboardRows: _buildStoryboardRows(scenes, state.shots),
      isLoading: false,
      clearError: true,
    );
    return scene;
  }

  Future<void> updateScene(StoryboardScene scene) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .updateScene(projectId: arg, scene: scene);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final scenes = await repo.loadScenes(arg);
    state = state.copyWith(
      scenes: scenes,
      storyboardRows: _buildStoryboardRows(scenes, state.shots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> deleteEmptyScene(String sceneId) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deleteEmptyScene(projectId: arg, sceneId: sceneId);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final scenes = await repo.loadScenes(arg);
    state = state.copyWith(
      scenes: scenes,
      storyboardRows: _buildStoryboardRows(scenes, state.shots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> reorderScenes(List<String> orderedSceneIds) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .reorderScenes(projectId: arg, orderedSceneIds: orderedSceneIds);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final scenes = await repo.loadScenes(arg);
    state = state.copyWith(
      scenes: scenes,
      storyboardRows: _buildStoryboardRows(scenes, state.shots),
      isLoading: false,
      clearError: true,
    );
  }

  List<StoryboardRow> _buildStoryboardRows(
    List<StoryboardScene> scenes,
    List<ShotRecord> shots,
  ) {
    if (scenes.isEmpty) {
      return const <StoryboardRow>[];
    }
    final shotsByScene = <String, List<ShotRecord>>{};
    for (final shot in shots) {
      shotsByScene.putIfAbsent(shot.sceneId, () => <ShotRecord>[]).add(shot);
    }
    final orderedScenes = [...scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final hideSingleDefaultScene =
        orderedScenes.length == 1 &&
        orderedScenes.first.name.trim().isEmpty &&
        orderedScenes.first.numberMode == StoryboardSceneNumberMode.auto;
    final rows = <StoryboardRow>[];
    for (var index = 0; index < orderedScenes.length; index++) {
      final scene = orderedScenes[index];
      final sceneShots = [...(shotsByScene[scene.id] ?? const <ShotRecord>[])]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      if (!hideSingleDefaultScene) {
        rows.add(
          SceneHeaderRow(
            scene: scene,
            autoNumber: index + 1,
            shotCount: sceneShots.length,
          ),
        );
      }
      for (var shotIndex = 0; shotIndex < sceneShots.length; shotIndex++) {
        rows.add(
          StoryboardShotRow(
            scene: scene,
            autoNumber: index + 1,
            shot: sceneShots[shotIndex],
            sceneShotIndex: shotIndex,
          ),
        );
      }
    }
    return rows;
  }

  Future<void> createCustomColumn({
    required String name,
    required CustomColumnType type,
    BuiltInEnumSource? enumSource,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .createCustomColumn(
          projectId: arg,
          name: name,
          type: type,
          enumSource: enumSource,
        );
    await _refreshColumnArtifacts();
  }

  Future<void> renameCustomColumn({
    required String columnId,
    required String name,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .renameCustomColumn(projectId: arg, columnId: columnId, name: name);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final customColumns = await repo.loadCustomColumns(arg);
    state = state.copyWith(
      customColumns: customColumns,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> deleteCustomColumn(String columnId) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deleteCustomColumn(projectId: arg, columnId: columnId);
    await _refreshColumnArtifacts(refreshShots: true);
  }

  Future<void> deleteFixedFieldCustomOption({
    required String fieldKey,
    required String option,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deleteFixedFieldOption(
          projectId: arg,
          fieldKey: fieldKey,
          option: option,
        );
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final fixedFieldCustomOptions = await repo.loadFixedFieldCustomOptions(arg);
    state = state.copyWith(
      fixedFieldCustomOptions: fixedFieldCustomOptions,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> deleteCustomColumnOption({
    required String columnId,
    required String option,
  }) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deleteCustomColumnOption(
          projectId: arg,
          columnId: columnId,
          option: option,
        );
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final customColumns = await repo.loadCustomColumns(arg);
    state = state.copyWith(
      customColumns: customColumns,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> saveColumnTemplate(String name) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .saveColumnTemplate(projectId: arg, name: name);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final templates = await repo.loadColumnTemplates(arg);
    state = state.copyWith(
      columnTemplates: templates,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> applyColumnTemplate(String templateId) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .applyColumnTemplate(projectId: arg, templateId: templateId);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final preset = await repo.loadColumnPreset(arg);
    state = state.copyWith(
      columnPreset: preset,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> deleteColumnTemplate(String templateId) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .deleteColumnTemplate(projectId: arg, templateId: templateId);
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final templates = await repo.loadColumnTemplates(arg);
    state = state.copyWith(
      columnTemplates: templates,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> importAiDrafts(List<AiShotDraft> drafts) async {
    if (drafts.isEmpty) {
      return;
    }
    final seedShots = [
      for (var index = 0; index < drafts.length; index++)
        _seedShotFromAiDraft(
          drafts[index],
          orderIndex: state.shots.length + index,
        ),
    ];
    final importedShots = await ref
        .read(workspaceCommandServiceProvider)
        .importSeedShotsBatch(arg, seedShots: seedShots);
    state = state.copyWith(
      shots: importedShots,
      storyboardRows: _buildStoryboardRows(state.scenes, importedShots),
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> undo() async {
    await ref.read(workspaceCommandServiceProvider).undo(arg);
    await load(arg);
  }

  Future<void> redo() async {
    await ref.read(workspaceCommandServiceProvider).redo(arg);
    await load(arg);
  }

  Future<void> _refreshPlanBoard() async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final planBoard = await repo.loadPlanBoard(arg);
    state = state.copyWith(
      planBoard: planBoard,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> _refreshColumnArtifacts({bool refreshShots = false}) async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final columnPreset = await repo.loadColumnPreset(arg);
    final columnTemplates = await repo.loadColumnTemplates(arg);
    final customColumns = await repo.loadCustomColumns(arg);
    final shots = refreshShots ? await repo.loadShots(arg) : state.shots;
    state = state.copyWith(
      shots: shots,
      columnPreset: columnPreset,
      columnTemplates: columnTemplates,
      customColumns: customColumns,
      storyboardRows: _buildStoryboardRows(state.scenes, shots),
      isLoading: false,
      clearError: true,
    );
  }

  List<ShotRecord> _replaceShot(ShotRecord shot) {
    return [
      for (final current in state.shots)
        if (current.id == shot.id) shot else current,
    ];
  }

  List<ShotRecord> _replaceShots(List<ShotRecord> nextShots) {
    if (nextShots.isEmpty) {
      return state.shots;
    }
    final byId = {for (final shot in nextShots) shot.id: shot};
    return [for (final current in state.shots) byId[current.id] ?? current];
  }

  List<ShotRecord> _normalizeOrderIndexes(List<ShotRecord> shots) {
    return [
      for (final entry in shots.asMap().entries)
        entry.value.copyWith(orderIndex: entry.key),
    ];
  }

  ShotRecord _seedShotFromAiDraft(
    AiShotDraft draft, {
    required int orderIndex,
  }) {
    return ShotRecord(
      id: '',
      orderIndex: orderIndex,
      sceneId: state.scenes.isEmpty ? 'default-scene' : state.scenes.first.id,
      shotNo: draft.shotNo,
      shotSize: draft.shotSize,
      durationSec: draft.durationSec,
      content: draft.content,
      dialogue: draft.dialogue,
      notes: draft.notes,
      sceneExpectation: draft.sceneExpectation,
      audio: draft.audio,
      cameraAngle: draft.cameraAngle,
      cameraMove: draft.cameraMove,
      cameraRig: draft.cameraRig,
      focalLength: draft.focalLength,
    );
  }
}
