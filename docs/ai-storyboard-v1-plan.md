# VisionDraft AI Storyboard V1 Plan

## Goal

Add an optional AI-assisted workflow that converts a pasted script or text file into a structured storyboard draft, then lets the user review and import the draft into the current project as a single undoable operation.

This feature must not bypass the existing local-first editing workflow.

## Product Position

The AI feature is an enhancement layer on top of the storyboard editor, not a replacement for manual editing.

Target workflow:

1. User opens the storyboard editor.
2. User clicks `AI 生成`.
3. User pastes script text or imports a text file.
4. AI generates storyboard draft rows.
5. User reviews, edits, deletes, or accepts draft rows.
6. User imports the accepted rows into the current project.
7. Import is recorded as one history entry and can be undone with a single undo operation.

## V1 Scope

### Included

- Paste script text
- Import `.txt` or `.md`
- Generate storyboard draft rows
- Support provider presets:
  - ChatGPT
  - Claude
  - Gemini
  - DeepSeek
  - Custom OpenAI-compatible endpoint
- Preview AI output before import
- Edit or remove draft rows before import
- Import to current project as appended shots
- One-shot undo/redo for the full imported batch

### Excluded

- Image generation
- Reference frame generation
- Direct overwrite of existing shots
- Direct PDF or DOCX parsing
- Automatic shooting plan generation
- Multi-turn AI chat inside the editor
- Hard requirement on cloud AI

## UI Plan

## Entry Point

Place the main entry button in the storyboard editor toolbar, inside:

- `lib/features/storyboard_editor/presentation/pages/storyboard_editor_page.dart`

Recommended order:

- `批量`
- `选择`
- `分镜设置`
- `列设置`
- `AI生成`
- `撤销`
- `重做`
- `新建镜头`

Button style:

- `FilledButton.icon`
- icon: `Icons.auto_awesome_rounded`
- label: `AI生成`

This action should not be placed in the global workspace header because it is an editor-scoped action, not a project-scoped action.

## Interaction Surface

Open a right-side large sheet using the existing side-sheet interaction pattern already present in the editor page.

The AI sheet should contain three stacked areas:

### 1. Script Input

- multiline text input
- import file button
- script mode:
  - auto
  - drama
  - ad
  - narration
- generation density:
  - brief
  - standard
  - detailed

### 2. Provider Settings

- provider segmented control or dropdown:
  - ChatGPT
  - Claude
  - Gemini
  - DeepSeek
  - Custom
- fields:
  - base URL
  - API key
  - model
  - test connection

### 3. Draft Preview

- draft rows rendered in a compact editable table
- each row shows:
  - shot number
  - shot size
  - duration
  - content
  - dialogue
  - notes
  - camera angle
  - camera move
  - camera rig
  - focal length
- per-row metadata:
  - confidence
  - source excerpt
- actions:
  - delete row
  - regenerate all
  - import accepted rows

## Data Model Plan

Create a new feature module:

```text
lib/features/ai_storyboard/
├─ domain/
│  ├─ ai_generation_request.dart
│  ├─ ai_generation_result.dart
│  ├─ ai_provider_config.dart
│  ├─ ai_provider_preset.dart
│  └─ ai_shot_draft.dart
├─ application/
│  ├─ ai_storyboard_controller.dart
│  └─ generate_storyboard_from_script_use_case.dart
├─ infrastructure/
│  ├─ adapters/
│  │  ├─ anthropic_adapter.dart
│  │  ├─ deepseek_adapter.dart
│  │  ├─ gemini_adapter.dart
│  │  └─ openai_adapter.dart
│  ├─ prompt_builder.dart
│  ├─ script_chunker.dart
│  └─ ai_provider_registry.dart
└─ presentation/
   ├─ ai_storyboard_sheet.dart
   └─ widgets/
```

## Core Types

### AiProviderPreset

- id
- label
- providerType
- defaultBaseUrl
- defaultModel
- protocol

### AiProviderConfig

- providerType
- baseUrl
- apiKey
- model
- isEnabled

Stored in app-level local settings, not in the project bundle.

### AiGenerationRequest

- rawScript
- scriptMode
- generationDensity
- providerConfig

### AiShotDraft

- shotNo
- shotSize
- durationSec
- content
- dialogue
- notes
- sceneExpectation
- audio
- cameraAngle
- cameraMove
- cameraRig
- focalLength
- confidence
- sourceExcerpt

### AiGenerationResult

- title
- draftShots
- warnings

## Existing Model Mapping

Storyboard draft rows are mapped into existing `ShotRecord` fields in:

- `lib/features/project_workspace/domain/models/shot_record.dart`
- `lib/features/project_workspace/domain/models/shot_fields.dart`

Mapped fields:

- `shotNo`
- `shotSize`
- `durationSec`
- `content`
- `dialogue`
- `notes`
- `sceneExpectation`
- `audio`
- `cameraAngle`
- `cameraMove`
- `cameraRig`
- `focalLength`

Initially left empty:

- `frameImage`
- `referenceImage`

## Provider Strategy

Avoid large external SDK dependencies. Use small Dart HTTP-based adapters.

### ChatGPT

- base URL: `https://api.openai.com/v1`
- endpoint: `/responses`
- protocol: OpenAI Responses API
- default model: `gpt-5`

### Claude

- base URL: `https://api.anthropic.com/v1`
- endpoint: `/messages`
- protocol: Anthropic Messages API
- default model: `claude-sonnet-4-20250514`

### Gemini

- base URL: `https://generativelanguage.googleapis.com/v1beta`
- endpoint: `/models/{model}:generateContent`
- default model: `gemini-2.0-flash`

### DeepSeek

- base URL: `https://api.deepseek.com`
- endpoint: `/chat/completions`
- protocol: OpenAI-compatible chat completions
- default model: `deepseek-chat`

### Custom

- OpenAI-compatible endpoint
- user-defined base URL and model

## Referenced Projects

These are reference sources for interaction ideas and provider organization, not direct code imports:

- LobeChat
  - reference value: multi-provider preset organization and AI settings structure
  - repo: `https://github.com/lobehub/lobe-chat`

- unified-llm
  - reference value: provider abstraction and response normalization ideas
  - repo: `https://github.com/rhyizm/unified-llm`

Implementation in VisionDraft should remain native to the Flutter/Dart architecture and avoid web-stack dependency carryover.

## Generation Strategy

AI must return strict JSON.

Do not allow free-form prose output to flow directly into the app.

### Output Contract

Expected shape:

```json
{
  "title": "Storyboard Draft",
  "shots": [
    {
      "shotNo": "1",
      "shotSize": "中景",
      "durationSec": 4,
      "content": "主角推门进入房间，停顿观察四周",
      "dialogue": "有人吗？",
      "notes": "建议保留停顿，突出陌生感",
      "sceneExpectation": "室内，压抑，偏冷",
      "audio": "门轴声，轻微环境底噪",
      "cameraAngle": "平视",
      "cameraMove": "固定",
      "cameraRig": "三脚架",
      "focalLength": "35mm",
      "confidence": 0.82,
      "sourceExcerpt": "主角推开门，小心走进空房间……"
    }
  ]
}
```

### Long Script Handling

Do not send very long scripts as a single prompt.

Use a local `ScriptChunker`:

- split by scene heading
- split by blank lines
- split by paragraph block

Then:

1. generate per chunk
2. normalize locally
3. merge drafts
4. reindex shot numbers if needed

## Import Strategy

AI generation itself should not modify the project.

Import must happen only after user confirmation.

Add a new command in:

- `lib/features/project_workspace/domain/commands/workspace_commands.dart`

Suggested command:

- `ImportGeneratedShotsCommand`

Suggested behavior:

- create all accepted shots
- append them to current project order
- register needed custom option values if required
- create one history entry for the entire import
- undo removes the full imported batch
- redo restores the batch

This command should be handled in:

- `lib/features/project_workspace/application/project_workspace_command_service.dart`

## Option Handling

Existing fixed dropdown fields already support project-level custom options.

If AI returns values that are not part of the built-in list:

- preserve them in preview
- import them as project custom options when appropriate
- then write them to the imported shots

Example:

- `超特写`
- `肩扛`
- `升降推进`

These should not be discarded or forcibly downgraded.

## Settings Storage

Store AI provider settings at app level, not in the project bundle.

Reason:

- API keys are user-level secrets
- provider settings should survive project switching
- project bundles should remain portable without embedding private credentials

Possible storage path:

- existing app preferences service under infrastructure filesystem

## Error Handling

Need explicit states for:

- missing API key
- invalid endpoint
- unsupported model
- invalid JSON response
- chunk generation partial failure
- rate limit
- timeout

UI behavior:

- show per-request error
- keep input text intact
- allow retry without losing draft

## Security Notes

- never store API keys in project bundle
- avoid logging raw script content unless debugging is explicitly enabled
- avoid logging full provider responses in production mode

## Test Plan

### Unit Tests

- provider preset normalization
- script chunking
- JSON response parsing
- draft-to-shot mapping
- import command undo/redo

### Widget Tests

- AI button visible in storyboard toolbar
- side sheet opens
- provider preset switching
- preview table rendering
- import button enabled only when valid draft exists

### Integration Tests

- paste script -> generate draft -> import -> undo -> redo
- custom option import flow
- long script chunk-merge flow

## Phase Plan

### Phase 1

- add provider models
- add local settings storage
- add AI side sheet shell
- add fake adapter for UI-only flow

### Phase 2

- add OpenAI adapter
- add strict JSON parsing
- add preview draft table

### Phase 3

- add Claude, Gemini, and DeepSeek presets
- add import command
- add undo/redo integration

### Phase 4

- polish error handling
- improve chunking
- performance and UX cleanup

## Pre-Code Decision Lock

Before implementation begins, keep these decisions fixed:

1. Feature name: `AI 生成分镜`
2. Entry point: storyboard editor toolbar
3. Interaction: right-side large sheet
4. Import mode: append to current project only
5. History mode: one history entry per AI import
6. Provider mode: multi-provider presets + custom OpenAI-compatible endpoint
7. V1 image generation: excluded
8. V1 file support: `.txt` and `.md` only
