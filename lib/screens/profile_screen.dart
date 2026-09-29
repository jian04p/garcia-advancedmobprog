import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserData();
  }

  void _reloadProfile() {
    setState(() => _userFuture = _userService.getUserData());
  }

  Future<void> _updateUsername(User user) async {
    final controller = TextEditingController(text: user.username);
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (username == null || username.isEmpty) return;
    try {
      await _userService.updateUsername(username: username);
      _reloadProfile();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update username: $error')),
      );
    }
  }

  Future<void> _changePassword(User user) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final passwords = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
              currentController.text,
              newController.text,
            )),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    currentController.dispose();
    newController.dispose();
    if (passwords == null) return;
    if (passwords.$1.isEmpty || passwords.$2.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Use a current password and a 6+ character new password.',
          ),
        ),
      );
      return;
    }
    try {
      await _userService.resetPasswordFromCurrentPassword(
        email: user.email,
        currentPassword: passwords.$1,
        newPassword: passwords.$2,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update password: $error')),
      );
    }
  }

  Future<void> _deleteAccount(User user) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm your password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty) return;
    try {
      await _userService.deleteAccount(email: user.email, password: password);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/signin', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete account: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text('No signed-in user found.'));
        }
        return _ProfileBody(
          user: user,
          onUpdateUsername: () => _updateUsername(user),
          onChangePassword: () => _changePassword(user),
          onDeleteAccount: () => _deleteAccount(user),
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.onUpdateUsername,
    required this.onChangePassword,
    required this.onDeleteAccount,
  });

  final User user;
  final VoidCallback onUpdateUsername;
  final VoidCallback onChangePassword;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFirebase = user.loginType == LoginType.firebase;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Enhancement 3: profile data is retrieved through UserService.getUserData.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _UserAvatar(imageUrl: user.image),
                const SizedBox(height: 16),
                Text(
                  user.fullName.isEmpty ? user.username : user.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: colors.primary),
                ),
                const SizedBox(height: 12),
                Chip(
                  avatar: Icon(
                    isFirebase ? Icons.cloud_outlined : Icons.api_outlined,
                    size: 18,
                  ),
                  label: Text(
                    isFirebase ? 'Firebase account' : 'DummyJSON account',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              _ProfileRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              const Divider(height: 1),
              _ProfileRow(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: user.age?.toString() ?? 'Not provided',
              ),
              const Divider(height: 1),
              _ProfileRow(
                icon: Icons.phone_outlined,
                label: 'Contact number',
                value: user.contactNo.isEmpty ? 'Not provided' : user.contactNo,
              ),
              if (!isFirebase) ...[
                const Divider(height: 1),
                _ProfileRow(
                  icon: Icons.badge_outlined,
                  label: 'DummyJSON user ID',
                  value: '#${user.id}',
                ),
              ],
            ],
          ),
        ),
        if (isFirebase) ...[
          const SizedBox(height: 20),
          Text(
            'Account controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Update username'),
                  onTap: onUpdateUsername,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.password_outlined),
                  title: const Text('Change password'),
                  onTap: onChangePassword,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colors.error),
                  title: Text(
                    'Delete account',
                    style: TextStyle(color: colors.error),
                  ),
                  onTap: onDeleteAccount,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 52,
        child: Icon(Icons.person, size: 52),
      );
    }
    return CircleAvatar(
      radius: 52,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, _) {},
      child: const SizedBox.expand(),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
