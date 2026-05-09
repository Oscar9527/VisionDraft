import 'package:flutter_test/flutter_test.dart';
import 'package:vision_draft/features/ai_storyboard/infrastructure/storyboard_json_parser.dart';

void main() {
  const parser = AiStoryboardJsonParser();

  test('parses direct json response into storyboard draft', () {
    final result = parser.parse('''
{
  "title": "AI分镜草案",
  "warnings": ["存在少量推断"],
  "shots": [
    {
      "shotNo": "1",
      "shotSize": "中景",
      "durationSec": 4,
      "content": "主角坐在窗边翻看旧照片。",
      "dialogue": "今天终于想明白了。",
      "notes": "情绪由平静转向坚定",
      "sceneExpectation": "安静但带一点压抑感",
      "audio": "轻环境声，保留纸张摩擦声",
      "cameraAngle": "平视",
      "cameraMove": "固定",
      "cameraRig": "三脚架",
      "focalLength": "50mm",
      "confidence": 0.86,
      "sourceExcerpt": "主角坐在窗边翻看旧照片"
    }
  ]
}
''');

    expect(result.title, 'AI分镜草案');
    expect(result.warnings, ['存在少量推断']);
    expect(result.draftShots, hasLength(1));
    expect(result.draftShots.first.shotNo, '1');
    expect(result.draftShots.first.shotSize, '中景');
    expect(result.draftShots.first.durationSec, 4);
  });

  test('parses fenced json and fills defaults for missing fields', () {
    final result = parser.parse('''
```json
{
  "title": "AI分镜草案",
  "shots": [
    {
      "shotNo": "3",
      "content": "产品被放到桌面中央。"
    }
  ]
}
```
''');

    final draft = result.draftShots.single;
    expect(draft.shotNo, '3');
    expect(draft.shotSize, '中景');
    expect(draft.cameraMove, '固定');
    expect(draft.cameraRig, '手持');
    expect(draft.focalLength, '35mm');
    expect(draft.durationSec, 4);
  });
}
