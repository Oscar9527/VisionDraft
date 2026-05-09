import '../models/board_preset.dart';
import '../models/call_sheet.dart';
import '../models/column_preset.dart';
import '../models/column_template.dart';
import '../models/custom_column_definition.dart';
import '../models/plan_board.dart';
import '../models/project_bundle.dart';
import '../models/shot_record.dart';

class ProjectWorkspaceSnapshot {
  const ProjectWorkspaceSnapshot({
    required this.bundle,
    required this.shots,
    required this.columnPreset,
    required this.columnTemplates,
    required this.customColumns,
    required this.fixedFieldCustomOptions,
    required this.boardPreset,
    required this.planBoard,
    required this.callSheet,
    this.isLoading = false,
    this.errorMessage,
  });

  final ProjectBundle bundle;
  final List<ShotRecord> shots;
  final ColumnPreset columnPreset;
  final List<ColumnTemplate> columnTemplates;
  final List<CustomColumnDefinition> customColumns;
  final Map<String, List<String>> fixedFieldCustomOptions;
  final BoardPreset boardPreset;
  final PlanBoard planBoard;
  final CallSheet callSheet;
  final bool isLoading;
  final String? errorMessage;

  factory ProjectWorkspaceSnapshot.empty(String projectId) {
    final now = DateTime.now();
    return ProjectWorkspaceSnapshot(
      bundle: ProjectBundle(
        id: projectId,
        name: '未命名项目',
        rootPath: '',
        manifestPath: '',
        databasePath: '',
        createdAt: now,
        updatedAt: now,
      ),
      shots: const [],
      columnPreset: ColumnPreset.initial(),
      columnTemplates: const [],
      customColumns: const [],
      fixedFieldCustomOptions: const {},
      boardPreset: BoardPreset.initial(),
      planBoard: const PlanBoard(unassignedShotIds: [], sections: []),
      callSheet: const CallSheet(
        id: 'default',
        title: '拍摄通告',
        sectionSummaries: [],
      ),
      isLoading: true,
    );
  }

  ProjectWorkspaceSnapshot copyWith({
    ProjectBundle? bundle,
    List<ShotRecord>? shots,
    ColumnPreset? columnPreset,
    List<ColumnTemplate>? columnTemplates,
    List<CustomColumnDefinition>? customColumns,
    Map<String, List<String>>? fixedFieldCustomOptions,
    BoardPreset? boardPreset,
    PlanBoard? planBoard,
    CallSheet? callSheet,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProjectWorkspaceSnapshot(
      bundle: bundle ?? this.bundle,
      shots: shots ?? this.shots,
      columnPreset: columnPreset ?? this.columnPreset,
      columnTemplates: columnTemplates ?? this.columnTemplates,
      customColumns: customColumns ?? this.customColumns,
      fixedFieldCustomOptions:
          fixedFieldCustomOptions ?? this.fixedFieldCustomOptions,
      boardPreset: boardPreset ?? this.boardPreset,
      planBoard: planBoard ?? this.planBoard,
      callSheet: callSheet ?? this.callSheet,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
