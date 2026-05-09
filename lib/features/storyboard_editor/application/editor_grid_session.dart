import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusedGridCell {
  const FocusedGridCell({
    required this.shotId,
    required this.fieldKey,
  });

  final String shotId;
  final String fieldKey;

  String get storageKey => '$shotId::$fieldKey';

  @override
  bool operator ==(Object other) {
    return other is FocusedGridCell &&
        other.shotId == shotId &&
        other.fieldKey == fieldKey;
  }

  @override
  int get hashCode => Object.hash(shotId, fieldKey);
}

class EditorGridSessionState {
  const EditorGridSessionState({
    this.zoomPercent = 92,
    this.printPreviewEnabled = false,
    this.effectiveFieldOrderKeys = const <String>[],
    this.columnWidthsByFieldKey = const <String, double>{},
    this.rowHeightsByShotId = const <String, double>{},
    this.focusedCell,
  });

  final double zoomPercent;
  final bool printPreviewEnabled;
  final List<String> effectiveFieldOrderKeys;
  final Map<String, double> columnWidthsByFieldKey;
  final Map<String, double> rowHeightsByShotId;
  final FocusedGridCell? focusedCell;

  EditorGridSessionState copyWith({
    double? zoomPercent,
    bool? printPreviewEnabled,
    List<String>? effectiveFieldOrderKeys,
    Map<String, double>? columnWidthsByFieldKey,
    Map<String, double>? rowHeightsByShotId,
    FocusedGridCell? focusedCell,
    bool clearFocusedCell = false,
  }) {
    return EditorGridSessionState(
      zoomPercent: zoomPercent ?? this.zoomPercent,
      printPreviewEnabled: printPreviewEnabled ?? this.printPreviewEnabled,
      effectiveFieldOrderKeys:
          effectiveFieldOrderKeys ?? this.effectiveFieldOrderKeys,
      columnWidthsByFieldKey:
          columnWidthsByFieldKey ?? this.columnWidthsByFieldKey,
      rowHeightsByShotId: rowHeightsByShotId ?? this.rowHeightsByShotId,
      focusedCell: clearFocusedCell ? null : (focusedCell ?? this.focusedCell),
    );
  }
}

class EditorGridSessionController
    extends FamilyNotifier<EditorGridSessionState, String> {
  @override
  EditorGridSessionState build(String projectId) {
    return const EditorGridSessionState();
  }

  void setZoomPercent(double value) {
    state = state.copyWith(zoomPercent: value.clamp(70.0, 150.0));
  }

  void setPrintPreviewEnabled(bool enabled) {
    state = state.copyWith(printPreviewEnabled: enabled);
  }

  void setFieldOrderKeys(List<String> fieldOrderKeys) {
    state = state.copyWith(
      effectiveFieldOrderKeys: _normalizeFieldOrder(fieldOrderKeys),
    );
  }

  void clearFieldOrderOverride() {
    state = state.copyWith(effectiveFieldOrderKeys: const <String>[]);
  }

  void setColumnWidth(String fieldKey, double width) {
    state = state.copyWith(
      columnWidthsByFieldKey: {
        ...state.columnWidthsByFieldKey,
        fieldKey: width,
      },
    );
  }

  void setRowHeight(String shotId, double height) {
    state = state.copyWith(
      rowHeightsByShotId: {
        ...state.rowHeightsByShotId,
        shotId: height,
      },
    );
  }

  void setFocusedCell(FocusedGridCell? cell) {
    if (cell == null) {
      state = state.copyWith(clearFocusedCell: true);
      return;
    }
    state = state.copyWith(focusedCell: cell);
  }

  void reorderField({
    required String draggedFieldKey,
    required String targetFieldKey,
    required bool placeAfter,
    required List<String> fallbackOrder,
  }) {
    final order = _normalizeFieldOrder(
      state.effectiveFieldOrderKeys.isEmpty
          ? fallbackOrder
          : state.effectiveFieldOrderKeys,
    );
    final fromIndex = order.indexOf(draggedFieldKey);
    final targetIndex = order.indexOf(targetFieldKey);
    if (fromIndex == -1 || targetIndex == -1 || fromIndex == targetIndex) {
      return;
    }

    final item = order.removeAt(fromIndex);
    var insertIndex = order.indexOf(targetFieldKey);
    if (placeAfter) {
      insertIndex += 1;
    }
    if (fromIndex < targetIndex && !placeAfter) {
      insertIndex -= 1;
    }
    insertIndex = insertIndex.clamp(0, order.length);
    order.insert(insertIndex, item);
    state = state.copyWith(effectiveFieldOrderKeys: order);
  }

  void moveFieldByOffset({
    required String fieldKey,
    required int offset,
    required List<String> fallbackOrder,
  }) {
    final order = _normalizeFieldOrder(
      state.effectiveFieldOrderKeys.isEmpty
          ? fallbackOrder
          : state.effectiveFieldOrderKeys,
    );
    final index = order.indexOf(fieldKey);
    if (index == -1) {
      return;
    }
    final target = (index + offset).clamp(0, order.length - 1);
    if (target == index) {
      return;
    }
    final item = order.removeAt(index);
    order.insert(target, item);
    state = state.copyWith(effectiveFieldOrderKeys: order);
  }

  List<String> _normalizeFieldOrder(List<String> fieldOrderKeys) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final fieldKey in fieldOrderKeys) {
      if (seen.add(fieldKey)) {
        ordered.add(fieldKey);
      }
    }
    return ordered;
  }
}
