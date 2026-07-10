# Flawless Flutter Theme Toggling with Signals and SharedPreferences.

If you are looking for a lightweight, declarative way to handle theme switching and disk persistence in Flutter without a massive footprint, Signals is a fantastic choice.

Using signals_flutter and shared_preferences, we can build a type-safe, reactive theme manager that automatically saves changes to disk on mutation and instantly paints updates across your widget tree. Let’s look at how to set up this architecture step-by-step.


In this article, we will build a production-ready, clean, and modern theme toggler using a unified AppState and PersistedEnumSignal.

Why Signals?
Before jumping into the code, let’s quickly look at why signals_flutter is a fantastic alternative for state management:

* Fine-Grained Reactivity: Instead of rebuilding the entire widget tree (like traditional setState), Signals automatically track dependencies and only trigger updates where the values are explicitly read.

* Minimal Boilerplate: No actions, mutations, or complex state events to configure. You read a .value or assign a new .value, and the framework does the heavy lifting.

* Built-in Persistence: The ecosystem includes native abstractions to sync local storage smoothly without locking your UI or forcing you to handle async delays inside your build methods.

Step 1: Connecting Signals to Local Storage

Signals provides a contract called SignalsKeyValueStore. By implementing this interface, we can redirect signal updates straight into SharedPreferences.

```dart
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
```

This tiny bridge enables the PersistedEnumSignal to read saved settings on startup and save modifications immediately upon mutation.

Step 2: The App State Singleton

Instead of polluting the global namespace or drilling parameters through widgets, we create a unified, single source of truth called MyAppState.


```Dart
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
```

Key Advantages:
1. **Asynchronous Safety:** By executing AppState.instance.initialize() inside your main() method, we ensure that the stored configuration is fully loaded before the application starts painting.

2. **Type Safety:** PersistedEnumSignal handles the serialization and deserialization of Dart Enums seamlessly. You don't have to map strings manually back into ThemeMode.dark.

Step 3: Bootstrapping and Global Application Setup

In our entry point, we ensure Flutter bindings are configured and then initialize our state. Next, we wrap MaterialApp with a SignalBuilder.

```Dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Single initialization point for all app state.
  // Defaults to ThemeMode.system so the OS controls the theme
  // until the user explicitly picks one.
  await AppState.instance.initialize();
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
          themeMode: AppState.instance.themeMode.value,
          theme: MyAppTheme.lightTheme,
          darkTheme: MyAppTheme.darkTheme,
          home: const MyHomePage(),
        );
      },
    );
  }
}

// Simple decoupled theme data configurations
final class MyAppTheme {
  MyAppTheme._();
  static ThemeData get lightTheme => ThemeData(useMaterial3: true, brightness: Brightness.light);
  static ThemeData get darkTheme => ThemeData(useMaterial3: true, brightness: Brightness.dark);
}
```

Notice how clean the MaterialApp is. By reading AppState.instance.themeMode.value, SignalBuilder registers a listener automatically. Whenever the theme changes anywhere in the app, this builder will fire up instantly and apply the new configuration.

Step 4: Putting it Together with a UI Toggler

To let users switch themes, we can implement a PopupMenuButton in our MyHomePage view. The UI checks the reactive value to showcase active checkmarks/colors and calls setThemeMode when tapped.


```Dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _themeOptions = [
    (label: 'System Theme', icon: Icons.brightness_auto, mode: ThemeMode.system),
    (label: 'Light Theme', icon: Icons.light_mode, mode: ThemeMode.light),
    (label: 'Dark Theme', icon: Icons.dark_mode, mode: ThemeMode.dark),
  ];

  @override
  Widget build(BuildContext context) {
    // Access the current value reactively
    final currentMode = AppState.instance.themeMode.value;

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
            onSelected: AppState.instance.setThemeMode,
            itemBuilder: (context) => _themeOptions.map((option) {
              final isSelected = currentMode == option.mode;
              return PopupMenuItem<ThemeMode>(
                value: option.mode,
                child: Row(
                  children: [
                    Icon(
                      option.icon,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      option.label,
                      style: isSelected ? TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ) : null,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Theme is persisted across app restarts!\nCurrent mode: ${currentMode.name}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
```

Wrapping Up
With under 150 lines of incredibly readable code, we managed to:

1. Initialize a global storage adapter.

2. Bind theme changes directly to internal system configurations.

3. Automatically serialize enums down to disk storage.

4. Eliminate boilerplate wrappers from our widget layouts.

Signals provide a modern, explicit, and highly performant paradigm for building stateful Flutter apps without the weight of overly structured frameworks.

Have you tried Signals in your Flutter workflows yet? Let me know your thoughts down in the comments below!


Full code at [theme_signals](https://github.com/JohanScheepers/them_signals)