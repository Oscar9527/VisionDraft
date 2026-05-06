import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/providers.dart';
import '../domain/project_library_models.dart';

class ProjectLibraryState {
  const ProjectLibraryState({
    required this.projects,
    this.query = '',
    this.isLoading = false,
  });

  final List<ProjectLibraryEntry> projects;
  final String query;
  final bool isLoading;

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
  }) {
    return ProjectLibraryState(
      projects: projects ?? this.projects,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true);
    final repo = ref.read(projectLibraryRepositoryProvider);
    final projects = await repo.listProjects();
    state = state.copyWith(
      projects: projects,
      isLoading: false,
    );
  }

  Future<ProjectLibraryEntry> createProject(String name) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    final entry = await repo.createProject(name);
    state = state.copyWith(
      projects: [entry, ...state.projects],
      isLoading: false,
    );
    return entry;
  }

  Future<void> openProject(String projectId) async {
    final repo = ref.read(projectLibraryRepositoryProvider);
    await repo.markOpened(projectId);
  }
}
