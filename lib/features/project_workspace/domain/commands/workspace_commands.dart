import '../../../../core/command/app_command.dart';
import '../models/asset_ref.dart';
import '../models/board_preset.dart';
import '../models/column_preset.dart';
import '../models/column_template.dart';
import '../models/custom_column_definition.dart';

enum ProjectHistoryScope { workspace }

class AssetRefPayload {
  const AssetRefPayload({
    required this.mode,
    required this.uri,
    required this.fingerprint,
    required this.missingState,
    this.width,
    this.height,
    this.bytes,
  });

  final AssetMode mode;
  final String uri;
  final String fingerprint;
  final MissingState missingState;
  final int? width;
  final int? height;
  final int? bytes;

  AssetRef toAssetRef() {
    return AssetRef(
      mode: mode,
      uri: uri,
      fingerprint: fingerprint,
      missingState: missingState,
      width: width,
      height: height,
      bytes: bytes,
    );
  }

  factory AssetRefPayload.fromAssetRef(AssetRef asset) {
    return AssetRefPayload(
      mode: asset.mode,
      uri: asset.uri,
      fingerprint: asset.fingerprint,
      missingState: asset.missingState,
      width: asset.width,
      height: asset.height,
      bytes: asset.bytes,
    );
  }
}

class ShotFieldUpdate {
  const ShotFieldUpdate({
    required this.projectId,
    required this.shotId,
    required this.fieldKey,
    required this.value,
    this.scope = ProjectHistoryScope.workspace,
  });

  final String projectId;
  final String shotId;
  final String fieldKey;
  final Object? value;
  final ProjectHistoryScope scope;
}

class BatchFieldUpdate {
  const BatchFieldUpdate({
    required this.shotId,
    required this.fieldKey,
    required this.value,
  });

  final String shotId;
  final String fieldKey;
  final Object? value;
}

class CreateShotCommand extends AppCommand {
  const CreateShotCommand({required this.projectId});

  final String projectId;

  @override
  String get label => 'CreateShot';
}

class UpdateShotFieldCommand extends AppCommand {
  const UpdateShotFieldCommand({
    required this.projectId,
    required this.shotId,
    required this.fieldKey,
    required this.value,
  });

  final String projectId;
  final String shotId;
  final String fieldKey;
  final Object? value;

  @override
  String get label => 'UpdateShotField';
}

class BatchUpdateShotFieldCommand extends AppCommand {
  const BatchUpdateShotFieldCommand({
    required this.projectId,
    required this.updates,
  });

  final String projectId;
  final List<BatchFieldUpdate> updates;

  @override
  String get label => 'BatchUpdateShotField';
}

class ReorderShotCommand extends AppCommand {
  const ReorderShotCommand({
    required this.projectId,
    required this.shotId,
    required this.toIndex,
  });

  final String projectId;
  final String shotId;
  final int toIndex;

  @override
  String get label => 'ReorderShot';
}

class AssignShotToPlanCommand extends AppCommand {
  const AssignShotToPlanCommand({
    required this.projectId,
    required this.shotId,
    required this.sectionId,
  });

  final String projectId;
  final String shotId;
  final String sectionId;

  @override
  String get label => 'AssignShotToPlan';
}

class ImportAssetCommand extends AppCommand {
  const ImportAssetCommand({
    required this.projectId,
    required this.shotId,
    required this.sourcePath,
    required this.assetMode,
    required this.managedTargetPath,
    required this.targetField,
    required this.fingerprint,
  });

  final String projectId;
  final String shotId;
  final String sourcePath;
  final AssetMode assetMode;
  final String managedTargetPath;
  final String targetField;
  final String fingerprint;

  @override
  String get label => 'ImportAsset';
}

class RelinkAssetCommand extends AppCommand {
  const RelinkAssetCommand({
    required this.projectId,
    required this.shotId,
    required this.targetField,
    required this.newPath,
  });

  final String projectId;
  final String shotId;
  final String targetField;
  final String newPath;

  @override
  String get label => 'RelinkAsset';
}

class UpdateViewPresetCommand extends AppCommand {
  const UpdateViewPresetCommand({
    required this.projectId,
    this.boardPreset,
    this.columnPreset,
  });

  final String projectId;
  final BoardPreset? boardPreset;
  final ColumnPreset? columnPreset;

  @override
  String get label => 'UpdateViewPreset';
}

class CreateCustomColumnCommand extends AppCommand {
  const CreateCustomColumnCommand({
    required this.projectId,
    required this.name,
    required this.type,
    this.enumSource,
  });

  final String projectId;
  final String name;
  final CustomColumnType type;
  final BuiltInEnumSource? enumSource;

  @override
  String get label => 'CreateCustomColumn';
}

class RenameCustomColumnCommand extends AppCommand {
  const RenameCustomColumnCommand({
    required this.projectId,
    required this.columnId,
    required this.name,
  });

  final String projectId;
  final String columnId;
  final String name;

  @override
  String get label => 'RenameCustomColumn';
}

class DeleteCustomColumnCommand extends AppCommand {
  const DeleteCustomColumnCommand({
    required this.projectId,
    required this.columnId,
  });

  final String projectId;
  final String columnId;

  @override
  String get label => 'DeleteCustomColumn';
}

class SaveColumnTemplateCommand extends AppCommand {
  const SaveColumnTemplateCommand({
    required this.projectId,
    required this.name,
  });

  final String projectId;
  final String name;

  @override
  String get label => 'SaveColumnTemplate';
}

class ApplyColumnTemplateCommand extends AppCommand {
  const ApplyColumnTemplateCommand({
    required this.projectId,
    required this.templateId,
  });

  final String projectId;
  final String templateId;

  @override
  String get label => 'ApplyColumnTemplate';
}

class DeleteColumnTemplateCommand extends AppCommand {
  const DeleteColumnTemplateCommand({
    required this.projectId,
    required this.templateId,
  });

  final String projectId;
  final String templateId;

  @override
  String get label => 'DeleteColumnTemplate';
}

class AddFixedFieldOptionCommand extends AppCommand {
  const AddFixedFieldOptionCommand({
    required this.projectId,
    required this.fieldKey,
    required this.option,
  });

  final String projectId;
  final String fieldKey;
  final String option;

  @override
  String get label => 'AddFixedFieldOption';
}

class CreatePlanSectionCommand extends AppCommand {
  const CreatePlanSectionCommand({
    required this.projectId,
    required this.name,
  });

  final String projectId;
  final String name;

  @override
  String get label => 'CreatePlanSection';
}

class RenamePlanSectionCommand extends AppCommand {
  const RenamePlanSectionCommand({
    required this.projectId,
    required this.sectionId,
    required this.name,
  });

  final String projectId;
  final String sectionId;
  final String name;

  @override
  String get label => 'RenamePlanSection';
}

class DeletePlanSectionCommand extends AppCommand {
  const DeletePlanSectionCommand({
    required this.projectId,
    required this.sectionId,
  });

  final String projectId;
  final String sectionId;

  @override
  String get label => 'DeletePlanSection';
}

class ReorderPlanSectionShotsCommand extends AppCommand {
  const ReorderPlanSectionShotsCommand({
    required this.projectId,
    required this.sectionId,
    required this.orderedShotIds,
  });

  final String projectId;
  final String sectionId;
  final List<String> orderedShotIds;

  @override
  String get label => 'ReorderPlanSectionShots';
}

class UnassignShotFromPlanCommand extends AppCommand {
  const UnassignShotFromPlanCommand({
    required this.projectId,
    required this.shotId,
  });

  final String projectId;
  final String shotId;

  @override
  String get label => 'UnassignShotFromPlan';
}

class GenerateCallSheetCommand extends AppCommand {
  const GenerateCallSheetCommand({required this.projectId});

  final String projectId;

  @override
  String get label => 'GenerateCallSheet';

  @override
  bool get recordInHistory => false;
}

class ColumnTemplatePayload {
  const ColumnTemplatePayload({
    required this.id,
    required this.projectId,
    required this.name,
    required this.visibleFieldKeys,
    required this.fieldOrderKeys,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final List<String> visibleFieldKeys;
  final List<String> fieldOrderKeys;
  final DateTime updatedAt;

  ColumnTemplate toTemplate() {
    return ColumnTemplate(
      id: id,
      projectId: projectId,
      name: name,
      visibleFieldKeys: visibleFieldKeys,
      fieldOrderKeys: fieldOrderKeys,
      updatedAt: updatedAt,
    );
  }

  factory ColumnTemplatePayload.fromTemplate(ColumnTemplate template) {
    return ColumnTemplatePayload(
      id: template.id,
      projectId: template.projectId,
      name: template.name,
      visibleFieldKeys: template.visibleFieldKeys,
      fieldOrderKeys: template.fieldOrderKeys,
      updatedAt: template.updatedAt,
    );
  }
}
