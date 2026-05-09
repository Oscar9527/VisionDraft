import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/providers.dart';
import '../../ai_storyboard/domain/ai_shot_draft.dart';
import '../domain/models/asset_ref.dart';
import '../domain/models/board_preset.dart';
import '../domain/models/column_preset.dart';
import '../domain/models/custom_column_definition.dart';
import '../domain/models/shot_record.dart';
import '../domain/models/shot_fields.dart';
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
        boardPreset: boardPreset,
        planBoard: planBoard,
        callSheet: callSheet,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> createShot() async {
    final created = await ref
        .read(workspaceCommandServiceProvider)
        .createShot(arg);
    state = state.copyWith(
      shots: [...state.shots, created],
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
      fixedFieldCustomOptions: fixedFieldCustomOptions,
      customColumns: customColumns,
      isLoading: false,
      clearError: true,
    );
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
    final createdShots = <ShotRecord>[];
    for (var index = 0; index < drafts.length; index++) {
      final draft = drafts[index];
      final created = await ref
          .read(workspaceCommandServiceProvider)
          .createShot(
            arg,
            seedShot: _seedShotFromAiDraft(
              draft,
              orderIndex: state.shots.length + index,
            ),
          );
      createdShots.add(created);
    }
    state = state.copyWith(
      shots: [...state.shots, ...createdShots],
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

  ShotRecord _seedShotFromAiDraft(
    AiShotDraft draft, {
    required int orderIndex,
  }) {
    return ShotRecord(
      id: '',
      orderIndex: orderIndex,
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
