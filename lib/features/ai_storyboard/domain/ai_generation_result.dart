import 'ai_shot_draft.dart';

class AiGenerationResult {
  const AiGenerationResult({
    required this.title,
    required this.draftShots,
    this.warnings = const [],
  });

  final String title;
  final List<AiShotDraft> draftShots;
  final List<String> warnings;

  AiGenerationResult copyWith({
    String? title,
    List<AiShotDraft>? draftShots,
    List<String>? warnings,
  }) {
    return AiGenerationResult(
      title: title ?? this.title,
      draftShots: draftShots ?? this.draftShots,
      warnings: warnings ?? this.warnings,
    );
  }
}
