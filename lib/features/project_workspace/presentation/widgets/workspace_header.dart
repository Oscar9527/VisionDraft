import 'package:flutter/material.dart';

import '../../../../app/theme/theme_mode_button.dart';
import '../pages/project_workspace_page.dart';

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({
    super.key,
    required this.projectName,
    required this.activeSection,
    required this.onBackPressed,
    required this.onSectionSelected,
    required this.onExportPressed,
  });

  final String projectName;
  final WorkspaceSection activeSection;
  final VoidCallback onBackPressed;
  final ValueChanged<WorkspaceSection> onSectionSelected;
  final VoidCallback onExportPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmedProjectName = projectName.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactTabs = constraints.maxWidth < 1260;
        return Row(
          children: [
            IconButton(
              tooltip: '返回项目库',
              onPressed: onBackPressed,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
            if (trimmedProjectName.isNotEmpty) ...[
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: compactTabs ? 120 : 180),
                child: Tooltip(
                  message: trimmedProjectName,
                  child: Text(
                    trimmedProjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: WorkspaceSection.values.map((section) {
                    final selected = section == activeSection;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _SectionTab(
                        label: section.label,
                        selected: selected,
                        compact: compactTabs,
                        onPressed: () => onSectionSelected(section),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const ThemeModeButton(compact: true),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              onPressed: onExportPressed,
              icon: const Icon(Icons.ios_share_rounded, size: 16),
              label: const Text('导出'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 28),
                foregroundColor: scheme.onSurface,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedColor = scheme.primary.withValues(alpha: 0.18);
    final borderColor = selected
        ? scheme.primary.withValues(alpha: 0.65)
        : Theme.of(context).dividerColor;

    return Material(
      color: selected ? selectedColor : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 9,
            vertical: compact ? 4 : 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check_rounded,
                  size: compact ? 12 : 13,
                  color: scheme.primary,
                ),
                SizedBox(width: compact ? 4 : 5),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? scheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
