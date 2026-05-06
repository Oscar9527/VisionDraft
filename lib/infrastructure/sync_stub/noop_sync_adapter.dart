import '../../features/project_workspace/domain/services/sync_adapter.dart';

class NoopSyncAdapter implements SyncAdapter {
  const NoopSyncAdapter();

  @override
  Future<void> pullProject(String projectId) async {}

  @override
  Future<void> pushProject(String projectId) async {}
}
