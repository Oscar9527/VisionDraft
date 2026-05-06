import 'asset_ref.dart';

class ShotRecord {
  const ShotRecord({
    required this.id,
    required this.orderIndex,
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
    this.frameImage,
    this.referenceImage,
    this.customFieldValues = const {},
  });

  final String id;
  final int orderIndex;
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
  final AssetRef? frameImage;
  final AssetRef? referenceImage;
  final Map<String, Object?> customFieldValues;

  ShotRecord copyWith({
    String? id,
    int? orderIndex,
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
    AssetRef? frameImage,
    AssetRef? referenceImage,
    Map<String, Object?>? customFieldValues,
    bool clearFrameImage = false,
    bool clearReferenceImage = false,
  }) {
    return ShotRecord(
      id: id ?? this.id,
      orderIndex: orderIndex ?? this.orderIndex,
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
      frameImage: clearFrameImage ? null : frameImage ?? this.frameImage,
      referenceImage:
          clearReferenceImage ? null : referenceImage ?? this.referenceImage,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }
}
