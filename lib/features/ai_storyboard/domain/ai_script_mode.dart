enum AiScriptMode { auto, drama, ad, narration }

extension AiScriptModeX on AiScriptMode {
  String get label => switch (this) {
    AiScriptMode.auto => '自动',
    AiScriptMode.drama => '剧情',
    AiScriptMode.ad => '广告',
    AiScriptMode.narration => '口播',
  };
}
