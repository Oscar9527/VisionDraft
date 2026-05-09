import '../../domain/ai_provider_config.dart';
import '../ai_api_exception.dart';
import '../ai_http_client.dart';
import '../storyboard_response_schema.dart';
import 'ai_provider_adapter.dart';

class OpenAiResponsesAdapter implements AiProviderAdapter {
  OpenAiResponsesAdapter({required AiHttpClient httpClient})
    : _httpClient = httpClient;

  final AiHttpClient _httpClient;

  @override
  Future<String> generateText({
    required AiProviderConfig config,
    required String prompt,
  }) async {
    final response = await _httpClient.postJson(
      uri: _resolveUri(config.baseUrl, '/responses'),
      headers: {'Authorization': 'Bearer ${config.apiKey.trim()}'},
      body: {
        'model': config.model.trim(),
        'input': prompt,
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'visiondraft_storyboard',
            'schema': storyboardResponseSchema,
            'strict': true,
          },
        },
      },
    );

    if (response is! Map) {
      throw const AiApiException('OpenAI 返回内容格式异常。');
    }

    final mapped = Map<String, dynamic>.from(response);
    final outputText = mapped['output_text']?.toString().trim();
    if (outputText != null && outputText.isNotEmpty) {
      return outputText;
    }

    final output = mapped['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output) {
        if (item is! Map) {
          continue;
        }
        final content = item['content'];
        if (content is! List) {
          continue;
        }
        for (final block in content) {
          if (block is! Map) {
            continue;
          }
          final text = block['text']?.toString();
          if (text != null && text.trim().isNotEmpty) {
            buffer.writeln(text.trim());
          }
        }
      }
      final combined = buffer.toString().trim();
      if (combined.isNotEmpty) {
        return combined;
      }
    }

    throw const AiApiException('OpenAI 返回成功，但没有可解析的文本输出。');
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
