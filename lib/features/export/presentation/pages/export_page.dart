import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../app/bootstrap/providers.dart';
import '../../../project_workspace/domain/models/export_payload.dart';
import '../../../project_workspace/domain/queries/project_workspace_snapshot.dart';
import '../../../storyboard_editor/application/editor_grid_session.dart';

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  final Set<ExportDocumentType> _busyTypes = <ExportDocumentType>{};
  late final TextEditingController _brandNameController;
  late final TextEditingController _brandTaglineController;

  ExportDocumentType _selectedType = ExportDocumentType.shotSheet;
  String? _lastSavedPath;
  String? _brandLogoPath;
  bool _showDefaultBrandLogo = true;

  static const _pdfTypeGroup = XTypeGroup(label: 'PDF', extensions: ['pdf']);
  static const _imageTypeGroup = XTypeGroup(
    label: 'Images',
    extensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
  );

  @override
  void initState() {
    super.initState();
    _brandNameController = TextEditingController(text: 'VisionDraft');
    _brandTaglineController = TextEditingController(text: '影视策划与前置统筹');
    _brandNameController.addListener(_handleBrandingChanged);
    _brandTaglineController.addListener(_handleBrandingChanged);
  }

  @override
  void dispose() {
    _brandNameController.removeListener(_handleBrandingChanged);
    _brandTaglineController.removeListener(_handleBrandingChanged);
    _brandNameController.dispose();
    _brandTaglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(workspaceControllerProvider(widget.projectId));
    final gridSession = ref.watch(editorGridSessionProvider(widget.projectId));

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1180;
        final previewFilename = _filenameFor(_selectedType, snapshot);
        final previewKey = [
          _selectedType.name,
          previewFilename,
          _brandLogoPath ?? '',
          _showDefaultBrandLogo ? 'default-logo' : 'no-default-logo',
          _brandNameController.text,
          _brandTaglineController.text,
        ].join('|');

        final sidebar = _ExportSidebar(
          snapshot: snapshot,
          selectedType: _selectedType,
          lastSavedPath: _lastSavedPath,
          brandNameController: _brandNameController,
          brandTaglineController: _brandTaglineController,
          brandLogoPath: _brandLogoPath,
          showDefaultBrandLogo: _showDefaultBrandLogo,
          busyTypes: _busyTypes,
          onTypeSelected: (type) {
            if (_selectedType == type) {
              return;
            }
            setState(() {
              _selectedType = type;
            });
          },
          onGenerate: () => _exportDocument(_selectedType),
          onPrint: () => _printDocument(_selectedType),
          onShare: () => _shareDocument(_selectedType),
          onPickLogo: _pickBrandLogo,
          onClearBranding: _clearBranding,
          onResetBranding: _resetBranding,
          onBrandingChanged: _handleBrandingChanged,
          titleForType: _titleForType,
          subtitleForType: _subtitleForType,
          iconForType: _iconForType,
        );

        final preview = _ExportPreviewPanel(
          previewKey: previewKey,
          title: _titleForType(_selectedType),
          filename: previewFilename,
          buildPreview: () => ref
              .read(pdfExportServiceProvider)
              .generate(_buildPayload(_selectedType, snapshot, gridSession)),
        );

        if (compact) {
          return Column(
            children: [
              SizedBox(height: 520, child: sidebar),
              const SizedBox(height: 12),
              Expanded(child: preview),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 340, child: sidebar),
            const SizedBox(width: 12),
            Expanded(child: preview),
          ],
        );
      },
    );
  }

  ExportPayload _buildPayload(
    ExportDocumentType type,
    ProjectWorkspaceSnapshot snapshot,
    EditorGridSessionState gridSession,
  ) {
    final brandName = _brandNameController.text.trim();
    final tagline = _brandTaglineController.text.trim();
    final hasCustomLogo = _brandLogoPath != null && _brandLogoPath!.isNotEmpty;
    final effectiveShowDefaultLogo =
        _showDefaultBrandLogo &&
        (brandName.isNotEmpty || tagline.isNotEmpty || hasCustomLogo);

    return ExportPayload(
      bundle: snapshot.bundle,
      shots: snapshot.shots,
      columnPreset: snapshot.columnPreset,
      effectiveFieldOrderKeys: gridSession.effectiveFieldOrderKeys,
      effectiveColumnWidths: gridSession.columnWidthsByFieldKey,
      effectiveRowHeights: gridSession.rowHeightsByShotId,
      fieldLabelsByKey: {
        for (final column in snapshot.customColumns)
          column.fieldKey: column.name,
      },
      branding: ExportBranding(
        brandName: brandName,
        tagline: tagline,
        showDefaultLogo: effectiveShowDefaultLogo,
        logoPath: _brandLogoPath,
      ),
      boardPreset: snapshot.boardPreset,
      planBoard: snapshot.planBoard,
      callSheet: snapshot.callSheet,
      documentType: type,
    );
  }

  Future<void> _pickBrandLogo() async {
    final file = await openFile(
      acceptedTypeGroups: const [_imageTypeGroup],
      confirmButtonText: '选择 Logo',
    );
    if (file == null || file.path.isEmpty) {
      return;
    }
    setState(() {
      _brandLogoPath = file.path;
      _showDefaultBrandLogo = false;
    });
  }

  void _handleBrandingChanged() {
    final brandNameCleared = _brandNameController.text.trim().isEmpty;
    final taglineCleared = _brandTaglineController.text.trim().isEmpty;
    final brandingCleared =
        (_brandLogoPath == null || _brandLogoPath!.isEmpty) &&
        brandNameCleared &&
        taglineCleared;

    setState(() {
      if (brandingCleared) {
        _showDefaultBrandLogo = false;
      }
    });
  }

  void _clearBranding() {
    setState(() {
      _brandLogoPath = null;
      _showDefaultBrandLogo = false;
      _brandNameController.clear();
      _brandTaglineController.clear();
    });
  }

  void _resetBranding() {
    setState(() {
      _brandLogoPath = null;
      _showDefaultBrandLogo = true;
      _brandNameController.text = 'VisionDraft';
      _brandTaglineController.text = '影视策划与前置统筹';
    });
  }

  Future<void> _exportDocument(ExportDocumentType type) async {
    await _runDocumentAction(
      type,
      action: (bytes, payload, filename) async {
        final file = await _savePdfAs(
          bytes: bytes,
          filename: filename,
          initialDirectory: payload.bundle.rootPath,
        );
        if (file == null || !mounted) {
          return;
        }
        setState(() {
          _lastSavedPath = file.path;
        });
        _showSnackBar('已导出到 ${file.path}');
      },
    );
  }

  Future<void> _printDocument(ExportDocumentType type) async {
    await _runDocumentAction(
      type,
      action: (bytes, payload, filename) async {
        await ref.read(printServiceProvider).layoutPdf(bytes, name: filename);
        _showSnackBar('已发送到系统打印流程');
      },
    );
  }

  Future<void> _shareDocument(ExportDocumentType type) async {
    await _runDocumentAction(
      type,
      action: (bytes, payload, filename) async {
        if (defaultTargetPlatform == TargetPlatform.windows) {
          final file = await _savePdfAs(
            bytes: bytes,
            filename: filename,
            initialDirectory: payload.bundle.rootPath,
          );
          if (file == null || !mounted) {
            return;
          }
          setState(() {
            _lastSavedPath = file.path;
          });
          _showSnackBar('已保存到 ${file.path}');
          return;
        }

        await ref
            .read(printServiceProvider)
            .sharePdf(
              bytes,
              filename: filename,
              subject: '${payload.bundle.name} - ${_titleForType(type)}',
              body: '来自 VisionDraft 的导出文件',
            );
        _showSnackBar('已调用系统分享');
      },
    );
  }

  Future<void> _runDocumentAction(
    ExportDocumentType type, {
    required Future<void> Function(
      Uint8List bytes,
      ExportPayload payload,
      String filename,
    )
    action,
  }) async {
    if (_busyTypes.contains(type)) {
      return;
    }

    setState(() {
      _busyTypes.add(type);
    });

    try {
      final snapshot = ref.read(workspaceControllerProvider(widget.projectId));
      final gridSession = ref.read(editorGridSessionProvider(widget.projectId));
      final payload = _buildPayload(type, snapshot, gridSession);
      final filename = _filenameFor(type, snapshot);
      final bytes = await ref.read(pdfExportServiceProvider).generate(payload);
      await action(bytes, payload, filename);
    } catch (error) {
      if (mounted) {
        _showSnackBar('导出失败：$error', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyTypes.remove(type);
        });
      }
    }
  }

  Future<File?> _savePdfAs({
    required List<int> bytes,
    required String filename,
    required String initialDirectory,
  }) async {
    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: const [_pdfTypeGroup],
      initialDirectory: initialDirectory,
      suggestedName: filename,
      confirmButtonText: '导出 PDF',
      canCreateDirectories: true,
    );
    if (saveLocation == null) {
      return null;
    }

    final file = File(saveLocation.path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _filenameFor(
    ExportDocumentType type,
    ProjectWorkspaceSnapshot snapshot,
  ) {
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final safeName = snapshot.bundle.name.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );
    return '$safeName-${_slugForType(type)}-$stamp.pdf';
  }

  String _titleForType(ExportDocumentType type) {
    return switch (type) {
      ExportDocumentType.shotSheet => '分镜单',
      ExportDocumentType.shootingPlan => '拍摄计划单',
      ExportDocumentType.callSheet => '拍摄通告单',
    };
  }

  String _slugForType(ExportDocumentType type) {
    return switch (type) {
      ExportDocumentType.shotSheet => 'shot-sheet',
      ExportDocumentType.shootingPlan => 'shooting-plan',
      ExportDocumentType.callSheet => 'call-sheet',
    };
  }

  IconData _iconForType(ExportDocumentType type) {
    return switch (type) {
      ExportDocumentType.shotSheet => Icons.table_chart_outlined,
      ExportDocumentType.shootingPlan => Icons.schedule_outlined,
      ExportDocumentType.callSheet => Icons.description_outlined,
    };
  }

  String _subtitleForType(
    ExportDocumentType type,
    ProjectWorkspaceSnapshot snapshot,
  ) {
    return switch (type) {
      ExportDocumentType.shotSheet => '${snapshot.shots.length} 镜头，按当前活动列布局导出',
      ExportDocumentType.shootingPlan =>
        '${snapshot.planBoard.sections.length} 个区块，含未规划镜头',
      ExportDocumentType.callSheet =>
        '${snapshot.callSheet.sectionSummaries.length} 条摘要，现场执行稿',
    };
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.errorContainer
            : null,
      ),
    );
  }
}

class _ExportSidebar extends StatelessWidget {
  const _ExportSidebar({
    required this.snapshot,
    required this.selectedType,
    required this.lastSavedPath,
    required this.brandNameController,
    required this.brandTaglineController,
    required this.brandLogoPath,
    required this.showDefaultBrandLogo,
    required this.busyTypes,
    required this.onTypeSelected,
    required this.onGenerate,
    required this.onPrint,
    required this.onShare,
    required this.onPickLogo,
    required this.onClearBranding,
    required this.onResetBranding,
    required this.onBrandingChanged,
    required this.titleForType,
    required this.subtitleForType,
    required this.iconForType,
  });

  final ProjectWorkspaceSnapshot snapshot;
  final ExportDocumentType selectedType;
  final String? lastSavedPath;
  final TextEditingController brandNameController;
  final TextEditingController brandTaglineController;
  final String? brandLogoPath;
  final bool showDefaultBrandLogo;
  final Set<ExportDocumentType> busyTypes;
  final ValueChanged<ExportDocumentType> onTypeSelected;
  final VoidCallback onGenerate;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final Future<void> Function() onPickLogo;
  final VoidCallback onClearBranding;
  final VoidCallback onResetBranding;
  final VoidCallback onBrandingChanged;
  final String Function(ExportDocumentType type) titleForType;
  final String Function(
    ExportDocumentType type,
    ProjectWorkspaceSnapshot snapshot,
  )
  subtitleForType;
  final IconData Function(ExportDocumentType type) iconForType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = busyTypes.contains(selectedType);

    return _PanelFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('导出与打印', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '右侧预览与最终导出保持一致。每次导出都会先让你选择保存位置。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final type in ExportDocumentType.values) ...[
                    _DocumentTypeTile(
                      title: titleForType(type),
                      subtitle: subtitleForType(type, snapshot),
                      icon: iconForType(type),
                      selected: type == selectedType,
                      onTap: () => onTypeSelected(type),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : onGenerate,
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('导出 PDF'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isBusy ? null : onPrint,
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('打印'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isBusy ? null : onShare,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('分享'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _BrandingCard(
                    logoPath: brandLogoPath,
                    showDefaultLogo: showDefaultBrandLogo,
                    brandNameController: brandNameController,
                    brandTaglineController: brandTaglineController,
                    onPickLogo: onPickLogo,
                    onClear: onClearBranding,
                    onReset: onResetBranding,
                    onChanged: onBrandingChanged,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: '项目', value: snapshot.bundle.name),
                  _InfoRow(label: '镜头数', value: '${snapshot.shots.length}'),
                  _InfoRow(
                    label: '计划区块',
                    value: '${snapshot.planBoard.sections.length}',
                  ),
                  _InfoRow(
                    label: '最近导出',
                    value: lastSavedPath == null
                        ? '暂无'
                        : File(lastSavedPath!).path,
                    multiline: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportPreviewPanel extends StatelessWidget {
  const _ExportPreviewPanel({
    required this.previewKey,
    required this.title,
    required this.filename,
    required this.buildPreview,
  });

  final String previewKey;
  final String title;
  final String filename;
  final Future<Uint8List> Function() buildPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PDF 预览', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '$title · $filename',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerLowest,
                child: PdfPreview(
                  key: ValueKey(previewKey),
                  build: (_) => buildPreview(),
                  pdfFileName: filename,
                  initialPageFormat: PdfPageFormat.a4,
                  allowPrinting: false,
                  allowSharing: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  useActions: false,
                  shouldRepaint: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  previewPageMargin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  maxPageWidth: 1200,
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onError: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('预览生成失败：$error'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTypeTile extends StatelessWidget {
  const _DocumentTypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.5)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? scheme.primary : null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: selected ? scheme.primary : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelFrame extends StatelessWidget {
  const _PanelFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _BrandingCard extends StatelessWidget {
  const _BrandingCard({
    required this.logoPath,
    required this.showDefaultLogo,
    required this.brandNameController,
    required this.brandTaglineController,
    required this.onPickLogo,
    required this.onClear,
    required this.onReset,
    required this.onChanged,
  });

  final String? logoPath;
  final bool showDefaultLogo;
  final TextEditingController brandNameController;
  final TextEditingController brandTaglineController;
  final Future<void> Function() onPickLogo;
  final VoidCallback onClear;
  final VoidCallback onReset;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasCustomLogo = logoPath != null && logoPath!.isNotEmpty;
    final showsAnyLogo = hasCustomLogo || showDefaultLogo;
    final hasBrandName = brandNameController.text.trim().isNotEmpty;
    final hasBrandTagline = brandTaglineController.text.trim().isNotEmpty;
    final stateLabel = hasCustomLogo
        ? '自定义品牌'
        : showDefaultLogo
        ? '默认品牌'
        : '空白品牌';
    final stateDescription = hasCustomLogo
        ? '使用你的自定义 Logo，导出时会按当前品牌名称和文案显示。'
        : showDefaultLogo
        ? '使用 VisionDraft 默认图标，可继续修改名称和文案。'
        : '当前不显示 Logo。名称和品牌文案也留空时，导出顶部会保持空白。';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '品牌区',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              stateLabel,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              stateDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showsAnyLogo) ...[
                  _LogoPreview(
                    logoPath: logoPath,
                    showDefaultLogo: showDefaultLogo,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showsAnyLogo ? 'Logo 已启用' : 'Logo 已关闭',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onPickLogo,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('选择 Logo'),
                          ),
                          OutlinedButton.icon(
                            onPressed: onClear,
                            icon: const Icon(Icons.clear_rounded),
                            label: const Text('清空'),
                          ),
                          OutlinedButton.icon(
                            onPressed: onReset,
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('恢复默认'),
                          ),
                        ],
                      ),
                      if (!showsAnyLogo &&
                          !hasBrandName &&
                          !hasBrandTagline) ...[
                        const SizedBox(height: 8),
                        Text(
                          '当前导出顶部品牌区为空白。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brandNameController,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: '品牌名称',
                hintText: 'VisionDraft',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: brandTaglineController,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: '品牌文案',
                hintText: '影视策划与前置统筹',
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.logoPath, required this.showDefaultLogo});

  final String? logoPath;
  final bool showDefaultLogo;

  @override
  Widget build(BuildContext context) {
    final path = logoPath;
    if (path != null && path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(path),
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _DefaultLogoBox(),
        ),
      );
    }

    if (showDefaultLogo) {
      return const _DefaultLogoBox();
    }

    return const SizedBox.shrink();
  }
}

class _DefaultLogoBox extends StatelessWidget {
  const _DefaultLogoBox();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        ),
        child: Image.asset(
          'assets/branding/default_logo.png',
          width: 54,
          height: 54,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: multiline ? null : 1,
            overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
