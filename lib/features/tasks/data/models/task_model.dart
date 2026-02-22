import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      dueDate: entity.dueDate,
      priority: entity.priority,
      category: entity.category,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.isCompleted,
    super.dueDate,
    required super.priority,
    required super.category,
    required super.userId,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      priority: json['priority'] as String? ?? 'Medium',
      category: json['category'] as String? ?? 'Work',
      userId: json['user_id'] as String,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
      'user_id': userId,
    };
  }
}
