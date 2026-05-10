# VisionDraft

<p align="center">
  <img src="./assets/branding/default_logo.png" alt="VisionDraft Logo" width="96" height="96" />
</p>

<p align="center">
  Local-first storyboard planning and shooting preparation software for Windows desktop.
</p>

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="https://github.com/Oscar9527/VisionDraft/releases">Releases</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows-0078D4" alt="Windows" />
  <img src="https://img.shields.io/badge/Flutter-3.41.9-02569B" alt="Flutter 3.41.9" />
  <img src="https://img.shields.io/badge/status-active%20development-6f42c1" alt="Active Development" />
  <img src="https://img.shields.io/badge/storage-local--first-2ea44f" alt="Local First" />
</p>

## Overview

VisionDraft is a local-first desktop application for film pre-production. It is built for directors, storyboard artists, cinematographers, and solo creators who need a practical workflow for shot planning, visual review, shooting organization, and printable output.

The current public deliverable is the **Windows desktop version**.

## Features

- Storyboard editor with fixed fields, custom columns, inline editing, image fields, and column templates
- Storyboard board with shared display presets and thumbnail-first browsing
- Shooting plan organization with section-based scheduling
- Export for shot sheets, shooting plans, call sheets, Excel, PDF preview, and Windows print
- Script-to-storyboard AI draft workflow with local provider settings
- Local-first `.vdraft` project bundles backed by SQLite

## Current Scope

This repository currently documents and ships:

- Windows desktop runtime
- local project bundle workflow
- shot editing and storyboard browsing
- shooting plan organization
- PDF / Excel export and Windows print flow

This repository does **not** publicly promise unfinished Android delivery.

## Quick Start

### Requirements

- Flutter `3.41.9`
- Dart `3.11.5`
- Visual Studio 2022 Build Tools
- Windows development environment

### Run in development

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

## Build for Windows

Use the repository build script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

Build output:

```text
dist/windows/
```

Entry executable:

```text
dist/windows/vision_draft.exe
```

Installer script:

```text
scripts/visiondraft_setup.iss
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

## Project Structure

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

## Validation

Recommended validation before submitting changes:

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

Generated directories such as `dist/`, `build/`, `.dart_tool/`, `tmp_build/`, and `tmp_run_logs/` should not be committed.

## Roadmap

Near-term priorities:

- keep stabilizing the Windows desktop workflow
- improve export polish and print predictability
- harden data editing and recovery flows
- expand performance validation for larger storyboard projects

## License

No formal license file has been published in this repository yet.
