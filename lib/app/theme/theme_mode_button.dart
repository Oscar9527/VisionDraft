import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/providers.dart';

class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return PopupMenuButton<ThemeMode>(
      tooltip: '切换显示模式',
      initialValue: themeMode,
      onSelected: (value) {
        ref.read(themeModeControllerProvider.notifier).setThemeMode(value);
      },
      itemBuilder: (context) => [
        CheckedPopupMenuItem<ThemeMode>(
          value: ThemeMode.light,
          checked: themeMode == ThemeMode.light,
          child: const Text('浅色模式'),
        ),
        CheckedPopupMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          checked: themeMode == ThemeMode.dark,
          child: const Text('深色模式'),
        ),
        CheckedPopupMenuItem<ThemeMode>(
          value: ThemeMode.system,
          checked: themeMode == ThemeMode.system,
          child: const Text('跟随系统'),
        ),
      ],
      icon: Icon(_iconFor(themeMode), size: compact ? 18 : 20),
      splashRadius: compact ? 18 : 20,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: compact ? 30 : 34,
        height: compact ? 30 : 34,
      ),
    );
  }

  IconData _iconFor(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };
  }
}
