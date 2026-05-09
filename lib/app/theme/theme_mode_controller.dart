import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/filesystem/app_preferences_service.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._preferencesService) : super(ThemeMode.system) {
    unawaited(_restore());
  }

  final AppPreferencesService _preferencesService;
  bool _hasLocalOverride = false;

  Future<void> _restore() async {
    final restoredMode = await _preferencesService.loadThemeMode();
    if (_hasLocalOverride) {
      return;
    }
    state = restoredMode;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _hasLocalOverride = true;
    if (state != themeMode) {
      state = themeMode;
    }
    await _preferencesService.saveThemeMode(themeMode);
  }
}
