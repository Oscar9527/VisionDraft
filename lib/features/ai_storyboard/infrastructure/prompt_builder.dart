import '../domain/ai_generation_density.dart';
import '../domain/ai_generation_request.dart';
import '../domain/ai_script_mode.dart';
import 'script_chunker.dart';

class AiStoryboardPromptBuilder {
  AiStoryboardPromptBuilder({ScriptChunker? chunker})
    : _chunker = chunker ?? const ScriptChunker();

  final ScriptChunker _chunker;

  String build(AiGenerationRequest request) {
    final chunkCount = _chunker.chunk(request.rawScript).length;
    final targetShotCount = _estimateTargetShotCount(
      density: request.generationDensity,
      chunkCount: chunkCount,
    );

    return '''
你是 VisionDraft 的影视前置统筹 AI 助手。

任务：
把用户提供的脚本文案拆解为结构化分镜草案，直接服务于拍摄前置规划，而不是文学分析。

输出要求：
1. 只返回一个 JSON 对象。
2. 不要输出 Markdown，不要加代码块，不要加解释性前后缀。
3. JSON 结构必须是：
{
  "title": "AI分镜草案",
  "warnings": ["..."],
  "shots": [
    {
      "shotNo": "1",
      "shotSize": "中景",
      "durationSec": 4,
      "content": "画面内容",
      "dialogue": "台词，没有则空字符串",
      "notes": "补充说明，没有则空字符串",
      "sceneExpectation": "场景氛围或预期",
      "audio": "声音设计或收音重点",
      "cameraAngle": "机位角度",
      "cameraMove": "运镜方式",
      "cameraRig": "机位设备",
      "focalLength": "焦段，例如 35mm",
      "confidence": 0.82,
      "sourceExcerpt": "来自原文的短摘录"
    }
  ]
}

字段约束：
- title 固定为 "AI分镜草案"
- warnings 为字符串数组，没有则返回 []
- shotNo 为字符串
- durationSec 为整数，范围尽量控制在 1 到 12 秒
- confidence 为 0 到 1 之间的小数
- 所有文本字段使用简体中文
- 如果信息不足，不要编故事，写出合理但保守的推断，并在 warnings 中说明

建议取值：
- shotSize 优先使用：大远景、全景、中景、近景、特写
- cameraAngle 优先使用：平视、仰拍、俯拍、侧拍、顶拍
- cameraMove 优先使用：固定、推、拉、摇、移、跟
- cameraRig 优先使用：手持、三脚架、独脚架、云台、滑轨
- focalLength 优先给出常见焦段，如 24mm、35mm、50mm、85mm

拆分原则：
- 脚本类型：${_scriptModeDescription(request.scriptMode)}
- 拆分密度：${request.generationDensity.label}
- 目标镜头数量：约 $targetShotCount 条，允许上下浮动 2 条
- 优先保证每条镜头有明确画面主体、运动或情绪功能
- 如果原文是口播或广告，不要机械地一段一镜，应该按信息节奏拆
- 如果原文明显不足以支撑目标数量，宁可少生成，也不要灌水

原始脚本：
${request.rawScript.trim()}
''';
  }

  int _estimateTargetShotCount({
    required AiGenerationDensity density,
    required int chunkCount,
  }) {
    final base = switch (density) {
      AiGenerationDensity.brief => (chunkCount / 1.8).ceil(),
      AiGenerationDensity.standard => (chunkCount * 1.2).ceil(),
      AiGenerationDensity.detailed => (chunkCount * 1.8).ceil(),
    };

    return switch (density) {
      AiGenerationDensity.brief => (base.clamp(4, 8) as num).toInt(),
      AiGenerationDensity.standard => (base.clamp(6, 12) as num).toInt(),
      AiGenerationDensity.detailed => (base.clamp(8, 16) as num).toInt(),
    };
  }

  String _scriptModeDescription(AiScriptMode mode) {
    return switch (mode) {
      AiScriptMode.auto => '自动判断叙事、信息密度和画面节奏',
      AiScriptMode.drama => '按剧情推进、情绪变化和镜头关系拆分',
      AiScriptMode.ad => '按卖点展示、节奏变化和信息节点拆分',
      AiScriptMode.narration => '按口播节奏、信息段落和辅助画面拆分',
    };
  }
}
