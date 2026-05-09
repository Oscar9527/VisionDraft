import '../../domain/ai_provider_config.dart';
import '../ai_api_exception.dart';
import '../ai_http_client.dart';
import 'ai_provider_adapter.dart';

class OpenAiCompatibleChatAdapter implements AiProviderAdapter {
  OpenAiCompatibleChatAdapter({required AiHttpClient httpClient})
    : _httpClient = httpClient;

  final AiHttpClient _httpClient;

  @override
  Future<String> generateText({
    required AiProviderConfig config,
    required String prompt,
  }) async {
    final response = await _httpClient.postJson(
      uri: _resolveUri(config.baseUrl, '/chat/completions'),
      headers: {'Authorization': 'Bearer ${config.apiKey.trim()}'},
      body: {
        'model': config.model.trim(),
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.2,
        'response_format': {'type': 'json_object'},
      },
    );

    if (response is! Map) {
      throw const AiApiException('兼容 OpenAI 的服务返回格式异常。');
    }

    final choices = response['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final message = first['message'];
        if (message is Map) {
          final content = message['content']?.toString().trim();
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
      }
    }

    throw const AiApiException('兼容 OpenAI 的服务返回成功，但没有可解析的文本输出。');
  }

  Uri _resolveUri(String baseUrl, String endpointPath) {
    final base = Uri.parse(baseUrl.trim());
    final currentPath = _normalizePath(base.path);
    final appendPath = _normalizePath(endpointPath);
    final mergedPath = currentPath.endsWith(appendPath)
        ? currentPath
        : '$currentPath$appendPath';
    return base.replace(path: mergedPath);
  }

  String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '/') {
      return '';
    }
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}
