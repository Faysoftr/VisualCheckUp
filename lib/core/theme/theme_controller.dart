import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts the user's selected [ThemeMode] (system / light / dark).
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
      : super(initialMode);

  static const String _themeModeKey = 'visualcheckup_theme_mode_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModeKey);
    value = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}
