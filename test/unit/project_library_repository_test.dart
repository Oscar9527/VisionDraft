import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vision_draft/core/logging/app_logger.dart';
import 'package:vision_draft/infrastructure/database/app_index_database.dart';
import 'package:vision_draft/infrastructure/database/drift_project_library_repository.dart';
import 'package:vision_draft/infrastructure/database/drift_project_workspace_repository.dart';
import 'package:vision_draft/infrastructure/filesystem/app_storage_service.dart';
import 'package:vision_draft/infrastructure/filesystem/project_bundle_service.dart';

class _FakeAppStorageService extends AppStorageService {
  _FakeAppStorageService(this.paths);

  final AppStoragePaths paths;

  @override
  Future<AppStoragePaths> resolve() async => paths;
}

void main() {
  test('project library repository creates and deletes bundle directory', () async {
    final tempRoot = await Directory.systemTemp.createTemp('visiondraft-library');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final supportDirectory = Directory('${tempRoot.path}/support')..createSync(recursive: true);
    final cacheDirectory = Directory('${supportDirectory.path}/cache')
      ..createSync(recursive: true);
    final exportsDirectory = Directory('${supportDirectory.path}/temp_exports')
      ..createSync(recursive: true);
    final indexFile = File('${supportDirectory.path}/visiondraft_index.db')
      ..createSync(recursive: true);
    final projectParent = Directory('${tempRoot.path}/projects')
      ..createSync(recursive: true);

    final storageService = _FakeAppStorageService(
      AppStoragePaths(
        supportDirectory: supportDirectory,
        cacheDirectory: cacheDirectory,
        tempExportsDirectory: exportsDirectory,
        projectsDirectory: projectParent,
        indexDatabaseFile: indexFile,
      ),
    );

    final logger = AppLogger();
    final bundleService = ProjectBundleService(logger: logger);
    Future<AppIndexDatabase> indexFactory() async => AppIndexDatabase(indexFile);
    final workspaceRepository = DriftProjectWorkspaceRepository(
      bundleService: bundleService,
      indexDatabaseFactory: indexFactory,
    );
    final repository = DriftProjectLibraryRepository(
      storageService: storageService,
      bundleService: bundleService,
      workspaceRepository: workspaceRepository,
      indexDatabaseFactory: indexFactory,
      logger: logger,
    );

    final before = await repository.listProjects();
    final created = await repository.createProject(
      name: 'Repository Smoke',
      parentDirectory: projectParent.path,
    );
    final createdDirectory = Directory(created.path);
    final afterCreate = await repository.listProjects();

    expect(before.any((project) => project.id == created.id), isFalse);
    expect(await createdDirectory.exists(), isTrue);
    expect(afterCreate.any((project) => project.id == created.id), isTrue);

    await repository.deleteProject(created.id);
    final afterDelete = await repository.listProjects();

    expect(await createdDirectory.exists(), isFalse);
    expect(afterDelete.any((project) => project.id == created.id), isFalse);
  });
}
