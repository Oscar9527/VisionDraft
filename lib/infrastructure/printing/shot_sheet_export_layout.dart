import 'dart:math' as math;

import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../../features/project_workspace/domain/models/board_preset.dart';
import '../../features/project_workspace/domain/models/export_payload.dart';
import '../../features/project_workspace/domain/models/shot_fields.dart';
import '../../features/project_workspace/domain/models/shot_record.dart';
import '../../features/project_workspace/domain/models/storyboard_scene.dart';

class ResolvedShotSheetFields {
  const ResolvedShotSheetFields({
    required this.orderedVisibleFieldKeys,
    required this.imageFieldKeys,
  });

  final List<String> orderedVisibleFieldKeys;
  final Set<String> imageFieldKeys;

  bool isImageField(String fieldKey) => imageFieldKeys.contains(fieldKey);
}

class ShotSheetSceneGroup {
  const ShotSheetSceneGroup({
    required this.showHeader,
    required this.headerLabel,
    required this.shots,
  });

  final bool showHeader;
  final String headerLabel;
  final List<ShotRecord> shots;
}

class ShotSheetResolvedLayout {
  const ShotSheetResolvedLayout({
    required this.fields,
    required this.columnWidths,
    required this.rowHeights,
    required this.sceneGroups,
    required this.hasImageFields,
  });

  final ResolvedShotSheetFields fields;
  final Map<String, double> columnWidths;
  final Map<String, double> rowHeights;
  final List<ShotSheetSceneGroup> sceneGroups;
  final bool hasImageFields;
}

class ShotSheetExportLayoutResolver {
  const ShotSheetExportLayoutResolver();

  ShotSheetResolvedLayout resolve(ExportPayload payload) {
    final fields = _resolveFields(payload);
    final columnWidths = {
      for (final fieldKey in fields.orderedVisibleFieldKeys)
        fieldKey: _sheetColumnWidthValue(payload, fieldKey, fields),
    };
    final rowHeights = {
      for (final shot in payload.shots)
        shot.id: _sheetRowHeightValue(
          payload,
          shot.id,
          fields.orderedVisibleFieldKeys,
          fields,
        ),
    };
    return ShotSheetResolvedLayout(
      fields: fields,
      columnWidths: columnWidths,
      rowHeights: rowHeights,
      sceneGroups: _buildSceneShotGroups(payload),
      hasImageFields: fields.imageFieldKeys.isNotEmpty,
    );
  }

  ResolvedShotSheetFields _resolveFields(ExportPayload payload) {
    final sourceOrder = payload.effectiveFieldOrderKeys.isNotEmpty
        ? payload.effectiveFieldOrderKeys
        : payload.columnPreset.fieldOrderKeys;
    final orderedVisible = <String>[];
    final seen = <String>{};
    for (final fieldKey in sourceOrder) {
      final isVisible =
          payload.columnPreset.visibleFieldKeys.contains(fieldKey) ||
          fieldKey == ShotFieldKey.shotNo.storageKey;
      if (!isVisible || !seen.add(fieldKey)) {
        continue;
      }
      orderedVisible.add(fieldKey);
    }
    if (!orderedVisible.contains(ShotFieldKey.shotNo.storageKey)) {
      orderedVisible.insert(0, ShotFieldKey.shotNo.storageKey);
    }

    final imageFields = <String>{};
    for (final fieldKey in orderedVisible) {
      if (fieldKey == ShotFieldKey.frameImage.storageKey ||
          fieldKey == ShotFieldKey.referenceImage.storageKey) {
        imageFields.add(fieldKey);
        continue;
      }
      if (payload.shots.any((shot) => shot.customFieldValues[fieldKey] is AssetRef)) {
        imageFields.add(fieldKey);
      }
    }

    return ResolvedShotSheetFields(
      orderedVisibleFieldKeys: orderedVisible,
      imageFieldKeys: imageFields,
    );
  }

  double _sheetColumnWidthValue(
    ExportPayload payload,
    String fieldKey,
    ResolvedShotSheetFields fields,
  ) {
    final sessionWidth = payload.effectiveColumnWidths[fieldKey];
    if (sessionWidth != null && sessionWidth > 0) {
      return sessionWidth;
    }
    final editorScale = _editorScale(payload);
    if (fields.isImageField(fieldKey)) {
      return ((fieldKey == ShotFieldKey.frameImage.storageKey ? 220 : 190) *
              editorScale)
          .toDouble();
    }
    return ((switch (fieldKey) {
          'shotNo' => 92,
          'durationSec' => 84,
          'shotSize' => 100,
          'frameImage' || 'referenceImage' => 220,
          'content' => 230,
          'dialogue' => 164,
          'notes' => 172,
          'sceneExpectation' => 172,
          'audio' => 152,
          'cameraAngle' => 110,
          'cameraMove' => 110,
          'cameraRig' => 120,
          'focalLength' => 100,
          _ => 140,
        }).toDouble() *
        editorScale);
  }

  double _sheetRowHeightValue(
    ExportPayload payload,
    String shotId,
    List<String> visibleFields,
    ResolvedShotSheetFields fields,
  ) {
    final sessionHeight = payload.effectiveRowHeights[shotId];
    if (sessionHeight != null && sessionHeight > 0) {
      return sessionHeight;
    }
    final editorScale = _editorScale(payload);
    return ((visibleFields.any(fields.isImageField) ? 108 : 76).toDouble() *
            editorScale)
        .toDouble();
  }

  List<ShotSheetSceneGroup> _buildSceneShotGroups(ExportPayload payload) {
    final scenes = [...payload.scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    if (scenes.isEmpty) {
      return [
        ShotSheetSceneGroup(
          showHeader: false,
          headerLabel: '',
          shots: payload.shots,
        ),
      ];
    }

    final shotsByScene = <String, List<ShotRecord>>{};
    for (final shot in payload.shots) {
      shotsByScene.putIfAbsent(shot.sceneId, () => <ShotRecord>[]).add(shot);
    }

    final hideSingleDefaultScene =
        scenes.length == 1 &&
        scenes.first.name.trim().isEmpty &&
        scenes.first.numberMode == StoryboardSceneNumberMode.auto;

    return [
      for (var index = 0; index < scenes.length; index++)
        ShotSheetSceneGroup(
          showHeader: !hideSingleDefaultScene,
          headerLabel: scenes[index].name.trim().isEmpty
              ? '${scenes[index].displayNumber(index + 1)}场'
              : '${scenes[index].displayNumber(index + 1)}场 ${scenes[index].name.trim()}',
          shots: [...(shotsByScene[scenes[index].id] ?? const <ShotRecord>[])]
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        ),
    ];
  }

  double _editorScale(ExportPayload payload) {
    return _clampDouble(payload.editorScalePercent / 100, 0.7, 1.5);
  }
}

String shotSheetFieldLabel(ExportPayload payload, String fieldKey) {
  final fixed = shotFieldKeyFromStorageKey(fieldKey);
  return fixed?.label ?? payload.fieldLabelsByKey[fieldKey] ?? '自定义列';
}

String shotSheetDisplayShotNo(BoardPreset preset, ShotRecord shot) {
  return preset.shotNumberMode == ShotNumberMode.order
      ? '${shot.orderIndex + 1}'
      : shot.shotNo;
}

String shotSheetFieldValue(
  ShotRecord shot,
  String fieldKey,
  BoardPreset preset,
) {
  final customValue = shot.customFieldValues[fieldKey];
  if (customValue is AssetRef) {
    return '';
  }
  if (customValue != null) {
    return '$customValue'.trim();
  }

  return switch (fieldKey) {
    'shotNo' => shotSheetDisplayShotNo(preset, shot),
    'shotSize' => shot.shotSize,
    'durationSec' => '${shot.durationSec}s',
    'content' => shot.content,
    'dialogue' => shot.dialogue,
    'notes' => shot.notes,
    'sceneExpectation' => shot.sceneExpectation,
    'audio' => shot.audio,
    'cameraAngle' => shot.cameraAngle,
    'cameraMove' => shot.cameraMove,
    'cameraRig' => shot.cameraRig,
    'focalLength' => shot.focalLength,
    'frameImage' => '',
    'referenceImage' => '',
    _ => '',
  }.trim();
}

AssetRef? shotSheetAssetForField(ShotRecord shot, String fieldKey) {
  if (fieldKey == ShotFieldKey.frameImage.storageKey) {
    return shot.frameImage;
  }
  if (fieldKey == ShotFieldKey.referenceImage.storageKey) {
    return shot.referenceImage;
  }
  final value = shot.customFieldValues[fieldKey];
  return value is AssetRef ? value : null;
}

double clampShotSheetDouble(double value, double min, double max) {
  return _clampDouble(value, min, max);
}

double _clampDouble(double value, double min, double max) {
  return math.min(math.max(value, min), max);
}

