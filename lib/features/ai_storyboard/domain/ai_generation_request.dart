import 'ai_generation_density.dart';
import 'ai_provider_config.dart';
import 'ai_script_mode.dart';

class AiGenerationRequest {
  const AiGenerationRequest({
    required this.rawScript,
    required this.scriptMode,
    required this.generationDensity,
    required this.providerConfig,
  });

  final String rawScript;
  final AiScriptMode scriptMode;
  final AiGenerationDensity generationDensity;
  final AiProviderConfig providerConfig;
}
