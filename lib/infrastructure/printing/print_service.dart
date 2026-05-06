import 'dart:typed_data';

import 'package:printing/printing.dart';

class PrintService {
  const PrintService();

  Future<void> layoutPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<List<Printer>> listPrinters() => Printing.listPrinters();
}
