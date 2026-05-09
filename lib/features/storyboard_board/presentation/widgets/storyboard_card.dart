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
    final uri = shot.frameImage?.uri;
    final file = (uri != null && uri.isNotEmpty) ? File(uri) : null;
    final canPreview = file != null && file.existsSync();
    final title = shot.content.trim().isEmpty ? '未填写画面内容' : shot.content.trim();
    final secondary = <String>[
      if (shot.shotSize.trim().isNotEmpty) shot.shotSize.trim(),
      '${shot.durationSec}s',
      if (shot.cameraMove.trim().isNotEmpty) shot.cameraMove.trim(),
    ];

    final titleStyle = switch (preset.textScaleMode) {
      TextScaleMode.small => Theme.of(context).textTheme.titleMedium,
      TextScaleMode.large => Theme.of(context).textTheme.titleLarge,
    };
    final bodyStyle = switch (preset.textScaleMode) {
      TextScaleMode.small => Theme.of(context).textTheme.bodySmall,
      TextScaleMode.large => Theme.of(context).textTheme.bodyMedium,
    };

    final textAlign = switch (preset.textAlignMode) {
      TextAlignMode.center => TextAlign.center,
      _ => TextAlign.left,
    };
    final crossAxisAlignment = switch (preset.textAlignMode) {
      TextAlignMode.center => CrossAxisAlignment.center,
      _ => CrossAxisAlignment.start,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 11,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.34),
                  child: canPreview
                      ? Image.file(
                          file,
                          fit: preset.fitMode == ImageFitMode.cover
                              ? BoxFit.cover
                              : BoxFit.contain,
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined, size: 34),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        _displayShotNo(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        secondary.join(' · '),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  Text(
                    title,
                    maxLines: preset.textScaleMode == TextScaleMode.large ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: textAlign,
                  ),
                  const SizedBox(height: 8),
                  if (shot.notes.trim().isNotEmpty)
                    Text(
                      shot.notes.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                      textAlign: textAlign,
                    )
                  else if (shot.dialogue.trim().isNotEmpty)
                    Text(
                      shot.dialogue.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                      textAlign: textAlign,
                    )
                  else
                    Text(
                      _footerSummary(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                      textAlign: textAlign,
                    ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: textAlign == TextAlign.center
                        ? WrapAlignment.center
                        : WrapAlignment.start,
                    children: [
                      if (shot.cameraAngle.trim().isNotEmpty)
                        _MetaPill(label: shot.cameraAngle.trim()),
                      if (shot.cameraRig.trim().isNotEmpty)
                        _MetaPill(label: shot.cameraRig.trim()),
                      if (shot.focalLength.trim().isNotEmpty)
                        _MetaPill(label: shot.focalLength.trim()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayShotNo() {
    return preset.shotNumberMode == ShotNumberMode.order
        ? '镜头 ${shot.orderIndex + 1}'
        : '镜头 ${shot.shotNo}';
  }

  String _footerSummary() {
    final parts = <String>[
      if (shot.sceneExpectation.trim().isNotEmpty) shot.sceneExpectation.trim(),
      if (shot.audio.trim().isNotEmpty) shot.audio.trim(),
    ];
    if (parts.isEmpty) {
      return '机位 ${shot.cameraMove} · ${shot.cameraRig} · ${shot.focalLength}';
    }
    return parts.join(' · ');
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
