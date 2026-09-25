import 'package:flutter/material.dart';

import '../services/user_service.dart';
import 'signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final user = await _userService.getSavedUser();
    if (!mounted) return;

    // Enhancement 1: persisted authentication decides the first screen.
    Navigator.of(context).pushReplacementNamed(
      user == null ? SignInScreen.routeName : '/home',
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary, colors.tertiary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor: colors.surface,
                foregroundColor: colors.primary,
                child: const Icon(Icons.storefront_rounded, size: 56),
              ),
              const SizedBox(height: 20),
              Text(
                'NUBD Exchange',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              CircularProgressIndicator(color: colors.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
