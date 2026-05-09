import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_draft/app/bootstrap/providers.dart';
import 'package:vision_draft/app/theme/theme_mode_button.dart';
import 'package:vision_draft/app/theme/theme_mode_controller.dart';
import 'package:vision_draft/infrastructure/filesystem/app_preferences_service.dart';
import 'package:vision_draft/infrastructure/filesystem/app_storage_service.dart';

class _FakePreferencesService extends AppPreferencesService {
  _FakePreferencesService() : super(storageService: const AppStorageService());

  @override
  Future<ThemeMode> loadThemeMode() async => ThemeMode.system;

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {}
}

class _TestThemeModeController extends ThemeModeController {
  _TestThemeModeController(this.onSet) : super(_FakePreferencesService());

  final void Function(ThemeMode themeMode) onSet;

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    onSet(themeMode);
  }
}

void main() {
  testWidgets('theme toggle button switches dark to light', (tester) async {
    ThemeMode? capturedMode;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeControllerProvider.overrideWith(
            (ref) => _TestThemeModeController((mode) => capturedMode = mode),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: ThemeModeButton(compact: true)),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(capturedMode, ThemeMode.light);
  });
}
