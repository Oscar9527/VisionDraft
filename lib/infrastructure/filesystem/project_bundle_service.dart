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
    required Directory parentDirectory,
    required String name,
  }) async {
    final projectId = _uuid.v4();
    final safeName = _sanitizeBundleName(name);
    final bundleRoot = Directory(p.join(parentDirectory.path, '$safeName.vdraft'));
    final now = DateTime.now();

    if (await bundleRoot.exists()) {
      throw AppException('项目目录已存在：${bundleRoot.path}');
    }

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

  String _sanitizeBundleName(String name) {
    final normalized = name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    if (normalized.isEmpty) {
      return '未命名项目';
    }
    return normalized;
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
    final targetPath = p.join(
      targetDirectory.path,
      '${_sanitizeBundleName(bundle.name)}.zip',
    );
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
    final stagingRoot = Directory(
      p.join(
        targetDirectory.path,
        '.import_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await stagingRoot.create(recursive: true);
    try {
      extractArchiveToDisk(archive, stagingRoot.path);
      final bundleDirectory = await _findImportedBundleDirectory(stagingRoot);
      if (bundleDirectory == null) {
        throw const AppException('No project bundle directory found after import');
      }
      final basename = p.basename(bundleDirectory.path);
      final targetPath = await _resolveAvailableDirectoryPath(
        targetDirectory,
        basename,
      );
      final movedDirectory = await bundleDirectory.rename(targetPath);
      return loadBundle(movedDirectory);
    } finally {
      if (await stagingRoot.exists()) {
        await stagingRoot.delete(recursive: true);
      }
    }
  }

  Future<Directory?> _findImportedBundleDirectory(Directory root) async {
    final stack = <Directory>[root];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      await for (final entity in current.list()) {
        if (entity is! Directory) {
          continue;
        }
        if (p.extension(entity.path).toLowerCase() == '.vdraft') {
          final manifestFile = File(p.join(entity.path, 'manifest.json'));
          if (await manifestFile.exists()) {
            return entity;
          }
        }
        stack.add(entity);
      }
    }
    return null;
  }

  Future<String> _resolveAvailableDirectoryPath(
    Directory parentDirectory,
    String basename,
  ) async {
    final extension = p.extension(basename);
    final stem = p.basenameWithoutExtension(basename);
    var candidate = p.join(parentDirectory.path, basename);
    var suffix = 2;
    while (await Directory(candidate).exists()) {
      candidate = p.join(parentDirectory.path, '$stem-$suffix$extension');
      suffix += 1;
    }
    return candidate;
  }
}
