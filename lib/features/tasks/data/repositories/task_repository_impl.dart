import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/offline_sync_data_source.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/pending_operation.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {

  TaskRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._offlineSyncDataSource,
    this._connectivity,
  );
  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final OfflineSyncDataSource _offlineSyncDataSource;
  final Connectivity _connectivity;

  Future<bool> get _isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<TaskEntity>> getTasks(String userId, {int skip = 0, int limit = 10}) async {
    if (await _isConnected) {
      try {
        final remoteTasks = await _remoteDataSource.getTasks(userId, skip: skip, limit: limit);
        if (skip == 0) {
          await _localDataSource.cacheTasks(remoteTasks);
        }
        return remoteTasks;
      } catch (e) {
        return _localDataSource.getCachedTasks();
      }
    } else {
      final localTasks = await _localDataSource.getCachedTasks();
      if (localTasks.isEmpty && skip == 0) {
        throw const CacheException('No cached tasks available.');
      }
      return localTasks;
    }
  }

  @override
  Future<TaskEntity> addTask(String userId, TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    if (await _isConnected) {
      final added = await _remoteDataSource.addTask(userId, taskModel);
      await _appendLocalCache(added);
      return added;
    } else {
      // Queue offline
      final localId = DateTime.now().millisecondsSinceEpoch;
      final offlineTask = TaskModel.fromEntity(task.copyWith(id: localId));
      
      await _offlineSyncDataSource.addOperation(
        PendingOperation(id: localId, type: SyncOperationType.add, task: offlineTask, userId: userId)
      );
      
      await _appendLocalCache(offlineTask);
      return offlineTask;
    }
  }

  @override
  Future<TaskEntity> updateTask(String userId, TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    if (await _isConnected) {
      final updated = await _remoteDataSource.updateTask(userId, taskModel);
      await _updateLocalCache(updated);
      return updated;
    } else {
      // Queue offline
      await _offlineSyncDataSource.addOperation(
        PendingOperation(id: task.id, type: SyncOperationType.update, task: taskModel, userId: userId)
      );
      
      await _updateLocalCache(taskModel);
      return taskModel;
    }
  }

  @override
  Future<void> deleteTask(String userId, int taskId) async {
    if (await _isConnected) {
      await _remoteDataSource.deleteTask(userId, taskId);
      await _deleteLocalCache(taskId);
    } else {
      final dummyTask = TaskModel(id: taskId, title: '', isCompleted: false, priority: '', category: '', userId: userId);
      await _offlineSyncDataSource.addOperation(
        PendingOperation(id: taskId, type: SyncOperationType.delete, task: dummyTask, userId: userId)
      );
      await _deleteLocalCache(taskId);
    }
  }

  // --- Local Cache Helpers ---
  Future<void> _appendLocalCache(TaskModel task) async {
    final cached = await _localDataSource.getCachedTasks();
    cached.insert(0, task);
    await _localDataSource.cacheTasks(cached);
  }

  Future<void> _updateLocalCache(TaskModel task) async {
    final cached = await _localDataSource.getCachedTasks();
    final index = cached.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      cached[index] = task;
      await _localDataSource.cacheTasks(cached);
    }
  }

  Future<void> _deleteLocalCache(int taskId) async {
    final cached = await _localDataSource.getCachedTasks();
    cached.removeWhere((t) => t.id == taskId);
    await _localDataSource.cacheTasks(cached);
  }
}
