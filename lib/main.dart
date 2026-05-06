import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _writeBootstrapLog(
          'FLUTTER_ERROR\n${details.exceptionAsString()}\n${details.stack}',
        );
      };

      ErrorWidget.builder = (details) {
        _writeBootstrapLog(
          'ERROR_WIDGET\n${details.exceptionAsString()}\n${details.stack}',
        );
        return Material(
          color: const Color(0xFFF7F8FB),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E4EC)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VisionDraft 启动失败',
                          style: ThemeData.light().textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          details.exceptionAsString(),
                          style: ThemeData.light().textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _writeBootstrapLog('PLATFORM_ERROR\n$error\n$stack');
        return false;
      };

      runApp(const ProviderScope(child: VisionDraftApp()));
    },
    (error, stack) {
      _writeBootstrapLog('ZONE_ERROR\n$error\n$stack');
    },
  );
}

void _writeBootstrapLog(String message) {
  try {
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}visiondraft_bootstrap.log',
    );
    final timestamp = DateTime.now().toIso8601String();
    file.writeAsStringSync(
      '[$timestamp] $message\n\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {
    // Swallow bootstrap logging failures to avoid masking the real startup error.
  }
}
