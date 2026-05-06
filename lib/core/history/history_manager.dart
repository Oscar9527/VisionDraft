import 'package:flutter/foundation.dart';

import 'history_entry.dart';

class HistoryManager extends ChangeNotifier {
  HistoryManager({this.capacity = 100});

  final int capacity;
  final List<HistoryEntry> _undoStack = [];
  final List<HistoryEntry> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void record(HistoryEntry entry) {
    if (_undoStack.isNotEmpty && _undoStack.last.canMergeWith(entry)) {
      _undoStack[_undoStack.length - 1] = _undoStack.last.mergeWith(entry);
    } else {
      _undoStack.add(entry);
      if (_undoStack.length > capacity) {
        _undoStack.removeAt(0);
      }
    }
    _redoStack.clear();
    notifyListeners();
  }

  Future<bool> undo() async {
    if (!canUndo) {
      return false;
    }
    final entry = _undoStack.removeLast();
    await entry.undo();
    _redoStack.add(entry);
    notifyListeners();
    return true;
  }

  Future<bool> redo() async {
    if (!canRedo) {
      return false;
    }
    final entry = _redoStack.removeLast();
    await entry.redo();
    _undoStack.add(entry);
    notifyListeners();
    return true;
  }
}
