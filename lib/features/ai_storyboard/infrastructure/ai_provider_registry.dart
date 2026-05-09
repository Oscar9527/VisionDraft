import '../domain/ai_provider_type.dart';
import 'adapters/ai_provider_adapter.dart';
import 'adapters/anthropic_messages_adapter.dart';
import 'adapters/gemini_generate_content_adapter.dart';
import 'adapters/openai_compatible_chat_adapter.dart';
import 'adapters/openai_responses_adapter.dart';
import 'ai_http_client.dart';

class AiProviderRegistry {
  AiProviderRegistry({AiHttpClient? httpClient})
    : _httpClient = httpClient ?? AiHttpClient();

  final AiHttpClient _httpClient;

  late final Map<AiProviderType, AiProviderAdapter> _adapters = {
    AiProviderType.chatgpt: OpenAiResponsesAdapter(httpClient: _httpClient),
    AiProviderType.claude: AnthropicMessagesAdapter(httpClient: _httpClient),
    AiProviderType.gemini: GeminiGenerateContentAdapter(
      httpClient: _httpClient,
    ),
    AiProviderType.deepseek: OpenAiCompatibleChatAdapter(
      httpClient: _httpClient,
    ),
    AiProviderType.custom: OpenAiCompatibleChatAdapter(httpClient: _httpClient),
  };

  AiProviderAdapter adapterFor(AiProviderType type) {
    final adapter = _adapters[type];
    if (adapter == null) {
      throw StateError('No AI provider adapter registered for $type');
    }
    return adapter;
  }
}
