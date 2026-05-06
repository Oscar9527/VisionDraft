import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/project_library/presentation/pages/project_library_page.dart';
import '../../features/project_workspace/presentation/pages/project_workspace_page.dart';

GoRouter buildAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/projects',
    routes: [
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectLibraryPage(),
        routes: [
          GoRoute(
            path: ':projectId',
            redirect: (context, state) {
              final projectId = state.pathParameters['projectId']!;
              return '/projects/$projectId/editor';
            },
          ),
          GoRoute(
            path: ':projectId/:section',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId']!;
              final section = WorkspaceSectionX.fromPath(
                state.pathParameters['section'],
              );
              return ProjectWorkspacePage(
                projectId: projectId,
                initialSection: section,
              );
            },
          ),
        ],
      ),
    ],
  );
}
