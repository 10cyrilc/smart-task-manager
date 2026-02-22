class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDate,
    required this.priority,
    required this.category,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final String priority;
  final String category;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
    String? category,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
