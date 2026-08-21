import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            // Enhancement 3: Theme control is moved to the settings screen.
            title: const Text('Dark mode'),
            subtitle: const Text('Use the dark color theme throughout the app.'),
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDark,
            onChanged: themeProvider.toggleTheme,
          ),
        ),
      ],
    );
  }
}
