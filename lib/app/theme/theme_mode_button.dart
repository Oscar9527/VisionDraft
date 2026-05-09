import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/providers.dart';

class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    final brightness = Theme.of(context).brightness;
    final effectiveDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final nextMode = effectiveDark ? ThemeMode.light : ThemeMode.dark;
    final icon = effectiveDark
        ? Icons.dark_mode_rounded
        : Icons.light_mode_rounded;
    final label = effectiveDark ? '深色' : '浅色';
    final tooltip = effectiveDark ? '切换到浅色模式' : '切换到深色模式';

    if (compact) {
      return IconButton(
        tooltip: tooltip,
        onPressed: () {
          ref.read(themeModeControllerProvider.notifier).setThemeMode(nextMode);
        },
        icon: Icon(icon, size: 18),
        splashRadius: 18,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 30, height: 30),
        visualDensity: VisualDensity.compact,
      );
    }

    return OutlinedButton.icon(
      onPressed: () {
        ref.read(themeModeControllerProvider.notifier).setThemeMode(nextMode);
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 36),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
