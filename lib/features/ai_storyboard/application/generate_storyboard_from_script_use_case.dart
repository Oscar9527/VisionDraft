import '../domain/ai_generation_density.dart';
import '../domain/ai_generation_request.dart';
import '../domain/ai_generation_result.dart';
import '../domain/ai_script_mode.dart';
import '../domain/ai_shot_draft.dart';
import '../infrastructure/script_chunker.dart';

abstract class AiStoryboardGenerator {
  Future<AiGenerationResult> generate(AiGenerationRequest request);
}

class GenerateStoryboardFromScriptUseCase {
  const GenerateStoryboardFromScriptUseCase({
    required AiStoryboardGenerator generator,
  }) : _generator = generator;

  final AiStoryboardGenerator _generator;

  Future<AiGenerationResult> call(AiGenerationRequest request) {
    return _generator.generate(request);
  }
}

class FakeAiStoryboardGenerator implements AiStoryboardGenerator {
  FakeAiStoryboardGenerator({ScriptChunker? chunker})
    : _chunker = chunker ?? const ScriptChunker();

  final ScriptChunker _chunker;

  static const _shotSizes = ['全景', '中景', '近景', '特写'];
  static const _angles = ['平视', '仰拍', '俯拍', '侧拍'];
  static const _moves = ['固定', '推进', '跟拍', '摇镜'];
  static const _rigs = ['三脚架', '手持', '云台', '滑轨'];
  static const _focals = ['24mm', '35mm', '50mm', '85mm'];

  @override
  Future<AiGenerationResult> generate(AiGenerationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final chunks = _chunker.chunk(request.rawScript);
    if (chunks.isEmpty) {
      return const AiGenerationResult(
        title: 'AI 分镜草案',
        draftShots: [],
        warnings: ['未检测到可生成的文本内容。'],
      );
    }

    final selectedChunks = _selectChunksForDensity(
      chunks,
      request.generationDensity,
    );
    final shots = <AiShotDraft>[];
    for (var index = 0; index < selectedChunks.length; index++) {
      final chunk = selectedChunks[index];
      final content = _normalizeSingleLine(chunk);
      final dialogue = _extractDialogue(chunk);
      shots.add(
        AiShotDraft(
          shotNo: '${index + 1}',
          shotSize: _shotSizes[index % _shotSizes.length],
          durationSec: _estimateDuration(chunk),
          content: content,
          dialogue: dialogue,
          notes: 'Phase 1 为本地模拟草案，建议人工复核镜头拆分。',
          sceneExpectation: _sceneExpectationForMode(request.scriptMode),
          audio: dialogue.isNotEmpty ? '对白 + 环境声' : '环境声',
          cameraAngle: _angles[index % _angles.length],
          cameraMove: _cameraMoveForDensity(request.generationDensity, index),
          cameraRig: _rigs[index % _rigs.length],
          focalLength: _focals[index % _focals.length],
          confidence: 0.74 + ((index % 4) * 0.05),
          sourceExcerpt: content.length > 48
              ? '${content.substring(0, 48)}...'
              : content,
        ),
      );
    }

    return AiGenerationResult(
      title: 'AI 分镜草案',
      draftShots: shots,
      warnings: const ['当前阶段使用本地模拟生成器，尚未接入真实联网 AI。'],
    );
  }

  List<String> _selectChunksForDensity(
    List<String> chunks,
    AiGenerationDensity density,
  ) {
    return switch (density) {
      AiGenerationDensity.brief => _mergeAdjacentChunks(chunks, 2),
      AiGenerationDensity.standard => chunks.take(8).toList(),
      AiGenerationDensity.detailed => _expandDetailedChunks(chunks),
    };
  }

  List<String> _mergeAdjacentChunks(List<String> chunks, int size) {
    final merged = <String>[];
    for (var index = 0; index < chunks.length; index += size) {
      merged.add(chunks.skip(index).take(size).join('\n').trim());
    }
    return merged.take(8).toList();
  }

  List<String> _expandDetailedChunks(List<String> chunks) {
    final expanded = <String>[];
    for (final chunk in chunks) {
      final parts = chunk
          .split(RegExp(r'(?<=[。！？!?])'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (parts.length <= 1) {
        expanded.add(chunk);
      } else {
        expanded.addAll(parts);
      }
      if (expanded.length >= 10) {
        break;
      }
    }
    return expanded.take(10).toList();
  }

  int _estimateDuration(String chunk) {
    final length = chunk.replaceAll(RegExp(r'\s+'), '').length;
    if (length <= 18) {
      return 3;
    }
    if (length <= 36) {
      return 4;
    }
    if (length <= 56) {
      return 5;
    }
    return 6;
  }

  String _extractDialogue(String chunk) {
    final quoted = RegExp(r'["“”「」](.*?)["“”「」]').firstMatch(chunk);
    if (quoted != null) {
      return quoted.group(1)?.trim() ?? '';
    }
    final colon = RegExp(r'[:：]\s*(.+)').firstMatch(chunk);
    return colon?.group(1)?.trim() ?? '';
  }

  String _sceneExpectationForMode(AiScriptMode mode) {
    return switch (mode) {
      AiScriptMode.auto => '自动判断场景氛围与视觉重点',
      AiScriptMode.drama => '偏情绪与叙事推进',
      AiScriptMode.ad => '偏产品展示与信息传达',
      AiScriptMode.narration => '偏口播节奏与信息清晰度',
    };
  }

  String _cameraMoveForDensity(AiGenerationDensity density, int index) {
    if (density == AiGenerationDensity.brief) {
      return '固定';
    }
    if (density == AiGenerationDensity.detailed) {
      return _moves[index % _moves.length];
    }
    return _moves[index % 2];
  }

  String _normalizeSingleLine(String raw) {
    return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
