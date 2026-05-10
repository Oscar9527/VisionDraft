enum StoryboardSceneNumberMode { auto, manual }

class StoryboardScene {
  const StoryboardScene({
    required this.id,
    required this.projectId,
    required this.sortIndex,
    required this.numberMode,
    required this.manualNumber,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final int sortIndex;
  final StoryboardSceneNumberMode numberMode;
  final String manualNumber;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasName => name.trim().isNotEmpty;

  String displayNumber(int autoNumber) {
    if (numberMode == StoryboardSceneNumberMode.manual &&
        manualNumber.trim().isNotEmpty) {
      return manualNumber.trim();
    }
    return '$autoNumber';
  }

  StoryboardScene copyWith({
    String? id,
    String? projectId,
    int? sortIndex,
    StoryboardSceneNumberMode? numberMode,
    String? manualNumber,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryboardScene(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sortIndex: sortIndex ?? this.sortIndex,
      numberMode: numberMode ?? this.numberMode,
      manualNumber: manualNumber ?? this.manualNumber,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
