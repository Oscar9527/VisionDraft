import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum DocumentOutputKind { save, share }

class SavedDocumentResult {
  const SavedDocumentResult({
    required this.file,
    required this.shared,
  });

  final File file;
  final bool shared;
}

class DocumentOutputService {
  const DocumentOutputService();

  Future<SavedDocumentResult?> saveDocument({
    required List<int> bytes,
    required String filename,
    required String initialDirectory,
    required XTypeGroup typeGroup,
    required String confirmButtonText,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final directory = await getTemporaryDirectory();
      final exportDir = Directory(p.join(directory.path, 'visiondraft_exports'));
      await exportDir.create(recursive: true);
      final file = File(p.join(exportDir.path, filename));
      await file.writeAsBytes(bytes, flush: true);
      return SavedDocumentResult(file: file, shared: false);
    }

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [typeGroup],
      initialDirectory: initialDirectory,
      suggestedName: filename,
      confirmButtonText: confirmButtonText,
      canCreateDirectories: true,
    );
    if (saveLocation == null) {
      return null;
    }
    final file = File(saveLocation.path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return SavedDocumentResult(file: file, shared: false);
  }

  Future<SavedDocumentResult?> shareDocument({
    required Uint8List bytes,
    required String filename,
    String? subject,
    String? text,
  }) async {
    final directory = await getTemporaryDirectory();
    final exportDir = Directory(p.join(directory.path, 'visiondraft_exports'));
    await exportDir.create(recursive: true);
    final file = File(p.join(exportDir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject,
        text: text,
      ),
    );
    return SavedDocumentResult(file: file, shared: true);
  }
}
