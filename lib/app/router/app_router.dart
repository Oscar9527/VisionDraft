import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/project_library/presentation/pages/project_library_page.dart';
import '../../features/project_workspace/presentation/pages/project_workspace_page.dart';

GoRouter buildAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/projects',
    overridePlatformDefaultLocation: true,
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '页面加载失败',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    SelectableText(state.error.toString()),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/projects'),
                      child: const Text('返回项目库'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/projects',
      ),
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
