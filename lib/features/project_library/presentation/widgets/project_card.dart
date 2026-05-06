import 'package:flutter/material.dart';

import '../../../../core/widgets/surface_card.dart';
import '../../domain/project_library_models.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onOpen,
  });

  final ProjectLibraryEntry project;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.folder_open_rounded, size: 42),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              project.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              project.updatedAtLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              project.path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
