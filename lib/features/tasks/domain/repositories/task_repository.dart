import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks(String userId, {int skip = 0, int limit = 10});
  Future<TaskEntity> addTask(String userId, TaskEntity task);
  Future<TaskEntity> updateTask(String userId, TaskEntity task);
  Future<void> deleteTask(String userId, int taskId);
}
