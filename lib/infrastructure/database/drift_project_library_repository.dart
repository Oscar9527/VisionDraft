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
    final paths = await storageService.resolve();
    final db = await indexDatabaseFactory();
    try {
      await _syncBundleDirectories(paths.projectsDirectory, db);
      final rows = await (db.select(db.recentProjects)
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
          .get();
      return rows.map(_mapRow).toList();
    } finally {
      await db.close();
    }
  }

  @override
  Future<ProjectLibraryEntry> createProject(String name) async {
    final paths = await storageService.resolve();
    final bundle = await bundleService.createBundle(
      rootDirectory: paths.projectsDirectory,
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

  Future<void> _syncBundleDirectories(
    Directory projectsDirectory,
    AppIndexDatabase db,
  ) async {
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
