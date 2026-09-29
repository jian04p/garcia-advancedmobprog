import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

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
            // Lab Activity 2 enhancement: theme control lives in Settings.
            title: const Text('Dark mode'),
            subtitle: const Text(
              'Use the dark color theme throughout the app.',
            ),
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDark,
            onChanged: themeProvider.toggleTheme,
          ),
        ),
        const SizedBox(height: 20),
        // Enhancement 3: logout is available in Settings and returns to login.
        FilledButton.icon(
          onPressed: () async => onLogout(),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
