import 'package:flutter/material.dart';

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

    return Row(
      children: [
        IconButton(
          tooltip: '返回项目库',
          onPressed: onBackPressed,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            projectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: WorkspaceSection.values.map((section) {
                final selected = section == activeSection;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _SectionTab(
                    label: section.label,
                    selected: selected,
                    onPressed: () => onSectionSelected(section),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onExportPressed,
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: const Text('导出'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            foregroundColor: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
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
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
