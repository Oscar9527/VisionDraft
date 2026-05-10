import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel_community/excel_community.dart';
import 'package:xml/xml.dart';

import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../../features/project_workspace/domain/models/board_preset.dart';
import '../../features/project_workspace/domain/models/export_payload.dart';
import 'shot_sheet_export_layout.dart';

class ExcelExportService {
  const ExcelExportService();

  static const String _sheetName = '分镜单';
  static const String _sheetPath = 'xl/worksheets/sheet1.xml';
  static const String _drawingPath = 'xl/drawings/drawing1.xml';
  static const String _drawingRelsPath = 'xl/drawings/_rels/drawing1.xml.rels';
  static const String _contentTypesPath = '[Content_Types].xml';

  Future<Uint8List> generate(ExportPayload payload) async {
    final resolved = const ShotSheetExportLayoutResolver().resolve(payload);
    final fields = resolved.fields.orderedVisibleFieldKeys;
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != _sheetName) {
      excel.rename(defaultSheet, _sheetName);
    }
    final sheet = excel[_sheetName];

    final headerStyle = _headerCellStyle();
    final textStyle = _textCellStyle();
    final centeredStyle = _centerCellStyle();
    final imageStyle = _imageCellStyle();
    final sceneStyle = _sceneHeaderStyle();
    final imageAnchors = <_ExcelEmbeddedImageAnchor>[];

    for (var columnIndex = 0; columnIndex < fields.length; columnIndex++) {
      final fieldKey = fields[columnIndex];
      final widthPx = resolved.columnWidths[fieldKey] ?? 140;
      sheet.setColumnWidth(columnIndex, _columnWidthUnitsFromPixels(widthPx));
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0),
      );
      cell.value = TextCellValue(shotSheetFieldLabel(payload, fieldKey));
      cell.cellStyle = headerStyle;
    }
    sheet.setRowHeight(0, 24);

    var rowIndex = 1;
    for (final group in resolved.sceneGroups) {
      if (group.showHeader) {
        final sceneCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        );
        sceneCell.value = TextCellValue(group.headerLabel);
        sceneCell.cellStyle = sceneStyle;
        if (fields.length > 1) {
          sheet.merge(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(
              columnIndex: fields.length - 1,
              rowIndex: rowIndex,
            ),
          );
        }
        sheet.setRowHeight(rowIndex, 22);
        rowIndex += 1;
      }

      for (final shot in group.shots) {
        final rowHeightPx = resolved.rowHeights[shot.id] ?? 76;
        sheet.setRowHeight(rowIndex, _rowPointsFromPixels(rowHeightPx));
        for (var columnIndex = 0; columnIndex < fields.length; columnIndex++) {
          final fieldKey = fields[columnIndex];
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: columnIndex,
              rowIndex: rowIndex,
            ),
          );

          if (resolved.fields.isImageField(fieldKey)) {
            cell.value = TextCellValue('');
            cell.cellStyle = imageStyle;
            final asset = shotSheetAssetForField(shot, fieldKey);
            final anchor = await _buildImageAnchor(
              asset: asset,
              fitMode: payload.boardPreset.fitMode,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              cellWidthPx: _columnPixelsFromWidthUnits(
                _columnWidthUnitsFromPixels(
                  resolved.columnWidths[fieldKey] ?? 140,
                ),
              ),
              cellHeightPx: _rowPixelsFromPoints(_rowPointsFromPixels(rowHeightPx)),
            );
            if (anchor != null) {
              imageAnchors.add(anchor);
            }
            continue;
          }

          final value = shotSheetFieldValue(shot, fieldKey, payload.boardPreset);
          cell.value = _toCellValue(fieldKey, value);
          cell.cellStyle = _prefersCenteredCell(fieldKey) ? centeredStyle : textStyle;
        }
        rowIndex += 1;
      }
    }

    final encoded = excel.encode();
    final bytes = Uint8List.fromList(encoded ?? const <int>[]);
    if (imageAnchors.isEmpty) {
      return bytes;
    }
    return _embedImagesIntoWorkbook(bytes, imageAnchors);
  }

  CellStyle _headerCellStyle() {
    final border = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.grey700,
    );
    return CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.grey800,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
      fontSize: 11,
    );
  }

  CellStyle _sceneHeaderStyle() {
    final border = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.grey700,
    );
    return CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.grey200,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
      fontSize: 11,
    );
  }

  CellStyle _textCellStyle() {
    final border = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.grey400,
    );
    return CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Top,
      textWrapping: TextWrapping.WrapText,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
      fontSize: 10,
    );
  }

  CellStyle _centerCellStyle() {
    return _textCellStyle().copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
    );
  }

  CellStyle _imageCellStyle() {
    final border = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.grey400,
    );
    return CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
      backgroundColorHex: ExcelColor.grey50,
    );
  }

  bool _prefersCenteredCell(String fieldKey) {
    return switch (fieldKey) {
      'shotNo' || 'durationSec' || 'shotSize' => true,
      _ => false,
    };
  }

  CellValue _toCellValue(String fieldKey, String value) {
    if (fieldKey == 'durationSec') {
      final parsed = int.tryParse(value.replaceAll('s', '').trim());
      if (parsed != null) {
        return IntCellValue(parsed);
      }
    }
    return TextCellValue(value);
  }

  Future<_ExcelEmbeddedImageAnchor?> _buildImageAnchor({
    required AssetRef? asset,
    required ImageFitMode fitMode,
    required int rowIndex,
    required int columnIndex,
    required double cellWidthPx,
    required double cellHeightPx,
  }) async {
    final uri = asset?.uri;
    if (uri == null || uri.isEmpty) {
      return null;
    }
    final file = File(uri);
    if (!await file.exists()) {
      return null;
    }

    final ext = _supportedImageExtension(file.path);
    if (ext == null) {
      return null;
    }
    final bytes = await file.readAsBytes();
    final intrinsicWidth = (asset?.width ?? 0) > 0 ? asset!.width!.toDouble() : cellWidthPx;
    final intrinsicHeight = (asset?.height ?? 0) > 0
        ? asset!.height!.toDouble()
        : math.max(cellHeightPx, 1).toDouble();
    final crop = _resolveImageCrop(
      fitMode: fitMode,
      imageWidth: intrinsicWidth,
      imageHeight: intrinsicHeight,
      cellWidth: cellWidthPx,
      cellHeight: cellHeightPx,
    );

    return _ExcelEmbeddedImageAnchor(
      rowIndex: rowIndex,
      columnIndex: columnIndex,
      bytes: bytes,
      extension: ext,
      displayWidthPx: crop.displayWidthPx,
      displayHeightPx: crop.displayHeightPx,
      offsetXPx: crop.offsetXPx,
      offsetYPx: crop.offsetYPx,
      cropLeft: crop.cropLeft,
      cropTop: crop.cropTop,
      cropRight: crop.cropRight,
      cropBottom: crop.cropBottom,
    );
  }

  Future<Uint8List> _embedImagesIntoWorkbook(
    Uint8List workbookBytes,
    List<_ExcelEmbeddedImageAnchor> anchors,
  ) async {
    final archive = ZipDecoder().decodeBytes(workbookBytes);
    final drawingDoc = _loadXmlDocument(archive, _drawingPath, _emptyDrawingXml());
    final drawingRelsDoc = _loadXmlDocument(
      archive,
      _drawingRelsPath,
      _emptyRelationshipsXml(),
    );
    final sheetDoc = _loadXmlDocument(archive, _sheetPath, null);
    final contentTypesDoc = _loadXmlDocument(archive, _contentTypesPath, null);
    if (sheetDoc == null || contentTypesDoc == null) {
      return workbookBytes;
    }

    final drawingRoot = drawingDoc!.rootElement;
    final drawingRelsRoot = drawingRelsDoc!.rootElement;
    final sheetRoot = sheetDoc.rootElement;
    final contentTypesRoot = contentTypesDoc.rootElement;

    _ensureContentTypeDefaults(contentTypesRoot);
    _ensureWorksheetDrawingReference(sheetRoot);

    var mediaIndex = 1;
    final existingMedia = archive.files.where((file) => file.name.startsWith('xl/media/image'));
    for (final file in existingMedia) {
      final match = RegExp(r'image(\d+)').firstMatch(file.name);
      final parsed = match == null ? null : int.tryParse(match.group(1)!);
      if (parsed != null && parsed >= mediaIndex) {
        mediaIndex = parsed + 1;
      }
    }

    var relIndex = drawingRelsRoot.findElements('Relationship').length + 1;
    var pictureIndex = 1;
    for (final anchor in anchors) {
      final mediaPath = 'xl/media/image$mediaIndex.${anchor.extension}';
      final relId = 'rId$relIndex';
      mediaIndex += 1;
      relIndex += 1;

      _upsertArchiveBytes(archive, mediaPath, anchor.bytes);
      drawingRelsRoot.children.add(
        XmlElement(
          XmlName('Relationship'),
          [
            XmlAttribute(XmlName('Id'), relId),
            XmlAttribute(
              XmlName('Type'),
              'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
            ),
            XmlAttribute(XmlName('Target'), '../media/${mediaPath.split('/').last}'),
          ],
        ),
      );

      drawingRoot.children.add(
        _buildTwoCellAnchor(anchor, relId: relId, pictureIndex: pictureIndex),
      );
      pictureIndex += 1;
    }

    _upsertArchiveString(
      archive,
      _drawingPath,
      _xmlWithDeclaration(drawingDoc),
    );
    _upsertArchiveString(
      archive,
      _drawingRelsPath,
      _xmlWithDeclaration(drawingRelsDoc),
    );
    _upsertArchiveString(
      archive,
      _sheetPath,
      _xmlWithDeclaration(sheetDoc),
    );
    _upsertArchiveString(
      archive,
      _contentTypesPath,
      _xmlWithDeclaration(contentTypesDoc),
    );

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  XmlDocument? _loadXmlDocument(
    Archive archive,
    String path,
    String? fallback,
  ) {
    final file = archive.find(path);
    if (file == null && fallback == null) {
      return null;
    }
    final content = file == null
        ? fallback!
        : String.fromCharCodes(file.content);
    return XmlDocument.parse(content);
  }

  void _ensureContentTypeDefaults(XmlElement root) {
    final existing = {
      for (final element in root.findElements('Default'))
        element.getAttribute('Extension')?.toLowerCase(),
    };
    final defaults = <String, String>{
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
    };
    for (final entry in defaults.entries) {
      if (existing.contains(entry.key)) {
        continue;
      }
      root.children.add(
        XmlElement(
          XmlName('Default'),
          [
            XmlAttribute(XmlName('Extension'), entry.key),
            XmlAttribute(XmlName('ContentType'), entry.value),
          ],
        ),
      );
    }
  }

  void _ensureWorksheetDrawingReference(XmlElement sheetRoot) {
    final hasDrawing = sheetRoot.children.whereType<XmlElement>().any(
      (element) => element.name.local == 'drawing',
    );
    if (hasDrawing) {
      return;
    }
    final drawingElement = XmlElement(
      XmlName('drawing'),
      [XmlAttribute(XmlName('id', 'r'), 'rId1')],
    );
    final pageMarginsIndex = sheetRoot.children.indexWhere(
      (node) => node is XmlElement && node.name.local == 'pageMargins',
    );
    if (pageMarginsIndex == -1) {
      sheetRoot.children.add(drawingElement);
    } else {
      sheetRoot.children.insert(pageMarginsIndex, drawingElement);
    }
  }

  XmlElement _buildTwoCellAnchor(
    _ExcelEmbeddedImageAnchor anchor, {
    required String relId,
    required int pictureIndex,
  }) {
    final fromColOff = _emuFromPixels(anchor.offsetXPx);
    final fromRowOff = _emuFromPixels(anchor.offsetYPx);
    final toColOff = _emuFromPixels(anchor.offsetXPx + anchor.displayWidthPx);
    final toRowOff = _emuFromPixels(anchor.offsetYPx + anchor.displayHeightPx);

    final blipChildren = <XmlNode>[
      XmlElement(XmlName('blip', 'a'), [
        XmlAttribute(XmlName('embed', 'r'), relId),
      ]),
    ];
    if (anchor.hasCrop) {
      blipChildren.add(
        XmlElement(XmlName('srcRect', 'a'), [
          if (anchor.cropLeft > 0)
            XmlAttribute(XmlName('l'), anchor.cropLeft.toString()),
          if (anchor.cropTop > 0)
            XmlAttribute(XmlName('t'), anchor.cropTop.toString()),
          if (anchor.cropRight > 0)
            XmlAttribute(XmlName('r'), anchor.cropRight.toString()),
          if (anchor.cropBottom > 0)
            XmlAttribute(XmlName('b'), anchor.cropBottom.toString()),
        ]),
      );
    }
    blipChildren.add(
      XmlElement(
        XmlName('stretch', 'a'),
        [],
        [XmlElement(XmlName('fillRect', 'a'))],
      ),
    );

    return XmlElement(
      XmlName('twoCellAnchor', 'xdr'),
      [XmlAttribute(XmlName('editAs'), 'oneCell')],
      [
        XmlElement(XmlName('from', 'xdr'), [], [
          XmlElement(XmlName('col', 'xdr'), [], [XmlText('${anchor.columnIndex}')]),
          XmlElement(XmlName('colOff', 'xdr'), [], [XmlText('$fromColOff')]),
          XmlElement(XmlName('row', 'xdr'), [], [XmlText('${anchor.rowIndex}')]),
          XmlElement(XmlName('rowOff', 'xdr'), [], [XmlText('$fromRowOff')]),
        ]),
        XmlElement(XmlName('to', 'xdr'), [], [
          XmlElement(XmlName('col', 'xdr'), [], [XmlText('${anchor.columnIndex}')]),
          XmlElement(XmlName('colOff', 'xdr'), [], [XmlText('$toColOff')]),
          XmlElement(XmlName('row', 'xdr'), [], [XmlText('${anchor.rowIndex}')]),
          XmlElement(XmlName('rowOff', 'xdr'), [], [XmlText('$toRowOff')]),
        ]),
        XmlElement(XmlName('pic', 'xdr'), [], [
          XmlElement(XmlName('nvPicPr', 'xdr'), [], [
            XmlElement(XmlName('cNvPr', 'xdr'), [
              XmlAttribute(XmlName('id'), '$pictureIndex'),
              XmlAttribute(XmlName('name'), 'Picture $pictureIndex'),
            ]),
            XmlElement(XmlName('cNvPicPr', 'xdr'), [], [
              XmlElement(XmlName('picLocks', 'a'), [
                XmlAttribute(XmlName('noChangeAspect'), '1'),
              ]),
            ]),
          ]),
          XmlElement(XmlName('blipFill', 'xdr'), [], blipChildren),
          XmlElement(XmlName('spPr', 'xdr'), [], [
            XmlElement(XmlName('xfrm', 'a'), [], [
              XmlElement(XmlName('off', 'a'), [
                XmlAttribute(XmlName('x'), '0'),
                XmlAttribute(XmlName('y'), '0'),
              ]),
              XmlElement(XmlName('ext', 'a'), [
                XmlAttribute(XmlName('cx'), '${_emuFromPixels(anchor.displayWidthPx)}'),
                XmlAttribute(XmlName('cy'), '${_emuFromPixels(anchor.displayHeightPx)}'),
              ]),
            ]),
            XmlElement(XmlName('prstGeom', 'a'), [
              XmlAttribute(XmlName('prst'), 'rect'),
            ], [
              XmlElement(XmlName('avLst', 'a')),
            ]),
          ]),
        ]),
        XmlElement(XmlName('clientData', 'xdr')),
      ],
    );
  }

  String? _supportedImageExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'png',
      'jpg' => 'jpg',
      'jpeg' => 'jpeg',
      _ => null,
    };
  }

  _ImagePlacement _resolveImageCrop({
    required ImageFitMode fitMode,
    required double imageWidth,
    required double imageHeight,
    required double cellWidth,
    required double cellHeight,
  }) {
    final safeImageWidth = math.max(imageWidth, 1);
    final safeImageHeight = math.max(imageHeight, 1);
    final safeCellWidth = math.max(cellWidth, 1).toDouble();
    final safeCellHeight = math.max(cellHeight, 1).toDouble();
    if (fitMode == ImageFitMode.cover) {
      final imageRatio = safeImageWidth / safeImageHeight;
      final cellRatio = safeCellWidth / safeCellHeight;
      var cropLeft = 0;
      var cropTop = 0;
      var cropRight = 0;
      var cropBottom = 0;
      if (imageRatio > cellRatio) {
        final visibleWidth = safeImageHeight * cellRatio;
        final trimRatio = (safeImageWidth - visibleWidth) / (2 * safeImageWidth);
        final crop = (trimRatio * 100000).round();
        cropLeft = crop;
        cropRight = crop;
      } else if (imageRatio < cellRatio) {
        final visibleHeight = safeImageWidth / cellRatio;
        final trimRatio = (safeImageHeight - visibleHeight) / (2 * safeImageHeight);
        final crop = (trimRatio * 100000).round();
        cropTop = crop;
        cropBottom = crop;
      }
      return _ImagePlacement(
        displayWidthPx: safeCellWidth,
        displayHeightPx: safeCellHeight,
        offsetXPx: 0,
        offsetYPx: 0,
        cropLeft: cropLeft,
        cropTop: cropTop,
        cropRight: cropRight,
        cropBottom: cropBottom,
      );
    }

    final scale = math.min(safeCellWidth / safeImageWidth, safeCellHeight / safeImageHeight);
    final displayWidth = safeImageWidth * scale;
    final displayHeight = safeImageHeight * scale;
    return _ImagePlacement(
      displayWidthPx: displayWidth,
      displayHeightPx: displayHeight,
      offsetXPx: (safeCellWidth - displayWidth) / 2,
      offsetYPx: (safeCellHeight - displayHeight) / 2,
    );
  }

  double _columnWidthUnitsFromPixels(double pixels) {
    return clampShotSheetDouble((math.max(pixels, 40) - 5) / 7, 6.5, 48);
  }

  double _columnPixelsFromWidthUnits(double widthUnits) {
    return math.max(40, widthUnits * 7 + 5);
  }

  double _rowPointsFromPixels(double pixels) {
    return clampShotSheetDouble(pixels * 0.75, 18, 140);
  }

  double _rowPixelsFromPoints(double points) {
    return points * 96 / 72;
  }

  int _emuFromPixels(double pixels) {
    return (pixels * 9525).round();
  }

  void _upsertArchiveString(Archive archive, String path, String content) {
    _upsertArchiveBytes(archive, path, Uint8List.fromList(content.codeUnits));
  }

  void _upsertArchiveBytes(Archive archive, String path, List<int> bytes) {
    final existing = archive.find(path);
    if (existing != null) {
      archive.removeFile(existing);
    }
    archive.addFile(ArchiveFile(path, bytes.length, Uint8List.fromList(bytes)));
  }

  String _xmlWithDeclaration(XmlDocument document) {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '${document.rootElement.toXmlString(pretty: false)}';
  }

  String _emptyDrawingXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" '
        'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>';
  }

  String _emptyRelationshipsXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"></Relationships>';
  }
}

class _ExcelEmbeddedImageAnchor {
  const _ExcelEmbeddedImageAnchor({
    required this.rowIndex,
    required this.columnIndex,
    required this.bytes,
    required this.extension,
    required this.displayWidthPx,
    required this.displayHeightPx,
    required this.offsetXPx,
    required this.offsetYPx,
    required this.cropLeft,
    required this.cropTop,
    required this.cropRight,
    required this.cropBottom,
  });

  final int rowIndex;
  final int columnIndex;
  final Uint8List bytes;
  final String extension;
  final double displayWidthPx;
  final double displayHeightPx;
  final double offsetXPx;
  final double offsetYPx;
  final int cropLeft;
  final int cropTop;
  final int cropRight;
  final int cropBottom;

  bool get hasCrop =>
      cropLeft > 0 || cropTop > 0 || cropRight > 0 || cropBottom > 0;
}

class _ImagePlacement {
  const _ImagePlacement({
    required this.displayWidthPx,
    required this.displayHeightPx,
    required this.offsetXPx,
    required this.offsetYPx,
    this.cropLeft = 0,
    this.cropTop = 0,
    this.cropRight = 0,
    this.cropBottom = 0,
  });

  final double displayWidthPx;
  final double displayHeightPx;
  final double offsetXPx;
  final double offsetYPx;
  final int cropLeft;
  final int cropTop;
  final int cropRight;
  final int cropBottom;
}

