# VisionDraft

VisionDraft 是一款面向影视策划、分镜整理与拍摄前统筹的本地优先工具。

当前仓库提供一套可运行的 Flutter 跨端代码基线，优先完成 Windows 桌面工作流，同时保留 Android 端扩展能力。项目核心目标是把传统纸质/Excel 分镜表，升级成可编辑、可预览、可调度、可导出的本地化生产工具。

## 核心能力

- 分镜制作：表格化镜头录入、列显隐、列顺序、项目级列模板、自定义列
- 故事板预览：网格化卡片浏览、共享显示预设、缩略图优先渲染
- 拍摄计划：镜头分配、计划区块整理、桌面与移动端差异化布局
- 导出输出：分镜单、拍摄计划单、拍摄通告单 PDF 生成与 Windows 打印
- 本地优先：项目包落地为 `.vdraft` 目录，离线可用，数据持久化在本地

## 技术栈

- Flutter
- Riverpod
- Drift + SQLite
- Windows 桌面 Runner
- Android 原生宿主

## 项目包结构

每个项目以独立 `.vdraft` 目录保存，典型结构如下：

```text
MyProject.vdraft/
├─ manifest.json
├─ project.db
├─ assets/
│  └─ originals/
└─ exports/
```

应用级目录只负责索引库、缓存和临时导出，不承载核心项目数据。

## 目录结构

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

## 本地开发

### 环境要求

- Flutter `3.41.9`
- Dart `3.11.5`
- Windows 构建工具（Visual Studio 2022 Build Tools）

### 拉起开发环境

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

## Windows 发布构建

仓库内提供可复现的 Windows 构建脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

构建完成后，可运行目录位于：

```text
dist/windows/
```

入口程序：

```text
dist/windows/vision_draft.exe
```

## GitHub 上传建议

推荐上传源码仓库本体，不上传以下目录：

- `build/`
- `dist/`
- `.dart_tool/`
- `tmp_build/`
- `tmp_run_logs/`
- 本地截图与临时验证文件

当前 `.gitignore` 已覆盖这些内容。

如果需要导出一份干净源码包，可直接使用：

```powershell
git archive --format=zip --output VisionDraft-source.zip HEAD
```

## 测试与验证

常用验证命令：

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

## 当前状态

- Windows 桌面版可启动、可构建、可导出
- 导出品牌区支持清空，不再强制回退默认文案
- 项目库支持新建项目和打开已有项目
- 发布目录已整理为绿色可运行形态

## 说明

当前仓库仍处于持续迭代阶段，交付重点是桌面端主工作流的稳定性、可维护性与后续商业化实现基础。
