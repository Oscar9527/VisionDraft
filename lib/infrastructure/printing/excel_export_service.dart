import 'dart:typed_data';

import 'package:excel_community/excel_community.dart';

import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../../features/project_workspace/domain/models/board_preset.dart';
import '../../features/project_workspace/domain/models/export_payload.dart';
import '../../features/project_workspace/domain/models/shot_fields.dart';
import '../../features/project_workspace/domain/models/shot_record.dart';

class ExcelExportService {
  const ExcelExportService();

  static const String _sheetName = '分镜单';

  Future<Uint8List> generate(ExportPayload payload) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != _sheetName) {
      excel.rename(defaultSheet, _sheetName);
    }

    final sheet = excel[_sheetName];
    final visibleFields = _visibleFields(payload);

    sheet.appendRow(
      visibleFields
          .map((fieldKey) => TextCellValue(_fieldLabel(payload, fieldKey)))
          .toList(),
    );
    sheet.setRowHeight(0, 24);

    for (var rowIndex = 0; rowIndex < payload.shots.length; rowIndex++) {
      final shot = payload.shots[rowIndex];
      sheet.appendRow(
        visibleFields
            .map(
              (fieldKey) => _fieldCellValue(
                payload,
                shot: shot,
                fieldKey: fieldKey,
              ),
            )
            .toList(),
      );
      final rowHeight = payload.effectiveRowHeights[shot.id];
      if (rowHeight != null) {
        sheet.setRowHeight(rowIndex + 1, (rowHeight / 2).clamp(20, 120));
      }
    }

    for (var columnIndex = 0; columnIndex < visibleFields.length; columnIndex++) {
      final fieldKey = visibleFields[columnIndex];
      final columnWidth =
          payload.effectiveColumnWidths[fieldKey] ?? _defaultColumnWidth(fieldKey);
      sheet.setColumnWidth(
        columnIndex,
        (columnWidth / 10).clamp(10, 48).toDouble(),
      );
    }

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? const <int>[]);
  }

  List<String> _visibleFields(ExportPayload payload) {
    final sourceOrder = payload.effectiveFieldOrderKeys.isNotEmpty
        ? payload.effectiveFieldOrderKeys
        : payload.columnPreset.fieldOrderKeys;
    final visible = <String>[];
    for (final fieldKey in sourceOrder) {
      final isVisible =
          payload.columnPreset.visibleFieldKeys.contains(fieldKey) ||
          fieldKey == ShotFieldKey.shotNo.storageKey;
      if (isVisible && !visible.contains(fieldKey)) {
        visible.add(fieldKey);
      }
    }

    if (!visible.contains(ShotFieldKey.shotNo.storageKey)) {
      visible.insert(0, ShotFieldKey.shotNo.storageKey);
    }
    return visible;
  }

  String _fieldLabel(ExportPayload payload, String fieldKey) {
    final fixed = shotFieldKeyFromStorageKey(fieldKey);
    return fixed?.label ?? payload.fieldLabelsByKey[fieldKey] ?? '自定义列';
  }

  CellValue? _fieldCellValue(
    ExportPayload payload, {
    required ShotRecord shot,
    required String fieldKey,
  }) {
    final customValue = shot.customFieldValues[fieldKey];
    if (customValue != null) {
      return _toCellValue(customValue);
    }

    return switch (fieldKey) {
      'shotNo' => TextCellValue(
        payload.boardPreset.shotNumberMode == ShotNumberMode.order
            ? '${shot.orderIndex + 1}'
            : shot.shotNo,
      ),
      'shotSize' => TextCellValue(shot.shotSize),
      'durationSec' => IntCellValue(shot.durationSec),
      'content' => TextCellValue(shot.content),
      'dialogue' => TextCellValue(shot.dialogue),
      'notes' => TextCellValue(shot.notes),
      'sceneExpectation' => TextCellValue(shot.sceneExpectation),
      'audio' => TextCellValue(shot.audio),
      'cameraAngle' => TextCellValue(shot.cameraAngle),
      'cameraMove' => TextCellValue(shot.cameraMove),
      'cameraRig' => TextCellValue(shot.cameraRig),
      'focalLength' => TextCellValue(shot.focalLength),
      'frameImage' => TextCellValue(shot.frameImage?.uri ?? ''),
      'referenceImage' => TextCellValue(shot.referenceImage?.uri ?? ''),
      _ => TextCellValue(''),
    };
  }

  CellValue _toCellValue(Object? value) {
    return switch (value) {
      null => TextCellValue(''),
      int intValue => IntCellValue(intValue),
      double doubleValue => DoubleCellValue(doubleValue),
      bool flag => BoolCellValue(flag),
      AssetRef asset => TextCellValue(asset.uri),
      _ => TextCellValue('$value'),
    };
  }

  double _defaultColumnWidth(String fieldKey) {
    return switch (fieldKey) {
      'shotNo' => 88,
      'durationSec' => 76,
      'shotSize' => 92,
      'frameImage' || 'referenceImage' => 220,
      'content' => 240,
      'dialogue' || 'notes' || 'sceneExpectation' => 180,
      'audio' => 156,
      'cameraAngle' || 'cameraMove' => 96,
      'cameraRig' => 104,
      'focalLength' => 92,
      _ => 144,
    }.toDouble();
  }
}
