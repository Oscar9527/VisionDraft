import 'dart:convert';

import 'ai_api_exception.dart';
import '../domain/ai_generation_result.dart';
import '../domain/ai_shot_draft.dart';

class AiStoryboardJsonParser {
  const AiStoryboardJsonParser();

  AiGenerationResult parse(String rawText) {
    final decoded = _decodeObject(rawText);
    final title = _readString(decoded, 'title', fallback: 'AI分镜草案');
    final warnings = _readStringList(decoded['warnings']);
    final rawShots = decoded['shots'] ?? decoded['draftShots'];

    final shotMaps = switch (rawShots) {
      List<dynamic> value => value.whereType<Map>().toList(),
      _ => const <Map<dynamic, dynamic>>[],
    };
    if (shotMaps.isEmpty) {
      throw const AiApiException('AI 返回成功，但没有解析出可导入的镜头数据。');
    }

    final shots = <AiShotDraft>[];
    for (var index = 0; index < shotMaps.length; index++) {
      shots.add(_parseShot(Map<String, dynamic>.from(shotMaps[index]), index));
    }

    return AiGenerationResult(
      title: title,
      draftShots: shots,
      warnings: warnings,
    );
  }

  Map<String, dynamic> _decodeObject(String rawText) {
    final normalized = rawText.trim();
    final candidates = <String>[
      normalized,
      _stripMarkdownFence(normalized),
      _extractJsonObject(normalized),
    ].where((item) => item.trim().isNotEmpty).toSet();

    for (final candidate in candidates) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        continue;
      }
    }

    throw const AiApiException('AI 返回内容不是可解析的 JSON。');
  }

  String _stripMarkdownFence(String value) {
    var next = value.trim();
    if (next.startsWith('```')) {
      next = next.replaceFirst(RegExp(r'^```[a-zA-Z0-9_-]*\s*'), '');
      next = next.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return next.trim();
  }

  String _extractJsonObject(String value) {
    final start = value.indexOf('{');
    final end = value.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      return '';
    }
    return value.substring(start, end + 1).trim();
  }

  AiShotDraft _parseShot(Map<String, dynamic> json, int index) {
    final content = _readString(
      json,
      'content',
      fallback: _readString(json, 'description'),
    );

    final confidenceValue =
        (_readDouble(json['confidence'], fallback: 0.72).clamp(0.0, 1.0) as num)
            .toDouble();

    return AiShotDraft(
      shotNo: _readString(
        json,
        'shotNo',
        fallback: _readString(json, 'shot_no', fallback: '${index + 1}'),
      ),
      shotSize: _readString(json, 'shotSize', fallback: '中景'),
      durationSec:
          (_readInt(json['durationSec'], fallback: 4).clamp(1, 120) as num)
              .toInt(),
      content: content,
      dialogue: _readString(json, 'dialogue'),
      notes: _readString(json, 'notes'),
      sceneExpectation: _readString(json, 'sceneExpectation'),
      audio: _readString(json, 'audio'),
      cameraAngle: _readString(json, 'cameraAngle', fallback: '平视'),
      cameraMove: _readString(json, 'cameraMove', fallback: '固定'),
      cameraRig: _readString(json, 'cameraRig', fallback: '手持'),
      focalLength: _readString(json, 'focalLength', fallback: '35mm'),
      confidence: confidenceValue,
      sourceExcerpt: _readString(
        json,
        'sourceExcerpt',
        fallback: content.length > 48
            ? '${content.substring(0, 48)}...'
            : content,
      ),
    );
  }

  String _readString(
    Map<String, dynamic> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _readInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return int.tryParse(text) ?? double.tryParse(text)?.round() ?? fallback;
  }

  double _readDouble(Object? value, {required double fallback}) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return double.tryParse(text) ?? fallback;
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
  }
}
