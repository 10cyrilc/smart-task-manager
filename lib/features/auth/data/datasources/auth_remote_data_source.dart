import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUser> login(String email, String password);
  Future<AuthUser> register(String email, String password, String name);
  Future<void> logout();
  AuthUser? getCurrentUser();
  Stream<AuthUser?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl(this._firebaseAuth);

  AuthUser _mapFirebaseUser(fb_auth.User user) {
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  void _handleFirebaseException(fb_auth.FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided for that user.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      default:
        message = e.message ?? 'An unknown authentication error occurred.';
    }
    throw AuthException(message, code: e.code);
  }

  @override
  Future<AuthUser> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException('Login failed: User is null.');
      }
      return _mapFirebaseUser(userCredential.user!);
    } on fb_auth.FirebaseAuthException catch (e) {
      _handleFirebaseException(e);
      throw AuthException(e.message ?? 'Unknown auth error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthUser> register(String email, String password, String name) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException('Registration failed: User is null.');
      }
      
      // Update display name
      await userCredential.user!.updateDisplayName(name);
      
      return AuthUser(
        id: userCredential.user!.uid,
        email: email,
        displayName: name,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      _handleFirebaseException(e);
      throw AuthException(e.message ?? 'Unknown error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  AuthUser? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _mapFirebaseUser(user);
    }
    return null;
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }
}
