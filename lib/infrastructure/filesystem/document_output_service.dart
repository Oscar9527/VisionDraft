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

  Future<Directory> _resolveAndroidTempExportDirectory() async {
    final support = await getApplicationSupportDirectory();
    final exportDir = Directory(
      p.join(support.path, 'visiondraft', 'temp_exports'),
    );
    await exportDir.create(recursive: true);
    return exportDir;
  }

  Future<Directory> _resolveAndroidSaveDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      final exportDir = Directory(p.join(downloads.path, 'VisionDraft'));
      await exportDir.create(recursive: true);
      return exportDir;
    }
    return _resolveAndroidTempExportDirectory();
  }

  Future<File> _writeUniqueFile(
    Directory directory,
    String filename,
    List<int> bytes,
  ) async {
    final sanitizedName = filename.trim().isEmpty ? 'visiondraft.bin' : filename;
    final extension = p.extension(sanitizedName);
    final basename = p.basenameWithoutExtension(sanitizedName);

    var candidate = File(p.join(directory.path, sanitizedName));
    var suffix = 2;
    while (await candidate.exists()) {
      candidate = File(
        p.join(directory.path, '$basename-$suffix$extension'),
      );
      suffix += 1;
    }

    await candidate.parent.create(recursive: true);
    await candidate.writeAsBytes(bytes, flush: true);
    return candidate;
  }

  Future<SavedDocumentResult?> saveDocument({
    required List<int> bytes,
    required String filename,
    required String initialDirectory,
    required XTypeGroup typeGroup,
    required String confirmButtonText,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final exportDir = await _resolveAndroidSaveDirectory();
      final file = await _writeUniqueFile(exportDir, filename, bytes);
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
    final exportDir = defaultTargetPlatform == TargetPlatform.android
        ? await _resolveAndroidTempExportDirectory()
        : await getTemporaryDirectory().then(
            (directory) => Directory(
              p.join(directory.path, 'visiondraft_exports'),
            )..createSync(recursive: true),
          );
    final file = await _writeUniqueFile(exportDir, filename, bytes);
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
