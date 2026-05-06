import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../project_workspace/domain/models/plan_board.dart';
import '../../../project_workspace/domain/models/shot_record.dart';
import '../widgets/plan_section_card.dart';

class ShootingPlanPage extends ConsumerWidget {
  const ShootingPlanPage({
    super.key,
    required this.projectId,
    required this.isDesktop,
  });

  final String projectId;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(workspaceControllerProvider(projectId));
    final controller = ref.read(workspaceControllerProvider(projectId).notifier);
    final shotsById = {for (final shot in snapshot.shots) shot.id: shot};

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DragTarget<String>(
              onAcceptWithDetails: (details) async {
                await controller.unassignShotFromPlan(shotId: details.data);
              },
              builder: (context, candidateData, rejectedData) {
                final isActive = candidateData.isNotEmpty;
                return SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '未规划镜头',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text('${snapshot.planBoard.unassignedShotIds.length}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          color: isActive
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                        child: SizedBox(
                          height: 520,
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              final shotId =
                                  snapshot.planBoard.unassignedShotIds[index];
                              final shot = shotsById[shotId];
                              return Draggable<String>(
                                data: shotId,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 220,
                                    child: _ShotChip(shot: shot),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.4,
                                  child: _ShotChip(shot: shot),
                                ),
                                child: _ShotChip(shot: shot),
                              );
                            },
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemCount:
                                snapshot.planBoard.unassignedShotIds.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '计划区块',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _showCreateSectionDialog(
                          context,
                          onSubmit: controller.createPlanSection,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('新建区块'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final section = snapshot.planBoard.sections[index];
                        return PlanSectionCard(
                          section: section,
                          shotsById: shotsById,
                          onAcceptShot: (shotId) => controller.assignShotToPlan(
                            shotId: shotId,
                            sectionId: section.id,
                          ),
                          onRename: () => _showRenameSectionDialog(
                            context,
                            section: section,
                            onSubmit: (name) => controller.renamePlanSection(
                              sectionId: section.id,
                              name: name,
                            ),
                          ),
                          onReorderShots: (oldIndex, newIndex) async {
                            final ordered = [...section.shotIds];
                            final moved = ordered.removeAt(oldIndex);
                            final target =
                                newIndex > oldIndex ? newIndex - 1 : newIndex;
                            ordered.insert(target, moved);
                            await controller.reorderPlanSectionShots(
                              sectionId: section.id,
                              orderedShotIds: ordered,
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemCount: snapshot.planBoard.sections.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '拍摄计划',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showCreateSectionDialog(
                  context,
                  onSubmit: controller.createPlanSection,
                ),
                icon: const Icon(Icons.add),
                label: const Text('新建区块'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const TabBar(
            tabs: [
              Tab(text: '待分配'),
              Tab(text: '计划区块'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                ListView.separated(
                  itemBuilder: (context, index) {
                    final shotId = snapshot.planBoard.unassignedShotIds[index];
                    final shot = shotsById[shotId];
                    return _MobileAssignableShotTile(
                      shot: shot,
                      sections: snapshot.planBoard.sections,
                      onAssign: (sectionId) => controller.assignShotToPlan(
                        shotId: shotId,
                        sectionId: sectionId,
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemCount: snapshot.planBoard.unassignedShotIds.length,
                ),
                ListView.separated(
                  itemBuilder: (context, index) {
                    final section = snapshot.planBoard.sections[index];
                    return PlanSectionCard(
                      section: section,
                      shotsById: shotsById,
                      onRename: () => _showRenameSectionDialog(
                        context,
                        section: section,
                        onSubmit: (name) => controller.renamePlanSection(
                          sectionId: section.id,
                          name: name,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemCount: snapshot.planBoard.sections.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSectionDialog(
    BuildContext context, {
    required Future<void> Function(String name) onSubmit,
  }) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新建计划区块'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '区块名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  return;
                }
                await onSubmit(name);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRenameSectionDialog(
    BuildContext context, {
    required PlanSection section,
    required Future<void> Function(String name) onSubmit,
  }) async {
    final controller = TextEditingController(text: section.name);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重命名区块'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '区块名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty || name == section.name) {
                  Navigator.of(context).pop();
                  return;
                }
                await onSubmit(name);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}

class _ShotChip extends StatelessWidget {
  const _ShotChip({required this.shot});

  final ShotRecord? shot;

  @override
  Widget build(BuildContext context) {
    final title = shot == null ? '未找到镜头' : '镜头 ${shot!.shotNo}';
    final subtitle = shot == null
        ? ''
        : shot!.content.isEmpty
            ? '${shot!.shotSize} · ${shot!.durationSec}s'
            : shot!.content;

    return ListTile(
      tileColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(title),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const Icon(Icons.drag_indicator_rounded),
    );
  }
}

class _MobileAssignableShotTile extends StatelessWidget {
  const _MobileAssignableShotTile({
    required this.shot,
    required this.sections,
    required this.onAssign,
  });

  final ShotRecord? shot;
  final List<PlanSection> sections;
  final Future<void> Function(String sectionId) onAssign;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(shot == null ? '未找到镜头' : '镜头 ${shot!.shotNo}'),
      subtitle: Text(
        shot == null
            ? ''
            : (shot!.content.isEmpty
                ? '${shot!.shotSize} · ${shot!.durationSec}s'
                : shot!.content),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        tooltip: '分配到区块',
        onSelected: onAssign,
        itemBuilder: (context) => sections
            .map(
              (section) => PopupMenuItem<String>(
                value: section.id,
                child: Text(section.name),
              ),
            )
            .toList(),
      ),
    );
  }
}
