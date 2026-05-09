# VisionDraft

<p align="center">
  面向 Windows 桌面的本地优先分镜策划与拍摄前统筹软件。
</p>

<p align="center">
  <a href="./README.md">English</a> ·
  <a href="./README.zh-CN.md">简体中文</a> ·
  <a href="https://github.com/Oscar9527/VisionDraft/releases">版本发布</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows-0078D4" alt="Windows" />
  <img src="https://img.shields.io/badge/Flutter-3.41.9-02569B" alt="Flutter 3.41.9" />
  <img src="https://img.shields.io/badge/status-active%20development-6f42c1" alt="Active Development" />
  <img src="https://img.shields.io/badge/storage-local--first-2ea44f" alt="Local First" />
</p>

## 概览

VisionDraft 是一款面向影视前期统筹的本地优先桌面软件，服务于导演、分镜师、摄影师和独立创作者。它的目标不是写剧本，而是把分镜录入、故事板浏览、拍摄计划整理和纸面执行输出整合到一个离线可用的桌面工作流里。

当前公开交付目标是 **Windows 桌面版**。

## 为什么做 VisionDraft

传统分镜工作流往往分散在纸笔、图片文件夹和 Excel 表格里。VisionDraft 的目的，是把这些环节收敛到一个结构化桌面工作区，让创作者可以：

- 录入和编辑镜头
- 用视觉化方式浏览分镜
- 把镜头重组为拍摄计划
- 导出可打印的执行文档
- 在离线状态下完整使用项目数据

## 当前范围

当前仓库对外描述和实际交付包含：

- Windows 桌面运行版本
- 本地项目包工作流
- 分镜编辑与故事板浏览
- 拍摄计划整理
- PDF 导出与 Windows 打印

当前仓库 **不对外承诺** 尚未完成的平台交付能力。

## 功能特性

### 分镜制作

- 表格式镜头录入
- 固定字段编辑
- 自定义列
- 列显隐与列顺序
- 项目级列模板

### 故事板浏览

- 卡片化镜头预览
- 共享显示预设
- 缩略图优先渲染

### 拍摄计划

- 分区式计划整理
- 未分配镜头池
- 镜头分配到计划区块

### 导出

- 分镜单导出
- 拍摄计划单导出
- 拍摄通告单导出
- Windows 打印支持

### 本地优先存储

- 项目以 `.vdraft` 目录保存
- 离线优先工作流
- 本地 SQLite 持久化

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

## 开发说明

提交改动前建议执行：

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

`dist/`、`build/`、`.dart_tool/`、`tmp_build/`、`tmp_run_logs/` 等生成目录不应提交。

如需导出干净源码包：

```powershell
git archive --format=zip --output VisionDraft-source.zip HEAD
```

## 路线图

下一阶段重点：

- 继续稳定 Windows 桌面主工作流
- 提升导出和打印的确定性
- 强化编辑与恢复流程
- 扩大大项目性能验证覆盖

## 参与贡献

当前仓库仍在持续迭代，提交改动时建议保持聚焦、小步，并遵循现有的本地优先桌面架构。

## 许可证

当前仓库尚未发布正式许可证文件。
