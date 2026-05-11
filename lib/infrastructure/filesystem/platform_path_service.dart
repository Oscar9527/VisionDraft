import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PlatformPathService {
  const PlatformPathService();

  Future<String?> pickProjectParentDirectory({
    required String confirmButtonText,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final directory = await getApplicationDocumentsDirectory();
      final root = Directory(p.join(directory.path, 'VisionDraftProjects'));
      await root.create(recursive: true);
      return root.path;
    }
    return getDirectoryPath(
      confirmButtonText: confirmButtonText,
      canCreateDirectories: true,
    );
  }

  Future<String?> pickExistingBundleDirectory({
    required String confirmButtonText,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return null;
    }
    return getDirectoryPath(confirmButtonText: confirmButtonText);
  }
}
