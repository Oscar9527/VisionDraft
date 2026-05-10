import 'shot_record.dart';
import 'storyboard_scene.dart';

sealed class StoryboardRow {
  const StoryboardRow();
}

class SceneHeaderRow extends StoryboardRow {
  const SceneHeaderRow({
    required this.scene,
    required this.autoNumber,
    required this.shotCount,
  });

  final StoryboardScene scene;
  final int autoNumber;
  final int shotCount;

  String get displayNumber => scene.displayNumber(autoNumber);
}

class StoryboardShotRow extends StoryboardRow {
  const StoryboardShotRow({
    required this.scene,
    required this.autoNumber,
    required this.shot,
    required this.sceneShotIndex,
  });

  final StoryboardScene scene;
  final int autoNumber;
  final ShotRecord shot;
  final int sceneShotIndex;

  String get displayNumber => scene.displayNumber(autoNumber);
}
