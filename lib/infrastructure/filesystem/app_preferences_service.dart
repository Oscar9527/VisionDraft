import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'app_storage_service.dart';

class AppPreferencesService {
  AppPreferencesService({required AppStorageService storageService})
    : _storageService = storageService;

  final AppStorageService _storageService;

  static const _settingsFileName = 'app_settings.json';
  static const _themeModeKey = 'themeMode';

  Future<ThemeMode> loadThemeMode() async {
    final file = await _resolveSettingsFile();
    if (!await file.exists()) {
      return ThemeMode.system;
    }

    try {
      final raw = jsonDecode(await file.readAsString());
      if (raw is Map<String, dynamic>) {
        return _decodeThemeMode(raw[_themeModeKey] as String?);
      }
      if (raw is Map) {
        return _decodeThemeMode(raw[_themeModeKey]?.toString());
      }
    } catch (_) {
      return ThemeMode.system;
    }

    return ThemeMode.system;
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final file = await _resolveSettingsFile();
    final payload = await _readExistingSettings(file);
    payload[_themeModeKey] = _encodeThemeMode(themeMode);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
  }

  Future<File> _resolveSettingsFile() async {
    final paths = await _storageService.resolve();
    return File(p.join(paths.supportDirectory.path, _settingsFileName));
  }

  Future<Map<String, dynamic>> _readExistingSettings(File file) async {
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final raw = jsonDecode(await file.readAsString());
      if (raw is Map<String, dynamic>) {
        return raw;
      }
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  String _encodeThemeMode(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  ThemeMode _decodeThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
