import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'signup_screen.dart';

enum _LoginMode { firebase, dummyJson }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const routeName = '/signin';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  _LoginMode _mode = _LoginMode.firebase;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setMode(_LoginMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _identifierController.text = mode == _LoginMode.dummyJson ? 'emilys' : '';
      _passwordController.text = mode == _LoginMode.dummyJson
          ? 'emilyspass'
          : '';
    });
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final User user;
      if (_mode == _LoginMode.firebase) {
        final credential = await _userService.signIn(
          email: _identifierController.text.trim(),
          password: _passwordController.text,
        );
        final firebaseUser = credential.user!;
        user =
            (await _userService.getUserData()) ??
            User(
              id: 0,
              username: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
              firstName: '',
              lastName: '',
              gender: '',
              image: firebaseUser.photoURL ?? '',
              accessToken: '',
              refreshToken: '',
              loginType: LoginType.firebase,
              firebaseUid: firebaseUser.uid,
            );
        await _userService.saveUserData(user);
      } else {
        user = await _userService.loginUser(
          _identifierController.text.trim(),
          _passwordController.text,
        );
      }
      if (!mounted) return;
      // Lab 5 Enhancement 2: Firebase and DummyJSON use separate login paths.
      Navigator.of(context).pushReplacementNamed('/home', arguments: user);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFirebase = _mode == _LoginMode.firebase;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: const Icon(Icons.lock_person_rounded, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    // Enhancement 2: makes the DummyJSON and Firebase flows visible.
                    SegmentedButton<_LoginMode>(
                      segments: const [
                        ButtonSegment(
                          value: _LoginMode.firebase,
                          icon: Icon(Icons.cloud_outlined),
                          label: Text('Firebase'),
                        ),
                        ButtonSegment(
                          value: _LoginMode.dummyJson,
                          icon: Icon(Icons.api_outlined),
                          label: Text('DummyJSON'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (selection) =>
                          _setMode(selection.single),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: isFirebase
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: isFirebase ? 'Email address' : 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final identifier = value?.trim() ?? '';
                        if (identifier.isEmpty) {
                          return isFirebase
                              ? 'Enter your email address.'
                              : 'Enter your username.';
                        }
                        if (isFirebase && !identifier.contains('@')) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Use at least 6 characters.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Log in'),
                    ),
                    if (isFirebase) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(
                                context,
                              ).pushNamed(SignUpScreen.routeName),
                        child: const Text('Create a Firebase account'),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text(
                        'Demo: emilys / emilyspass',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
