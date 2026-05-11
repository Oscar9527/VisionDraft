import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../app/bootstrap/providers.dart';
import '../application/ai_storyboard_controller.dart';
import '../domain/ai_generation_density.dart';
import '../domain/ai_provider_config.dart';
import '../domain/ai_provider_preset.dart';
import '../domain/ai_provider_type.dart';
import '../domain/ai_script_mode.dart';
import '../domain/ai_shot_draft.dart';

Future<void> showAiStoryboardSheet(
  BuildContext context, {
  required String projectId,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'AI分镜草案',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: _AiStoryboardSheet(projectId: projectId),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class _AiStoryboardSheet extends ConsumerStatefulWidget {
  const _AiStoryboardSheet({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_AiStoryboardSheet> createState() => _AiStoryboardSheetState();
}

class _AiStoryboardSheetState extends ConsumerState<_AiStoryboardSheet> {
  final _scriptController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();

  String? _syncedConfigSignature;
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _scriptController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiStoryboardControllerProvider(widget.projectId));
    final controller = ref.read(
      aiStoryboardControllerProvider(widget.projectId).notifier,
    );
    _syncControllers(state);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 640,
        margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 32,
              color: Color(0x33000000),
              offset: Offset(-4, 8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI分镜草案',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '把文案脚本直接交给在线 AI，先出草案，再在导入前人工复核。',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          title: '脚本输入',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _pickScriptFile,
                                    icon: const Icon(Icons.upload_file_rounded),
                                    label: const Text('导入 txt / md'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: state.scriptInput.isEmpty
                                        ? null
                                        : () => controller.updateScriptInput(
                                            '',
                                            sourceLabel: '',
                                          ),
                                    icon: const Icon(Icons.clear_rounded),
                                    label: const Text('清空'),
                                  ),
                                  const Spacer(),
                                  if (state.sourceLabel.isNotEmpty)
                                    Flexible(
                                      child: Text(
                                        '来源：${state.sourceLabel}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _scriptController,
                                minLines: 8,
                                maxLines: 12,
                                onChanged: controller.updateScriptInput,
                                decoration: const InputDecoration(
                                  hintText: '把文案脚本、口播稿、剧情段落或拍摄需求粘贴到这里。',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        DropdownButtonFormField<AiScriptMode>(
                                          initialValue: state.scriptMode,
                                          decoration: const InputDecoration(
                                            labelText: '脚本类型',
                                          ),
                                          items: AiScriptMode.values
                                              .map(
                                                (mode) => DropdownMenuItem(
                                                  value: mode,
                                                  child: Text(mode.label),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              controller.setScriptMode(value);
                                            }
                                          },
                                        ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child:
                                        DropdownButtonFormField<
                                          AiGenerationDensity
                                        >(
                                          initialValue: state.generationDensity,
                                          decoration: const InputDecoration(
                                            labelText: '拆分密度',
                                          ),
                                          items: AiGenerationDensity.values
                                              .map(
                                                (density) => DropdownMenuItem(
                                                  value: density,
                                                  child: Text(density.label),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              controller.setGenerationDensity(
                                                value,
                                              );
                                            }
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: '服务商设置',
                          subtitle: '配置只保存在当前电脑，不写入项目包。生成时会真实联网调用。',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final preset in aiProviderPresets)
                                    ChoiceChip(
                                      label: Text(preset.label),
                                      selected:
                                          state.selectedProvider == preset.type,
                                      onSelected: (_) => controller
                                          .selectProvider(preset.type),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _ProviderProtocolHint(
                                preset: presetForProvider(
                                  state.selectedProvider,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _baseUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Base URL',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _modelController,
                                decoration: const InputDecoration(
                                  labelText: 'Model',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _apiKeyController,
                                obscureText: _obscureApiKey,
                                decoration: InputDecoration(
                                  labelText: 'API Key',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureApiKey = !_obscureApiKey;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureApiKey
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed: state.isLoadingSettings
                                        ? null
                                        : _saveProviderConfig,
                                    icon: const Icon(Icons.save_rounded),
                                    label: const Text('保存配置'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _resetProviderConfig(
                                      state.selectedProvider,
                                    ),
                                    icon: const Icon(Icons.restart_alt_rounded),
                                    label: const Text('恢复预设'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.errorMessage != null &&
                            state.errorMessage!.trim().isNotEmpty) ...[
                          _MessageBanner(
                            color: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            icon: Icons.error_outline_rounded,
                            lines: [state.errorMessage!],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.result.warnings.isNotEmpty) ...[
                          _MessageBanner(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                            icon: Icons.info_outline_rounded,
                            lines: state.result.warnings,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: state.isGenerating
                                  ? null
                                  : _generateDraft,
                              icon: state.isGenerating
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome_rounded),
                              label: Text(
                                state.isGenerating ? '生成中...' : '生成草案',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              state.isGenerating
                                  ? '正在请求在线 AI...'
                                  : '生成结果会先停留在草案区，不会直接写入项目。',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: state.result.title,
                          subtitle: state.result.draftShots.isEmpty
                              ? '生成后会在这里出现草案列表。'
                              : '可以删改草案，再一次性导入到当前项目。',
                          child: state.result.draftShots.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: Text(
                                    '还没有生成内容。先输入脚本，再点击“生成草案”。',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < state.result.draftShots.length;
                                      index++
                                    ) ...[
                                      _DraftCard(
                                        draft: state.result.draftShots[index],
                                        onEdit: () => _editDraft(
                                          index,
                                          state.result.draftShots[index],
                                        ),
                                        onDelete: () =>
                                            controller.removeDraftAt(index),
                                      ),
                                      if (index !=
                                          state.result.draftShots.length - 1)
                                        const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: state.result.draftShots.isEmpty
                          ? null
                          : controller.clearDraft,
                      icon: const Icon(Icons.delete_sweep_rounded),
                      label: const Text('清空草案'),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: state.result.draftShots.isEmpty
                          ? null
                          : _importDraftsToProject,
                      icon: const Icon(Icons.playlist_add_check_rounded),
                      label: const Text('导入到当前项目'),
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

  void _syncControllers(AiStoryboardState state) {
    if (_scriptController.text != state.scriptInput) {
      _scriptController.value = TextEditingValue(
        text: state.scriptInput,
        selection: TextSelection.collapsed(offset: state.scriptInput.length),
      );
    }

    final config = state.selectedConfig;
    final signature = [
      state.selectedProvider.name,
      config.baseUrl,
      config.model,
      config.apiKey,
    ].join('|');
    if (_syncedConfigSignature == signature) {
      return;
    }
    _syncedConfigSignature = signature;
    _baseUrlController.text = config.baseUrl;
    _modelController.text = config.model;
    _apiKeyController.text = config.apiKey;
  }

  Future<void> _pickScriptFile() async {
    final filePath = await ref.read(mediaImportServiceProvider).pickTextFile();
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    try {
      final content = await File(filePath).readAsString();
      if (!mounted) {
        return;
      }
      ref
          .read(aiStoryboardControllerProvider(widget.projectId).notifier)
          .updateScriptInput(content, sourceLabel: p.basename(filePath));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('读取脚本失败：$error')));
    }
  }

  Future<void> _saveProviderConfig() async {
    await _persistProviderConfig(showSnackBar: true);
  }

  Future<void> _generateDraft() async {
    await _persistProviderConfig(showSnackBar: false);
    if (!mounted) {
      return;
    }
    await ref
        .read(aiStoryboardControllerProvider(widget.projectId).notifier)
        .generateDraft();
  }

  Future<void> _persistProviderConfig({required bool showSnackBar}) async {
    final controller = ref.read(
      aiStoryboardControllerProvider(widget.projectId).notifier,
    );
    final state = ref.read(aiStoryboardControllerProvider(widget.projectId));
    await controller.saveProviderConfig(
      AiProviderConfig(
        providerType: state.selectedProvider,
        baseUrl: _baseUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        model: _modelController.text.trim(),
      ),
    );
    if (!mounted || !showSnackBar) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('AI 服务商配置已保存到本地设置。')));
  }

  Future<void> _resetProviderConfig(AiProviderType providerType) async {
    final preset = presetForProvider(providerType);
    _baseUrlController.text = preset.defaultBaseUrl;
    _modelController.text = preset.defaultModel;
    _apiKeyController.clear();
    await ref
        .read(aiStoryboardControllerProvider(widget.projectId).notifier)
        .saveProviderConfig(AiProviderConfig.fromPreset(preset));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已恢复当前服务商的默认预设。')));
  }

  Future<void> _editDraft(int index, AiShotDraft draft) async {
    final edited = await showDialog<AiShotDraft>(
      context: context,
      builder: (dialogContext) {
        return _DraftEditDialog(draft: draft);
      },
    );
    if (edited == null) {
      return;
    }
    ref
        .read(aiStoryboardControllerProvider(widget.projectId).notifier)
        .replaceDraft(index, edited);
  }

  Future<void> _importDraftsToProject() async {
    final drafts = ref
        .read(aiStoryboardControllerProvider(widget.projectId))
        .result
        .draftShots;
    final workspaceController = ref.read(
      workspaceControllerProvider(widget.projectId).notifier,
    );
    await workspaceController.importAiDrafts(drafts);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已追加导入 ${drafts.length} 条镜头到当前项目。')));
    Navigator.of(context).pop();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProviderProtocolHint extends StatelessWidget {
  const _ProviderProtocolHint({required this.preset});

  final AiProviderPreset preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${preset.label} 默认协议：${preset.protocolLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.color,
    required this.foregroundColor,
    required this.icon,
    required this.lines,
  });

  final Color color;
  final Color foregroundColor;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  Text(
                    line,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: foregroundColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.onEdit,
    required this.onDelete,
  });

  final AiShotDraft draft;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '镜头 ${draft.shotNo}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 10),
              Text(
                '${draft.shotSize} · ${draft.durationSec}s · 置信度 ${(draft.confidence * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: '编辑',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              IconButton(
                tooltip: '删除',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DraftLine(label: '画面内容', value: draft.content),
          if (draft.dialogue.trim().isNotEmpty)
            _DraftLine(label: '台词', value: draft.dialogue),
          if (draft.notes.trim().isNotEmpty)
            _DraftLine(label: '备注', value: draft.notes),
          if (draft.sceneExpectation.trim().isNotEmpty)
            _DraftLine(label: '场景预期', value: draft.sceneExpectation),
          if (draft.audio.trim().isNotEmpty)
            _DraftLine(label: '声音', value: draft.audio),
          const SizedBox(height: 8),
          Text(
            '来源摘录：${draft.sourceExcerpt}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DraftLine extends StatelessWidget {
  const _DraftLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label：',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftEditDialog extends StatefulWidget {
  const _DraftEditDialog({required this.draft});

  final AiShotDraft draft;

  @override
  State<_DraftEditDialog> createState() => _DraftEditDialogState();
}

class _DraftEditDialogState extends State<_DraftEditDialog> {
  late final TextEditingController _shotNoController;
  late final TextEditingController _shotSizeController;
  late final TextEditingController _durationController;
  late final TextEditingController _contentController;
  late final TextEditingController _dialogueController;
  late final TextEditingController _notesController;
  late final TextEditingController _sceneController;
  late final TextEditingController _audioController;
  late final TextEditingController _angleController;
  late final TextEditingController _moveController;
  late final TextEditingController _rigController;
  late final TextEditingController _focalController;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _shotNoController = TextEditingController(text: draft.shotNo);
    _shotSizeController = TextEditingController(text: draft.shotSize);
    _durationController = TextEditingController(text: '${draft.durationSec}');
    _contentController = TextEditingController(text: draft.content);
    _dialogueController = TextEditingController(text: draft.dialogue);
    _notesController = TextEditingController(text: draft.notes);
    _sceneController = TextEditingController(text: draft.sceneExpectation);
    _audioController = TextEditingController(text: draft.audio);
    _angleController = TextEditingController(text: draft.cameraAngle);
    _moveController = TextEditingController(text: draft.cameraMove);
    _rigController = TextEditingController(text: draft.cameraRig);
    _focalController = TextEditingController(text: draft.focalLength);
  }

  @override
  void dispose() {
    _shotNoController.dispose();
    _shotSizeController.dispose();
    _durationController.dispose();
    _contentController.dispose();
    _dialogueController.dispose();
    _notesController.dispose();
    _sceneController.dispose();
    _audioController.dispose();
    _angleController.dispose();
    _moveController.dispose();
    _rigController.dispose();
    _focalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑 AI 草案'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _shotNoController,
                      decoration: const InputDecoration(labelText: '镜号'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _shotSizeController,
                      decoration: const InputDecoration(labelText: '景别'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '时长(秒)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: '画面内容'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dialogueController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '台词'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '备注'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sceneController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '场景预期'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _audioController,
                decoration: const InputDecoration(labelText: '声音'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _angleController,
                      decoration: const InputDecoration(labelText: '机位角度'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _moveController,
                      decoration: const InputDecoration(labelText: '运镜'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rigController,
                      decoration: const InputDecoration(labelText: '机位设备'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _focalController,
                      decoration: const InputDecoration(labelText: '焦段'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              widget.draft.copyWith(
                shotNo: _shotNoController.text.trim(),
                shotSize: _shotSizeController.text.trim(),
                durationSec:
                    int.tryParse(_durationController.text.trim()) ??
                    widget.draft.durationSec,
                content: _contentController.text.trim(),
                dialogue: _dialogueController.text.trim(),
                notes: _notesController.text.trim(),
                sceneExpectation: _sceneController.text.trim(),
                audio: _audioController.text.trim(),
                cameraAngle: _angleController.text.trim(),
                cameraMove: _moveController.text.trim(),
                cameraRig: _rigController.text.trim(),
                focalLength: _focalController.text.trim(),
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
