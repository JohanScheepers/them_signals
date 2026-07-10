import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:them_signals/core/data/persistence/shared_preferences_store.dart';
import 'package:them_signals/main.dart';

/// Single source of truth for all persistent app state.
class MyAppState {
  MyAppState._();

  static final MyAppState instance = MyAppState._();

  // ── Theme ──────
  late final PersistedEnumSignal<ThemeMode> themeMode;

  /// Call once in [main] before [runApp].
  Future<void> initialize({ThemeMode systemTheme = ThemeMode.system}) async {
    final prefs = await SharedPreferences.getInstance();
    final store = SharedPreferencesStore(prefs);

    // Theme – persisted via signals store
    themeMode = PersistedEnumSignal<ThemeMode>(
      systemTheme,
      'app_theme_mode',
      ThemeMode.values,
      store: store,
    );
  }

  /// Switch between [ThemeMode.system], [ThemeMode.light], and [ThemeMode.dark].
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  /// Convenience toggle between light and dark (ignores system).
  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}
