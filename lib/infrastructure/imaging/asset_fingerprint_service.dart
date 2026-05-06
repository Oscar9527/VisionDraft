import 'dart:io';

import 'package:crypto/crypto.dart';

class AssetFingerprintService {
  const AssetFingerprintService();

  Future<String> fingerprintFile(File file) async {
    final digest = md5.convert(await file.readAsBytes());
    return digest.toString();
  }
}
