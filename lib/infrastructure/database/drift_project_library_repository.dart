import 'dart:io';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../core/logging/app_logger.dart';
import '../../features/project_library/domain/project_library_models.dart';
import '../../features/project_library/domain/project_library_repository.dart';
import '../../features/project_workspace/domain/models/project_bundle.dart';
import '../filesystem/app_storage_service.dart';
import '../filesystem/project_bundle_service.dart';
import 'app_index_database.dart';
import 'drift_project_workspace_repository.dart';

class DriftProjectLibraryRepository implements ProjectLibraryRepository {
  DriftProjectLibraryRepository({
    required this.storageService,
    required this.bundleService,
    required this.workspaceRepository,
    required this.indexDatabaseFactory,
    required this.logger,
  });

  final AppStorageService storageService;
  final ProjectBundleService bundleService;
  final DriftProjectWorkspaceRepository workspaceRepository;
  final Future<AppIndexDatabase> Function() indexDatabaseFactory;
  final AppLogger logger;

  @override
  Future<List<ProjectLibraryEntry>> listProjects() async {
    final db = await indexDatabaseFactory();
    try {
      final paths = await storageService.resolve();
      await _syncLegacyProjects(paths.supportDirectory, db);
      await _pruneMissingIndexEntries(db);
      final rows = await (db.select(db.recentProjects)
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
          .get();
      return rows.map(_mapRow).toList();
    } finally {
      await db.close();
    }
  }

  @override
  Future<ProjectLibraryEntry> createProject({
    required String name,
    required String parentDirectory,
  }) async {
    final bundle = await bundleService.createBundle(
      parentDirectory: Directory(parentDirectory),
      name: name,
    );
    await workspaceRepository.initializeProject(bundle);
    final db = await indexDatabaseFactory();
    try {
      await _upsertBundle(db, bundle);
      final row = await (db.select(db.recentProjects)
            ..where((tbl) => tbl.id.equals(bundle.id)))
          .getSingle();
      return _mapRow(row);
    } finally {
      await db.close();
    }
  }

  @override
  Future<ProjectLibraryEntry> registerExistingProject(String bundlePath) async {
    final directory = Directory(bundlePath);
    if (!await directory.exists()) {
      throw const FileSystemException('项目目录不存在');
    }
    if (p.extension(directory.path).toLowerCase() != '.vdraft') {
      throw const FileSystemException('请选择 .vdraft 项目目录');
    }

    final bundle = await bundleService.loadBundle(directory);
    final db = await indexDatabaseFactory();
    try {
      await _upsertBundle(db, bundle);
      final row = await (db.select(db.recentProjects)
            ..where((tbl) => tbl.id.equals(bundle.id)))
          .getSingle();
      return _mapRow(row);
    } finally {
      await db.close();
    }
  }

  @override
  Future<ProjectLibraryEntry> importProjectArchive(String archivePath) async {
    final archiveFile = File(archivePath);
    if (!await archiveFile.exists()) {
      throw const FileSystemException('项目包不存在');
    }

    final paths = await storageService.resolve();
    final bundle = await bundleService.importFromZip(
      zipFile: archiveFile,
      targetDirectory: paths.projectsDirectory,
    );
    final db = await indexDatabaseFactory();
    try {
      await _upsertBundle(db, bundle);
      final row = await (db.select(db.recentProjects)
            ..where((tbl) => tbl.id.equals(bundle.id)))
          .getSingle();
      return _mapRow(row);
    } finally {
      await db.close();
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await workspaceRepository.compactProject(projectId);
    } catch (error) {
      logger.warn('Compact project failed before delete ($projectId): $error');
    }

    final db = await indexDatabaseFactory();
    try {
      final row = await (db.select(db.recentProjects)
            ..where((tbl) => tbl.id.equals(projectId)))
          .getSingleOrNull();

      if (row != null) {
        final bundleDirectory = Directory(row.bundlePath);
        if (await bundleDirectory.exists()) {
          await _deleteDirectoryWithRetry(bundleDirectory);
        }
      }

      await db.transaction(() async {
        await (db.delete(db.projectSearchIndex)
              ..where((tbl) => tbl.projectId.equals(projectId)))
            .go();
        await (db.delete(db.trashEntries)..where((tbl) => tbl.id.equals(projectId)))
            .go();
        await (db.delete(db.recentProjects)
              ..where((tbl) => tbl.id.equals(projectId)))
            .go();
      });
    } finally {
      await db.close();
    }
  }

  @override
  Future<String?> findBundlePath(String projectId) async {
    final db = await indexDatabaseFactory();
    try {
      final row = await (db.select(db.recentProjects)
            ..where((tbl) => tbl.id.equals(projectId)))
          .getSingleOrNull();
      return row?.bundlePath;
    } finally {
      await db.close();
    }
  }

  @override
  Future<void> markOpened(String projectId) async {
    final db = await indexDatabaseFactory();
    try {
      await (db.update(db.recentProjects)
            ..where((tbl) => tbl.id.equals(projectId)))
          .write(
        RecentProjectsCompanion(
          lastOpenedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } finally {
      await db.close();
    }
  }

  Future<void> _syncLegacyProjects(
    Directory supportDirectory,
    AppIndexDatabase db,
  ) async {
    final projectsDirectory = Directory(p.join(supportDirectory.path, 'projects'));
    if (!await projectsDirectory.exists()) {
      return;
    }

    final bundles = projectsDirectory
        .listSync()
        .whereType<Directory>()
        .where((dir) => p.extension(dir.path) == '.vdraft');

    for (final dir in bundles) {
      try {
        final bundle = await bundleService.loadBundle(dir);
        await _upsertBundle(db, bundle);
      } catch (error) {
        logger.warn('Skipping invalid bundle ${dir.path}: $error');
      }
    }
  }

  Future<void> _pruneMissingIndexEntries(AppIndexDatabase db) async {
    final rows = await db.select(db.recentProjects).get();
    for (final row in rows) {
      if (await Directory(row.bundlePath).exists()) {
        continue;
      }
      await (db.delete(db.projectSearchIndex)
            ..where((tbl) => tbl.projectId.equals(row.id)))
          .go();
      await (db.delete(db.recentProjects)..where((tbl) => tbl.id.equals(row.id)))
          .go();
    }
  }

  Future<void> _upsertBundle(AppIndexDatabase db, ProjectBundle bundle) async {
    await db.into(db.recentProjects).insertOnConflictUpdate(
          RecentProjectsCompanion.insert(
            id: bundle.id,
            name: bundle.name,
            bundlePath: bundle.rootPath,
            updatedAt: bundle.updatedAt,
            lastOpenedAt: bundle.updatedAt,
          ),
        );

    await db.into(db.projectSearchIndex).insertOnConflictUpdate(
          ProjectSearchIndexCompanion.insert(
            projectId: bundle.id,
            searchText: '${bundle.name} ${bundle.rootPath}',
          ),
        );
  }

  Future<void> _deleteDirectoryWithRetry(Directory directory) async {
    FileSystemException? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        await directory.delete(recursive: true);
        return;
      } on FileSystemException catch (error) {
        lastError = error;
        await Future<void>.delayed(Duration(milliseconds: 120 * (attempt + 1)));
      }
    }
    if (lastError != null) {
      throw lastError;
    }
  }

  ProjectLibraryEntry _mapRow(RecentProject row) {
    return ProjectLibraryEntry(
      id: row.id,
      name: row.name,
      path: row.bundlePath,
      updatedAtLabel: _formatDate(row.updatedAt),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);
    final formatter = DateFormat('HH:mm');

    if (date == today) {
      return '今天 ${formatter.format(dateTime)}';
    }
    if (date == today.subtract(const Duration(days: 1))) {
      return '昨天 ${formatter.format(dateTime)}';
    }

    return DateFormat('MM-dd HH:mm').format(dateTime);
  }
}
