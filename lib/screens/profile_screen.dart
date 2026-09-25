import 'package:flutter/material.dart';

import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user, required this.onLogout});

  final User user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Enhancement 3: the profile is rendered from the saved User model.
        Card(
          clipBehavior: Clip.antiAlias,
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
                icon: Icons.wc_outlined,
                label: 'Gender',
                value: user.gender,
              ),
              const Divider(height: 1),
              _ProfileRow(
                icon: Icons.badge_outlined,
                label: 'User ID',
                value: '#${user.id}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async => onLogout(),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
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
