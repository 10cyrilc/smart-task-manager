import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_state.dart';
import '../providers/task_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(taskControllerProvider.notifier).loadMore();
    }
  }

  void /**/_onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(taskControllerProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineProvider);
    final taskStateAsync = ref.watch(taskControllerProvider);

    // Sync strategy on connection restored
    ref.listen(connectivityProvider, (previous, next) {
      final wasOffline = previous?.value?.contains(ConnectivityResult.none) ?? false;
      final isNowOnline = next.value != null && !next.value!.contains(ConnectivityResult.none);

      if (wasOffline && isNowOnline) {
        ref.read(offlineSyncServiceProvider).syncPendingOperations().then((_) {
          ref.read(taskControllerProvider.notifier).refresh();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => context.push('/profile')),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(ref),
                const SizedBox(width: 8),
                _buildSortDropdown(ref),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              color: Colors.redAccent,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'You are offline. Showing cached tasks.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: taskStateAsync.when(
              data: (state) {
                final tasks = state.filteredAndSortedTasks;

                if (tasks.isEmpty && !state.isLoadingMore) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(taskControllerProvider.notifier).refresh();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.task_alt, size: 80, color: Theme.of(context).colorScheme.primaryContainer),
                                const SizedBox(height: 16),
                                Text('No tasks found.', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                const Text('Enjoy your free time or add a new task!'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(taskControllerProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: tasks.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == tasks.length) {
                        return const Center(
                          child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
                        );
                      }

                      final task = tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (bool? val) {
                            if (val != null) {
                              ref.read(taskControllerProvider.notifier).updateTask(task.copyWith(isCompleted: val));
                            }
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
                        ),
                        subtitle: Text('${task.category} • Priority: ${task.priority}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddTaskDialog(context, ref, task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref.read(taskControllerProvider.notifier).deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () => ref.read(taskControllerProvider.notifier).refresh(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref, [TaskEntity? task]) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    String priority = task?.priority ?? 'Medium';
    String category = task?.category ?? 'Work';
    DateTime? dueDate = task?.dueDate;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'Edit Task' : 'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      title: Text(dueDate == null ? 'Select Due Date' : 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => dueDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: priority,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'High', child: Text('High')),
                              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                              DropdownMenuItem(value: 'Low', child: Text('Low')),
                            ],
                            onChanged: (val) => setState(() => priority = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: category,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Work', child: Text('Work')),
                              DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (val) => setState(() => category = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final newTask = TaskEntity(
                          id: isEditing ? task.id : 0,
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          isCompleted: isEditing && task.isCompleted,
                          priority: priority,
                          category: category,
                          userId: isEditing ? task.userId : '',
                          createdAt: isEditing ? task.createdAt : DateTime.now(),
                          dueDate: dueDate,
                        );

                        if (isEditing) {
                          ref.read(taskControllerProvider.notifier).updateTask(newTask);
                        } else {
                          ref.read(taskControllerProvider.notifier).addTask(newTask);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(isEditing ? 'Save Changes' : 'Create Task', style: const TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(WidgetRef ref) {
    final stateInfo = ref.watch(taskControllerProvider).value;
    final filter = stateInfo?.filter ?? TaskFilter.all;

    return DropdownButton<TaskFilter>(
      value: filter,
      icon: const Icon(Icons.filter_list),
      underline: const SizedBox(),
      onChanged: (TaskFilter? newFilter) {
        if (newFilter != null) {
          ref.read(taskControllerProvider.notifier).setFilter(newFilter);
        }
      },
      items: TaskFilter.values.map((f) {
        return DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()));
      }).toList(),
    );
  }

  Widget _buildSortDropdown(WidgetRef ref) {
    final stateInfo = ref.watch(taskControllerProvider).value;
    final sort = stateInfo?.sort ?? TaskSort.createdDate;

    return DropdownButton<TaskSort>(
      value: sort,
      icon: const Icon(Icons.sort),
      underline: const SizedBox(),
      onChanged: (TaskSort? newSort) {
        if (newSort != null) {
          ref.read(taskControllerProvider.notifier).setSort(newSort);
        }
      },
      items: TaskSort.values.map((s) {
        return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()));
      }).toList(),
    );
  }
}
