import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import 'task_state.dart';

part 'task_controller.g.dart';

@riverpod
class TaskController extends _$TaskController {
  @override
  FutureOr<TaskState> build() async {
    return _fetchInitialTasks();
  }

  Future<TaskState> _fetchInitialTasks() async {
    final user = await ref.watch(authStateChangesProvider.future);
    if (user == null) {
      return const TaskState();
    }

    final repo = ref.watch(taskRepositoryProvider);
    const limit = 10;

    final tasks = await repo.getTasks(user.id);

    return TaskState(
      tasks: tasks,
      skip: tasks.length,
      hasReachedMax: tasks.length < limit,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    final user = await ref.read(authStateChangesProvider.future);
    if (user == null) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(taskRepositoryProvider);
      final newTasks = await repo.getTasks(
        user.id,
        skip: currentState.skip,
        limit: currentState.limit,
      );

      state = AsyncData(
        currentState.copyWith(
          tasks: [...currentState.tasks, ...newTasks],
          skip: currentState.skip + newTasks.length,
          hasReachedMax: newTasks.length < currentState.limit,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      // Re-throw if UI should catch, but generally we suppress loadMore errors or flag them in state
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchInitialTasks);
  }

  void setFilter(TaskFilter filter) {
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(filter: filter));
    }
  }

  void setSearchQuery(String query) {
    if (state.value != null) {
      // For debouncing, UI will handle dispatching this function with delay
      state = AsyncData(state.value!.copyWith(searchQuery: query));
    }
  }

  void setSort(TaskSort sort) {
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(sort: sort));
    }
  }

  Future<void> addTask(TaskEntity task) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic Update
    final tempTasks = [task, ...currentState.tasks];
    state = AsyncData(currentState.copyWith(tasks: tempTasks));

    try {
      final user = await ref.read(authStateChangesProvider.future);
      if (user == null) return;

      final repo = ref.read(taskRepositoryProvider);
      final addedTask = await repo.addTask(user.id, task);

      // Exchange optimistic item with the one fetched from API
      // Match by the temporary ID we created for optimistic update.
      final finalTasks = state.value!.tasks
          .map((t) => t.id == task.id ? addedTask : t)
          .toList();
      state = AsyncData(state.value!.copyWith(tasks: finalTasks));
    } catch (e) {
      // Revert Optimistic Update
      state = AsyncData(currentState);
      throw ErrorMapper.mapExceptionToFailure(e as Exception);
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic Update
    final tempTasks = currentState.tasks
        .map((t) => t.id == task.id ? task : t)
        .toList();
    state = AsyncData(currentState.copyWith(tasks: tempTasks));

    try {
      final user = await ref.read(authStateChangesProvider.future);
      if (user == null) return;

      final repo = ref.read(taskRepositoryProvider);
      final updatedTask = await repo.updateTask(user.id, task);

      final finalTasks = state.value!.tasks
          .map((t) => t.id == task.id ? updatedTask : t)
          .toList();
      state = AsyncData(state.value!.copyWith(tasks: finalTasks));
    } catch (e) {
      state = AsyncData(currentState);
      throw ErrorMapper.mapExceptionToFailure(e as Exception);
    }
  }

  Future<void> deleteTask(int taskId) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic Update
    final tempTasks = currentState.tasks.where((t) => t.id != taskId).toList();
    state = AsyncData(currentState.copyWith(tasks: tempTasks));

    try {
      final user = await ref.read(authStateChangesProvider.future);
      if (user == null) return;

      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(user.id, taskId);
    } catch (e) {
      state = AsyncData(currentState);
      throw ErrorMapper.mapExceptionToFailure(e as Exception);
    }
  }
}
