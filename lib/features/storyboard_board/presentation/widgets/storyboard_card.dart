import 'dart:io';

import 'package:flutter/material.dart';

import '../../../project_workspace/domain/models/board_preset.dart';
import '../../../project_workspace/domain/models/shot_record.dart';

class StoryboardCard extends StatelessWidget {
  const StoryboardCard({
    super.key,
    required this.shot,
    required this.preset,
  });

  final ShotRecord shot;
  final BoardPreset preset;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (preset.textAlignMode) {
      TextAlignMode.center => Alignment.center,
      TextAlignMode.start => Alignment.centerLeft,
      TextAlignMode.topStart => Alignment.topLeft,
    };
    final uri = shot.frameImage?.uri;
    final file = (uri != null && uri.isNotEmpty) ? File(uri) : null;
    final canPreview = file != null && file.existsSync();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: preset.aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: canPreview
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          fit: preset.fitMode == ImageFitMode.cover
                              ? BoxFit.cover
                              : BoxFit.contain,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, size: 28),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              alignment: alignment,
              child: Text(
                shot.content.isEmpty ? '未填写内容' : shot.content,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: switch (preset.textAlignMode) {
                  TextAlignMode.center => TextAlign.center,
                  _ => TextAlign.left,
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('镜头 ${shot.shotNo}  ·  ${shot.shotSize}  ·  ${shot.durationSec}s'),
          ],
        ),
      ),
    );
  }
}
