import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../../features/project_workspace/domain/models/board_preset.dart';
import '../../features/project_workspace/domain/models/export_payload.dart';
import '../../features/project_workspace/domain/models/shot_fields.dart';
import '../../features/project_workspace/domain/models/shot_record.dart';
import '../../features/project_workspace/domain/models/storyboard_scene.dart';

class PdfExportService {
  const PdfExportService();

  static const double _shotSheetSceneHeaderHeight = 22;

  static const String _defaultLogoPngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAHiSURBVFhH3dY9TgJBFAfw9RsMtVFvYKMiFmrCEdRGAyz4AcVeQE2Ml7CwEAW8BELQEhOREEvvYdwgWI3vDTOb2d3ZhZgZCl/yL2d//4HwFkPVnLT71vFbn2COhOQgWZ5Wn5itvsWOqBvEIRQfUkAfPkIB9fipgA8poAeHOHhIAfV4vv1DcVkBEYfowSE+XFJALz7k49eHj3B7/XjI7cePCwX0f+djxQFzfmoy+P/i8HDXepVFhhfebQO2XgIDq3eQ1iDwBqTJDLLCjvgHHh6KM9iH5ztdxIu49zHs5cNfvzQAY7qQJDvmH0CkBQTYhxvkNRD3FAjH+QDo/LGQxIWbL8E3/xPOByGOsu3mWzLb1U9jv9lTj/NBMAjfqX0ZiafvWwjZa/bU43xYCRcef6R4EfENFlpCNS6bwgehOIcxcZZdKKEV33q2DQCluFhCC44DYDII5lmr22TzpnPNjqgfQCwvillvAF6zyeJVg0RyDxj3rlA5ALpKcHzpsk6iZoUWmMtWMHpLIMzx5YtHEju4I/OpEolACVaAzJoaSwBurSJ+ViWxw3sSzZRF2MmMzhIL51WLo14cYCfTmbK+EoDSEp5bizjNVFpjCUCtIJjhNJPpkr4SgFpenMMMp5lIiSUM4xfhImnqhjb4gAAAAABJRU5ErkJggg==';

  Future<Uint8List> generate(ExportPayload payload) async {
    final theme = await _loadTheme();
    final brandingLogo = await _loadBrandLogo(
      payload.branding.logoPath,
      fallbackToDefault: payload.branding.showDefaultLogo,
    );
    final document = pw.Document(
      theme: theme,
      title: '${payload.bundle.name}-${_titleForType(payload.documentType)}',
      author: 'VisionDraft',
    );

    switch (payload.documentType) {
      case ExportDocumentType.shotSheet:
        await _buildShotSheet(document, payload, brandingLogo);
      case ExportDocumentType.shootingPlan:
        _buildShootingPlan(document, payload, brandingLogo);
      case ExportDocumentType.callSheet:
        _buildCallSheet(document, payload, brandingLogo);
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

  Future<pw.MemoryImage?> _loadBrandLogo(
    String? path, {
    required bool fallbackToDefault,
  }) async {
    final normalizedPath = path?.trim();
    if (normalizedPath != null && normalizedPath.isNotEmpty) {
      final file = File(normalizedPath);
      if (await file.exists()) {
        return pw.MemoryImage(await file.readAsBytes());
      }
    }
    if (!fallbackToDefault) {
      return null;
    }
    return pw.MemoryImage(base64Decode(_defaultLogoPngBase64));
  }

  Future<void> _buildShotSheet(
    pw.Document document,
    ExportPayload payload,
    pw.MemoryImage? brandingLogo,
  ) async {
    final visibleFields = _visibleShotSheetFields(payload);

    final imageCache = <String, pw.MemoryImage>{};
    final baseColumnWidths = {
      for (final fieldKey in visibleFields)
        fieldKey: _sheetColumnWidthValue(payload, fieldKey),
    };
    final baseRowHeights = {
      for (final shot in payload.shots)
        shot.id: _sheetRowHeightValue(payload, shot.id, visibleFields),
    };
    final layout = _resolveShotSheetLayout(
      payload: payload,
      visibleFields: visibleFields,
      columnWidths: baseColumnWidths,
      rowHeights: baseRowHeights,
    );
    final shotPages = _paginateShotSheetSceneRows(
      payload: payload,
      rowHeights: layout.rowHeights,
      headerRowHeight: layout.headerRowHeight,
      pageBodyHeight: layout.tableBodyHeight,
    );

    for (final pageShots in shotPages) {
      final tableRows = <pw.TableRow>[
        _tableHeaderRow(
          visibleFields
              .map((fieldKey) => _fieldLabel(payload, fieldKey))
              .toList(),
          rowHeight: layout.headerRowHeight,
          fontSize: layout.headerFontSize,
        ),
      ];

      for (final row in pageShots) {
        if (row is _ScenePageHeaderRow) {
          tableRows.add(
            _sceneHeaderTableRow(
              row.label,
              columnCount: visibleFields.length,
              rowHeight: _shotSheetSceneHeaderHeight,
              fontSize: layout.bodyFontSize,
            ),
          );
          continue;
        }
        final shot = (row as _ScenePageShotRow).shot;
        tableRows.add(
          await _shotSheetRow(
            shot: shot,
            fields: visibleFields,
            preset: payload.boardPreset,
            imageCache: imageCache,
            payload: payload,
            rowHeight: layout.rowHeights[shot.id] ?? layout.defaultRowHeight,
            bodyFontSize: layout.bodyFontSize,
            maxTextLines: layout.maxTextLines,
            imagePadding: layout.imagePadding,
          ),
        );
      }

      document.addPage(
        pw.Page(
          pageFormat: layout.pageFormat,
          margin: layout.margin,
          build: (context) => pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.SizedBox(
              width: layout.contentWidth,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _pdfHeader(
                    title: _titleForType(payload.documentType),
                    projectName: payload.bundle.name,
                    payload: payload,
                    brandingLogo: brandingLogo,
                    scale: layout.headerScale,
                  ),
                  pw.SizedBox(height: layout.headerSpacing),
                  pw.Align(
                    alignment: pw.Alignment.topCenter,
                    child: pw.SizedBox(
                      width: layout.tableWidth,
                      child: pw.Table(
                        border: _shotSheetTableBorder(),
                        defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.middle,
                        columnWidths: {
                          for (var index = 0; index < visibleFields.length; index++)
                            index: pw.FixedColumnWidth(
                              layout.columnWidths[visibleFields[index]]!,
                            ),
                        },
                        children: tableRows,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _buildShootingPlan(
    pw.Document document,
    ExportPayload payload,
    pw.MemoryImage? brandingLogo,
  ) {
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
              payload: payload,
              brandingLogo: brandingLogo,
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
                  border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
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
                        color: PdfColors.grey700,
                        width: 0.72,
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
                        ], rowHeight: 26),
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
                  border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
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

  void _buildCallSheet(
    pw.Document document,
    ExportPayload payload,
    pw.MemoryImage? brandingLogo,
  ) {
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
              payload: payload,
              brandingLogo: brandingLogo,
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
                  border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
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
                        color: PdfColors.grey700,
                        width: 0.72,
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
                        ], rowHeight: 26),
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
    final editorScale = _editorScale(payload);
    if (_isImageField(payload, fieldKey)) {
      return ((fieldKey == ShotFieldKey.frameImage.storageKey ? 260 : 220) *
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
  ) {
    final sessionHeight = payload.effectiveRowHeights[shotId];
    if (sessionHeight != null && sessionHeight > 0) {
      return sessionHeight;
    }
    final editorScale = _editorScale(payload);
    return ((visibleFields.any((fieldKey) => _isImageField(payload, fieldKey))
                ? 108
                : 76)
            .toDouble() *
        editorScale)
        .toDouble();
  }

  Future<pw.TableRow> _shotSheetRow({
    required ShotRecord shot,
    required List<String> fields,
    required BoardPreset preset,
    required Map<String, pw.MemoryImage> imageCache,
    required ExportPayload payload,
    required double rowHeight,
    required double bodyFontSize,
    required int maxTextLines,
    required double imagePadding,
  }) async {
    final cells = <pw.Widget>[];

    for (final fieldKey in fields) {
      if (_isImageField(payload, fieldKey)) {
        final asset = _assetForField(shot, fieldKey);
        final image = await _loadMemoryImage(asset, imageCache);
        cells.add(
          pw.Container(
            height: rowHeight,
            padding: pw.EdgeInsets.all(imagePadding),
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
        pw.Container(
          height: rowHeight,
          alignment: pw.Alignment.centerLeft,
          padding: pw.EdgeInsets.symmetric(
            horizontal: math.max(3.0, imagePadding + 0.5),
            vertical: math.max(2.0, imagePadding * 0.72),
          ),
          child: pw.Text(
            _fieldValue(shot, fieldKey, preset),
            style: pw.TextStyle(fontSize: bodyFontSize),
            maxLines: maxTextLines,
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
    required ExportPayload payload,
    required pw.MemoryImage? brandingLogo,
    double scale = 1.0,
  }) {
    final brandName = payload.branding.brandName.trim();
    final tagline = payload.branding.tagline.trim();
    final hasBrandBlock =
        brandingLogo != null || brandName.isNotEmpty || tagline.isNotEmpty;
    final paddingBottom = 10 * scale;
    final titleSize = math.max(12.0, 18 * scale);
    final projectSize = math.max(8.6, 11 * scale);
    final brandSize = math.max(8.4, 11 * scale);
    final taglineSize = math.max(7.0, 8.5 * scale);
    final logoSize = math.max(20.0, 28 * scale);
    final gap = math.max(8.0, 16 * scale);

    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: paddingBottom),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey700, width: 0.9),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: titleSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  projectName,
                  style: pw.TextStyle(fontSize: projectSize),
                ),
              ],
            ),
          ),
          if (hasBrandBlock) ...[
            pw.SizedBox(width: gap),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (brandingLogo != null) ...[
                  pw.ClipRRect(
                    horizontalRadius: 7,
                    verticalRadius: 7,
                    child: pw.Image(
                      brandingLogo,
                      width: logoSize,
                      height: logoSize,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                ],
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (brandName.isNotEmpty)
                      pw.Text(
                        brandName,
                        style: pw.TextStyle(
                          fontSize: brandSize,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    if (brandName.isNotEmpty && tagline.isNotEmpty)
                      pw.SizedBox(height: 2),
                    if (tagline.isNotEmpty)
                      pw.Text(
                        tagline,
                        style: pw.TextStyle(fontSize: taglineSize),
                        textAlign: pw.TextAlign.right,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.TableRow _tableHeaderRow(
    List<String> values, {
    required double rowHeight,
    double fontSize = 8.6,
  }) {
    final safeRowHeight = math.max(rowHeight, fontSize + 8);
    final verticalPadding = _clampDouble(
      (safeRowHeight - fontSize) / 2 - 0.4,
      2.0,
      5.0,
    );
    final horizontalPadding = _clampDouble(fontSize * 0.55, 3.6, 6.0);

    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: values
          .map(
            (value) => pw.Container(
              height: safeRowHeight,
              alignment: pw.Alignment.centerLeft,
              padding: pw.EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: fontSize,
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
          border: pw.Border.all(color: PdfColors.grey700, width: 0.65),
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
    if (customValue is AssetRef) {
      return customValue.uri;
    }
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
      top: pw.BorderSide(color: PdfColors.grey800, width: 0.95),
      bottom: pw.BorderSide(color: PdfColors.grey800, width: 0.95),
      left: pw.BorderSide(color: PdfColors.grey800, width: 0.95),
      right: pw.BorderSide(color: PdfColors.grey800, width: 0.95),
      horizontalInside: pw.BorderSide(color: PdfColors.grey700, width: 0.72),
      verticalInside: pw.BorderSide(color: PdfColors.grey800, width: 0.95),
    );
  }

  List<String> _visibleShotSheetFields(ExportPayload payload) {
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
    return visibleFields;
  }

  bool _isImageField(ExportPayload payload, String fieldKey) {
    if (fieldKey == ShotFieldKey.frameImage.storageKey ||
        fieldKey == ShotFieldKey.referenceImage.storageKey) {
      return true;
    }
    return payload.shots.any((shot) => shot.customFieldValues[fieldKey] is AssetRef);
  }

  AssetRef? _assetForField(ShotRecord shot, String fieldKey) {
    if (fieldKey == ShotFieldKey.frameImage.storageKey) {
      return shot.frameImage;
    }
    if (fieldKey == ShotFieldKey.referenceImage.storageKey) {
      return shot.referenceImage;
    }
    final value = shot.customFieldValues[fieldKey];
    return value is AssetRef ? value : null;
  }

  _ShotSheetLayout _resolveShotSheetLayout({
    required ExportPayload payload,
    required List<String> visibleFields,
    required Map<String, double> columnWidths,
    required Map<String, double> rowHeights,
  }) {
    final pageFormat = PdfPageFormat.a4.landscape;
    const margin = pw.EdgeInsets.fromLTRB(10, 10, 10, 10);
    const headerSpacing = 6.0;
    final hasImage = visibleFields.any((fieldKey) => _isImageField(payload, fieldKey));
    final isDenseTextMode = !hasImage;
    final editorScale = _editorScale(payload);
    final editorFontBias = math.pow(editorScale, 0.12).toDouble();
    final boardTextBias =
        payload.boardPreset.textScaleMode == TextScaleMode.large ? 1.08 : 0.96;
    final availableWidth = pageFormat.width - margin.left - margin.right;
    final availableHeight = pageFormat.height - margin.top - margin.bottom;
    final desiredColumnWidthTotal = visibleFields.fold<double>(
      0,
      (sum, fieldKey) => sum + math.max(1.0, columnWidths[fieldKey] ?? 1.0),
    );
    final widthFitScale = math.min(
      1.0,
      availableWidth / math.max(desiredColumnWidthTotal, 1.0),
    );
    final normalizedColumnWidths = _expandShotSheetColumnWidths(
      payload: payload,
      visibleFields: visibleFields,
      availableWidth: availableWidth,
      columnWidths: {
        for (final fieldKey in visibleFields)
          fieldKey: math.max(1.0, columnWidths[fieldKey] ?? 1.0) * widthFitScale,
      },
    );
    final densityScale = _clampDouble(
      math.pow(widthFitScale, hasImage ? 0.28 : 0.14).toDouble(),
      hasImage ? 0.82 : 0.84,
      1.0,
    );
    final scaledRowHeights = {
      for (final shot in payload.shots)
        shot.id: _clampDouble(
          math.max(1.0, rowHeights[shot.id] ?? 1.0) * densityScale,
          hasImage ? 56.0 : 28.0,
          hasImage ? 132.0 : 68.0,
        ),
    };
    final tableWidth = visibleFields.fold<double>(
      0,
      (sum, fieldKey) => sum + (normalizedColumnWidths[fieldKey] ?? 0),
    );
    final averageRowHeight = scaledRowHeights.isEmpty
        ? (hasImage ? 76.0 : 42.0)
        : scaledRowHeights.values.fold<double>(0, (sum, value) => sum + value) /
            scaledRowHeights.length;
    final widthFontBias = _clampDouble(
      math.pow(widthFitScale, 0.18).toDouble(),
      0.92,
      1.0,
    );
    final bodyFontSize = _clampDouble(
      (hasImage ? 9.0 : 8.5) * widthFontBias * editorFontBias * boardTextBias,
      isDenseTextMode ? 6.6 : 7.4,
      hasImage ? 10.6 : 9.4,
    );
    final headerFontSize = _clampDouble(bodyFontSize + 0.8, 8.0, 11.6);
    final headerRowHeight = _clampDouble(
      bodyFontSize * 2.08,
      22.0,
      hasImage ? 30.0 : 24.0,
    );
    final maxTextLines = math.max(
      2,
      math.min(
        hasImage ? 5 : 7,
        ((averageRowHeight - 8) / (bodyFontSize * 1.24)).floor(),
      ),
    );
    final imagePadding = _clampDouble(
      averageRowHeight * 0.03,
      isDenseTextMode ? 1.2 : 2.0,
      isDenseTextMode ? 2.8 : 4.6,
    );
    final headerScale = _clampDouble(
      bodyFontSize / 8.9,
      0.9,
      1.08,
    );
    final hasBrandBlock =
        payload.branding.showDefaultLogo ||
        (payload.branding.logoPath?.trim().isNotEmpty ?? false) ||
        payload.branding.brandName.trim().isNotEmpty ||
        payload.branding.tagline.trim().isNotEmpty;
    final estimatedHeaderHeight = _clampDouble(
      (hasBrandBlock ? 44.0 : 32.0) * headerScale,
      28.0,
      60.0,
    );
    final tableBodyHeight = math.max(
      120.0,
      availableHeight - estimatedHeaderHeight - headerSpacing,
    );

    return _ShotSheetLayout(
      pageFormat: pageFormat,
      margin: margin,
      headerSpacing: headerSpacing,
      headerRowHeight: headerRowHeight,
      headerFontSize: headerFontSize,
      bodyFontSize: bodyFontSize,
      headerScale: headerScale,
      maxTextLines: maxTextLines,
      imagePadding: imagePadding,
      defaultRowHeight: averageRowHeight,
      tableBodyHeight: tableBodyHeight,
      contentWidth: availableWidth,
      tableWidth: tableWidth,
      columnWidths: normalizedColumnWidths,
      rowHeights: scaledRowHeights,
    );
  }

  pw.TableRow _sceneHeaderTableRow(
    String label, {
    required int columnCount,
    required double rowHeight,
    required double fontSize,
  }) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.Container(
          height: rowHeight,
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: math.max(fontSize, 8.2),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        for (var index = 1; index < columnCount; index++)
          pw.Container(
            height: rowHeight,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          ),
      ],
    );
  }

  Map<String, double> _expandShotSheetColumnWidths({
    required ExportPayload payload,
    required List<String> visibleFields,
    required double availableWidth,
    required Map<String, double> columnWidths,
  }) {
    final widths = <String, double>{...columnWidths};
    if (visibleFields.isEmpty) {
      return widths;
    }

    var remainingWidth = availableWidth - widths.values.fold<double>(0, (sum, value) => sum + value);
    if (remainingWidth <= 1.0) {
      return widths;
    }

    var expandable = visibleFields
        .where((fieldKey) => fieldKey != ShotFieldKey.shotNo.storageKey)
        .toList();
    while (remainingWidth > 0.5 && expandable.isNotEmpty) {
      final totalWeight = expandable.fold<double>(
        0,
        (sum, fieldKey) => sum + _shotSheetColumnExpansionWeight(payload, fieldKey),
      );
      if (totalWeight <= 0) {
        break;
      }

      final nextExpandable = <String>[];
      var consumedWidth = 0.0;
      for (final fieldKey in expandable) {
        final current = widths[fieldKey] ?? 0;
        final maxWidth = _shotSheetMaxColumnWidth(payload, fieldKey);
        if (current >= maxWidth - 0.5) {
          continue;
        }
        final ratio =
            _shotSheetColumnExpansionWeight(payload, fieldKey) / totalWeight;
        final delta = math.min(
          remainingWidth * ratio,
          maxWidth - current,
        );
        if (delta <= 0) {
          continue;
        }
        widths[fieldKey] = current + delta;
        consumedWidth += delta;
        if ((widths[fieldKey] ?? current) < maxWidth - 0.5) {
          nextExpandable.add(fieldKey);
        }
      }
      if (consumedWidth <= 0) {
        break;
      }
      remainingWidth -= consumedWidth;
      expandable = nextExpandable;
    }

    return widths;
  }

  double _shotSheetColumnExpansionWeight(ExportPayload payload, String fieldKey) {
    if (_isImageField(payload, fieldKey)) {
      return 2.2;
    }
    return switch (fieldKey) {
      'content' || 'dialogue' || 'notes' || 'sceneExpectation' || 'audio' => 1.8,
      'shotSize' || 'cameraAngle' || 'cameraMove' || 'cameraRig' => 1.2,
      'durationSec' => 0.9,
      _ => 1.0,
    };
  }

  double _shotSheetMaxColumnWidth(ExportPayload payload, String fieldKey) {
    if (_isImageField(payload, fieldKey)) {
      return fieldKey == ShotFieldKey.frameImage.storageKey ? 300.0 : 250.0;
    }
    return switch (fieldKey) {
      'shotNo' => 96,
      'durationSec' => 92,
      'shotSize' => 118,
      'content' => 320,
      'dialogue' => 220,
      'notes' => 240,
      'sceneExpectation' => 240,
      'audio' => 220,
      'cameraAngle' => 150,
      'cameraMove' => 150,
      'cameraRig' => 160,
      'focalLength' => 130,
      _ => 220,
    }.toDouble();
  }

  List<List<_ScenePageRow>> _paginateShotSheetSceneRows({
    required ExportPayload payload,
    required Map<String, double> rowHeights,
    required double headerRowHeight,
    required double pageBodyHeight,
  }) {
    if (payload.shots.isEmpty) {
      return const [<_ScenePageRow>[]];
    }

    final bodyLimit = math.max(96.0, pageBodyHeight - headerRowHeight);
    final pages = <List<_ScenePageRow>>[];
    var currentPage = <_ScenePageRow>[];
    var currentHeight = 0.0;

    final groups = _buildSceneShotGroups(payload);
    for (final group in groups) {
      if (group.showHeader) {
        final wouldOverflow =
            currentPage.isNotEmpty &&
            currentHeight + _shotSheetSceneHeaderHeight > bodyLimit;
        if (wouldOverflow) {
          pages.add(currentPage);
          currentPage = <_ScenePageRow>[];
          currentHeight = 0.0;
        }
        currentPage.add(_ScenePageHeaderRow(group.headerLabel));
        currentHeight += _shotSheetSceneHeaderHeight;
      }

      for (final shot in group.shots) {
        final shotHeight = rowHeights[shot.id] ?? 0;
        final wouldOverflow =
            currentPage.isNotEmpty && currentHeight + shotHeight > bodyLimit;

        if (wouldOverflow) {
          pages.add(currentPage);
          currentPage = <_ScenePageRow>[];
          currentHeight = 0.0;
          if (group.showHeader) {
            currentPage.add(_ScenePageHeaderRow(group.headerLabel));
            currentHeight += _shotSheetSceneHeaderHeight;
          }
        }

        currentPage.add(_ScenePageShotRow(shot));
        currentHeight += shotHeight;
      }
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }

  List<_SceneShotGroup> _buildSceneShotGroups(ExportPayload payload) {
    final scenes = [...payload.scenes]..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    if (scenes.isEmpty) {
      return [
        _SceneShotGroup(
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
        _SceneShotGroup(
          showHeader: !hideSingleDefaultScene,
          headerLabel: scenes[index].name.trim().isEmpty
              ? '${scenes[index].displayNumber(index + 1)}场'
              : '${scenes[index].displayNumber(index + 1)}场  ${scenes[index].name.trim()}',
          shots: [...(shotsByScene[scenes[index].id] ?? const <ShotRecord>[])]
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        ),
    ];
  }

  double _editorScale(ExportPayload payload) {
    return _clampDouble(payload.editorScalePercent / 100, 0.7, 1.5);
  }
}

class _ShotSheetLayout {
  const _ShotSheetLayout({
    required this.pageFormat,
    required this.margin,
    required this.headerSpacing,
    required this.headerRowHeight,
    required this.headerFontSize,
    required this.bodyFontSize,
    required this.headerScale,
    required this.maxTextLines,
    required this.imagePadding,
    required this.defaultRowHeight,
    required this.tableBodyHeight,
    required this.contentWidth,
    required this.tableWidth,
    required this.columnWidths,
    required this.rowHeights,
  });

  final PdfPageFormat pageFormat;
  final pw.EdgeInsets margin;
  final double headerSpacing;
  final double headerRowHeight;
  final double headerFontSize;
  final double bodyFontSize;
  final double headerScale;
  final int maxTextLines;
  final double imagePadding;
  final double defaultRowHeight;
  final double tableBodyHeight;
  final double contentWidth;
  final double tableWidth;
  final Map<String, double> columnWidths;
  final Map<String, double> rowHeights;
}

sealed class _ScenePageRow {
  const _ScenePageRow();
}

class _ScenePageHeaderRow extends _ScenePageRow {
  const _ScenePageHeaderRow(this.label);

  final String label;
}

class _ScenePageShotRow extends _ScenePageRow {
  const _ScenePageShotRow(this.shot);

  final ShotRecord shot;
}

class _SceneShotGroup {
  const _SceneShotGroup({
    required this.showHeader,
    required this.headerLabel,
    required this.shots,
  });

  final bool showHeader;
  final String headerLabel;
  final List<ShotRecord> shots;
}

double _clampDouble(double value, double min, double max) {
  return math.min(math.max(value, min), max);
}
