import 'board_preset.dart';
import 'call_sheet.dart';
import 'column_preset.dart';
import 'plan_board.dart';
import 'project_bundle.dart';
import 'shot_record.dart';

enum ExportDocumentType { shotSheet, shootingPlan, callSheet }

class ExportBranding {
  const ExportBranding({
    this.brandName = '',
    this.tagline = '',
    this.showDefaultLogo = false,
    this.logoPath,
  });

  final String brandName;
  final String tagline;
  final bool showDefaultLogo;
  final String? logoPath;
}

class ExportPayload {
  const ExportPayload({
    required this.bundle,
    required this.shots,
    required this.columnPreset,
    required this.effectiveFieldOrderKeys,
    this.editorScalePercent = 100,
    this.effectiveColumnWidths = const <String, double>{},
    this.effectiveRowHeights = const <String, double>{},
    this.fieldLabelsByKey = const <String, String>{},
    this.branding = const ExportBranding(),
    required this.boardPreset,
    required this.planBoard,
    required this.callSheet,
    required this.documentType,
  });

  final ProjectBundle bundle;
  final List<ShotRecord> shots;
  final ColumnPreset columnPreset;
  final List<String> effectiveFieldOrderKeys;
  final double editorScalePercent;
  final Map<String, double> effectiveColumnWidths;
  final Map<String, double> effectiveRowHeights;
  final Map<String, String> fieldLabelsByKey;
  final ExportBranding branding;
  final BoardPreset boardPreset;
  final PlanBoard planBoard;
  final CallSheet callSheet;
  final ExportDocumentType documentType;
}
