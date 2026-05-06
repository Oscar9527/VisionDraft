import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/error/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../features/project_workspace/domain/models/project_bundle.dart';
import 'project_bundle_manifest.dart';

class ProjectBundleService {
  ProjectBundleService({required this.logger, Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppLogger logger;
  final Uuid _uuid;

  Future<ProjectBundle> createBundle({
    required Directory rootDirectory,
    required String name,
  }) async {
    final projectId = _uuid.v4();
    final bundleRoot = Directory(p.join(rootDirectory.path, '$projectId.vdraft'));
    final now = DateTime.now();

    await Directory(p.join(bundleRoot.path, 'assets', 'originals'))
        .create(recursive: true);
    await Directory(p.join(bundleRoot.path, 'exports')).create(recursive: true);
    await File(p.join(bundleRoot.path, 'project.db')).create(recursive: true);

    final manifest = ProjectBundleManifest(
      id: projectId,
      name: name,
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
      exportCompatibilityVersion: '0.1',
    );
    final manifestFile = File(p.join(bundleRoot.path, 'manifest.json'));
    await manifestFile.writeAsString(manifest.encode());
    logger.info('Created project bundle at ${bundleRoot.path}');
    return ProjectBundle(
      id: projectId,
      name: name,
      rootPath: bundleRoot.path,
      manifestPath: manifestFile.path,
      databasePath: p.join(bundleRoot.path, 'project.db'),
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<ProjectBundle> loadBundle(Directory bundleRoot) async {
    final manifestFile = File(p.join(bundleRoot.path, 'manifest.json'));
    if (!await manifestFile.exists()) {
      throw const AppException('manifest.json not found in project bundle');
    }
    final manifestMap =
        jsonDecode(await manifestFile.readAsString()) as Map<String, Object?>;
    final manifest = ProjectBundleManifest.fromJson(manifestMap);
    return ProjectBundle(
      id: manifest.id,
      name: manifest.name,
      rootPath: bundleRoot.path,
      manifestPath: manifestFile.path,
      databasePath: p.join(bundleRoot.path, 'project.db'),
      createdAt: manifest.createdAt,
      updatedAt: manifest.updatedAt,
    );
  }

  Future<File> exportAsZip(ProjectBundle bundle, Directory targetDirectory) async {
    final sourceDir = Directory(bundle.rootPath);
    if (!await sourceDir.exists()) {
      throw AppException('Project bundle not found: ${bundle.rootPath}');
    }
    final targetPath = p.join(targetDirectory.path, '${bundle.id}.zip');
    final encoder = ZipFileEncoder()..create(targetPath);
    encoder.addDirectory(sourceDir);
    encoder.close();
    return File(targetPath);
  }

  Future<ProjectBundle> importFromZip({
    required File zipFile,
    required Directory targetDirectory,
  }) async {
    final archiveBytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(archiveBytes);
    extractArchiveToDisk(archive, targetDirectory.path);
    final directories = targetDirectory
        .listSync()
        .whereType<Directory>()
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    if (directories.isEmpty) {
      throw const AppException('No project bundle directory found after import');
    }
    return loadBundle(directories.first);
  }
}
