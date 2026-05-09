import 'ai_provider_type.dart';

class AiProviderPreset {
  const AiProviderPreset({
    required this.type,
    required this.label,
    required this.defaultBaseUrl,
    required this.defaultModel,
    required this.protocolLabel,
  });

  final AiProviderType type;
  final String label;
  final String defaultBaseUrl;
  final String defaultModel;
  final String protocolLabel;
}

const aiProviderPresets = <AiProviderPreset>[
  AiProviderPreset(
    type: AiProviderType.chatgpt,
    label: 'ChatGPT',
    defaultBaseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-5.2',
    protocolLabel: 'OpenAI Responses API',
  ),
  AiProviderPreset(
    type: AiProviderType.claude,
    label: 'Claude',
    defaultBaseUrl: 'https://api.anthropic.com/v1',
    defaultModel: 'claude-sonnet-4-20250514',
    protocolLabel: 'Anthropic Messages API',
  ),
  AiProviderPreset(
    type: AiProviderType.gemini,
    label: 'Gemini',
    defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    defaultModel: 'gemini-2.5-flash',
    protocolLabel: 'Gemini generateContent',
  ),
  AiProviderPreset(
    type: AiProviderType.deepseek,
    label: 'DeepSeek',
    defaultBaseUrl: 'https://api.deepseek.com',
    defaultModel: 'deepseek-v4-flash',
    protocolLabel: 'OpenAI-Compatible Chat API',
  ),
  AiProviderPreset(
    type: AiProviderType.custom,
    label: '自定义',
    defaultBaseUrl: '',
    defaultModel: '',
    protocolLabel: 'Custom OpenAI-Compatible Endpoint',
  ),
];

AiProviderPreset presetForProvider(AiProviderType type) {
  return aiProviderPresets.firstWhere((item) => item.type == type);
}
