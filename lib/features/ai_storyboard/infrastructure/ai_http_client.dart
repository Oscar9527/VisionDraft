import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ai_api_exception.dart';

class AiHttpClient {
  AiHttpClient({HttpClient? httpClient, Duration? timeout})
    : _httpClient = httpClient ?? HttpClient(),
      _timeout = timeout ?? const Duration(seconds: 90) {
    _httpClient.connectionTimeout = _timeout;
  }

  final HttpClient _httpClient;
  final Duration _timeout;

  Future<dynamic> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required Object body,
  }) async {
    final request = await _httpClient.postUrl(uri).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    for (final entry in headers.entries) {
      if (entry.value.trim().isEmpty) {
        continue;
      }
      request.headers.set(entry.key, entry.value);
    }
    request.write(jsonEncode(body));

    final response = await request.close().timeout(_timeout);
    final rawBody = await utf8.decoder.bind(response).join();
    final decoded = _tryDecodeJson(rawBody);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiApiException(
        _extractErrorMessage(decoded) ?? '请求失败，请稍后重试。',
        statusCode: response.statusCode,
        responseBody: rawBody,
      );
    }

    return decoded ?? rawBody;
  }

  dynamic _tryDecodeJson(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(rawBody);
    } catch (_) {
      return null;
    }
  }

  String? _extractErrorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      final message = decoded['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    if (decoded is Map) {
      return _extractErrorMessage(Map<String, dynamic>.from(decoded));
    }
    return null;
  }
}
