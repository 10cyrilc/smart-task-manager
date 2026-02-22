import '../../domain/entities/task_entity.dart';

enum TaskFilter { all, completed, pending }

enum TaskSort { dueDate, priority, createdDate }

class TaskState {
  const TaskState({
    this.tasks = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.skip = 0,
    this.limit = 10,
    this.filter = TaskFilter.all,
    this.searchQuery = '',
    this.sort = TaskSort.createdDate,
  });
  final List<TaskEntity> tasks;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int skip;
  final int limit;
  final TaskFilter filter;
  final String searchQuery;
  final TaskSort sort;

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? skip,
    int? limit,
    TaskFilter? filter,
    String? searchQuery,
    TaskSort? sort,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
    );
  }

  /// Helper to get the currently filtered and sorted tasks for the UI
  List<TaskEntity> get filteredAndSortedTasks {
    List<TaskEntity> result = List.from(tasks);

    // 1. Search (Title)
    if (searchQuery.isNotEmpty) {
      result = result
          .where(
            (t) => t.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // 2. Filter
    if (filter == TaskFilter.completed) {
      result = result.where((t) => t.isCompleted).toList();
    } else if (filter == TaskFilter.pending) {
      result = result.where((t) => !t.isCompleted).toList();
    }

    // 3. Sort
    switch (sort) {
      case TaskSort.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.priority:
        final Map<String, int> priorityValues = {
          'High': 1,
          'Medium': 2,
          'Low': 3,
        };
        result.sort((a, b) {
          final int valA = priorityValues[a.priority] ?? 4;
          final int valB = priorityValues[b.priority] ?? 4;
          return valA.compareTo(valB);
        });
        break;
      case TaskSort.createdDate:
        result.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!); // Descending mostly
        });
        break;
    }

    return result;
  }
}
