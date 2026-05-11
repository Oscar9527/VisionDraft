import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../ai_storyboard/presentation/ai_storyboard_sheet.dart';
import '../../../project_workspace/application/project_workspace_controller.dart';
import '../../../project_workspace/domain/models/board_preset.dart';
import '../../../project_workspace/domain/models/column_preset.dart';
import '../../../project_workspace/domain/models/column_template.dart';
import '../../../project_workspace/domain/models/custom_column_definition.dart';
import '../../../project_workspace/domain/models/asset_ref.dart';
import '../../../project_workspace/domain/models/shot_record.dart';
import '../../../project_workspace/domain/models/shot_fields.dart';
import '../../../project_workspace/domain/models/storyboard_scene.dart';
import '../widgets/storyboard_table.dart';

const String _sceneDragPrefix = 'scene:';
const String _shotDragPrefix = 'shot:';

bool _shouldHideDefaultSceneChrome(List<StoryboardScene> scenes) {
  if (scenes.length != 1) {
    return false;
  }
  final scene = scenes.first;
  return scene.name.trim().isEmpty &&
      scene.numberMode == StoryboardSceneNumberMode.auto;
}

String _sceneDragData(String sceneId) => '$_sceneDragPrefix$sceneId';

String? _extractSceneDragId(Object? data) {
  if (data is! String || !data.startsWith(_sceneDragPrefix)) {
    return null;
  }
  return data.substring(_sceneDragPrefix.length);
}

String? _extractShotDragId(Object? data) {
  if (data is! String || !data.startsWith(_shotDragPrefix)) {
    return null;
  }
  return data.substring(_shotDragPrefix.length);
}

List<String> _extractShotDragIds(Object? data) {
  final single = _extractShotDragId(data);
  if (single == null) {
    return const <String>[];
  }
  return single
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

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
  String? _activeSceneId;

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

  int? _resolveInsertIndexForVisibleRow(
    List<ShotRecord> allShots,
    List<ShotRecord> visibleShots,
    int rowIndex, {
    required bool placeBelow,
  }) {
    if (rowIndex < 0 || rowIndex >= visibleShots.length) {
      return null;
    }
    final anchorShotId = visibleShots[rowIndex].id;
    final globalIndex = allShots.indexWhere((shot) => shot.id == anchorShotId);
    if (globalIndex < 0) {
      return null;
    }
    return placeBelow ? globalIndex + 1 : globalIndex;
  }

  Future<void> _reorderVisibleShots(
    ProjectWorkspaceController controller,
    List<ShotRecord> allShots,
    List<ShotRecord> visibleShots,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < 0 || oldIndex >= visibleShots.length) {
      return;
    }
    final activeSceneId = _activeSceneId;
    if (activeSceneId == null) {
      await controller.reorderShots(oldIndex, newIndex);
      return;
    }
    final safeTarget = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final reorderedSceneShots = [...visibleShots];
    final moved = reorderedSceneShots.removeAt(oldIndex);
    reorderedSceneShots.insert(
      safeTarget.clamp(0, reorderedSceneShots.length),
      moved,
    );

    final reorderedSceneIds = reorderedSceneShots
        .map((shot) => shot.id)
        .toList();
    final nextShotIds = <String>[];
    var insertedSceneShots = false;

    for (final shot in allShots) {
      if (shot.sceneId == activeSceneId) {
        if (!insertedSceneShots) {
          nextShotIds.addAll(reorderedSceneIds);
          insertedSceneShots = true;
        }
        continue;
      }
      nextShotIds.add(shot.id);
    }

    if (!insertedSceneShots) {
      nextShotIds.addAll(reorderedSceneIds);
    }

    await controller.reorderShotIds(nextShotIds);
  }

  Future<void> _moveShotsToScene(
    ProjectWorkspaceController controller,
    List<String> shotIds,
    String targetSceneId,
    int? targetIndex,
  ) async {
    await controller.moveShotsToScene(
      shotIds: shotIds,
      targetSceneId: targetSceneId,
      targetIndex: targetIndex,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _activeSceneId = targetSceneId;
      _selectedShotIds
        ..clear()
        ..addAll(shotIds);
    });
  }

  int _insertSceneIndex(List<StoryboardScene> scenes) {
    final activeSceneId = _activeSceneId;
    if (activeSceneId == null) {
      return scenes.length;
    }
    final activeScene = scenes.firstWhereOrNull(
      (scene) => scene.id == activeSceneId,
    );
    if (activeScene == null) {
      return scenes.length;
    }
    return activeScene.sortIndex + 1;
  }

  Future<void> _reorderSceneBlocks(
    ProjectWorkspaceController controller,
    List<StoryboardScene> scenes,
    String draggedSceneId,
    int targetIndex,
  ) async {
    final orderedIds = [...scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final sceneIds = orderedIds.map((scene) => scene.id).toList();
    final sourceIndex = sceneIds.indexOf(draggedSceneId);
    if (sourceIndex < 0) {
      return;
    }
    final movedSceneId = sceneIds.removeAt(sourceIndex);
    final safeTargetIndex = targetIndex > sourceIndex
        ? targetIndex - 1
        : targetIndex;
    sceneIds.insert(safeTargetIndex.clamp(0, sceneIds.length), movedSceneId);
    await controller.reorderScenes(sceneIds);
    if (!mounted) {
      return;
    }
    setState(() {
      _activeSceneId = draggedSceneId;
    });
  }

  double _estimateSceneTableHeight(
    List<ShotRecord> shots,
    Map<String, double> rowHeights,
    double zoomPercent,
  ) {
    final scale = (zoomPercent / 100).clamp(0.7, 1.5);
    if (shots.isEmpty) {
      return 120;
    }
    var bodyHeight = 0.0;
    for (final shot in shots) {
      bodyHeight += (rowHeights[shot.id] ?? 88) * scale;
    }
    final estimated = bodyHeight + 56;
    return estimated.clamp(220.0, 680.0);
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
    final hideDefaultSceneChrome = _shouldHideDefaultSceneChrome(
      snapshot.scenes,
    );
    _activeSceneId ??= snapshot.scenes.isNotEmpty
        ? snapshot.scenes.first.id
        : null;
    final hasActiveScene = snapshot.scenes.any(
      (scene) => scene.id == _activeSceneId,
    );
    if (!hasActiveScene && snapshot.scenes.isNotEmpty) {
      _activeSceneId = snapshot.scenes.first.id;
    }
    final activeSceneId = _activeSceneId;
    final activeScene = activeSceneId == null
        ? null
        : snapshot.scenes
              .where((scene) => scene.id == activeSceneId)
              .firstOrNull;
    final activeSceneLabel = hideDefaultSceneChrome || activeScene == null
        ? null
        : activeScene.name.trim().isEmpty
        ? '${activeScene.displayNumber(activeScene.sortIndex + 1)}场'
        : '${activeScene.displayNumber(activeScene.sortIndex + 1)}场 ${activeScene.name.trim()}';
    final visibleShots =
        activeSceneId == null
              ? snapshot.shots
              : snapshot.shots
                    .where((shot) => shot.sceneId == activeSceneId)
                    .toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final visibleShotIds = visibleShots.map((shot) => shot.id).toList();
    final orderedSelectedShotIds = snapshot.shots
        .where((shot) => _selectedShotIds.contains(shot.id))
        .map((shot) => shot.id)
        .toList();

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
                  onPressed: () =>
                      controller.createShot(sceneId: _activeSceneId),
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
                    onTap: () => _openMobileShotEditor(
                      context,
                      controller,
                      snapshot,
                      shot,
                    ),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${shot.durationSec}s'),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
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
          activeSceneLabel: activeSceneLabel,
          isBatchMode: _isBatchMode,
          canUndo: history.canUndo,
          canRedo: history.canRedo,
          onUndo: controller.undo,
          onRedo: controller.redo,
          onCreateShot: () => controller.createShot(sceneId: _activeSceneId),
          onCreateScene: () async {
            final scene = await controller.createScene(
              insertIndex: _insertSceneIndex(snapshot.scenes),
            );
            if (!mounted) {
              return;
            }
            setState(() {
              _activeSceneId = scene.id;
              _selectedShotIds.clear();
            });
          },
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
            final shotIds = visibleShotIds;
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
          onOpenBatchRowHeight: _selectedShotIds.isEmpty
              ? null
              : () => _showBatchRowHeightSheet(
                  context,
                  selectedShotIds: _selectedShotIds.toList(),
                  currentRowHeights: gridSession.rowHeightsByShotId,
                  zoomPercent: gridSession.zoomPercent,
                  onApply: (height) => gridSessionController.setRowHeights(
                    _selectedShotIds,
                    height / ((gridSession.zoomPercent / 100).clamp(0.7, 1.5)),
                  ),
                ),
          onDeleteSelected: _selectedShotIds.isEmpty
              ? null
              : () async {
                  final selected = _selectedShotIds.toList();
                  for (final shotId in selected) {
                    await controller.deleteShot(shotId);
                  }
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _selectedShotIds.clear();
                  });
                },
          onOpenBoardSettings: () => _showBoardSettingsSheet(
            context,
            preset: snapshot.boardPreset,
            onSubmit: controller.updateBoardPreset,
          ),
          onOpenColumnSettings: () =>
              _openColumnSettings(context, controller, snapshot),
        ),
        if (!hideDefaultSceneChrome) ...[
          _SceneStrip(
            scenes: snapshot.scenes,
            shots: snapshot.shots,
            activeSceneId: _activeSceneId,
            onSelectScene: (sceneId) {
              setState(() {
                _activeSceneId = sceneId;
                if (!_isBatchMode) {
                  _selectedShotIds.clear();
                }
              });
            },
            onMoveShotToScene: (shotIds, targetSceneId) =>
                _moveShotsToScene(controller, shotIds, targetSceneId, null),
            onCreateScene: () async {
              final scene = await controller.createScene(
                insertIndex: _insertSceneIndex(snapshot.scenes),
              );
              if (!context.mounted) {
                return;
              }
              setState(() {
                _activeSceneId = scene.id;
                if (!_isBatchMode) {
                  _selectedShotIds.clear();
                }
              });
            },
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: _SceneWorkspace(
            scenes: snapshot.scenes,
            shots: snapshot.shots,
            showSceneHeaders: !hideDefaultSceneChrome,
            activeSceneId: _activeSceneId,
            onSelectScene: (sceneId) {
              setState(() {
                _activeSceneId = sceneId;
                if (!_isBatchMode) {
                  _selectedShotIds.clear();
                }
              });
            },
            onMoveShotToScene: (shotIds, targetSceneId, targetIndex) =>
                _moveShotsToScene(
                  controller,
                  shotIds,
                  targetSceneId,
                  targetIndex,
                ),
            onRenameScene: (scene) async {
              final next = await _showNamePrompt(
                context,
                title: '重命名场',
                label: '场名称',
                initialValue: scene.name,
              );
              if (next == null) {
                return;
              }
              await controller.updateScene(
                scene.copyWith(name: next.trim(), updatedAt: DateTime.now()),
              );
            },
            onToggleNumberMode: (scene, useManual) async {
              await controller.updateScene(
                scene.copyWith(
                  numberMode: useManual
                      ? StoryboardSceneNumberMode.manual
                      : StoryboardSceneNumberMode.auto,
                  updatedAt: DateTime.now(),
                ),
              );
            },
            onEditManualNumber: (scene) async {
              final next = await _showNamePrompt(
                context,
                title: '设置场号',
                label: '场号',
                initialValue: scene.manualNumber,
              );
              if (next == null) {
                return;
              }
              await controller.updateScene(
                scene.copyWith(
                  numberMode: StoryboardSceneNumberMode.manual,
                  manualNumber: next.trim(),
                  updatedAt: DateTime.now(),
                ),
              );
            },
            onDeleteScene: (scene) => controller.deleteEmptyScene(scene.id),
            onReorderScene: (draggedSceneId, targetIndex) =>
                _reorderSceneBlocks(
                  controller,
                  snapshot.scenes,
                  draggedSceneId,
                  targetIndex,
                ),
            sceneTableBuilder: (sceneId, sceneShots) {
              return SizedBox(
                height: _estimateSceneTableHeight(
                  sceneShots,
                  gridSession.rowHeightsByShotId,
                  gridSession.zoomPercent,
                ),
                child: StoryboardTable(
                  shots: sceneShots,
                  columnPreset: snapshot.columnPreset,
                  effectiveFieldOrderKeys: gridSession.effectiveFieldOrderKeys,
                  customColumns: snapshot.customColumns,
                  fixedFieldCustomOptions: snapshot.fixedFieldCustomOptions,
                  boardPreset: snapshot.boardPreset,
                  isBatchMode: _isBatchMode,
                  selectedShotIds: _selectedShotIds.intersection(
                    sceneShots.map((shot) => shot.id).toSet(),
                  ),
                  dragSelectedShotIdsInOrder: orderedSelectedShotIds,
                  globalSelectedShotCount: _selectedShotIds.length,
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
                  onReorder: (oldIndex, newIndex) => _reorderVisibleShots(
                    controller,
                    snapshot.shots,
                    sceneShots,
                    oldIndex,
                    newIndex,
                  ),
                  onUpdateField: controller.updateShotField,
                  onImportAsset: controller.importAsset,
                  onRelinkAsset: controller.relinkAsset,
                  onInsertRowAbove: (rowIndex) => controller.createShot(
                    insertIndex: _resolveInsertIndexForVisibleRow(
                      snapshot.shots,
                      sceneShots,
                      rowIndex,
                      placeBelow: false,
                    ),
                    sceneId: sceneId,
                  ),
                  onInsertRowBelow: (rowIndex) => controller.createShot(
                    insertIndex: _resolveInsertIndexForVisibleRow(
                      snapshot.shots,
                      sceneShots,
                      rowIndex,
                      placeBelow: true,
                    ),
                    sceneId: sceneId,
                  ),
                  onDeleteRow: controller.deleteShot,
                  onDropShot: ({required shotIds, required targetIndex}) =>
                      _moveShotsToScene(
                        controller,
                        shotIds,
                        sceneId,
                        targetIndex,
                      ),
                  onAddColumn: () async => _showCreateCustomColumnSheet(
                    context,
                    onSubmit: ({required name, required type, enumSource}) =>
                        controller.createCustomColumn(
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
                  onReorderField:
                      ({
                        required draggedFieldKey,
                        required targetFieldKey,
                        required placeAfter,
                      }) {
                        final nextOrder = gridSessionController.reorderField(
                          draggedFieldKey: draggedFieldKey,
                          targetFieldKey: targetFieldKey,
                          placeAfter: placeAfter,
                          fallbackOrder: snapshot.columnPreset.fieldOrderKeys,
                        );
                        if (nextOrder == null) {
                          return;
                        }
                        controller.updateColumnPreset(
                          snapshot.columnPreset.copyWith(
                            fieldOrderKeys: nextOrder,
                            updatedAt: DateTime.now(),
                          ),
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
                  onDeleteFixedFieldOption:
                      ({required fieldKey, required option}) =>
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
              );
            },
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

  Future<void> _openMobileShotEditor(
    BuildContext context,
    ProjectWorkspaceController controller,
    snapshot,
    ShotRecord shot,
  ) async {
    final fixedOptions = snapshot.fixedFieldCustomOptions;
    final customColumns = snapshot.customColumns;
    final sceneItems = [...snapshot.scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    String sceneLabel(StoryboardScene scene) {
      final base = '${scene.displayNumber(scene.sortIndex + 1)}场';
      return scene.name.trim().isEmpty ? base : '$base ${scene.name.trim()}';
    }

    Widget buildTextField({
      required String label,
      required String initialValue,
      required Future<void> Function(String value) onCommit,
      int minLines = 1,
      int maxLines = 1,
      TextInputType? keyboardType,
    }) {
      final textController = TextEditingController(text: initialValue);
      return TextField(
        controller: textController,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (value) => onCommit(value.trim()),
        onEditingComplete: () => onCommit(textController.text.trim()),
      );
    }

    Future<void> pickImage(String targetField) async {
      final path = await ref.read(mediaImportServiceProvider).pickImageFile();
      if (path == null || path.isEmpty) {
        return;
      }
      await controller.importAsset(
        shotId: shot.id,
        targetField: targetField,
        sourcePath: path,
        assetMode: AssetMode.managed,
      );
    }

    Widget buildImageField({
      required String label,
      required String fieldKey,
      required AssetRef? asset,
    }) {
      final previewPath = asset?.uri;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
            ),
            clipBehavior: Clip.antiAlias,
            child: previewPath == null || previewPath.isEmpty
                ? Center(
                    child: Text(
                      '未设置图片',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Image.file(
                    File(previewPath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        '图片不可用',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => pickImage(fieldKey),
                icon: const Icon(Icons.image_outlined),
                label: Text(asset == null ? '导入图片' : '替换图片'),
              ),
              if (asset != null)
                OutlinedButton.icon(
                  onPressed: () => controller.updateShotField(
                    shotId: shot.id,
                    fieldKey: fieldKey,
                    value: null,
                  ),
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('清除'),
                ),
            ],
          ),
        ],
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.92,
              maxChildSize: 0.96,
              minChildSize: 0.7,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '镜头 ${shot.shotNo.isEmpty ? shot.orderIndex + 1 : shot.shotNo}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: shot.sceneId,
                                decoration: const InputDecoration(
                                  labelText: '所属场',
                                ),
                                items: sceneItems
                                    .map(
                                      (scene) => DropdownMenuItem<String>(
                                        value: scene.id,
                                        child: Text(sceneLabel(scene)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null || value == shot.sceneId) {
                                    return;
                                  }
                                  await controller.moveShotToScene(
                                    shotId: shot.id,
                                    targetSceneId: value,
                                  );
                                  if (!sheetContext.mounted) {
                                    return;
                                  }
                                  Navigator.of(sheetContext).pop();
                                },
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '镜号',
                                initialValue: shot.shotNo,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey: ShotFieldKey.shotNo.storageKey,
                                  value: value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: shot.shotSize.isEmpty
                                    ? null
                                    : shot.shotSize,
                                decoration: const InputDecoration(
                                  labelText: '景别',
                                ),
                                items:
                                    fixedFieldOptions(
                                          ShotFieldKey.shotSize.storageKey,
                                          customOptionsByFieldKey: fixedOptions,
                                        )
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) async {
                                  await controller.updateShotField(
                                    shotId: shot.id,
                                    fieldKey: ShotFieldKey.shotSize.storageKey,
                                    value: value ?? '',
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '时长(秒)',
                                initialValue: shot.durationSec.toString(),
                                keyboardType: TextInputType.number,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey: ShotFieldKey.durationSec.storageKey,
                                  value: int.tryParse(value) ?? 0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildImageField(
                                label: '画面',
                                fieldKey: ShotFieldKey.frameImage.storageKey,
                                asset: shot.frameImage,
                              ),
                              const SizedBox(height: 12),
                              buildImageField(
                                label: '参考图',
                                fieldKey:
                                    ShotFieldKey.referenceImage.storageKey,
                                asset: shot.referenceImage,
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '画面内容',
                                initialValue: shot.content,
                                minLines: 3,
                                maxLines: 5,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey: ShotFieldKey.content.storageKey,
                                  value: value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '台词',
                                initialValue: shot.dialogue,
                                minLines: 2,
                                maxLines: 4,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey: ShotFieldKey.dialogue.storageKey,
                                  value: value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '备注',
                                initialValue: shot.notes,
                                minLines: 2,
                                maxLines: 4,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey: ShotFieldKey.notes.storageKey,
                                  value: value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '场景预期',
                                initialValue: shot.sceneExpectation,
                                minLines: 2,
                                maxLines: 4,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey:
                                      ShotFieldKey.sceneExpectation.storageKey,
                                  value: value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                label: '声音',
                                initialValue: shot.audio,
                                minLines: 2,
                                maxLines: 4,
                                onCommit: (value) => controller.updateShotField(
                                  shotId: shot.id,
                                  fieldKey: ShotFieldKey.audio.storageKey,
                                  value: value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: shot.cameraAngle.isEmpty
                                    ? null
                                    : shot.cameraAngle,
                                decoration: const InputDecoration(
                                  labelText: '机位角度',
                                ),
                                items:
                                    fixedFieldOptions(
                                          ShotFieldKey.cameraAngle.storageKey,
                                          customOptionsByFieldKey: fixedOptions,
                                        )
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    controller.updateShotField(
                                      shotId: shot.id,
                                      fieldKey:
                                          ShotFieldKey.cameraAngle.storageKey,
                                      value: value ?? '',
                                    ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: shot.cameraMove.isEmpty
                                    ? null
                                    : shot.cameraMove,
                                decoration: const InputDecoration(
                                  labelText: '运镜',
                                ),
                                items:
                                    fixedFieldOptions(
                                          ShotFieldKey.cameraMove.storageKey,
                                          customOptionsByFieldKey: fixedOptions,
                                        )
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    controller.updateShotField(
                                      shotId: shot.id,
                                      fieldKey:
                                          ShotFieldKey.cameraMove.storageKey,
                                      value: value ?? '',
                                    ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: shot.cameraRig.isEmpty
                                    ? null
                                    : shot.cameraRig,
                                decoration: const InputDecoration(
                                  labelText: '机位设备',
                                ),
                                items:
                                    fixedFieldOptions(
                                          ShotFieldKey.cameraRig.storageKey,
                                          customOptionsByFieldKey: fixedOptions,
                                        )
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    controller.updateShotField(
                                      shotId: shot.id,
                                      fieldKey:
                                          ShotFieldKey.cameraRig.storageKey,
                                      value: value ?? '',
                                    ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: shot.focalLength.isEmpty
                                    ? null
                                    : shot.focalLength,
                                decoration: const InputDecoration(
                                  labelText: '焦段',
                                ),
                                items:
                                    fixedFieldOptions(
                                          ShotFieldKey.focalLength.storageKey,
                                          customOptionsByFieldKey: fixedOptions,
                                        )
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    controller.updateShotField(
                                      shotId: shot.id,
                                      fieldKey:
                                          ShotFieldKey.focalLength.storageKey,
                                      value: value ?? '',
                                    ),
                              ),
                              for (final column in customColumns) ...[
                                const SizedBox(height: 12),
                                switch (column.type) {
                                  CustomColumnType.text => buildTextField(
                                    label: column.name,
                                    initialValue:
                                        (shot.customFieldValues[column.fieldKey]
                                            as String?) ??
                                        '',
                                    onCommit: (value) =>
                                        controller.updateShotField(
                                          shotId: shot.id,
                                          fieldKey: column.fieldKey,
                                          value: value,
                                        ),
                                  ),
                                  CustomColumnType.number => buildTextField(
                                    label: column.name,
                                    initialValue:
                                        '${shot.customFieldValues[column.fieldKey] ?? ''}',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onCommit: (value) =>
                                        controller.updateShotField(
                                          shotId: shot.id,
                                          fieldKey: column.fieldKey,
                                          value: double.tryParse(value) ?? 0,
                                        ),
                                  ),
                                  CustomColumnType.singleSelect =>
                                    DropdownButtonFormField<String>(
                                      initialValue:
                                          (shot.customFieldValues[column
                                                          .fieldKey]
                                                      as String?)
                                                  ?.isEmpty ==
                                              true
                                          ? null
                                          : shot.customFieldValues[column
                                                    .fieldKey]
                                                as String?,
                                      decoration: InputDecoration(
                                        labelText: column.name,
                                      ),
                                      items: column.options
                                          .map(
                                            (item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) =>
                                          controller.updateShotField(
                                            shotId: shot.id,
                                            fieldKey: column.fieldKey,
                                            value: value ?? '',
                                          ),
                                    ),
                                  CustomColumnType.image => buildImageField(
                                    label: column.name,
                                    fieldKey: column.fieldKey,
                                    asset:
                                        shot.customFieldValues[column.fieldKey]
                                            as AssetRef?,
                                  ),
                                  _ => const SizedBox.shrink(),
                                },
                              ],
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () async {
                                  await controller.deleteShot(shot.id);
                                  if (!sheetContext.mounted) {
                                    return;
                                  }
                                  Navigator.of(sheetContext).pop();
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('删除镜头'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showBatchRowHeightSheet(
    BuildContext context, {
    required List<String> selectedShotIds,
    required Map<String, double> currentRowHeights,
    required double zoomPercent,
    required ValueChanged<double> onApply,
  }) async {
    final uiScale = (zoomPercent / 100).clamp(0.7, 1.5);
    final displayMin = 84.0 * uiScale;
    final displayMax = 280.0 * uiScale;
    final explicitHeights = selectedShotIds
        .map((shotId) => currentRowHeights[shotId])
        .whereType<double>()
        .map((height) => height * uiScale)
        .toList();
    final initialHeight = explicitHeights.isEmpty
        ? 108.0 * uiScale
        : explicitHeights.reduce((sum, value) => sum + value) /
              explicitHeights.length;
    final controller = TextEditingController(
      text: initialHeight.toStringAsFixed(0),
    );
    var currentHeight = initialHeight.clamp(displayMin, displayMax);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _SideSheet(
              title: '批量调整行高',
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选 ${selectedShotIds.length} 行。输入统一高度，或直接拖动任意已选中行的底边批量调整。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '统一行高',
                      suffixText: 'px',
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null) {
                        return;
                      }
                      setSheetState(() {
                        currentHeight = parsed.clamp(displayMin, displayMax);
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  Slider(
                    value: currentHeight,
                    min: displayMin,
                    max: displayMax,
                    divisions: 28,
                    label: currentHeight.toStringAsFixed(0),
                    onChanged: (value) {
                      setSheetState(() {
                        currentHeight = value;
                        controller.text = value.toStringAsFixed(0);
                      });
                    },
                  ),
                  Row(
                    children: [
                      Text(displayMin.toStringAsFixed(0)),
                      const Spacer(),
                      Text(
                        '当前 ${currentHeight.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const Spacer(),
                      Text(displayMax.toStringAsFixed(0)),
                    ],
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
                        onPressed: () {
                          final parsed =
                              double.tryParse(controller.text.trim()) ??
                              currentHeight;
                          onApply(parsed.clamp(displayMin, displayMax));
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
    required this.activeSceneLabel,
    required this.isBatchMode,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onCreateShot,
    required this.onCreateScene,
    required this.onOpenAiStoryboard,
    required this.onToggleBatchMode,
    required this.onChooseSelection,
    required this.onOpenBatchEdit,
    required this.onOpenBatchRowHeight,
    required this.onDeleteSelected,
    required this.onOpenBoardSettings,
    required this.onOpenColumnSettings,
  });

  final int shotCount;
  final int totalDuration;
  final int selectedCount;
  final String? activeSceneLabel;
  final bool isBatchMode;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onCreateShot;
  final VoidCallback onCreateScene;
  final VoidCallback onOpenAiStoryboard;
  final VoidCallback onToggleBatchMode;
  final ValueChanged<_SelectionAction> onChooseSelection;
  final VoidCallback? onOpenBatchEdit;
  final VoidCallback? onOpenBatchRowHeight;
  final VoidCallback? onDeleteSelected;
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
                          if (activeSceneLabel != null &&
                              activeSceneLabel!.trim().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text('当前场：$activeSceneLabel', style: summaryStyle),
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
                              forceEnabledAppearance: true,
                            ),
                          ),
                          if (isBatchMode) ...[
                            const SizedBox(width: 6),
                            _ToolbarPillButton(
                              icon: Icons.edit_note_rounded,
                              label: '批量填值',
                              onPressed: onOpenBatchEdit,
                            ),
                            const SizedBox(width: 6),
                            _ToolbarPillButton(
                              icon: Icons.height_rounded,
                              label: '批量行高',
                              onPressed: onOpenBatchRowHeight,
                            ),
                            const SizedBox(width: 6),
                            _ToolbarPillButton(
                              icon: Icons.delete_sweep_rounded,
                              label: '批量删除',
                              onPressed: onDeleteSelected,
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
                  MenuAnchor(
                    builder: (context, controller, child) {
                      return FilledButton.icon(
                        onPressed: () {
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('新建'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: onCreateShot,
                        leadingIcon: const Icon(Icons.video_call_outlined),
                        child: const Text('新建镜头'),
                      ),
                      MenuItemButton(
                        onPressed: onCreateScene,
                        leadingIcon: const Icon(Icons.view_agenda_outlined),
                        child: const Text('新建场'),
                      ),
                    ],
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

class _SceneStrip extends StatelessWidget {
  const _SceneStrip({
    required this.scenes,
    required this.shots,
    required this.activeSceneId,
    required this.onSelectScene,
    required this.onMoveShotToScene,
    required this.onCreateScene,
  });

  final List<StoryboardScene> scenes;
  final List<ShotRecord> shots;
  final String? activeSceneId;
  final ValueChanged<String> onSelectScene;
  final Future<void> Function(List<String> shotIds, String targetSceneId)
  onMoveShotToScene;
  final VoidCallback onCreateScene;

  @override
  Widget build(BuildContext context) {
    final orderedScenes = [...scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final shotsByScene = <String, int>{};
    for (final shot in shots) {
      final sceneId = shot.sceneId;
      shotsByScene[sceneId] = (shotsByScene[sceneId] ?? 0) + 1;
    }

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: orderedScenes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final scene = orderedScenes[index];
                final count = shotsByScene[scene.id] ?? 0;
                final number = scene.displayNumber(index + 1);
                final label = scene.name.trim().isEmpty
                    ? '$number场'
                    : '$number场  ${scene.name.trim()}';
                final isActive = activeSceneId == scene.id;
                final theme = Theme.of(context);
                final scheme = theme.colorScheme;
                final borderColor = isActive
                    ? scheme.primary.withValues(alpha: 0.4)
                    : theme.dividerColor;
                final backgroundColor = isActive
                    ? scheme.primaryContainer
                    : scheme.surface;
                final foregroundColor = isActive
                    ? scheme.onPrimaryContainer
                    : theme.textTheme.bodyMedium?.color;
                return DragTarget<String>(
                  onWillAcceptWithDetails: (details) =>
                      _extractShotDragIds(details.data).isNotEmpty,
                  onAcceptWithDetails: (details) async {
                    final shotIds = _extractShotDragIds(details.data);
                    if (shotIds.isEmpty) {
                      return;
                    }
                    await onMoveShotToScene(shotIds, scene.id);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final highlighted = candidateData.isNotEmpty;
                    return Material(
                      color: highlighted
                          ? scheme.primaryContainer.withValues(alpha: 0.88)
                          : backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => onSelectScene(scene.id),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: highlighted
                                ? scheme.primaryContainer.withValues(
                                    alpha: 0.88,
                                  )
                                : backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: highlighted ? scheme.primary : borderColor,
                              width: highlighted ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                highlighted ? '放到$label' : label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: foregroundColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? scheme.primary.withValues(alpha: 0.12)
                                      : scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$count',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: foregroundColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onCreateScene,
            icon: const Icon(Icons.view_agenda_outlined, size: 16),
            label: const Text('新建场'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneWorkspace extends StatefulWidget {
  const _SceneWorkspace({
    required this.scenes,
    required this.shots,
    required this.showSceneHeaders,
    required this.activeSceneId,
    required this.onSelectScene,
    required this.onMoveShotToScene,
    required this.onRenameScene,
    required this.onToggleNumberMode,
    required this.onEditManualNumber,
    required this.onDeleteScene,
    required this.onReorderScene,
    required this.sceneTableBuilder,
  });

  final List<StoryboardScene> scenes;
  final List<ShotRecord> shots;
  final bool showSceneHeaders;
  final String? activeSceneId;
  final ValueChanged<String> onSelectScene;
  final Future<void> Function(
    List<String> shotIds,
    String targetSceneId,
    int? targetIndex,
  )
  onMoveShotToScene;
  final Future<void> Function(StoryboardScene scene) onRenameScene;
  final Future<void> Function(StoryboardScene scene, bool useManual)
  onToggleNumberMode;
  final Future<void> Function(StoryboardScene scene) onEditManualNumber;
  final Future<void> Function(StoryboardScene scene) onDeleteScene;
  final Future<void> Function(String draggedSceneId, int targetIndex)
  onReorderScene;
  final Widget Function(String sceneId, List<ShotRecord> sceneShots)
  sceneTableBuilder;

  @override
  State<_SceneWorkspace> createState() => _SceneWorkspaceState();
}

class _SceneWorkspaceState extends State<_SceneWorkspace> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sceneKeys = <String, GlobalKey>{};

  GlobalKey _sceneKey(String sceneId) =>
      _sceneKeys.putIfAbsent(sceneId, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveScene());
  }

  @override
  void didUpdateWidget(covariant _SceneWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSceneId != widget.activeSceneId) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToActiveScene(),
      );
    }
  }

  void _scrollToActiveScene() {
    final activeSceneId = widget.activeSceneId;
    if (activeSceneId == null || !_scrollController.hasClients) {
      return;
    }
    final key = _sceneKeys[activeSceneId];
    final context = key?.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      alignment: 0.04,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderedScenes = [...widget.scenes]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final orderedShots = [...widget.shots]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final shotsByScene = <String, List<ShotRecord>>{
      for (final scene in orderedScenes) scene.id: <ShotRecord>[],
    };
    for (final shot in orderedShots) {
      shotsByScene.putIfAbsent(shot.sceneId, () => <ShotRecord>[]).add(shot);
    }

    if (!widget.showSceneHeaders && orderedScenes.length == 1) {
      final scene = orderedScenes.first;
      final sceneShots = shotsByScene[scene.id] ?? const <ShotRecord>[];
      return sceneShots.isEmpty
          ? _EmptySceneDropZone(
              onSelect: () => widget.onSelectScene(scene.id),
              highlighted: false,
            )
          : widget.sceneTableBuilder(scene.id, sceneShots);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: orderedScenes.length * 2 + 1,
      itemBuilder: (context, index) {
        if (index.isEven) {
          return _SceneReorderDropTarget(
            targetIndex: index ~/ 2,
            onAcceptScene: widget.onReorderScene,
          );
        }
        final sceneIndex = index ~/ 2;
        final scene = orderedScenes[sceneIndex];
        final sceneShots = shotsByScene[scene.id] ?? const <ShotRecord>[];
        return KeyedSubtree(
          key: _sceneKey(scene.id),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SceneWorkspaceBlock(
              scene: scene,
              autoNumber: sceneIndex + 1,
              showHeader: widget.showSceneHeaders,
              isActive: widget.activeSceneId == scene.id,
              shotCount: sceneShots.length,
              shots: sceneShots,
              onSelect: () => widget.onSelectScene(scene.id),
              onMoveShotToScene: (shotIds) => widget.onMoveShotToScene(
                shotIds,
                scene.id,
                sceneShots.length,
              ),
              onRenameScene: () => widget.onRenameScene(scene),
              onToggleNumberMode: () => widget.onToggleNumberMode(
                scene,
                scene.numberMode != StoryboardSceneNumberMode.manual,
              ),
              onEditManualNumber: () => widget.onEditManualNumber(scene),
              onDeleteScene: sceneShots.isEmpty
                  ? () => widget.onDeleteScene(scene)
                  : null,
              child: widget.sceneTableBuilder(scene.id, sceneShots),
            ),
          ),
        );
      },
    );
  }
}

class _SceneReorderDropTarget extends StatelessWidget {
  const _SceneReorderDropTarget({
    required this.targetIndex,
    required this.onAcceptScene,
  });

  final int targetIndex;
  final Future<void> Function(String draggedSceneId, int targetIndex)
  onAcceptScene;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          _extractSceneDragId(details.data) != null,
      onAcceptWithDetails: (details) async {
        final sceneId = _extractSceneDragId(details.data);
        if (sceneId == null) {
          return;
        }
        await onAcceptScene(sceneId, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: active ? 16 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: active
              ? Center(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _SceneWorkspaceBlock extends StatelessWidget {
  const _SceneWorkspaceBlock({
    required this.scene,
    required this.autoNumber,
    required this.showHeader,
    required this.isActive,
    required this.shotCount,
    required this.shots,
    required this.onSelect,
    required this.onMoveShotToScene,
    required this.onRenameScene,
    required this.onToggleNumberMode,
    required this.onEditManualNumber,
    required this.onDeleteScene,
    required this.child,
  });

  final StoryboardScene scene;
  final int autoNumber;
  final bool showHeader;
  final bool isActive;
  final int shotCount;
  final List<ShotRecord> shots;
  final VoidCallback onSelect;
  final Future<void> Function(List<String> shotIds) onMoveShotToScene;
  final Future<void> Function() onRenameScene;
  final Future<void> Function() onToggleNumberMode;
  final Future<void> Function() onEditManualNumber;
  final Future<void> Function()? onDeleteScene;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sceneNumber = scene.displayNumber(autoNumber);
    final title = scene.name.trim().isEmpty
        ? '$sceneNumber场'
        : '$sceneNumber场  ${scene.name.trim()}';
    final borderColor = isActive
        ? scheme.primary.withValues(alpha: 0.55)
        : theme.dividerColor.withValues(alpha: 0.9);

    if (!showHeader) {
      return shots.isEmpty
          ? _EmptySceneDropZone(onSelect: onSelect, highlighted: false)
          : child;
    }

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          _extractShotDragIds(details.data).isNotEmpty,
      onAcceptWithDetails: (details) async {
        final shotIds = _extractShotDragIds(details.data);
        if (shotIds.isEmpty) {
          return;
        }
        await onMoveShotToScene(shotIds);
      },
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: highlighted
                ? scheme.primaryContainer.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted
                  ? scheme.primary.withValues(alpha: 0.85)
                  : borderColor,
              width: highlighted ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onSelect,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? scheme.primaryContainer.withValues(alpha: 0.72)
                        : scheme.surfaceContainerHighest.withValues(
                            alpha: 0.35,
                          ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: borderColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Draggable<String>(
                        data: _sceneDragData(scene.id),
                        maxSimultaneousDrags: 1,
                        feedback: Material(
                          color: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: scheme.primary),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<_SceneBlockAction>(
                              tooltip: '场操作',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 172,
                                maxWidth: 220,
                              ),
                              onSelected: (action) async {
                                switch (action) {
                                  case _SceneBlockAction.rename:
                                    await onRenameScene();
                                  case _SceneBlockAction.toggleNumberMode:
                                    await onToggleNumberMode();
                                  case _SceneBlockAction.editManualNumber:
                                    await onEditManualNumber();
                                  case _SceneBlockAction.deleteScene:
                                    if (onDeleteScene != null) {
                                      await onDeleteScene!();
                                    }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: _SceneBlockAction.rename,
                                  child: SizedBox(
                                    width: 140,
                                    child: Text('重命名场'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: _SceneBlockAction.toggleNumberMode,
                                  child: SizedBox(
                                    width: 140,
                                    child: Text(
                                      scene.numberMode ==
                                              StoryboardSceneNumberMode.manual
                                          ? '恢复自动场号'
                                          : '切换为手动场号',
                                    ),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: _SceneBlockAction.editManualNumber,
                                  child: SizedBox(
                                    width: 140,
                                    child: Text('设置手动场号'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: _SceneBlockAction.deleteScene,
                                  enabled: onDeleteScene != null,
                                  child: SizedBox(
                                    width: 140,
                                    child: Text(
                                      onDeleteScene != null ? '删除空场' : '仅空场可删除',
                                    ),
                                  ),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 14,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '场菜单',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? scheme.primary.withValues(alpha: 0.12)
                              : scheme.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$shotCount 镜',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: shots.isEmpty
                    ? (isActive || highlighted
                          ? _EmptySceneDropZone(
                              onSelect: onSelect,
                              highlighted: highlighted,
                            )
                          : const SizedBox(height: 2))
                    : child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptySceneDropZone extends StatelessWidget {
  const _EmptySceneDropZone({
    required this.onSelect,
    required this.highlighted,
  });

  final VoidCallback onSelect;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: highlighted ? 88 : 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted
              ? scheme.primaryContainer.withValues(alpha: 0.28)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlighted
                ? scheme.primary.withValues(alpha: 0.8)
                : theme.dividerColor.withValues(alpha: 0.9),
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          highlighted ? '松手放到这个场' : '空场，拖镜头到这里或点击后新建镜头',
          style: theme.textTheme.bodyMedium,
        ),
      ),
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
    this.forceEnabledAppearance = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool forceEnabledAppearance;

  @override
  Widget build(BuildContext context) {
    final enabled = forceEnabledAppearance || onPressed != null;
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

enum _SceneBlockAction {
  rename,
  toggleNumberMode,
  editManualNumber,
  deleteScene,
}

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
