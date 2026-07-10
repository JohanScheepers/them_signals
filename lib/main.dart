import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Single initialization point for all app state.
  // Defaults to ThemeMode.system so the OS controls the theme
  // until the user explicitly picks one.
  await MyAppState.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the MaterialApp inside a SignalBuilder
    return SignalBuilder(
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Theme_Signals Demo',
          // 2. Use .value to automatically track the signal
          themeMode: MyAppState.instance.themeMode.value,
          theme: MyAppTheme.lightTheme,
          darkTheme: MyAppTheme.darkTheme,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _themeOptions = [
    (
      label: 'System Theme',
      icon: Icons.brightness_auto,
      mode: ThemeMode.system,
    ),
    (label: 'Light Theme', icon: Icons.light_mode, mode: ThemeMode.light),
    (label: 'Dark Theme', icon: Icons.dark_mode, mode: ThemeMode.dark),
  ];

  @override
  Widget build(BuildContext context) {
    final currentMode = MyAppState.instance.themeMode.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Theme_Signals Demo'),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Select theme',
            icon: Icon(switch (currentMode) {
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
              ThemeMode.system => Icons.brightness_auto,
            }),
            initialValue: currentMode,
            onSelected: MyAppState.instance.setThemeMode,
            itemBuilder: (context) => _themeOptions
                .map(
                  (option) => PopupMenuItem<ThemeMode>(
                    value: option.mode,
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          color: currentMode == option.mode
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option.label,
                          style: currentMode == option.mode
                              ? TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Text(
                'Theme is persisted across app restarts!\nCurrent mode: ${currentMode.name}',
                textAlign: TextAlign.center,
              )
            ],
        ),
      ),
    );
  }
}

/// A [SignalsKeyValueStore] backed by [SharedPreferences].
class SharedPreferencesStore implements SignalsKeyValueStore {
  final SharedPreferences prefs;
  SharedPreferencesStore(this.prefs);

  @override
  Future<String?> getItem(String key) async => prefs.getString(key);

  @override
  Future<void> removeItem(String key) async => prefs.remove(key);

  @override
  Future<void> setItem(String key, String value) async =>
      prefs.setString(key, value);
}

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

final class MyAppTheme {
  MyAppTheme._();
  static ThemeData get lightTheme {
    return ThemeData(useMaterial3: true, brightness: Brightness.light);
  }

  static ThemeData get darkTheme {
    return ThemeData(useMaterial3: true, brightness: Brightness.dark);
  }
}
