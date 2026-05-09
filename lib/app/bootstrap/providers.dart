import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_mode_controller.dart';
import '../../core/command/command_bus.dart';
import '../../core/history/history_manager.dart';
import '../../core/logging/app_logger.dart';
import '../../features/project_library/application/project_library_controller.dart';
import '../../features/project_library/domain/project_library_repository.dart';
import '../../features/project_workspace/application/project_workspace_command_service.dart';
import '../../features/project_workspace/application/project_workspace_controller.dart';
import '../../features/project_workspace/domain/queries/project_workspace_snapshot.dart';
import '../../features/project_workspace/domain/repositories/project_workspace_repository.dart';
import '../../features/project_workspace/domain/services/sync_adapter.dart';
import '../../features/storyboard_editor/application/editor_grid_session.dart';
import '../../infrastructure/database/app_index_database.dart';
import '../../infrastructure/database/drift_project_library_repository.dart';
import '../../infrastructure/database/drift_project_workspace_repository.dart';
import '../../infrastructure/filesystem/app_preferences_service.dart';
import '../../infrastructure/filesystem/app_storage_service.dart';
import '../../infrastructure/filesystem/project_bundle_service.dart';
import '../../infrastructure/imaging/asset_fingerprint_service.dart';
import '../../infrastructure/imaging/asset_health_check_use_case.dart';
import '../../infrastructure/printing/pdf_export_service.dart';
import '../../infrastructure/printing/print_service.dart';
import '../../infrastructure/sync_stub/noop_sync_adapter.dart';
import '../router/app_router.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger();
});

final appStorageServiceProvider = Provider<AppStorageService>((ref) {
  return const AppStorageService();
});

final appPreferencesServiceProvider = Provider<AppPreferencesService>((ref) {
  return AppPreferencesService(
    storageService: ref.watch(appStorageServiceProvider),
  );
});

final appStoragePathsProvider = FutureProvider<AppStoragePaths>((ref) async {
  return ref.watch(appStorageServiceProvider).resolve();
});

final appIndexDatabaseFactoryProvider =
    Provider<Future<AppIndexDatabase> Function()>((ref) {
      return () async {
        final paths = await ref.watch(appStoragePathsProvider.future);
        return AppIndexDatabase(paths.indexDatabaseFile);
      };
    });

final projectBundleServiceProvider = Provider<ProjectBundleService>((ref) {
  return ProjectBundleService(logger: ref.watch(appLoggerProvider));
});

final projectWorkspaceRepositoryProvider = Provider<ProjectWorkspaceRepository>(
  (ref) {
    return DriftProjectWorkspaceRepository(
      bundleService: ref.watch(projectBundleServiceProvider),
      indexDatabaseFactory: ref.watch(appIndexDatabaseFactoryProvider),
    );
  },
);

final projectLibraryRepositoryProvider = Provider<ProjectLibraryRepository>((
  ref,
) {
  return DriftProjectLibraryRepository(
    storageService: ref.watch(appStorageServiceProvider),
    bundleService: ref.watch(projectBundleServiceProvider),
    workspaceRepository:
        ref.watch(projectWorkspaceRepositoryProvider)
            as DriftProjectWorkspaceRepository,
    indexDatabaseFactory: ref.watch(appIndexDatabaseFactoryProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final historyManagerProvider = ChangeNotifierProvider<HistoryManager>((ref) {
  return HistoryManager();
});

final commandBusProvider = Provider<CommandBus>((ref) {
  return CommandBus(historyManager: ref.watch(historyManagerProvider));
});

final workspaceCommandServiceProvider =
    Provider<ProjectWorkspaceCommandService>((ref) {
      return ProjectWorkspaceCommandService(
        commandBus: ref.watch(commandBusProvider),
        historyManager: ref.watch(historyManagerProvider),
        workspaceRepository: ref.watch(projectWorkspaceRepositoryProvider),
      );
    });

final assetFingerprintServiceProvider = Provider<AssetFingerprintService>((
  ref,
) {
  return const AssetFingerprintService();
});

final assetHealthCheckUseCaseProvider = Provider<AssetHealthCheckUseCase>((
  ref,
) {
  return AssetHealthCheckUseCase(
    bundleService: ref.watch(projectBundleServiceProvider),
  );
});

final syncAdapterProvider = Provider<SyncAdapter>((ref) {
  return const NoopSyncAdapter();
});

final pdfExportServiceProvider = Provider<PdfExportService>((ref) {
  return const PdfExportService();
});

final printServiceProvider = Provider<PrintService>((ref) {
  return const PrintService();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return buildAppRouter(ref);
});

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
      return ThemeModeController(ref.watch(appPreferencesServiceProvider));
    });

final projectLibraryProvider =
    NotifierProvider<ProjectLibraryController, ProjectLibraryState>(
      ProjectLibraryController.new,
    );

final workspaceControllerProvider =
    NotifierProvider.family<
      ProjectWorkspaceController,
      ProjectWorkspaceSnapshot,
      String
    >(ProjectWorkspaceController.new);

final editorGridSessionProvider =
    NotifierProvider.family<
      EditorGridSessionController,
      EditorGridSessionState,
      String
    >(EditorGridSessionController.new);
