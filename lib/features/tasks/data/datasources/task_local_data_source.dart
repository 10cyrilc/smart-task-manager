import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<List<TaskModel>> getCachedTasks();
  Future<void> clearTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String _boxName = 'tasks_box';
  static const String _cachedTasksKey = 'cached_tasks';

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final box = await Hive.openBox(_boxName);
    final List<Map<String, dynamic>> jsonList = tasks
        .map((t) => t.toJson())
        .toList();
    final String jsonString = jsonEncode(jsonList);
    await box.put(_cachedTasksKey, jsonString);
  }

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    final box = await Hive.openBox(_boxName);
    final jsonString = box.get(_cachedTasksKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> clearTasks() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_cachedTasksKey);
  }
}
