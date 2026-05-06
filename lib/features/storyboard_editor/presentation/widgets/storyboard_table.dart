import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../project_workspace/domain/models/asset_ref.dart';
import '../../../project_workspace/domain/models/board_preset.dart';
import '../../../project_workspace/domain/models/column_preset.dart';
import '../../../project_workspace/domain/models/custom_column_definition.dart';
import '../../../project_workspace/domain/models/shot_fields.dart';
import '../../../project_workspace/domain/models/shot_record.dart';

typedef ShotFieldUpdater = Future<void> Function({
  required String shotId,
  required String fieldKey,
  required Object? value,
});

typedef ShotAssetImporter = Future<void> Function({
  required String shotId,
  required String targetField,
  required String sourcePath,
  required AssetMode assetMode,
});

typedef ShotAssetRelinker = Future<void> Function({
  required String shotId,
  required String targetField,
  required String newPath,
});

class StoryboardTable extends StatefulWidget {
  const StoryboardTable({
    super.key,
    required this.shots,
    required this.columnPreset,
    required this.customColumns,
    required this.fixedFieldCustomOptions,
    required this.boardPreset,
    required this.isBatchMode,
    required this.selectedShotIds,
    required this.onSelectShot,
    required this.onReorder,
    required this.onUpdateField,
    required this.onImportAsset,
    required this.onRelinkAsset,
  });

  final List<ShotRecord> shots;
  final ColumnPreset columnPreset;
  final List<CustomColumnDefinition> customColumns;
  final Map<String, List<String>> fixedFieldCustomOptions;
  final BoardPreset boardPreset;
  final bool isBatchMode;
  final Set<String> selectedShotIds;
  final void Function(String shotId, bool selected) onSelectShot;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ShotFieldUpdater onUpdateField;
  final ShotAssetImporter onImportAsset;
  final ShotAssetRelinker onRelinkAsset;

  @override
  State<StoryboardTable> createState() => _StoryboardTableState();
}

class _StoryboardTableState extends State<StoryboardTable> {
  final ScrollController _headerController = ScrollController();
  final ScrollController _contentController = ScrollController();
  bool _syncingHeader = false;
  bool _syncingContent = false;

  @override
  void initState() {
    super.initState();
    _headerController.addListener(() {
      if (_syncingHeader) {
        return;
      }
      _syncingContent = true;
      if (_contentController.hasClients) {
        _contentController.jumpTo(_headerController.offset);
      }
      _syncingContent = false;
    });
    _contentController.addListener(() {
      if (_syncingContent) {
        return;
      }
      _syncingHeader = true;
      if (_headerController.hasClients) {
        _headerController.jumpTo(_contentController.offset);
      }
      _syncingHeader = false;
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleFields = _buildVisibleFieldKeys();
    final totalWidth = 64 +
        visibleFields.fold<double>(
          0,
          (sum, fieldKey) => sum + _columnWidth(fieldKey),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.28),
              child: Row(
                children: [
                  const SizedBox(width: 64),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _headerController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totalWidth - 64,
                        child: Row(
                          children: visibleFields
                              .map(
                                (fieldKey) => _HeaderCell(
                                  label: _labelFor(fieldKey),
                                  width: _columnWidth(fieldKey),
                                  canAddCustomValue:
                                      _supportsCustomValue(fieldKey),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              onReorder: widget.isBatchMode ? (_, _) {} : widget.onReorder,
              itemCount: widget.shots.length,
              itemBuilder: (context, index) {
                final shot = widget.shots[index];
                final selected = widget.selectedShotIds.contains(shot.id);
                return Container(
                  key: ValueKey(shot.id),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.24)
                        : index.isOdd
                            ? Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.12)
                            : Colors.transparent,
                    border: Border(
                      top: BorderSide(
                        color:
                            Theme.of(context).dividerColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 64,
                        child: _buildLeadingCell(context, index, shot, selected),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _contentController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: totalWidth - 64,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: visibleFields
                                  .map(
                                    (fieldKey) => _EditableCell(
                                      width: _columnWidth(fieldKey),
                                      shot: shot,
                                      fieldKey: fieldKey,
                                      customColumns: widget.customColumns,
                                      fixedFieldCustomOptions:
                                          widget.fixedFieldCustomOptions,
                                      boardPreset: widget.boardPreset,
                                      onUpdateField: widget.onUpdateField,
                                      onImportAsset: widget.onImportAsset,
                                      onRelinkAsset: widget.onRelinkAsset,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildLeadingCell(
    BuildContext context,
    int index,
    ShotRecord shot,
    bool selected,
  ) {
    if (widget.isBatchMode) {
      return Checkbox(
        value: selected,
        onChanged: (value) => widget.onSelectShot(shot.id, value == true),
      );
    }
    return ReorderableDragStartListener(
      index: index,
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.drag_indicator_rounded, size: 18),
        ),
      ),
    );
  }

  List<String> _buildVisibleFieldKeys() {
    final visible = widget.columnPreset.visibleFieldKeys.toSet();
    final ordered = widget.columnPreset.fieldOrderKeys
        .where((fieldKey) => visible.contains(fieldKey))
        .toList();
    if (!ordered.contains(ShotFieldKey.shotNo.storageKey)) {
      ordered.insert(0, ShotFieldKey.shotNo.storageKey);
    }
    return ordered;
  }

  String _labelFor(String fieldKey) {
    final fixed = shotFieldKeyFromStorageKey(fieldKey);
    if (fixed != null) {
      return fixed.label;
    }
    final custom = _findCustomColumn(fieldKey);
    return custom?.name ?? fieldKey;
  }

  bool _supportsCustomValue(String fieldKey) {
    final custom = _findCustomColumn(fieldKey);
    if (custom != null) {
      return custom.type == CustomColumnType.singleSelect;
    }
    return fixedFieldSupportsCustomValue(fieldKey);
  }

  CustomColumnDefinition? _findCustomColumn(String fieldKey) {
    for (final column in widget.customColumns) {
      if (column.fieldKey == fieldKey) {
        return column;
      }
    }
    return null;
  }

  double _columnWidth(String fieldKey) {
    return switch (fieldKey) {
      'shotNo' => 88,
      'durationSec' => 118,
      'shotSize' => 126,
      'frameImage' => 280,
      'referenceImage' => 220,
      'content' => 320,
      'dialogue' => 220,
      'notes' => 240,
      'sceneExpectation' => 220,
      'audio' => 180,
      'cameraAngle' => 150,
      'cameraMove' => 150,
      'cameraRig' => 160,
      'focalLength' => 130,
      _ => 170,
    };
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.width,
    required this.canAddCustomValue,
  });

  final String label;
  final double width;
  final bool canAddCustomValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (canAddCustomValue)
              const Tooltip(
                message: '此列支持录入自定义选项',
                child: Icon(Icons.tune_rounded, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditableCell extends StatefulWidget {
  const _EditableCell({
    required this.width,
    required this.shot,
    required this.fieldKey,
    required this.customColumns,
    required this.fixedFieldCustomOptions,
    required this.boardPreset,
    required this.onUpdateField,
    required this.onImportAsset,
    required this.onRelinkAsset,
  });

  final double width;
  final ShotRecord shot;
  final String fieldKey;
  final List<CustomColumnDefinition> customColumns;
  final Map<String, List<String>> fixedFieldCustomOptions;
  final BoardPreset boardPreset;
  final ShotFieldUpdater onUpdateField;
  final ShotAssetImporter onImportAsset;
  final ShotAssetRelinker onRelinkAsset;

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _stringValue);
    _focusNode = FocusNode()
      ..addListener(() {
        if (!_focusNode.hasFocus) {
          _commitTextIfNeeded();
        }
      });
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != _stringValue) {
      _controller.text = _stringValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  CustomColumnDefinition? get _customColumn {
    for (final column in widget.customColumns) {
      if (column.fieldKey == widget.fieldKey) {
        return column;
      }
    }
    return null;
  }

  String get _stringValue {
    final custom = _customColumn;
    if (custom != null) {
      return widget.shot.customFieldValues[custom.fieldKey]?.toString() ?? '';
    }

    return switch (widget.fieldKey) {
      'shotNo' => widget.shot.shotNo,
      'shotSize' => widget.shot.shotSize,
      'durationSec' => widget.shot.durationSec.toString(),
      'content' => widget.shot.content,
      'dialogue' => widget.shot.dialogue,
      'notes' => widget.shot.notes,
      'sceneExpectation' => widget.shot.sceneExpectation,
      'audio' => widget.shot.audio,
      'cameraAngle' => widget.shot.cameraAngle,
      'cameraMove' => widget.shot.cameraMove,
      'cameraRig' => widget.shot.cameraRig,
      'focalLength' => widget.shot.focalLength,
      'frameImage' => widget.shot.frameImage?.uri ?? '',
      'referenceImage' => widget.shot.referenceImage?.uri ?? '',
      _ => '',
    };
  }

  bool get _isImageField => fixedFieldIsImage(widget.fieldKey);

  bool get _isDropdownField {
    if (_customColumn case final custom?) {
      return custom.type == CustomColumnType.singleSelect;
    }
    return fixedFieldIsDropdown(widget.fieldKey);
  }

  bool get _isNumericField {
    if (widget.fieldKey == ShotFieldKey.durationSec.storageKey) {
      return true;
    }
    return _customColumn?.type == CustomColumnType.number;
  }

  bool get _isLongTextField {
    if (_customColumn != null) {
      return false;
    }
    return fixedFieldIsLongText(widget.fieldKey);
  }

  List<String> get _options {
    final custom = _customColumn;
    if (custom != null) {
      return [...custom.options, _customOptionSentinel];
    }
    return [
      ...fixedFieldOptions(
        widget.fieldKey,
        customOptionsByFieldKey: widget.fixedFieldCustomOptions,
      ),
      _customOptionSentinel,
    ];
  }

  Future<void> _commitTextIfNeeded() async {
    if (_submitting || _isImageField || _isDropdownField) {
      return;
    }
    final raw = _controller.text.trim();
    if (raw == _stringValue.trim()) {
      return;
    }

    _submitting = true;
    try {
      final nextValue = _isNumericField
          ? (int.tryParse(raw) ?? double.tryParse(raw)?.round() ?? 0)
          : raw;
      await widget.onUpdateField(
        shotId: widget.shot.id,
        fieldKey: widget.fieldKey,
        value: nextValue,
      );
    } finally {
      _submitting = false;
    }
  }

  Future<void> _pickAsset(AssetMode mode) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'images',
          extensions: ['png', 'jpg', 'jpeg', 'webp'],
        ),
      ],
    );
    if (file == null) {
      return;
    }
    await widget.onImportAsset(
      shotId: widget.shot.id,
      targetField: widget.fieldKey,
      sourcePath: file.path,
      assetMode: mode,
    );
  }

  Future<void> _relinkAsset() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'images',
          extensions: ['png', 'jpg', 'jpeg', 'webp'],
        ),
      ],
    );
    if (file == null) {
      return;
    }
    await widget.onRelinkAsset(
      shotId: widget.shot.id,
      targetField: widget.fieldKey,
      newPath: file.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      constraints: BoxConstraints(minHeight: _isImageField ? 176 : 132),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
          ),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isImageField) {
      final asset = widget.fieldKey == ShotFieldKey.frameImage.storageKey
          ? widget.shot.frameImage
          : widget.shot.referenceImage;
      return _ImageFieldCell(
        asset: asset,
        height: widget.fieldKey == ShotFieldKey.frameImage.storageKey ? 92 : 78,
        onImportManaged: () => _pickAsset(AssetMode.managed),
        onImportLinked: () => _pickAsset(AssetMode.linked),
        onRelink: asset == null ? null : _relinkAsset,
        onClear: asset == null
            ? null
            : () async {
                await widget.onUpdateField(
                  shotId: widget.shot.id,
                  fieldKey: widget.fieldKey,
                  value: null,
                );
              },
      );
    }

    if (_isDropdownField) {
      final currentValue =
          _options.contains(_stringValue) ? _stringValue : null;
      return DropdownButtonFormField<String>(
        initialValue: currentValue,
        isExpanded: true,
        items: _options
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) async {
          if (value == null) {
            return;
          }
          if (value == _customOptionSentinel) {
            final next = await _promptCustomValue(context);
            if (next == null || next.isEmpty) {
              return;
            }
            await widget.onUpdateField(
              shotId: widget.shot.id,
              fieldKey: widget.fieldKey,
              value: next,
            );
            return;
          }
          await widget.onUpdateField(
            shotId: widget.shot.id,
            fieldKey: widget.fieldKey,
            value: value,
          );
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
        ),
      );
    }

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType:
          _isNumericField ? TextInputType.number : TextInputType.text,
      minLines: _isLongTextField ? 4 : 1,
      maxLines: _isLongTextField ? 6 : 1,
      onSubmitted: (_) => _commitTextIfNeeded(),
      decoration: InputDecoration(
        isDense: true,
        hintText: _isLongTextField ? '输入内容' : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<String?> _promptCustomValue(BuildContext context) async {
    final controller = TextEditingController();
    String? result;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加自定义选项'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: '输入新选项'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                result = controller.text.trim();
                Navigator.of(context).pop();
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

class _ImageFieldCell extends StatelessWidget {
  const _ImageFieldCell({
    required this.asset,
    required this.height,
    required this.onImportManaged,
    required this.onImportLinked,
    required this.onRelink,
    required this.onClear,
  });

  final AssetRef? asset;
  final double height;
  final VoidCallback onImportManaged;
  final VoidCallback onImportLinked;
  final VoidCallback? onRelink;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final uri = asset?.uri;
    final file = (uri != null && uri.isNotEmpty) ? File(uri) : null;
    final canPreview = file != null && file.existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.9),
            ),
          ),
          child: canPreview
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file, fit: BoxFit.cover),
                )
              : const Center(
                  child: Icon(Icons.add_photo_alternate_outlined),
                ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MiniAction(
              label: '导入',
              icon: Icons.upload_file_outlined,
              onPressed: onImportManaged,
            ),
            _MiniAction(
              label: '外链',
              icon: Icons.link_outlined,
              onPressed: onImportLinked,
            ),
            _MiniAction(
              label: '重连',
              icon: Icons.sync_outlined,
              onPressed: onRelink,
            ),
            _MiniAction(
              label: '清除',
              icon: Icons.delete_outline_rounded,
              onPressed: onClear,
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

const _customOptionSentinel = '__custom_option__';
