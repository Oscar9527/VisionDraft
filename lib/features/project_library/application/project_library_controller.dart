import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/providers.dart';
import '../domain/project_library_models.dart';

class ProjectLibraryState {
  const ProjectLibraryState({
    required this.projects,
    this.query = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ProjectLibraryEntry> projects;
  final String query;
  final bool isLoading;
  final String? errorMessage;

  List<ProjectLibraryEntry> get filteredProjects {
    if (query.isEmpty) {
      return projects;
    }
    return projects
        .where((project) => project.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  ProjectLibraryState copyWith({
    List<ProjectLibraryEntry>? projects,
    String? query,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProjectLibraryState(
      projects: projects ?? this.projects,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProjectLibraryController extends Notifier<ProjectLibraryState> {
  @override
  ProjectLibraryState build() {
    Future.microtask(loadProjects);
    return const ProjectLibraryState(
      projects: [],
      isLoading: true,
    );
  }

  void updateQuery(String value) {
    state = state.copyWith(query: value);
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(projectLibraryRepositoryProvider);
    try {
      final projects = await repo.listProjects();
      state = state.copyWith(
        projects: projects,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<ProjectLibraryEntry> createProject({
    required String name,
    required String parentDirectory,
  }) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    final entry = await repo.createProject(
      name: name,
      parentDirectory: parentDirectory,
    );
    state = state.copyWith(
      projects: [entry, ...state.projects],
      isLoading: false,
      clearError: true,
    );
    return entry;
  }

  Future<ProjectLibraryEntry> registerExistingProject(String bundlePath) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    final entry = await repo.registerExistingProject(bundlePath);
    await loadProjects();
    return entry;
  }

  Future<ProjectLibraryEntry> importProjectArchive(String archivePath) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    final entry = await repo.importProjectArchive(archivePath);
    await loadProjects();
    return entry;
  }

  Future<void> deleteProject(String projectId) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    await repo.deleteProject(projectId);
    final remainingProjects = state.projects
        .where((project) => project.id != projectId)
        .toList();
    state = state.copyWith(
      projects: remainingProjects,
      isLoading: false,
      clearError: true,
    );
    await loadProjects();
  }

  Future<void> openProject(String projectId) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    await repo.markOpened(projectId);
  }
}
