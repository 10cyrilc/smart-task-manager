import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/auth_providers.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial state is void, representing no ongoing auth action
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final loginUseCase = ref.read(loginUseCaseProvider);
        await loginUseCase.execute(email, password);
      } on Exception catch (e) {
        final failure = ErrorMapper.mapExceptionToFailure(e);
        throw failure;
      }
    });
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final registerUseCase = ref.read(registerUseCaseProvider);
        final profileRepository = ref.read(profileRepositoryProvider);

        final user = await registerUseCase.execute(email, password, name);

        await profileRepository.createUserProfile(
          UserProfile(
            id: user.id,
            email: user.email,
            name: name,
            createdAt: DateTime.now(),
            themeMode: 'system',
          ),
        );
      } on Exception catch (e) {
        final failure = ErrorMapper.mapExceptionToFailure(e);
        throw failure;
      }
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final logoutUseCase = ref.read(logoutUseCaseProvider);
        await logoutUseCase.execute();
      } on Exception catch (e) {
        final failure = ErrorMapper.mapExceptionToFailure(e);
        throw failure;
      }
    });
  }
}
