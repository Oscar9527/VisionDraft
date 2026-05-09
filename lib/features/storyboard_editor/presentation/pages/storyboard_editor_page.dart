import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../ai_storyboard/presentation/ai_storyboard_sheet.dart';
import '../../../project_workspace/application/project_workspace_controller.dart';
import '../../../project_workspace/domain/models/board_preset.dart';
import '../../../project_workspace/domain/models/column_preset.dart';
import '../../../project_workspace/domain/models/column_template.dart';
import '../../../project_workspace/domain/models/custom_column_definition.dart';
import '../../../project_workspace/domain/models/shot_fields.dart';
import '../widgets/storyboard_table.dart';

class StoryboardEditorPage extends ConsumerStatefulWidget {
  const StoryboardEditorPage({
    super.key,
    required this.projectId,
    required this.isDesktop,
  });

  final String projectId;
  final bool isDesktop;

  @override
  ConsumerState<StoryboardEditorPage> createState() =>
      _StoryboardEditorPageState();
}

class _StoryboardEditorPageState extends ConsumerState<StoryboardEditorPage> {
  bool _isBatchMode = false;
  final Set<String> _selectedShotIds = <String>{};

  static const List<({double value, String label})> _aspectRatioOptions = [
    (value: 1 / 1, label: '1:1'),
    (value: 16 / 9, label: '16:9'),
    (value: 2 / 1, label: '2:1'),
    (value: 1.85 / 1, label: '1.85:1'),
    (value: 2.35 / 1, label: '2.35:1'),
    (value: 2.39 / 1, label: '2.39:1'),
    (value: 1.66 / 1, label: '1.66:1'),
    (value: 4 / 3, label: '4:3'),
    (value: 9 / 16, label: '9:16'),
    (value: 1 / 2, label: '1:2'),
    (value: 3 / 4, label: '3:4'),
  ];

  void _openColumnSettings(
    BuildContext context,
    ProjectWorkspaceController controller,
    snapshot,
  ) {
    _showColumnSettingsSheet(
      context,
      activePreset: snapshot.columnPreset,
      templates: snapshot.columnTemplates,
      customColumns: snapshot.customColumns,
      onSubmitPreset: controller.updateColumnPreset,
      onSaveTemplate: controller.saveColumnTemplate,
      onApplyTemplate: controller.applyColumnTemplate,
      onDeleteTemplate: controller.deleteColumnTemplate,
      onRenameColumn: controller.renameCustomColumn,
      onDeleteColumn: controller.deleteCustomColumn,
      onCreateCustomColumn: ({required name, required type, enumSource}) =>
          controller.createCustomColumn(
            name: name,
            type: type,
            enumSource: enumSource,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(workspaceControllerProvider(widget.projectId));
    final controller = ref.read(
      workspaceControllerProvider(widget.projectId).notifier,
    );
    final gridSession = ref.watch(editorGridSessionProvider(widget.projectId));
    final gridSessionController = ref.read(
      editorGridSessionProvider(widget.projectId).notifier,
    );
    final history = ref.watch(historyManagerProvider);
    final totalDuration = snapshot.shots.fold<int>(
      0,
      (sum, shot) => sum + shot.durationSec,
    );

    if (snapshot.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.isDesktop) {
      return SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分镜制作', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              '${snapshot.shots.length} 镜头  ·  总时长 ${totalDuration}s',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: controller.createShot,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建镜头'),
                ),
                OutlinedButton.icon(
                  onPressed: () => showAiStoryboardSheet(
                    context,
                    projectId: widget.projectId,
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('AI生成'),
                ),
                OutlinedButton.icon(
                  onPressed: history.canUndo ? controller.undo : null,
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('撤销'),
                ),
                OutlinedButton.icon(
                  onPressed: history.canRedo ? controller.redo : null,
                  icon: const Icon(Icons.redo_rounded),
                  label: const Text('重做'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: snapshot.shots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final shot = snapshot.shots[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.32),
                    title: Text('镜头 ${shot.shotNo}'),
                    subtitle: Text(
                      shot.content.isEmpty ? '未填写画面内容' : shot.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text('${shot.durationSec}s'),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _EditorToolbar(
          shotCount: snapshot.shots.length,
          totalDuration: totalDuration,
          selectedCount: _selectedShotIds.length,
          isBatchMode: _isBatchMode,
          canUndo: history.canUndo,
          canRedo: history.canRedo,
          onUndo: controller.undo,
          onRedo: controller.redo,
          onCreateShot: controller.createShot,
          onOpenAiStoryboard: () =>
              showAiStoryboardSheet(context, projectId: widget.projectId),
          onToggleBatchMode: () {
            setState(() {
              _isBatchMode = !_isBatchMode;
              if (!_isBatchMode) {
                _selectedShotIds.clear();
              }
            });
          },
          onChooseSelection: (action) {
            final shotIds = snapshot.shots.map((shot) => shot.id).toList();
            setState(() {
              _isBatchMode = true;
              switch (action) {
                case _SelectionAction.selectAll:
                  _selectedShotIds
                    ..clear()
                    ..addAll(shotIds);
                case _SelectionAction.invert:
                  final next = shotIds.where(
                    (id) => !_selectedShotIds.contains(id),
                  );
                  _selectedShotIds
                    ..clear()
                    ..addAll(next);
                case _SelectionAction.clear:
                  _selectedShotIds.clear();
              }
            });
          },
          onOpenBatchEdit: _selectedShotIds.isEmpty
              ? null
              : () => _showBatchEditSheet(
                  context,
                  customColumns: snapshot.customColumns,
                  fixedFieldCustomOptions: snapshot.fixedFieldCustomOptions,
                  onApply: (fieldKey, value) async {
                    await controller.batchUpdateShotField(
                      shotIds: _selectedShotIds.toList(),
                      fieldKey: fieldKey,
                      value: value,
                    );
                  },
                ),
          onOpenBoardSettings: () => _showBoardSettingsSheet(
            context,
            preset: snapshot.boardPreset,
            onSubmit: controller.updateBoardPreset,
          ),
          onOpenColumnSettings: () =>
              _openColumnSettings(context, controller, snapshot),
        ),
        Expanded(
          child: StoryboardTable(
            shots: snapshot.shots,
            columnPreset: snapshot.columnPreset,
            effectiveFieldOrderKeys: gridSession.effectiveFieldOrderKeys,
            customColumns: snapshot.customColumns,
            fixedFieldCustomOptions: snapshot.fixedFieldCustomOptions,
            boardPreset: snapshot.boardPreset,
            isBatchMode: _isBatchMode,
            selectedShotIds: _selectedShotIds,
            zoomPercent: gridSession.zoomPercent,
            columnWidths: gridSession.columnWidthsByFieldKey,
            rowHeights: gridSession.rowHeightsByShotId,
            focusedCell: gridSession.focusedCell,
            onZoomChanged: gridSessionController.setZoomPercent,
            onColumnWidthChanged: gridSessionController.setColumnWidth,
            onRowHeightChanged: gridSessionController.setRowHeight,
            onFocusedCellChanged: gridSessionController.setFocusedCell,
            onSelectShot: (shotId, selected) {
              setState(() {
                if (selected) {
                  _selectedShotIds.add(shotId);
                } else {
                  _selectedShotIds.remove(shotId);
                }
              });
            },
            onReorder: controller.reorderShots,
            onUpdateField: controller.updateShotField,
            onImportAsset: controller.importAsset,
            onRelinkAsset: controller.relinkAsset,
            onInsertRowAbove: (rowIndex) =>
                controller.createShot(insertIndex: rowIndex),
            onInsertRowBelow: (rowIndex) =>
                controller.createShot(insertIndex: rowIndex + 1),
            onDeleteRow: controller.deleteShot,
            onAddColumn: () async => _showCreateCustomColumnSheet(
              context,
              onSubmit: ({
                required name,
                required type,
                enumSource,
              }) => controller.createCustomColumn(
                name: name,
                type: type,
                enumSource: enumSource,
              ),
            ),
            onHideColumn: (fieldKey) async {
              final nextVisible = snapshot.columnPreset.visibleFieldKeys
                  .where((key) => key != fieldKey)
                  .toList();
              await controller.updateColumnPreset(
                snapshot.columnPreset.copyWith(
                  visibleFieldKeys: nextVisible,
                  updatedAt: DateTime.now(),
                ),
              );
            },
            onMoveColumnLeft: (fieldKey) async {
              gridSessionController.moveFieldByOffset(
                fieldKey: fieldKey,
                offset: -1,
                fallbackOrder: snapshot.columnPreset.fieldOrderKeys,
              );
            },
            onMoveColumnRight: (fieldKey) async {
              gridSessionController.moveFieldByOffset(
                fieldKey: fieldKey,
                offset: 1,
                fallbackOrder: snapshot.columnPreset.fieldOrderKeys,
              );
            },
            onReorderField:
                ({
                  required draggedFieldKey,
                  required targetFieldKey,
                  required placeAfter,
                }) {
                  gridSessionController.reorderField(
                    draggedFieldKey: draggedFieldKey,
                    targetFieldKey: targetFieldKey,
                    placeAfter: placeAfter,
                    fallbackOrder: snapshot.columnPreset.fieldOrderKeys,
                  );
                },
            onRenameColumn: (columnId) async {
              final column = snapshot.customColumns
                  .where((item) => item.id == columnId)
                  .firstOrNull;
              if (column == null) {
                return;
              }
              final next = await _showNamePrompt(
                context,
                title: '重命名列',
                label: '列名',
                initialValue: column.name,
              );
              if (next == null || next.trim().isEmpty) {
                return;
              }
              await controller.renameCustomColumn(
                columnId: columnId,
                name: next.trim(),
              );
            },
            onDeleteColumn: controller.deleteCustomColumn,
            onDeleteFixedFieldOption: ({required fieldKey, required option}) =>
                controller.deleteFixedFieldCustomOption(
                  fieldKey: fieldKey,
                  option: option,
                ),
            onDeleteCustomColumnOption:
                ({required columnId, required option}) =>
                    controller.deleteCustomColumnOption(
                      columnId: columnId,
                      option: option,
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateCustomColumnSheet(
    BuildContext context, {
    required Future<void> Function({
      required String name,
      required CustomColumnType type,
      BuiltInEnumSource? enumSource,
    })
    onSubmit,
  }) async {
    final nameController = TextEditingController();
    CustomColumnType type = CustomColumnType.text;
    BuiltInEnumSource? enumSource;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _SideSheet(
              title: '新增自定义列',
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: '列名'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CustomColumnType>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: '列类型'),
                    items: CustomColumnType.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(switch (item) {
                              CustomColumnType.text => '文本',
                              CustomColumnType.number => '数字',
                              CustomColumnType.singleSelect => '单选',
                              CustomColumnType.image => '图片',
                            }),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setSheetState(() {
                        type = value;
                        if (type != CustomColumnType.singleSelect) {
                          enumSource = null;
                        } else {
                          enumSource ??= BuiltInEnumSource.priority;
                        }
                      });
                    },
                  ),
                  if (type == CustomColumnType.singleSelect) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<BuiltInEnumSource>(
                      initialValue: enumSource,
                      decoration: const InputDecoration(labelText: '枚举来源'),
                      items: BuiltInEnumSource.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          enumSource = value;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            return;
                          }
                          await onSubmit(
                            name: name,
                            type: type,
                            enumSource: enumSource,
                          );
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('创建'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showColumnSettingsSheet(
    BuildContext context, {
    required ColumnPreset activePreset,
    required List<ColumnTemplate> templates,
    required List<CustomColumnDefinition> customColumns,
    required Future<void> Function(ColumnPreset preset) onSubmitPreset,
    required Future<void> Function(String name) onSaveTemplate,
    required Future<void> Function(String templateId) onApplyTemplate,
    required Future<void> Function(String templateId) onDeleteTemplate,
    required Future<void> Function({
      required String columnId,
      required String name,
    })
    onRenameColumn,
    required Future<void> Function(String columnId) onDeleteColumn,
    required Future<void> Function({
      required String name,
      required CustomColumnType type,
      BuiltInEnumSource? enumSource,
    })
    onCreateCustomColumn,
  }) async {
    final visibleKeys = [...activePreset.visibleFieldKeys];
    final orderedKeys = [...activePreset.fieldOrderKeys];
    String? selectedTemplateId = templates.isEmpty ? null : templates.first.id;

    String labelFor(String fieldKey) {
      final fixed = shotFieldKeyFromStorageKey(fieldKey);
      if (fixed != null) {
        return fixed.label;
      }
      for (final column in customColumns) {
        if (column.fieldKey == fieldKey) {
          return column.name;
        }
      }
      return fieldKey;
    }

    Future<void> persist() async {
      final normalizedVisible = orderedKeys
          .where(
            (key) =>
                visibleKeys.contains(key) ||
                key == ShotFieldKey.shotNo.storageKey,
          )
          .toList();
      await onSubmitPreset(
        activePreset.copyWith(
          visibleFieldKeys: normalizedVisible,
          fieldOrderKeys: orderedKeys,
          updatedAt: DateTime.now(),
        ),
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _SideSheet(
              title: '列设置',
              width: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedTemplateId,
                          decoration: const InputDecoration(labelText: '模板库'),
                          items: templates
                              .map(
                                (template) => DropdownMenuItem(
                                  value: template.id,
                                  child: Text(template.name),
                                ),
                              )
                              .toList(),
                          onChanged: templates.isEmpty
                              ? null
                              : (value) {
                                  setSheetState(() {
                                    selectedTemplateId = value;
                                  });
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _showCreateCustomColumnSheet(
                            context,
                            onSubmit: onCreateCustomColumn,
                          );
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('新增列'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          final name = await _showNamePrompt(
                            context,
                            title: '存储模板',
                            label: '模板名称',
                          );
                          if (name == null || name.isEmpty) {
                            return;
                          }
                          await persist();
                          await onSaveTemplate(name);
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('存储模板'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: selectedTemplateId == null
                            ? null
                            : () async {
                                await onApplyTemplate(selectedTemplateId!);
                                if (!sheetContext.mounted) {
                                  return;
                                }
                                Navigator.of(sheetContext).pop();
                              },
                        icon: const Icon(Icons.playlist_add_check_rounded),
                        label: const Text('应用模板'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: selectedTemplateId == null
                            ? null
                            : () async {
                                await onDeleteTemplate(selectedTemplateId!);
                                if (!sheetContext.mounted) {
                                  return;
                                }
                                Navigator.of(sheetContext).pop();
                              },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('删除模板'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '字段顺序与显隐',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: orderedKeys.length,
                      onReorder: (oldIndex, newIndex) {
                        setSheetState(() {
                          final item = orderedKeys.removeAt(oldIndex);
                          final target = newIndex > oldIndex
                              ? newIndex - 1
                              : newIndex;
                          orderedKeys.insert(target, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final fieldKey = orderedKeys[index];
                        final isShotNo =
                            fieldKey == ShotFieldKey.shotNo.storageKey;
                        final isVisible =
                            visibleKeys.contains(fieldKey) || isShotNo;
                        final custom = customColumns
                            .where((item) => item.fieldKey == fieldKey)
                            .firstOrNull;
                        return ListTile(
                          key: ValueKey(fieldKey),
                          leading: Checkbox(
                            value: isVisible,
                            onChanged: isShotNo
                                ? null
                                : (value) {
                                    setSheetState(() {
                                      if (value == true) {
                                        visibleKeys.add(fieldKey);
                                      } else {
                                        visibleKeys.remove(fieldKey);
                                      }
                                    });
                                  },
                          ),
                          title: Text(labelFor(fieldKey)),
                          subtitle: custom == null
                              ? null
                              : Text(switch (custom.type) {
                                  CustomColumnType.text => '文本',
                                  CustomColumnType.number => '数字',
                                  CustomColumnType.singleSelect =>
                                    '单选 · ${custom.enumSource?.label ?? ''}',
                                  CustomColumnType.image => '图片',
                                }),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (custom != null) ...[
                                IconButton(
                                  tooltip: '重命名',
                                  onPressed: () async {
                                    final next = await _showNamePrompt(
                                      context,
                                      title: '重命名列',
                                      label: '列名',
                                      initialValue: custom.name,
                                    );
                                    if (next == null || next.trim().isEmpty) {
                                      return;
                                    }
                                    await onRenameColumn(
                                      columnId: custom.id,
                                      name: next.trim(),
                                    );
                                    if (!sheetContext.mounted) {
                                      return;
                                    }
                                    Navigator.of(sheetContext).pop();
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: '删除列',
                                  onPressed: () async {
                                    await onDeleteColumn(custom.id);
                                    if (!sheetContext.mounted) {
                                      return;
                                    }
                                    Navigator.of(sheetContext).pop();
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                ),
                              ],
                              const Icon(Icons.drag_indicator_rounded),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('关闭'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          await persist();
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('应用布局'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showBoardSettingsSheet(
    BuildContext context, {
    required BoardPreset preset,
    required Future<void> Function(BoardPreset preset) onSubmit,
  }) async {
    var draft = preset;
    final customRatioController = TextEditingController(
      text: _formatAspectRatioValue(preset.aspectRatio),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _SideSheet(
              title: '分镜设置',
              width: 420,
              child: Column(
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
                      setSheetState(() {
                        draft = draft.copyWith(textScaleMode: value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    initialValue: _matchingAspectRatio(draft.aspectRatio),
                    decoration: const InputDecoration(labelText: '图片比例'),
                    items: _aspectRatioOptions
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.value,
                            child: Text(entry.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setSheetState(() {
                        draft = draft.copyWith(aspectRatio: value);
                        customRatioController.text = _formatAspectRatioValue(
                          value,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customRatioController,
                    decoration: const InputDecoration(
                      labelText: '自定义比例',
                      hintText: '支持 2.35 或 21:9',
                    ),
                    onChanged: (value) {
                      final parsed = _parseAspectRatioInput(value);
                      if (parsed == null) {
                        return;
                      }
                      setSheetState(() {
                        draft = draft.copyWith(aspectRatio: parsed);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前比例：${_formatAspectRatioLabel(draft.aspectRatio)}',
                    style: Theme.of(context).textTheme.bodySmall,
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
                      setSheetState(() {
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
                      setSheetState(() {
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
                      setSheetState(() {
                        draft = draft.copyWith(
                          shotNumberMode: value
                              ? ShotNumberMode.custom
                              : ShotNumberMode.order,
                        );
                      });
                    },
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          await onSubmit(draft);
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('应用'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    customRatioController.dispose();
  }

  double? _matchingAspectRatio(double value) {
    for (final option in _aspectRatioOptions) {
      if ((option.value - value).abs() < 0.001) {
        return option.value;
      }
    }
    return null;
  }

  double? _parseAspectRatioInput(String raw) {
    final input = raw.trim();
    if (input.isEmpty) {
      return null;
    }
    if (input.contains(':')) {
      final parts = input.split(':');
      if (parts.length != 2) {
        return null;
      }
      final left = double.tryParse(parts.first.trim());
      final right = double.tryParse(parts.last.trim());
      if (left == null || right == null || left <= 0 || right <= 0) {
        return null;
      }
      return left / right;
    }
    final direct = double.tryParse(input);
    if (direct == null || direct <= 0) {
      return null;
    }
    return direct;
  }

  String _formatAspectRatioValue(double ratio) {
    return ratio.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _formatAspectRatioLabel(double ratio) {
    for (final option in _aspectRatioOptions) {
      if ((option.value - ratio).abs() < 0.001) {
        return option.label;
      }
    }
    return _formatAspectRatioValue(ratio);
  }

  Future<void> _showBatchEditSheet(
    BuildContext context, {
    required List<CustomColumnDefinition> customColumns,
    required Map<String, List<String>> fixedFieldCustomOptions,
    required Future<void> Function(String fieldKey, Object? value) onApply,
  }) async {
    String selectedFieldKey = ShotFieldKey.content.storageKey;
    final valueController = TextEditingController();
    String? selectedEnumValue;

    Iterable<_BatchFieldOption> options() sync* {
      yield const _BatchFieldOption(
        key: 'shotNo',
        label: '镜号',
        kind: _BatchFieldKind.text,
      );
      yield _BatchFieldOption(
        key: 'shotSize',
        label: '景别',
        kind: _BatchFieldKind.select,
        values: fixedFieldOptions(
          'shotSize',
          customOptionsByFieldKey: fixedFieldCustomOptions,
        ),
      );
      yield const _BatchFieldOption(
        key: 'durationSec',
        label: '时长(秒)',
        kind: _BatchFieldKind.number,
      );
      yield const _BatchFieldOption(
        key: 'content',
        label: '画面内容',
        kind: _BatchFieldKind.text,
      );
      yield const _BatchFieldOption(
        key: 'dialogue',
        label: '台词',
        kind: _BatchFieldKind.text,
      );
      yield const _BatchFieldOption(
        key: 'notes',
        label: '备注',
        kind: _BatchFieldKind.text,
      );
      yield const _BatchFieldOption(
        key: 'sceneExpectation',
        label: '场景预期',
        kind: _BatchFieldKind.text,
      );
      yield const _BatchFieldOption(
        key: 'audio',
        label: '声音',
        kind: _BatchFieldKind.text,
      );
      yield _BatchFieldOption(
        key: 'cameraAngle',
        label: '机位角度',
        kind: _BatchFieldKind.select,
        values: fixedFieldOptions(
          'cameraAngle',
          customOptionsByFieldKey: fixedFieldCustomOptions,
        ),
      );
      yield _BatchFieldOption(
        key: 'cameraMove',
        label: '运镜',
        kind: _BatchFieldKind.select,
        values: fixedFieldOptions(
          'cameraMove',
          customOptionsByFieldKey: fixedFieldCustomOptions,
        ),
      );
      yield _BatchFieldOption(
        key: 'cameraRig',
        label: '机位设备',
        kind: _BatchFieldKind.select,
        values: fixedFieldOptions(
          'cameraRig',
          customOptionsByFieldKey: fixedFieldCustomOptions,
        ),
      );
      yield _BatchFieldOption(
        key: 'focalLength',
        label: '焦段',
        kind: _BatchFieldKind.select,
        values: fixedFieldOptions(
          'focalLength',
          customOptionsByFieldKey: fixedFieldCustomOptions,
        ),
      );

      for (final column in customColumns) {
        if (column.type == CustomColumnType.image) {
          continue;
        }
        yield _BatchFieldOption(
          key: column.fieldKey,
          label: column.name,
          kind: switch (column.type) {
            CustomColumnType.text => _BatchFieldKind.text,
            CustomColumnType.number => _BatchFieldKind.number,
            CustomColumnType.singleSelect => _BatchFieldKind.select,
            CustomColumnType.image => _BatchFieldKind.text,
          },
          values: column.options,
        );
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final option = options().firstWhere(
              (item) => item.key == selectedFieldKey,
            );
            return _SideSheet(
              title: '批量编辑',
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedFieldKey,
                    decoration: const InputDecoration(labelText: '字段'),
                    items: options()
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.key,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setSheetState(() {
                        selectedFieldKey = value;
                        valueController.clear();
                        selectedEnumValue = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (option.kind == _BatchFieldKind.select)
                    DropdownButtonFormField<String>(
                      initialValue: selectedEnumValue,
                      decoration: const InputDecoration(labelText: '统一值'),
                      items: option.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedEnumValue = value;
                        });
                      },
                    )
                  else
                    TextField(
                      controller: valueController,
                      keyboardType: option.kind == _BatchFieldKind.number
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: const InputDecoration(labelText: '统一值'),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final value = switch (option.kind) {
                            _BatchFieldKind.text => valueController.text.trim(),
                            _BatchFieldKind.number =>
                              int.tryParse(valueController.text.trim()) ??
                                  double.tryParse(
                                    valueController.text.trim(),
                                  )?.round() ??
                                  0,
                            _BatchFieldKind.select => selectedEnumValue,
                          };
                          await onApply(option.key, value);
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('应用'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showNamePrompt(
    BuildContext context, {
    required String title,
    required String label,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    String? result;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
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
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    return result;
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.shotCount,
    required this.totalDuration,
    required this.selectedCount,
    required this.isBatchMode,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onCreateShot,
    required this.onOpenAiStoryboard,
    required this.onToggleBatchMode,
    required this.onChooseSelection,
    required this.onOpenBatchEdit,
    required this.onOpenBoardSettings,
    required this.onOpenColumnSettings,
  });

  final int shotCount;
  final int totalDuration;
  final int selectedCount;
  final bool isBatchMode;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onCreateShot;
  final VoidCallback onOpenAiStoryboard;
  final VoidCallback onToggleBatchMode;
  final ValueChanged<_SelectionAction> onChooseSelection;
  final VoidCallback? onOpenBatchEdit;
  final VoidCallback onOpenBoardSettings;
  final VoidCallback onOpenColumnSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1520;
        final dense = constraints.maxWidth < 1320;
        final summaryStyle = theme.textTheme.bodySmall;

        return SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text('分镜制作', style: theme.textTheme.titleSmall),
                          const SizedBox(width: 6),
                          Text('$shotCount 镜头', style: summaryStyle),
                          const SizedBox(width: 6),
                          Text('${totalDuration}s', style: summaryStyle),
                          if (isBatchMode) ...[
                            const SizedBox(width: 6),
                            Text('已选 $selectedCount', style: summaryStyle),
                          ],
                          SizedBox(width: dense ? 10 : 12),
                          _ToolbarPillButton(
                            icon: Icons.checklist_rtl_rounded,
                            label: isBatchMode ? '退出批量' : '批量',
                            onPressed: onToggleBatchMode,
                          ),
                          const SizedBox(width: 6),
                          PopupMenuButton<_SelectionAction>(
                            tooltip: '选择镜头',
                            onSelected: onChooseSelection,
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _SelectionAction.selectAll,
                                child: Text('全选'),
                              ),
                              PopupMenuItem(
                                value: _SelectionAction.invert,
                                child: Text('反选'),
                              ),
                              PopupMenuItem(
                                value: _SelectionAction.clear,
                                child: Text('清空选择'),
                              ),
                            ],
                            child: _ToolbarPillButton(
                              icon: Icons.ads_click_rounded,
                              label: selectedCount > 0
                                  ? '选择($selectedCount)'
                                  : '选择',
                            ),
                          ),
                          if (isBatchMode) ...[
                            const SizedBox(width: 6),
                            _ToolbarPillButton(
                              icon: Icons.edit_note_rounded,
                              label: '批量填值',
                              onPressed: onOpenBatchEdit,
                            ),
                          ],
                          SizedBox(width: compact ? 6 : 8),
                          _ToolbarDivider(),
                          SizedBox(width: compact ? 6 : 8),
                          _ToolbarPillButton(
                            icon: Icons.view_compact_alt_rounded,
                            label: '分镜设置',
                            onPressed: onOpenBoardSettings,
                          ),
                          const SizedBox(width: 6),
                          _ToolbarPillButton(
                            icon: Icons.view_column_rounded,
                            label: '列设置',
                            onPressed: onOpenColumnSettings,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ToolbarIconButton(
                    tooltip: '撤销',
                    icon: Icons.undo_rounded,
                    onPressed: canUndo ? onUndo : null,
                  ),
                  const SizedBox(width: 6),
                  _ToolbarIconButton(
                    tooltip: '重做',
                    icon: Icons.redo_rounded,
                    onPressed: canRedo ? onRedo : null,
                  ),
                  const SizedBox(width: 6),
                  FilledButton.icon(
                    onPressed: onOpenAiStoryboard,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('AI生成'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.icon(
                    onPressed: onCreateShot,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('新建镜头'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.75),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
    );
  }
}

class _ToolbarPillButton extends StatelessWidget {
  const _ToolbarPillButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = enabled
        ? (isDark
              ? scheme.outline.withValues(alpha: 0.92)
              : scheme.outlineVariant)
        : scheme.outlineVariant;
    final backgroundColor = enabled
        ? (isDark
              ? scheme.surfaceContainerHigh.withValues(alpha: 0.42)
              : Colors.transparent)
        : (isDark
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.18)
              : Colors.transparent);
    final textStyle = Theme.of(context).textTheme.labelLarge;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: enabled ? null : scheme.outline),
              const SizedBox(width: 5),
              Text(
                label,
                style: textStyle?.copyWith(
                  color: enabled ? null : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideSheet extends StatelessWidget {
  const _SideSheet({
    required this.title,
    required this.child,
    required this.width,
  });

  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

enum _SelectionAction { selectAll, invert, clear }

enum _BatchFieldKind { text, number, select }

class _BatchFieldOption {
  const _BatchFieldOption({
    required this.key,
    required this.label,
    required this.kind,
    this.values = const [],
  });

  final String key;
  final String label;
  final _BatchFieldKind kind;
  final List<String> values;
}
