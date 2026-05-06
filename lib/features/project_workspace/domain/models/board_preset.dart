enum ImageFitMode { contain, cover }

enum TextAlignMode { center, start, topStart }

enum TextScaleMode { small, large }

enum ShotNumberMode { order, custom }

class BoardPreset {
  const BoardPreset({
    required this.id,
    required this.name,
    required this.aspectRatio,
    required this.fitMode,
    required this.textAlignMode,
    required this.textScaleMode,
    required this.shotNumberMode,
    required this.primaryFields,
    required this.secondaryFields,
  });

  final String id;
  final String name;
  final double aspectRatio;
  final ImageFitMode fitMode;
  final TextAlignMode textAlignMode;
  final TextScaleMode textScaleMode;
  final ShotNumberMode shotNumberMode;
  final List<String> primaryFields;
  final List<String> secondaryFields;

  factory BoardPreset.initial() {
    return const BoardPreset(
      id: 'default',
      name: '默认分镜预设',
      aspectRatio: 16 / 9,
      fitMode: ImageFitMode.contain,
      textAlignMode: TextAlignMode.center,
      textScaleMode: TextScaleMode.small,
      shotNumberMode: ShotNumberMode.custom,
      primaryFields: ['content'],
      secondaryFields: ['shotNo', 'shotSize', 'durationSec'],
    );
  }

  BoardPreset copyWith({
    String? id,
    String? name,
    double? aspectRatio,
    ImageFitMode? fitMode,
    TextAlignMode? textAlignMode,
    TextScaleMode? textScaleMode,
    ShotNumberMode? shotNumberMode,
    List<String>? primaryFields,
    List<String>? secondaryFields,
  }) {
    return BoardPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      fitMode: fitMode ?? this.fitMode,
      textAlignMode: textAlignMode ?? this.textAlignMode,
      textScaleMode: textScaleMode ?? this.textScaleMode,
      shotNumberMode: shotNumberMode ?? this.shotNumberMode,
      primaryFields: primaryFields ?? this.primaryFields,
      secondaryFields: secondaryFields ?? this.secondaryFields,
    );
  }
}
