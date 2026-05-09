enum ShotFieldKey {
  shotNo,
  frameImage,
  referenceImage,
  shotSize,
  durationSec,
  content,
  dialogue,
  notes,
  sceneExpectation,
  audio,
  cameraAngle,
  cameraMove,
  cameraRig,
  focalLength,
}

const fixedShotFields = <ShotFieldKey>[
  ShotFieldKey.shotNo,
  ShotFieldKey.frameImage,
  ShotFieldKey.referenceImage,
  ShotFieldKey.shotSize,
  ShotFieldKey.durationSec,
  ShotFieldKey.content,
  ShotFieldKey.dialogue,
  ShotFieldKey.notes,
  ShotFieldKey.sceneExpectation,
  ShotFieldKey.audio,
  ShotFieldKey.cameraAngle,
  ShotFieldKey.cameraMove,
  ShotFieldKey.cameraRig,
  ShotFieldKey.focalLength,
];

const shotSizeOptions = <String>[
  '大远景',
  '全景',
  '中景',
  '近景',
  '特写',
];

const cameraAngleOptions = <String>[
  '平视',
  '俯拍',
  '仰拍',
  '侧拍',
  '顶拍',
];

const cameraMoveOptions = <String>[
  '固定',
  '推',
  '拉',
  '摇',
  '移',
  '跟',
];

const cameraRigOptions = <String>[
  '手持',
  '三脚架',
  '独脚架',
  '云台',
  '滑轨',
];

const focalLengthOptions = <String>[
  '16mm',
  '24mm',
  '35mm',
  '50mm',
  '85mm',
];

const fixedFieldBaseOptionsByKey = <String, List<String>>{
  'shotSize': shotSizeOptions,
  'cameraAngle': cameraAngleOptions,
  'cameraMove': cameraMoveOptions,
  'cameraRig': cameraRigOptions,
  'focalLength': focalLengthOptions,
};

const defaultVisibleStoryboardFieldKeys = <String>[
  'shotNo',
  'frameImage',
  'shotSize',
  'durationSec',
  'content',
  'notes',
];

final fixedShotFieldByStorageKey = <String, ShotFieldKey>{
  for (final field in fixedShotFields) field.storageKey: field,
};

ShotFieldKey? shotFieldKeyFromStorageKey(String storageKey) {
  return fixedShotFieldByStorageKey[storageKey];
}

extension ShotFieldKeyX on ShotFieldKey {
  String get storageKey => name;

  String get label => switch (this) {
        ShotFieldKey.shotNo => '镜号',
        ShotFieldKey.frameImage => '画面',
        ShotFieldKey.referenceImage => '参考图',
        ShotFieldKey.shotSize => '景别',
        ShotFieldKey.durationSec => '时长(秒)',
        ShotFieldKey.content => '内容',
        ShotFieldKey.dialogue => '台词',
        ShotFieldKey.notes => '备注',
        ShotFieldKey.sceneExpectation => '场景预期',
        ShotFieldKey.audio => '声音',
        ShotFieldKey.cameraAngle => '机位角度',
        ShotFieldKey.cameraMove => '运镜',
        ShotFieldKey.cameraRig => '机位设备',
        ShotFieldKey.focalLength => '焦段',
      };
}

List<String> fixedFieldOptions(
  String fieldKey, {
  Map<String, List<String>> customOptionsByFieldKey = const {},
}) {
  final base = fixedFieldBaseOptionsByKey[fieldKey] ?? const <String>[];
  final extras = customOptionsByFieldKey[fieldKey] ?? const <String>[];
  return [
    ...base,
    ...extras.where(
      (item) => item.trim().isNotEmpty && !base.contains(item),
    ),
  ];
}

bool fixedFieldIsDropdown(String fieldKey) {
  return fixedFieldOptions(fieldKey).isNotEmpty;
}

bool fixedFieldSupportsCustomValue(String fieldKey) {
  return fixedFieldIsDropdown(fieldKey);
}

bool fixedFieldIsImage(String fieldKey) {
  return fieldKey == ShotFieldKey.frameImage.storageKey ||
      fieldKey == ShotFieldKey.referenceImage.storageKey;
}

bool fixedFieldIsLongText(String fieldKey) {
  return fieldKey == ShotFieldKey.content.storageKey ||
      fieldKey == ShotFieldKey.dialogue.storageKey ||
      fieldKey == ShotFieldKey.notes.storageKey ||
      fieldKey == ShotFieldKey.sceneExpectation.storageKey ||
      fieldKey == ShotFieldKey.audio.storageKey;
}
