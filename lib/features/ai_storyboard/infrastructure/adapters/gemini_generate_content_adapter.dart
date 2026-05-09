import '../../domain/ai_provider_config.dart';
import '../ai_api_exception.dart';
import '../ai_http_client.dart';
import '../storyboard_response_schema.dart';
import 'ai_provider_adapter.dart';

class GeminiGenerateContentAdapter implements AiProviderAdapter {
  GeminiGenerateContentAdapter({required AiHttpClient httpClient})
    : _httpClient = httpClient;

  final AiHttpClient _httpClient;

  @override
  Future<String> generateText({
    required AiProviderConfig config,
    required String prompt,
  }) async {
    final model = config.model.trim().replaceFirst(RegExp(r'^models/'), '');
    final response = await _httpClient.postJson(
      uri: _resolveUri(config.baseUrl, '/models/$model:generateContent'),
      headers: {'x-goog-api-key': config.apiKey.trim()},
      body: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          '_responseJsonSchema': storyboardResponseSchema,
          'temperature': 0.2,
        },
      },
    );

    if (response is! Map) {
      throw const AiApiException('Gemini 返回内容格式异常。');
    }

    final candidates = response['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final first = candidates.first;
      if (first is Map) {
        final content = first['content'];
        if (content is Map) {
          final parts = content['parts'];
          if (parts is List) {
            final text = parts
                .whereType<Map>()
                .map((part) => part['text']?.toString().trim() ?? '')
                .where((item) => item.isNotEmpty)
                .join('\n');
            if (text.isNotEmpty) {
              return text;
            }
          }
        }
      }
    }

    final promptFeedback = response['promptFeedback'];
    if (promptFeedback is Map) {
      final blockReason = promptFeedback['blockReason']?.toString();
      if (blockReason != null && blockReason.isNotEmpty) {
        throw AiApiException('Gemini 拒绝了本次请求：$blockReason');
      }
    }

    throw const AiApiException('Gemini 返回成功，但没有可解析的文本输出。');
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
