import 'dart:convert';

class ProjectBundleManifest {
  const ProjectBundleManifest({
    required this.id,
    required this.name,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.exportCompatibilityVersion,
  });

  final String id;
  final String name;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String exportCompatibilityVersion;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'exportCompatibilityVersion': exportCompatibilityVersion,
    };
  }

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory ProjectBundleManifest.fromJson(Map<String, Object?> json) {
    return ProjectBundleManifest(
      id: json['id']! as String,
      name: json['name']! as String,
      schemaVersion: json['schemaVersion']! as int,
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      exportCompatibilityVersion: json['exportCompatibilityVersion']! as String,
    );
  }
}
