import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/providers.dart';
import '../domain/ai_generation_density.dart';
import '../domain/ai_generation_request.dart';
import '../domain/ai_generation_result.dart';
import '../domain/ai_provider_config.dart';
import '../domain/ai_provider_preset.dart';
import '../domain/ai_provider_type.dart';
import '../domain/ai_script_mode.dart';
import '../domain/ai_shot_draft.dart';

class AiStoryboardState {
  const AiStoryboardState({
    required this.projectId,
    required this.scriptInput,
    required this.scriptMode,
    required this.generationDensity,
    required this.selectedProvider,
    required this.providerConfigs,
    required this.result,
    required this.isLoadingSettings,
    required this.isGenerating,
    required this.sourceLabel,
    this.errorMessage,
  });

  factory AiStoryboardState.initial(String projectId) {
    return AiStoryboardState(
      projectId: projectId,
      scriptInput: '',
      scriptMode: AiScriptMode.auto,
      generationDensity: AiGenerationDensity.standard,
      selectedProvider: AiProviderType.chatgpt,
      providerConfigs: {
        for (final preset in aiProviderPresets)
          preset.type: AiProviderConfig.fromPreset(preset),
      },
      result: const AiGenerationResult(title: 'AI 分镜草案', draftShots: []),
      isLoadingSettings: true,
      isGenerating: false,
      sourceLabel: '',
    );
  }

  final String projectId;
  final String scriptInput;
  final AiScriptMode scriptMode;
  final AiGenerationDensity generationDensity;
  final AiProviderType selectedProvider;
  final Map<AiProviderType, AiProviderConfig> providerConfigs;
  final AiGenerationResult result;
  final bool isLoadingSettings;
  final bool isGenerating;
  final String sourceLabel;
  final String? errorMessage;

  AiProviderConfig get selectedConfig =>
      providerConfigs[selectedProvider] ??
      AiProviderConfig.fromPreset(presetForProvider(selectedProvider));

  AiStoryboardState copyWith({
    String? scriptInput,
    AiScriptMode? scriptMode,
    AiGenerationDensity? generationDensity,
    AiProviderType? selectedProvider,
    Map<AiProviderType, AiProviderConfig>? providerConfigs,
    AiGenerationResult? result,
    bool? isLoadingSettings,
    bool? isGenerating,
    String? sourceLabel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiStoryboardState(
      projectId: projectId,
      scriptInput: scriptInput ?? this.scriptInput,
      scriptMode: scriptMode ?? this.scriptMode,
      generationDensity: generationDensity ?? this.generationDensity,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      providerConfigs: providerConfigs ?? this.providerConfigs,
      result: result ?? this.result,
      isLoadingSettings: isLoadingSettings ?? this.isLoadingSettings,
      isGenerating: isGenerating ?? this.isGenerating,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiStoryboardController extends FamilyNotifier<AiStoryboardState, String> {
  @override
  AiStoryboardState build(String projectId) {
    Future.microtask(_loadSettings);
    return AiStoryboardState.initial(projectId);
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(aiProviderSettingsRepositoryProvider);
    final configs = await repository.loadConfigs();
    state = state.copyWith(
      providerConfigs: configs,
      isLoadingSettings: false,
      clearError: true,
    );
  }

  void updateScriptInput(String value, {String? sourceLabel}) {
    state = state.copyWith(
      scriptInput: value,
      sourceLabel: sourceLabel ?? state.sourceLabel,
      clearError: true,
    );
  }

  void selectProvider(AiProviderType providerType) {
    state = state.copyWith(selectedProvider: providerType, clearError: true);
  }

  void setScriptMode(AiScriptMode mode) {
    state = state.copyWith(scriptMode: mode, clearError: true);
  }

  void setGenerationDensity(AiGenerationDensity density) {
    state = state.copyWith(generationDensity: density, clearError: true);
  }

  Future<void> saveProviderConfig(AiProviderConfig config) async {
    final nextConfigs = {...state.providerConfigs, config.providerType: config};
    state = state.copyWith(providerConfigs: nextConfigs, clearError: true);
    await ref
        .read(aiProviderSettingsRepositoryProvider)
        .saveConfigs(nextConfigs);
  }

  Future<void> generateDraft() async {
    final script = state.scriptInput.trim();
    if (script.isEmpty) {
      state = state.copyWith(errorMessage: '请先输入脚本文案。');
      return;
    }

    state = state.copyWith(isGenerating: true, clearError: true);
    try {
      final result = await ref
          .read(generateStoryboardUseCaseProvider)
          .call(
            AiGenerationRequest(
              rawScript: script,
              scriptMode: state.scriptMode,
              generationDensity: state.generationDensity,
              providerConfig: state.selectedConfig,
            ),
          );
      state = state.copyWith(
        isGenerating: false,
        result: result,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: error.toString(),
      );
    }
  }

  void removeDraftAt(int index) {
    if (index < 0 || index >= state.result.draftShots.length) {
      return;
    }
    final nextDrafts = [...state.result.draftShots]..removeAt(index);
    state = state.copyWith(
      result: state.result.copyWith(draftShots: nextDrafts),
      clearError: true,
    );
  }

  void replaceDraft(int index, AiShotDraft draft) {
    if (index < 0 || index >= state.result.draftShots.length) {
      return;
    }
    final nextDrafts = [...state.result.draftShots];
    nextDrafts[index] = draft;
    state = state.copyWith(
      result: state.result.copyWith(draftShots: nextDrafts),
      clearError: true,
    );
  }

  void clearDraft() {
    state = state.copyWith(
      result: state.result.copyWith(draftShots: const [], warnings: const []),
      clearError: true,
    );
  }
}
