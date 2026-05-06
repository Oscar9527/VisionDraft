typedef AsyncHistoryCallback = Future<void> Function();
typedef HistoryEntryMerger = HistoryEntry Function(
  HistoryEntry previous,
  HistoryEntry next,
);

class HistoryEntry {
  const HistoryEntry({
    required this.label,
    required this.undo,
    required this.redo,
    required this.createdAt,
    this.mergeKey,
    this.mergeWindow = const Duration(seconds: 2),
    this.merger,
  });

  final String label;
  final AsyncHistoryCallback undo;
  final AsyncHistoryCallback redo;
  final DateTime createdAt;
  final String? mergeKey;
  final Duration mergeWindow;
  final HistoryEntryMerger? merger;

  bool canMergeWith(HistoryEntry next) {
    if (mergeKey == null || next.mergeKey == null) {
      return false;
    }
    return mergeKey == next.mergeKey &&
        next.createdAt.difference(createdAt) <= mergeWindow;
  }

  HistoryEntry mergeWith(HistoryEntry next) {
    final merger = this.merger ?? next.merger;
    if (merger != null) {
      return merger(this, next);
    }
    return next;
  }
}
