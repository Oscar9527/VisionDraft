import '../../domain/ai_provider_config.dart';

abstract interface class AiProviderAdapter {
  Future<String> generateText({
    required AiProviderConfig config,
    required String prompt,
  });
}
