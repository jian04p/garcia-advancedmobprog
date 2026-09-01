import 'package:flutter/material.dart';

import 'cart_screen.dart';
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
    CartScreen(),
    _ComingSoonScreen(label: 'Profile'),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Commerce App'), centerTitle: false),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // Lab Activity 3 Enhancement 2: chat moved from the bottom bar to this FAB.
      floatingActionButton: _selectedIndex == 1
          ? null
          : FloatingActionButton(
              tooltip: 'Chat',
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const _ChatScreen())),
              child: const Icon(Icons.chat_bubble_outline),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Shop'),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ChatScreen extends StatelessWidget {
  const _ChatScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(child: Text('Messages screen')),
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
