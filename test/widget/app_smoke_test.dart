import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_draft/app/app.dart';
import 'package:vision_draft/app/bootstrap/providers.dart';
import 'package:vision_draft/features/project_library/application/project_library_controller.dart';
import 'package:vision_draft/features/project_library/domain/project_library_models.dart';

void main() {
  testWidgets('renders project library entry point', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectLibraryProvider.overrideWith(
            () => _FakeProjectLibraryController(),
          ),
        ],
        child: const VisionDraftApp(),
      ),
    );
    await tester.pump();

    expect(find.text('我的项目'), findsOneWidget);
    expect(find.text('搜索项目名称'), findsOneWidget);
    expect(find.text('测试项目'), findsOneWidget);
  });
}

class _FakeProjectLibraryController extends ProjectLibraryController {
  @override
  ProjectLibraryState build() {
    return const ProjectLibraryState(
      projects: [
        ProjectLibraryEntry(
          id: 'project-test',
          name: '测试项目',
          path: 'E:/visiondraft/test-project.vdraft',
          updatedAtLabel: '今天 12:00',
        ),
      ],
      isLoading: false,
    );
  }
}
