import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'product_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ProductScreen(userId: widget.user.id),
      CartScreen(userId: widget.user.id),
      ProfileScreen(user: widget.user, onLogout: _logout),
      const SettingsScreen(),
    ];
  }

  Future<void> _logout() async {
    await UserService().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 1
              ? 'Cart'
              : _selectedIndex == 2
              ? widget.user.firstName
              : 'E-Commerce App',
        ),
        centerTitle: false,
        actions: _selectedIndex == 1
            ? [
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => setState(() => _selectedIndex = 3),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ]
            : null,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // Lab Activity 3 enhancement: chat is hidden while the cart is selected.
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
