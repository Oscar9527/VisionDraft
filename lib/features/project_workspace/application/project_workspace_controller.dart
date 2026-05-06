import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/providers.dart';
import '../domain/models/asset_ref.dart';
import '../domain/models/board_preset.dart';
import '../domain/models/column_preset.dart';
import '../domain/models/custom_column_definition.dart';
import '../domain/queries/project_workspace_snapshot.dart';

class ProjectWorkspaceController
    extends FamilyNotifier<ProjectWorkspaceSnapshot, String> {
  @override
  ProjectWorkspaceSnapshot build(String projectId) {
    Future.microtask(() => load(projectId));
    return ProjectWorkspaceSnapshot.empty(projectId);
  }

  Future<void> load(String projectId) async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    final bundle = await repo.loadBundle(projectId);
    final shots = await repo.loadShots(projectId);
    final columnPreset = await repo.loadColumnPreset(projectId);
    final columnTemplates = await repo.loadColumnTemplates(projectId);
    final customColumns = await repo.loadCustomColumns(projectId);
    final fixedFieldCustomOptions =
        await repo.loadFixedFieldCustomOptions(projectId);
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
  }

  Future<void> createShot() async {
    await ref.read(workspaceCommandServiceProvider).createShot(arg);
    await load(arg);
  }

  Future<void> reorderShots(int oldIndex, int newIndex) async {
    final shots = state.shots;
    if (oldIndex < 0 || oldIndex >= shots.length) {
      return;
    }
    final safeTarget = newIndex > oldIndex ? newIndex - 1 : newIndex;
    await ref.read(workspaceCommandServiceProvider).reorderShots(
          projectId: arg,
          shotId: shots[oldIndex].id,
          toIndex: safeTarget,
        );
    await load(arg);
  }

  Future<void> updateShotField({
    required String shotId,
    required String fieldKey,
    required Object? value,
  }) async {
    await ref.read(workspaceCommandServiceProvider).updateField(
          projectId: arg,
          shotId: shotId,
          fieldKey: fieldKey,
          value: value,
        );
    await load(arg);
  }

  Future<void> importAsset({
    required String shotId,
    required String targetField,
    required String sourcePath,
    required AssetMode assetMode,
  }) async {
    await ref.read(workspaceCommandServiceProvider).importAsset(
          projectId: arg,
          shotId: shotId,
          targetField: targetField,
          sourcePath: sourcePath,
          assetMode: assetMode,
        );
    await load(arg);
  }

  Future<void> relinkAsset({
    required String shotId,
    required String targetField,
    required String newPath,
  }) async {
    await ref.read(workspaceCommandServiceProvider).relinkAsset(
          projectId: arg,
          shotId: shotId,
          targetField: targetField,
          newPath: newPath,
        );
    await load(arg);
  }

  Future<void> assignShotToPlan({
    required String shotId,
    required String sectionId,
  }) async {
    await ref.read(workspaceCommandServiceProvider).assignShotToPlan(
          projectId: arg,
          shotId: shotId,
          sectionId: sectionId,
        );
    await load(arg);
  }

  Future<void> unassignShotFromPlan({
    required String shotId,
  }) async {
    final repo = ref.read(projectWorkspaceRepositoryProvider);
    await repo.unassignShot(arg, shotId);
    await load(arg);
  }

  Future<void> updateBoardPreset(BoardPreset preset) async {
    await ref.read(workspaceCommandServiceProvider).updateBoardPreset(arg, preset);
    await load(arg);
  }

  Future<void> updateColumnPreset(ColumnPreset preset) async {
    await ref
        .read(workspaceCommandServiceProvider)
        .updateColumnPreset(arg, preset);
    await load(arg);
  }

  Future<void> createPlanSection(String name) async {
    await ref.read(workspaceCommandServiceProvider).createPlanSection(arg, name);
    await load(arg);
  }

  Future<void> renamePlanSection({
    required String sectionId,
    required String name,
  }) async {
    await ref.read(workspaceCommandServiceProvider).renamePlanSection(
          projectId: arg,
          sectionId: sectionId,
          name: name,
        );
    await load(arg);
  }

  Future<void> reorderPlanSectionShots({
    required String sectionId,
    required List<String> orderedShotIds,
  }) async {
    await ref.read(workspaceCommandServiceProvider).reorderPlanSectionShots(
          projectId: arg,
          sectionId: sectionId,
          orderedShotIds: orderedShotIds,
        );
    await load(arg);
  }

  Future<void> batchUpdateShotField({
    required List<String> shotIds,
    required String fieldKey,
    required Object? value,
  }) async {
    await ref.read(workspaceCommandServiceProvider).batchUpdateField(
          projectId: arg,
          shotIds: shotIds,
          fieldKey: fieldKey,
          value: value,
        );
    await load(arg);
  }

  Future<void> createCustomColumn({
    required String name,
    required CustomColumnType type,
    BuiltInEnumSource? enumSource,
  }) async {
    await ref.read(workspaceCommandServiceProvider).createCustomColumn(
          projectId: arg,
          name: name,
          type: type,
          enumSource: enumSource,
        );
    await load(arg);
  }

  Future<void> renameCustomColumn({
    required String columnId,
    required String name,
  }) async {
    await ref.read(workspaceCommandServiceProvider).renameCustomColumn(
          projectId: arg,
          columnId: columnId,
          name: name,
        );
    await load(arg);
  }

  Future<void> deleteCustomColumn(String columnId) async {
    await ref.read(workspaceCommandServiceProvider).deleteCustomColumn(
          projectId: arg,
          columnId: columnId,
        );
    await load(arg);
  }

  Future<void> saveColumnTemplate(String name) async {
    await ref.read(workspaceCommandServiceProvider).saveColumnTemplate(
          projectId: arg,
          name: name,
        );
    await load(arg);
  }

  Future<void> applyColumnTemplate(String templateId) async {
    await ref.read(workspaceCommandServiceProvider).applyColumnTemplate(
          projectId: arg,
          templateId: templateId,
        );
    await load(arg);
  }

  Future<void> deleteColumnTemplate(String templateId) async {
    await ref.read(workspaceCommandServiceProvider).deleteColumnTemplate(
          projectId: arg,
          templateId: templateId,
        );
    await load(arg);
  }

  Future<void> undo() async {
    await ref.read(workspaceCommandServiceProvider).undo(arg);
    await load(arg);
  }

  Future<void> redo() async {
    await ref.read(workspaceCommandServiceProvider).redo(arg);
    await load(arg);
  }
}
