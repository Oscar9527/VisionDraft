import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../app/layout/app_breakpoints.dart';
import '../../../../core/widgets/surface_card.dart';
import '../widgets/project_card.dart';

class ProjectLibraryPage extends ConsumerWidget {
  const ProjectLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectLibraryProvider);
    final controller = ref.read(projectLibraryProvider.notifier);
    final columns = AppBreakpoints.isDesktop(context) ? 4 : 2;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '我的项目',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onChanged: controller.updateQuery,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: '搜索项目名称',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: state.filteredProjects.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return SurfaceCard(
                              child: InkWell(
                                onTap: () async {
                                  final entry =
                                      await controller.createProject('新建项目');
                                  if (!context.mounted) {
                                    return;
                                  }
                                  context.go('/projects/${entry.id}/editor');
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Center(
                                  child: Icon(Icons.add, size: 42),
                                ),
                              ),
                            );
                          }

                          final project = state.filteredProjects[index - 1];
                          return ProjectCard(
                            project: project,
                            onOpen: () async {
                              await controller.openProject(project.id);
                              if (!context.mounted) {
                                return;
                              }
                              context.go('/projects/${project.id}/editor');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
