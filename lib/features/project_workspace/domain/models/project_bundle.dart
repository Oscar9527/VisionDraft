class ProjectBundle {
  const ProjectBundle({
    required this.id,
    required this.name,
    required this.rootPath,
    required this.manifestPath,
    required this.databasePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String rootPath;
  final String manifestPath;
  final String databasePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get assetsPath => '$rootPath/assets/originals';
  String get exportsPath => '$rootPath/exports';
}
