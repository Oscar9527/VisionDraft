import '../application/generate_storyboard_from_script_use_case.dart';
import '../domain/ai_generation_request.dart';
import '../domain/ai_generation_result.dart';
import 'ai_api_exception.dart';
import 'ai_provider_registry.dart';
import 'prompt_builder.dart';
import 'storyboard_json_parser.dart';

class RemoteAiStoryboardGenerator implements AiStoryboardGenerator {
  RemoteAiStoryboardGenerator({
    required AiProviderRegistry providerRegistry,
    AiStoryboardPromptBuilder? promptBuilder,
    AiStoryboardJsonParser? parser,
  }) : _providerRegistry = providerRegistry,
       _promptBuilder = promptBuilder ?? AiStoryboardPromptBuilder(),
       _parser = parser ?? const AiStoryboardJsonParser();

  final AiProviderRegistry _providerRegistry;
  final AiStoryboardPromptBuilder _promptBuilder;
  final AiStoryboardJsonParser _parser;

  @override
  Future<AiGenerationResult> generate(AiGenerationRequest request) async {
    final config = request.providerConfig;
    if (config.baseUrl.trim().isEmpty) {
      throw const AiApiException('请先填写服务商 Base URL。');
    }
    if (config.model.trim().isEmpty) {
      throw const AiApiException('请先填写模型名称。');
    }
    if (config.apiKey.trim().isEmpty) {
      throw const AiApiException('请先填写 API Key。');
    }

    final adapter = _providerRegistry.adapterFor(config.providerType);
    final prompt = _promptBuilder.build(request);
    final rawText = await adapter.generateText(config: config, prompt: prompt);
    return _parser.parse(rawText);
  }
}
