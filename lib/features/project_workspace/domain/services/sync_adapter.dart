abstract interface class SyncAdapter {
  Future<void> pushProject(String projectId);

  Future<void> pullProject(String projectId);
}
