import 'package:flutter/material.dart';

import '../../../../core/widgets/surface_card.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('拍摄通告与导出', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ExportTile(title: '故事板联系表', icon: Icons.view_module_outlined),
              _ExportTile(title: '拍摄计划单', icon: Icons.schedule_outlined),
              _ExportTile(title: '拍摄通告单', icon: Icons.description_outlined),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '项目级模板和字段设置会直接影响这里的 PDF 输出。Android 端通过系统分享或打印，Windows 端直接走系统打印。',
          ),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {},
                child: const Text('生成 PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
