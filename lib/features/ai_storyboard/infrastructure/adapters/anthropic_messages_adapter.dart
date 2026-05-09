import '../../domain/ai_provider_config.dart';
import '../ai_api_exception.dart';
import '../ai_http_client.dart';
import 'ai_provider_adapter.dart';

class AnthropicMessagesAdapter implements AiProviderAdapter {
  AnthropicMessagesAdapter({required AiHttpClient httpClient})
    : _httpClient = httpClient;

  final AiHttpClient _httpClient;

  @override
  Future<String> generateText({
    required AiProviderConfig config,
    required String prompt,
  }) async {
    final response = await _httpClient.postJson(
      uri: _resolveUri(config.baseUrl, '/messages'),
      headers: {
        'x-api-key': config.apiKey.trim(),
        'anthropic-version': '2023-06-01',
      },
      body: {
        'model': config.model.trim(),
        'max_tokens': 4096,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
            ],
          },
        ],
      },
    );

    if (response is! Map) {
      throw const AiApiException('Claude 返回内容格式异常。');
    }

    final content = response['content'];
    if (content is List) {
      final lines = <String>[];
      for (final block in content) {
        if (block is! Map) {
          continue;
        }
        if (block['type']?.toString() != 'text') {
          continue;
        }
        final text = block['text']?.toString().trim();
        if (text != null && text.isNotEmpty) {
          lines.add(text);
        }
      }
      if (lines.isNotEmpty) {
        return lines.join('\n');
      }
    }

    throw const AiApiException('Claude 返回成功，但没有可解析的文本输出。');
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
