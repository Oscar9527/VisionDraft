class AiShotDraft {
  const AiShotDraft({
    required this.shotNo,
    required this.shotSize,
    required this.durationSec,
    required this.content,
    required this.dialogue,
    required this.notes,
    required this.sceneExpectation,
    required this.audio,
    required this.cameraAngle,
    required this.cameraMove,
    required this.cameraRig,
    required this.focalLength,
    required this.confidence,
    required this.sourceExcerpt,
  });

  final String shotNo;
  final String shotSize;
  final int durationSec;
  final String content;
  final String dialogue;
  final String notes;
  final String sceneExpectation;
  final String audio;
  final String cameraAngle;
  final String cameraMove;
  final String cameraRig;
  final String focalLength;
  final double confidence;
  final String sourceExcerpt;

  AiShotDraft copyWith({
    String? shotNo,
    String? shotSize,
    int? durationSec,
    String? content,
    String? dialogue,
    String? notes,
    String? sceneExpectation,
    String? audio,
    String? cameraAngle,
    String? cameraMove,
    String? cameraRig,
    String? focalLength,
    double? confidence,
    String? sourceExcerpt,
  }) {
    return AiShotDraft(
      shotNo: shotNo ?? this.shotNo,
      shotSize: shotSize ?? this.shotSize,
      durationSec: durationSec ?? this.durationSec,
      content: content ?? this.content,
      dialogue: dialogue ?? this.dialogue,
      notes: notes ?? this.notes,
      sceneExpectation: sceneExpectation ?? this.sceneExpectation,
      audio: audio ?? this.audio,
      cameraAngle: cameraAngle ?? this.cameraAngle,
      cameraMove: cameraMove ?? this.cameraMove,
      cameraRig: cameraRig ?? this.cameraRig,
      focalLength: focalLength ?? this.focalLength,
      confidence: confidence ?? this.confidence,
      sourceExcerpt: sourceExcerpt ?? this.sourceExcerpt,
    );
  }
}
