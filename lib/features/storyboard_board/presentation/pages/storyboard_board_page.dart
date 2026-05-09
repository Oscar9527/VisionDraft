import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../project_workspace/domain/models/board_preset.dart';
import '../widgets/storyboard_card.dart';

class StoryboardBoardPage extends ConsumerWidget {
  const StoryboardBoardPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(workspaceControllerProvider(projectId));
    final controller = ref.read(workspaceControllerProvider(projectId).notifier);
    final shotCount = snapshot.shots.length;
    final totalDuration = snapshot.shots.fold<int>(
      0,
      (sum, shot) => sum + shot.durationSec,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '故事板预览',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$shotCount 镜头 · 总时长 ${totalDuration}s · 当前比例 ${_formatAspectRatio(snapshot.boardPreset.aspectRatio)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: '图片适配',
                value: snapshot.boardPreset.fitMode == ImageFitMode.cover
                    ? '缩放'
                    : '适应',
              ),
              _StatChip(
                label: '文字对齐',
                value: switch (snapshot.boardPreset.textAlignMode) {
                  TextAlignMode.center => '居中',
                  TextAlignMode.start => '居左',
                  TextAlignMode.topStart => '居左上',
                },
              ),
              _StatChip(
                label: '镜号显示',
                value: snapshot.boardPreset.shotNumberMode == ShotNumberMode.custom
                    ? '自定义镜号'
                    : '顺序镜号',
              ),
              OutlinedButton.icon(
                onPressed: () => _showBoardSettingsDialog(
                  context,
                  preset: snapshot.boardPreset,
                  onSubmit: controller.updateBoardPreset,
                ),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('显示设置'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gridMaxExtent = constraints.maxWidth >= 1500
                  ? 318.0
                  : constraints.maxWidth >= 1200
                      ? 340.0
                      : constraints.maxWidth >= 900
                          ? 360.0
                          : 420.0;

              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: gridMaxExtent,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: snapshot.shots.length,
                itemBuilder: (context, index) {
                  return StoryboardCard(
                    shot: snapshot.shots[index],
                    preset: snapshot.boardPreset,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showBoardSettingsDialog(
    BuildContext context, {
    required BoardPreset preset,
    required Future<void> Function(BoardPreset preset) onSubmit,
  }) async {
    var draft = preset;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('故事板显示设置'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<TextScaleMode>(
                      initialValue: draft.textScaleMode,
                      decoration: const InputDecoration(labelText: '文字大小'),
                      items: const [
                        DropdownMenuItem(
                          value: TextScaleMode.small,
                          child: Text('小'),
                        ),
                        DropdownMenuItem(
                          value: TextScaleMode.large,
                          child: Text('大'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          draft = draft.copyWith(textScaleMode: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      initialValue: _matchAspectRatio(draft.aspectRatio),
                      decoration: const InputDecoration(labelText: '图片比例'),
                      items: const [
                        DropdownMenuItem(value: 1.0, child: Text('1:1')),
                        DropdownMenuItem(value: 16 / 9, child: Text('16:9')),
                        DropdownMenuItem(value: 4 / 3, child: Text('4:3')),
                        DropdownMenuItem(value: 2.35, child: Text('2.35:1')),
                        DropdownMenuItem(value: 9 / 16, child: Text('9:16')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          draft = draft.copyWith(aspectRatio: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ImageFitMode>(
                      initialValue: draft.fitMode,
                      decoration: const InputDecoration(labelText: '图片适配'),
                      items: const [
                        DropdownMenuItem(
                          value: ImageFitMode.contain,
                          child: Text('适应'),
                        ),
                        DropdownMenuItem(
                          value: ImageFitMode.cover,
                          child: Text('缩放'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          draft = draft.copyWith(fitMode: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TextAlignMode>(
                      initialValue: draft.textAlignMode,
                      decoration: const InputDecoration(labelText: '文字对齐'),
                      items: const [
                        DropdownMenuItem(
                          value: TextAlignMode.center,
                          child: Text('居中'),
                        ),
                        DropdownMenuItem(
                          value: TextAlignMode.start,
                          child: Text('居左'),
                        ),
                        DropdownMenuItem(
                          value: TextAlignMode.topStart,
                          child: Text('居左上'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          draft = draft.copyWith(textAlignMode: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: draft.shotNumberMode == ShotNumberMode.custom,
                      title: const Text('使用自定义镜号'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          draft = draft.copyWith(
                            shotNumberMode:
                                value ? ShotNumberMode.custom : ShotNumberMode.order,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () async {
                    await onSubmit(draft);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static double _matchAspectRatio(double value) {
    const candidates = <double>[1.0, 16 / 9, 4 / 3, 2.35, 9 / 16];
    for (final candidate in candidates) {
      if ((candidate - value).abs() < 0.02) {
        return candidate;
      }
    }
    return 16 / 9;
  }

  static String _formatAspectRatio(double value) {
    if ((value - 1).abs() < 0.02) {
      return '1:1';
    }
    if ((value - 16 / 9).abs() < 0.02) {
      return '16:9';
    }
    if ((value - 4 / 3).abs() < 0.02) {
      return '4:3';
    }
    if ((value - 9 / 16).abs() < 0.02) {
      return '9:16';
    }
    return '${value.toStringAsFixed(2)}:1';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('$label · $value'),
      ),
    );
  }
}
