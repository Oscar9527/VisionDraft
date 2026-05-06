import 'package:flutter_test/flutter_test.dart';
import 'package:vision_draft/core/history/history_entry.dart';
import 'package:vision_draft/core/history/history_manager.dart';

void main() {
  test('history manager merges entries with same merge key in window', () async {
    final manager = HistoryManager();
    var undoCount = 0;
    var redoCount = 0;

    manager.record(
      HistoryEntry(
        label: 'edit1',
        undo: () async => undoCount++,
        redo: () async => redoCount++,
        createdAt: DateTime(2026, 1, 1, 12, 0, 0),
        mergeKey: 'shot-1-content',
      ),
    );
    manager.record(
      HistoryEntry(
        label: 'edit2',
        undo: () async => undoCount++,
        redo: () async => redoCount++,
        createdAt: DateTime(2026, 1, 1, 12, 0, 1),
        mergeKey: 'shot-1-content',
      ),
    );

    expect(manager.canUndo, isTrue);
    await manager.undo();
    expect(undoCount, 1);

    await manager.redo();
    expect(redoCount, 1);
  });

  test('record clears redo stack after undo', () async {
    final manager = HistoryManager();
    var undoCount = 0;
    var redoCount = 0;

    manager.record(
      HistoryEntry(
        label: 'first',
        undo: () async => undoCount++,
        redo: () async => redoCount++,
        createdAt: DateTime(2026, 1, 1, 12, 0, 0),
      ),
    );

    await manager.undo();
    expect(manager.canRedo, isTrue);

    manager.record(
      HistoryEntry(
        label: 'second',
        undo: () async => undoCount++,
        redo: () async => redoCount++,
        createdAt: DateTime(2026, 1, 1, 12, 0, 2),
      ),
    );

    expect(manager.canRedo, isFalse);
  });

  test('history manager notifies listeners on state changes', () async {
    final manager = HistoryManager();
    var notifications = 0;
    manager.addListener(() => notifications++);

    manager.record(
      HistoryEntry(
        label: 'edit',
        undo: () async {},
        redo: () async {},
        createdAt: DateTime(2026, 1, 1, 12, 0, 0),
      ),
    );
    await manager.undo();
    await manager.redo();

    expect(notifications, 3);
  });
}
