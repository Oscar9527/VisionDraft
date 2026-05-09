import '../history/history_entry.dart';
import '../history/history_manager.dart';
import 'app_command.dart';

typedef CommandHandler<T extends AppCommand> =
    Future<CommandResult> Function(T command);

class CommandResult {
  const CommandResult({this.historyEntry, this.message, this.payload});

  final HistoryEntry? historyEntry;
  final String? message;
  final Object? payload;
}

class CommandBus {
  CommandBus({required this.historyManager});

  final HistoryManager historyManager;
  final Map<Type, Future<CommandResult> Function(AppCommand)> _handlers = {};

  void register<T extends AppCommand>(CommandHandler<T> handler) {
    _handlers[T] = (command) => handler(command as T);
  }

  Future<CommandResult> dispatch<T extends AppCommand>(T command) async {
    final handler = _handlers[T];
    if (handler == null) {
      throw StateError('No handler registered for ${T.toString()}');
    }
    final result = await handler(command);
    if (command.recordInHistory && result.historyEntry != null) {
      historyManager.record(result.historyEntry!);
    }
    return result;
  }
}
