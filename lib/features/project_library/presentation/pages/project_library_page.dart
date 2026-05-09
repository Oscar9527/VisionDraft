import 'dart:async';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../app/layout/app_breakpoints.dart';
import '../../../../app/theme/theme_mode_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/project_library_models.dart';
import '../widgets/project_card.dart';

class ProjectLibraryPage extends ConsumerWidget {
  const ProjectLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectLibraryProvider);
    final controller = ref.read(projectLibraryProvider.notifier);

    void openProject(String projectId) {
      unawaited(controller.openProject(projectId).catchError((_) {}));
      context.go('/projects/$projectId/editor');
    }

    Future<void> createProject() async {
      final projectName = await _showProjectNameDialog(context);
      if (projectName == null || projectName.trim().isEmpty) {
        return;
      }

      final parentDirectory = await getDirectoryPath(
        confirmButtonText: '选择项目保存位置',
        canCreateDirectories: true,
      );
      if (parentDirectory == null || parentDirectory.isEmpty) {
        return;
      }

      try {
        final entry = await controller.createProject(
          name: projectName.trim(),
          parentDirectory: parentDirectory,
        );
        if (!context.mounted) {
          return;
        }
        context.go('/projects/${entry.id}/editor');
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建项目失败：$error')));
      }
    }

    Future<void> openExistingProject() async {
      final bundlePath = await getDirectoryPath(confirmButtonText: '打开已有项目');
      if (bundlePath == null || bundlePath.isEmpty) {
        return;
      }

      try {
        final entry = await controller.registerExistingProject(bundlePath);
        if (!context.mounted) {
          return;
        }
        context.go('/projects/${entry.id}/editor');
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打开项目失败：$error')));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LibraryHeader(
                query: state.query,
                onQueryChanged: controller.updateQuery,
                onCreateProject: createProject,
                onOpenExistingProject: openExistingProject,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _ProjectLibraryContent(
                  isLoading: state.isLoading,
                  errorMessage: state.errorMessage,
                  projects: state.filteredProjects,
                  hasQuery: state.query.isNotEmpty,
                  onRetry: controller.loadProjects,
                  onCreateProject: createProject,
                  onOpenExistingProject: openExistingProject,
                  onOpenProject: openProject,
                  onDeleteProject: (project) async {
                    final confirmed =
                        await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('删除项目'),
                              content: Text(
                                '将永久删除“${project.name}”以及它的项目目录，此操作不可恢复。是否继续？',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('取消'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('删除'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                    if (!confirmed) {
                      return;
                    }

                    try {
                      await controller.deleteProject(project.id);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已删除项目：${project.name}')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('删除失败，请关闭占用该项目文件的窗口后重试。\n$error'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showProjectNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: '新建项目');
    String? result;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('新建项目'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: '项目名称'),
            onSubmitted: (_) {
              result = controller.text.trim();
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                result = controller.text.trim();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('下一步'),
            ),
          ],
        );
      },
    );

    return result;
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.query,
    required this.onQueryChanged,
    required this.onCreateProject,
    required this.onOpenExistingProject,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function() onCreateProject;
  final Future<void> Function() onOpenExistingProject;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1120;

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          spacing: 12,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的项目',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '本地项目包 · 离线可用 · 新建时自主选择保存位置',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: compact ? 300 : 340,
                  child: TextFormField(
                    initialValue: query,
                    onChanged: onQueryChanged,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: '搜索项目名称',
                      isDense: true,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenExistingProject,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('打开已有项目'),
                ),
                const ThemeModeButton(),
                FilledButton.icon(
                  onPressed: onCreateProject,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建项目'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProjectLibraryContent extends StatelessWidget {
  const _ProjectLibraryContent({
    required this.isLoading,
    required this.errorMessage,
    required this.projects,
    required this.hasQuery,
    required this.onRetry,
    required this.onCreateProject,
    required this.onOpenExistingProject,
    required this.onOpenProject,
    required this.onDeleteProject,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ProjectLibraryEntry> projects;
  final bool hasQuery;
  final Future<void> Function() onRetry;
  final Future<void> Function() onCreateProject;
  final Future<void> Function() onOpenExistingProject;
  final void Function(String projectId) onOpenProject;
  final Future<void> Function(ProjectLibraryEntry project) onDeleteProject;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('项目库加载失败', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SelectableText(errorMessage!),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (projects.isEmpty) {
      if (!hasQuery) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 2 : 1;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 2 ? 1.95 : 2.15,
              children: [
                _EmptyActionCard(
                  icon: Icons.add_box_outlined,
                  title: '创建第一个项目',
                  description: '创建新的 VisionDraft 本地项目，下一步直接选择保存位置。',
                  buttonLabel: '新建项目',
                  onPressed: onCreateProject,
                  primary: true,
                ),
                _EmptyActionCard(
                  icon: Icons.folder_open_rounded,
                  title: '打开已有项目',
                  description: '选择任意 .vdraft 项目目录，注册到项目库后立刻继续编辑。',
                  buttonLabel: '打开已有项目',
                  onPressed: onOpenExistingProject,
                ),
                const _EmptyInfoCard(
                  title: '本地优先',
                  lines: [
                    '所有项目以独立 .vdraft 目录保存',
                    '新建项目时每次手动选择保存位置',
                    '关闭软件后数据仍保留在本地',
                  ],
                ),
                const _EmptyInfoCard(
                  title: '工作流建议',
                  lines: ['先建立项目并导入参考图', '在分镜制作页完成镜头表', '再进入拍摄计划和导出通告'],
                ),
              ],
            );
          },
        );
      }

      return SurfaceCard(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasQuery
                      ? Icons.search_off_rounded
                      : Icons.video_library_outlined,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  hasQuery ? '没有匹配的项目' : '还没有项目',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  hasQuery
                      ? '换个关键词试试，或者直接创建新项目。'
                      : '新建项目后会创建一个独立的 .vdraft 项目目录。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onCreateProject,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(hasQuery ? '新建项目' : '创建第一个项目'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppBreakpoints.isDesktop(context);
        final minTileWidth = isDesktop ? 276.0 : 248.0;
        final columns = math.max(
          1,
          (constraints.maxWidth / minTileWidth).floor(),
        );
        const tileExtent = 244.0;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: tileExtent,
          ),
          itemCount: projects.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _CreateProjectCard(onPressed: onCreateProject);
            }

            final project = projects[index - 1];
            return ProjectCard(
              project: project,
              onOpen: () => onOpenProject(project.id),
              onDelete: () => onDeleteProject(project),
            );
          },
        );
      },
    );
  }
}

class _CreateProjectCard extends StatelessWidget {
  const _CreateProjectCard({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfaceCard(
      child: SizedBox.expand(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 26,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text('新建项目', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  '创建新的 VisionDraft 本地项目，下一步会先让你选择保存位置。',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('开始创建'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyActionCard extends StatelessWidget {
  const _EmptyActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final Future<void> Function() onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  (primary
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest)
                      .withValues(alpha: primary ? 0.72 : 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 26,
              color: primary ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          if (primary)
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(buttonLabel),
            )
          else
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(buttonLabel),
            ),
        ],
      ),
    );
  }
}

class _EmptyInfoCard extends StatelessWidget {
  const _EmptyInfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(line, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
