import 'package:flutter/material.dart';

import 'product_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _pages = [
    ProductScreen(),
    _ComingSoonScreen(label: 'Messages'),
    _ComingSoonScreen(label: 'Profile'),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        centerTitle: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$label screen'));
  }
}
