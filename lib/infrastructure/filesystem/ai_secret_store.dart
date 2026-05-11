import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/ai_storyboard/domain/ai_provider_type.dart';
import 'app_preferences_service.dart';

abstract interface class AiSecretStore {
  Future<String?> readApiKey(AiProviderType providerType);

  Future<void> writeApiKey(AiProviderType providerType, String apiKey);
}

class PlatformAiSecretStore implements AiSecretStore {
  PlatformAiSecretStore({required AppPreferencesService preferencesService})
      : _preferencesService = preferencesService,
        _secureStorage = _shouldUseSecureStorage
            ? const FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true),
              )
            : null;

  static const _fallbackSettingsKey = 'aiProviderSecrets';

  static bool get _shouldUseSecureStorage {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  final AppPreferencesService _preferencesService;
  final FlutterSecureStorage? _secureStorage;

  String _keyFor(AiProviderType providerType) =>
      'visiondraft.ai.apiKey.${providerType.name}';

  @override
  Future<String?> readApiKey(AiProviderType providerType) async {
    final key = _keyFor(providerType);
    if (_secureStorage != null) {
      return await _secureStorage.read(key: key);
    }

    final payload =
        await _preferencesService.loadJsonObject(_fallbackSettingsKey) ??
        <String, dynamic>{};
    final value = payload[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  @override
  Future<void> writeApiKey(AiProviderType providerType, String apiKey) async {
    final key = _keyFor(providerType);
    final trimmed = apiKey.trim();
    if (_secureStorage != null) {
      if (trimmed.isEmpty) {
        await _secureStorage.delete(key: key);
      } else {
        await _secureStorage.write(key: key, value: trimmed);
      }
      return;
    }

    final payload =
        await _preferencesService.loadJsonObject(_fallbackSettingsKey) ??
        <String, dynamic>{};
    if (trimmed.isEmpty) {
      payload.remove(key);
    } else {
      payload[key] = trimmed;
    }
    await _preferencesService.saveJsonObject(_fallbackSettingsKey, payload);
  }
}
