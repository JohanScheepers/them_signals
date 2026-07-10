import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:them_signals/core/state/my_app_state.dart';
import 'package:them_signals/core/theme/my_app_theme.dart';
import 'package:them_signals/features/my_app/views/my_app_views.dart';

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
