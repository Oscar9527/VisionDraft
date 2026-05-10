# VisionDraft

<p align="center">
  <img src="./assets/branding/default_logo.png" alt="VisionDraft Logo" width="96" height="96" />
</p>

<p align="center">
  面向 Windows 桌面的本地优先分镜策划与拍摄前置统筹软件。
</p>

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="https://github.com/Oscar9527/VisionDraft/releases">版本发布</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows-0078D4" alt="Windows" />
  <img src="https://img.shields.io/badge/Flutter-3.41.9-02569B" alt="Flutter 3.41.9" />
  <img src="https://img.shields.io/badge/status-active%20development-6f42c1" alt="Active Development" />
  <img src="https://img.shields.io/badge/storage-local--first-2ea44f" alt="Local First" />
</p>

## 概览

VisionDraft 是一款服务于影视前期统筹的本地优先桌面应用，面向导演、分镜师、摄影师和独立创作者。它的目标不是写剧本，而是把分镜录入、故事板浏览、拍摄计划整理和纸面执行输出整合到一个离线可用的桌面工作流里。

当前公开交付目标是 **Windows 桌面版**。

## 功能

- 分镜制作：固定字段、自定义列、行内编辑、图片列、列模板
- 故事板浏览：共享显示预设、缩略图优先预览
- 拍摄计划：按区块整理镜头，支持计划调度
- 输出能力：分镜单、拍摄计划单、拍摄通告单、Excel、PDF 预览、Windows 打印
- AI 草案：从脚本文案生成 AI 分镜草案，并支持本地保存服务商配置
- 本地优先存储：每个项目都以独立 `.vdraft` 项目包落盘，底层为 SQLite

## 当前公开范围

当前仓库对外描述和实际交付包含：

- Windows 桌面运行版本
- 本地项目包工作流
- 分镜编辑与故事板浏览
- 拍摄计划组织
- PDF / Excel 导出与 Windows 打印

当前仓库 **不对外承诺** 尚未完成的 Android 交付能力。

## 快速开始

### 环境要求

- Flutter `3.41.9`
- Dart `3.11.5`
- Visual Studio 2022 Build Tools
- Windows 开发环境

### 开发运行

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

## Windows 构建

使用仓库内构建脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

构建输出目录：

```text
dist/windows/
```

启动入口：

```text
dist/windows/vision_draft.exe
```

安装器脚本：

```text
scripts/visiondraft_setup.iss
```

## 项目包格式

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

## 项目结构

```text
lib/
├─ app/
├─ core/
├─ features/
│  ├─ ai_storyboard/
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

## 开发验证

提交改动前建议执行：

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

`dist/`、`build/`、`.dart_tool/`、`tmp_build/`、`tmp_run_logs/` 等生成目录不应提交。

## 路线图

近期重点：

- 继续稳定 Windows 桌面主工作流
- 提升导出和打印的确定性
- 强化编辑与恢复流程
- 扩大大项目性能验证覆盖

## 许可证

当前仓库尚未发布正式许可证文件。
