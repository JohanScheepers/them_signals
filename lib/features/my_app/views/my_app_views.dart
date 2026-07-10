import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:them_signals/core/state/my_app_state.dart';
import 'package:them_signals/features/widgets/theme_selector.dart';

class MyHomePage extends SignalWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = MyAppState.instance.themeMode.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Theme_Signals Demo'),
        actions: [ThemeSelector()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Theme is persisted across app restarts!\nCurrent mode: ${currentMode.name}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
