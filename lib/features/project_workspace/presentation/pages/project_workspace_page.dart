import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../app/layout/app_breakpoints.dart';
import '../../../export/presentation/pages/export_page.dart';
import '../../../shooting_plan/presentation/pages/shooting_plan_page.dart';
import '../../../storyboard_board/presentation/pages/storyboard_board_page.dart';
import '../../../storyboard_editor/presentation/pages/storyboard_editor_page.dart';
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
        WorkspaceSection.callSheet => '拍摄通告',
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

    if (snapshot.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        toolbarHeight: 84,
        title: WorkspaceHeader(
          projectName: snapshot.bundle.name,
          activeSection: section,
          onBackPressed: () => context.go('/'),
          onSectionSelected: (next) {
            context.go('/projects/$projectId/${next.path}');
          },
          onExportPressed: () {
            context.go('/projects/$projectId/call-sheet');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: switch (section) {
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
          },
        ),
      ),
    );
  }
}
