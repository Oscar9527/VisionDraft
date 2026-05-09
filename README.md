# VisionDraft

> Current release target: **Windows desktop**
>
> 当前公开交付目标：**Windows 桌面版**

VisionDraft is a local-first pre-production tool for filmmakers, storyboard artists, and solo creators. It turns traditional paper or spreadsheet-based shot planning into an editable, visual, and exportable desktop workflow.

VisionDraft 是一款面向影视前期策划的本地优先工具，服务于导演、分镜师和独立创作者。它把传统纸质或 Excel 分镜表，升级成可编辑、可预览、可调度、可导出的桌面工作流。

---

## 中文说明

### 项目定位

VisionDraft 聚焦影视前期统筹，核心目标不是“写剧本”，而是把镜头策划、故事板浏览、拍摄计划整理和纸面执行输出整合到一个本地化软件里。

当前仓库对外描述和实际交付，统一以 **Windows 桌面版** 为准。

### 当前已实现的主链路

- 分镜制作工作台
  - 表格式镜头录入
  - 固定字段编辑
  - 自定义列
  - 列显隐与列顺序
  - 项目级列模板
- 故事板预览
  - 卡片化镜头浏览
  - 共享显示预设
  - 缩略图优先渲染
- 拍摄计划整理
  - 镜头分配到计划区块
  - 未分配池与计划分区视图
- 导出与打印
  - 分镜单
  - 拍摄计划单
  - 拍摄通告单
  - Windows 打印流程
- 本地优先
  - 项目以 `.vdraft` 目录保存
  - 离线可用
  - 数据持久化在本地 SQLite

### 当前交付状态

- 可运行平台：Windows 桌面
- 可构建状态：通过
- 可测试状态：通过 `flutter analyze` 和 `flutter test`
- 可交付形态：绿色目录版

### 技术栈

- Flutter
- Riverpod
- Drift + SQLite
- Windows Desktop Runner

### 项目包结构

每个项目使用独立 `.vdraft` 目录保存：

```text
MyProject.vdraft/
├─ manifest.json
├─ project.db
├─ assets/
│  └─ originals/
└─ exports/
```

应用级目录只负责索引库、缓存和临时文件，不承载核心项目数据。

### 仓库结构

```text
lib/
├─ app/                  # 启动、路由、主题、布局壳层
├─ core/                 # command/history/cache/result/widgets
├─ features/
│  ├─ project_library/
│  ├─ project_workspace/
│  ├─ storyboard_editor/
│  ├─ storyboard_board/
│  ├─ shooting_plan/
│  └─ export/
└─ infrastructure/
   ├─ database/
   ├─ filesystem/
   ├─ imaging/
   ├─ printing/
   └─ sync_stub/
```

### 本地开发

环境要求：

- Flutter `3.41.9`
- Dart `3.11.5`
- Visual Studio 2022 Build Tools

开发命令：

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

### Windows 构建

仓库内提供可复现的 Windows 构建脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

构建完成后，绿色运行目录位于：

```text
dist/windows/
```

入口程序：

```text
dist/windows/vision_draft.exe
```

### 仓库说明

- `dist/`、`build/`、`.dart_tool/`、`tmp_build/` 等目录默认不提交
- GitHub 仓库应提交源码，而不是本地构建产物
- 如需导出干净源码包，可使用：

```powershell
git archive --format=zip --output VisionDraft-source.zip HEAD
```

### 当前边界

这个仓库当前公开描述只覆盖 Windows 桌面版。任何尚未完成、尚未达到交付标准的平台能力，都不在 README 中对外承诺。

---

## English

### Overview

VisionDraft is a local-first pre-production tool for film planning. It is designed for directors, storyboard artists, and solo creators who need a practical desktop workflow for shot planning, visual review, scheduling, and printable output.

This public repository currently describes and ships the **Windows desktop version** only.

### What is implemented

- Storyboard editor workspace
  - table-based shot entry
  - fixed-field editing
  - custom columns
  - column visibility and ordering
  - project-level column templates
- Storyboard preview
  - card-based browsing
  - shared display presets
  - thumbnail-first rendering
- Shooting plan organization
  - assign shots into plan sections
  - unassigned pool and sectioned planning view
- Export and print
  - shot sheet
  - shooting plan
  - call sheet
  - Windows print flow
- Local-first storage
  - projects stored as `.vdraft` folders
  - fully offline workflow
  - local SQLite persistence

### Current delivery status

- Supported runtime target: Windows desktop
- Build status: working
- Validation status: passes `flutter analyze` and `flutter test`
- Distribution form: portable folder build

### Stack

- Flutter
- Riverpod
- Drift + SQLite
- Windows Desktop Runner

### Project bundle layout

Each project is stored as an isolated `.vdraft` folder:

```text
MyProject.vdraft/
├─ manifest.json
├─ project.db
├─ assets/
│  └─ originals/
└─ exports/
```

App-level storage is only used for index data, cache, and temporary files. Core project data stays inside the project bundle.

### Repository layout

```text
lib/
├─ app/
├─ core/
├─ features/
│  ├─ project_library/
│  ├─ project_workspace/
│  ├─ storyboard_editor/
│  ├─ storyboard_board/
│  ├─ shooting_plan/
│  └─ export/
└─ infrastructure/
   ├─ database/
   ├─ filesystem/
   ├─ imaging/
   ├─ printing/
   └─ sync_stub/
```

### Local development

Requirements:

- Flutter `3.41.9`
- Dart `3.11.5`
- Visual Studio 2022 Build Tools

Commands:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

### Windows build

Use the reproducible build script in this repository:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

The runnable output is generated under:

```text
dist/windows/
```

Entry executable:

```text
dist/windows/vision_draft.exe
```

### Notes

- Source code should be pushed to GitHub, not local build artifacts
- Generated directories such as `dist/`, `build/`, `.dart_tool/`, and `tmp_build/` are ignored
- To export a clean source archive:

```powershell
git archive --format=zip --output VisionDraft-source.zip HEAD
```

### Public scope

This README intentionally documents only the Windows desktop deliverable. Features or platforms that are not production-ready are not publicly promised here.
