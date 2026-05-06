import 'shot_fields.dart';

enum ColumnPresetKind { active, template }

class ColumnPreset {
  const ColumnPreset({
    required this.id,
    required this.name,
    required this.kind,
    required this.visibleFieldKeys,
    required this.fieldOrderKeys,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final ColumnPresetKind kind;
  final List<String> visibleFieldKeys;
  final List<String> fieldOrderKeys;
  final DateTime updatedAt;

  factory ColumnPreset.initial() {
    return ColumnPreset(
      id: 'active',
      name: '当前布局',
      kind: ColumnPresetKind.active,
      visibleFieldKeys: defaultVisibleStoryboardFieldKeys,
      fieldOrderKeys: fixedShotFields.map((field) => field.storageKey).toList(),
      updatedAt: DateTime.now(),
    );
  }

  bool isVisible(String fieldKey) => visibleFieldKeys.contains(fieldKey);

  ColumnPreset copyWith({
    String? id,
    String? name,
    ColumnPresetKind? kind,
    List<String>? visibleFieldKeys,
    List<String>? fieldOrderKeys,
    DateTime? updatedAt,
  }) {
    return ColumnPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      visibleFieldKeys: visibleFieldKeys ?? this.visibleFieldKeys,
      fieldOrderKeys: fieldOrderKeys ?? this.fieldOrderKeys,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
