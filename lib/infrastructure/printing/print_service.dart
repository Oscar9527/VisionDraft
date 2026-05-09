import 'dart:typed_data';

import 'package:printing/printing.dart';

class PrintService {
  const PrintService();

  Future<void> layoutPdf(
    Uint8List bytes, {
    String name = 'VisionDraft.pdf',
  }) async {
    await Printing.layoutPdf(
      name: name,
      onLayout: (_) async => bytes,
    );
  }

  Future<void> sharePdf(
    Uint8List bytes, {
    required String filename,
    String? subject,
    String? body,
  }) async {
    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
      subject: subject,
      body: body,
    );
  }

  Future<List<Printer>> listPrinters() => Printing.listPrinters();
}
