import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthUser> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<AuthUser> register(String email, String password, String name) {
    return _remoteDataSource.register(email, password, name);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  AuthUser? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges;
  }
}
