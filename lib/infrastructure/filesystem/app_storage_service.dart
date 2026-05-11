import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppStoragePaths {
  const AppStoragePaths({
    required this.supportDirectory,
    required this.cacheDirectory,
    required this.tempExportsDirectory,
    required this.projectsDirectory,
    required this.indexDatabaseFile,
  });

  final Directory supportDirectory;
  final Directory cacheDirectory;
  final Directory tempExportsDirectory;
  final Directory projectsDirectory;
  final File indexDatabaseFile;
}

class AppStorageService {
  const AppStorageService();

  Future<AppStoragePaths> resolve() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'visiondraft'));
    final cache = Directory(p.join(root.path, 'cache'));
    final exports = Directory(p.join(root.path, 'temp_exports'));
    final projects = Directory(p.join(root.path, 'projects'));
    await root.create(recursive: true);
    await cache.create(recursive: true);
    await exports.create(recursive: true);
    await projects.create(recursive: true);
    final indexDbFile = File(p.join(root.path, 'visiondraft_index.db'));
    if (!await indexDbFile.exists()) {
      await indexDbFile.create(recursive: true);
    }
    return AppStoragePaths(
      supportDirectory: root,
      cacheDirectory: cache,
      tempExportsDirectory: exports,
      projectsDirectory: projects,
      indexDatabaseFile: indexDbFile,
    );
  }
}
