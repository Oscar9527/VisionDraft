import '../../../infrastructure/filesystem/app_preferences_service.dart';
import '../../../infrastructure/filesystem/ai_secret_store.dart';
import '../domain/ai_provider_config.dart';
import '../domain/ai_provider_preset.dart';
import '../domain/ai_provider_type.dart';

class AiProviderSettingsRepository {
  AiProviderSettingsRepository({
    required AppPreferencesService preferencesService,
    required AiSecretStore secretStore,
  })  : _preferencesService = preferencesService,
        _secretStore = secretStore;

  final AppPreferencesService _preferencesService;
  final AiSecretStore _secretStore;

  static const _settingsKey = 'aiProviderConfigs';

  Future<Map<AiProviderType, AiProviderConfig>> loadConfigs() async {
    final stored = await _preferencesService.loadJsonObject(_settingsKey);
    final defaults = {
      for (final preset in aiProviderPresets)
        preset.type: AiProviderConfig.fromPreset(preset),
    };
    if (stored == null) {
      return defaults;
    }

    final next = <AiProviderType, AiProviderConfig>{...defaults};
    for (final entry in stored.entries) {
      final type = AiProviderType.values.firstWhere(
        (item) => item.name == entry.key,
        orElse: () => AiProviderType.custom,
      );
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        next[type] = AiProviderConfig.fromJson(value);
      } else if (value is Map) {
        next[type] = AiProviderConfig.fromJson(
          Map<String, dynamic>.from(value),
        );
      }
      final apiKey = await _secretStore.readApiKey(type) ?? '';
      next[type] = next[type]!.copyWith(apiKey: apiKey);
    }
    for (final type in next.keys) {
      final apiKey = await _secretStore.readApiKey(type) ?? '';
      next[type] = next[type]!.copyWith(apiKey: apiKey);
    }
    return next;
  }

  Future<void> saveConfigs(
    Map<AiProviderType, AiProviderConfig> configs,
  ) async {
    final payload = <String, dynamic>{
      for (final entry in configs.entries)
        entry.key.name: entry.value.copyWith(apiKey: '').toJson(),
    };
    await _preferencesService.saveJsonObject(_settingsKey, payload);
    for (final entry in configs.entries) {
      await _secretStore.writeApiKey(entry.key, entry.value.apiKey);
    }
  }
}
