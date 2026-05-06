import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vision_draft/core/logging/app_logger.dart';
import 'package:vision_draft/features/project_workspace/domain/models/asset_ref.dart';
import 'package:vision_draft/infrastructure/filesystem/project_bundle_service.dart';
import 'package:vision_draft/infrastructure/imaging/asset_health_check_use_case.dart';

void main() {
  test('asset health check flags missing file for relink', () async {
    final temp = await Directory.systemTemp.createTemp('visiondraft-test');
    final service = ProjectBundleService(logger: AppLogger());
    final useCase = AssetHealthCheckUseCase(bundleService: service);

    final asset = AssetRef(
      mode: AssetMode.linked,
      uri: File('${temp.path}/missing.png').path,
      fingerprint: 'abc',
      missingState: MissingState.available,
    );

    final result = await useCase.validate(asset);
    expect(result.missingState, MissingState.relinkRequired);
  });
}
