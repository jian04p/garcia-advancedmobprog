import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const routeName = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final credential = await _userService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _userService.updateUsername(
        username: _usernameController.text.trim(),
      );
      final firebaseUser = credential.user!;
      final user = User(
        id: 0,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: '',
        image: firebaseUser.photoURL ?? '',
        accessToken: '',
        refreshToken: '',
        age: int.tryParse(_ageController.text.trim()),
        contactNo: _contactController.text.trim(),
        loginType: LoginType.firebase,
        firebaseUid: firebaseUser.uid,
      );
      await _userService.saveUserData(user);
      if (!mounted) return;
      // Enhancement 2: captures the required Firebase sign-up fields.
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (route) => false, arguments: user);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account creation failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Your profile details are stored locally while Firebase Auth secures your email and password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _requiredField(
                controller: _firstNameController,
                label: 'First name',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _requiredField(
                controller: _lastNameController,
                label: 'Last name',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _requiredField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final age = int.tryParse(value?.trim() ?? '');
                  return age == null || age < 1 || age > 120
                      ? 'Enter a valid age.'
                      : null;
                },
              ),
              const SizedBox(height: 14),
              _requiredField(
                controller: _contactController,
                label: 'Contact number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _requiredField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              _requiredField(
                controller: _emailController,
                label: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  return email.contains('@') ? null : 'Enter a valid email.';
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Use at least 6 characters.'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _createAccount,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Firebase account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requiredField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty
              ? 'Enter your ${label.toLowerCase()}.'
              : null,
    );
  }
}
