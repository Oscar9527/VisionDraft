import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppStoragePaths {
  const AppStoragePaths({
    required this.supportDirectory,
    required this.projectsDirectory,
    required this.cacheDirectory,
    required this.exportsDirectory,
    required this.indexDatabaseFile,
  });

  final Directory supportDirectory;
  final Directory projectsDirectory;
  final Directory cacheDirectory;
  final Directory exportsDirectory;
  final File indexDatabaseFile;
}

class AppStorageService {
  const AppStorageService();

  Future<AppStoragePaths> resolve() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'visiondraft'));
    final projects = Directory(p.join(root.path, 'projects'));
    final cache = Directory(p.join(root.path, 'cache'));
    final exports = Directory(p.join(root.path, 'exports'));
    await root.create(recursive: true);
    await projects.create(recursive: true);
    await cache.create(recursive: true);
    await exports.create(recursive: true);
    final indexDbFile = File(p.join(root.path, 'visiondraft_index.db'));
    if (!await indexDbFile.exists()) {
      await indexDbFile.create(recursive: true);
    }
    return AppStoragePaths(
      supportDirectory: root,
      projectsDirectory: projects,
      cacheDirectory: cache,
      exportsDirectory: exports,
      indexDatabaseFile: indexDbFile,
    );
  }
}
