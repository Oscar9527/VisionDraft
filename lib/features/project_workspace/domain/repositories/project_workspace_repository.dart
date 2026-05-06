import '../models/asset_ref.dart';
import '../models/board_preset.dart';
import '../models/call_sheet.dart';
import '../models/column_preset.dart';
import '../models/column_template.dart';
import '../models/custom_column_definition.dart';
import '../models/custom_field_value.dart';
import '../models/plan_board.dart';
import '../models/project_bundle.dart';
import '../models/shot_record.dart';

abstract interface class ProjectWorkspaceRepository {
  Future<ProjectBundle> loadBundle(String projectId);

  Future<List<ShotRecord>> loadShots(String projectId);

  Future<ColumnPreset> loadColumnPreset(String projectId);

  Future<List<ColumnTemplate>> loadColumnTemplates(String projectId);

  Future<List<CustomColumnDefinition>> loadCustomColumns(String projectId);

  Future<Map<String, List<String>>> loadFixedFieldCustomOptions(String projectId);

  Future<Map<String, Map<String, CustomFieldValue>>> loadCustomFieldValuesByShot(
    String projectId,
  );

  Future<BoardPreset> loadBoardPreset(String projectId);

  Future<PlanBoard> loadPlanBoard(String projectId);

  Future<CallSheet> loadCallSheet(String projectId);

  Future<ShotRecord> createShot(String projectId, {ShotRecord? seedShot});

  Future<void> deleteShot(String projectId, String shotId);

  Future<ShotRecord> updateShotField(
    String projectId,
    String shotId,
    String fieldKey,
    Object? value,
  );

  Future<void> updateCustomFieldValue({
    required String projectId,
    required String shotId,
    required String columnId,
    required Object? value,
  });

  Future<AssetRef> importManagedAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String sourcePath,
    required String managedTargetPath,
    required String fingerprint,
  });

  Future<AssetRef> attachLinkedAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String sourcePath,
    required String fingerprint,
  });

  Future<void> removeAssetRef(
    String projectId,
    String shotId,
    String targetField,
  );

  Future<AssetRef> relinkAsset({
    required String projectId,
    required String shotId,
    required String targetField,
    required String newPath,
    required String fingerprint,
  });

  Future<void> updateBoardPreset(String projectId, BoardPreset preset);

  Future<void> updateColumnPreset(String projectId, ColumnPreset preset);

  Future<CustomColumnDefinition> createCustomColumn({
    required String projectId,
    required String name,
    required CustomColumnType type,
    BuiltInEnumSource? enumSource,
    List<String>? customOptions,
    String? columnId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  Future<void> renameCustomColumn({
    required String projectId,
    required String columnId,
    required String name,
  });

  Future<void> deleteCustomColumn({
    required String projectId,
    required String columnId,
  });

  Future<void> addFixedFieldCustomOption({
    required String projectId,
    required String fieldKey,
    required String option,
  });

  Future<void> replaceFixedFieldCustomOptions({
    required String projectId,
    required Map<String, List<String>> nextOptionsByFieldKey,
  });

  Future<ColumnTemplate> saveColumnTemplate({
    required String projectId,
    required String name,
    required ColumnPreset sourcePreset,
    String? templateId,
  });

  Future<void> deleteColumnTemplate({
    required String projectId,
    required String templateId,
  });

  Future<void> assignShotToSection(
    String projectId,
    String shotId,
    String sectionId,
  );

  Future<void> unassignShot(
    String projectId,
    String shotId,
  );

  Future<void> createPlanSection(String projectId, PlanSection section);

  Future<void> deletePlanSection(String projectId, String sectionId);

  Future<void> renamePlanSection(
    String projectId,
    String sectionId,
    String name,
  );

  Future<void> reorderSectionShots(
    String projectId,
    String sectionId,
    List<String> orderedShotIds,
  );

  Future<void> reorderShots(String projectId, List<String> orderedShotIds);
}
