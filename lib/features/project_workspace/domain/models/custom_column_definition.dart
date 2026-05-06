import 'shot_fields.dart';

enum CustomColumnType { text, number, singleSelect }

enum BuiltInEnumSource {
  shotSize,
  priority,
  shootStatus,
  locationType,
  timeOfDay,
}

extension BuiltInEnumSourceX on BuiltInEnumSource {
  String get storageKey => name;

  String get label => switch (this) {
        BuiltInEnumSource.shotSize => '景别',
        BuiltInEnumSource.priority => '优先级',
        BuiltInEnumSource.shootStatus => '拍摄状态',
        BuiltInEnumSource.locationType => '场景类型',
        BuiltInEnumSource.timeOfDay => '时段',
      };

  List<String> get options => switch (this) {
        BuiltInEnumSource.shotSize => shotSizeOptions,
        BuiltInEnumSource.priority => const ['高', '中', '低'],
        BuiltInEnumSource.shootStatus => const ['待拍', '已拍', '补拍', '作废'],
        BuiltInEnumSource.locationType => const ['内景', '外景'],
        BuiltInEnumSource.timeOfDay => const ['晨', '日', '昏', '夜'],
      };
}

class CustomColumnDefinition {
  const CustomColumnDefinition({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.enumSource,
    this.customOptions = const [],
  });

  final String id;
  final String projectId;
  final String name;
  final CustomColumnType type;
  final BuiltInEnumSource? enumSource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> customOptions;

  String get fieldKey => 'custom:$id';

  List<String> get options => [
        ...(enumSource?.options ?? const <String>[]),
        ...customOptions,
      ];

  CustomColumnDefinition copyWith({
    String? id,
    String? projectId,
    String? name,
    CustomColumnType? type,
    BuiltInEnumSource? enumSource,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? customOptions,
    bool clearEnumSource = false,
  }) {
    return CustomColumnDefinition(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      enumSource: clearEnumSource ? null : enumSource ?? this.enumSource,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customOptions: customOptions ?? this.customOptions,
    );
  }
}
