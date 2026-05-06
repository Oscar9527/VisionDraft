class ColumnTemplate {
  const ColumnTemplate({
    required this.id,
    required this.projectId,
    required this.name,
    required this.visibleFieldKeys,
    required this.fieldOrderKeys,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final List<String> visibleFieldKeys;
  final List<String> fieldOrderKeys;
  final DateTime updatedAt;

  ColumnTemplate copyWith({
    String? id,
    String? projectId,
    String? name,
    List<String>? visibleFieldKeys,
    List<String>? fieldOrderKeys,
    DateTime? updatedAt,
  }) {
    return ColumnTemplate(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      visibleFieldKeys: visibleFieldKeys ?? this.visibleFieldKeys,
      fieldOrderKeys: fieldOrderKeys ?? this.fieldOrderKeys,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
