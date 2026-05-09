import 'ai_provider_preset.dart';
import 'ai_provider_type.dart';

class AiProviderConfig {
  const AiProviderConfig({
    required this.providerType,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  final AiProviderType providerType;
  final String baseUrl;
  final String apiKey;
  final String model;

  bool get hasMinimumSettings =>
      baseUrl.trim().isNotEmpty && model.trim().isNotEmpty;

  AiProviderConfig copyWith({
    AiProviderType? providerType,
    String? baseUrl,
    String? apiKey,
    String? model,
  }) {
    return AiProviderConfig(
      providerType: providerType ?? this.providerType,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerType': providerType.name,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'model': model,
    };
  }

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) {
    final typeName = json['providerType']?.toString();
    final providerType = AiProviderType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => AiProviderType.custom,
    );
    final preset = presetForProvider(providerType);
    return AiProviderConfig(
      providerType: providerType,
      baseUrl: json['baseUrl']?.toString() ?? preset.defaultBaseUrl,
      apiKey: json['apiKey']?.toString() ?? '',
      model: json['model']?.toString() ?? preset.defaultModel,
    );
  }

  factory AiProviderConfig.fromPreset(AiProviderPreset preset) {
    return AiProviderConfig(
      providerType: preset.type,
      baseUrl: preset.defaultBaseUrl,
      apiKey: '',
      model: preset.defaultModel,
    );
  }
}
