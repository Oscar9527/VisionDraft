enum AiGenerationDensity { brief, standard, detailed }

extension AiGenerationDensityX on AiGenerationDensity {
  String get label => switch (this) {
    AiGenerationDensity.brief => '简略',
    AiGenerationDensity.standard => '标准',
    AiGenerationDensity.detailed => '详细',
  };
}
