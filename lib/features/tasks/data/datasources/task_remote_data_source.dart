import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(
    String userId, {
    int skip = 0,
    int limit = 10,
  });
  Future<TaskModel> addTask(String userId, TaskModel task);
  Future<TaskModel> updateTask(String userId, TaskModel task);
  Future<void> deleteTask(String userId, int taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<List<TaskModel>> getTasks(
    String userId, {
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/tasks/',
        queryParameters: {'user_id': userId, 'skip': skip, 'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch tasks');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TaskModel> addTask(String userId, TaskModel task) async {
    try {
      final response = await _dioClient.post(
        '/tasks/',
        queryParameters: {'user_id': userId},
        data: task.toJson(),
      );
      final responseData = response.data['data'] ?? response.data;
      return TaskModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to add task');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TaskModel> updateTask(String userId, TaskModel task) async {
    try {
      final response = await _dioClient.put(
        '/tasks/${task.id}',
        queryParameters: {'user_id': userId},
        data: task.toJson(),
      );
      final responseData = response.data['data'] ?? response.data;
      return TaskModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update task');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteTask(String userId, int taskId) async {
    try {
      await _dioClient.delete(
        '/tasks/$taskId',
        queryParameters: {'user_id': userId},
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete task');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}
