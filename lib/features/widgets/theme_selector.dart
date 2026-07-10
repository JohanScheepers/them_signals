import 'package:flutter/material.dart';
import 'package:them_signals/core/state/my_app_state.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

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
    return PopupMenuButton<ThemeMode>(
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
    );
  }
}
