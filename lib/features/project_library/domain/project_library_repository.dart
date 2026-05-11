import 'project_library_models.dart';

abstract interface class ProjectLibraryRepository {
  Future<List<ProjectLibraryEntry>> listProjects();

  Future<ProjectLibraryEntry> createProject({
    required String name,
    required String parentDirectory,
  });

  Future<ProjectLibraryEntry> registerExistingProject(String bundlePath);

  Future<ProjectLibraryEntry> importProjectArchive(String archivePath);

  Future<void> deleteProject(String projectId);

  Future<String?> findBundlePath(String projectId);

  Future<void> markOpened(String projectId);
}
