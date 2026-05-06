import 'package:flutter/material.dart';

import '../../../project_workspace/domain/models/plan_board.dart';
import '../../../project_workspace/domain/models/shot_record.dart';

class PlanSectionCard extends StatelessWidget {
  const PlanSectionCard({
    super.key,
    required this.section,
    required this.shotsById,
    this.onRename,
    this.onAcceptShot,
    this.onReorderShots,
  });

  final PlanSection section;
  final Map<String, ShotRecord> shotsById;
  final Future<void> Function()? onRename;
  final Future<void> Function(String shotId)? onAcceptShot;
  final Future<void> Function(int oldIndex, int newIndex)? onReorderShots;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: onAcceptShot == null
          ? null
          : (details) async {
              await onAcceptShot!(details.data);
            },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: '重命名区块',
                      onPressed: onRename == null ? null : () => onRename!(),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.55)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: section.shotIds.isEmpty
                      ? const Text('拖入镜头到这个计划区块')
                      : ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: section.shotIds.length,
                          onReorder: onReorderShots == null
                              ? (_, _) {}
                              : (oldIndex, newIndex) async {
                                  await onReorderShots!(oldIndex, newIndex);
                                },
                          itemBuilder: (context, index) {
                            final shotId = section.shotIds[index];
                            final shot = shotsById[shotId];
                            return Padding(
                              key: ValueKey('$shotId-${section.id}'),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Draggable<String>(
                                data: shotId,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 220,
                                    child: _PlanShotTile(shot: shot),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.4,
                                  child: _PlanShotTile(shot: shot),
                                ),
                                child: _PlanShotTile(shot: shot),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanShotTile extends StatelessWidget {
  const _PlanShotTile({required this.shot});

  final ShotRecord? shot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shot == null ? '未找到镜头' : '镜头 ${shot!.shotNo}'),
                const SizedBox(height: 4),
                Text(
                  shot == null
                      ? ''
                      : (shot!.content.isEmpty
                          ? '${shot!.shotSize} · ${shot!.durationSec}s'
                          : shot!.content),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.drag_indicator_rounded),
        ],
      ),
    );
  }
}
