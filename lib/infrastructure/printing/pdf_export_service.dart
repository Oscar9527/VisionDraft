import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../features/project_workspace/domain/models/export_payload.dart';

class PdfExportService {
  const PdfExportService();

  Future<Uint8List> generate(ExportPayload payload) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: _titleForType(payload.documentType)),
          pw.Text('项目：${payload.bundle.name}'),
          pw.SizedBox(height: 12),
          ...payload.shots.map(
            (shot) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                '镜头 ${shot.shotNo} | ${shot.shotSize} | ${shot.durationSec}s | ${shot.content}',
              ),
            ),
          ),
        ],
      ),
    );
    return document.save();
  }

  String _titleForType(ExportDocumentType type) {
    return switch (type) {
      ExportDocumentType.storyboard => '故事板联系表',
      ExportDocumentType.shootingPlan => '拍摄计划单',
      ExportDocumentType.callSheet => '拍摄通告单',
    };
  }
}
