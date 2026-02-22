import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 16),
              Text(profile.name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                profile.email,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile Name'),
                onTap: () {
                  _showEditNameDialog(context, ref, profile.id, profile.name);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme Mode'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      ref.read(themeModeProvider.notifier).setTheme(newMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref, String userId, String currentName) async {
    final controller = TextEditingController(text: currentName);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                await ref.read(profileRepositoryProvider).updateProfile(userId, newName);
                ref.invalidate(currentUserProfileProvider);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
