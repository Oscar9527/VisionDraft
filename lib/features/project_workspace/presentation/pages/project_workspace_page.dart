import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../app/layout/app_breakpoints.dart';
import '../../../../app/theme/theme_mode_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../export/presentation/pages/export_page.dart';
import '../../../shooting_plan/presentation/pages/shooting_plan_page.dart';
import '../../../storyboard_board/presentation/pages/storyboard_board_page.dart';
import '../../../storyboard_editor/presentation/pages/storyboard_editor_page.dart';
import '../../domain/models/project_bundle.dart';
import '../widgets/workspace_header.dart';

enum WorkspaceSection { editor, board, shootingPlan, callSheet }

extension WorkspaceSectionX on WorkspaceSection {
  String get path => switch (this) {
    WorkspaceSection.editor => 'editor',
    WorkspaceSection.board => 'board',
    WorkspaceSection.shootingPlan => 'shooting-plan',
    WorkspaceSection.callSheet => 'call-sheet',
  };

  String get label => switch (this) {
    WorkspaceSection.editor => '分镜制作',
    WorkspaceSection.board => '故事板',
    WorkspaceSection.shootingPlan => '拍摄计划',
    WorkspaceSection.callSheet => '导出',
  };

  IconData get icon => switch (this) {
    WorkspaceSection.editor => Icons.table_chart_outlined,
    WorkspaceSection.board => Icons.dashboard_outlined,
    WorkspaceSection.shootingPlan => Icons.schedule_outlined,
    WorkspaceSection.callSheet => Icons.ios_share_outlined,
  };

  static WorkspaceSection fromPath(String? value) {
    return WorkspaceSection.values.firstWhere(
      (section) => section.path == value,
      orElse: () => WorkspaceSection.editor,
    );
  }
}

class ProjectWorkspacePage extends ConsumerWidget {
  const ProjectWorkspacePage({
    super.key,
    required this.projectId,
    required this.initialSection,
  });

  final String projectId;
  final WorkspaceSection initialSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(workspaceControllerProvider(projectId));
    final section = initialSection;
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context) && !isDesktop;

    if (snapshot.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (snapshot.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('项目工作区'),
          leading: IconButton(
            tooltip: '返回项目库',
            onPressed: () => context.go('/projects'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SurfaceCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '项目加载失败',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(snapshot.errorMessage!),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => ref
                            .read(
                              workspaceControllerProvider(projectId).notifier,
                            )
                            .load(projectId),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('重试'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/projects'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('返回项目库'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 8,
          toolbarHeight: 44,
          title: WorkspaceHeader(
            projectName: snapshot.bundle.name,
            activeSection: section,
            onBackPressed: () => context.go('/projects'),
            onSectionSelected: (next) {
              context.go('/projects/$projectId/${next.path}');
            },
            onProjectPackagePressed: () async {
              await _exportProjectPackage(context, ref, snapshot.bundle);
            },
            onExportPressed: () {
              context.go('/projects/$projectId/call-sheet');
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
          child: _buildSectionBody(section, isDesktop),
        ),
      );
    }

    final mobileAppBar = AppBar(
      leading: IconButton(
        tooltip: '返回项目库',
        onPressed: () => context.go('/projects'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      titleSpacing: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot.bundle.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            section.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      actions: [
        const ThemeModeButton(compact: true),
        IconButton(
          tooltip: '导出项目包',
          onPressed: () async {
            await _exportProjectPackage(context, ref, snapshot.bundle);
          },
          icon: const Icon(Icons.archive_outlined),
        ),
      ],
    );

    if (isTablet) {
      return Scaffold(
        appBar: mobileAppBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: WorkspaceSection.values.indexOf(section),
              extended: MediaQuery.sizeOf(context).width >= 920,
              labelType: MediaQuery.sizeOf(context).width >= 920
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              onDestinationSelected: (index) {
                final next = WorkspaceSection.values[index];
                context.go('/projects/$projectId/${next.path}');
              },
              destinations: [
                for (final item in WorkspaceSection.values)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: _buildSectionBody(section, false),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: mobileAppBar,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _buildSectionBody(section, false),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: WorkspaceSection.values.indexOf(section),
        onDestinationSelected: (index) {
          final next = WorkspaceSection.values[index];
          context.go('/projects/$projectId/${next.path}');
        },
        destinations: [
          for (final item in WorkspaceSection.values)
            NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionBody(WorkspaceSection section, bool isDesktop) {
    return switch (section) {
      WorkspaceSection.editor => StoryboardEditorPage(
        key: const ValueKey('editor'),
        projectId: projectId,
        isDesktop: isDesktop,
      ),
      WorkspaceSection.board => StoryboardBoardPage(
        key: const ValueKey('board'),
        projectId: projectId,
      ),
      WorkspaceSection.shootingPlan => ShootingPlanPage(
        key: const ValueKey('plan'),
        projectId: projectId,
        isDesktop: isDesktop,
      ),
      WorkspaceSection.callSheet => ExportPage(
        key: const ValueKey('call-sheet'),
        projectId: projectId,
      ),
    };
  }

  Future<void> _exportProjectPackage(
    BuildContext context,
    WidgetRef ref,
    ProjectBundle bundle,
  ) async {
    try {
      final paths = await ref.read(appStoragePathsProvider.future);
      final zipFile = await ref
          .read(projectBundleServiceProvider)
          .exportAsZip(bundle, paths.tempExportsDirectory);
      final zipBytes = await zipFile.readAsBytes();
      if (!context.mounted) {
        return;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final action = await showModalBottomSheet<String>(
          context: context,
          builder: (sheetContext) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('保存到设备'),
                    subtitle: const Text('保存到 Android 下载目录中的 VisionDraft 文件夹'),
                    onTap: () => Navigator.of(sheetContext).pop('save'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('系统分享'),
                    subtitle: const Text('发送给其他应用或设备'),
                    onTap: () => Navigator.of(sheetContext).pop('share'),
                  ),
                ],
              ),
            );
          },
        );
        if (!context.mounted) {
          return;
        }
        if (action == null) {
          return;
        }

        if (action == 'save') {
          final result = await ref.read(documentOutputServiceProvider).saveDocument(
                bytes: zipBytes,
                filename: zipFile.uri.pathSegments.last,
                initialDirectory: bundle.rootPath,
                typeGroup: const XTypeGroup(
                  label: 'VisionDraft Archive',
                  extensions: ['zip'],
                ),
                confirmButtonText: '保存项目包',
              );
          if (!context.mounted || result == null) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('项目包已保存到 ${result.file.path}')),
          );
          return;
        }

        await ref.read(documentOutputServiceProvider).shareDocument(
              bytes: zipBytes,
              filename: zipFile.uri.pathSegments.last,
              subject: '${bundle.name} 项目包',
              text: '来自 VisionDraft 的项目包',
            );
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已调起系统分享项目包')));
        return;
      }

      final result = await ref.read(documentOutputServiceProvider).saveDocument(
            bytes: zipBytes,
            filename: zipFile.uri.pathSegments.last,
            initialDirectory: bundle.rootPath,
            typeGroup: const XTypeGroup(
              label: 'VisionDraft Archive',
              extensions: ['zip'],
            ),
            confirmButtonText: '导出项目包',
          );
      if (!context.mounted || result == null) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('项目包已导出到 ${result.file.path}')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出项目包失败：$error')));
    }
  }
}
