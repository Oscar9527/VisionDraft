# VisionDraft

> Local-first storyboard planning and shooting preparation software for Windows desktop.  
> 面向 Windows 桌面的本地优先分镜策划与拍摄前统筹软件。

## Table of Contents

- [Overview](#overview)
- [Product Scope](#product-scope)
- [Current Status](#current-status)
- [Core Features](#core-features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Windows Build](#windows-build)
- [Project Bundle Format](#project-bundle-format)
- [Repository Notes](#repository-notes)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [中文说明](#中文说明)

## Overview

VisionDraft is a local-first desktop application for film pre-production. It is built for directors, storyboard artists, cinematographers, and solo creators who need a practical workflow for:

- structuring shots
- reviewing storyboard cards
- regrouping shots into shooting plans
- exporting printable production sheets

The current public deliverable is the **Windows desktop version**. This repository does not publicly promise unfinished platform targets.

## Product Scope

VisionDraft focuses on pre-shoot planning rather than scriptwriting. The software is designed to replace paper notes and spreadsheet-based shot lists with a structured desktop workflow that remains fully usable offline.

Primary workflow:

1. Create or open a local project bundle
2. Edit shots in the storyboard editor
3. Review shots in board view
4. Organize shooting sections and assignments
5. Export shot sheets, shooting plans, and call sheets

## Current Status

Current repository status:

- Delivery target: Windows desktop
- Runtime: working
- Build: working
- Static analysis: passing
- Tests: passing
- Distribution form: portable folder build

Known public boundary:

- Windows desktop is the only production-facing target described in this README
- Unfinished platforms are intentionally excluded from external delivery claims

## Core Features

### Storyboard Editor

- table-based shot entry
- fixed field editing
- custom columns
- column visibility and ordering
- project-level column templates
- local-first project persistence

### Storyboard Board

- card-based visual browsing
- shared display presets
- thumbnail-first rendering for better performance

### Shooting Plan

- shot assignment into plan sections
- section-based planning view
- unassigned pool workflow

### Export and Print

- shot sheet export
- shooting plan export
- call sheet export
- Windows print flow

## Tech Stack

- Flutter
- Riverpod
- Drift
- SQLite
- Windows Desktop Runner

## Project Structure

```text
lib/
├─ app/                  # app bootstrap, routing, theme, layout shell
├─ core/                 # command, history, cache, result, shared widgets
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

## Getting Started

### Requirements

- Flutter `3.41.9`
- Dart `3.11.5`
- Visual Studio 2022 Build Tools
- Windows development environment

### Development

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

## Windows Build

Use the repository build script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

Runnable output:

```text
dist/windows/
```

Entry executable:

```text
dist/windows/vision_draft.exe
```

## Project Bundle Format

Each project is stored as an isolated `.vdraft` directory:

```text
MyProject.vdraft/
├─ manifest.json
├─ project.db
├─ assets/
│  └─ originals/
└─ exports/
```

App-level storage is used only for lightweight index data, cache, and temporary files. Core production data stays inside the project bundle.

## Repository Notes

- Source code belongs in GitHub
- Local build outputs should not be committed
- The repository already ignores generated folders such as:
  - `dist/`
  - `build/`
  - `.dart_tool/`
  - `tmp_build/`
  - `tmp_run_logs/`

To export a clean source archive:

```powershell
git archive --format=zip --output VisionDraft-source.zip HEAD
```

## Roadmap

Near-term priorities:

- continue stabilizing the Windows desktop workflow
- improve export polish and print predictability
- harden data editing and recovery flows
- expand performance validation for large storyboard projects

## Contributing

This repository is still under active iteration. If you plan to contribute, keep changes focused and aligned with the existing local-first desktop architecture.

Recommended validation before submitting changes:

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

## License

License has not been published in this repository yet.

---

## 中文说明

### 概览

VisionDraft 是一款面向影视前期统筹的本地优先桌面软件，服务于导演、分镜师、摄影师和独立创作者。它的目标不是写剧本，而是把分镜录入、故事板浏览、拍摄计划整理和纸面执行输出整合到一个离线可用的桌面工作流里。

当前仓库对外公开的交付目标只有 **Windows 桌面版**。

### 产品范围

VisionDraft 主要解决的是拍摄前准备阶段的组织问题，包括：

- 镜头整理
- 分镜表编辑
- 故事板浏览
- 拍摄计划重组
- 分镜单、计划单、通告单导出

当前不对外承诺未完成的平台版本。

### 当前状态

当前仓库状态：

- 交付目标：Windows 桌面
- 运行状态：可启动
- 构建状态：可构建
- 静态检查：已通过
- 测试状态：已通过
- 交付形态：绿色目录版

### 核心功能

#### 分镜制作

- 表格式镜头录入
- 固定字段编辑
- 自定义列
- 列显隐与列顺序
- 项目级列模板
- 本地项目持久化

#### 故事板浏览

- 卡片化镜头预览
- 共享显示预设
- 缩略图优先渲染

#### 拍摄计划

- 镜头分配到计划区块
- 区块化计划视图
- 未分配镜头池

#### 导出与打印

- 分镜单导出
- 拍摄计划单导出
- 拍摄通告单导出
- Windows 打印流程

### 技术栈

- Flutter
- Riverpod
- Drift
- SQLite
- Windows Desktop Runner

### 项目结构

```text
lib/
├─ app/                  # 启动、路由、主题、布局壳层
├─ core/                 # command、history、cache、result、共享组件
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
- Windows 开发环境

开发命令：

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

### Windows 构建

使用仓库内构建脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

构建完成后的可运行目录：

```text
dist/windows/
```

启动入口：

```text
dist/windows/vision_draft.exe
```

### 项目包格式

每个项目使用独立 `.vdraft` 目录保存：

```text
MyProject.vdraft/
├─ manifest.json
├─ project.db
├─ assets/
│  └─ originals/
└─ exports/
```

应用级目录只负责索引库、缓存和临时文件，不承载项目核心生产数据。

### 仓库说明

- GitHub 仓库应提交源码，不提交本地构建产物
- `dist/`、`build/`、`.dart_tool/`、`tmp_build/`、`tmp_run_logs/` 等目录默认忽略
- 如需导出干净源码包，可使用：

```powershell
git archive --format=zip --output VisionDraft-source.zip HEAD
```

### 路线图

下一阶段重点：

- 继续打磨 Windows 桌面主工作流
- 提升导出和打印的稳定性
- 强化编辑与恢复流程
- 扩大大项目性能验证覆盖

### 贡献说明

当前仓库仍在持续迭代，提交改动时建议保持小步、聚焦，并遵循现有的本地优先桌面架构。

建议提交前执行：

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

### 许可证

当前仓库尚未发布正式许可证文件。
