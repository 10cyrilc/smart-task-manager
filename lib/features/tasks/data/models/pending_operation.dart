import '../models/task_model.dart';

enum SyncOperationType { add, update, delete }

class PendingOperation {

  const PendingOperation({
    required this.id,
    required this.type,
    required this.task,
    required this.userId,
  });

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as int,
      type: SyncOperationType.values.firstWhere((e) => e.name == json['type']),
      task: TaskModel.fromJson(json['task']),
      userId: json['userId'] as String,
    );
  }
  final SyncOperationType type;
  final TaskModel task;
  final String userId;
  final int id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'task': task.toJson(),
      'userId': userId,
    };
  }
}
