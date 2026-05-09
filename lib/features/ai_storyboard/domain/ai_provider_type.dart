enum AiProviderType { chatgpt, claude, gemini, deepseek, custom }

extension AiProviderTypeX on AiProviderType {
  String get label => switch (this) {
    AiProviderType.chatgpt => 'ChatGPT',
    AiProviderType.claude => 'Claude',
    AiProviderType.gemini => 'Gemini',
    AiProviderType.deepseek => 'DeepSeek',
    AiProviderType.custom => '自定义',
  };
}
