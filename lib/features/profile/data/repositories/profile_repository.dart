import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;


  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.id).set(profile.toMap());
  }

  Future<void> updateUserTheme(String userId, String themeMode) async {
    await _firestore.collection('users').doc(userId).update({'themeMode': themeMode});
  }
  
  Future<void> updateProfile(String userId, String name) async {
    await _firestore.collection('users').doc(userId).update({
      'name': name,
    });
  }
}
