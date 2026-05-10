import 'dart:io';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/editor_grid_session.dart';
import '../../../project_workspace/domain/models/asset_ref.dart';
import '../../../project_workspace/domain/models/board_preset.dart';
import '../../../project_workspace/domain/models/column_preset.dart';
import '../../../project_workspace/domain/models/custom_column_definition.dart';
import '../../../project_workspace/domain/models/shot_fields.dart';
import '../../../project_workspace/domain/models/shot_record.dart';

typedef ShotFieldUpdater =
    Future<void> Function({
      required String shotId,
      required String fieldKey,
      required Object? value,
    });

typedef ShotAssetImporter =
    Future<void> Function({
      required String shotId,
      required String targetField,
      required String sourcePath,
      required AssetMode assetMode,
    });

typedef ShotAssetRelinker =
    Future<void> Function({
      required String shotId,
      required String targetField,
      required String newPath,
    });
typedef RowActionRequested = Future<void> Function(int rowIndex);
typedef DeleteRowRequested = Future<void> Function(String shotId);

typedef AddColumnRequested = Future<void> Function();
typedef ColumnActionRequested = Future<void> Function(String fieldKey);
typedef ColumnWidthChanged = void Function(String fieldKey, double width);
typedef RowHeightChanged = void Function(String shotId, double height);
typedef ReorderFieldRequested =
    void Function({
      required String draggedFieldKey,
      required String targetFieldKey,
      required bool placeAfter,
    });
typedef FixedFieldOptionDeleteRequested =
    Future<void> Function({required String fieldKey, required String option});
typedef CustomColumnOptionDeleteRequested =
    Future<void> Function({required String columnId, required String option});

class StoryboardTable extends StatefulWidget {
  const StoryboardTable({
    super.key,
    required this.shots,
    required this.columnPreset,
    required this.effectiveFieldOrderKeys,
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
    required this.onInsertRowAbove,
    required this.onInsertRowBelow,
    required this.onDeleteRow,
    required this.onAddColumn,
    required this.onHideColumn,
    required this.onMoveColumnLeft,
    required this.onMoveColumnRight,
    required this.onReorderField,
    required this.onRenameColumn,
    required this.onDeleteColumn,
    required this.onDeleteFixedFieldOption,
    required this.onDeleteCustomColumnOption,
    this.zoomPercent = 100,
    this.columnWidths = const {},
    this.rowHeights = const {},
    this.focusedCell,
    this.onZoomChanged,
    this.onColumnWidthChanged,
    this.onRowHeightChanged,
    this.onFocusedCellChanged,
  });

  final List<ShotRecord> shots;
  final ColumnPreset columnPreset;
  final List<String> effectiveFieldOrderKeys;
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
  final RowActionRequested onInsertRowAbove;
  final RowActionRequested onInsertRowBelow;
  final DeleteRowRequested onDeleteRow;
  final AddColumnRequested onAddColumn;
  final ColumnActionRequested onHideColumn;
  final ColumnActionRequested onMoveColumnLeft;
  final ColumnActionRequested onMoveColumnRight;
  final ReorderFieldRequested onReorderField;
  final Future<void> Function(String columnId) onRenameColumn;
  final Future<void> Function(String columnId) onDeleteColumn;
  final FixedFieldOptionDeleteRequested onDeleteFixedFieldOption;
  final CustomColumnOptionDeleteRequested onDeleteCustomColumnOption;
  final double zoomPercent;
  final Map<String, double> columnWidths;
  final Map<String, double> rowHeights;
  final FocusedGridCell? focusedCell;
  final ValueChanged<double>? onZoomChanged;
  final ColumnWidthChanged? onColumnWidthChanged;
  final RowHeightChanged? onRowHeightChanged;
  final ValueChanged<FocusedGridCell?>? onFocusedCellChanged;

  @override
  State<StoryboardTable> createState() => _StoryboardTableState();
}

class _StoryboardTableState extends State<StoryboardTable> {
  final ScrollController _headerController = ScrollController();
  final ScrollController _contentController = ScrollController();
  final Map<String, FocusNode> _cellFocusNodes = <String, FocusNode>{};
  bool _syncingHeader = false;
  bool _syncingContent = false;

  double get _uiScale => widget.zoomPercent / 100;
  double get _leadingWidth => 64;
  double get _trailingWidth => 40;

  @override
  void initState() {
    super.initState();
    _headerController.addListener(() {
      if (_syncingHeader || !_contentController.hasClients) {
        return;
      }
      _syncingContent = true;
      _contentController.jumpTo(_headerController.offset);
      _syncingContent = false;
    });
    _contentController.addListener(() {
      if (_syncingContent || !_headerController.hasClients) {
        return;
      }
      _syncingHeader = true;
      _headerController.jumpTo(_contentController.offset);
      _syncingHeader = false;
    });
  }

  @override
  void didUpdateWidget(covariant StoryboardTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedCell != oldWidget.focusedCell &&
        widget.focusedCell != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestCellFocus(widget.focusedCell!);
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    for (final node in _cellFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleFields = _buildVisibleFieldKeys();
        final resolvedWidths = _resolvedColumnWidths(
          visibleFields,
          constraints.maxWidth - _leadingWidth - _trailingWidth,
        );
        final contentWidth =
            resolvedWidths.values.fold<double>(0, (sum, width) => sum + width) +
            _trailingWidth;
        final totalWidth = _leadingWidth + contentWidth;

        return Focus(
          autofocus: true,
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent &&
                  event.buttons == 0 &&
                  HardwareKeyboard.instance.isControlPressed) {
                final delta = event.scrollDelta.dy > 0 ? -10.0 : 10.0;
                final next = (widget.zoomPercent + delta).clamp(70.0, 150.0);
                widget.onZoomChanged?.call(next);
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark ? scheme.surfaceContainerLow : scheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  Container(
                    color: isDark
                        ? scheme.surfaceContainerHighest.withValues(alpha: 0.34)
                        : scheme.surfaceContainerHighest.withValues(
                            alpha: 0.22,
                          ),
                    child: Row(
                      children: [
                        _LeadingHeaderCell(
                          width: _leadingWidth,
                          isBatchMode: widget.isBatchMode,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _headerController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: totalWidth - _leadingWidth,
                              child: Row(
                                children: [
                                  for (final entry
                                      in visibleFields.asMap().entries)
                                    _HeaderCell(
                                      key: ValueKey('header:${entry.value}'),
                                      fieldKey: entry.value,
                                      label: _labelFor(entry.value),
                                      width: resolvedWidths[entry.value]!,
                                      minWidth: _minimumDisplayColumnWidth(
                                        entry.value,
                                      ),
                                      maxWidth: _maximumDisplayColumnWidth(
                                        entry.value,
                                      ),
                                      uiScale: _uiScale,
                                      isShotNo:
                                          entry.value ==
                                          ShotFieldKey.shotNo.storageKey,
                                      canAddCustomValue: _supportsCustomValue(
                                        entry.value,
                                      ),
                                      customColumn: _findCustomColumn(
                                        entry.value,
                                      ),
                                      showLeadingBorder: entry.key > 0,
                                      onAction: (action) => _handleColumnAction(
                                        entry.value,
                                        action,
                                      ),
                                      onWidthChanged:
                                          widget.onColumnWidthChanged,
                                      onReorderDropped:
                                          ({
                                            required draggedFieldKey,
                                            required placeAfter,
                                          }) {
                                            widget.onReorderField(
                                              draggedFieldKey: draggedFieldKey,
                                              targetFieldKey: entry.value,
                                              placeAfter: placeAfter,
                                            );
                                          },
                                    ),
                                  _AddColumnHeaderCell(
                                    width: _trailingWidth,
                                    showLeadingBorder: visibleFields.isNotEmpty,
                                    onPressed: widget.onAddColumn,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      onReorder: widget.isBatchMode
                          ? (_, _) {}
                          : widget.onReorder,
                      itemCount: widget.shots.length,
                      itemBuilder: (context, index) {
                        final shot = widget.shots[index];
                        final selected = widget.selectedShotIds.contains(
                          shot.id,
                        );
                        final rowHeight = _rowHeight(shot.id);
                        return Container(
                          key: ValueKey(shot.id),
                          height: rowHeight,
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context).colorScheme.primaryContainer
                                      .withValues(alpha: isDark ? 0.22 : 0.14)
                                : index.isOdd
                                ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: isDark ? 0.16 : 0.06)
                                : Colors.transparent,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: _leadingWidth,
                                    child: _buildLeadingCell(
                                      context,
                                      index,
                                      shot,
                                      selected,
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _contentController,
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: totalWidth - _leadingWidth,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            for (final entry
                                                in visibleFields
                                                    .asMap()
                                                    .entries)
                                              _EditableCell(
                                                key: ValueKey(
                                                  '${shot.id}:${entry.value}',
                                                ),
                                                width:
                                                    resolvedWidths[entry
                                                        .value]!,
                                                height: rowHeight,
                                                shot: shot,
                                                fieldKey: entry.value,
                                                orderedFieldKeys: visibleFields,
                                                orderedShotIds: [
                                                  for (final item
                                                      in widget.shots)
                                                    item.id,
                                                ],
                                                customColumns:
                                                    widget.customColumns,
                                                fixedFieldCustomOptions: widget
                                                    .fixedFieldCustomOptions,
                                                boardPreset: widget.boardPreset,
                                                uiScale: _uiScale,
                                                showLeadingBorder:
                                                    entry.key > 0,
                                                focusNode: _focusNodeFor(
                                                  shot.id,
                                                  entry.value,
                                                ),
                                                onFocused: () => widget
                                                    .onFocusedCellChanged
                                                    ?.call(
                                                      FocusedGridCell(
                                                        shotId: shot.id,
                                                        fieldKey: entry.value,
                                                      ),
                                                    ),
                                                onNavigate: _handleNavigation,
                                                onUpdateField:
                                                    widget.onUpdateField,
                                                onImportAsset:
                                                    widget.onImportAsset,
                                                onRelinkAsset:
                                                    widget.onRelinkAsset,
                                                onDeleteFixedFieldOption: widget
                                                    .onDeleteFixedFieldOption,
                                                onDeleteCustomColumnOption: widget
                                                    .onDeleteCustomColumnOption,
                                              ),
                                            Container(
                                              width: _trailingWidth,
                                              decoration: BoxDecoration(
                                                border: visibleFields.isEmpty
                                                    ? null
                                                    : Border(
                                                        left: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor
                                                                  .withValues(
                                                                    alpha: 0.72,
                                                                  ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              _RowResizeHandle(
                                initialHeight: rowHeight,
                                minHeight: _minimumDisplayRowHeight,
                                maxHeight: _maximumDisplayRowHeight,
                                onHeightChanged: (height) =>
                                    _applyRowHeightChange(shot.id, height),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleColumnAction(
    String fieldKey,
    _ColumnAction action,
  ) async {
    switch (action) {
      case _ColumnAction.hide:
        await widget.onHideColumn(fieldKey);
      case _ColumnAction.moveLeft:
        await widget.onMoveColumnLeft(fieldKey);
      case _ColumnAction.moveRight:
        await widget.onMoveColumnRight(fieldKey);
      case _ColumnAction.rename:
        final custom = _findCustomColumn(fieldKey);
        if (custom != null) {
          await widget.onRenameColumn(custom.id);
        }
      case _ColumnAction.delete:
        final custom = _findCustomColumn(fieldKey);
        if (custom != null) {
          await widget.onDeleteColumn(custom.id);
        }
    }
  }

  Widget _buildLeadingCell(
    BuildContext context,
    int index,
    ShotRecord shot,
    bool selected,
  ) {
    if (widget.isBatchMode) {
      return Center(
        child: Checkbox(
          value: selected,
          visualDensity: VisualDensity.compact,
          onChanged: (value) => widget.onSelectShot(shot.id, value == true),
        ),
      );
    }
    return ReorderableDragStartListener(
      index: index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.5
                          : 0.32,
                    ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            PopupMenuButton<_RowAction>(
              tooltip: '行操作',
              padding: EdgeInsets.zero,
              constraints: _rowMenuConstraints,
              onSelected: (action) async {
                switch (action) {
                  case _RowAction.insertAbove:
                    await widget.onInsertRowAbove(index);
                  case _RowAction.insertBelow:
                    await widget.onInsertRowBelow(index);
                  case _RowAction.deleteRow:
                    await widget.onDeleteRow(shot.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _RowAction.insertAbove,
                  child: SizedBox(width: 140, child: Text('上方插入一行')),
                ),
                PopupMenuItem(
                  value: _RowAction.insertBelow,
                  child: SizedBox(width: 140, child: Text('下方插入一行')),
                ),
                PopupMenuItem(
                  value: _RowAction.deleteRow,
                  child: SizedBox(width: 140, child: Text('删除本行')),
                ),
              ],
              icon: Icon(
                Icons.more_vert_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageFieldKey(String fieldKey) {
    if (fixedFieldIsImage(fieldKey)) {
      return true;
    }
    final custom = _findCustomColumn(fieldKey);
    return custom?.type == CustomColumnType.image;
  }
 
  List<String> _buildVisibleFieldKeys() {
    final visible = widget.columnPreset.visibleFieldKeys.toSet();
    final validFieldKeys = _validFieldKeys();
    final sourceOrder = widget.effectiveFieldOrderKeys.isNotEmpty
        ? widget.effectiveFieldOrderKeys
        : widget.columnPreset.fieldOrderKeys;
    final ordered = <String>[];
    final seen = <String>{};
    for (final fieldKey in sourceOrder) {
      if (!validFieldKeys.contains(fieldKey) || !visible.contains(fieldKey)) {
        continue;
      }
      if (seen.add(fieldKey)) {
        ordered.add(fieldKey);
      }
    }
    for (final fieldKey in visible) {
      if (!validFieldKeys.contains(fieldKey)) {
        continue;
      }
      if (seen.add(fieldKey)) {
        ordered.add(fieldKey);
      }
    }
    if (!ordered.contains(ShotFieldKey.shotNo.storageKey)) {
      ordered.insert(0, ShotFieldKey.shotNo.storageKey);
    }
    return ordered;
  }

  Set<String> _validFieldKeys() {
    return <String>{
      for (final field in fixedShotFields) field.storageKey,
      for (final column in widget.customColumns) column.fieldKey,
    };
  }

  String _labelFor(String fieldKey) {
    final fixed = shotFieldKeyFromStorageKey(fieldKey);
    if (fixed != null) {
      return fixed.label;
    }
    final custom = _findCustomColumn(fieldKey);
    final name = custom?.name.trim() ?? '';
    return name.isEmpty ? '自定义列' : name;
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

  double get _minimumDisplayRowHeight => _minimumRowHeight * _uiScale;
  double get _maximumDisplayRowHeight => _maximumRowHeight * _uiScale;

  double _logicalColumnWidth(String fieldKey) {
    final stored = widget.columnWidths[fieldKey];
    if (stored != null) {
      return _clampDouble(
        stored,
        _minimumColumnWidth(fieldKey),
        _maximumColumnWidth(fieldKey),
      );
    }
    return _defaultColumnWidth(fieldKey);
  }

  double _displayColumnWidth(String fieldKey) {
    return _logicalColumnWidth(fieldKey) * _uiScale;
  }

  double _defaultColumnWidth(String fieldKey) {
    final custom = _findCustomColumn(fieldKey);
    if (custom?.type == CustomColumnType.image) {
      return _clampDouble(220, _minimumColumnWidth(fieldKey), _maximumColumnWidth(fieldKey));
    }
    final base = switch (fieldKey) {
      'shotNo' => 92.0,
      'durationSec' => 84.0,
      'shotSize' => 100.0,
      'frameImage' => 260.0,
      'referenceImage' => 220.0,
      'content' => 230.0,
      'dialogue' => 164.0,
      'notes' => 172.0,
      'sceneExpectation' => 172.0,
      'audio' => 152.0,
      'cameraAngle' => 110.0,
      'cameraMove' => 110.0,
      'cameraRig' => 120.0,
      'focalLength' => 100.0,
      _ => 140.0,
    };
    return _clampDouble(
      base,
      _minimumColumnWidth(fieldKey),
      _maximumColumnWidth(fieldKey),
    );
  }

  double _minimumColumnWidth(String fieldKey) {
    final base = _baseMinimumColumnWidth(fieldKey);
    final label = _labelFor(fieldKey);
    final estimatedLabelWidth = _estimateHeaderLabelWidth(label);
    final actionWidth = 24.0 + 18.0;
    return math.max(base, estimatedLabelWidth + actionWidth);
  }

  double _baseMinimumColumnWidth(String fieldKey) {
    final custom = _findCustomColumn(fieldKey);
    if (custom?.type == CustomColumnType.image) {
      return 180.0;
    }
    return switch (fieldKey) {
      'shotNo' => 90.0,
      'durationSec' => 92.0,
      'shotSize' => 108.0,
      'frameImage' => 180.0,
      'referenceImage' => 180.0,
      'content' => 188.0,
      'dialogue' => 156.0,
      'notes' => 148.0,
      'sceneExpectation' => 164.0,
      'audio' => 140.0,
      'cameraAngle' => 128.0,
      'cameraMove' => 112.0,
      'cameraRig' => 132.0,
      'focalLength' => 104.0,
      _ => 144.0,
    };
  }

  double _maximumColumnWidth(String fieldKey) {
    final custom = _findCustomColumn(fieldKey);
    if (custom?.type == CustomColumnType.image) {
      return 420.0;
    }
    final base = switch (fieldKey) {
      'content' ||
      'dialogue' ||
      'notes' ||
      'sceneExpectation' ||
      'audio' => 520.0,
      'frameImage' || 'referenceImage' => 420.0,
      _ => 300.0,
    };
    return math.max(base, _minimumColumnWidth(fieldKey));
  }

  double _minimumDisplayColumnWidth(String fieldKey) {
    return _minimumColumnWidth(fieldKey) * _uiScale;
  }

  double _maximumDisplayColumnWidth(String fieldKey) {
    return _maximumColumnWidth(fieldKey) * _uiScale;
  }

  double _estimateHeaderLabelWidth(String label) {
    var units = 0;
    for (final rune in label.runes) {
      units += rune <= 0x7f ? 1 : 2;
    }
    return math.max(24, units * 7.0);
  }

  Map<String, double> _resolvedColumnWidths(
    List<String> visibleFields,
    double availableWidth,
  ) {
    final widths = <String, double>{
      for (final fieldKey in visibleFields)
        fieldKey: _displayColumnWidth(fieldKey),
    };
    if (visibleFields.isEmpty || availableWidth <= 0) {
      return widths;
    }

    final currentWidth = widths.values.fold<double>(
      0,
      (sum, width) => sum + width,
    );
    var remaining = availableWidth - currentWidth;
    if (remaining <= 0) {
      return widths;
    }

    var targets = visibleFields
        .where(_prefersWidthExpansion)
        .where(
          (fieldKey) => widths[fieldKey]! < _maximumDisplayColumnWidth(fieldKey),
        )
        .toList();
    if (targets.isEmpty) {
      targets = visibleFields
          .where((fieldKey) => fieldKey != ShotFieldKey.shotNo.storageKey)
          .where(
            (fieldKey) =>
                widths[fieldKey]! < _maximumDisplayColumnWidth(fieldKey),
          )
          .toList();
    }

    while (remaining > 0.5 && targets.isNotEmpty) {
      final share = remaining / targets.length;
      final nextTargets = <String>[];
      for (final fieldKey in targets) {
        final current = widths[fieldKey]!;
        final maxWidth = _maximumDisplayColumnWidth(fieldKey);
        final delta = math.min(share, maxWidth - current);
        widths[fieldKey] = current + delta;
        remaining -= delta;
        if (widths[fieldKey]! < maxWidth - 0.5) {
          nextTargets.add(fieldKey);
        }
      }
      if (nextTargets.length == targets.length) {
        break;
      }
      targets = nextTargets;
    }

    return widths;
  }

  bool _prefersWidthExpansion(String fieldKey) {
    if (_isImageFieldKey(fieldKey)) {
      return true;
    }
    return switch (fieldKey) {
      'frameImage' ||
      'referenceImage' ||
      'content' ||
      'dialogue' ||
      'notes' ||
      'sceneExpectation' ||
      'audio' => true,
      _ => false,
    };
  }

  double _rowHeight(String shotId) {
    final stored = widget.rowHeights[shotId];
    return _clampDouble(
      (stored ?? _defaultRowHeight) * _uiScale,
      _minimumDisplayRowHeight,
      _maximumDisplayRowHeight,
    );
  }

  FocusNode _focusNodeFor(String shotId, String fieldKey) {
    final key = '$shotId::$fieldKey';
    return _cellFocusNodes.putIfAbsent(key, () => FocusNode(debugLabel: key));
  }

  void _requestCellFocus(FocusedGridCell cell) {
    final node = _cellFocusNodes[cell.storageKey];
    if (node != null && node.canRequestFocus) {
      node.requestFocus();
    }
  }

  void _handleNavigation(_CellNavigationIntent intent) {
    final visibleFields = _buildVisibleFieldKeys();
    if (visibleFields.isEmpty || widget.shots.isEmpty) {
      return;
    }

    final shotIndex = widget.shots.indexWhere(
      (shot) => shot.id == intent.shotId,
    );
    final fieldIndex = visibleFields.indexOf(intent.fieldKey);
    if (shotIndex == -1 || fieldIndex == -1) {
      return;
    }

    var nextShotIndex = shotIndex;
    var nextFieldIndex = fieldIndex;

    switch (intent.direction) {
      case _CellMoveDirection.down:
        nextShotIndex = (shotIndex + 1).clamp(0, widget.shots.length - 1);
      case _CellMoveDirection.up:
        nextShotIndex = (shotIndex - 1).clamp(0, widget.shots.length - 1);
      case _CellMoveDirection.nextColumn:
        if (fieldIndex >= visibleFields.length - 1) {
          nextFieldIndex = 0;
          nextShotIndex = (shotIndex + 1).clamp(0, widget.shots.length - 1);
        } else {
          nextFieldIndex = fieldIndex + 1;
        }
      case _CellMoveDirection.previousColumn:
        if (fieldIndex <= 0) {
          nextFieldIndex = visibleFields.length - 1;
          nextShotIndex = (shotIndex - 1).clamp(0, widget.shots.length - 1);
        } else {
          nextFieldIndex = fieldIndex - 1;
        }
    }

    final target = FocusedGridCell(
      shotId: widget.shots[nextShotIndex].id,
      fieldKey: visibleFields[nextFieldIndex],
    );
    widget.onFocusedCellChanged?.call(target);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCellFocus(target);
    });
  }

  void _applyRowHeightChange(String shotId, double height) {
    final onRowHeightChanged = widget.onRowHeightChanged;
    if (onRowHeightChanged == null) {
      return;
    }
    final logicalHeight = height / math.max(_uiScale, 0.001);
    if (widget.isBatchMode &&
        widget.selectedShotIds.length > 1 &&
        widget.selectedShotIds.contains(shotId)) {
      for (final selectedShotId in widget.selectedShotIds) {
        onRowHeightChanged(selectedShotId, logicalHeight);
      }
      return;
    }
    onRowHeightChanged(shotId, logicalHeight);
  }
}

enum _ColumnAction { hide, moveLeft, moveRight, rename, delete }

enum _RowAction { insertAbove, insertBelow, deleteRow }

const BoxConstraints _columnMenuConstraints = BoxConstraints(
  minWidth: 168,
  maxWidth: 220,
);

const BoxConstraints _rowMenuConstraints = BoxConstraints(
  minWidth: 168,
  maxWidth: 220,
);

class _LeadingHeaderCell extends StatelessWidget {
  const _LeadingHeaderCell({required this.width, required this.isBatchMode});

  final double width;
  final bool isBatchMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Tooltip(
        message: isBatchMode
            ? '选择当前行镜头。拖动已选中行的底边，可批量调整这些行的高度'
            : '拖动当前行调整镜头顺序',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBatchMode
                  ? Icons.checklist_rounded
                  : Icons.drag_indicator_rounded,
              size: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              isBatchMode ? '选择' : '排序',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontSize: 10, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatefulWidget {
  const _HeaderCell({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.width,
    required this.minWidth,
    required this.maxWidth,
    required this.uiScale,
    required this.isShotNo,
    required this.canAddCustomValue,
    required this.showLeadingBorder,
    required this.onAction,
    required this.onWidthChanged,
    required this.onReorderDropped,
    this.customColumn,
  });

  final String fieldKey;
  final String label;
  final double width;
  final double minWidth;
  final double maxWidth;
  final double uiScale;
  final bool isShotNo;
  final bool canAddCustomValue;
  final bool showLeadingBorder;
  final CustomColumnDefinition? customColumn;
  final ValueChanged<_ColumnAction> onAction;
  final ColumnWidthChanged? onWidthChanged;
  final void Function({
    required String draggedFieldKey,
    required bool placeAfter,
  })
  onReorderDropped;

  @override
  State<_HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<_HeaderCell> {
  double? _dragStartWidth;
  bool _hoverLeading = false;
  bool _hoverTrailing = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Stack(
        children: [
          DragTarget<String>(
            onWillAcceptWithDetails: (details) {
              if (details.data == widget.fieldKey) {
                return false;
              }
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) {
                return true;
              }
              final local = box.globalToLocal(details.offset);
              setState(() {
                _hoverLeading = local.dx < widget.width / 2;
                _hoverTrailing = !_hoverLeading;
              });
              return true;
            },
            onLeave: (_) {
              setState(() {
                _hoverLeading = false;
                _hoverTrailing = false;
              });
            },
            onAcceptWithDetails: (details) {
              final box = context.findRenderObject() as RenderBox?;
              bool placeAfter = false;
              if (box != null) {
                final local = box.globalToLocal(details.offset);
                placeAfter = local.dx >= widget.width / 2;
              }
              setState(() {
                _hoverLeading = false;
                _hoverTrailing = false;
              });
              widget.onReorderDropped(
                draggedFieldKey: details.data,
                placeAfter: placeAfter,
              );
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [
                  LongPressDraggable<String>(
                    data: widget.fieldKey,
                    axis: Axis.horizontal,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: widget.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Text(
                          widget.label,
                          style: Theme.of(context).textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.32,
                      child: _headerContent(context),
                    ),
                    child: _headerContent(context),
                  ),
                  if (_hoverLeading)
                    Positioned(
                      left: 0,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        width: 3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (_hoverTrailing)
                    Positioned(
                      right: 0,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        width: 3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              );
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (_) {
                  _dragStartWidth = widget.width;
                },
                onHorizontalDragUpdate: (details) {
                  final base = _dragStartWidth ?? widget.width;
                  final next = _clampDouble(
                    base + details.localPosition.dx,
                    widget.minWidth,
                    widget.maxWidth,
                  );
                  widget.onWidthChanged?.call(
                    widget.fieldKey,
                    next / math.max(widget.uiScale, 0.001),
                  );
                },
                child: SizedBox(
                  width: 8,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: widget.showLeadingBorder
              ? BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
                )
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: math.max(12, 13 * widget.uiScale),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<_ColumnAction>(
              tooltip: '列操作',
              padding: EdgeInsets.zero,
              constraints: _columnMenuConstraints,
              onSelected: widget.onAction,
              itemBuilder: (context) => [
                if (!widget.isShotNo)
                  const PopupMenuItem(
                    value: _ColumnAction.hide,
                    child: SizedBox(width: 140, child: Text('隐藏此列')),
                  ),
                const PopupMenuItem(
                  value: _ColumnAction.moveLeft,
                  child: SizedBox(width: 140, child: Text('左移')),
                ),
                const PopupMenuItem(
                  value: _ColumnAction.moveRight,
                  child: SizedBox(width: 140, child: Text('右移')),
                ),
                if (widget.customColumn != null)
                  const PopupMenuItem(
                    value: _ColumnAction.rename,
                    child: SizedBox(width: 140, child: Text('重命名')),
                  ),
                if (widget.customColumn != null)
                  const PopupMenuItem(
                    value: _ColumnAction.delete,
                    child: SizedBox(width: 140, child: Text('删除列')),
                  ),
              ],
              icon: Icon(
                Icons.more_horiz_rounded,
                size: math.max(16, 17 * widget.uiScale),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddColumnHeaderCell extends StatelessWidget {
  const _AddColumnHeaderCell({
    required this.width,
    required this.showLeadingBorder,
    required this.onPressed,
  });

  final double width;
  final bool showLeadingBorder;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          left: showLeadingBorder
              ? BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
                )
              : BorderSide.none,
        ),
      ),
      child: Tooltip(
        message: '新增列',
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Center(
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.42
                          : 0.28,
                    ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowResizeHandle extends StatefulWidget {
  const _RowResizeHandle({
    required this.initialHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.onHeightChanged,
  });

  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final ValueChanged<double> onHeightChanged;

  @override
  State<_RowResizeHandle> createState() => _RowResizeHandleState();
}

class _RowResizeHandleState extends State<_RowResizeHandle> {
  double? _dragStartHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (_) {
            _dragStartHeight = widget.initialHeight;
          },
          onVerticalDragUpdate: (details) {
            final base = _dragStartHeight ?? widget.initialHeight;
            final next = _clampDouble(
              base + details.localPosition.dy,
              widget.minHeight,
              widget.maxHeight,
            );
            widget.onHeightChanged(next);
          },
          child: const SizedBox(height: 8),
        ),
      ),
    );
  }
}

enum _CellMoveDirection { down, up, nextColumn, previousColumn }

class _CellNavigationIntent {
  const _CellNavigationIntent({
    required this.shotId,
    required this.fieldKey,
    required this.direction,
  });

  final String shotId;
  final String fieldKey;
  final _CellMoveDirection direction;
}

class _EditableCell extends StatefulWidget {
  const _EditableCell({
    super.key,
    required this.width,
    required this.height,
    required this.shot,
    required this.fieldKey,
    required this.orderedFieldKeys,
    required this.orderedShotIds,
    required this.customColumns,
    required this.fixedFieldCustomOptions,
    required this.boardPreset,
    required this.uiScale,
    required this.showLeadingBorder,
    required this.focusNode,
    required this.onFocused,
    required this.onNavigate,
    required this.onUpdateField,
    required this.onImportAsset,
    required this.onRelinkAsset,
    required this.onDeleteFixedFieldOption,
    required this.onDeleteCustomColumnOption,
  });

  final double width;
  final double height;
  final ShotRecord shot;
  final String fieldKey;
  final List<String> orderedFieldKeys;
  final List<String> orderedShotIds;
  final List<CustomColumnDefinition> customColumns;
  final Map<String, List<String>> fixedFieldCustomOptions;
  final BoardPreset boardPreset;
  final double uiScale;
  final bool showLeadingBorder;
  final FocusNode focusNode;
  final VoidCallback onFocused;
  final ValueChanged<_CellNavigationIntent> onNavigate;
  final ShotFieldUpdater onUpdateField;
  final ShotAssetImporter onImportAsset;
  final ShotAssetRelinker onRelinkAsset;
  final FixedFieldOptionDeleteRequested onDeleteFixedFieldOption;
  final CustomColumnOptionDeleteRequested onDeleteCustomColumnOption;

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late final TextEditingController _controller;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _stringValue);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
    if (!widget.focusNode.hasFocus && _controller.text != _stringValue) {
      _controller.text = _stringValue;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      widget.onFocused();
      return;
    }
    _commitTextIfNeeded();
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
      if (custom.type == CustomColumnType.image) {
        return '';
      }
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

  bool get _isImageField {
    if (fixedFieldIsImage(widget.fieldKey)) {
      return true;
    }
    return _customColumn?.type == CustomColumnType.image;
  }

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

  double get _cellHorizontalPadding =>
      _clampDouble(8 * widget.uiScale, 6, 16);

  double get _cellVerticalPadding =>
      _clampDouble(6 * widget.uiScale, 4, 12);

  double get _textFontSize {
    final base = widget.boardPreset.textScaleMode == TextScaleMode.large
        ? 14.0
        : 13.0;
    return _clampDouble(base * widget.uiScale, 11.0, 18.0);
  }

  double get _imagePreviewHeight {
    return _clampDouble(
      widget.height - (10 * widget.uiScale),
      64 * widget.uiScale,
      math.max(64 * widget.uiScale, widget.height - (4 * widget.uiScale)),
    );
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

  bool _isBuiltInOption(String value) {
    final custom = _customColumn;
    if (custom != null) {
      return custom.enumSource?.options.contains(value) ?? false;
    }
    return (fixedFieldBaseOptionsByKey[widget.fieldKey] ?? const <String>[])
        .contains(value);
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
        XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg', 'webp']),
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
        XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg', 'webp']),
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _commitTextIfNeeded();
      widget.onNavigate(
        _CellNavigationIntent(
          shotId: widget.shot.id,
          fieldKey: widget.fieldKey,
          direction: HardwareKeyboard.instance.isShiftPressed
              ? _CellMoveDirection.previousColumn
              : _CellMoveDirection.nextColumn,
        ),
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _commitTextIfNeeded();
      widget.onNavigate(
        _CellNavigationIntent(
          shotId: widget.shot.id,
          fieldKey: widget.fieldKey,
          direction: HardwareKeyboard.instance.isShiftPressed
              ? _CellMoveDirection.up
              : _CellMoveDirection.down,
        ),
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: widget.width,
      height: widget.height,
      padding: EdgeInsets.fromLTRB(
        _clampDouble(5 * widget.uiScale, 4, 10),
        _clampDouble(4 * widget.uiScale, 3, 8),
        _clampDouble(5 * widget.uiScale, 4, 10),
        _clampDouble(5 * widget.uiScale, 4, 10),
      ),
      decoration: BoxDecoration(
        border: Border(
          left: widget.showLeadingBorder
              ? BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.72),
                )
              : BorderSide.none,
        ),
      ),
      child: _buildContent(context),
    );

    if (_isImageField || _isDropdownField) {
      return Focus(
        focusNode: widget.focusNode,
        onKeyEvent: _handleKeyEvent,
        child: content,
      );
    }

    return Focus(
      onKeyEvent: _handleKeyEvent,
      canRequestFocus: false,
      skipTraversal: true,
      child: content,
    );
  }

  Widget _buildTextFieldCell() {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.tab): () {
          _commitTextIfNeeded();
          widget.onNavigate(
            _CellNavigationIntent(
              shotId: widget.shot.id,
              fieldKey: widget.fieldKey,
              direction: HardwareKeyboard.instance.isShiftPressed
                  ? _CellMoveDirection.previousColumn
                  : _CellMoveDirection.nextColumn,
            ),
          );
        },
        const SingleActivator(LogicalKeyboardKey.enter): () {
          _commitTextIfNeeded();
          widget.onNavigate(
            _CellNavigationIntent(
              shotId: widget.shot.id,
              fieldKey: widget.fieldKey,
              direction: HardwareKeyboard.instance.isShiftPressed
                  ? _CellMoveDirection.up
                  : _CellMoveDirection.down,
            ),
          );
        },
        const SingleActivator(LogicalKeyboardKey.numpadEnter): () {
          _commitTextIfNeeded();
          widget.onNavigate(
            _CellNavigationIntent(
              shotId: widget.shot.id,
              fieldKey: widget.fieldKey,
              direction: HardwareKeyboard.instance.isShiftPressed
                  ? _CellMoveDirection.up
                  : _CellMoveDirection.down,
            ),
          );
        },
      },
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        style: TextStyle(fontSize: _textFontSize),
        keyboardType: _isNumericField
            ? TextInputType.number
            : TextInputType.text,
        minLines: _isLongTextField ? 2 : 1,
        maxLines: _isLongTextField ? 3 : 1,
        onTap: widget.onFocused,
        onSubmitted: (_) => _commitTextIfNeeded(),
        decoration: InputDecoration(
          isDense: true,
          hintText: '输入内容',
          contentPadding: EdgeInsets.symmetric(
            horizontal: _cellHorizontalPadding,
            vertical: _cellVerticalPadding,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isImageField) {
      final asset = switch (widget.fieldKey) {
        final key when key == ShotFieldKey.frameImage.storageKey =>
          widget.shot.frameImage,
        final key when key == ShotFieldKey.referenceImage.storageKey =>
          widget.shot.referenceImage,
        _ => widget.shot.customFieldValues[widget.fieldKey] as AssetRef?,
      };
      return _ImageFieldCell(
        asset: asset,
        previewHeight: _imagePreviewHeight,
        fitMode: widget.boardPreset.fitMode,
        uiScale: widget.uiScale,
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
      final currentValue = _options.contains(_stringValue)
          ? _stringValue
          : null;
      return InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _showDropdownSheet(context, currentValue),
        child: InputDecorator(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: _cellHorizontalPadding,
              vertical: _cellVerticalPadding,
            ),
            border: const OutlineInputBorder(),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentValue ?? '请选择',
                  style: TextStyle(fontSize: _textFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down_rounded),
            ],
          ),
        ),
      );
    }

    return _buildTextFieldCell();
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
            decoration: const InputDecoration(labelText: '输入新的选项内容'),
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

  Future<void> _showDropdownSheet(
    BuildContext context,
    String? currentValue,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final option in _options)
                if (option == _customOptionSentinel)
                  ListTile(
                    leading: const Icon(Icons.add_rounded),
                    title: const Text('自定义...'),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final next = await _promptCustomValue(context);
                      if (next == null || next.isEmpty) {
                        return;
                      }
                      await widget.onUpdateField(
                        shotId: widget.shot.id,
                        fieldKey: widget.fieldKey,
                        value: next,
                      );
                    },
                  )
                else
                  ListTile(
                    selected: option == currentValue,
                    title: Text(option, overflow: TextOverflow.ellipsis),
                    trailing: _isBuiltInOption(option)
                        ? null
                        : IconButton(
                            tooltip: '删除此自定义项',
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('删除自定义选项'),
                                    content: Text('确认删除“$option”？已写入镜头的旧值会保留。'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          dialogContext,
                                        ).pop(false),
                                        child: const Text('取消'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(
                                          dialogContext,
                                        ).pop(true),
                                        child: const Text('删除'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmed != true) {
                                return;
                              }
                              if (!sheetContext.mounted) {
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                              final custom = _customColumn;
                              if (custom != null) {
                                await widget.onDeleteCustomColumnOption(
                                  columnId: custom.id,
                                  option: option,
                                );
                              } else {
                                await widget.onDeleteFixedFieldOption(
                                  fieldKey: widget.fieldKey,
                                  option: option,
                                );
                              }
                            },
                          ),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await widget.onUpdateField(
                        shotId: widget.shot.id,
                        fieldKey: widget.fieldKey,
                        value: option,
                      );
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageFieldCell extends StatelessWidget {
  const _ImageFieldCell({
    required this.asset,
    required this.previewHeight,
    required this.fitMode,
    required this.uiScale,
    required this.onImportManaged,
    required this.onImportLinked,
    required this.onRelink,
    required this.onClear,
  });

  final AssetRef? asset;
  final double previewHeight;
  final ImageFitMode fitMode;
  final double uiScale;
  final VoidCallback onImportManaged;
  final VoidCallback onImportLinked;
  final VoidCallback? onRelink;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final uri = asset?.uri;
    final file = (uri != null && uri.isNotEmpty) ? File(uri) : null;
    final canPreview = file != null && file.existsSync();
    final hasAsset = asset != null;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: previewHeight,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    _clampDouble(6 * uiScale, 4, 10),
                  ),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.9),
                  ),
                ),
                child: canPreview
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _clampDouble(6 * uiScale, 4, 10),
                        ),
                        child: Image.file(
                          file,
                          width: double.infinity,
                          fit: fitMode == ImageFitMode.cover
                              ? BoxFit.cover
                              : BoxFit.contain,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 22,
                        ),
                      ),
              ),
              Positioned(
                top: _clampDouble(4 * uiScale, 3, 8),
                right: _clampDouble(4 * uiScale, 3, 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _clampDouble(2 * uiScale, 1, 4),
                      vertical: _clampDouble(1 * uiScale, 1, 3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniIconAction(
                          tooltip: hasAsset ? '替换图片' : '导入图片',
                          icon: Icons.upload_file_outlined,
                          uiScale: uiScale,
                          onPressed: onImportManaged,
                        ),
                        _MiniIconAction(
                          tooltip: '外链图片',
                          icon: Icons.link_outlined,
                          uiScale: uiScale,
                          onPressed: onImportLinked,
                        ),
                        if (hasAsset && onRelink != null)
                          _MiniIconAction(
                            tooltip: '重连图片',
                            icon: Icons.sync_outlined,
                            uiScale: uiScale,
                            onPressed: onRelink,
                          ),
                        if (hasAsset && onClear != null)
                          _MiniIconAction(
                            tooltip: '清除图片',
                            icon: Icons.delete_outline_rounded,
                            uiScale: uiScale,
                            onPressed: onClear,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _clampDouble(4 * uiScale, 3, 8)),
        Text(
          hasAsset ? '已关联图片' : '未关联图片',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontSize: _clampDouble(11 * uiScale, 10, 14)),
        ),
      ],
    );
  }
}

class _MiniIconAction extends StatelessWidget {
  const _MiniIconAction({
    required this.tooltip,
    required this.icon,
    required this.uiScale,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final double uiScale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: _clampDouble(24 * uiScale, 22, 34),
        height: _clampDouble(24 * uiScale, 22, 34),
      ),
      icon: Icon(icon, size: _clampDouble(14 * uiScale, 12, 18)),
    );
  }
}

double _clampDouble(double value, double min, double max) {
  return math.min(math.max(value, min), max);
}

const _defaultRowHeight = 108.0;
const _minimumRowHeight = 84.0;
const _maximumRowHeight = 280.0;
const _customOptionSentinel = '__custom_option__';
