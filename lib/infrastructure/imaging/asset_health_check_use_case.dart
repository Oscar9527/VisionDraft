import 'dart:io';

import '../../features/project_workspace/domain/models/asset_ref.dart';
import '../filesystem/project_bundle_service.dart';

class AssetHealthCheckUseCase {
  const AssetHealthCheckUseCase({
    required this.bundleService,
  });

  final ProjectBundleService bundleService;

  Future<AssetRef> validate(AssetRef asset) async {
    final exists = await File(asset.uri).exists();
    return asset.copyWith(
      missingState: exists ? MissingState.available : MissingState.relinkRequired,
    );
  }
}
