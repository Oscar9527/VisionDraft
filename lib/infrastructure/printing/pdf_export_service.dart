import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../../features/project_workspace/domain/models/board_preset.dart';
import '../../features/project_workspace/domain/models/export_payload.dart';
import '../../features/project_workspace/domain/models/shot_record.dart';
import '../../features/project_workspace/domain/models/shot_fields.dart';

class PdfExportService {
  const PdfExportService();

  Future<Uint8List> generate(ExportPayload payload) async {
    final theme = await _loadTheme();
    final document = pw.Document(
      theme: theme,
      title: '${payload.bundle.name}-${_titleForType(payload.documentType)}',
      author: 'VisionDraft',
    );

    switch (payload.documentType) {
      case ExportDocumentType.shotSheet:
        await _buildShotSheet(document, payload);
      case ExportDocumentType.shootingPlan:
        _buildShootingPlan(document, payload);
      case ExportDocumentType.callSheet:
        _buildCallSheet(document, payload);
    }

    return document.save();
  }

  Future<pw.ThemeData> _loadTheme() async {
    final candidates = <String>[
      r'C:\Windows\Fonts\Deng.ttf',
      r'C:\Windows\Fonts\simhei.ttf',
      r'C:\Windows\Fonts\simkai.ttf',
      r'C:\Windows\Fonts\simsunb.ttf',
    ];

    for (final path in candidates) {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final font = pw.Font.ttf(bytes.buffer.asByteData());
        return pw.ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        );
      }
    }

    return pw.ThemeData.withFont();
  }

  Future<void> _buildShotSheet(
    pw.Document document,
    ExportPayload payload,
  ) async {
    final sourceOrder = payload.effectiveFieldOrderKeys.isNotEmpty
        ? payload.effectiveFieldOrderKeys
        : payload.columnPreset.fieldOrderKeys;
    final visibleFields = sourceOrder
        .where(
          (fieldKey) =>
              payload.columnPreset.visibleFieldKeys.contains(fieldKey) ||
              fieldKey == ShotFieldKey.shotNo.storageKey,
        )
        .toList();
    if (!visibleFields.contains(ShotFieldKey.shotNo.storageKey)) {
      visibleFields.insert(0, ShotFieldKey.shotNo.storageKey);
    }

    final imageCache = <String, pw.MemoryImage>{};
    final tableRows = <pw.TableRow>[
      _tableHeaderRow(
        visibleFields
            .map((fieldKey) => _fieldLabel(payload, fieldKey))
            .toList(),
      ),
    ];

    for (final shot in payload.shots) {
      tableRows.add(
        await _shotSheetRow(
          shot: shot,
          fields: visibleFields,
          preset: payload.boardPreset,
          imageCache: imageCache,
          payload: payload,
        ),
      );
    }

    final designWidth = visibleFields.fold<double>(
      0,
      (sum, fieldKey) => sum + _sheetColumnWidthValue(payload, fieldKey),
    );
    final columnWidths = <int, pw.TableColumnWidth>{
      for (var index = 0; index < visibleFields.length; index++)
        index: pw.FixedColumnWidth(
          _sheetColumnWidthValue(payload, visibleFields[index]),
        ),
    };

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(16, 16, 16, 16),
        build: (context) => pw.FittedBox(
          fit: pw.BoxFit.scaleDown,
          alignment: pw.Alignment.topLeft,
          child: pw.SizedBox(
            width: designWidth,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfHeader(
                  title: _titleForType(payload.documentType),
                  projectName: payload.bundle.name,
                  subtitle:
                      '镜头 ${payload.shots.length} 条 · A4 横向单页 · ${_timestamp(DateTime.now())}',
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: _shotSheetTableBorder(),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  columnWidths: columnWidths,
                  children: tableRows,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _buildShootingPlan(pw.Document document, ExportPayload payload) {
    final shotById = {for (final shot in payload.shots) shot.id: shot};
    final sections = payload.planBoard.sections;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 20),
        build: (context) {
          final widgets = <pw.Widget>[
            _pdfHeader(
              title: _titleForType(payload.documentType),
              projectName: payload.bundle.name,
              subtitle:
                  '计划区块 ${sections.length} 个 · 未规划 ${payload.planBoard.unassignedShotIds.length} 个',
            ),
            pw.SizedBox(height: 12),
          ];

          for (final section in sections) {
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      section.name,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey500,
                        width: 0.5,
                      ),
                      columnWidths: const {
                        0: pw.FixedColumnWidth(52),
                        1: pw.FixedColumnWidth(54),
                        2: pw.FixedColumnWidth(54),
                        3: pw.FlexColumnWidth(3.0),
                        4: pw.FlexColumnWidth(2.0),
                        5: pw.FixedColumnWidth(54),
                      },
                      children: [
                        _tableHeaderRow(const [
                          '序号',
                          '镜号',
                          '景别',
                          '画面内容',
                          '运镜 / 机位',
                          '时长',
                        ]),
                        for (final shotId in section.shotIds)
                          _tableDataRow(_planRowData(shotById[shotId])),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          if (payload.planBoard.unassignedShotIds.isNotEmpty) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '未规划镜头',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: payload.planBoard.unassignedShotIds
                          .map((shotId) => shotById[shotId])
                          .whereType<ShotRecord>()
                          .map(
                            (shot) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey200,
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(12),
                                ),
                              ),
                              child: pw.Text(
                                '${_displayShotNo(payload.boardPreset, shot)} · ${shot.content.isEmpty ? "未填写内容" : _truncate(shot.content, 20)}',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }

          return widgets;
        },
      ),
    );
  }

  void _buildCallSheet(pw.Document document, ExportPayload payload) {
    final groupedSections = payload.planBoard.sections
        .map(
          (section) => (
            section: section,
            shots: payload.shots
                .where((shot) => section.shotIds.contains(shot.id))
                .toList(),
          ),
        )
        .toList();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 20),
        build: (context) {
          final widgets = <pw.Widget>[
            _pdfHeader(
              title: _titleForType(payload.documentType),
              projectName: payload.bundle.name,
              subtitle:
                  '区块 ${groupedSections.length} 个 · 镜头 ${payload.shots.length} 个',
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    payload.callSheet.title,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '导出时间：${_timestamp(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  if (payload.callSheet.sectionSummaries.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    ...payload.callSheet.sectionSummaries.map(
                      (summary) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text('• $summary'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 12),
          ];

          for (final entry in groupedSections) {
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      entry.section.name,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '镜头数 ${entry.shots.length} · 预计总时长 ${entry.shots.fold<int>(0, (sum, shot) => sum + shot.durationSec)}s',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey500,
                        width: 0.5,
                      ),
                      columnWidths: const {
                        0: pw.FixedColumnWidth(54),
                        1: pw.FixedColumnWidth(54),
                        2: pw.FlexColumnWidth(2.5),
                        3: pw.FlexColumnWidth(1.6),
                        4: pw.FlexColumnWidth(1.3),
                      },
                      children: [
                        _tableHeaderRow(const [
                          '镜号',
                          '景别',
                          '画面内容',
                          '声音 / 台词',
                          '设备',
                        ]),
                        for (final shot in entry.shots)
                          _tableDataRow([
                            _displayShotNo(payload.boardPreset, shot),
                            shot.shotSize,
                            _truncate(shot.content, 40),
                            _truncate(
                              [shot.audio, shot.dialogue]
                                  .where((item) => item.trim().isNotEmpty)
                                  .join(' / '),
                              34,
                            ),
                            _truncate(
                              [
                                    shot.cameraRig,
                                    shot.cameraMove,
                                    shot.focalLength,
                                  ]
                                  .where((item) => item.trim().isNotEmpty)
                                  .join(' / '),
                              20,
                            ),
                          ]),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return widgets;
        },
      ),
    );
  }

  double _sheetColumnWidthValue(ExportPayload payload, String fieldKey) {
    final sessionWidth = payload.effectiveColumnWidths[fieldKey];
    if (sessionWidth != null && sessionWidth > 0) {
      return sessionWidth;
    }
    return switch (fieldKey) {
      'shotNo' => 58,
      'durationSec' => 60,
      'shotSize' => 64,
      'frameImage' || 'referenceImage' => 140,
      'content' => 260,
      'dialogue' => 180,
      'notes' => 180,
      'sceneExpectation' => 180,
      'audio' => 160,
      'cameraAngle' => 92,
      'cameraMove' => 92,
      'cameraRig' => 100,
      'focalLength' => 84,
      _ => 160,
    }.toDouble();
  }

  Future<pw.TableRow> _shotSheetRow({
    required ShotRecord shot,
    required List<String> fields,
    required BoardPreset preset,
    required Map<String, pw.MemoryImage> imageCache,
    required ExportPayload payload,
  }) async {
    final cells = <pw.Widget>[];

    for (final fieldKey in fields) {
      if (fieldKey == 'frameImage' || fieldKey == 'referenceImage') {
        final asset = fieldKey == 'frameImage'
            ? shot.frameImage
            : shot.referenceImage;
        final image = await _loadMemoryImage(asset, imageCache);
        cells.add(
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: _pdfImageBox(
              image: image,
              aspectRatio: preset.aspectRatio,
              fitMode: preset.fitMode,
            ),
          ),
        );
        continue;
      }

      cells.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: pw.Text(
            _fieldValue(shot, fieldKey, preset),
            style: const pw.TextStyle(fontSize: 8.2),
            maxLines: 4,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      );
    }

    return pw.TableRow(children: cells);
  }

  pw.Widget _pdfHeader({
    required String title,
    required String projectName,
    required String subtitle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.8),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(projectName, style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  pw.TableRow _tableHeaderRow(List<String> values) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: values
          .map(
            (value) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 8.6,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.TableRow _tableDataRow(List<String> values) {
    return pw.TableRow(
      children: values
          .map(
            (value) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 5,
              ),
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
            ),
          )
          .toList(),
    );
  }

  List<String> _planRowData(ShotRecord? shot) {
    if (shot == null) {
      return const ['-', '-', '-', '-', '-', '-'];
    }
    return [
      '${shot.orderIndex + 1}',
      shot.shotNo,
      shot.shotSize,
      _truncate(shot.content, 34),
      _truncate('${shot.cameraMove} / ${shot.cameraRig}', 20),
      '${shot.durationSec}s',
    ];
  }

  Future<pw.MemoryImage?> _loadMemoryImage(
    AssetRef? asset,
    Map<String, pw.MemoryImage> cache,
  ) async {
    final uri = asset?.uri;
    if (uri == null || uri.isEmpty) {
      return null;
    }

    final cached = cache[uri];
    if (cached != null) {
      return cached;
    }

    final file = File(uri);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final image = pw.MemoryImage(bytes);
    cache[uri] = image;
    return image;
  }

  pw.Widget _pdfImageBox({
    required pw.MemoryImage? image,
    required double aspectRatio,
    required ImageFitMode fitMode,
  }) {
    final safeRatio = aspectRatio > 0 ? aspectRatio : 16 / 9;
    return pw.AspectRatio(
      aspectRatio: safeRatio,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          border: pw.Border.all(color: PdfColors.grey500, width: 0.4),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        alignment: pw.Alignment.center,
        child: image == null
            ? pw.Text(
                '无图片',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              )
            : pw.ClipRRect(
                horizontalRadius: 4,
                verticalRadius: 4,
                child: pw.Image(
                  image,
                  fit: fitMode == ImageFitMode.cover
                      ? pw.BoxFit.cover
                      : pw.BoxFit.contain,
                ),
              ),
      ),
    );
  }

  String _displayShotNo(BoardPreset preset, ShotRecord shot) {
    return preset.shotNumberMode == ShotNumberMode.order
        ? '${shot.orderIndex + 1}'
        : shot.shotNo;
  }

  String _fieldLabel(ExportPayload payload, String fieldKey) {
    final fixed = shotFieldKeyFromStorageKey(fieldKey);
    return fixed?.label ?? payload.fieldLabelsByKey[fieldKey] ?? '自定义列';
  }

  String _fieldValue(ShotRecord shot, String fieldKey, BoardPreset preset) {
    final customValue = shot.customFieldValues[fieldKey];
    if (customValue != null) {
      return '$customValue'.trim();
    }

    return switch (fieldKey) {
      'shotNo' => _displayShotNo(preset, shot),
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
      'frameImage' => shot.frameImage?.uri ?? '',
      'referenceImage' => shot.referenceImage?.uri ?? '',
      _ => '',
    }.trim();
  }

  String _timestamp(DateTime time) {
    return DateFormat('yyyy-MM-dd HH:mm').format(time);
  }

  String _truncate(String value, int maxLength) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '-';
    }
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength - 1)}…';
  }

  String _titleForType(ExportDocumentType type) {
    return switch (type) {
      ExportDocumentType.shotSheet => '分镜单',
      ExportDocumentType.shootingPlan => '拍摄计划单',
      ExportDocumentType.callSheet => '拍摄通告单',
    };
  }

  pw.TableBorder _shotSheetTableBorder() {
    return const pw.TableBorder(
      top: pw.BorderSide(color: PdfColors.grey700, width: 0.8),
      bottom: pw.BorderSide(color: PdfColors.grey700, width: 0.8),
      left: pw.BorderSide(color: PdfColors.grey700, width: 0.8),
      right: pw.BorderSide(color: PdfColors.grey700, width: 0.8),
      horizontalInside: pw.BorderSide(color: PdfColors.grey500, width: 0.45),
      verticalInside: pw.BorderSide(color: PdfColors.grey700, width: 0.8),
    );
  }
}
