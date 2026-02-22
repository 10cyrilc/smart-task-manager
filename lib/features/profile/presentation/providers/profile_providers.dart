import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Future<UserProfile?> currentUserProfile(Ref ref) async {
  final authUser = await ref.watch(authStateChangesProvider.future);

  if (authUser == null) {
    return null;
  }

  final profileRepo = ref.watch(profileRepositoryProvider);
  final profile = await profileRepo.getUserProfile(authUser.id);

  return profile;
}
