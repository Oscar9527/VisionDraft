import 'project_library_models.dart';

abstract interface class ProjectLibraryRepository {
  Future<List<ProjectLibraryEntry>> listProjects();

  Future<ProjectLibraryEntry> createProject(String name);

  Future<String?> findBundlePath(String projectId);

  Future<void> markOpened(String projectId);
}
