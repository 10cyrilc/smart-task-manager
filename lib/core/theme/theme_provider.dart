import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/profile/presentation/providers/profile_providers.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    _loadThemeFromProfile();
    return ThemeMode.system;
  }

  Future<void> _loadThemeFromProfile() async {
    final profile = await ref.watch(currentUserProfileProvider.future);
    if (profile != null) {
      if (profile.themeMode == 'light') {
        state = ThemeMode.light;
      } else if (profile.themeMode == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile != null) {
      final String modeString = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system';
      await ref
          .read(profileRepositoryProvider)
          .updateUserTheme(profile.id, modeString);
    }
  }
}
