import 'dart:io';

import 'package:vision_draft/features/project_workspace/domain/models/export_payload.dart';
import 'package:vision_draft/infrastructure/database/app_index_database.dart';
import 'package:vision_draft/infrastructure/database/drift_project_workspace_repository.dart';
import 'package:vision_draft/infrastructure/filesystem/project_bundle_service.dart';
import 'package:vision_draft/infrastructure/printing/pdf_export_service.dart';
import 'package:vision_draft/core/logging/app_logger.dart';

Future<void> main() async {
  final paths = _resolvePaths();
  final indexDb = File(paths.$1);
  if (!await indexDb.exists()) {
    stderr.writeln('Index database not found: ${indexDb.path}');
    exitCode = 1;
    return;
  }

  final index = AppIndexDatabase(indexDb);
  final rows = await index.select(index.recentProjects).get();
  await index.close();

  if (rows.isEmpty) {
    stderr.writeln('No projects found in recent projects index.');
    exitCode = 1;
    return;
  }

  final projectId = rows.first.id;
  final repo = DriftProjectWorkspaceRepository(
    bundleService: ProjectBundleService(logger: AppLogger()),
    indexDatabaseFactory: () async => AppIndexDatabase(indexDb),
  );
  final exportService = const PdfExportService();

  final bundle = await repo.loadBundle(projectId);
  final shots = await repo.loadShots(projectId);
  final columnPreset = await repo.loadColumnPreset(projectId);
  final boardPreset = await repo.loadBoardPreset(projectId);
  final planBoard = await repo.loadPlanBoard(projectId);
  final callSheet = await repo.loadCallSheet(projectId);

  for (final type in ExportDocumentType.values) {
    final payload = ExportPayload(
      bundle: bundle,
      shots: shots,
      columnPreset: columnPreset,
      effectiveFieldOrderKeys: columnPreset.fieldOrderKeys,
      effectiveColumnWidths: const <String, double>{},
      effectiveRowHeights: const <String, double>{},
      boardPreset: boardPreset,
      planBoard: planBoard,
      callSheet: callSheet,
      documentType: type,
    );
    final bytes = await exportService.generate(payload);
    final file = File(
      '${bundle.exportsPath}${Platform.pathSeparator}${type.name}-smoke.pdf',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    stdout.writeln('${type.name}: ${file.path} (${bytes.length} bytes)');
  }
}

(String, String) _resolvePaths() {
  final appData =
      Platform.environment['APPDATA'] ?? Platform.environment['AppData'];
  if (appData == null || appData.isEmpty) {
    throw StateError('APPDATA is not available in the environment.');
  }
  final root =
      '$appData${Platform.pathSeparator}com.visiondraft${Platform.pathSeparator}vision_draft${Platform.pathSeparator}visiondraft';
  return (
    '$root${Platform.pathSeparator}visiondraft_index.db',
    '$root${Platform.pathSeparator}projects',
  );
}
