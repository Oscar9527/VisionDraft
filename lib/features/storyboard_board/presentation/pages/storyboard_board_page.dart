import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/providers.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('故事板预览', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _showBoardSettingsDialog(
                context,
                preset: snapshot.boardPreset,
                onSubmit: controller.updateBoardPreset,
              ),
              icon: const Icon(Icons.grid_view_outlined),
              label: const Text('显示设置'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: snapshot.shots.length,
            itemBuilder: (context, index) {
              return StoryboardCard(
                shot: snapshot.shots[index],
                preset: snapshot.boardPreset,
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
    double aspectRatio = preset.aspectRatio;
    ImageFitMode fitMode = preset.fitMode;
    TextAlignMode textAlignMode = preset.textAlignMode;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('故事板显示设置'),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('画面比例'),
                    const SizedBox(height: 8),
                    SegmentedButton<double>(
                      segments: const [
                        ButtonSegment<double>(value: 16 / 9, label: Text('16:9')),
                        ButtonSegment<double>(value: 4 / 3, label: Text('4:3')),
                        ButtonSegment<double>(value: 1, label: Text('1:1')),
                      ],
                      selected: {aspectRatio},
                      onSelectionChanged: (values) {
                        setState(() => aspectRatio = values.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('图片适配'),
                    const SizedBox(height: 8),
                    SegmentedButton<ImageFitMode>(
                      segments: const [
                        ButtonSegment<ImageFitMode>(
                          value: ImageFitMode.contain,
                          label: Text('完整显示'),
                        ),
                        ButtonSegment<ImageFitMode>(
                          value: ImageFitMode.cover,
                          label: Text('铺满裁切'),
                        ),
                      ],
                      selected: {fitMode},
                      onSelectionChanged: (values) {
                        setState(() => fitMode = values.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('文字对齐'),
                    const SizedBox(height: 8),
                    SegmentedButton<TextAlignMode>(
                      segments: const [
                        ButtonSegment<TextAlignMode>(
                          value: TextAlignMode.start,
                          label: Text('居左'),
                        ),
                        ButtonSegment<TextAlignMode>(
                          value: TextAlignMode.center,
                          label: Text('居中'),
                        ),
                      ],
                      selected: {textAlignMode},
                      onSelectionChanged: (values) {
                        setState(() => textAlignMode = values.first);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () async {
                    await onSubmit(
                      preset.copyWith(
                        aspectRatio: aspectRatio,
                        fitMode: fitMode,
                        textAlignMode: textAlignMode,
                      ),
                    );
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
      },
    );
  }
}
